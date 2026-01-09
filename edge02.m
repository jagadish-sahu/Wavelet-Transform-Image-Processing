I = imread('img_01.jpg');     % Read input image
I = rgb2gray(I);              % Convert to grayscale if needed

% --- Wavelet Decomposition ---
[LL, LH, HL, HH] = dwt2(I, 'db2');   % Daubechies (db2) wavelet
figure;
subplot(2,2,1), imshow(mat2gray(LL)), title('Approximation (LL)');
subplot(2,2,2), imshow(mat2gray(LH)), title('Horizontal Detail (LH)');
subplot(2,2,3), imshow(mat2gray(HL)), title('Vertical Detail (HL)');
subplot(2,2,4), imshow(mat2gray(HH)), title('Diagonal Detail (HH)');

% --- Compute Texture Features ---
subbands = {LL, LH, HL, HH};
names = {'LL','LH','HL','HH'};

for i = 1:4
E = sum(sum(subbands{i}.^2));        % Energy
Ent = entropy(mat2gray(subbands{i}));% Entropy
M = mean2(subbands{i});              % Mean
SD = std2(subbands{i});              % Std. deviation
fprintf('%s -> Energy: %.2f, Entropy: %.3f, Mean: %.3f, Std: %.3f\n', ...
names{i}, E, Ent, M, SD);
end

% --- Plot Energy and Entropy ---
Energy = zeros(1,4);
EntropyVal = zeros(1,4);
for i = 1:4
Energy(i) = sum(sum(subbands{i}.^2));
EntropyVal(i) = entropy(mat2gray(subbands{i}));
end

figure;
subplot(1,2,1);
bar(Energy);
set(gca,'XTickLabel',names);
title('Wavelet Subband Energy');
xlabel('Subband'); ylabel('Energy');

subplot(1,2,2);
bar(EntropyVal);
set(gca,'XTickLabel',names);
title('Wavelet Subband Entropy');
xlabel('Subband'); ylabel('Entropy');