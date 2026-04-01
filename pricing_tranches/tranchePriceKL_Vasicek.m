function price = tranchePriceKL_Vasicek(I, p, rho, LGD, Kd, Ku)
% TRANCHEPRICEKL_VASICEK
% 
% KL approximation of the expected tranche loss for a tranche [Kd, Ku] in 
% the Vasicek model.
%
% INPUTS:
%   I   : number of obligors in the homogeneous pool
%   p   : default probability
%   rho : asset correlation
%   LGD : loss given default
%   Kd  : attachment point
%   Ku  : detachment point
%
% OUTPUT:
%   price : approximate expected tranche loss (fraction of tranche notional)
%
% THEORY:
%   For large I, the binomial term is approximated via Stirling:
%
%       P(m|y) ≈ (1/I) * C1(z) * exp( -I * K(z, p(y)) ),   z = m/I
%
%   where:
%       K(z,q) = z ln(z/q) + (1-z) ln((1-z)/(1-q))   
%
%       C1(z) = 1 / sqrt(2*pi*z*(1-z))              
%
%   Expected tranche loss:
%
%       E[l] ≈ ∫ dy φ(y) ∫_0^1 dz C1(z) e^{-I K(z,p(y))} l(z)
%


    % Threshold K such that P(v_i <= K) = p
    Kthr = norminv(p);

    % Conditional default probability p(y)
    p_y = @(y) normcdf( (Kthr - sqrt(rho).*y) ./ sqrt(1 - rho) );

    % Tranche loss as function of fraction of defaults z
    trancheLoss = @(z) min(max((LGD.*z - Kd) ./ (Ku - Kd), 0), 1);

    % KL = K(z,q) = z ln(z/q) + (1-z) ln((1-z)/(1-q)) 
    KL = @(z, q) z .* log(z ./ q) + (1 - z) .* log((1 - z) ./ (1 - q));

    % Stirling prefactor C1(z) = 1 / sqrt(2*pi*z*(1-z))
    C1 = @(z) sqrt(I)./ sqrt(2*pi*z.*(1-z));

    % Inner integral over z in [0,1]
    innerZ = @(y) quadgk(@(z) ...
        C1(z).* ...                          % Stirling prefactor
        exp(-I .* KL(z, p_y(y))) .* ...       % KL exponential term
        trancheLoss(z), ...                   % tranche payoff
        0, 1);

    % Outer integral over Y ~ N(0,1)
     integrandY = @(y) arrayfun(@(yy) innerZ(yy), y) .* normpdf(y);
     price = quadgk(integrandY, -Inf, Inf);
end
