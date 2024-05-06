function o = complex_Hessian(S, lambda,type)

betamax = 1e4;

fxx = [-1,2,-1];
fyy = [-1;2;-1];
fxy = [1,-1;-1,1];

[N,M,D] = size(S);

otfFxx = psf2otf(fxx,[N,M]);
otfFyy = psf2otf(fyy,[N,M]);
otfFxy = psf2otf(fxy,[N,M]);

Normin1 = fft2(S);

Denormin2 = abs(otfFxx).^2 + abs(otfFyy).^2 + 2 * abs(otfFxy).^2;
if D>1
    Denormin2 = repmat(Denormin2,[1,1,D]);
end
beta = lambda;

o = S;

foo = @(x) 8 * exp(-8*abs(x));

while beta < betamax
    lambeta = lambda/beta;
    Denormin   = 1 + beta*Denormin2;
    % h-v subproblem
%     gxx = ifft2(fft2(o).*otfFxx);
%     gyy = ifft2(fft2(o).*otfFyy);
%     gxy = ifft2(fft2(o).*otfFxy);
    gxx = forward_difference_xx(o);
    gyy = forward_difference_yy(o);
    gxy = forward_difference_xy(o);

    switch type
        case 'isotropic'
            den = sqrt(gxx.^2 + gyy.^2 + 2*gxy.^2) + 1e-3;
            gxx = gxx ./abs(den) .* max(abs(den) - lambeta ,0);
            gyy = gyy ./abs(den) .* max(abs(den) - lambeta ,0);
            gxy = gxy ./abs(den) .* max(abs(den) - lambeta ,0);
        case 'anisotropic'
            gxx = sign(gxx) .* max(abs(gxx) - lambeta ,0);
            gyy = sign(gyy) .* max(abs(gyy) - lambeta ,0);
            gxy = sign(gxy) .* max(abs(gxy) - lambeta ,0);
        case 'hard'
            den = u.^2 + v.^2;
            u = (abs(den) > lambeta) .* u;
            v = (abs(den) > lambeta) .* v;
        otherwise
            error('the type should be isotropic, or anisotrapic, or hard');
    end
    

    % o subproblem
%     gxx = fft2(gxx) .* conj(otfFxx);
%     gyy = fft2(gyy) .* conj(otfFyy);
%     gxy = fft2(gxy) .* conj(otfFxy);
%     Fo = (Normin1 + beta*(gxx + gyy + 2*gxy))./Denormin;

    gxx = backward_difference_xx(gxx);
    gyy = backward_difference_yy(gyy);
    gxy = backward_difference_xy(gxy);
    Fo = (Normin1 + beta*fft2(gxx + gyy + 2*gxy))./Denormin;
    o = (ifft2(Fo));

    beta = beta*2;

end

end


function out = forward_difference_xx(o)
temp = [diff(o,1,2), o(:,1,:) - o(:,end,:)];
out = [diff(temp,1,2), temp(:,1,:) - temp(:,end,:)];
end

function out = forward_difference_yy(o)
temp = [diff(o,1,1); o(1,:,:) - o(end,:,:)];
out = [diff(temp,1,1); temp(1,:,:) - temp(end,:,:)];
end

function out = forward_difference_xy(o)
temp = [diff(o,1,2), o(:,1,:) - o(:,end,:)];
out = [diff(temp,1,1); temp(1,:,:) - temp(end,:,:)];
end


function out = backward_difference_xx(o)
temp = [o(:,end,:) - o(:, 1,:), -diff(o,1,2)];
out = [temp(:,end,:) - temp(:, 1,:), -diff(temp,1,2)];
end

function out = backward_difference_yy(o)
temp = [o(end,:,:) - o(1, :,:); -diff(o,1,1)];
out = [temp(end,:,:) - temp(1, :,:); -diff(temp,1,1)];
end

function out = backward_difference_xy(o)
temp = [o(:,end,:) - o(:, 1,:), -diff(o,1,2)];
out = [temp(end,:,:) - temp(1, :,:); -diff(temp,1,1)];
end
