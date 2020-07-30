%%
function setYECGGrid(axes_handle, grid_checkbox_handle)

y_lim = get(axes_handle, 'YLim');

if max(y_lim) - min(y_lim) > 5
    axes_handle.YTickMode = 'auto';
    axes_handle.YTickLabelMode = 'auto';
%     axes_handle.YLimMode = 'auto';
    
    axes_handle.YGrid = 'off';
    grid_checkbox_handle.Enable = 'off';
else
    grid_checkbox_handle.Enable = 'on';   
    
    axes_handle.YTickMode = 'manual';
    
    if max(y_lim) - min(y_lim) <= 0.5
        
        yTick_delta = 0.1;                
        
    elseif max(y_lim) - min(y_lim) > 0.5 && max(y_lim) - min(y_lim) <= 3
        yTick_delta = 0.5;
    elseif max(y_lim) - min(y_lim) <= 5 && max(y_lim) - min(y_lim) > 3
        yTick_delta = 1;
    end
    
    axes_handle.GridColor = [1 0 0];
    
    if grid_checkbox_handle.Value
        axes_handle.YGrid = 'on';
    else
        axes_handle.YGrid = 'off';
    end
    axes_handle.YTick = min(y_lim) : yTick_delta : max(y_lim); % milliVolt
    set(axes_handle, 'YTickLabel', arrayfun(@(x) sprintf('%.2f', x), axes_handle.YTick, 'UniformOutput', false));
end