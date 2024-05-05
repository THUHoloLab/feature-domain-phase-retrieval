function rollout = rollingguidance_multichannelRF(In,sigmas,sigmar,iter)
% employ adaptive manifold for the bilateral filter
if ~exist('sigmas','var')
    sigmas = 10;
end
if ~exist('sigmar','var')
    sigmar = 0.1;
end
if ~exist('iter','var')
    iter = 5;
end

init = ones(size(In));
for i=1:iter
    disp(['Iteration ' num2str(i)]);
    init = RF(In,sigmas,sigmar,5,init);
end
rollout = init;
end
