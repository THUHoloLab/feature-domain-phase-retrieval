function w = D(x)

[n1,n2] = size(x);
w = zeros(n1,n2,2);

% w(:,:,1) = x - circshift(x,[-1,0]);
% w(n1,:,1) = 0;
% w(:,:,2) = x - circshift(x,[0,-1]);
% w(:,n2,2) = 0;

w(:,:,1) = [x(:,2:end,:) - x(:,1:end-1,:), x(:,1,:) - x(:,end,:)];
w(:,:,2) = [x(2:end,:,:) - x(1:end-1,:,:); x(1,:,:) - x(end,:,:)];
end

