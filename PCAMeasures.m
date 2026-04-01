function [ES, VaR] = PCAMeasures(alpha, numberOfPrincipalComponents, weights, ...
    portfolioValue, riskMeasureTimeIntervalInDays, returns)
% PCAMEASURES
% PCA‑based Gaussian VaR and ES using only the first npc principal components.
%
% INPUTS:
%   alpha                       = confidence level 
%   numberOfPrincipalComponents = number of retained PCs
%   weights                     = vector of portfolio weights
%   portfolioValue              = scalar, current portfolio value
%   riskMeasureTimeIntervalInDays = time horizon in days 
%   returns                     = matrix of asset returns
%
% OUTPUTS:
%   ES, VaR                     = PCA‑Gaussian Expected Shortfall and Value‑at‑Risk
%

%% 1. Covariance matrix of returns
Sigma = cov(returns);

%% 2. Eigen‑decomposition of Σ (Σ v_i = λ_i v_i)
[V, D] = eig(Sigma);

% Extract eigenvalues λ_i and sort them in descending order
[eigenvalues, idx] = sort(diag(D), 'descend');

% Reorder eigenvectors accordingly
V = V(:, idx);

%% 3. Reduced covariance matrix using the first npc components
V_r      = V(:, 1:numberOfPrincipalComponents);          % retained eigenvectors
Lambda_r = diag(eigenvalues(1:numberOfPrincipalComponents)); % retained eigenvalues
weights_PC = V_r' * weights;


%% 4. Portfolio standard deviation under PCA approximation (returns scale)
sigma_r = sqrt(weights_PC' * Lambda_r * weights_PC);

%% 5. Portfolio mean return and conversion to loss
mu_cap = V_r'*(mean(returns))';
mu_r = mu_cap'* weights_PC;     % mean portfolio return
mu   = - portfolioValue * mu_r;     % mean portfolio loss
sigma = portfolioValue * sigma_r;   % std of portfolio loss

%% 6. Time scaling
mu    = mu    * riskMeasureTimeIntervalInDays;
sigma = sigma * sqrt(riskMeasureTimeIntervalInDays);

%% 7. Gaussian VaR and ES
% Normal quantile for the confidence level alpha
z = norminv(alpha);

VaR = mu + sigma * z;
ES  = mu + sigma * normpdf(z) / (1 - alpha);

end

