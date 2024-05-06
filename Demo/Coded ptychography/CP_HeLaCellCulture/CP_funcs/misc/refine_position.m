function [locX,locY]=refine_position(imRawCrop,locX0,locY0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Citation: Shaowei Jiang, Pengming Song, Tianbo Wang, et al.,
% "Spatial and Fourier domain ptychography for high-throughput bio-imaging", 
% submitted to Nature Protocols, 2023
% 
% Positional shift refinement function for spatial-domain coded 
% ptychography (CP). 
%
% Inputs:
% imRawCrop     Cropped region for positional tracking
% locX0         Initial esitimated x shifts
% locY0         Initial esitimated y shifts
%
% Outputs:
% locX          Refined x shifts
% locY          Refined y shifts
%
% Copyright (c) 2023, Shaowei Jiang, Pengming Song, and Guoan Zheng, 
% University of Connecticut.
% Email: shaowei.jiang@uconn.edu or guoan.zheng@uconn.edu
% All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate the refined reference image                    
imRawCrop = imRawCrop./mean(imRawCrop,3);
imSize0 = size(imRawCrop,1);                        % The size of cropped measurements
imNum = size(imRawCrop,3);                          % The number of measurements
% Subpixel shift parameters
fy0 = ifftshift(gpuArray.linspace(-floor(imSize0/2),ceil(imSize0/2)-1,imSize0));
fx0 = ifftshift(gpuArray.linspace(-floor(imSize0/2),ceil(imSize0/2)-1,imSize0));
[FX0,FY0] = meshgrid(fx0,fy0); clear fx0 fy0
% Shift back the cropped tiles 
imRefRefineSum = zeros(imSize0,imSize0,'single');  
for i=1:imNum
    if abs(locX0(i))>2 && abs(locY0(i))>2
    Hs = exp(-1j*2*pi.*(FX0.*locX0(i)/imSize0+FY0.*locY0(i)/imSize0));  % Generate the phase factor
    imRefRefineSum = imRefRefineSum+ifft2(fft2(imRawCrop(:,:,i)).*Hs);  % Sub-pixel level shift
    end
end
imRefRefine = abs(imRefRefineSum)/imNum;     % imRefRefine: the refined reference image

% Refine the subpixel shifts
locX=zeros(imNum,1);
locY=zeros(imNum,1);
edge0=20;
standardImg=imRefRefine(1+edge0:end-edge0,1+edge0:end-edge0,1);
for i=1:imNum
    disp(['Refine position of ',num2str(i),'th image.']);
    copyImg = imRawCrop(1+edge0:end-edge0,1+edge0:end-edge0,i);
    [output, ~] = dftregistration(fft2(standardImg),fft2(copyImg),100);
    locY(i) = output(3);
    locX(i) = output(4);
end

end