% create_dwt_pyramid_3level_figure.m
% Produces a 2-row figure:
% top row: schematic 1/2/3-level decomposition diagrams
% bottom row: original image + coefficient mosaics for 1/2/3 levels
%
% Uses the image at /mnt/data/dbbb059c-017c-4f29-ad1c-8a8693f710c6.png by default.

clear; close all; clc;

% ---------- USER SETTINGS ----------
input_image = 'img_5.jpg'; % <-- your reference image
output_png   = 'DWT_pyramid_combined.png';
wname = 'bior4.4';   % good visual approximation to CDF 9/7; try 'cdf97' if available
convert_to_gray = true;
% -----------------------------------

% Read image
I = imread(input_image);
if convert_to_gray && size(I,3)==3
    I = rgb2gray(I);
end
I = im2double(I);

% Ensure sizes are compatible for 3-level dyadic DWT
[h0,w0] = size(I);
% pad to multiple of 2^3
padH = mod(-h0,2^3); padW = mod(-w0,2^3);
if padH>0 || padW>0
    I = padarray(I, [padH padW], 'symmetric', 'post');
end

% --- 1-level DWT
[LL1, LH1, HL1, HH1] = dwt2(I, wname);

% --- 2-level (on LL1)
[LL2, LH2, HL2, HH2] = dwt2(LL1, wname);

% --- 3-level (on LL2)
[LL3, LH3, HL3, HH3] = dwt2(LL2, wname);

% --- Helper to build coefficient montage for a given level
% For level 1: place LL1 top-left? We'll follow the canonical: show 2x2 mosaic [LL LH; HL HH]
build_mosaic = @(A_LL, A_LH, A_HL, A_HH) ...
    padarray( [ mat2gray(A_LL), mat2gray(A_LH); mat2gray(A_HL), mat2gray(A_HH) ], [1 1], 1, 'pre');

% Create mosaics for visual comparison
m1 = build_mosaic(LL1, LH1, HL1, HH1);
% For higher levels we will upscale the smaller LLs to the same visual tile size so the mosaic looks uniform
% Determine target tile size (use LL1 tile size)
tile_h = size(LL1,1);
tile_w = size(LL1,2);

% Build level2 mosaic: LL2 is smaller than LL1 - resize for display only (bicubic)
LL2_disp = imresize( mat2gray(LL2), [tile_h tile_w], 'bicubic' );
LH2_disp = imresize( mat2gray(LH2), [tile_h tile_w], 'bicubic' );
HL2_disp = imresize( mat2gray(HL2), [tile_h tile_w], 'bicubic' );
HH2_disp = imresize( mat2gray(HH2), [tile_h tile_w], 'bicubic' );
m2 = [LL2_disp, LH2_disp; HL2_disp, HH2_disp];

LL3_disp = imresize( mat2gray(LL3), [tile_h tile_w], 'bicubic' );
LH3_disp = imresize( mat2gray(LH3), [tile_h tile_w], 'bicubic' );
HL3_disp = imresize( mat2gray(HL3), [tile_h tile_w], 'bicubic' );
HH3_disp = imresize( mat2gray(HH3), [tile_h tile_w], 'bicubic' );
m3 = [LL3_disp, LH3_disp; HL3_disp, HH3_disp];

% Create the final composite figure with tiled layout
figure('Units','normalized','Position',[0.05 0.05 0.9 0.75],'Color','w');

% Use tiledlayout for clean control
t = tiledlayout(2,4,'TileSpacing','compact','Padding','compact');

% --- Top row: schematic diagrams (drawn manually using small axes)
ax1 = nexttile(1);
axis off; title('1 level decomposition','FontWeight','normal');
draw_schematic(ax1,1);

ax2 = nexttile(2);
axis off; title('2 level decomposition','FontWeight','normal');
draw_schematic(ax2,2);

ax3 = nexttile(3);
axis off; title('3 level decomposition','FontWeight','normal');
draw_schematic(ax3,3);

% blank tile to balance top row
nexttile(4); axis off;

% --- Bottom row: Image + mosaics
nexttile(5);
imshow(mat2gray(I)); axis image off; title('Image');

nexttile(6);
imshow(m1); axis image off; title('Coefficients (1 level)');

