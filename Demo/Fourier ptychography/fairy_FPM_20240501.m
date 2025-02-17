%% FD-PR recovery for FPM experiment with unknown defocus

clear
clc
close all
addpath(genpath('func_ware'));
led_num = [1,8,12,16,24,32];
led_total = sum(led_num(:));
rot_ang = 0 / 180 * pi;
name = 100;

for group_No = 25
name_group = name+group_No*5;
% figure;
% % 
% [temp,rect] = imcrop((imread(['0\',num2str(group_No),'\',num2str(name_group),'.000_1.tif'])));
% if rem(size(temp,1),2) == 1
%     rect(4) = rect(4) - 1;
% end
% if rem(size(temp,2),2) == 1
%     rect(3) = rect(3) - 1;
% end
% pix = fix((rect(4) + rect(3))/2);
% pix = pix + mod(pix,2);
% rect = fix(rect);
% save("loc_pos.mat","pix","rect")

load loc_pos.mat;
imRaw = zeros(pix,pix,led_total);
path = 'dataset\';

% Load data, crop image
for num_of_image = 1:led_total
    clc
    disp(num_of_image);
    img = double(imread([path,num2str(name_group),'.000_',...
                            num2str(num_of_image),'.tif'],...
                    'PixelRegion',{[rect(2),rect(2)+pix-1],...
                                   [rect(1),rect(1)+pix-1]}));

    imRaw(:,:,num_of_image) = mean(img,3);
end

imRaw = imRaw - min(imRaw(:));
imRaw = imRaw / max(imRaw(:));
imRaw = sqrt(imRaw);



init_environment;

%% preparing reconstruction data for WARE engine
imRaw_new = imRaw;
fpm_cube = combine(arrayDatastore(f_pos_set_true, 'IterationDimension',1),...
                   arrayDatastore(imRaw_new, 'IterationDimension',3));

% set mini-batch size a total of 225 images for FPM recon

batchSize = 31; 
fpm_cube = minibatchqueue(fpm_cube,...
            'MiniBatchSize',     batchSize,...
            'MiniBatchFormat',   ["",""],...
            'OutputEnvironment', {'gpu'},...
            'OutputAsDlarray',   false);


numEpochs = 1000;
numIterationsPerEpoch  = size(imRaw_new,3) / batchSize;
numIterations = numEpochs * numIterationsPerEpoch;



%% The iterative recovery process for FP
intensity_constrain = 1.2;


wavefront1 = gpuArray(ones(pix*pratio));
wavefront2 = gpuArray(Pupil0);


epoch = 0;
iteration = 0;
type = 'none';
clear imRaw led_pos uo vo;
c = 0;


learning_rate = 0.006;
optimizer_w1 = optimizer_RMSprop(0,0,0.999,0,false,learning_rate);
optimizer_w2 = optimizer_RMSprop(0,0,0.999,0,false,learning_rate);


%% Iterative process
while epoch < numEpochs
    epoch = epoch + 1;
    
    fpm_cube.shuffle();

    clc
    disp(['processing :',fix(num2str(100 * epoch/numEpochs)*100)/100,'%',...
        ' at ',num2str(epoch),'-th epoch']);

    if epoch > 500 && mod(epoch,50) == 0 % learning rate decay
        learning_rate = learning_rate / 2;
        optimizer_w1.lr = learning_rate;
        optimizer_w2.lr = learning_rate;
    end

    while hasdata(fpm_cube)
        iteration = iteration + 1;
        [leds,dY_obs] = fpm_cube.next();
        
        %% forward propagation, gain gradient
        [loss,dldw1,dldw2] = fpm_forward(wavefront1 + c, ...
                                         wavefront2, ...
                                         leds, ...
                                         dY_obs, ...
                                         pratio, ...
                                         type);

        %% learning the parameters
        wavefront1 = optimizer_w1.step(wavefront1,dldw1);
        wavefront2 = optimizer_w2.step(wavefront2,dldw2);

        wavefront2 = wavefront2 .* Pupil0;
        wavefront2 = min(max(abs(wavefront2),0.75),1.25) .* sign(wavefront2);

    end

    %% Result visualization
    if mod(epoch,1) == 0
        o = wavefront1 + c;

        F = fftshift(fft2(o));

        img_spe = log(abs(F)+1);mm = max(max(log(abs(F)+1)))/2;
        img_spe(img_spe>mm) = mm;
        img_spe(img_spe<0) = 0;
        img_spe = mat2gray(img_spe);
        figure(5);

        subplot(131); imshow(angle(wavefront2),[]); title('pupil phase','FontSize',16)
        subplot(132); imshow(img_spe,[]);           title('Intensity','FontSize',16);
        subplot(133); imshow(angle(o),[]);          title('Phase','FontSize',16);
        drawnow;
    end
end
if ~exist(['results\',path],'dir')
    mkdir(['results\',path])
end

save(['results\',path,'\data_saved_iter_25_wave.mat'],'wavefront1','wavefront2')
end
