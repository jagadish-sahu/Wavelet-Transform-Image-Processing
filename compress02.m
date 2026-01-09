% Wavelet-based image compression in MATLAB
I = im2double(imread('original_image.png'));  % Input grayscale image
wname = 'db2';                             % Wavelet family
level = 3;                                 % Decomposition level

% 1. Perform 2D wavelet decomposition
[C, S] = wavedec2(I, level, wname);

% 2. Retain top 10% of largest coefficients
keep_ratio = 0.10;
absC = abs(C);
sortedC = sort(absC, 'descend');
thresh = sortedC(round(keep_ratio * numel(C)));
Cc = C;
Cc(absC < thresh) = 0;

% 3. Reconstruct the compressed image
I_rec = waverec2(Cc, S, wname);
I_rec = min(max(I_rec, 0), 1);             % Clip values to [0,1]

% 4. Evaluate quality
psnr_val = psnr(I_rec, I);
ssim_val = ssim(I_rec, I);

% 5. Display results
subplot(1,3,1), imshow(I), title('Original');
subplot(1,3,2), imshow(I_rec), title('Compressed (10% coefficients)');
subplot(1,3,3), imshow(abs(I - I_rec), []), title('Error Map');
fprintf('PSNR: %.2f dB, SSIM: %.4f\n', psnr_val, ssim_val);


