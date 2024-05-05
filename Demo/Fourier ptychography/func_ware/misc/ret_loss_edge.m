function [loss,out] = ret_loss_edge(dW,type)
loss = 0;

edge = [-1,1];


dxx = psf2otf(edge,[size(dW,1),size(dW,2)]);
dyy = psf2otf(edge',[size(dW,1),size(dW,2)]);

oxx = real(ifft2(fft2(dW) .* dxx));
oyy = real(ifft2(fft2(dW) .* dyy));


switch type
    case 'isotropic'
        den = sqrt(oxx.^2 + oyy.^2) + 1e-5;
%         loss = sqrt((RxdW).^2 + (RydW).^2);
        oxx = oxx./den;
        oyy = oyy./den;

    case 'anisotropic' 
%         loss = abs(RxdW) + abs(RydW);
        oxx = sign(oxx);
        oyy = sign(oyy);%./den;
    otherwise
    error("parameter #3 should be a string either 'isotropic', or 'anisotropic'")
end

oxx = real(ifft2(fft2(oxx) .* conj(dxx)));
oyy = real(ifft2(fft2(oyy) .* conj(dyy)));

out = oxx + oyy;
loss = sum(loss(:));
end