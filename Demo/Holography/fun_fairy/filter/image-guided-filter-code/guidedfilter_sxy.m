function res = guidedfilter_sxy(I,G,sigmas,eps)
if ~exist('sigmas','var')
    sigmas = 4;
end
if ~exist('eps','var')
    eps = 0.01^2;
end

for i=1:size(I,3)
    res(:,:,i) = guidedfilter(G(:,:,1),I(:,:,i),sigmas,eps);
end

end