%% Setup the parameters for CP
imSize0 = size(imRaw,1);    % The size of measurements
imNum = size(imRaw,3);      % The number of measurements
waveLength = 0.405e-6;      % Wavelength of the light source
d2 = (838).*1e-6;           % Distance between coded surface and image sensor
mag = 4;                    % Upsampling index
pixelSize0 = 1.85e-6;       % Pixel size of image sensor
pixelSize = pixelSize0/mag; % Pixel size of recovered image             
gamaO = 1;                  % Parameters for rPIE algorithm, here we use all one (ePIE)
gamaCS = 1;
alphaCS = 1;
alphaO = 1;

%% Initialize parameters for sub-pixel shift and propagation
% Subpixel shift parameters (raw image size)
fy0 = ifftshift(gpuArray.linspace(-floor(imSize0/2),ceil(imSize0/2)-1,imSize0));
fx0 = ifftshift(gpuArray.linspace(-floor(imSize0/2),ceil(imSize0/2)-1,imSize0));
[FX0,FY0] = meshgrid(fx0,fy0); clear fx0 fy0
% Subpixel shift parameters (final image size)
fy=ifftshift(gpuArray.linspace(-floor(imSize0*mag/2),ceil(imSize0*mag/2)-1,imSize0*mag));
fx=ifftshift(gpuArray.linspace(-floor(imSize0*mag/2),ceil(imSize0*mag/2)-1,imSize0*mag));
[FX,FY]=meshgrid(fx,fy); clear fx fy
% Prop parameters
k0=2*pi/waveLength;
kmax=pi/pixelSize;
kxm0=gpuArray.linspace(-kmax,kmax,imSize0*mag);
kym0=gpuArray.linspace(-kmax,kmax,imSize0*mag);
[kxm,kym]=meshgrid(kxm0,kym0);
clear kxm0 kym0
kzm=single(sqrt(complex(k0^2-kxm.^2-kym.^2)));
H_d2=(exp(1i.*d2.*real(kzm)).*exp(-abs(d2).*abs(imag(kzm))).*((k0^2-kxm.^2-kym.^2)>=0)); 
invH_d2=(exp(1i.*(-d2).*real(kzm)).*exp(-abs((-d2)).*abs(imag(kzm))).*((k0^2-kxm.^2-kym.^2)>=0)); 

%% Estimate positional shifts
if exist('CP_datasets\refined_pos.mat','file')
    load('CP_datasets\refined_pos.mat')
else
    % Initial postional tracking
    % [locX,locY]=track_position(imRaw(201:800,301:900,:)); 
    [locX,locY]=track_position(imRaw); 
    % Refine positional shifts (repeat 1-3 times)
    for iLoc = 1
        % [locX,locY]=refine_position(imRaw(201:800,301:900,:),locX,locY);
        [locX,locY]=refine_position(imRaw,locX,locY);
    end
    save(['CP_datasets\refined_pos.mat'],'locX','locY')
    figure;plot(locX,locY,'r*-');hold on
end



