%%
function [] = plot_oximetry_dfa(ax, plot_data)
%PLOT_DFA_FN Plots the DFA F(n) function.
%   ax: axes handle to plot to.
%   plot_data: struct returned from dfa.
%

n = plot_data.n;
fn = plot_data.fn;

%% Plot

h1 = loglog(n, fn, 'ko', 'Parent', ax, 'MarkerSize', 7);
hold(ax, 'on');
grid(ax, 'on');
axis(ax, 'tight');

% xlabel(ax, '$log_2(n)$', 'Interpreter', 'Latex');
% ylabel(ax, '$DFA(n)$', 'Interpreter', 'Latex');
% set(ax, 'XTick', 2.^(1:15)); % Set ticks at powers of two
% legend(ax, 'DFA', 'Location', 'northwest', 'Interpreter', 'Latex');
% uistack(h1, 'top');
% set(ax, 'TickLabelInterpreter', 'Latex');

xlabel(ax, 'log_2(n)');
ylabel(ax, 'DFA(n)');
set(ax, 'XTick', 2.^(1:15)); % Set ticks at powers of two
legend(ax, 'DFA', 'Location', 'northwest');
uistack(h1, 'top');
