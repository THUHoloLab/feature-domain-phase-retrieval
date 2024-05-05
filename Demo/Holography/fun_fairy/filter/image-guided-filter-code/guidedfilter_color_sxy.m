function res = guidedfilter_color_sxy(I,G,sigmas,eps)
if ~exist('sigmas','var')
    sigmas = 4;
end
if ~exist('eps','var')
    eps = 0.01^2;
end

if size(G,3)~=3
    G = repmat(G(:,:,1),[1 1 3]);
end

for i=1:size(I,3)
    res(:,:,i) = guidedfilter_color(G,I(:,:,i),sigmas,eps);
end

end