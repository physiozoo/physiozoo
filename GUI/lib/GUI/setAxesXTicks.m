function setAxesXTicks(axes_handle)
x_ticks_array = get(axes_handle, 'XTick');
set(axes_handle, 'XTickLabel', arrayfun(@(x) calcDuration(x, 0), x_ticks_array, 'UniformOutput', false));