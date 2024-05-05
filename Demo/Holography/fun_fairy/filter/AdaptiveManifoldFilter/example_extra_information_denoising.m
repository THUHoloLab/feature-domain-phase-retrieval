%  This MATLAB script demonstrates how to perform denoising with our
%  adaptive-manifold filter in a space defined by non-local-means plus
%  additional information (for this example, an infrared image).
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

% Read noisy low-light color image (f) and infrared image (ir)
f  = imread('images/books-noisy.png');
ir = imread('images/books-infrared.png');
f  = im2double(f);
ir = im2double(ir);

% Compute non-local-means reduced patch space for noisy low-light color image, using 3x3 color patches reduced to 6-D.
patch_radius       = 1; % patch size is 2*patch_radius + 1;
num_pca_dimensions = 6;
nlmeans_space      = compute_non_local_means_basis(f, patch_radius, num_pca_dimensions);

% Filtering parameters
sigma_s       = 8;
sigma_r_color = 0.2;
sigma_r_ir    = 0.04;
pca_iterations = 2;

% The filtering space is defined by the non-local-means PCA-reduced patches, plus the infrared (ir) image.
f_joint = cat(3, nlmeans_space / sigma_r_color, ir / sigma_r_ir);

% Compute tree height using Eq. (12)
tree_height = 2 + compute_manifold_tree_height(sigma_s, sigma_r_color);

% tilde_g is the output of our filter with outliers suppressed.
[g tilde_g] = adaptive_manifold_filter(f, sigma_s, 1, tree_height, f_joint, pca_iterations);

% Show the images to the screen
figure;
subplot(1,2,1); imshow(f);       title('Input noisy low-light image');
subplot(1,2,2); imshow(tilde_g); title('Denoised with our adaptive-manifold filter in 9 dimensions (6-D color range + 1-D infrared + 2-D space)');
