%%
function plot_oximetry_PRSA(ax, PRSA_window)

% PRSA_window = calc_PRSA(signal, 10);

plot(linspace(1, 21, 21), PRSA_window, 'Parent', ax);
xlabel(ax, 'Time (sec)'); ylabel(ax, 'Oxygen Saturation (%)');
legend(ax, 'PRSA window');


