function rollout = rollingguidance_multichannel(In,sigmas,sigmar,iter)
% employ adaptive manifold for the bilateral filter
if ~exist('sigmas','var')
    sigmas = 10;
end
if ~exist('sigmar','var')
    sigmar = 0.1;
end
if ~exist('iter','var')
    iter = 4;
end

gausskernel = fspecial('gaussian',2*sigmas+1,sigmas);

init = imfilter(In,gausskernel,'same','corr');
tree_height = compute_manifold_tree_height(sigmas, sigmar);
for i=1:iter
    disp(['Iteration ' num2str(i)]);
    [~,init] = adaptive_manifold_filter(In,sigmas,sigmar,tree_height);
end
rollout = init;
end
