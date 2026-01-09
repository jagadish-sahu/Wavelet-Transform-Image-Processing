% Read the input image
inputImage = imread('img_01.jpg'); % Replace 'example.jpg' with your image file
grayImage = rgb2gray(inputImage);  % Convert to grayscale if it's a color image

% Perform 2D Wavelet Decomposition
[coeffs, S] = wavedec2(grayImage, 2, 'haar'); % 2-level Haar wavelet decomposition

% Thresholding for Compression
threshold = 100; % Adjust threshold for desired compression level
coeffs(abs(coeffs) < threshold) = 0; % Set small coefficients to zero

% Reconstruct the Image
compressedImage = waverec2(coeffs, S, 'haar');

% Display Original and Compressed Images
figure;
subplot(1, 2, 1);
imshow(grayImage, []);
title('Original Image');

subplot(1, 2, 2);
imshow(uint8(compressedImage), []);
title('Compressed Image');

% Calculate Compression Ratio
originalSize = numel(grayImage);
compressedSize = nnz(coeffs); % Non-zero coefficients
compressionRatio = originalSize / compressedSize;
disp(['Compression Ratio: ', num2str(compressionRatio)]);
