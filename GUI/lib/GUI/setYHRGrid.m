%%
function setYHRGrid(axes_handle, grid_checkbox_handle)

y_lim = get(axes_handle, 'YLim');
axes_handle.GridColor = [1 0 0];

if grid_checkbox_handle.Value
    axes_handle.YGrid = 'on';
%     axes_handle.YMinorGrid = 'on';
else
    axes_handle.YGrid = 'off';
%     axes_handle.YMinorGrid = 'off';
end
% yTick_delta = 50;
% axes_handle.YTick = min(y_lim) : yTick_delta : max(y_lim); % milliVolt