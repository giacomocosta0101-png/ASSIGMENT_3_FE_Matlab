% runAssignment3
% group 5, AY2025-2026
%
% Risk Measurements of a Linear Portfolio, pricing in presence of counterparty 
% risk and MBS pricing 

%% Parameters
addpath('pricing_tranches','ex_2_VaR')
inputFile = 'sx5e_historical_data.xls'; % File name containing historical price data
formatDate = 'dd/mm/yyyy';              % Date format
NumberOfYears = 2;                      % Length of the historical window
timeWindow = -NumberOfYears * 12;       % Convert years into months

%% Exercise 0
refDate = datenum('24-Jul-2012');         % Current date 
sharesList ={ 'Inditex'; 'BASF'; 'LVMH'}; % Portfolio composition
alpha = 0.95;                             % Confidence level for VaR and ES
portfolioValue = 10e6;                    % Notional
riskMeasureTimeIntervalInDays = 1;        % 1‑day time horizon
numberAssets = size(sharesList,1);        % Number of assets in the ptf
weights = (1/numberAssets) * ones(numberAssets,1);  % Equally‑weighted ptf

[~, returnsSelected, ~] = returnsOfInterest(inputFile, refDate, ...
        timeWindow, sharesList, formatDate);
try  % We compute VaR & ES under the Gaussian approach
    [ES, VaR] = AnalyticNormalMeasures(alpha, weights, portfolioValue, ...
        riskMeasureTimeIntervalInDays, returnsSelected); 
catch err
    err.message 
end
%% Exercise 1.a
alpha = 0.99;                           % Confidence level for VaR and ES
riskMeasureTimeIntervalInDays = 1;      % 1-day time horizon
sharesList = { 'ENI' ; 'Telefonica' ; 'EON' ; 'Daimler' };% Portfolio composition
shares = [18000; 25000; 15000; 9000];   % Number of shares per asset
M = 200;                                % Number of bootstrap simulations

% Select 2y returns and aligned prices
[ ~, returnsSelected, pricesAligned] = returnsOfInterest(inputFile, refDate, ...
    timeWindow, sharesList, formatDate);
currentPrices = pricesAligned(end, :)';  % Vector of current prices
portfolioValue = sum(shares .* currentPrices); % Value of the ptf
weights = (shares .* currentPrices) / portfolioValue; % Portfolio weights

% Historical Simulation VaR & ES
[ES_HS, VaR_HS] = HSMeasures(alpha, weights, portfolioValue, ...
            riskMeasureTimeIntervalInDays, returnsSelected);
% Bootstrap
[ES_boot, VaR_boot] = BootstrapMeasures(alpha, weights, portfolioValue, ...
            riskMeasureTimeIntervalInDays, returnsSelected, M);
% Plausibility Check
VaR_PC_1 = PlausibilityCheckVaR(alpha, weights, portfolioValue, ...
            riskMeasureTimeIntervalInDays, returnsSelected);

%% Exercise 1.b
alpha = 0.99;                          % Confidence level for VaR and ES
lambda = 0.98;                         % Exponential decay parameter
riskMeasureTimeIntervalInDays = 1;     % 1-day time horizon
portfolioValue = 1;                    % Notional
sharesList = { 'Vivendi' ; 'AXA' ; 'ENEL' ; 'Volkswagen' ; 'Schneider' };% Portfolio composition
N = size(sharesList,1);              % Number of assets in the ptf
weights = ones(N,1) / N;               % Equally weighted portfolio

% Select returns and aligned prices
[ ~, returnsSelected, pricesAligned] = returnsOfInterest(inputFile, refDate, ...
    timeWindow, sharesList, formatDate);

%Weighted Historical Simulation VaR & ES
[ES_WHS, VaR_WHS] = WHSMeasures(alpha, lambda, weights,portfolioValue, ...
            riskMeasureTimeIntervalInDays, returnsSelected);
% Plausibility Check 
VaR_PC_2 = PlausibilityCheckVaR(alpha, weights, portfolioValue, ...
            riskMeasureTimeIntervalInDays, returnsSelected);
