function [price_LHP, price_exact, price_KL] = compute_tranche_prices( ...
        I_grid, p, rho, LGD, Kd, Ku, valuationDate, expiry, I_max_exact, ...
        notional)
% COMPUTE_TRANCHE_PRICES 
%   Computes the LHP, exact finite-pool (only for I ≤ I_max_exact),
%   and KL-approximation prices for a Vasicek tranche
%
%   INPUTS:
%       I_grid       – vector of pool sizes ( logspace grid)
%       p            – default probability
%       rho          – asset correlation
%       LGD          – loss given default
%       Kd, Ku       – attachment / detachment points
%       valuationDate– current date
%       expiry       – end of the interest period
%       I_max_exact  – maximum pool size for exact computation
%       notional     – notional 
%
%   OUTPUTS:
%       price_LHP    – LHP price (same size as I_grid)
%       price_exact  – exact finite-pool price (NaN where I > I_max_exact)
%       price_KL     – KL approximation price 
%


% We compute the discount factor
[disc_fact, ~]= find_rate_from_bootstrap_curve(valuationDate,expiry);


% LHP price
price_LHP_value = tranchePriceLHP_Vasicek(p, rho, LGD, Kd, Ku);
price_LHP = disc_fact*(1 - price_LHP_value * ones(size(I_grid)))*notional;

% Exact finite-pool price (only for I ≤ I_max_exact)
price_exact = NaN(size(I_grid));   % initialization
idx_exact = (I_grid <= I_max_exact);

if any(idx_exact)
    % Vector of I values where exact computation is feasible
    I_small = I_grid(idx_exact);

    % Compute exact prices for all feasible I
    price_exact(idx_exact) = arrayfun(@(I) ...
       disc_fact*(1 - tranchePriceExact_Vasicek(I, p, rho, LGD, Kd, Ku))*notional, I_small);
end

% KL approximation
price_KL = arrayfun(@(I) ...
    disc_fact*(1 - tranchePriceKL_Vasicek(I, p, rho, LGD, Kd, Ku))*notional, I_grid);

end
