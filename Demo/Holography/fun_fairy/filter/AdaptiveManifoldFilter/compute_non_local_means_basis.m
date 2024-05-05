%  This implements a simple non-local-means patchspace. Note that this code is
%  not optimized for memory use.  
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

function [H Eval C] = compute_non_local_means_basis(I, radius, pca_outdim)

[h w nc] = size(I);

nneighbors = (2*radius + 1)^2;

H = zeros([h w nneighbors*nc]);

n = 1;

I = bsxfun(@minus, I, mean(mean(I)));

for i = -radius:radius
    for j = -radius:radius
        dist2  = i^2 + j^2;
        weight = exp(-dist2 / 2 / (radius / 2));
        C = circshift(I, [i j]);
        H(:,:, 3*(n-1)+1:3*n) = C * weight;
        n = n + 1;
    end
end

if exist('pca_outdim','var');
    H = reshape(H, h*w, nneighbors*nc);
    H = bsxfun(@minus, H, mean(H));
    
    [Evec Eval] = eig( H'*H );

    Evec = flipdim(Evec, 2);

    Eval = flipdim(diag(Eval),1)';
    Eval = Eval(1:pca_outdim);

    C = reshape( H, [h w nneighbors*nc] );
    H = reshape( H*Evec(:,1:pca_outdim), [h w pca_outdim] );
end

end
