function [VaR_FMC, VaR_DN] = computeVaR_Exercise2(stockNotional, strike, expiryDate,...
    refDate, alpha, volatility, dividendYield, riskMeasureTimeIntervalInDays, ...
    timeWindow, sharesList, inputFile, formatDate)

% COMPUTEVAR_EXERCISE2
% Computes the Full Monte‑Carlo VaR and the Delta‑Normal VaR for the
% portfolio described in Exercise 2
%
% The portfolio consists of:
%   - stockNotional invested in Generali shares
%   - the same number of European put options (same maturity and strike)
%
% INPUTS:
%   stockNotional  = amount invested in Generali (EUR)
%   strike         = strike price of the put option
%   expiryDate     = option maturity (datenum)
%   refDate        = valuation date (datenum)
%   alpha          = confidence level for VaR
%   volatility     = yearly volatility of the underlying
%   dividendYield  = yearly dividend yield
%   riskMeasureTimeIntervalInDays = time horizon in days 
%   timeWindow     = length of the historical window
%   sharesList     = portfolio composition
%   inputFile      = Excel file containing historical data
%   formatDate     = date format
%
% OUTPUTS:
%   VaR_FMC        = Full Monte‑Carlo VaR
%   VaR_DN         = Delta‑Normal VaR

%% 1. Retrieve the zero‑coupon rate from the bootstrap curve
[~,rate] = find_rate_from_bootstrap_curve(refDate,expiryDate);


%% 2. Load 2‑year historical returns and aligned prices for Generali
[~, returnsSelected, pricesAligned] = returnsOfInterest( ...
    inputFile, refDate, timeWindow, sharesList, formatDate);

%% 3. Current stock price (last aligned price)
currentPrice = pricesAligned(end)

%% 4. Number of shares and number of puts
% The investor holds stockNotional worth of Generali shares
numberOfShares = stockNotional / currentPrice

% The same number of put options is held
numberOfPuts = numberOfShares;

%% 5. Time‑to‑maturity in years for the put
TTM_in_years = yearfrac(refDate, expiryDate, 3); % ACT/365 day convention 

%% 6. Full Monte‑Carlo VaR
VaR_FMC = FullMonteCarloVaR(alpha, numberOfShares, numberOfPuts, ...
    currentPrice, strike, rate, dividendYield, volatility, ...
    TTM_in_years, riskMeasureTimeIntervalInDays, returnsSelected);


%% 7. Delta‑Normal VaR
VaR_DN = DeltaNormalVaR(alpha, numberOfShares, numberOfPuts, ...
    currentPrice, strike, rate, dividendYield, volatility, ...
    TTM_in_years, riskMeasureTimeIntervalInDays, returnsSelected);

end
