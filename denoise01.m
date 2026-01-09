% Read and prepare grayscale image
I_noisy = im2double(imread('img_03.jpg'));

% Add Gaussian noise with variance 0.15^2
I_noisy = imnoise(I_noisy, 'gaussian', 0, 0.2^2);

% Wavelet denoising using 2-level decomposition
I_rec = wdenoise2(I_noisy, 2, ...
    'Wavelet', 'bior4.4', ...
    'DenoisingMethod', 'Bayes', ...
    'ThresholdRule', 'Soft');

% Display noisy and reconstructed images
figure; 
imshowpair(I_noisy, I_rec, 'montage');
title('Noisy (left) vs wdenoise2 result (right)');

% Save the denoised image
imwrite(I_rec, 'gray_img_01_denoised.jpg');

imwrite(I_noisy, 'gray_img_01_noised.jpg');

% Save the comparison figure
saveas(gcf, 'gray_img_01_comparison.png');
