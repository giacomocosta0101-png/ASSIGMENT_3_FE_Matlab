function [ES, VaR] = BootstrapMeasures(alpha, weights, portfolioValue, ...
                                       riskMeasureTimeIntervalInDays, returns, M)
% BootstrapMeasures
% Computes VaR and ES using the non-parametric Bootstrap method for a
% linear frozen portfolio
%
% Bootstrap method:
%   - Resample historical losses with replacement
%   - Each bootstrap sample has length n (same as historical sample)
%   - Repeat M times
%   - VaR_boot = average of VaR across bootstrap samples
%   - ES_boot  = average of ES across bootstrap samples
%
%
% INPUTS:
%   alpha                   = confidence level 
%   weights                 = vector of portfolio weights
%   portfolioValue          = scalar, current portfolio value
%   riskMeasureTimeIntervalInDays = time horizon in days (for scaling)
%   returns                 = matrix of daily returns
%   M                       = number of bootstrap simulations
%
% OUTPUTS:
%   ES, VaR                 = Bootstrap Expected Shortfall and VaR 

    
    % Number of historical observations
    n = size(returns, 1);

    % Daily portfolio losses
    L_series = -portfolioValue * (returns * weights);  
    
    % Set seed for reproducibility
    rng(5)

    % Generate n*M bootstrap losses (sampling with replacement)
    boot = randsample(L_series, n * M, true);

    % Reshape into n × M matrix: each column is a bootstrap scenario
    boot = reshape(boot, n, M);

    % Sort each bootstrap scenario in descending order (worst losses first)
    boot_sorted = sort(boot, 'descend');

    % Index for the (1 - alpha) quantile
    k = floor((1 - alpha) * n);
    k = max(k, 1);

    % Bootstrap VaR = average VaR across bootstrap samples
    VaR = mean( boot_sorted(k, :) );

    % Bootstrap ES = average ES across bootstrap samples
    ES  = mean( mean( boot_sorted(1:k, :) ) );

    % Time scaling
    VaR = VaR * sqrt(riskMeasureTimeIntervalInDays);
    ES  = ES  * sqrt(riskMeasureTimeIntervalInDays);

end
