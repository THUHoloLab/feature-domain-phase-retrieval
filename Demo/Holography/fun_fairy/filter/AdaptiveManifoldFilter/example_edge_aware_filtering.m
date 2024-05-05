%  This MATLAB script demonstrates how to perform edge-aware color filtering
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

% Read input image
f = imread('images/kodim23.png');

% Set filtering parameters
sigma_s = 24;
sigma_r = 0.2;

% The tree height is computed automatically
g = adaptive_manifold_filter(f, sigma_s, sigma_r);

% Show the images to the screen
figure;
subplot(1,2,1); imshow(f); title('Input photograph');
subplot(1,2,2); imshow(g); title('Edge-aware smoothing with our adaptive-manifold filter in 5-D');
