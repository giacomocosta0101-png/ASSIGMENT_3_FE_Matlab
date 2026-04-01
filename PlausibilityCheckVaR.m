function VaR = PlausibilityCheckVaR(alpha, weights, portfolioValue, ...
                                    riskMeasureTimeIntervalInDays, returns)
% PlausibilityCheckVaR
% Implements the Plausibility Check: a quick order-of-magnitude estimate 
% of portfolio VaR.
%
% INPUTS:
%   alpha               = confidence level
%   weights             = vector of portfolio weights
%   portfolioValue      = scalar, current portfolio value
%   riskMeasureTimeIntervalInDays = time horizon in days (for scaling)
%   returns             = matrix of daily returns
%
% OUTPUT:
%   VaR                 = Plausibility Check VaR

    % We compute lower and upper quantiles for all factor
    l = quantile(returns, 1 - alpha);   % 1 × n
    u = quantile(returns, alpha);       % 1 × n

    % Convert to column vectors
    l = l(:);
    u = u(:);

    % We compute sensitivities: for a linear portfolio sens_i = w_i * V
    sens = weights * portfolioValue;

    % Signed VaR for each factor
    sVaR = sens .* (abs(l) + abs(u)) / 2;

    % Correlation matrix
    C = corr(returns);

    % Portfolio VaR (1-day)
    VaR_1d = sqrt( sVaR' * C * sVaR );

    % Time scaling
    VaR = VaR_1d * sqrt(riskMeasureTimeIntervalInDays);

end
