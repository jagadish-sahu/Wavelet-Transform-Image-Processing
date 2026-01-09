% rate_distortion.m
close all; clear; clc;
I = im2double(imread('gray_img_01.jpg'));   % use your image if you want
wname = 'db2';
level = 3;
[C, S] = wavedec2(I, level, wname);

keep_list = [0.01 0.02 0.03 0.04 0.05 0.1 0.2 0.3 0.4 0.5];  % fractions to test
PSNRs = zeros(size(keep_list));
Ncoeff = numel(C);

absC = abs(C);
sortedC = sort(absC, 'descend');

for k = 1:length(keep_list)
    keep_ratio = keep_list(k);
    idx = max(1, round(keep_ratio * Ncoeff));
    thresh = sortedC(idx);
    Cc = C .* (absC >= thresh);
    I_rec = waverec2(Cc, S, wname);
    I_rec = min(max(I_rec,0),1);
    PSNRs(k) = psnr(I_rec, I);
end

figure;
plot(keep_list*100, PSNRs, '-o','LineWidth',1.4);
xlabel('Kept coefficients (%)'); ylabel('PSNR (dB)');
title('Rate–Distortion: PSNR vs % kept coefficients'); grid on;

% Print summary table
fprintf('Kept(%%)\tPSNR(dB)\n');
for k=1:length(keep_list)
    fprintf('%.2f\t\t%.3f\n', keep_list(k)*100, PSNRs(k));
end
