%%
function plot_oximetry_desat_hist(ax, desat_intervals_length)

% desat_intervals_length = [];
% for index = 1 : length(begin_desat)
%     desat_intervals_length(index) = end_desat(index) - begin_desat(index);
% end

h1 = histogram(ax, desat_intervals_length);
hold(ax, 'on');

l1 = line([min(desat_intervals_length), min(desat_intervals_length)], ylim(ax), 'LineWidth', 2, 'Color', 'r', 'Parent', ax, 'LineStyle', ':');
l2 = line([max(desat_intervals_length), max(desat_intervals_length)], ylim(ax), 'LineWidth', 2, 'Color', 'r', 'Parent', ax, 'LineStyle', ':');
l3 = line([median(desat_intervals_length), median(desat_intervals_length)], ylim(ax), 'LineWidth', 2, 'Color', '#EDB120', 'Parent', ax);
l4 = line([mean(desat_intervals_length), mean(desat_intervals_length)], ylim(ax), 'LineWidth', 2.5, 'Color', 'r', 'Parent', ax);

% legend(ax, [l1 l2 l3 l4], {'minimum', 'maximum', 'median', 'average'}, 'Interpreter', 'Latex'); % 'desaturation length', 
legend(ax, [l1 l2 l3 l4], {'minimum', 'maximum', 'median', 'average'}); % 'desaturation length', 

% xlabel(ax, '$Desaturation $\space$ Length (sec)$', 'Interpreter', 'Latex');
% ylabel(ax, '$Count$', 'Interpreter', 'Latex');
% set(ax, 'TickLabelInterpreter', 'Latex');
% , 'Location', 'best'

xlabel(ax, 'Desaturation Length (sec)');
ylabel(ax, 'Count');