function [ES, VaR] = WHSMeasures(alpha, lambda, weights, portfolioValue, ...
    riskMeasureTimeIntervalInDays, returns)
% WHSMEASURES
% Weighted Historical Simulation (WHS) with exponential decay
%
% INPUTS:
%   alpha                   = confidence level
%   lambda                  = decay parameter
%   weights                 = vector of portfolio weights
%   portfolioValue          = scalar, current portfolio value
%   riskMeasureTimeIntervalInDays = time horizon in days (for time scaling)
%   returns                 = matrix of daily returns
%
% OUTPUTS:
%   ES, VaR                 = Weighted Historical Simulation Expected Shortfall and VaR

% We compute daily portfolio losses
L = -returns * weights * portfolioValue;

T = length(L);

% We build exponential decay weights 
C = (1 - lambda) / (1 - lambda^T);
w = C * lambda.^((T-1):-1:0)'; 



% Normalize weights so that sum(w) = 1
%w = w / sum(w); c'è già C che fa questa cosa



% Sort losses from worst to best
[Ls, idx] = sort(L, 'descend');

% Reorder weights according to the sorted losses
ws = w(idx);

% Compute cumulative weights
cumw = cumsum(ws);

% Find the VaR quantile: VaR is the largest loss such that cumulative 
% weight ≥ (1 - alpha)
k = find(cumw <= (1 - alpha), 1,'last');
VaR = Ls(k);

% Compute Weighted ES
% ES is the weighted average of all losses worse than VaR.
ES = sum(Ls(1:k) .* ws(1:k)) / sum(ws(1:k));

% Time scaling
VaR = VaR * sqrt(riskMeasureTimeIntervalInDays);
ES  = ES* sqrt(riskMeasureTimeIntervalInDays);

end
