%  This is the implementation of the RF filter of [Gastal and Oliveira 2011],
%  modified to use an l2-norm when blurring over the adaptive manifolds.
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

function F = RF_filter(img, joint_image, sigma_s, sigma_r)

I = double(img);

if exist('joint_image', 'var') && ~isempty(joint_image)
    J = double(joint_image);

	if (size(I,1) ~= size(J,1)) || (size(I,2) ~= size(J,2))
		error('Input and joint images must have equal width and height.');
	end
else
    J = I;
end

[h w num_joint_channels] = size(J);

dIcdx = diff(J, 1, 2);
dIcdy = diff(J, 1, 1);

dIdx = zeros(h,w);
dIdy = zeros(h,w);

for c = 1:num_joint_channels
    dIdx(:,2:end) = dIdx(:,2:end) + ( dIcdx(:,:,c) ).^2;
    dIdy(2:end,:) = dIdy(2:end,:) + ( dIcdy(:,:,c) ).^2;
end

sigma_H = sigma_s;

dHdx = sqrt((sigma_H/sigma_s).^2 + (sigma_H/sigma_r).^2 * dIdx);
dVdy = sqrt((sigma_H/sigma_s).^2 + (sigma_H/sigma_r).^2 * dIdy);

dVdy = dVdy';

N = 1;
F = I;

for i = 0:N - 1

    sigma_H_i = sigma_H * sqrt(3) * 2^(N - (i + 1)) / sqrt(4^N - 1);

    F = TransformedDomainRecursiveFilter_Horizontal(F, dHdx, sigma_H_i);
    F = image_transpose(F);

    F = TransformedDomainRecursiveFilter_Horizontal(F, dVdy, sigma_H_i);
    F = image_transpose(F);
    
end

F = cast(F, class(img));

end


function F = TransformedDomainRecursiveFilter_Horizontal(I, D, sigma)

a = exp(-sqrt(2) / sigma);

F = I;
V = a.^D;

[h w num_channels] = size(I);

for i = 2:w
    for c = 1:num_channels
        F(:,i,c) = F(:,i,c) + V(:,i) .* ( F(:,i - 1,c) - F(:,i,c) );
    end
end

for i = w-1:-1:1
    for c = 1:num_channels
        F(:,i,c) = F(:,i,c) + V(:,i+1) .* ( F(:,i + 1,c) - F(:,i,c) );
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
