% wavelet_compare.m
close all; clear; clc;
I = im2double(imread('cameraman.tif'));  % swap to img_01.jpg if you want RGB->gray first
wlist = {'db2', 'sym4', 'sym8', 'coif3', 'bior4.4'}; 
levels = [1 2 3];
keep_ratio = 0.1;   % keep 10% -- change to test sensitivity

results = zeros(length(wlist), length(levels));

for wi = 1:length(wlist)
    for li = 1:length(levels)
        wname = wlist{wi};
        level = levels(li);
        [C, S] = wavedec2(I, level, wname);
        absC = abs(C);
        sortedC = sort(absC,'descend');
        idx = max(1, round(keep_ratio * numel(C)));
        thresh = sortedC(idx);
        Cc = C .* (absC >= thresh);
        I_rec = waverec2(Cc, S, wname);
        I_rec = min(max(I_rec,0),1);
        results(wi, li) = psnr(I_rec, I);
    end
end

% Display results
disp('PSNR (dB) table: rows=wavelets, cols=levels');
disp(array2table(results, 'RowNames', wlist, 'VariableNames', cellstr(string(levels))));
% Show best combo
[maxPSNR, idx] = max(results(:));
[r, c] = ind2sub(size(results), idx);
fprintf('Best: %s at level %d → PSNR = %.3f dB\n', wlist{r}, levels(c), maxPSNR);
