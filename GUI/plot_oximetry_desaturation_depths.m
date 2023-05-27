%%
function plot_oximetry_desaturation_depths(ax, desat_intervals_depth)

% desat_intervals_depth = [];
% for index = 1 : length(begin_desat)
% 	desat_intervals_depth(index) = max(signal(begin_desat(index): end_desat(index))) - min(signal(begin_desat(index): end_desat(index)));
% end

h1 = histogram(ax, desat_intervals_depth);
hold(ax, 'on');

l1 = line([min(desat_intervals_depth), min(desat_intervals_depth)], ylim(ax), 'LineWidth', 2, 'Color', 'r', 'Parent', ax, 'LineStyle', ':');
l2 = line([max(desat_intervals_depth), max(desat_intervals_depth)], ylim(ax), 'LineWidth', 2, 'Color', 'r', 'Parent', ax, 'LineStyle', ':');
l3 = line([median(desat_intervals_depth), median(desat_intervals_depth)], ylim(ax), 'LineWidth', 2, 'Color', '#EDB120', 'Parent', ax);
l4 = line([mean(desat_intervals_depth), mean(desat_intervals_depth)], ylim(ax), 'LineWidth', 2.5, 'Color', 'r', 'Parent', ax);

% legend(ax, [l1 l2 l3 l4], {'minimum', 'maximum', 'median', 'mean'}, 'Interpreter', 'Latex'); % 'desaturation depth'
% xlabel(ax, '$Desaturation $\space$ Depth ($\%$)$', 'Interpreter', 'Latex');
% ylabel(ax, '$Count$', 'Interpreter', 'Latex');
% set(ax, 'TickLabelInterpreter', 'Latex');

% , 'Location', 'best'

legend(ax, [l1 l2 l3 l4], {'minimum', 'maximum', 'median', 'mean'}); % 'desaturation depth'
xlabel(ax, 'Desaturation Depth (%)');
ylabel(ax, 'Count');
