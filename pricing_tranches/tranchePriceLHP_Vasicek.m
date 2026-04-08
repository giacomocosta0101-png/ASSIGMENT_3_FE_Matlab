function price = tranchePriceLHP_Vasicek(p, rho, LGD, Kd, Ku)
% TRANCHEPRICELHP_VASICEK
%   Expected loss of a tranche [Kd, Ku] in the Vasicek model under the 
%   Large Homogeneous Portfolio (LHP) assumption.
%
%   INPUTS:
%       p   : default probability
%       rho : correlation
%       LGD : loss given default (1 - recovery)
%       Kd  : attachment point (as fraction of portfolio notional)
%       Ku  : detachment point (as fraction of portfolio notional)
%
%   OUTPUT:
%       price : expected tranche loss as a fraction of tranche notional
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
    price = quadgk(integrand, -Inf, Inf);
end
