function priceCliquet = FairPriceCliquet(S0, r, sigma)
% FAIRPRICECLIQUET
% Computes the fair price of the Cliquet option with annual payoff:
%       payoff_i = max(S(t_i) - S(t_{i-1}), 0)
%
% INPUTS:
%   S0          = Current underlying price at time t = 0
%   r           = Constant risk-free interest rate (annual)
%   sigma       = Constant annual volatility of the underlying
%
% OUTPUT:
%   priceCliquet = Fair value of the 5-year Cliquet option at time t = 0
%
% FORMULA:
%   Each coupon has present value:
%       PV_i = S0 * exp(-r) * BSCall(1,1,r,sigma)
%
%   Total Cliquet price:
%       Price = 5 * S0 * exp(-r) * BSCall(1,1,r,sigma)

    % Parameters for the ATM call
    S = 1;      % Normalized underlying
    K = 1;      % ATM strike
    T = 1;      % 1-year maturity
    
    % Black–Scholes d1 and d2
    d1 = (log(S/K) + (r + 0.5*sigma^2)*T) / (sigma*sqrt(T));
    d2 = d1 - sigma*sqrt(T);

    % Price of the ATM call with S=1, K=1
    BSCall_ATM = S * normcdf(d1) - K * exp(-r*T) * normcdf(d2);

    % Fair price of the 5-year Cliquet
    priceCliquet = 5 * S0 * BSCall_ATM;

end
