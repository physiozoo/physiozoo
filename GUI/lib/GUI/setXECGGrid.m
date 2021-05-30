%%
function setXECGGrid(axes_handle, grid_checkbox_handle)

x_lim = get(axes_handle, 'XLim');

xTick_minor_delta = 0.04;

if max(x_lim) - min(x_lim) > 60
    axes_handle.XTickMode = 'auto';

    axes_handle.XTickLabelRotation = 0;
    set(axes_handle, 'XTickLabel', arrayfun(@(x) calcDuration(x, 0, 1), get(axes_handle, 'XTick'), 'UniformOutput', false));
    
    axes_handle.XGrid = 'off';
    axes_handle.XMinorGrid = 'off';
    grid_checkbox_handle.Enable = 'off';
else
    grid_checkbox_handle.Enable = 'on';
    need_ms = 0;
    show_hours = 1;
    
    axes_handle.XTickLabelRotation = 0;
    axes_handle.XTickMode = 'manual';
    
    if max(x_lim) - min(x_lim) <= 1 % 2
        
        xTick_delta = 0.04;
        
        axes_handle.XTickLabelRotation = -45;
        need_ms = 1;
        show_hours = 0;
        
    elseif max(x_lim) - min(x_lim) > 1 && max(x_lim) - min(x_lim) <= 10
        xTick_delta = 0.2; % 1   
        
        
        axes_handle.XTickLabelRotation = -70;
        need_ms = 1;
        show_hours = 0;
        
    elseif max(x_lim) - min(x_lim) <= 60 && max(x_lim) - min(x_lim) > 10
        xTick_delta = 5;  % 5
        xTick_minor_delta = 1;
    end
    
    axes_handle.GridColor = [1 0 0];
    axes_handle.MinorGridColor = [1 0 0];
    axes_handle.MinorGridLineStyle = ':';
    axes_handle.GridAlpha = 0.5;
    
%     axes_handle.DataAspectRatio % = [1 1 1];
% 
% daspect(axes_handle, [1 1 1]);    
% pbaspect(axes_handle, [1 1 1]);    
% axis(axes_handle, 'square');
    

% Control Axes Layout

    if grid_checkbox_handle.Value
        axes_handle.XGrid = 'on';
        axes_handle.XMinorGrid = 'on';
    else
        axes_handle.XGrid = 'off';
        axes_handle.XMinorGrid = 'off';
    end
    
    axes_handle.XAxis.MinorTickValues = min(x_lim) : xTick_minor_delta : max(x_lim);  % 0.04      
    
    axes_handle.XTick = min(x_lim) : xTick_delta : max(x_lim);           
    set(axes_handle, 'XTickLabel', arrayfun(@(x) calcDuration(x, need_ms, show_hours), axes_handle.XTick, 'UniformOutput', false));
end