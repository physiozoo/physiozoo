%%
function plot_oximetry_time_hist(ax, signal)

h1 = histogram(ax, signal);
hold(ax, 'on');

l1 = line([min(signal), min(signal)], ylim(ax), 'LineWidth', 2, 'Color', 'r', 'Parent', ax, 'LineStyle', ':');
l2 = line([max(signal), max(signal)], ylim(ax), 'LineWidth', 2, 'Color', 'r', 'Parent', ax, 'LineStyle', ':');
l3 = line([median(signal), median(signal)], ylim(ax), 'LineWidth', 2, 'Color', '#EDB120', 'Parent', ax); % 
l4 = line([mean(signal), mean(signal)], ylim(ax), 'LineWidth', 2.5, 'Color', 'r', 'Parent', ax);

% legend(ax, [l1 l2 l3 l4], {'minimum', 'maximum', 'median', 'average'}, 'Interpreter', 'Latex'); % 'spo2 values', 
% xlabel(ax, '$SpO_2(\%)$', 'Interpreter', 'Latex');
% ylabel(ax, '$Count$', 'Interpreter', 'Latex');
% set(ax, 'TickLabelInterpreter', 'Latex');
% , 'Location', 'best'

legend(ax, [l1 l2 l3 l4], {'minimum', 'maximum', 'median', 'average'}); % 'spo2 values', 
xlabel(ax, sprintf('SpO\x2082(%%)')); 
ylabel(ax, 'Count');
