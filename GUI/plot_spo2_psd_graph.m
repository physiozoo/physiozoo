%%
function plot_spo2_psd_graph(ax, plot_data)

colors = lines;

hold(ax, 'on');

% Plot PSD
plot(ax, plot_data.x, plot_data.y, 'Color', colors(3,:), 'LineWidth', 1.5, 'Tag', 'psd');

grid(ax, 'on');
axis(ax, 'tight');

ylim(ax, [0 0.5]);

yrange = ylim(ax); % in case it was 'auto'
% Vertical lines of frequency ranges
lw = 3; ls = ':'; lc = 'black';
line(0.014  * ones(1,2), yrange, 'Parent', ax, 'LineStyle', ls, 'Color', lc, 'LineWidth', lw, 'Tag', 'freqband');
line(0.033  * ones(1,2), yrange, 'Parent', ax, 'LineStyle', ls, 'Color', lc, 'LineWidth', lw, 'Tag', 'freqband');

%% Labels
% X
xlabel(ax, 'Frequency (Hz)');
% Y
ylabel(ax, 'Amplitude (%^2/Hz)');