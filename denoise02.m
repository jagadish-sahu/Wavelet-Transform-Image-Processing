% Read clean grayscale image
I_clean = im2double(imread('img_03.jpg'));   % Load image and convert to [0,1]
if size(I_clean,3) > 1                            % If the image is RGB...
    I_clean = rgb2gray(I_clean);                  % ...convert it to grayscale
end

% Add Gaussian noise
rng(42);                                          % Fix seed for reproducibility
I_noisy = imnoise(I_clean, 'gaussian', 0, 0.15^2);% Add AWGN with variance 0.15^2

% Wavelets to test (orthogonal + biorthogonal families)
wavelets = {'haar','db2','db4','sym4','coif1','bior4.4','rbio4.4'};

% Decomposition levels to test
levels = [1 2 3];
% Loop over each wavelet and level
for k = 1:length(wavelets)
    for L = levels
        % Wavelet denoising using BayesShrink + Soft thresholding
        I_rec = wdenoise2(I_noisy, L, ...
            'Wavelet', wavelets{k}, ...
            'DenoisingMethod','Bayes', ...
            'ThresholdRule','Soft');
        
        % Evaluate reconstruction quality
        ps = psnr(I_rec, I_clean);        % Peak Signal-to-Noise Ratio
        ss = ssim(I_rec, I_clean);        % Structural Similarity Index
        
        % Print results
        fprintf('Wav:%-7s | L:%d | PSNR: %.2f dB | SSIM: %.4f\n', ...
            wavelets{k}, L, ps, ss);
    end
end
