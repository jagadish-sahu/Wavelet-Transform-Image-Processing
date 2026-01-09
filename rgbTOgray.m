% Read the RGB image
rgbImage = imread('img_92.jpg');

% Convert the RGB image to grayscale
grayImage = rgb2gray(rgbImage);

% Save the grayscale image
imwrite(grayImage, 'gray_img_05.jpg');
