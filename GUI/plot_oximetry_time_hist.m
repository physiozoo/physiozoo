%%
function plot_oximetry_time_hist(ax, signal)

histogram(ax, signal);
hold(ax, 'on');

line([min(signal), min(signal)], ylim(ax), 'LineWidth', 2, 'Color', 'k', 'Parent', ax);
line([max(signal), max(signal)], ylim(ax), 'LineWidth', 2, 'Color', 'g', 'Parent', ax);
line([median(signal), median(signal)], ylim(ax), 'LineWidth', 2, 'Color', 'y', 'Parent', ax);
line([mean(signal), mean(signal)], ylim(ax), 'LineWidth', 2, 'Color', 'r', 'Parent', ax);

xlabel(ax, 'SpO2 (%)'); ylabel(ax, 'Count');

legend(ax, 'spo2 values', 'minimum', 'maximum', 'median', 'average');