nexttile(7);
imshow(m2); axis image off; title('Coefficients (2 level)');

nexttile(8);
imshow(m3); axis image off; title('Coefficients (3 level)');

% Add a main suptitle
sgtitle(sprintf('DWT pyramid and coefficient mosaics (wavelet: %s)', wname),'FontSize',14);

% Save high-resolution PNG
set(gcf,'PaperPositionMode','auto');
print(gcf, output_png, '-dpng', '-r300');
fprintf('Saved combined figure to: %s\n', output_png);

% ------------- Subfunction: draw_schematic -------------
function draw_schematic(ax,levels)
% draws simple block-schematic like your example inside given axes
axes(ax); cla(ax); hold on;
axis equal off;
box_x = 1; box_y = 1; box_w = 1.2; box_h = 1.2;
% Draw main big square and 2x2 split
rectangle('Position',[0,0,box_w,box_h],'EdgeColor','k','LineWidth',1.2);
line([0,box_w],[box_h/2,box_h/2],'Color','k','LineWidth',1);
line([box_w/2,box_w/2],[0,box_h],'Color','k','LineWidth',1);
% put labels a/h/v/d (approx/horiz/vert/diag)
text(box_w*0.25, box_h*0.75, 'a','HorizontalAlignment','center','FontSize',10);
text(box_w*0.75, box_h*0.75, 'h','HorizontalAlignment','center','FontSize',10);
text(box_w*0.25, box_h*0.25, 'v','HorizontalAlignment','center','FontSize',10);
text(box_w*0.75, box_h*0.25, 'd','HorizontalAlignment','center','FontSize',10);
% if levels >=2, draw subdivided box in top-left (a -> aa/ah/av/ad)
if levels>=2
    % draw smaller 2x2 in the 'a' quadrant (top-left)
    ax_sc = [0, box_h/2, box_w/2, box_h/2];
    % inner grid
    line([ax_sc(1)+ax_sc(3)/2, ax_sc(1)+ax_sc(3)/2],[ax_sc(2), ax_sc(2)+ax_sc(4)],'Color','k','LineWidth',0.8);
    line([ax_sc(1), ax_sc(1)+ax_sc(3)],[ax_sc(2)+ax_sc(4)/2, ax_sc(2)+ax_sc(4)/2],'Color','k','LineWidth',0.8);
    text(ax_sc(1)+ax_sc(3)/4, ax_sc(2)+3*ax_sc(4)/4, 'aa','FontSize',7,'HorizontalAlignment','center');
    text(ax_sc(1)+3*ax_sc(3)/4, ax_sc(2)+3*ax_sc(4)/4, 'ah','FontSize',7,'HorizontalAlignment','center');
    text(ax_sc(1)+ax_sc(3)/4, ax_sc(2)+ax_sc(4)/4, 'av','FontSize',7,'HorizontalAlignment','center');
    text(ax_sc(1)+3*ax_sc(3)/4, ax_sc(2)+ax_sc(4)/4, 'ad','FontSize',7,'HorizontalAlignment','center');
end
% if levels>=3, subdivide the 'aa' (top-left of aa) again
if levels>=3
    % coordinates of 'aa' quadrant inside the small block (top-left small)
    aa_x = 0; aa_y = box_h*(3/4); aa_w = box_w/4; aa_h = box_h/4;
    % draw two divisions inside aa
    line([aa_x+aa_w/2, aa_x+aa_w/2],[aa_y-aa_h, aa_y],'Color','k','LineWidth',0.6);
    line([aa_x, aa_x+aa_w],[aa_y-aa_h/2, aa_y-aa_h/2],'Color','k','LineWidth',0.6);
    text(aa_x+aa_w*0.25, aa_y-aa_h*0.25, 'aaa','FontSize',6,'HorizontalAlignment','center');
    text(aa_x+aa_w*0.75, aa_y-aa_h*0.25, 'aah','FontSize',6,'HorizontalAlignment','center');
    text(aa_x+aa_w*0.25, aa_y-aa_h*0.75, 'aav','FontSize',6,'HorizontalAlignment','center');
    text(aa_x+aa_w*0.75, aa_y-aa_h*0.75, 'aad','FontSize',6,'HorizontalAlignment','center');
end
hold off;
end
