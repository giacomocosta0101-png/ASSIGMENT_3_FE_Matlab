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
% The Delta‑Normal VaR assumes:
%   = X_t are normally distributed
%   = the portfolio is linear w. r. t. to X_t
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
% First‑order approximation:
%       X_t = ΔS_t ≈ S_t * r_t

X = stockPrice * returns; %I think we should do: stockPrice*exp(returns)?

%% 3. Compute the standard deviation of X_t over the VaR horizon
% Daily standard deviation of the risk‑factor variations
sigma_X_daily = std(X); 
% Bisogna usare questa o la volatility data? sigma_X_daily = stockPrice * (volatility / sqrt(252));

% Time scaling 
sigma_X_horizon = sigma_X_daily * sqrt(riskMeasureTimeIntervalInDays);

%% 4. Delta‑Normal VaR (general normal formula with mean and std)
% In the Delta‑Normal framework the risk‑factor variation X_t is assumed normal.
% The linearized loss is:
%           L = − Delta_portfolio * X_t
%
% Therefore:
%   μ_L     = E[L]     = −Delta_portfolio * E[X_t]
%   σ_L     = std(L)   = |Delta_portfolio| * std(X_t)
%
% The general VaR formula for a normal loss distribution is:
%           VaR = −μ_L + z_alpha * σ_L

% Mean of the risk‑factor variation
mu_X = mean(X);

% Mean of the linearized loss
mu_L = -portfolioDelta * mu_X;

% Standard deviation of the linearized loss
sigma_L = abs(portfolioDelta) * sigma_X_horizon;

% Normal quantile
z = norminv(alpha);

% Final Delta‑Normal VaR
VaR = mu_L + z * sigma_L; % i've already compute mu_L as -portfolioDalta*mu_X 

%% 5. What I would do:




end
