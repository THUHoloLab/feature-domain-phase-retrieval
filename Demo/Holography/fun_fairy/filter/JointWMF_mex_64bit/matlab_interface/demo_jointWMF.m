


I = imread('imgs/image1.png');

tic;
res = jointWMF(vis_g,vis_g,5,25.5,256,256,1,'exp');
toc;

figure, imshow(res);