%  ADAPTIVE_MANIFOLD_FILTER  High-dimensional filtering using adaptive manifolds
% 
%  Parameters:
%    f                    Input image to be filtered.
%    sigma_s              Filter spatial standard deviation.
%    sigma_r              Filter range standard deviation.
%
%  Optional parameters:
%    tree_height          Height of the manifold tree (default: automatically computed).
%    f_joint              Image for joint filtering.
%    num_pca_iterations   Number of iterations to computed the eigenvector v1 (default: 1)
%
%  Output:
%    g                    Adaptive-manifold filter response adjusted for outliers.
%    tilde_g              Adaptive-manifold filter response NOT adjusted for outliers.
%
%
%
%  This code is part of the reference implementation of the adaptive-manifold
%  high-dimensional filter described in the paper:
% 
%    Adaptive Manifolds for Real-Time High-Dimensional Filtering
%    Eduardo S. L. Gastal  and  Manuel M. Oliveira
%    ACM Transactions on Graphics. Volume 31 (2012), Number 4.
%    Proceedings of SIGGRAPH 2012, Article 33.
%
%  Please refer to the publication above if you use this software. For an
%  up-to-date version go to:
%  
%             http://inf.ufrgs.br/~eslgastal/AdaptiveManifolds/
%
%
%  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY EXPRESSED OR IMPLIED WARRANTIES
%  OF ANY KIND, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
%  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%  OUT OF OR IN CONNECTION WITH THIS SOFTWARE OR THE USE OR OTHER DEALINGS IN
%  THIS SOFTWARE.
%
%  Version 1.0 - January 2012.

function [g tilde_g] = adaptive_manifold_filter(f, sigma_s, sigma_r, tree_height, f_joint, num_pca_iterations)

f = im2double(f);

% Use the center pixel as seed to random number generation.
rand('seed', f(round(end/2),round(end/2),1) );

global sum_w_ki_Psi_blur;
global sum_w_ki_Psi_blur_0;

sum_w_ki_Psi_blur   = zeros(size(f));
sum_w_ki_Psi_blur_0 = zeros(size(f,1),size(f,2));

global min_pixel_dist_to_manifold_squared;

min_pixel_dist_to_manifold_squared = inf(size(f,1),size(f,2));

% If the tree_height was not specified, compute it using Eq. (10) of our paper.
if ~exist('tree_height','var') || isempty(tree_height)
	tree_height = compute_manifold_tree_height(sigma_s, sigma_r);
end

% If no joint signal was specified, use the original signal
if ~exist('f_joint','var')
	f_joint = f;
else
	f_joint = im2double(f_joint);
end

% By default we use only one iteration to compute the eigenvector v1 (Appendix B)
if ~exist('num_pca_iterations','var')
    num_pca_iterations = 1;
end

% Display a progress bar
%global waitbar_handle;
global tree_nodes_visited;
tree_nodes_visited = 0;
%waitbar_handle = waitbar(0, ['Filtering with ' num2str(2^tree_height - 1) ' Adaptive Manifolds in ' num2str(2 + size(f_joint,3)) '-D Space...']);

% Algorithm 1, Step 1: compute the first manifold by low-pass filtering.
eta_1     = h_filter(f_joint, sigma_s);
cluster_1 = true(size(f,1),size(f,2));

current_tree_level = 1;

build_manifolds_and_perform_filtering(...
       f ...
     , f_joint ...
     , eta_1 ...
     , cluster_1 ...
     , sigma_s ...
     , sigma_r ...
     , current_tree_level ...
     , tree_height ...
     , num_pca_iterations ...
 );

% Compute the filter response by normalized convolution -- Eq. (4)
tilde_g = bsxfun(@rdivide, sum_w_ki_Psi_blur, sum_w_ki_Psi_blur_0);

% Adjust the filter response for outlier pixels -- Eq. (10)
alpha = exp( -0.5 .* min_pixel_dist_to_manifold_squared ./ sigma_r ./ sigma_r );
g     = f + bsxfun(@times, alpha, tilde_g - f);

% Close progressbar
%delete(waitbar_handle);

end

