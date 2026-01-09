% coeff_encode_estimate.m
close all; clear; clc;
I = im2double(imread('cameraman.tif'));   % grayscale example
% Parameters
wname = 'db2';
level = 3;
keep_ratio = 0.1;   % same as used above
Qlevels = 256;      % quantize kept coeffs to 256 levels (1 byte)
% 1. Wavelet decompose
[C, S] = wavedec2(I, level, wname);
Ncoeff = numel(C);

% 2. Thresholding (keep biggest magnitudes)
absC = abs(C);
sortedC = sort(absC, 'descend');
idx = max(1, round(keep_ratio * Ncoeff));
thresh = sortedC(idx);
Ck = C;
Ck(absC < thresh) = 0;

% 3. Quantize nonzero coefficients uniformly
% Determine dynamic range of remaining (nonzero) coeffs
vals = Ck(Ck~=0);
if isempty(vals)
    error('No coefficients kept. Increase keep_ratio.');
end
minv = min(vals); maxv = max(vals);
% map to signed integers in range -(Qlevels/2-1)..(Qlevels/2)
levels = Qlevels;
scale = (levels-1) / (maxv - minv + eps);
qvals = round((vals - minv) * scale) - floor(levels/2);
% write back quantized values
Cq = Ck;
Cq(Ck~=0) = qvals;

% 4. Simple run-length encode flattened vector (zeros & nonzeros)
vec = Cq(:);
% RLE format: pairs (run_length, value) where run_length is count of zeros preceding a nonzero value
runs = []; vals_out = [];
cnt = 0;
for i = 1:length(vec)
    if vec(i) == 0
        cnt = cnt + 1;
    else
        runs = [runs; cnt];    % zeros before this value
        vals_out = [vals_out; vec(i)];
        cnt = 0;
    end
end
% tail zeros can be encoded as final run (we'll store it too)
tailzeros = cnt;

% 5. Estimate bytes: assume
% - store runs as uint16 (2 bytes each)
% - store vals_out as int16 (2 bytes each)
% - store tailzeros as uint16
bytes_runs = 2 * numel(runs);
bytes_vals = 2 * numel(vals_out);
bytes_tail = 2;
header_bytes = 64; % small header overhead
total_bytes_est = header_bytes + bytes_runs + bytes_vals + bytes_tail;

% 6. Baseline original size: assume 8-bit grayscale image
orig_bytes = numel(I);  % one byte per pixel

fprintf('Keep ratio: %.2f, quantization levels: %d\n', keep_ratio, Qlevels);
fprintf('Kept coeffs: %d / %d (%.3f%%)\n', numel(vals_out), Ncoeff, 100*numel(vals_out)/Ncoeff);
fprintf('Estimated compressed bytes (RLE+quant): %d bytes\n', total_bytes_est);
fprintf('Original (8-bit) bytes: %d bytes\n', orig_bytes);
fprintf('Estimated compression ratio: %.2f : 1\n', orig_bytes / total_bytes_est);
