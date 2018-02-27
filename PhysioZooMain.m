function PhysioZooMain()

GUI.MainWindow = figure( ...
    'Name', 'Physio Zoo', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'HandleVisibility', 'off', ...
    'Position', [700, 300, 302, 267]);

GUI.mainLayout = uix.VBox('Parent', GUI.MainWindow, 'Spacing', 3);
GUI.ImageAxes = axes('Parent', GUI.mainLayout, 'ActivePositionProperty', 'Position');

logoImage = imread('D:\physiozoo-toolbox\Logo\logo_v1BIG.png');
imagesc(logoImage, 'Parent', GUI.ImageAxes, 'AlphaData', 0.2);
set(GUI.ImageAxes, 'xticklabel', [], 'yticklabel', [], 'handlevisibility', 'off', 'visible', 'off' );

GUI.PeakDetection_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', GUI.MainWindow, 'Callback', @PeakDetection_pushbutton_Callback, 'FontSize', 14, 'String', 'Peak Detection');


% b = uix.HButtonBox( 'Parent', f );



end