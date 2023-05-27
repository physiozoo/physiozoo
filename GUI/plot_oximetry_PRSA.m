%%
function plot_oximetry_PRSA(ax, PRSA_window)

% PRSA_window = calc_PRSA(signal, 10);

plot(linspace(1, 21, 21), PRSA_window, 'Parent', ax, 'LineWidth', 2);
% xlabel(ax, '$Time (sec)$', 'Interpreter', 'Latex');
% ylabel(ax, '$Oxygen $\space$ Saturation (\%)$', 'Interpreter', 'Latex');
% legend(ax, 'PRSA window', 'Interpreter', 'Latex');
% set(ax, 'TickLabelInterpreter', 'Latex');

xlabel(ax, 'Time (sec)');
ylabel(ax, 'Oxygen Saturation (%)');
legend(ax, 'PRSA window');


