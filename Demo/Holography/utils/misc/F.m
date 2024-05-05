function v = F(x,y,A)
% =========================================================================
% Data-fidelity function.
% -------------------------------------------------------------------------
% Input:    - x : The complex-valued image.
% Output:   - v : Value of the fidelity function.
% =========================================================================
% v = 1/2 * norm2(abs(A(x)) - sqrt(y))^2;

diff_map = (abs(A(x)) - sqrt(y)).^2;
v = sum(diff_map(:));
% v = 1/2 * norm2(abs(A(x)) - sqrt(y))^2;
end

function n = norm2(x)
n = norm(x(:),2);
end