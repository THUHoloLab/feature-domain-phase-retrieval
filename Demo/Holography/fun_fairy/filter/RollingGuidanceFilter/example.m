
close all;

I = im2double(imread('image.png'));

tic;
res = RollingGuidanceFilter(I,3,0.05,4);
toc;

figure,imshow(I);
figure,imshow(res);