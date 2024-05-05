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
% A  = @(x) C(Q(x));                                                              % overall sampling operation
% AH = @(x) QH(CT(x));                                                            % Hermitian of A
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
    
    % FAIRY likelihood module, forward-backward;
    [loss1,dldw] = holo_forward(wavefront,A,AH,dY);
    

    % Extended Hybrid input-output module performing denoising constrain
    switch use_filter
        case 1
            w_1 = complex_TV(wavefront,TV,'isotropic');
        case 2
            w_1 = guidedfilter(abs(wavefront),abs(wavefront),5,1e-4) .* exp(1i*...
                  guidedfilter(angle(wavefront),angle(wavefront),5,1e-4));     
        case 3
            w_1 = RF(abs(wavefront),0.1,3) .* exp(1i*...
                  RF(angle(wavefront),0.1,3));
        case 4
            w_1 = bilateral_filter(abs(wavefront),0.1,0.2) .* exp(1i*...
                  bilateral_filter(angle(wavefront),0.1,0.2));
        case 5
            w_1 = tsmooth(abs(wavefront),0.015,3) .* exp(1i*...
                  tsmooth(angle(wavefront),0.015,3)); 
        case 6
            img1 = repmat(abs(wavefront),[1,1,3]) * 255;
            img2 = angle(wavefront);
            max_0 = max(img2(:));
            min_0 = min(img2(:));
            img2 = repmat(mat2gray(img2),[1,1,3]) * 255;
            out_phase = (max_0 - min_0) * mat2gray(mean(qx_tree_filter(img2,img2,0.002,1),3)) + min_0;
            w_1 = mean(qx_tree_filter(img1,img1,0.0001,1),3)/255 .* exp(1i*out_phase);
        otherwise
    end
    
    w_2 = HIO(wavefront,1); % performing physical constrain

    
    loss2 = beta1 * sum(sum(abs(wavefront - w_1))) + ...
            beta2 * sum(sum(abs(wavefront - w_2)));

    loss_data = [loss_data,[loss1;loss2]];

    % compose gradient
    dldw = dldw + beta1 * (wavefront - w_1) + beta2 * (wavefront - w_2);

    % learning using optimizer
    wavefront = optimizer.step(wavefront,dldw);

    runtimes= toc(timer);
    if mod(loop,2) == 0
        fprintf('iter: %4d | objective: %10.4e | stepsize: %2.2e | runtime: %5.1f s\n', ...
                loop, loss1, lr, runtimes);
        figure(2023);
        w = (wavefront);
        subplot(121);imshow(mat2gray(abs(w)),[]);
        subplot(122);imshow(mat2gray(angle(w)),[]);
        drawnow;
        if loop > 80
           TV = max(TV * 0.5,0.01);
        end
    end
    
    lr = lr .* 0.995; % learning rate decay
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

%%
% =========================================================================
% Auxiliary functions
% =========================================================================
function [loss,dldw] = holo_forward(wavefront,forward,backward,dY)
    wave = forward(wavefront);
    dX = abs(wave);

    [loss,diff_map] = lp_difference_map(dX, sqrt(dY));            
    % [loss,diff_map] = KL_difference_map(dX.^scale, dY.^scale);  
     

    wave = diff_map .* sign(wave);%.* (dX + 1e-5).^(2*scale - 2); % back-propagation
    dldw = backward(wave);
end


%% hybrid input-output for physical constrain
function o = HIO(o,mask)            % hybrid input-output
    global amplitude
    o = mask .* min(abs(o),amplitude) .* sign(o);
end

function [loss,diff_map] = lp_difference_map(dX,dY)
% L-p norm likelihood
loss = (dX - dY).^2;
loss = sum(loss(:));
diff_map = (dX - dY);
end

function [loss,diff_map] = KL_difference_map(dX,dY)
% KL divergence for poisson likelihood
loss = dX - dY .* log(dX + 1e-5);
loss = sum(loss(:));
diff_map = 1 - dY ./ (dX + 1e-5);
end










