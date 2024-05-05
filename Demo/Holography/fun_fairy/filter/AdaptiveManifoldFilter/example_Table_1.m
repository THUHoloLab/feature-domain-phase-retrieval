%  This MATLAB script generates the number of manifold values from Table 1 of
%  our supplementary PDF.
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

[S R] = meshgrid([1 4 8 16 32 64 128], [0.01 0.1 0.2 0.4 1]);

fprintf('Table 1 from our supplementary pdf:\n');
disp(2.^compute_manifold_tree_height(S,R) - 1)
