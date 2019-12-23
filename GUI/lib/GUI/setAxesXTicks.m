%%
function setAxesXTicks(axes_handle)
x_ticks_array = get(axes_handle, 'XTick');
if max(x_ticks_array) - min(x_ticks_array) <= 2
    set(axes_handle, 'XTickLabel', arrayfun(@(x) calcDuration(x, 1, 0), x_ticks_array, 'UniformOutput', false));
else
    set(axes_handle, 'XTickLabel', arrayfun(@(x) calcDuration(x, 0, 1), x_ticks_array, 'UniformOutput', false));
end