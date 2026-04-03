function VaR = DeltaNormalVaR(alpha, numberOfShares, numberOfPuts, ...
    stockPrice, strike, rate, dividendYield, volatility, ...
    TTMinYears, riskMeasureTimeIntervalInDays, returns)
% DELTANORMALVAR
% Computes the Delta‑Normal VaR of a portfolio composed of:
%   = numberOfShares shares of the underlying
%   = numberOfPuts European put options on the same underlying
%
% The method follows the first‑order expansion:
%       L(X_t) ≈ − sensi(t) * X_t
%
% As per the course convention, "Delta-normal" refers to the first-order
% (Delta) linearization of the portfolio. The loss distribution is obtained
% via Historical Simulation on the underlying returns.
%
% INPUTS:
%   alpha               = confidence level
%   numberOfShares      = number of shares in the portfolio
%   numberOfPuts        = number of put options in the portfolio
%   stockPrice          = current stock price S_t
%   strike              = strike price of the put
%   rate                = risk‑free rate (yearly)
%   dividendYield       = dividend yield (yearly)
%   volatility          = yearly volatility of the underlying
%   TTMinYears          = time‑to‑maturity of the option (years, ACT/365)
%   riskMeasureTimeIntervalInDays = time horizon in days
%   returns             = vector of historical daily returns ( in this case
%                         corresponding to Generali)
%
% OUTPUT:
%   VaR                 = Delta‑Normal Value‑at‑Risk

%% 1. Compute the put option Delta (sensitivity to the underlying)
[~, putDelta] = blsdelta(stockPrice, strike, rate, TTMinYears, ...
                         volatility, dividendYield);

% Portfolio Delta = Delta_shares + Delta_puts
portfolioDelta = numberOfShares + numberOfPuts * putDelta;

%% 2. Compute the risk‑factor variations X_t
% For our portfolio, the risk factor is the underlying price.
% We compute the price change from historical returns:
%       ΔS = S_t * (exp(r_t) - 1)
DeltaS = stockPrice * (exp(returns) - 1);

%% 3. Compute the linearized portfolio losses
% First‑order approximation:
%       L = − Delta_portfolio * ΔS
losses = -portfolioDelta * DeltaS;

%% 4. Delta‑Normal VaR via Historical Simulation
% We extract the alpha-quantile from the empirical loss distribution
VaR = quantile(losses, alpha) * sqrt(riskMeasureTimeIntervalInDays);

end