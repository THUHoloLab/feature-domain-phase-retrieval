%  This MATLAB script demonstrates how to perform non-local-means denoising
%  using our adaptive-manifold filter.
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

% Get noisy data
f = imread('images/eyes_closeup_smaller.png');
f = im2double(f);
noisestddev = 0.2;
randn('seed', 0);
f = f + noisestddev * randn(size(f));

% Compute non-local-means patch space using 7x7 color patches reduced to 25 dimensions.
patch_radius       = 3; % patch size is 2*patch_radius + 1;
num_pca_dimensions = 25;
nlmeans_space      = compute_non_local_means_basis(f, patch_radius, num_pca_dimensions);

% Filtering parameters
sigma_s = 8;
sigma_r = 0.35;
pca_iterations = 2;

% Compute tree height using Eq. (12)
tree_height = 2 + compute_manifold_tree_height(sigma_s, sigma_r);

% tilde_g is the output of our filter with outliers suppressed.
[g tilde_g] = adaptive_manifold_filter(f, sigma_s, sigma_r, tree_height, nlmeans_space, pca_iterations);

% Show the images to the screen
figure;
subplot(1,2,1); imshow(f);       title('Input noisy image');
subplot(1,2,2); imshow(tilde_g); title('Denoised with our adaptive-manifold filter in 27 dimensions (25-D color range + 2-D space)');
