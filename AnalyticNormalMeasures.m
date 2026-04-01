function [ES, VaR] = AnalyticNormalMeasures(alpha, weights, portfolioValue, ...
    riskMeasureTimeIntervalInDays, returns)
% ANALYTICNORMALMEASURES
% Computes Gaussian VaR and ES for a linear portfolio:
%   L = - wᵀ X   with X ~ N(μ, Σ)
%
% INPUTS:
%   alpha                       = confidence level
%   weights                     = vector of portfolio weights
%   portfolioValue              = scalar, current portfolio value
%   riskMeasureTimeIntervalInDays = time horizon in days (for time scaling)
%   returns                     = matrix of daily returns
%
% OUTPUT:
%   ES, VaR                     = Expected Shortfall and Value-at-Risk
    
    % We compute the portfolio daily returns
    portfolioReturns = returns * weights;  

    % We define the daily losses as L_t = -portfolioReturns
    dailyLosses = -portfolioReturns;

    % We compute daily mean and std of the loss gaussian distribution
    muL_daily    = mean(dailyLosses);
    sigmaL_daily = std(dailyLosses);

    % We scale mean and std to the chosen time horizon (in days)
    muL_h    = muL_daily    * riskMeasureTimeIntervalInDays;
    sigmaL_h = sigmaL_daily * sqrt(riskMeasureTimeIntervalInDays);

    % Normal quantile for the confidence level alpha
    z = norminv(alpha);

    % Gaussian VaR and ES for the loss distribution
    VaR = portfolioValue * ( muL_h + sigmaL_h * z );
    ES  = portfolioValue * ( muL_h + sigmaL_h * normpdf(z) / (1 - alpha) );

end

