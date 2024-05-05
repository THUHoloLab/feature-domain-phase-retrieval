% ========================================================================
% Introduction
% ========================================================================
% This code provides a simple demonstration of compressive phase retrieval
% via constrained complex total variation (CCTV) regularization.
%
% Reference:
%   - Y. Gao and L. Cao, "Iterative projection meets sparsity 
%     regularization: towards practical single-shot quantitative phase 
%     imaging with in-line holography," Light: Advanced Manufacturing 4, 
%     6 (2023).
%
% Author: Yunhui Gao (gyh21@mails.tsinghua.edu.cn)
% =========================================================================
%%
% =========================================================================
% Data generation
% =========================================================================
clear;clc;
% close all;

% load functions
addpath(genpath('utils'))
addpath(genpath('src'))
addpath(genpath('fun_fairy'))

% load experimental data
group_num = 4;
img_bg  = im2double(rgb2gray(imread(['data/E',num2str(group_num),'/bg.bmp'])));
img_obj = im2double(rgb2gray(imread(['data/E',num2str(group_num),'/obj.bmp'])));
load(['data/E',num2str(group_num),'/data.mat'])

% normalization of the hologram
y = img_obj./mean(img_bg(:));
pos_x = 420;
pos_y = 185;
y = y(pos_y:pos_y+600,pos_x:pos_x+800); % E4

% figure; 
% [temp,rect] = imcrop(y);
% if rem(size(temp,1),2) == 1
%     rect(4) = rect(4) - 1;
% end
% if rem(size(temp,2),2) == 1
%     rect(3) = rect(3) - 1;
% end
% pix = fix((rect(4) + rect(3))/2);
% pix = pix + mod(pix,2);
% rect = fix(rect);
% y = y(rect(2):rect(2)+pix-1,rect(1):rect(1)+pix-1,:);


mag = 2; % upsampling sacle
y = imresize(y,mag,'bicubic');
y(y<0) = 0;
params.pxsize = params.pxsize ./ mag;
[N1,N2] = size(y);

% calculation of padding sizes to avoid circular boundary artifact
kernelsize = params.dist*params.wavlen/(params.pxsize*mag)/2;
nullpixels = ceil(kernelsize / params.pxsize);

% forward model
Q  = @(x) propagate(x, params.dist,params.pxsize,params.wavlen,params.method);    % forward propagation
QH = @(x) propagate(x,-params.dist,params.pxsize,params.wavlen,params.method);    % Hermitian of Q: backward propagation
C  = @(x) imgcrop(x,nullpixels);                                                  % image cropping operation (to model the finite size of the sensor area)
CT = @(x) zeropad(x,nullpixels);                                                  % transpose of C: zero-padding operation
% A  = @(x) C(Q(x));                                                                   % overall sampling operation
% AH = @(x) QH(CT(x));                                                                  % Hermitian of A
A  = @(x) Q(x);                                                                   % overall sampling operation
AH = @(x) QH(x);    
%%
% =========================================================================
% Compressive phase retrieval algorithm
% =========================================================================

% region for computing the errors
region.x1 = nullpixels+1;
region.x2 = nullpixels+N1;
region.y1 = nullpixels+1;
region.y2 = nullpixels+N2;

% algorithm settings
x_init  = AH(CT(sqrt(y)));   % initial guess
n_iters = 150;       % number of iterations (main loop)

% options
global amplitude
amplitude = 1.1;  % intensity comstrain

TV = 0.1; % denoising strength for TV denoising

beta1 = 1; % penalty strength for denoising
beta2 = 20;

timer = tic;
filter_case{1} = {1,'total variation'};
filter_case{2} = {2,'guided filter'};
filter_case{3} = {3,'recursive edge-preserving filter'};
filter_case{4} = {4,'bilateral filter'};
filter_case{5} = {5,'tsmooth'};
filter_case{6} = {6,'tree filter'};

for use_filter = 1

wavefront = x_init;
dY = CT(y);

loss_data = [];

lr = 0.02;  % learning rate
optimizer = optimizer_yogi(0,0,0.9,0.999,lr);
for loop = 1:n_iters
    
    wave = A(wavefront);        % forward propagation

    loss1 = abs(wave) - dY;
    loss1 = sum(loss1(:).^2);

    wave = dY .* sign(wave);    % replace the amplitude using measurement
    wavefront = AH(wave);         % backward propagation


    wavefront = HIO(wavefront,1); % performing physical constrain
    wavefront = complex_TV(wavefront,TV,'isotropic'); % project to TV denoising
    

    runtimes= toc(timer);
    if mod(loop,2) == 0
        figure(2023);
        w = (wavefront);
        subplot(121);imshow(mat2gray(abs(w)),[]);
        subplot(122);imshow(mat2gray(angle(w)),[]);
        drawnow;
        if loop > 80
           TV = max(TV * 0.5,0.01);
        end
    end
end
x_est = gather(wavefront);
x_crop = x_est(nullpixels+1:nullpixels+N1,nullpixels+1:nullpixels+N2);
save(['data/output/met_ware_',filter_case{use_filter}{2},'.mat'],'x_est','x_crop','loss_data')
end

%%
% =========================================================================
% Display results
% =========================================================================
% x_crop = x_est(nullpixels+1:nullpixels+N1,nullpixels+1:nullpixels+N2);
amp_est = abs(x_crop);
pha_est = puma_ho(angle(x_crop),1);

% visualize the reconstructed image
figure
subplot(1,2,1),imshow(amp_est,[]);colorbar
title('Retrieved amplitude','interpreter','latex','fontsize',14)
subplot(1,2,2),imshow(pha_est,[]);colorbar
title('Retrieved phase','interpreter','latex','fontsize',14)
set(gcf,'unit','normalized','position',[0.2,0.3,0.6,0.4])


% =========================================================================
% Auxiliary functions
% =========================================================================


%% hybrid input-output for physical constrain
function o = HIO(o,mask)            % hybrid input-output
    global amplitude
    o = mask .* min(abs(o),amplitude) .* sign(o);
end










