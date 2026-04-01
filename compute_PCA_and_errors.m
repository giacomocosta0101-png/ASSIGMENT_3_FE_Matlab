function [VaR_PCA, ES_PCA, relErrorVaR, k_5, k_1] = ...
    compute_PCA_and_errors(alpha, weights, portfolioValue, ...
                       riskMeasureTimeIntervalInDays, returnsSelected)
% COMPUTE_PCA_AND_ERRORS  
%
%   Computes PCA-based VaR/ES for k = 1,...,nAssets and the relative 
%   error vs full Gaussian VaR and finds the minimum number of PCs 
%   needed for <5% and <1% error
%
%   INPUTS:
%       alpha                   = confidence level
%       weights                 = portfolio weights (column vector)
%       portfolioValue          = scalar, current portfolio value
%       riskMeasureTimeIntervalInDays = time horizon in days
%       returnsSelected         = matrix of returns
%
%   OUTPUTS:
%       VaR_PCA             = nAssets×1 vector of VaR(k)
%       ES_PCA              = nAssets×1 vector of ES(k)
%       relErrorVaR         = nAssets×1 relative error vs VaR_full
%       k_5                 = smallest k with error <5%
%       k_1                 = smallest k with error <1%

    nAssets = size(returnsSelected, 2);
    k_vec   = (1:nAssets)';   % column vector of all k

    % We compute VaR by using full Gaussian approach
    [~, VaR_full] = AnalyticNormalMeasures(alpha, weights, portfolioValue, ...
            riskMeasureTimeIntervalInDays, returnsSelected);

    % we use PCAMeasures for computing VaR and ES for different k
    [ES_PCA, VaR_PCA] = arrayfun(@(k) PCAMeasures(alpha, k, weights, ...
        portfolioValue, riskMeasureTimeIntervalInDays, returnsSelected), ...
        k_vec);

    % Relative error vs full Gaussian VaR
    relErrorVaR = abs(VaR_PCA - VaR_full) / VaR_full;

    % Minimum k for <5% and <1% errors
    k_5 = find(relErrorVaR < 0.05, 1);
    k_1 = find(relErrorVaR < 0.01, 1);

end
