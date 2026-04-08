function VaR = FullMonteCarloVaR(alpha, numberOfShares, numberOfPuts, ...
    currentPrice, strike, rate, dividendYield, volatility, ...
    TTM_in_years, riskMeasureTimeIntervalInDays, returns)

% FULLMONTECARLOVAR
% Computes Full Monte‑Carlo VaR of a portfolio composed of:
%   - numberOfShares shares of the underlying
%   - numberOfPuts European put options on the same underlying
%
% The method follows the Full‑Valuation Monte‑Carlo approach:
%   1. Simulate underlying prices at t + Δ using historical returns
%   2. Reprice the option at t + Δ using Black‑Scholes
%   3. Compute the portfolio loss for each scenario
%   4. Extract the α‑quantile of the loss distribution
%
% INPUTS:
%   alpha           = confidence level 
%   numberOfShares  = number of shares in the portfolio
%   numberOfPuts    =  number of put options in the portfolio
%   currentPrice    = current stock price S_t
%   strike          = strike price of the put
%   rate            = risk‑free rate (yearly)
%   dividendYield   = dividend yield (yearly)
%   volatility      = volatility of the underlying (yearly)
%   TTM_in_years    = time‑to‑maturity of the option (years)
%   riskMeasureTimeIntervalInDays = time horizon in days
%   returns         = vector of historical daily returns ( in this case
%                     corresponding to Generali)
%
% OUTPUT:
%   VaR : Full Monte‑Carlo Value‑at‑Risk


%% 1. Simulate stock prices at t + Δ by using historical returns
S_next = currentPrice * exp(returns);


%% 2. Compute the put option price today (Black‑Scholes)
[~, putToday] = blsprice(currentPrice, strike, rate, TTM_in_years, ...
                    volatility, dividendYield);

%% 3. Compute option price at t + Δ for each simulated S_next
% we compute the new time‑to‑maturity which decreases by Δ = 1 day. Since we 
% want an yearly quantity, we divide the daily riskMeasureTimeIntervalInDays
% by 252 (number of trading day in one year)
TTM_next = TTM_in_years - riskMeasureTimeIntervalInDays/365; % più coerente con ACT/365

% Reprice the put for each simulated underlying
[~, putTomorrow]  = blsprice(S_next, strike, rate, TTM_next,volatility, dividendYield);

%% 4. Compute portfolio value today and tomorrow
V_today = numberOfShares * currentPrice + numberOfPuts * putToday;
V_tomorrow = numberOfShares * S_next + numberOfPuts * putTomorrow;


%% 5. Compute losses for each scenario
% Loss = V(t) - V(t+Δ)
losses = V_today - V_tomorrow;


%% 6. Extract the α‑quantile of the loss distribution
VaR = quantile(losses, alpha);

end
