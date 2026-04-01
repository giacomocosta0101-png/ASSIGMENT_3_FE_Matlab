function val = innerSumFinite(I, py, trancheLoss)
% INNERSUMFINITE
% 
% Computes the inner sum:
%
%       Σ_{m=0}^I P(m|y) * l(m/I)
%
% for a fixed value of y (thus fixed py = p(y)).
%
% INPUTS:
%   I           : number of obligors
%   py          : conditional default probability p(y)
%   trancheLoss : function handle l(z)
%
% OUTPUT:
%   val : value of the sum Σ_m P(m|y) * l(m/I)
%

    % Vector of possible default counts
    m = (0:I)';              % column vector

    % Fraction of defaults
    z = m / I;

    % Tranche loss evaluated on all z at once
    l = trancheLoss(z);

    % Binomial probabilities P(m|y) for all m
    % (numerically stable version, equivalent to nchoosek(I,m)*py^m*(1-py)^(I-m))
    Pm = binopdf(m, I, py);
    %Why not:
    %Pm = arrayfun(nchoosek(I,m)*py^m*(1-py)*(I-m),m);

    % Expected value
    val = sum(Pm .* l);
end
