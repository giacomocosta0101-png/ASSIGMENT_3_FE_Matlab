function price = tranchePriceExact_Vasicek(I, p, rho, LGD, Kd, Ku, disc_fact, notional)
% TRANCHEPRICEEXACT_VASICEK
%
% Computes the exact price of a tranche [Kd, Ku] in the
% Vasicek one‑factor model for a finite homogeneous pool of size I.
%
% INPUTS:
%   I        : number of obligors in the homogeneous portfolio
%   p        : unconditional default probability over the horizon T
%   rho      : asset correlation parameter in the Vasicek model
%   LGD      : loss‑given‑default (LGD = 1 - recovery)
%   Kd       : attachment point of the tranche (as fraction of portfolio)
%   Ku       : detachment point of the tranche (as fraction of portfolio)
%   disc_fact: discount factor from valuation date to expiry
%   notional : tranche notional
%
% OUTPUT:
%   price : tranche price, computed as:
%       price = B(t0, T) * (1 - E[l]) * notional
%   where B(t0, T) is the discount factor and E[l] is the expected
%   tranche loss as a fraction of the tranche notional.
%
% THEORY:
%   Conditional on the systemic factor Y = y, defaults are independent
%   Bernoulli(p(y)), where:
%
%       p(y) = N( (K - sqrt(rho)*y) / sqrt(1 - rho) )
%       K    = N^{-1}(p)
%
%   The number of defaults M | Y=y follows a Binomial distribution:
%
%       P(M = m | y) = nchoosek(I, m) * p(y)^m * (1 - p(y))^(I - m)
%
%   The tranche loss for a fraction of defaults z = m/I is:
%
%       l(z) = min( max( (LGD*z - Kd)/(Ku - Kd), 0 ), 1 )
%
%   The unconditional expected tranche loss is:
%
%       E[l] = ∫ φ(y) * Σ_{m=0}^I P(m|y) * l(m/I) dy
%
%   where φ(y) is the standard normal density.
%
% Threshold K such that P(v_i <= K) = p
     K = norminv(p);
% Conditional default probability p(y)
    p_y = @(y) normcdf( (K - sqrt(rho).*y) ./ sqrt(1 - rho) );
% Tranche loss as function of fraction of defaults z = m/I
    trancheLoss = @(z) min(max((LGD.*z - Kd) ./ (Ku - Kd), 0), 1);
% Integrand over y: φ(y) * Σ_m P(m|y) * l(m/I)
    integrand = @(y) arrayfun(@(yy) innerSumFinite(I, p_y(yy), trancheLoss), y) ...
                     .* normpdf(y);
    expectedLoss = quadgk(integrand, -Inf,Inf);
% Tranche price
    price = disc_fact * (1 - expectedLoss) * notional;
end