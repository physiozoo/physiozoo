%%
function setXECGGrid(axes_handle, grid_checkbox_handle)

x_lim = get(axes_handle, 'XLim');
y_lim = get(axes_handle, 'YLim');

if max(x_lim) - min(x_lim) > 60
    axes_handle.XTickMode = 'auto';
    axes_handle.YTickMode = 'auto';
%     axes_handle.XMinorGrid = 'on';
%     axes_handle.YMinorGrid = 'on';
    axes_handle.XTickLabelRotation = 0;
    set(axes_handle, 'XTickLabel', arrayfun(@(x) calcDuration(x, 0, 1), get(axes_handle, 'XTick'), 'UniformOutput', false));
    
    axes_handle.XGrid = 'off';
    axes_handle.YGrid = 'off';
    grid_checkbox_handle.Enable = 'off';
else
    grid_checkbox_handle.Enable = 'on';
    need_ms = 0;
    show_hours = 1;
    
%     axes_handle.XMinorGrid = 'on';
%     axes_handle.YMinorGrid = 'on';
    
    axes_handle.XTickLabelRotation = 0;
    axes_handle.XTickMode = 'manual';
    
    if max(x_lim) - min(x_lim) <= 2
        
        xTick_delta = 0.04;
        yTick_delta = 0.1;
        
        axes_handle.XTickLabelRotation = -45;
        need_ms = 1;
        show_hours = 0;
        
    elseif max(x_lim) - min(x_lim) > 2 && max(x_lim) - min(x_lim) <= 15
        xTick_delta = 1;   
        yTick_delta = 0.5;
    elseif max(x_lim) - min(x_lim) <= 60 && max(x_lim) - min(x_lim) > 15
        xTick_delta = 5;  
        yTick_delta = 0.5;
    end
    
    axes_handle.GridColor = [1 0 0];
    
    if grid_checkbox_handle.Value
        axes_handle.XGrid = 'on';
        axes_handle.YGrid = 'on';
    else
        axes_handle.XGrid = 'off';
        axes_handle.YGrid = 'off';
    end
    axes_handle.YTick = min(y_lim) : yTick_delta : max(y_lim); % milliVolt
    set(axes_handle, 'YTickLabel', arrayfun(@(x) sprintf('%.2f', x), axes_handle.YTick, 'UniformOutput', false));
    axes_handle.XTick = min(x_lim) : xTick_delta : max(x_lim);        
    set(axes_handle, 'XTickLabel', arrayfun(@(x) calcDuration(x, need_ms, show_hours), axes_handle.XTick, 'UniformOutput', false));
end