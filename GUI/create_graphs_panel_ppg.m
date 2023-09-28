%%
function PPG_Axes = create_graphs_panel_ppg(parent_panel, Spacing, myUpBackgroundColor)

two_axes_box = uix.VBox('Parent', parent_panel, 'Spacing', Spacing);

PPG_Axes = axes('Parent', uicontainer('Parent', two_axes_box), 'Tag', 'GUI.PPG_Axes');
% RRInt_Axes = axes('Parent', uicontainer('Parent', two_axes_box), 'Tag', 'GUI.RRInt_Axes');

PPG_Axes.FontName = 'Times New Roman';
% RRInt_Axes.FontName = 'Times New Roman';

% set(two_axes_box, 'Heights', [-7, -3]);

set(parent_panel, 'BackgroundColor', myUpBackgroundColor);
set(two_axes_box, 'BackgroundColor', myUpBackgroundColor);

set(findobj(parent_panel, 'Type', 'uicontainer'), 'BackgroundColor', myUpBackgroundColor);