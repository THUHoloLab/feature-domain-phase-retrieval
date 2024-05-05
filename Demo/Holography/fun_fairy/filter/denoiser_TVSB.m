function o_TV = denoiser_TVSB(o,beta_TV)

%% Total variation regularization DPC


dx = [-1,1];    otf_dx = psf2otf(dx,size(o));
dy = [-1;1];    otf_dy = psf2otf(dy,size(o));
DTD = abs(otf_dx).^2 + abs(otf_dy).^2;

gx = 0;
gy = 0;
bx = 0;
by = 0;

beta = 1;

numer = fft2(o);
denom = 1;
for loop = 1:15

    u = gx + bx;
    v = gy + by;

    Gxx = [u(:,end,:) - u(:, 1,:), -diff(u,1,2)];
    Gyy = [v(end,:,:) - v(1, :,:); -diff(v,1,1)];
    fenzi = numer .* DTD  + beta * fft2(Gxx + Gyy);
    fenmu = denom .* DTD  + beta * DTD + 1e-5;

    fft_o = fenzi./fenmu;
    o = real(ifft2(fft_o));
    
    % g sub
    temp_gx = [diff(o,1,2), o(:,1,:) - o(:,end,:)];
    temp_gy = [diff(o,1,1); o(1,:,:) - o(end,:,:)];
    sss = sqrt((temp_gx - bx).^2 + (temp_gx - bx).^2) + 1e-5;

    gx = (temp_gx - bx)./sss .* max(sss - beta_TV/beta,0);
    gy = (temp_gy - by)./sss .* max(sss - beta_TV/beta,0);
    

    bx = bx + gx - temp_gx;
    by = by + gy - temp_gy;
end

o_TV = o;


end