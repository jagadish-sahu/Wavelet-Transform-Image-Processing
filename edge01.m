% wavelet_edge_texture_compact.m
clearvars; close all; clc;
set(0,'DefaultFigurePosition',[100 100 900 650]);

% ---------- User params ----------
imgname   = 'bablu_03.jpg';
wname     = 'db4';
levels    = 3;
th_factor = 3;
out_prefix = 'wavelet_fig';
% ---------------------------------

% toolbox check
if ~(exist('wavedec2','file')==2)
    error('Wavelet Toolbox required (wavedec2, detcoef2, appcoef2).');
end

% read image (fallback)
if isfile(imgname)
    I = imread(imgname);
else
    warning('Image "%s" not found — using builtin "cameraman.tif".', imgname);
    I = imread('cameraman.tif');
end
if size(I,3)==3, Igray = rgb2gray(I); else Igray = I; end
Igray = im2double(Igray);
imSize = size(Igray);

% wavelet decomposition
[C,S] = wavedec2(Igray, levels, wname);

% prealloc
edge_maps   = false([imSize, levels]);
energy_feats = zeros(levels,3); % [H V D]

% process levels (collect resized detail maps and energies)
for lev = 1:levels
    [H,V,D] = detcoef2('all', C, S, lev);          % coeffs at coeff-grid
    energy_feats(lev,:) = [sum(H(:).^2), sum(V(:).^2), sum(D(:).^2)];

    % gradient magnitude on coeff grid, robust MAD estimate
    G = sqrt(H.^2 + V.^2);
    sigma = median(abs(G(:))) / 0.6745;
    T = th_factor * (sigma + eps);   % safe threshold

    % resize to image size (for visualization & combining) and threshold
    G_full = imresize(G, imSize, 'bilinear');
    edge_maps(:,:,lev) = G_full > T;
end

% combine multi-scale edges
multi_edge = any(edge_maps,3);

% ---------- Visualizations (one-shot, minimal duplication) ----------
% overlay
overlay = repmat(Igray, [1 1 3]);
overlay(:,:,1) = overlay(:,:,1) + 0.5 * multi_edge;
overlay(overlay>1) = 1;

fig1 = figure('Units','normalized','Position',[0.05 0.05 0.45 0.7]);
subplot(2,1,1), imshow(Igray), title('Original image','FontSize',12);
subplot(2,1,2), imshow(overlay), title('Original with multi-scale wavelet edges (red)','FontSize',12);
set(fig1,'Color','w');
print(fig1,'-dpng','-r300',sprintf('%s_overlay_edges.png',out_prefix));

% detail subbands grid (use a nested helper to fetch and display scaled maps)
fig2 = figure('Units','normalized','Position',[0.1 0.05 0.8 0.8]);
t = 1;
for lev = 1:levels
    [H,V,D] = detcoef2('all', C, S, lev);
    Hr = wcodemat(imresize(H,imSize,'bilinear'),255);
    Vr = wcodemat(imresize(V,imSize,'bilinear'),255);
    Dr = wcodemat(imresize(D,imSize,'bilinear'),255);
    subplot(levels,3,t); imshow(imadjust(uint8(Hr))); title(sprintf('H L%d',lev),'FontSize',10); t=t+1;
    subplot(levels,3,t); imshow(imadjust(uint8(Vr))); title(sprintf('V L%d',lev),'FontSize',10); t=t+1;
    subplot(levels,3,t); imshow(imadjust(uint8(Dr))); title(sprintf('D L%d',lev),'FontSize',10); t=t+1;
end
colormap gray; set(fig2,'Color','w'); drawnow;
print(fig2,'-dpng','-r300',sprintf('%s_detail_subbands.png',out_prefix));
try exportgraphics(fig2,sprintf('%s_detail_subbands.pdf',out_prefix),'ContentType','vector'); end

% approximation pyramid
fig3 = figure('Units','normalized','Position',[0.1 0.3 0.8 0.3]);
for lev = 1:levels
    A = appcoef2(C,S,wname,lev);
    Ar = imresize(A,imSize,'bilinear');
    subplot(1,levels,lev), imshow(mat2gray(Ar)), title(sprintf('LL Level %d',lev),'FontSize',12);
end
set(fig3,'Color','w'); print(fig3,'-dpng','-r300',sprintf('%s_approx_pyramid.png',out_prefix));
try exportgraphics(fig3,sprintf('%s_approx_pyramid.pdf',out_prefix),'ContentType','vector'); end

% energy bar chart
fig4 = figure('Units','normalized','Position',[0.2 0.2 0.6 0.4]);
bar(energy_feats);
legend('H','V','D','Location','northwest');
xlabel('Decomposition level'); ylabel('Energy (sum of squares)');
title('Wavelet subband energy per level'); grid on; set(fig4,'Color','w');
print(fig4,'-dpng','-r300',sprintf('%s_energy_bar.png',out_prefix));
try exportgraphics(fig4,sprintf('%s_energy_bar.pdf',out_prefix),'ContentType','vector'); end

% save data
save(sprintf('%s_workspace.mat',out_prefix),'Igray','levels','edge_maps','multi_edge','energy_feats','C','S');

fprintf('Done. Saved: %s_overlay_edges.png, %s_detail_subbands.png, %s_approx_pyramid.png, %s_energy_bar.png\n',out_prefix,out_prefix,out_prefix,out_prefix);
