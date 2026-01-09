% Improved wavelet compression demo
I = im2double(imread('gray_img_02.jpg'));   % ensure grayscale MxN, values in [0,1]
wname = 'db2';
level = 3;

% 1) Decompose
[C, S] = wavedec2(I, level, wname);

% 2) Thresholding: keep top X% coefficients
keep_ratio = 0.10;            % keep 10%
absC = abs(C);
N = numel(C);
idx = max(1, round(keep_ratio * N));   % guard idx >= 1
sortedC = sort(absC, 'descend');
thresh = sortedC(idx);

% 3) Zero-out small coefficients (work on a copy)
Cc = C;
Cc(absC < thresh) = 0;

% Optional: compute actual kept ratio
kept = nnz(Cc);
actual_keep = kept / N;

% 4) Reconstruct
I_rec = waverec2(Cc, S, wname);
I_rec = min(max(I_rec, 0), 1);   % clip to [0,1]

% 5) Metrics & display
psnr_val = psnr(I_rec, I);
ssim_val = ssim(I_rec, I);

fprintf('Requested keep_ratio = %.3f, actual kept = %d/%d (%.3f%%)\n', ...
        keep_ratio, kept, N, actual_keep*100);
fprintf('PSNR = %.3f dB, SSIM = %.4f\n', psnr_val, ssim_val);

figure;
subplot(1,3,1), imshow(I), title('Original'), colormap gray, axis image off;
subplot(1,3,2), imshow(I_rec), title(sprintf('Compressed (kept %.2f%%)', actual_keep*100)), colormap gray, axis image off;
subplot(1,3,3), imshow(abs(I - I_rec), []), title('Absolute Error'), axis image off;
