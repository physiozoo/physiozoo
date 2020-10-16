%%
function plot_oximetry_desaturation_depths(ax, desat_intervals_depth)

% desat_intervals_depth = [];
% for index = 1 : length(begin_desat)
% 	desat_intervals_depth(index) = max(signal(begin_desat(index): end_desat(index))) - min(signal(begin_desat(index): end_desat(index)));
% end

histogram(ax, desat_intervals_depth);
hold(ax, 'on');

line([min(desat_intervals_depth), min(desat_intervals_depth)], ylim(ax), 'LineWidth', 2, 'Color', 'r', 'Parent', ax, 'LineStyle', ':');
line([max(desat_intervals_depth), max(desat_intervals_depth)], ylim(ax), 'LineWidth', 2, 'Color', 'r', 'Parent', ax, 'LineStyle', ':');
line([median(desat_intervals_depth), median(desat_intervals_depth)], ylim(ax), 'LineWidth', 2, 'Color', '#EDB120', 'Parent', ax);
line([mean(desat_intervals_depth), mean(desat_intervals_depth)], ylim(ax), 'LineWidth', 2.5, 'Color', 'r', 'Parent', ax);

legend(ax, 'desaturation depth', 'minimum', 'maximum', 'median', 'mean');

xlabel(ax, 'Desaturation Depth (%)');
ylabel(ax, 'Count');
