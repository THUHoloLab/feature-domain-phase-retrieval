function g = dF(x,y,A,AH)
% =========================================================================
% Wirtinger gradient of the data-fidelity function.
% -------------------------------------------------------------------------
% Input:    - x : The 3D complex-valued spatiotemporal datacube.
% Output:   - g : Wirtinger gradient.
% =========================================================================
g = NaN(size(x));
    u = A(x);
    u = (abs(u) - sqrt(y)) .* exp(1i*angle(u));
    g = 1/2 * AH(u);
end