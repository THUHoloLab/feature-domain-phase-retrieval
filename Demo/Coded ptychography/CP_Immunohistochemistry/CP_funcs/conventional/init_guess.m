%% Initialization
% Initialize the object
objectSum = zeros(imSize0,imSize0);
for i=1:imNum
    % Generate the phase factor for sub-pixel level shift
    Hs = exp(-1j*2*pi.*(FX0.*locX(i)/imSize0+FY0.*locY(i)/imSize0));

    % Sum the shifted back measurements
    objectSum = objectSum+ifft2(fft2(sqrt(imRaw(:,:,i))).*Hs);		
end
% Propagation back the up-sampled average to initialize the object wavefront 
objectIniGuess = ifft2(ifftshift(invH_d2.*padarray(fftshift(fft2(objectSum/imNum)),[imSize0*(mag-1)/2 imSize0*(mag-1)/2])));