function build_manifolds_and_perform_filtering(...
       f ...
     , f_joint ...
     , eta_k ...
     , cluster_k ...
     , sigma_s ...
     , sigma_r ...
     , current_tree_level ...
     , tree_height ...
     , num_pca_iterations ...
)

    % Dividing the covariance matrix by 2 is equivalent to dividing
    % the standard deviations by sqrt(2).
    sigma_r_over_sqrt_2 = sigma_r / sqrt(2);

    %% Compute downsampling factor
    floor_to_power_of_two = @(r) 2^floor(log2(r));
    df = min(sigma_s / 4, 256 * sigma_r);
    df = floor_to_power_of_two(df);
    df = max(1, df);
    
    [h_image w_image dR_image] = size(f);
    [h_joint w_joint dR_joint] = size(f_joint);
    
    downsample = @(x) imresize(x, 1/df, 'bilinear');
    upsample   = @(x) imresize(x, [h_image w_image], 'bilinear');
    
    %% Splatting: project the pixel values onto the current manifold eta_k
    
    phi = @(x_squared, sigma) exp( -0.5 .* x_squared ./ sigma / sigma );
    
    if size(eta_k,1) == size(f_joint,1)
        X = f_joint - eta_k;
        eta_k = downsample(eta_k);
    else
        X = f_joint - upsample(eta_k);
    end
    
    % Project pixel colors onto the manifold -- Eq. (3), Eq. (5)
    pixel_dist_to_manifold_squared = sum( X.^2, 3 );
    gaussian_distance_weights      = phi(pixel_dist_to_manifold_squared, sigma_r_over_sqrt_2);
    Psi_splat                      = bsxfun(@times, gaussian_distance_weights, f);
    Psi_splat_0                    = gaussian_distance_weights;
    
    % Save min distance to later perform adjustment of outliers -- Eq. (10)
    global min_pixel_dist_to_manifold_squared;
    min_pixel_dist_to_manifold_squared = min(min_pixel_dist_to_manifold_squared, pixel_dist_to_manifold_squared);
    
    %% Blurring: perform filtering over the current manifold eta_k

    blurred_projected_values = RF_filter(...
          downsample(cat(3, Psi_splat, Psi_splat_0)) ...
        , eta_k ...
        , sigma_s / df ...
        , sigma_r_over_sqrt_2 ...
    );

    w_ki_Psi_blur   = blurred_projected_values(:,:,1:end-1);
    w_ki_Psi_blur_0 = blurred_projected_values(:,:,end);

    %% Slicing: gather blurred values from the manifold
    
    global sum_w_ki_Psi_blur;
    global sum_w_ki_Psi_blur_0;
    
    % Since we perform splatting and slicing at the same points over the manifolds,
    % the interpolation weights are equal to the gaussian weights used for splatting.
    w_ki = gaussian_distance_weights;
    
    sum_w_ki_Psi_blur   = sum_w_ki_Psi_blur   + bsxfun(@times, w_ki, upsample(w_ki_Psi_blur  ));
    sum_w_ki_Psi_blur_0 = sum_w_ki_Psi_blur_0 + bsxfun(@times, w_ki, upsample(w_ki_Psi_blur_0));
    
    %% Compute two new manifolds eta_minus and eta_plus
    
    % Update progressbar
	% global waitbar_handle;
	global tree_nodes_visited;
	tree_nodes_visited = tree_nodes_visited + 1;
	% waitbar(tree_nodes_visited / (2^tree_height - 1), waitbar_handle);
    
    % Test stopping criterion
    if current_tree_level < tree_height

        % Algorithm 1, Step 2: compute the eigenvector v1
        X  = reshape(X, [h_joint*w_joint dR_joint]);
        rand_vec = rand(1,size(X,2)) - 0.5;
        v1 = compute_eigenvector(X(cluster_k(:),:), num_pca_iterations, rand_vec);
        
        % Algorithm 1, Step 3: Segment pixels into two clusters -- Eq. (6)
        dot = reshape(X * v1', [h_joint w_joint]);
        cluster_minus = logical((dot <  0) & cluster_k);
        cluster_plus  = logical((dot >= 0) & cluster_k);
        
        % Algorithm 1, Step 4: Compute new manifolds by weighted low-pass filtering -- Eq. (7-8)
        theta = 1 - w_ki;
        
        eta_minus = bsxfun(@rdivide ...
            , h_filter(downsample(bsxfun(@times, cluster_minus .* theta, f_joint)), sigma_s / df) ...
            , h_filter(downsample(               cluster_minus .* theta          ), sigma_s / df));
        
        eta_plus = bsxfun(@rdivide ...
            , h_filter(downsample(bsxfun(@times, cluster_plus .* theta, f_joint)), sigma_s / df) ...
            , h_filter(downsample(               cluster_plus .* theta          ), sigma_s / df));

		% Only keep required data in memory before recursing
        keep f f_joint eta_minus eta_plus cluster_minus cluster_plus sigma_s sigma_r current_tree_level tree_height num_pca_iterations
        
        % Algorithm 1, Step 5: recursively build more manifolds.
        build_manifolds_and_perform_filtering(f, f_joint, eta_minus, cluster_minus, sigma_s, sigma_r, current_tree_level + 1, tree_height, num_pca_iterations);
        keep f f_joint eta_plus cluster_plus sigma_s sigma_r current_tree_level tree_height num_pca_iterations
        build_manifolds_and_perform_filtering(f, f_joint, eta_plus,  cluster_plus,  sigma_s, sigma_r, current_tree_level + 1, tree_height, num_pca_iterations);
    end
    
end

% This function implements a O(dR N) algorithm to compute the eigenvector v1
% used for segmentation. See Appendix B.
function p = compute_eigenvector(X, num_pca_iterations, rand_vec)

p = rand_vec;

for i = 1:num_pca_iterations
    
    dots = sum( bsxfun(@times, p, X), 2 );
    t = bsxfun(@times, dots, X);
    t = sum(t, 1);
    p = t;

end

p = p / norm(p);

end

%#ok<*NASGU>
%#ok<*ASGLU>
