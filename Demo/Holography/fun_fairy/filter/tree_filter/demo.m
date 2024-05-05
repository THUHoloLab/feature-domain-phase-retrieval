
close all;
clear all
clc;
img0 = double(imread('cameraman.tif'));

img = repmat(img0,[1,1,3]);
% img(:,:,1) = img0;
% img(:,:,2) = img0;
% img(:,:,3) = img0;
[h,w,nr_channel]=size(img0);

if(nr_channel==1)
    sigma_r_local = 10;
    sigma_r_nonlocal = 10/255;
    img_tf_nonlocal1=qx_tree_filter(img,img,sigma_r_nonlocal,1);
    img_tf_local = qx_tree_filter(img,img,sigma_r_local,0);

    img_tf_nonlocal2=qx_tree_filter(img,img_tf_local,sigma_r_nonlocal,1);
%     img_jrbf=qx_jrbf(img,sigma_x,sigma_r,guidance_img);
    figure,imshow([double(img),img_tf_nonlocal1,img_tf_local,img_tf_nonlocal2]/255);
%     figure,imshow([img_rbf,img_jrbf]/255);
end