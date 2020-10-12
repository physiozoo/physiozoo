%%
function plot_oximetry_desat_hist(ax, desat_intervals_length)

% desat_intervals_length = [];
% for index = 1 : length(begin_desat)
%     desat_intervals_length(index) = end_desat(index) - begin_desat(index);
% end

histogram(ax, desat_intervals_length);
hold(ax, 'on');

line([min(desat_intervals_length), min(desat_intervals_length)], ylim(ax), 'LineWidth', 2, 'Color', 'k', 'Parent', ax);
line([max(desat_intervals_length), max(desat_intervals_length)], ylim(ax), 'LineWidth', 2, 'Color', 'g', 'Parent', ax);
line([median(desat_intervals_length), median(desat_intervals_length)], ylim(ax), 'LineWidth', 2, 'Color', 'y', 'Parent', ax);
line([mean(desat_intervals_length), mean(desat_intervals_length)], ylim(ax), 'LineWidth', 2, 'Color', 'r', 'Parent', ax);

legend(ax, 'desaturation length', 'minimum', 'maximum', 'median', 'average');

xlabel(ax, 'Desaturation Length (sec)');
ylabel(ax, 'Count');
