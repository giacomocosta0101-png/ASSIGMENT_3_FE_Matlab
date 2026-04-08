function [ES, VaR] = HSMeasures(alpha, weights, portfolioValue, riskMeasureTimeIntervalInDays, returns)
% HSMEASURES
% Historical Simulation under frozen lineal portfolio
%
% INPUTS:
%   alpha          = confidence level
%   weights        = vector of portfolio weights
%   portfolioValue = scalar, current portfolio value
%   riskMeasureTimeIntervalInDays = time horizon in days (for time scaling)
%   returns        = matrix of daily returns
%
% OUTPUTS:
%   ES, VaR        = Expected Shortfall and Value-at-Risk 

    % We compute daily portfolio losses
    L = -portfolioValue* returns * weights;

    % We sort losses in descending order:
    % Ls(1) is the worst (largest) loss, Ls(T) is the smallest one
    Ls = sort(L, 'descend');
    T  = length(Ls);   % Number of observations

    % We determine the index corresponding to the (1 - alpha) tail probability.
    k  = floor((1 - alpha) * T);
    k  = max(k, 1);    % Check: ensure k is at least 1

    % Historical VaR is the k-th worst loss, the empirical (1 - alpha)-quantile.
    VaR = Ls(k);

    % Historical ES is the average of the worst k losses, the mean of the tail.
    ES  = mean(Ls(1:k));
    
    % Time scaling
    VaR = VaR * sqrt(riskMeasureTimeIntervalInDays);
    ES  = ES * sqrt(riskMeasureTimeIntervalInDays);
end
