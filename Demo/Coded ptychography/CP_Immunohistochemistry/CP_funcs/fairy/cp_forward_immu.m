function [loss,dldw1,dldw2] = cp_forward_immu(wavefront1,...
                                                wavefront2, ...
                                                y_obs, ...
                                                Hs, ...
                                                mag, ...
                                                H1, ...
                                                H2)

eps = 1e-5;


Hs = fftshift(fftshift(Hs,1),2);

x           = fft2_ware(wavefront1,true) .* H1;
x_forward   = ifft2_ware(x .* Hs,true);
x           = x_forward .* wavefront2;
x           = ifft2_ware(fft2_ware(x,true).*H2,true);

dX          = abs(x);
dX_ds       = sqrt(imresize(dX.^2,1/mag,'box'));

% dm          = (dX_ds - y_obs); loss = sum(dm(:).^2);

[loss,dm]   = ret_loss(dX_ds - y_obs,'isotropic');
x           = imresize(dm./(dX_ds + eps),mag,'nearest') .* x;

x_backward  = ifft2_ware(fft2_ware(x,true) .* conj(H2),true);
x           = deconv_pie(x_backward, wavefront2,'none');
x           = fft2_ware(x,true) .* conj(Hs) .* conj(H1);

dldw1 = sum(ifft2_ware(x,true),3);
dldw2 = sum(deconv_pie(x_backward,x_forward,'none'),3);
end