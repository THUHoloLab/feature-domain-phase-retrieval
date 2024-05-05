% example: flash/noflash denoising
% figure 8 in our paper
% *** Errata ***: there is a typo in the caption of figure 8, the eps should be 0.02^2 instead of 0.2^2; sig_r should be 0.02 instead of 0.2.

close all;

p = im2double(imread('.\our_result\vis.png'));
I = im2double(imread('.\our_result\nir.png'));
size(p)
size(I)
r = 0;
eps = 0.01^2;

q = zeros(size(p));

% q(:, :, 1) = guidedfilter_color(I, p, r, eps);
q(:, :, 1) = guidedfilter(I(:, :, 1), p(:, :, 1), r, eps);
q(:, :, 2) = guidedfilter(I(:, :, 1), p(:, :, 2), r, eps);
q(:, :, 3) = guidedfilter(I(:, :, 1), p(:, :, 3), r, eps);
figure,imshow(q);
