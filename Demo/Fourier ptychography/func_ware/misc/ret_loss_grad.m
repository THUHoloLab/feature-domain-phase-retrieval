function [loss,out] = ret_loss_grad(dW,type)
loss = 0;
dxx = psf2otf([-1,2,-1],[size(dW,1),size(dW,2)]);
dyy = psf2otf([-1;2;-1],[size(dW,1),size(dW,2)]);
dxy = psf2otf([-1,1;1,-1],[size(dW,1),size(dW,2)]);

oxx = real(ifft2(fft2(dW) .* dxx));
oyy = real(ifft2(fft2(dW) .* dyy));
oxy = real(ifft2(fft2(dW) .* dxy));

switch type
    case 'isotropic'
        den = sqrt(oxx.^2 + oyy.^2 + oxy.^2) + 1e-5;
%         loss = sqrt((RxdW).^2 + (RydW).^2);
        oxx = oxx./den;
        oyy = oyy./den;
        oxy = oxy./den;
    case 'anisotropic' 
%         loss = abs(RxdW) + abs(RydW);
        oxx = sign(oxx);
        oyy = sign(oyy);
        oxy = sign(oxy);
    otherwise
    error("parameter #3 should be a string either 'isotropic', or 'anisotropic'")
end

oxx = real(ifft2(fft2(oxx) .* conj(dxx)));
oyy = real(ifft2(fft2(oyy) .* conj(dyy)));
oxy = real(ifft2(fft2(oxy) .* conj(dxy)));

out = oxx + oyy + oxy;
loss = sum(loss(:));
end