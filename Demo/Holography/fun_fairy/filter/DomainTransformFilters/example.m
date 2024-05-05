I = imread('noisyinput.png');
I = im2double(I);

I = imresize(I,0.5);

G = imread('nir.png');

G = imresize(im2double(G),0.5);
G = repmat(G,[1 1 3]);

%% Edge-preserving smoothing example
sigma_s = 10;
sigma_r = 0.1;

% Filter using normalized convolution.
% F_nc = NC(I, sigma_s, sigma_r);

% Filter using interpolated convolution.
% F_ic = IC(I, sigma_s, sigma_r);

% Filter using the recursive filter.
F_rf = RF(I, sigma_s, sigma_r,3,G);

% using guided filter
Guided = guidedfilter_sxy(I,G,4,0.005^2);

% using our filter

ours = joint_image_restoration(I,G,0.2);

% Show results.
figure, imshow(I); title('Input photograph');
figure, imshow(G); title('Input NIR image');
%figure, imshow(F_nc); title('Normalized convolution');
%figure, imshow(F_ic); title('Interpolated convolution');
figure, imshow(F_rf); title('Recursive filter');
figure, imshow(Guided); title('Guided filter');
figure, imshow(ours); title('ours');