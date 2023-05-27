%%
function ECG_Axes_Handles = create_grid_panel(parent_panel, Spacing, Padding, myUpBackgroundColor, ch_num)

% grid_panel = uix.GridFlex('Parent', parent_panel, 'Padding', Padding, 'Spacing', Spacing);
grid_panel = uix.GridFlex('Parent', parent_panel, 'Padding', 0, 'Spacing', Spacing);

ECG_Axes_Handles = gobjects(1, ch_num);

for i = 1 : ch_num
    tempPanel = uix.Panel('Parent', grid_panel, 'BorderType', 'none', 'Padding', Padding, 'Tag', ['ch_panel_' num2str(ch_num)]);
    
    axes_name = ['ch_axes_' num2str(ch_num)];    
%     ECG_Axes_Handles(i) = axes(uicontainer('Parent', tempPanel), 'ActivePositionProperty', 'Position', 'Tag', axes_name);
    ECG_Axes_Handles(i) = axes('Parent', tempPanel, 'ActivePositionProperty', 'Position', 'Tag', axes_name);
    ECG_Axes_Handles(i).FontName = 'Times New Roman';
                               
%     ECG_Axes_Handles(i).XTick = [];
%     ECG_Axes_Handles(i).YTick = [];  
%     ECG_Axes_Handles(i).XTickLabel = [];
%     ECG_Axes_Handles(i).YTickLabel = []; 
    ECG_Axes_Handles(i).XAxis.Visible = 'off';
    ECG_Axes_Handles(i).YAxis.Visible = 'off';
end

[tb1, btns1] = axtoolbar(ECG_Axes_Handles(1),{'pan', 'zoomin','zoomout','restoreview'});

set(grid_panel, 'Widths', [-2 -2], 'Heights', [-6 -6 -6 -6 -6 -6]);

set(parent_panel, 'BackgroundColor', myUpBackgroundColor);
set(grid_panel, 'BackgroundColor', myUpBackgroundColor);

set(findobj(parent_panel, 'Type', 'uicontainer'), 'BackgroundColor', myUpBackgroundColor);
set(findobj(parent_panel, 'Type', 'uipanel'), 'BackgroundColor', myUpBackgroundColor);