%% Exercise 1.c 
alpha = 0.99;                          % Confidence level for VaR and ES
riskMeasureTimeIntervalInDays = 10;    % 10‑day time horizon
portfolioValue = 15e6;                 % Notional
sharesList = {'AirLiquide' ; 'Allianz' ; 'InBev' ; 'Arcelor' ; 'ASML' ; ...
    'Generali' ; 'AXA' ; 'BBVA' ; 'Santander' ; 'BASF' ; 'Bayer' ; 'BMW' ; ...
    'BNP' ; 'Carrefour' ; 'StGobain' ; 'CRH' ; 'Daimler' ; 'Danone' ; 'DB' ;...
    'DT' ; 'EON' ; 'ENEL' ; 'ENI' ; 'Essilor' ; 'FT'}; % Portfolio composition
nAssets = size(sharesList,1);          % Number of assets in the ptf
weights = (1/nAssets) * ones(nAssets, 1); % Equally weighted portfolio
[~, returnsSelected, ~] = returnsOfInterest(inputFile, refDate, ...
    timeWindow, sharesList, formatDate); % Select 2y returns for the 25 stocks

% We compute PCA-based VaR/ES for k = 1,...,nAssets, the relative error vs 
% full Gaussian VaR and finds the minimum number of PCs for <5% and <1% error
[VaR_PCA, ES_PCA, relErrorVaR, k_5, k_1] = compute_PCA_and_errors( ...
         alpha, weights, portfolioValue, riskMeasureTimeIntervalInDays, ...
         returnsSelected);
% Plausibility Check
VaR_PC_3 = PlausibilityCheckVaR(alpha, weights, portfolioValue, ...
         riskMeasureTimeIntervalInDays, returnsSelected);

%% Exercise 2 
refDate =  datenum('15-Feb-2010');    % Current date
expiryDate = datenum('18-Apr-2010');  % Expiry of the option
sharesList = {'Generali'};            % Portfolio composition
volatility     = 0.223;               % yearly volatility
dividendYield  = 0.051;               % yearly dividend yield
strike = 28.5;                        % strike for the put 
stockNotional = 1164000;              % Stock notional
alpha = 0.99;                         % Confidence level  
riskMeasureTimeIntervalInDays = 1;    % 1‑day time horizon

% We compute the Full Monte‑Carlo VaR and the Delta‑Normal VaR 
[VaR_FMC, VaR_DN] = computeVaR_Exercise2(stockNotional, strike, expiryDate,...
    refDate, alpha, volatility, dividendYield, riskMeasureTimeIntervalInDays, ...
    timeWindow, sharesList, inputFile, formatDate);

%% Exercise 3 
valuationDate = datenum('15-Feb-2008');
volatility = 0.19;     % yearly volatility
notional = 45e6;       % notional
expiry_date = datenum(valuationDate + years(5)); % expiry of the Cliquet option 
[ ~, rate] = find_rate_from_bootstrap_curve(valuationDate,expiry_date); % zero rate
S0 = 1;                % current price of the stock

% We compute the correct price
priceCliquet = notional*FairPriceCliquet(S0, rate, volatility);

%% Exercise 4.a (mezzanine tranche)
expiry = datenum(valuationDate + years(3));  % end of the interest period
p   = 0.05;      %  default probability
rho = 0.40;      % asset correlation
R   = 0.20;      % recovery rate
LGD = 1 - R;     % loss given default
Kd = 0.05;       % attachment point
Ku = 0.09;       % detachment point
notional = 1e9;  % notional
I_max_exact = 400; % Maximum pool size for which the exact finite‑pool Vasicek price is computed
I_grid = round(logspace(1, log10(2e4), 30));% Grid of portfolio sizes I (log‑spaced)

% We computes the LHP, exact finite-pool and KL-approximation prices
[price_LHP, price_exact, price_KL] = compute_tranche_prices(I_grid, ...
               p, rho, LGD, Kd, Ku, valuationDate, expiry, I_max_exact, notional); 
% Plot of prices in % of tranche notional
plot_tranche_prices(I_grid, price_LHP, price_exact, price_KL, notional,...
               'Mezzanine [5%, 9%]', 'tranche_mezzanine.pdf');
%% Exercise 4.b (equity tranche)
Kd_eq = 0.00;    % attachment point
Ku_eq = 0.05;    % detachment point

% We computes the LHP, exact finite-pool and KL-approximation prices
[price_LHP_eq, price_exact_eq, price_KL_eq] = compute_tranche_prices( ...
    I_grid, p, rho, LGD, Kd_eq, Ku_eq,  valuationDate, expiry,I_max_exact, notional);
% Plot of prices in % of tranche notional
plot_tranche_prices(I_grid, price_LHP_eq, price_exact_eq, price_KL_eq,notional, ...
                    'Equity [0%, 5%]', 'tranche_equity.pdf');
