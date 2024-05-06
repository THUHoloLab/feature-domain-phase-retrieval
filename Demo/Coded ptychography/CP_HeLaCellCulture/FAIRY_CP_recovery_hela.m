%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{

    Implementation of coded ptychography using FAIRY

    Codes were adapted from:
    Shaowei Jiang, Pengming Song, Tianbo Wang, et al.,
    "Spatial and Fourier domain ptychography for high-throughput bio-imaging", 
    Nature Protocols, 2023

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

addpath(genpath('CP_funcs'))

load loc_pos.mat
% Load data, crop image
total_position = 300;
imRaw = zeros(pix,pix,total_position);
for num_of_image = 1:total_position
    clc
    disp(num_of_image);
    img = double(imread(['raw_data\img_',num2str(num_of_image),'.tif'],...
                    'PixelRegion',{[rect(2),rect(2)+pix-1],...
                                   [rect(1),rect(1)+pix-1]}));

    imRaw(:,:,num_of_image) = mean(img,3);
end
imRaw = single(imRaw);
imRaw = sqrt(imRaw);
imRaw = imRaw - min(imRaw(:));
imRaw = imRaw / max(imRaw(:));

% Load the coded surface profile
load(['CP_datasets\codedSurface_upsample4fold.mat'],'CSRecovery')
CSRecovery = imresize(CSRecovery,[1024,1024]);
CSRecovery = CSRecovery(rect(2):rect(2)+pix-1,rect(1):rect(1)+pix-1);
CSRecovery = imresize(CSRecovery,4,'bicubic');
CSRecovery = mat2gray(abs(CSRecovery)) .* sign(CSRecovery);


init_environment_hela;

d1 = -(396.95).*1e-6;
H_d1 = (exp(1i.*(-d1).*real(kzm)).*exp(-abs((-d1)).*abs(imag(kzm))).*...
       ((k0^2-kxm.^2-kym.^2)>=0));


ScanPos = [locX,locY];
total_size = size(imRaw,3);%imRaw = imRaw;
cp_cube = combine(arrayDatastore(ScanPos,   'IterationDimension',1), ...
                  arrayDatastore(imRaw,    'IterationDimension',3));

batchSize = 15;
cp_cube = minibatchqueue(cp_cube,...
            'MiniBatchSize',     batchSize,...
            'MiniBatchFormat',   ["",""],...
            'OutputEnvironment', {'gpu'},...
            'OutputAsDlarray',   false,...
            'OutputCast',       'single');



epoch_max = 100;

lr = 0.004;
optimizer1 = optimizer_RMSprop(0,0,0.999,0,false,lr);
optimizer2 = optimizer_RMSprop(0,0,0.999,0,false,lr);
% optimizer1 = optimizer_sgd(lr);
% optimizer2 = optimizer_sgd(lr);

init_guess;
foo = @(x) gpuArray(single(x));

objectIniGuess = ifft2_ware(fft2_ware(objectIniGuess,true).*conj(H_d1),true);

get_ones = @(x) ones(size(x));

% wavefront1 = foo(get_ones(objectIniGuess));
wavefront1 = foo(objectIniGuess);
% wavefront2 = foo(get_ones(CSRecovery));
wavefront2 = foo(CSRecovery);


denoiser = @(x,w) medfilt2(real(x),[w,w]) + 1i*medfilt2(imag(x),[w,w]);

epoch = 0;
loss_data = [];
while epoch < epoch_max
    cp_cube.shuffle();

    this_loss = 0;
    remain = 300;

    while cp_cube.hasdata()
        disp(num2str(remain))

        remain = max(remain - batchSize,0);

        [dX,y_obs] = cp_cube.next();

        Hs = (zeros(pix*mag,pix*mag,size(y_obs,3)));
        for channel = 1:size(dX,1)
            x_pos = dX(channel,1);
            y_pos = dX(channel,2);
            Hs(:,:,channel) = exp(1j*2*pi.*(FX.*x_pos/imSize0 + ...
                                            FY.*y_pos/imSize0));
        end


        [loss,dldw1,dldw2] = cp_forward_hela(wavefront1,...
                                                wavefront2, ...
                                                y_obs, ...
                                                Hs, ...
                                                mag, ...
                                                H_d1, ...
                                                H_d2);

        this_loss = this_loss + loss;

        w1 = denoiser(wavefront1,5);
        w2 = denoiser(wavefront2,5);

     wavefront1 = optimizer1.step(wavefront1,dldw1 + 10*(wavefront1 - w1));
     wavefront2 = optimizer2.step(wavefront2,dldw2 + 10*(wavefront2 - w2));
        
        figure(2024)
        subplot(131); imshow(abs(w1),[])
        subplot(132); imshow(angle(w1),[])
        subplot(133); imshow(abs(w2),[])
        % subplot(133); plot(loss_data)
        drawnow;

    end
    loss_data = [loss_data,this_loss];

end


