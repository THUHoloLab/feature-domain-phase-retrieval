%  This is the low-pass filter 'h' (Eq. (13)) we use for generating the
%  adaptive manifolds. 
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

function g = h_filter(f, sigma)

[h w num_channels] = size(f);

g = f;
g = h_filter_horizontal(g, sigma);
g = image_transpose(g);
g = h_filter_horizontal(g, sigma);
g = image_transpose(g);

end

function g = h_filter_horizontal(f, sigma)

a = exp(-sqrt(2) / sigma);

g = f;
[h w nc] = size(f);

for i = 2:w
    for c = 1:nc
        g(:,i,c) = g(:,i,c) + a .* ( g(:,i - 1,c) - g(:,i,c) );
    end
end

for i = w-1:-1:1
    for c = 1:nc
        g(:,i,c) = g(:,i,c) + a .* ( g(:,i + 1,c) - g(:,i,c) );
    end
end

end

function T = image_transpose(I)

[h w num_channels] = size(I);

T = zeros([w h num_channels], class(I));

for c = 1:num_channels
	T(:,:,c) = I(:,:,c)';
end
    
end
