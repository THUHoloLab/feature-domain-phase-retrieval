function [locX,locY]=track_position(imRawCrop)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Citation: Shaowei Jiang, Pengming Song, Tianbo Wang, et al.,
% "Spatial and Fourier domain ptychography for high-throughput bio-imaging", 
% submitted to Nature Protocols, 2023
% 
% Initial positional tracking function for spatial-domain coded 
% ptychography (CP). 
%
% Inputs
% imRawCrop     Cropped region for positional tracking
%
% Outputs
% locX          Estimated x shifts
% locY          Estimated y shifts
%
% Copyright (c) 2023, Shaowei Jiang, Pengming Song, and Guoan Zheng, 
% University of Connecticut.
% Email: shaowei.jiang@uconn.edu or guoan.zheng@uconn.edu
% All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate the initial reference image                   
imRawCrop = imRawCrop./mean(imRawCrop,3);
imRefInitial = imRawCrop(:,:,1);                    % imRefInitial: the initial reference image
imNum = size(imRawCrop,3);                          % The number of measurements

% Estimate the subpixel shifts 
locX=zeros(imNum,1);
locY=zeros(imNum,1);
edge0=20;
standardImg=imRefInitial(1+edge0:end-edge0,1+edge0:end-edge0,1);
for i=1:imNum
    disp(['Calculating position of ',num2str(i),'th image.']);
    copyImg = imRawCrop(1+edge0:end-edge0,1+edge0:end-edge0,i);
     % Cross-correlation analysis
    [output, ~] = dftregistration(fft2(standardImg),fft2(copyImg),100);
    locY(i) = output(3);
    locX(i) = output(4);
end

end