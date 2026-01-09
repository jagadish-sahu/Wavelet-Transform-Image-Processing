% wavelet_edge_texture_final.m

clearvars; close all; clc;
set(0,'DefaultFigurePosition',[100 100 900 650]);

% -----------------------------
% User parameters - edit here
% -----------------------------
imgname   = 'img_02.jpg'; % replace with your filename (or leave to use fallback)
wname     = 'db4';        % wavelet name (db4, sym4, haar, etc.)
levels    = 3;            % number of decomposition levels (integer >=1)
th_factor = 3;            % threshold multiplier for edge detection (tune 1.5-4)
out_prefix = 'wavelet_fig'; % prefix for saved files
% -----------------------------

% --- Check for Wavelet Toolbox (wavedec2, detcoef2, appcoef2)
v = ver;
hasWavelet = any(strcmp({v.Name}, 'Wavelet Toolbox'));
if ~hasWavelet
    error('Wavelet Toolbox is required (wavedec2, detcoef2, appcoef2).');
end

% --- Read and prepare image (fallback to sample)
if ~isfile(imgname)
    warning('Image "%s" not found — using builtin "cameraman.tif" as fallback.', imgname);
    I = imread('cameraman.tif');
else
    I = imread(imgname);
end

% Convert to grayscale double
if size(I,3) == 3
    Igray = rgb2gray(I);
else
    Igray = I;
end
Igray = im2double(Igray);

% --- 2-D wavelet decomposition
[C,S] = wavedec2(Igray, levels, wname);

% Preallocate containers
edge_maps = cell(levels,1);
energy_features = zeros(levels,3); % columns: [H, V, D]

% Loop through levels and compute detail maps + energies
for lev = 1:levels
    % Extract detail coefficients for this level: H (horizontal), V (vertical), D (diagonal)
    [H, V, D] = detcoef2('all', C, S, lev);

    % Compute energy of each subband (texture descriptor)
    energy_features(lev,1) = sum(H(:).^2);
    energy_features(lev,2) = sum(V(:).^2);
    energy_features(lev,3) = sum(D(:).^2);

    % Compute simple gradient magnitude for edges (H and V carry orientation info)
    G = sqrt(H.^2 + V.^2);

    % Robust noise estimate and threshold (MAD-based)
    sigma = median(abs(G(:))) / 0.6745;
    if sigma == 0
        T = th_factor * eps; % fallback tiny threshold to avoid all-zero
    else
        T = th_factor * sigma;
    end

    % Resize G to original image size for visualization and thresholding consistency
    G_resized = imresize(G, size(Igray), 'bilinear'); 
    edge_maps{lev} = G_resized > T;
end

% Combine multi-scale edges (logical OR)
multi_edge = false(size(Igray));
for lev = 1:levels
    multi_edge = multi_edge | edge_maps{lev};
end

% -----------------------------
% Visualization & Saving
% -----------------------------

% 1) Original and overlay (edges in red)
rgb = repmat(Igray, [1 1 3]);
overlay = rgb;
mask = multi_edge;
overlay(:,:,1) = overlay(:,:,1) + 0.5 * mask; % boost red channel on edges
overlay(overlay>1) = 1; % clamp

fig1 = figure('Units','normalized','Position',[0.05 0.05 0.45 0.7]);
subplot(2,1,1), imshow(Igray), title('Original image','FontSize',12);
subplot(2,1,2), imshow(overlay), title('Original with multi-scale wavelet edges (red)','FontSize',12);
set(fig1,'Color','w');
print(fig1,'-dpng','-r300',sprintf('%s_overlay_edges.png',out_prefix));


% 2) Detail subbands grid (levels x orientations) - improved scaling & contrast
fig2 = figure('Units','normalized','Position',[0.1 0.05 0.8 0.8]);
k = 1;
for lev = 1:levels
    [H,V,D] = detcoef2('all', C, S, lev);

    % Resize to original size using bilinear
    Hr = imresize(H, size(Igray), 'bilinear');
    Vr = imresize(V, size(Igray), 'bilinear');
    Dr = imresize(D, size(Igray), 'bilinear');

    % Scale coefficients for display and boost contrast
    Hs = wcodemat(Hr,255); Hs = imadjust(uint8(Hs));
    Vs = wcodemat(Vr,255); Vs = imadjust(uint8(Vs));
    Ds = wcodemat(Dr,255); Ds = imadjust(uint8(Ds));

    subplot(levels,3,k), imshow(Hs), title(sprintf('H L%d',lev),'FontSize',10); k=k+1;
    subplot(levels,3,k), imshow(Vs), title(sprintf('V L%d',lev),'FontSize',10); k=k+1;
    subplot(levels,3,k), imshow(Ds), title(sprintf('D L%d',lev),'FontSize',10); k=k+1;
end
colormap gray;
set(fig2,'Color','w');
drawnow;
print(fig2,'-dpng','-r300',sprintf('%s_detail_subbands.png',out_prefix));
try exportgraphics(fig2,sprintf('%s_detail_subbands.pdf',out_prefix),'ContentType','vector'); end

% 3) Approximation (LL) pyramid (coarse-to-fine) - full size
fig3 = figure('Units','normalized','Position',[0.1 0.3 0.8 0.3]);
for lev = 1:levels
    A = appcoef2(C,S,wname,lev);
    Ar = imresize(A, size(Igray), 'bilinear');
    subplot(1,levels,lev), imshow(mat2gray(Ar),[]), title(sprintf('LL Level %d', lev),'FontSize',12);
end
set(fig3,'Color','w');
print(fig3,'-dpng','-r300',sprintf('%s_approx_pyramid.png',out_prefix));
try exportgraphics(fig3,sprintf('%s_approx_pyramid.pdf',out_prefix),'ContentType','vector'); end

% 4) Energy bar chart (subband energies)
fig4 = figure('Units','normalized','Position',[0.2 0.2 0.6 0.4]);
bar(energy_features);
legend('H','V','D','Location','northwest');
xlabel('Decomposition level','FontSize',11);
ylabel('Energy (sum of squares)','FontSize',11);
title('Wavelet subband energy per level','FontSize',12);
set(gca,'FontSize',10);
grid on;
set(fig4,'Color','w');
print(fig4,'-dpng','-r300',sprintf('%s_energy_bar.png',out_prefix));
try exportgraphics(fig4,sprintf('%s_energy_bar.pdf',out_prefix),'ContentType','vector'); end

% --- Save workspace variables for inspection if needed
save(sprintf('%s_workspace.mat',out_prefix),'Igray','levels','edge_maps','multi_edge','energy_features','C','S');

fprintf('Finished. Figures saved (PNG and PDF where possible) with prefix "%s_".\n', out_prefix);
fprintf('Files: %s_overlay_edges.png, %s_detail_subbands.png, %s_approx_pyramid.png, %s_energy_bar.png\n', out_prefix,out_prefix,out_prefix,out_prefix);
