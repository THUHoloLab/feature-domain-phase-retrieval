function u = DT(w)

% [n1,n2,~] = size(w);
% 
% shift = circshift(w(:,:,1),[1,0]);
% u1 = w(:,:,1) - shift;
% u1(1,:) = w(1,:,1);
% u1(n1,:) = -shift(n1,:);
% 
% shift = circshift(w(:,:,2),[0,1]);
% u2 = w(:,:,2) - shift;
% u2(:,1) = w(:,1,2);
% u2(:,n2) = -shift(:,n2);
% 
% u = u1 + u2;
ox = w(:,:,1);
oy = w(:,:,2);

u = [ox(:,end,:) - ox(:, 1,:), ox(:,1:end-1,:) - ox(:,2:end,:)];
u = u + [oy(end,:,:) - oy(1, :,:); oy(1:end-1,:,:) - oy(2:end,:,:)];

end

