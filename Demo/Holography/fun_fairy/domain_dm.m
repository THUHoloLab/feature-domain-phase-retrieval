function [loss,out] = domain_dm(dW,type)


RxdW = [dW(:,2:end,:) - dW(:,1:end-1,:), dW(:,1,:) - dW(:,end,:)];
RydW = [dW(2:end,:,:) - dW(1:end-1,:,:); dW(1,:,:) - dW(end,:,:)];

switch type
    case 'isotropic'
        den = sqrt(RxdW.^2 + RydW.^2) + 1e-5;
        loss = sqrt((RxdW).^2 + (RydW).^2);
        ox = RxdW./den;
        oy = RydW./den;
    case 'anisotropic' 
        loss = abs(RxdW) + abs(RydW);
        ox = sign(RxdW);
        oy = sign(RydW);
    otherwise
    error("parameter #3 should be a string either 'isotropic', or 'anisotropic'")
end

out = [ox(:,end,:) - ox(:, 1,:), ox(:,1:end-1,:) - ox(:,2:end,:)];
out = out + [oy(end,:,:) - oy(1, :,:); oy(1:end-1,:,:) - oy(2:end,:,:)];
loss = sum(loss(:));
end