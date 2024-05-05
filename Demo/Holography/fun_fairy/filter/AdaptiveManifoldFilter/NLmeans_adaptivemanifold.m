function NLout = NLmeans_adaptivemanifold(In,G,sigmas,sigmar,patchr,numpca,pcaiter)

% using adaptive manifold algorithm to compute the nonlocal means filter
% paramters: IN,G,sigmas,sigmar,patchr,numpca,pcaiter

if ~exist('G','var')
    G = In;
end
if ~exist('sigmas','var')
    sigmas = 8;
end
if ~exist('sigmar','var')
    sigmar = 0.35;
end
if ~exist('patchr','var')
    patchr = 3;
end
if ~exist('numpca','var')
    numpca = 25;
end
if ~exist('pcaiter','var')
    pcaiter = 2;
end

if size(G,3)~=3
    G = repmat(G(:,:,1),[1 1 3]);
end

nlmeans_space      = compute_non_local_means_basis(G, patchr, numpca);
tree_height = 2 + compute_manifold_tree_height(sigmas, sigmar);
% tilde_g is the output of our filter with outliers suppressed.
[~,NLout] = adaptive_manifold_filter(In, sigmas, sigmar, tree_height, nlmeans_space, pcaiter);
end


