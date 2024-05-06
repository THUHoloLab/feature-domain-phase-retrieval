%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Citation: Shaowei Jiang, Pengming Song, Tianbo Wang, et al.,
% "Spatial and Fourier domain ptychography for high-throughput bio-imaging", 
% submitted to Nature Protocols, 2023
% 
% Reconstruction code for spatial-domain coded ptychography (CP). 
% 
% This MATLAB code iteratively recovers the object from CP measurements. 
% The positional shifts are initially estimated based on the function
% 'track_position.m'. The shifts can be further refined using the function
% 'refine_position.m'. 
% The coded surface profile 'codedSurface_upsample4fold.mat' was 
% pre-recovered via a calibration experiment. 
% The recovered wavefront of the object at the coded surface plane can be
% digitally propagated back to the object plane. 
% Note: the uploaded data has a dimension of 1024 by 1024. Small phyical
% size may lead to degradation of the spatial resolution.
%
% Used functions:
% track_position.m      Initial positional tracking
% refine_position.m     Positional shift refinement
% dftregistration.m     Subpixel image registration by crosscorrelation
%
% Datasets:
% rawImage_IHCslide.mat.mat         Measurements of IHC stained sample
% codedSurface_upsample4fold.mat    Pre-recovered coded surface profile
%
% Copyright (c) 2023, Shaowei Jiang, Pengming Song, and Guoan Zheng, 
% University of Connecticut.
% Email: shaowei.jiang@uconn.edu or guoan.zheng@uconn.edu
% All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load data
close all
clear
clc
addpath(genpath('CP_funcs'))

[temp,rect] = imcrop((imread(['raw_data\img_1.tif'])));
if rem(size(temp,1),2) == 1
    rect(4) = rect(4) - 1;
end
if rem(size(temp,2),2) == 1
    rect(3) = rect(3) - 1;
end
pix = fix((rect(4) + rect(3))/2);
pix = pix + mod(pix,2);
rect = fix(rect);
save("loc_pos.mat","pix","rect")

load loc_pos.mat
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
imRaw = imRaw - min(imRaw(:));
imRaw = imRaw / max(imRaw(:));




% Load the coded surface profile
load(['CP_datasets\codedSurface_upsample4fold.mat'],'CSRecovery')
CSRecovery = imresize(CSRecovery,[1024,1024]);
CSRecovery = CSRecovery(rect(2):rect(2)+pix-1,rect(1):rect(1)+pix-1);
CSRecovery = imresize(CSRecovery,4,'box');
CSRecovery = mat2gray(abs(CSRecovery)) .* sign(CSRecovery);

init_environment_immu;
init_guess;


%% Recovery process
clc
close all
objectRecovery = objectIniGuess;clear objectIniGuess

loopNum = 10;
for iLoop=1:loopNum
    for tt=1:imNum
    disp([iLoop tt]);
    
    % Shift the object wavefront
    Hs=exp(-1j*2*pi.*(FX.*-locX(tt,1)/imSize0+FY.*-locY(tt,1)/imSize0));
    objectRecoveryShift=ifft2(fft2(objectRecovery).*Hs);

    % Exit wavefront at the coded surface plane
    waveCSPlane = objectRecoveryShift.*CSRecovery;  

    % Propagate exit wavefront to the sensor plane
    waveSensorPlane=ifft2(ifftshift(H_d2.*fftshift(fft2(waveCSPlane))));
    
    % Downsample the intensity at the sensor plane
    intenSensorPlane = conv2(abs(waveSensorPlane).^2, ones(mag));
    intenDownSensorPlane = sqrt(intenSensorPlane(mag:mag:end,mag:mag:end));

    % Update the wavefront
    ratioMap = sqrt(imRaw(:,:,tt))./(intenDownSensorPlane); 
    ratioMap = imresize(gather(ratioMap),mag,'nearest');
    waveSensorPlaneUpdate = waveSensorPlane.*ratioMap;

    % Propagate the updated exit wave back to the coded surface plane
    waveCSPlaneUpdate=ifft2(ifftshift(invH_d2.*fftshift(fft2(waveSensorPlaneUpdate))));

    % Use rPIE algorithm to update the shifted object wavefront
    objectRecoveryShift = objectRecoveryShift + gamaO*conj(CSRecovery).*(waveCSPlaneUpdate-waveCSPlane)./(alphaO.*max(max(abs(CSRecovery).^2))+(1-alphaO).*(abs(CSRecovery)).^2);
    
    % Use rPIE algorithm to update the coded surface profile (optional)
    if iLoop>3
    CSRecovery = CSRecovery + gamaCS*conj(objectRecoveryShift).*(waveCSPlaneUpdate-waveCSPlane)./(alphaCS.*max(max(abs(objectRecoveryShift).^2))+(1-alphaCS).*(abs(objectRecoveryShift)).^2);
    end

    % Shift back the object wavefront
    Hs=exp(-1j*2*pi.*(FX.*locX(tt,1)/imSize0+FY.*locY(tt,1)/imSize0));
    objectRecovery=ifft2(fft2(objectRecoveryShift).*Hs);
    end 

    % show image 
    %% Refocus the object
    d1 = (282).*1e-6;
    invH_d1 = (exp(1i.*(-d1).*real(kzm)).*exp(-abs((-d1)).*abs(imag(kzm))).*((k0^2-kxm.^2-kym.^2)>=0)); 
    objectRecoveryRefocus = abs(ifft2(ifftshift(invH_d1.*fftshift(fft2(objectRecovery)))));
    objectRecoveryAmplitude = objectRecoveryRefocus;
    d1 = (282).*1e-6;
    invH_d1=(exp(1i.*(-d1).*real(kzm)).*exp(-abs((-d1)).*abs(imag(kzm))).*((k0^2-kxm.^2-kym.^2)>=0)); 
    objectRecoveryRefocus=angle(ifft2(ifftshift(invH_d1.*fftshift(fft2(objectRecovery)))));
    objectRecoveryPhase = objectRecoveryRefocus;
    edge0 = 5;

    figure(2025);
    subplot(121);imshow(objectRecoveryAmplitude,[]);title('Refocused amplitude')
    subplot(122);imshow(objectRecoveryPhase,[]);title('Refocused phase');
    drawnow;

end 


