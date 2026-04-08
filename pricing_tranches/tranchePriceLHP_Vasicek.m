function price = tranchePriceLHP_Vasicek(p, rho, LGD, Kd, Ku, disc_fact, notional)
% TRANCHEPRICELHP_VASICEK
%   Price of a tranche [Kd, Ku] in the Vasicek model under the
%   Large Homogeneous Portfolio (LHP) assumption.
%
%   INPUTS:
%       p        : default probability
%       rho      : correlation
%       LGD      : loss given default (1 - recovery)
%       Kd       : attachment point (as fraction of portfolio notional)
%       Ku       : detachment point (as fraction of portfolio notional)
%       disc_fact: discount factor from valuation date to expiry
%       notional : tranche notional
%
%   OUTPUT:
%       price : tranche price, computed as:
%           price = B(t0, T) * (1 - E[l]) * notional
%       where B(t0, T) is the discount factor and E[l] is the expected
%       tranche loss as a fraction of the tranche notional.
%
%   Under LHP:
%       - fraction of defaults Z = p(Y), with Y ~ N(0,1)
%       - portfolio loss L_rp = LGD * Z
%       - tranche loss (percentage of tranche notional):
%           l(z) = min( max( (LGD*z - Kd)/(Ku - Kd), 0 ), 1 )
%
%       Expected tranche loss:
%           E[l] = ∫ l(p(y)) φ(y) dy
    K = norminv(p);   % threshold such that P(v_i <= K) = p
% Conditional default probability given Y = y
    p_y = @(y) normcdf( (K - sqrt(rho).*y) ./ sqrt(1 - rho) );
% Tranche loss as function of fraction of defaults z
    trancheLoss = @(z) min(max((LGD.*z - Kd) ./ (Ku - Kd), 0), 1);
% Integrand over Y
    integrand = @(y) trancheLoss(p_y(y)) .* normpdf(y);
% Numerical integration over Y ~ N(0,1) using quadgk
    expectedLoss = quadgk(integrand, -Inf, Inf);
% Tranche price
    price = disc_fact * (1 - expectedLoss) * notional;
end