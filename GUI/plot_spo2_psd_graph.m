%%
function plot_spo2_psd_graph(ax, plot_data, yscale)

Frequency_Low = mhrv.defaults.mhrv_get_default('PeriodicityMeasures.Frequency_Low', 'value');
Frequency_High = mhrv.defaults.mhrv_get_default('PeriodicityMeasures.Frequency_High', 'value');

colors = lines;

hold(ax, 'on');

% Plot PSD
plot(ax, plot_data.x, plot_data.y, 'Color', colors(3,:), 'LineWidth', 1.5, 'Tag', 'psd');

% Set axes scales (linear/log)
set(ax, 'YScale', yscale);

grid(ax, 'on');
axis(ax, 'tight');

if strcmp(yscale, 'linear')
    ylim(ax, [0 0.5]);
else
    ylim(ax, 'auto');
end
yrange = ylim(ax); % in case it was 'auto'

% Vertical lines of frequency ranges
lw = 3; ls = ':'; lc = 'black';
line(Frequency_Low  * ones(1,2), yrange, 'Parent', ax, 'LineStyle', ls, 'Color', lc, 'LineWidth', lw, 'Tag', 'freqband');
line(Frequency_High  * ones(1,2), yrange, 'Parent', ax, 'LineStyle', ls, 'Color', lc, 'LineWidth', lw, 'Tag', 'freqband');

%% Legend
% legend(ax, 'Welch', 'Interpreter', 'Latex');
legend(ax, 'Welch');

%% Labels
% X
% xlabel(ax, '$Frequency (Hz)$', 'Interpreter', 'Latex');
xlabel(ax, 'Frequency (Hz)');
% Y
% ylabel(ax, '$Amplitude ( \frac {\%^2} {Hz})$', 'Interpreter', 'Latex');
ylabel(ax, 'Amplitude (%^2/Hz)');

% set(ax, 'TickLabelInterpreter', 'Latex');