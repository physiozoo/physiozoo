%%
function plot_oximetry_CA(ax, signal)

values_x = [70, 75, 80, 85, 90, 95, 100];

result = zeros(1, length(values_x));
for index = 1 : length(values_x)
    result(index) = calc_CA(signal, values_x(index));
end

plot(values_x, result, 'Parent', ax, 'LineWidth', 2);
xlabel(ax, 'Baseline (%)'); ylabel(ax, 'CA (sec*%)');

