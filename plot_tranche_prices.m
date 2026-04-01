function plot_tranche_prices(I_grid, price_LHP, price_exact, price_KL, ...
                             notional,tranche_name, filename)
% PLOT_TRANCHE_PRICES 
%   Plots the three tranche pricing curves (LHP, Exact, KL) on the same
%   axes using semilogarithmic x-scale and saves the figure as a PDF.
%
%   INPUTS:
%       I_grid       – vector of pool sizes (logspace grid)
%       price_LHP    – Nx1 vector of LHP prices
%       price_exact  – Nx1 vector of exact finite-pool prices (NaN where unavailable)
%       price_KL     – Nx1 vector of KL approximation prices
%       notional     – notional
%       tranche_name – string, e.g. 'Mezzanine [5%, 9%]' or 'Equity [0%, 5%]'
%       filename     – output PDF path
%
%   OUTPUT:
%       (none – figure saved to PDF)

fig = figure('Visible', 'off');
hold on; grid on;

% Plot LHP (black dashed)
semilogx(I_grid, 100*price_LHP/notional, 'k--', 'LineWidth', 1.6);

% Plot Exact only where available (blue circles)
idx_exact = ~isnan(price_exact);
semilogx(I_grid(idx_exact), 100*price_exact(idx_exact)/notional, 'bo-', ...
    'LineWidth', 1.3, 'MarkerSize', 5);

% Plot KL (red dash-dot)
semilogx(I_grid, 100*price_KL/notional, 'r-.', 'LineWidth', 1.6);
set(gca, 'XScale', 'log');
xlabel('Number of loans I (log scale)');
ylabel('Tranche price (% of tranche notional)');
title(['Vasicek – ', tranche_name]);

legend('LHP limit', 'Exact (finite I)', 'KL approximation', ...
       'Location', 'best');

set(gca, 'FontSize', 12);

% Save as vector PDF
exportgraphics(fig, filename, 'ContentType', 'vector');
close(fig);

fprintf('Plot saved to: %s\n', filename);

end
