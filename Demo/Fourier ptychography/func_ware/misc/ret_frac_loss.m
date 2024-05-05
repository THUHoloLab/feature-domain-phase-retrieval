function [loss,out] = ret_frac_loss(x,y,type)

xx = [x(:,2:end,:) - x(:,1:end-1,:), x(:,1,:) - x(:,end,:)] + 2;
xy = [x(2:end,:,:) - x(1:end-1,:,:); x(1,:,:) - x(end,:,:)] + 2;

yx = [y(:,2:end,:) - y(:,1:end-1,:), y(:,1,:) - y(:,end,:)] + 2;
yy = [y(2:end,:,:) - y(1:end-1,:,:); y(1,:,:) - y(end,:,:)] + 2;

switch type
    case 'isotropic'
        ss_y = sqrt(yy.^2 + yx.^2);
        ss_x = sqrt(xx.^2 + xy.^2);      
        ox = sign(1 - ss_y./ss_x) ./ (ss_x.^2) .* xx.*ss_y;
        oy = sign(1 - ss_y./ss_x) ./ (ss_x.^2) .* xy.*ss_y;
        
%         ss_x = (1 - yx./xx).^2;
%         ss_y = (1 - yy./xy).^2;
% 
%         ox = 2.*(1 - yx./xx) ./ sqrt(ss_x + ss_y + 1e-5) .* yx./(xx.^2);
%         oy = 2.*(1 - yy./xy) ./ sqrt(ss_x + ss_y + 1e-5) .* yy./(xy.^2);

    case 'anisotropic'
        ox = sign(1 - yx./xx) ./ (xx.^2) .* yx;
        oy = sign(1 - yy./xy) ./ (xy.^2) .* yy;
    otherwise
end
out = [ox(:,end,:) - ox(:, 1,:), ox(:,1:end-1,:) - ox(:,2:end,:)];
out = out + [oy(end,:,:) - oy(1, :,:); oy(1:end-1,:,:) - oy(2:end,:,:)];
loss = 0;
end