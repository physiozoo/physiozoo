function PhysioZooGUI_HRVAnalisis(fileNameFromM1)

% Add third-party dependencies to path
gui_basepath = fileparts(mfilename('fullpath'));
% addpath(genpath([gui_basepath filesep 'lib']));
% addpath(genpath([gui_basepath filesep 'Loader']));
% addpath(genpath([gui_basepath filesep 'myWFDB']));
% addpath(genpath([gui_basepath filesep 'mhrv']));
basepath = fileparts(gui_basepath);

if isdeployed
    mhrv_init;
    
    disp(['ctfroot: ', ctfroot]);
    disp(['pwd: ', pwd]);
    disp(['userpath: ', userpath]);
end

%myBackgroundColor = [0.9 1 1];
myUpBackgroundColor = [0.863 0.941 0.906];
myLowBackgroundColor = [1 1 1];
myEditTextColor = [1 1 1];
mySliderColor = [0.8 0.9 0.9];
myPushButtonColor = [0.26 0.37 0.41];
% myPanelColor = [0.58 0.69 0.73];

persistent DIRS;
persistent DATA_Fig;
persistent DATA_Measure;
persistent defaultRate;

%mhrv_init();
%% Load default toolbox parameters
%mhrv_load_defaults --clear;

%%
DATA = createData();
clearData();
GUI = createInterface();

if nargin >= 1
    onOpenFile([], [], fileNameFromM1);
end

displayEndOfDemoMessage('');

%%-------------------------------------------------------------------------%
    function DATA = createData()
        
        DATA.screensize = get( 0, 'ScreenSize' );
        %         get(0 , 'ScreenPixelsPerInch')
        %         get(0, 'MonitorPositions')
        
        DATA.PlotHR = 0;
        
        DATA.rec_name = [];
        
        DATA.mammal = [];
        
        DATA.file_types = {'mat'; 'txt'; 'qrs'};
        DATA.file_types_index = 1;
        
        DATA.mammals = {'human (task force)', 'human', 'dog', 'rabbit', 'mouse', 'custom'};
        DATA.GUI_mammals = {'Human (Task Force)'; 'Human'; 'Dog'; 'Rabbit'; 'Mouse'; 'Custom'};
        DATA.mammal_index = 1;
        
        DATA.GUI_Integration = {'ECG'; 'Electrogram'; 'Action Potential'};
        DATA.Integration = 'ECG';
        DATA.integration_index = 1;
        
        DATA.Filters = {'Moving average', 'Range', 'Quotient', 'Combined filters', 'No filtering'};
        DATA.filter_index = 1;
        
        DATA.default_filter_level_index = 1;
        DATA.FilterLevel = {'Default', 'Weak', 'Moderate', 'Strong', 'Custom'};
        DATA.FilterShortLevel = {'Default', 'Custom'};
        DATA.FilterNoLevel = {'No filtering'};
        DATA.filter_level_index = DATA.default_filter_level_index;
        DATA.filters_level_value = [60 20 10];
        
        DATA.filter_quotient = false;
        DATA.filter_ma = true;
        DATA.filter_range = false;
        
        %         DEBUGGING MODE - Small Screen
        %         DATA.screensize = [0 0 1250 800];
        
        DATA.window_size = [DATA.screensize(3)*0.99 DATA.screensize(4)*0.85];
        
        if DATA.screensize(3) < 1920 %1080
            DATA.BigFontSize = 10;
            DATA.SmallFontSize = 10;
            DATA.SmallScreen = 1;
        else
            DATA.BigFontSize = 11;
            DATA.SmallFontSize = 11;
            DATA.SmallScreen = 0;
        end
        
        %DATA.MyGreen = [39 232 51]/256;
        DATA.MyGreen = [139 252 27]/256;
        
        DATA.Spacing = 3;
        DATA.Padding = 0;
        
        %DATA.frequency_methods = {'Lomb'; 'Welch'; 'AR'};
        DATA.frequency_methods = {'Welch'; 'AR'};
        DATA.default_frequency_method_index = 1;
        
        DATA.FiguresFormats = {'all', 'fig', 'bmp', 'eps', 'emf', 'jpg', 'pcx', 'pbm', 'pdf', 'pgm', 'png', 'ppm', 'svg', 'tif', 'tiff'};
        
        rec_colors = lines(6);
        DATA.rectangle_color = rec_colors(6, :);
        
        %         DATA.quality_color = {rec_colors(5, :); rec_colors(3, :); rec_colors(2, :)};
        DATA.quality_color = {[140 228 140]/255; [255 220 169]/255; [255 200 200]/255};
        DATA.GUI_Class = {'A'; 'B'; 'C'};
        
        DATA.freq_yscale = 'linear';
        DATA.doCalc = false;
    end % createData
%-------------------------------------------------------------------------%
%%
    function clearData()
        % All signal (Intervals)
        DATA.trr = [];
        DATA.rri = [];
        
        % All Filtered Signal (Intervals)
        DATA.tnn = [];
        DATA.nni = [];
        
        DATA.firstSecond2Show = 0;
        DATA.MyWindowSize = [];
        DATA.maxSignalLength = [];
        DATA.RRIntPage_Length = [];
        
        DATA.YLimUpperAxes.MaxYLimit = 0;
        DATA.YLimUpperAxes.HRMinYLimit = 0;
        DATA.YLimUpperAxes.HRMaxYLimit = [];
        DATA.YLimUpperAxes.RRMinYLimit = 0;
        DATA.YLimUpperAxes.RRMaxYLimit = [];
        
        DATA.YLimLowAxes.MaxYLimit = 0;
        DATA.YLimLowAxes.HRMinYLimit = 0;
        DATA.YLimLowAxes.HRMaxYLimit = [];
        DATA.YLimLowAxes.RRMinYLimit = 0;
        DATA.YLimLowAxes.RRMaxYLimit = [];
        
        DATA.Filt_MyDefaultWindowSize = 300; % sec
        DATA.Filt_MaxSignalLength = [];
        
        DATA.SamplingFrequency = [];
        
        DATA.QualityAnnotations_Data = [];
        
        DATA.FL_win_indexes = [];
        DATA.filt_FL_win_indexes = [];
        DATA.DataFileName = '';
        
        DATA.TimeStat.PlotData = [];
        DATA.FrStat.PlotData = [];
        DATA.NonLinStat.PlotData = [];
        
        DATA.timeData = [];
        DATA.timeRowsNames = [];
        DATA.timeDescriptions = [];
        
        DATA.fd_arData = [];
        DATA.fd_ArRowsNames = [];
        
        DATA.fd_welchData = [];
        DATA.fd_WelchRowsNames = [];
        
        DATA.nonlinData = [];
        DATA.nonlinRowsNames = [];
        DATA.nonlinDescriptions = [];
        
        GUI.TimeParametersTableRowName = [];
        GUI.FrequencyParametersTableMethodRowName = [];
        GUI.NonLinearTableRowName = [];
        
        DATA.flag = '';
        
        DATA.freq_yscale = 'linear';
        
        DATA.active_window = 1;
        DATA.AutoYLimitUpperAxes = [];
        DATA.AutoYLimitLowAxes = [];
        
        DATA.Group.Path.AllDirs = [];  %Eugene 04.05.18
        DATA.Group.Path.AllExts = [];
        
        DATA.GroupsCalc = 0;
        
        DATA.custom_filters_thresholds = [];
        
        DATA.Action = 'move';
        
        DATA.quality_class_ind = [];
        %         DATA.custom_config_params = containers.Map;
    end
%%
    function clean_gui()
        
        set(GUI.SaveMeasures, 'Enable', 'off');
        
        set(GUI.DataQualityMenu,'Enable', 'off');
        set(GUI.SaveFiguresAsMenu,'Enable', 'off');
        set(GUI.SaveParamFileMenu,'Enable', 'off');
        set(GUI.LoadConfigFile, 'Enable', 'off');
        
        GUI.Filt_RawDataSlider.Enable = 'off';
        
        set(GUI.MinYLimitUpperAxes_Edit, 'String', '');
        set(GUI.MaxYLimitUpperAxes_Edit, 'String', '');
        set(GUI.WindowSize, 'String', '');
        set(GUI.FirstSecond, 'String', '');
        set(GUI.Active_Window_Length, 'String', '');
        set(GUI.Active_Window_Start, 'String', '');
        set(GUI.RRIntPage_Length, 'String', '');
        set(GUI.MinYLimitLowAxes_Edit, 'String', '');
        set(GUI.MaxYLimitLowAxes_Edit, 'String', '');
        
        title(GUI.RRDataAxes, '');
        
        set(GUI.RecordName_text, 'String', '');
        set(GUI.RecordLength_text, 'String', '');
        set(GUI.DataQuality_text, 'String', '');
        
        set(GUI.freq_yscale_Button, 'String', 'Log');
        set(GUI.freq_yscale_Button, 'Value', 1);
        
        GUI.PageDownButton.Enable = 'off';
        GUI.PageUpButton.Enable = 'on';
    end
%%
    function clearStatTables()
        GUI.TimeParametersTable.Data = []; %cell(1);
        GUI.TimeParametersTableData = [];
        GUI.TimeParametersTable.RowName = [];
        
        GUI.FragParametersTableData = [];
        GUI.FragParametersTable.RowName=[];
        GUI.FragParametersTable.Data = [];
        
        GUI.FrequencyParametersTable.Data = [];
        GUI.FrequencyParametersTableData = [];
        GUI.FrequencyParametersTable.RowName = [];
        GUI.FrequencyParametersTableMethodRowName = [];
        
        GUI.NonLinearTable.Data = [];
        GUI.NonLinearTableData = [];
        GUI.NonLinearTable.RowName = [];
        
        GUI.StatisticsTable.RowName = {''};
        GUI.StatisticsTable.Data = {''};
        GUI.StatisticsTable.ColumnName = {'Description'; 'Values'};
        
        DATA.TimeStat = [];
        DATA.FrStat = [];
        DATA.NonLinStat = [];
        
        %         DATA.TimeStat.hrv_time_metrics = [];
        %         DATA.FrStat.hrv_fr_metrics = [];
        %         DATA.NonLinStat.hrv_nonlin_metrics = [];
        
        DATA.timeStatPartRowNumber = 0;
        DATA.frequencyStatPartRowNumber = 0;
    end
%% Open the window
    function GUI = createInterface()
        
        SmallFontSize = DATA.SmallFontSize;
        BigFontSize = DATA.BigFontSize;
        
        %params_uicontrols = DATA.params_uicontrols;
        
        %iconpath = [matlabroot, '/toolbox/matlab/icons/'];
        
        % Create the user interface for the application and return a
        % structure of handles for global use.
        GUI = struct();
        % Open a new figure window and remove the toolbar and menus
        % Open a window and add some menus
        %GUI.SaveFiguresWindow = [];
        GUI.Window = figure( ...
            'Name', 'PhysioZoo', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', ...
            'Position', [20, 50, DATA.window_size(1), DATA.window_size(2)], ...
            'Tag', 'fPhysioZoo'); %, 'WindowButtonDownFcn', @WindowButtonDownFcn_mainFigure
        %'Tag', 'fPhysioZoo',
        % , 'ButtonDownFcn', {@my_clickOnAllData, 'aa'}
        
        set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
        set(GUI.Window, 'WindowButtonUpFcn', @my_WindowButtonUpFcn);
        set(GUI.Window, 'WindowButtonDownFcn', @my_clickOnAllData);
        set(GUI.Window, 'WindowScrollWheelFcn', @my_WindowScrollWheelFcn);
        set(GUI.Window, 'WindowKeyPressFcn', @my_WindowKeyPressFcn);
        set(GUI.Window, 'WindowKeyReleaseFcn', @my_WindowKeyReleaseFcn);
        
        GUI.blue_line = [];
        
        %set(GUI.Window, 'Color', [0.9 1 1]);
        
        % , 'WindowButtonMotionFcn', @WindowButtonMotionFcn_mainFigure
        %, 'WindowButtonMotionFcn', @WindowButtonMotionFcn_mainFigure
        
        
        %         import java.awt.*
        %         import javax.swing.*
        %         %figIcon = ImageIcon([iconpath 'tool_legend.gif']);
        %         figIcon = ImageIcon([iconpath 'greenarrowicon.gif']);
        %         %figIcon = ImageIcon([iconpath 'Arwen4.gif']);
        %         drawnow;
        %         mde = com.mathworks.mde.desk.MLDesktop.getInstance;
        %         jTreeFig = mde.getClient('HRV Analysis').getTopLevelAncestor;
        %         jTreeFig.setIcon(figIcon);
        
        
        %         jFrame=get(GUI.Window, 'javaframe');
        %         jicon=javax.swing.ImageIcon(['logo_v1.gif']);
        %         jFrame.setFigureIcon(jicon);
        
        %         javaFrame = get(GUI.Window,'JavaFrame');
        %         javaFrame.setFigureIcon(javax.swing.ImageIcon([basepath filesep 'GUI' filesep 'Logo' filesep 'logoRed.png']));
        
        setLogo(GUI.Window);
        
        
        DATA.zoom_handle = zoom(GUI.Window);
        %DATA.zoom_handle.Motion = 'vertical';
        DATA.zoom_handle.Enable = 'on';
        %         DATA.zoom_handle.ButtonDownFilter = @zoom_handle_ButtonDownFilter;
        
        % + File menu
        GUI.FileMenu = uimenu( GUI.Window, 'Label', 'File' );
        uimenu( GUI.FileMenu, 'Label', 'Open data file', 'Callback', @onOpenFile, 'Accelerator','O');
        GUI.DataQualityMenu = uimenu( GUI.FileMenu, 'Label', 'Open signal quality file', 'Callback', @onOpenDataQualityFile, 'Accelerator','Q', 'Enable', 'off');
        GUI.LoadConfigFile = uimenu( GUI.FileMenu, 'Label', 'Load custom config file', 'Callback', @onLoadCustomConfigFile, 'Accelerator','P', 'Enable', 'off');
        GUI.SaveParamFileMenu = uimenu( GUI.FileMenu, 'Label', 'Save config file', 'Callback', @onSaveParamFile, 'Accelerator','P', 'Enable', 'off');
        GUI.SaveFiguresAsMenu = uimenu( GUI.FileMenu, 'Label', 'Save figures', 'Callback', @onSaveFiguresAsFile, 'Accelerator','F', 'Enable', 'off');
        GUI.SaveMeasures = uimenu( GUI.FileMenu, 'Label', 'Save HRV measures', 'Callback', @onSaveMeasures, 'Accelerator', 'S', 'Enable', 'off');
        
        uimenu( GUI.FileMenu, 'Label', 'Exit', 'Callback', @onExit, 'Separator', 'on', 'Accelerator', 'E');
        
        % + Help menu
        %         helpMenu = uimenu( GUI.Window, 'Label', 'Help' );
        %         uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @onHelp );
        %         uimenu( helpMenu, 'Label', 'PhysioZoo Home', 'Callback', @onPhysioZooHome );
        %uimenu( helpMenu, 'Label', 'About', 'Callback', @onAbout );
        
        % + Peak Detection menu
        tempMenu = uimenu( GUI.Window, 'Label', 'Peak Detection');
        GUI.PeakDetectionMenu = uimenu( tempMenu, 'Label', 'Peak Detection', 'Callback', @onPeakDetection);
        
        % Create the layout (Arrange the main interface)
        GUI.mainLayout = uix.VBoxFlex('Parent', GUI.Window, 'Spacing', DATA.Spacing);
        
        % + Create the panels
        Upper_Part_Box = uix.HBoxFlex('Parent', GUI.mainLayout, 'Spacing', DATA.Spacing); % Upper Part
        Low_Part_BoxPanel = uix.BoxPanel( 'Parent', GUI.mainLayout, 'Title', '  ', 'Padding', DATA.Padding+2 ); %Low Part
        
        upper_part = 0.55;
        upper_part = 1 - upper_part;
        set( GUI.mainLayout, 'Heights', [(-1)*upper_part, (-1)*upper_part]  );
        
        %---------------------------------
        
        % + Upper Panel - Left and Right Parts
        temp_panel_left = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding);
        temp_panel_right = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding);
        temp_panel_buttons = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding);
        temp_vbox_buttons = uix.VBox( 'Parent', temp_panel_buttons, 'Spacing', DATA.Spacing);
        
        if DATA.SmallScreen
            left_part = 0.4; % 0.4
            Left_Part_widths_in_pixels = 0.3 * DATA.window_size(1); % 0.3
            buttons_part = 0.1;
        else
            left_part = 0.25; % 0.27
            Left_Part_widths_in_pixels = 0.25 * DATA.window_size(1); % 0.25
            buttons_part = 0.07; % 0.07
        end
        right_part = 0.7; % 0.7
        
        Right_Part_widths_in_pixels = DATA.window_size(1) - Left_Part_widths_in_pixels;
        
        set(Upper_Part_Box, 'Widths', [-1*left_part -1*right_part -1*buttons_part]);
        
        GUI.UpLeft_TabPanel = uix.TabPanel('Parent', temp_panel_left, 'Padding', DATA.Padding, 'TabWidth', 60, 'FontSize', BigFontSize, 'SelectionChangedFcn', @TabChange_Callback);
        GUI.UpCentral_TabPanel = uix.CardPanel('Parent', temp_panel_right, 'Padding', DATA.Padding);
        MainCommandsButtons_Box = uix.VButtonBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        BlueRectButtons_Box = uix.HButtonBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'Padding', DATA.Padding, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        PageUpDownButtons_Box = uix.HButtonBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'Padding', DATA.Padding+10, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        
        set(temp_vbox_buttons, 'Heights', [-100, -35, -20]); % -15
        %------------------------------------
        
        GUI.OptionsTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
        GUI.BatchTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
        %         GUI.GroupTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
        GUI.AdvancedTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
        GUI.DisplayTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
        
        %         GUI.UpLeft_TabPanel.TabTitles = {'Main', 'Single', 'Group', 'Options', 'Display'};
        GUI.UpLeft_TabPanel.TabTitles = {'Main', 'Single', 'Options', 'Display'};
        
        %------------------------------------
        two_axes_box = uix.VBox('Parent', GUI.UpCentral_TabPanel, 'Spacing', DATA.Spacing);
        GUI.RRDataAxes = axes('Parent', uicontainer('Parent', two_axes_box), 'Tag', 'MainAxes');
        GUI.AllDataAxes = axes('Parent', uicontainer('Parent', two_axes_box));
        set(two_axes_box, 'Heights', [-1, 100]);
        
        %------------------------------------
        
        %         GUI.GroupAnalysisSclPanel = uix.ScrollingPanel( 'Parent', GUI.UpCentral_TabPanel);
        %         GUI.GroupAnalysisBox = uix.VBox( 'Parent', GUI.GroupAnalysisSclPanel, 'Spacing', DATA.Spacing);
        %         set( GUI.GroupAnalysisSclPanel, 'Widths', Right_Part_widths_in_pixels, 'Heights', 500 );
        %
        %         GUI.UpCentral_TabPanel.Selection = 1;
        %------------------------------------
        
        GUI.AutoCompute_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', MainCommandsButtons_Box, 'Callback', @AutoCompute_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Compute', 'Enable', 'inactive');
        GUI.AutoCalc_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', MainCommandsButtons_Box, 'Callback', @AutoCalc_checkbox_Callback, 'FontSize', BigFontSize-1.5, 'String', 'Auto Compute', 'Value', 1);
        GUI.RR_or_HR_plot_button = uicontrol( 'Style', 'ToggleButton', 'Parent', MainCommandsButtons_Box, 'Callback', @RR_or_HR_plot_button_Callback, 'FontSize', BigFontSize, 'String', 'Plot HR');
        GUI.Reset_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', MainCommandsButtons_Box, 'Callback', @Reset_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Reset');
        set( MainCommandsButtons_Box, 'ButtonSize', [110, 25], 'Spacing', DATA.Spacing  );
        
        GUI.BlueRectFocusButton = uicontrol( 'Style', 'PushButton', 'Parent', BlueRectButtons_Box, 'Callback', @blue_rect_focus_pushbutton_Callback, 'FontSize', BigFontSize, 'Visible', 'on');
        if DATA.SmallScreen
            set( BlueRectButtons_Box, 'ButtonSize', [80, 25], 'Spacing', DATA.Spacing  );
        else
            set( BlueRectButtons_Box, 'ButtonSize', [105, 25], 'Spacing', DATA.Spacing  );
        end
        
        GUI.PageDownButton = uicontrol( 'Style', 'PushButton', 'Parent', PageUpDownButtons_Box, 'Callback', @page_down_pushbutton_Callback, 'FontSize', BigFontSize, 'String', sprintf('\x25C0'), 'Visible', 'on');  % 2190'
        GUI.PageUpButton = uicontrol( 'Style', 'PushButton', 'Parent', PageUpDownButtons_Box, 'Callback', @page_up_pushbutton_Callback, 'FontSize', BigFontSize, 'String', sprintf('\x25B6'), 'Visible', 'on');  % 2192
        set( PageUpDownButtons_Box, 'ButtonSize', [70, 25], 'Spacing', DATA.Spacing  );
        
        %---------------------------------
        Analysis_Box = uix.HBoxFlex('Parent', Low_Part_BoxPanel, 'Spacing', DATA.Spacing);
        Analysis_TabPanel = uix.TabPanel('Parent', Analysis_Box, 'Padding', DATA.Padding, 'TabWidth', 90, 'FontSize', BigFontSize);
        
        GUI.StatisticsTab = uix.Panel( 'Parent', Analysis_TabPanel, 'Padding', DATA.Padding+2);
        GUI.TimeTab = uix.Panel( 'Parent', Analysis_TabPanel, 'Padding', DATA.Padding+2);
        GUI.FrequencyTab = uix.Panel( 'Parent', Analysis_TabPanel, 'Padding', DATA.Padding+2);
        GUI.NonLinearTab = uix.Panel( 'Parent', Analysis_TabPanel, 'Padding', DATA.Padding+2);
        %         GUI.GroupSummaryTab = uix.Panel( 'Parent', Analysis_TabPanel, 'Padding', DATA.Padding+2);
        %         Analysis_TabPanel.TabTitles = {'Statistics', 'Time', 'Frequency', 'NonLinear', 'Group'};
        Analysis_TabPanel.TabTitles = {'Statistics', 'Time', 'Frequency', 'NonLinear'};
        
        %-----------------------------------------
        
        tabs_widths = Left_Part_widths_in_pixels;
        tabs_heights = 340; % 370
        
        GUI.OptionsSclPanel = uix.ScrollingPanel( 'Parent', GUI.OptionsTab);
        GUI.OptionsBox = uix.VBox( 'Parent', GUI.OptionsSclPanel, 'Spacing', DATA.Spacing);
        set( GUI.OptionsSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        GUI.BatchSclPanel = uix.ScrollingPanel( 'Parent', GUI.BatchTab);
        GUI.BatchBox = uix.VBox( 'Parent', GUI.BatchSclPanel, 'Spacing', DATA.Spacing);
        set( GUI.BatchSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        GUI.DisplaySclPanel = uix.ScrollingPanel( 'Parent', GUI.DisplayTab);
        GUI.DisplayBox = uix.VBox( 'Parent', GUI.DisplaySclPanel, 'Spacing', DATA.Spacing);
        set( GUI.DisplaySclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        %         GUI.GroupSclPanel = uix.ScrollingPanel( 'Parent', GUI.GroupTab);
        %         GUI.GroupBox = uix.VBox( 'Parent', GUI.GroupSclPanel, 'Spacing', DATA.Spacing);
        %         set( GUI.GroupSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        %--------------------------------------------------------------------------------------------
        
        GUI.AdvancedBox = uix.VBox( 'Parent', GUI.AdvancedTab, 'Spacing', DATA.Spacing);
        GUI.Advanced_TabPanel = uix.TabPanel('Parent', GUI.AdvancedBox, 'Padding', DATA.Padding, 'TabWidth', 70, 'FontSize', SmallFontSize-1);
        
        GUI.FilteringParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', DATA.Padding+2);
        GUI.TimeParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', DATA.Padding+2);
        GUI.FrequencyParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', DATA.Padding+2);
        GUI.NonLinearParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', DATA.Padding+2);
        GUI.Advanced_TabPanel.TabTitles = {'Filtering', 'Time', 'Frequency', 'NonLinear'};
        
        GUI.FilteringSclPanel = uix.ScrollingPanel('Parent', GUI.FilteringParamTab);
        GUI.FilteringParamBox = uix.VBox('Parent', GUI.FilteringSclPanel, 'Spacing', DATA.Spacing+2);
        set( GUI.FilteringSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        GUI.TimeSclPanel = uix.ScrollingPanel('Parent', GUI.TimeParamTab);
        GUI.TimeParamBox = uix.VBox('Parent', GUI.TimeSclPanel, 'Spacing', DATA.Spacing+2);
        set( GUI.TimeSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        GUI.FrequencySclPanel = uix.ScrollingPanel('Parent', GUI.FrequencyParamTab);
        GUI.FrequencyParamBox = uix.VBox('Parent', GUI.FrequencySclPanel, 'Spacing', DATA.Spacing+2);
        set( GUI.FrequencySclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        GUI.NonLinearParamSclPanel = uix.ScrollingPanel('Parent', GUI.NonLinearParamTab);
        GUI.NonLinearParamBox = uix.VBox('Parent', GUI.NonLinearParamSclPanel, 'Spacing', DATA.Spacing+2);
        set( GUI.NonLinearParamSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        %------------------------------------------------------------------------------
        
        GUI.RecordNameBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{1} = uicontrol( 'Style', 'text', 'Parent', GUI.RecordNameBox, 'String', 'File name', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.RecordName_text = uicontrol( 'Style', 'text', 'Parent', GUI.RecordNameBox, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        uix.Empty( 'Parent', GUI.RecordNameBox );
        
        GUI.DataQualityBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{2} = uicontrol( 'Style', 'text', 'Parent', GUI.DataQualityBox, 'String', 'Signal quality file name', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.DataQuality_text = uicontrol( 'Style', 'text', 'Parent', GUI.DataQualityBox, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        uix.Empty( 'Parent', GUI.DataQualityBox );
        
        GUI.DataLengthBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{3} = uicontrol( 'Style', 'text', 'Parent', GUI.DataLengthBox, 'String', 'Time series length', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.RecordLength_text = uicontrol( 'Style', 'text', 'Parent', GUI.DataLengthBox, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        uix.Empty( 'Parent', GUI.DataLengthBox );
        
        GUI.MammalBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{4} = uicontrol( 'Style', 'text', 'Parent', GUI.MammalBox, 'String', 'Mammal', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.Mammal_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', GUI.MammalBox, 'Callback', @Mammal_popupmenu_Callback, 'FontSize', SmallFontSize, 'String', DATA.GUI_mammals, 'Value', 1);
        uix.Empty( 'Parent', GUI.MammalBox );
        
        GUI.IntegrationBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{5} = uicontrol( 'Style', 'text', 'Parent', GUI.IntegrationBox, 'String', 'Integration level', 'FontSize', SmallFontSize, 'Enable', 'on', 'HorizontalAlignment', 'left');
        GUI.Integration_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', GUI.IntegrationBox, 'Callback', @Integration_popupmenu_Callback, 'FontSize', SmallFontSize, 'Enable', 'on', 'Value', 1);
        GUI.Integration_popupmenu.String = DATA.GUI_Integration;
        uix.Empty( 'Parent', GUI.IntegrationBox );
        
        GUI.FilteringBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{6} = uicontrol( 'Style', 'text', 'Parent', GUI.FilteringBox, 'String', 'Preprocessing', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.Filtering_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', GUI.FilteringBox, 'Callback', @Filtering_popupmenu_Callback, 'FontSize', SmallFontSize);
        GUI.Filtering_popupmenu.String = DATA.Filters;
        uix.Empty( 'Parent', GUI.FilteringBox );
        
        GUI.FilteringLevelBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{7} = uicontrol( 'Style', 'text', 'Parent', GUI.FilteringLevelBox, 'String', 'Preprocessing level', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.FilteringLevel_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', GUI.FilteringLevelBox, 'Callback', @FilteringLevel_popupmenu_Callback, 'FontSize', SmallFontSize);
        GUI.FilteringLevel_popupmenu.String = DATA.FilterLevel;
        GUI.FilteringLevel_popupmenu.Value = DATA.default_filter_level_index;
        uix.Empty( 'Parent', GUI.FilteringLevelBox );
        
        DefaultMethodBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{8} = uicontrol( 'Style', 'text', 'Parent', DefaultMethodBox, 'String', 'Default frequency method', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.DefaultMethod_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', DefaultMethodBox, 'Callback', @DefaultMethod_popupmenu_Callback, 'FontSize', SmallFontSize, 'TooltipString', 'Default frequency method to use to display under statistics');
        GUI.DefaultMethod_popupmenu.String = DATA.frequency_methods;
        GUI.DefaultMethod_popupmenu.Value = 1;
        uix.Empty( 'Parent', DefaultMethodBox );
        
        %         AutoCalcBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        %         GUI.AutoCalc_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', AutoCalcBox, 'Callback', @AutoCalc_checkbox_Callback, 'FontSize', BigFontSize, 'String', 'Auto Compute', 'Value', 1);
        %         GUI.AutoCompute_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', AutoCalcBox, 'Callback', @AutoCompute_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Compute', 'Enable', 'inactive');
        %         uix.Empty( 'Parent', AutoCalcBox );
        
        max_extent_control = calc_max_control_x_extend(a);
        field_size = [max_extent_control + 5, -1, 1];
        
        set( GUI.RecordNameBox, 'Widths', field_size  );
        set( GUI.DataQualityBox, 'Widths', field_size );
        set( GUI.DataLengthBox, 'Widths', field_size );
        
        if DATA.SmallScreen
            field_size = [max_extent_control + 5, -0.65, -0.35]; % -0.65, -0.35
        else
            field_size = [max_extent_control + 5, -0.65, -0.35]; % -0.6, -0.5
        end
        
        set( GUI.MammalBox, 'Widths', field_size );
        set( GUI.IntegrationBox, 'Widths', field_size );
        set( GUI.FilteringBox, 'Widths', field_size );
        set( GUI.FilteringLevelBox, 'Widths', field_size );
        set( DefaultMethodBox, 'Widths', field_size );
        %         set( AutoCalcBox, 'Widths', field_size );
        
        uix.Empty( 'Parent', GUI.OptionsBox );
        set( GUI.OptionsBox, 'Heights', [-7 -7 -7 -7 -7 -7 -7 -7 -15] ); %  [-7 -7 -7 -7 -7 -7 -7 24 -7]
        %---------------------------
        
        uicontrol( 'Style', 'text', 'Parent', GUI.BatchBox, 'String', 'Batch analysis', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'bold', ...
            'Tooltip', 'You can use this module to batch process the RR time series by overlapping windows. This is useful for tracking the HRV measures as they evolve over time.');
        uix.Empty( 'Parent', GUI.BatchBox );
        
        a = [];
        BatchStartTimeBox = uix.HBox( 'Parent', GUI.BatchBox, 'Spacing',DATA.Spacing);
        a{1} = uicontrol( 'Style', 'text', 'Parent', BatchStartTimeBox, 'String', 'Segment start', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.segment_startTime = uicontrol( 'Style', 'edit', 'Parent', BatchStartTimeBox, 'FontSize', SmallFontSize, 'Callback', @batch_Edit_Callback, 'Tag', 'segment_startTime');
        units_control_handle = uicontrol( 'Style', 'text', 'Parent', BatchStartTimeBox, 'String', 'h:min:sec', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        
        BatchEndTimeBox = uix.HBox( 'Parent', GUI.BatchBox, 'Spacing', DATA.Spacing);
        a{2} = uicontrol( 'Style', 'text', 'Parent', BatchEndTimeBox, 'String', 'Segment end', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.segment_endTime = uicontrol( 'Style', 'edit', 'Parent', BatchEndTimeBox, 'FontSize', SmallFontSize, 'Callback', @batch_Edit_Callback, 'Tag', 'segment_endTime');
        uicontrol( 'Style', 'text', 'Parent', BatchEndTimeBox, 'String', 'h:min:sec', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        pushpbutton_control_handle = uicontrol( 'Style', 'PushButton', 'Parent', BatchEndTimeBox, 'Callback', @Full_Length_pushbutton_Callback, 'FontSize', SmallFontSize-2, 'String', 'Use full length');
        
        pushpbutton_control_position = get(pushpbutton_control_handle, 'Position');
        pushpbutton_control_extent = get(pushpbutton_control_handle, 'Extent');
        set(pushpbutton_control_handle, 'Position', [pushpbutton_control_position(1) pushpbutton_control_position(2) pushpbutton_control_extent(3)+4 pushpbutton_control_position(4)]);
        
        pushpbutton_control_position = get(pushpbutton_control_handle, 'Position');
        
        BatchWindowLengthBox = uix.HBox( 'Parent', GUI.BatchBox, 'Spacing', DATA.Spacing);
        a{3} = uicontrol( 'Style', 'text', 'Parent', BatchWindowLengthBox, 'String', 'Window length', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.activeWindow_length = uicontrol( 'Style', 'edit', 'Parent', BatchWindowLengthBox, 'FontSize', SmallFontSize, 'Callback', @batch_Edit_Callback, 'Tag', 'activeWin_length');
        uicontrol( 'Style', 'text', 'Parent', BatchWindowLengthBox, 'String', 'h:min:sec', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        
        BatchOverlapBox = uix.HBox( 'Parent', GUI.BatchBox, 'Spacing', DATA.Spacing);
        a{4} = uicontrol( 'Style', 'text', 'Parent', BatchOverlapBox, 'String', 'Overlap', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.segment_overlap = uicontrol( 'Style', 'edit', 'Parent', BatchOverlapBox, 'FontSize', SmallFontSize, 'Callback', @batch_Edit_Callback, 'Tag', 'segment_overlap');
        uicontrol( 'Style', 'text', 'Parent', BatchOverlapBox, 'String', '%', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        
        BatchActWinNumBox = uix.HBox( 'Parent', GUI.BatchBox, 'Spacing', DATA.Spacing);
        a{5} = uicontrol( 'Style', 'text', 'Parent', BatchActWinNumBox, 'String', 'Selected window', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.active_winNum = uicontrol( 'Style', 'edit', 'Parent', BatchActWinNumBox, 'FontSize', SmallFontSize, 'Callback', @active_winNum_Edit_Callback, 'Tag', 'active_winNum', 'Enable', 'inactive');
        uix.Empty( 'Parent', BatchActWinNumBox );
        
        BatchWinNumBox = uix.HBox( 'Parent', GUI.BatchBox, 'Spacing', DATA.Spacing);
        a{6} = uicontrol( 'Style', 'text', 'Parent', BatchWinNumBox, 'String', 'Number of windows', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.segment_winNum = uicontrol( 'Style', 'text', 'Parent', BatchWinNumBox, 'FontSize', SmallFontSize, 'Callback', @batch_Edit_Callback, 'Tag', 'winNum', 'Enable', 'inactive');
        uix.Empty( 'Parent', BatchWinNumBox );
        
        max_extent_control = calc_max_control_x_extend(a);
        units_control_extent = get(units_control_handle, 'Extent');
        
        field_size = [max_extent_control + 2, 85, units_control_extent(3) + 2];
        set( BatchStartTimeBox, 'Widths', field_size  );
        set( BatchEndTimeBox, 'Widths', [max_extent_control + 2, 85, units_control_extent(3) + 2, pushpbutton_control_position(3)+10] ); % 75
        set( BatchWindowLengthBox, 'Widths', field_size  );
        set( BatchOverlapBox, 'Widths', field_size  );
        set( BatchActWinNumBox, 'Widths', field_size );
        set( BatchWinNumBox, 'Widths', field_size );
        
        uix.Empty( 'Parent', GUI.BatchBox );
        
        %         batch_Box = uix.HBox('Parent', GUI.BatchBox, 'Spacing', DATA.Spacing);
        %         uix.Empty( 'Parent', batch_Box );
        %         uicontrol( 'Style', 'PushButton', 'Parent', batch_Box, 'Callback', @RunMultSegments_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Compute');
        %         uix.Empty( 'Parent', batch_Box );
        %         set( batch_Box, 'Widths',  field_size);
        
        uix.Empty( 'Parent', GUI.BatchBox );
        set( GUI.BatchBox, 'Heights', [-10 -5 -10 -10 -10 -10 -10 -10 -10 -70] ); % -15 -70
        
        % -----------------------------------------
        
        uix.Empty( 'Parent', GUI.DisplayBox );
        b = [];
        
        SelectedWindowStartBox = uix.HBox( 'Parent', GUI.DisplayBox, 'Spacing', DATA.Spacing);
        b{1} = uicontrol( 'Style', 'text', 'Parent', SelectedWindowStartBox, 'String', 'Selected window start:', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        GUI.Active_Window_Start = uicontrol( 'Style', 'edit', 'Parent', SelectedWindowStartBox, 'Callback', @Active_Window_Start_Callback, 'FontSize', BigFontSize);
        uicontrol( 'Style', 'text', 'Parent', SelectedWindowStartBox, 'String', 'h:min:sec', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        
        SelectedWindowLengthtBox = uix.HBox( 'Parent', GUI.DisplayBox, 'Spacing', DATA.Spacing);
        b{2} = uicontrol( 'Style', 'text', 'Parent', SelectedWindowLengthtBox, 'String', 'Selected window length:', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        GUI.Active_Window_Length = uicontrol( 'Style', 'edit', 'Parent', SelectedWindowLengthtBox, 'Callback', @Active_Window_Length_Callback, 'FontSize', BigFontSize);
        uicontrol( 'Style', 'text', 'Parent', SelectedWindowLengthtBox, 'String', 'h:min:sec', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        
        uix.Empty( 'Parent', GUI.DisplayBox );
        
        Filt_RawDataSliderBox = uix.HBox('Parent', GUI.DisplayBox, 'Spacing', DATA.Spacing);
        uix.Empty( 'Parent', Filt_RawDataSliderBox );
        GUI.Filt_RawDataSlider = uicontrol( 'Style', 'slider', 'Parent', Filt_RawDataSliderBox, 'Callback', @filt_slider_Callback, 'Enable', 'off');
        addlistener(GUI.Filt_RawDataSlider, 'ContinuousValueChange', @filt_sldrFrame_Motion);
        uix.Empty( 'Parent', Filt_RawDataSliderBox );
        set( Filt_RawDataSliderBox, 'Widths', [-0.1 300 -1]  );
        
        uix.Empty( 'Parent', GUI.DisplayBox );
        
        WindowStartBox = uix.HBox( 'Parent', GUI.DisplayBox, 'Spacing', DATA.Spacing);
        b{3} = uicontrol( 'Style', 'text', 'Parent', WindowStartBox, 'String', 'Focus window start:', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        GUI.FirstSecond = uicontrol( 'Style', 'edit', 'Parent', WindowStartBox, 'Callback', @FirstSecond_Callback, 'FontSize', BigFontSize); % , 'Enable', 'off'
        units_control_handle = uicontrol( 'Style', 'text', 'Parent', WindowStartBox, 'String', 'h:min:sec', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        
        WindowLengthBox = uix.HBox( 'Parent', GUI.DisplayBox, 'Spacing', DATA.Spacing);
        b{4} = uicontrol( 'Style', 'text', 'Parent', WindowLengthBox, 'String', 'Focus window length:', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        GUI.WindowSize = uicontrol( 'Style', 'edit', 'Parent', WindowLengthBox, 'Callback', @WindowSize_Callback, 'FontSize', BigFontSize);
        uicontrol( 'Style', 'text', 'Parent', WindowLengthBox, 'String', 'h:min:sec', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        
        YLimitBox = uix.HBox('Parent', GUI.DisplayBox, 'Spacing', DATA.Spacing);
        b{5} = uicontrol( 'Style', 'text', 'Parent', YLimitBox, 'String', 'Y Limit:', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        GUI.MinYLimitUpperAxes_Edit = uicontrol( 'Style', 'edit', 'Parent', YLimitBox, 'Callback', @MinMaxYLimitUpperAxes_Edit_Callback, 'FontSize', BigFontSize);
        uicontrol( 'Style', 'text', 'Parent', YLimitBox, 'String', '-', 'FontSize', BigFontSize);
        GUI.MaxYLimitUpperAxes_Edit = uicontrol( 'Style', 'edit', 'Parent', YLimitBox, 'Callback', @MinMaxYLimitUpperAxes_Edit_Callback, 'FontSize', BigFontSize);
        GUI.AutoScaleYUpperAxes_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', YLimitBox, 'Callback', @AutoScaleYUpperAxes_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'Auto Scale Y', 'Value', 1);
        
        GUI.ShowLegend_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', GUI.DisplayBox, 'Callback', @ShowLegend_checkbox_Callback, 'FontSize', BigFontSize, 'String', 'Show legend', 'Value', 1);
        
        RawDataSliderBox = uix.HBox('Parent', GUI.DisplayBox, 'Spacing', DATA.Spacing);
        uix.Empty( 'Parent', RawDataSliderBox );
        GUI.RawDataSlider = uicontrol( 'Style', 'slider', 'Parent', RawDataSliderBox, 'Callback', @slider_Callback);
        GUI.RawDataSlider.Enable = 'on';
        addlistener(GUI.RawDataSlider, 'ContinuousValueChange', @sldrFrame_Motion);
        uix.Empty( 'Parent', RawDataSliderBox );
        set( RawDataSliderBox, 'Widths', [-0.1 300 -1]  );
        
        uix.Empty( 'Parent', GUI.DisplayBox );
        
        RRIntPageLengthtBox = uix.HBox( 'Parent', GUI.DisplayBox, 'Spacing', DATA.Spacing);
        tooltip = 'Choose the length of the segment to display on the lower panel. This is useful for particularly long time series';
        b{6} = uicontrol( 'Style', 'text', 'Parent', RRIntPageLengthtBox, 'String', 'Displayed segment:', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left', 'Tooltip', tooltip);
        GUI.RRIntPage_Length = uicontrol( 'Style', 'edit', 'Parent', RRIntPageLengthtBox, 'Callback', @RRIntPage_Length_Callback, 'FontSize', BigFontSize, 'Tooltip', tooltip);
        uicontrol( 'Style', 'text', 'Parent', RRIntPageLengthtBox, 'String', 'h:min:sec', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left', 'Tooltip', tooltip);
        
        
        YLimitBoxLowAxes = uix.HBox('Parent', GUI.DisplayBox, 'Spacing', DATA.Spacing);
        b{7} = uicontrol( 'Style', 'text', 'Parent', YLimitBoxLowAxes, 'String', 'Y Limit:', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left');
        GUI.MinYLimitLowAxes_Edit = uicontrol( 'Style', 'edit', 'Parent', YLimitBoxLowAxes, 'Callback', @MinMaxYLimitLowAxes_Edit_Callback, 'FontSize', BigFontSize);
        uicontrol( 'Style', 'text', 'Parent', YLimitBoxLowAxes, 'String', '-', 'FontSize', BigFontSize);
        GUI.MaxYLimitLowAxes_Edit = uicontrol( 'Style', 'edit', 'Parent', YLimitBoxLowAxes, 'Callback', @MinMaxYLimitLowAxes_Edit_Callback, 'FontSize', BigFontSize);
        GUI.AutoScaleYLowAxes_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', YLimitBoxLowAxes, 'Callback', @AutoScaleYLowAxes_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'Auto Scale Y', 'Value', 1);
        
        max_extent_control = calc_max_control_x_extend(b);
        units_control_extent = get(units_control_handle, 'Extent');
        
        field_size = [max_extent_control + 2, 92, units_control_extent(3) + 2];
        
        set( WindowStartBox, 'Widths', field_size  );
        set( WindowLengthBox, 'Widths', field_size  );
        set( YLimitBox, 'Widths', [max_extent_control + 2, 45, 2, 39, -1]  );
        set( SelectedWindowStartBox, 'Widths', field_size  );
        set( SelectedWindowLengthtBox, 'Widths', field_size  );
        set( RRIntPageLengthtBox, 'Widths', field_size  );
        set( YLimitBoxLowAxes, 'Widths', [max_extent_control + 2, 45, 2, 39, -1]  );
        
        uix.Empty( 'Parent', GUI.DisplayBox );
        set( GUI.DisplayBox, 'Heights', [-7 -7 -7 -7 -7 -10 -7 -7 -7 -7 -7 -10 -7 -7 -10] );
        
        %-----------------------------------------------------------------------------------------------
        
        %         uix.Empty( 'Parent', GUI.GroupBox );
        %
        %         DataTypeBox = uix.HBox( 'Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
        %         aa{1} = uicontrol( 'Style', 'text', 'Parent', DataTypeBox, 'String', 'Data Type', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        %         GUI.DataType_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', DataTypeBox, 'Callback', @DataType_popupmenu_Callback, 'FontSize', SmallFontSize, 'String', {'QRS'; 'ECG'}, 'Enable', 'off');
        %         uix.Empty( 'Parent', DataTypeBox );
        %         uix.Empty( 'Parent', DataTypeBox );
        %
        %         FileTypeBox = uix.HBox( 'Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
        %         aa{2} = uicontrol( 'Style', 'text', 'Parent', FileTypeBox, 'String', 'File Type', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        %         GUI.Group.pmFileType = uicontrol( 'Style', 'PopUpMenu', 'Parent', FileTypeBox, 'Callback', @FileType_popupmenu_Callback, 'FontSize', SmallFontSize, 'String', DATA.file_types);
        %         uix.Empty( 'Parent', FileTypeBox );
        %         uix.Empty( 'Parent', FileTypeBox );
        %
        %         %         DataType_bg = uibuttongroup( 'Parent', DataTypeBox, 'Title', 'Data Type');
        %         %         uix.Empty( 'Parent', DataTypeBox );
        %         %         uix.Empty( 'Parent', DataTypeBox );
        %         %         ECG_radiobutton = uicontrol('Parent', DataType_bg, 'Style', 'radiobutton', 'String', 'ECG');
        %         %         QRS_radiobutton = uicontrol('Parent', DataType_bg, 'Style', 'radiobutton', 'String', 'QRS');
        %         %         get(ECG_radiobutton, 'Units')
        %         %         get(ECG_radiobutton, 'Position')
        %         %         DataType_bg.Visible = 'on';
        %
        %         GUI.LoadBox = uix.HBox( 'Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
        %         aa{3} = uicontrol( 'Style', 'text', 'Parent', GUI.LoadBox, 'String', 'Load', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        %         GUI.Group.pmWorkDir = uicontrol( 'Style', 'PopUpMenu', 'Parent', GUI.LoadBox, 'Callback', @LoadGroupDir_popupmenu_Callback, 'FontSize', SmallFontSize, 'String', '  ');
        %         GUI.LoadButtons_Box = uix.HButtonBox('Parent', GUI.LoadBox, 'Spacing', DATA.Spacing, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'ButtonSize', [70, 30]);
        %         GUI.Group.btnLoadDir = uicontrol( 'Style', 'PushButton', 'Parent', GUI.LoadButtons_Box, 'Callback', @LoadDir_pushbutton_Callback, 'FontSize', BigFontSize, 'String', '  ...  ');
        %         uix.Empty( 'Parent', GUI.LoadBox );
        %
        %         uix.Empty( 'Parent', GUI.GroupBox );
        %
        %         GUI.MembersBox = uix.HBox( 'Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
        %         aa{4} = uicontrol( 'Style', 'text', 'Parent', GUI.MembersBox, 'String', 'Members', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        %         GUI.Group.lbMembers = uicontrol( 'Style', 'ListBox', 'Parent', GUI.MembersBox, 'Callback', @Members_listbox_Callback, 'FontSize', SmallFontSize, 'String', {' '; ' '; ' '; ' '}, 'Max', 5);
        %         uix.Empty( 'Parent', GUI.MembersBox );
        %         uix.Empty( 'Parent', GUI.MembersBox );
        %
        %         uix.Empty( 'Parent', GUI.GroupBox );
        %
        %         GUI.NamesBox = uix.HBox( 'Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
        %         aa{5} = uicontrol( 'Style', 'text', 'Parent', GUI.NamesBox, 'String', 'Name', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        %         GUI.Group.ebName = uicontrol( 'Style', 'edit', 'Parent', GUI.NamesBox, 'Callback', @Name_edit_Callback, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        %         GUI.AddDelButtons_Box = uix.HButtonBox('Parent', GUI.NamesBox, 'Spacing', DATA.Spacing, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'ButtonSize', [70, 30]);
        %         GUI.Group.btnAddGroup = uicontrol( 'Style', 'PushButton', 'Parent', GUI.AddDelButtons_Box, 'Callback', @Add_PushButton_Callback, 'FontSize', BigFontSize, 'String', 'Add', 'Enable', 'off');
        %         GUI.Group.btnDelGroup = uicontrol( 'Style', 'PushButton', 'Parent', GUI.AddDelButtons_Box, 'Callback', @Del_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Del');
        %         uix.Empty( 'Parent', GUI.NamesBox );
        %
        %         uix.Empty( 'Parent', GUI.GroupBox );
        %
        %         GUI.GroupsBox = uix.HBox( 'Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
        %         aa{6} = uicontrol( 'Style', 'text', 'Parent', GUI.GroupsBox, 'String', 'Groups', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        %         GUI.Group.lbGroups = uicontrol( 'Style', 'ListBox', 'Parent', GUI.GroupsBox, 'Callback', @Groups_listbox_Callback, 'FontSize', SmallFontSize, 'String', {' '; ' '; ' '; ' '});
        %         uix.Empty( 'Parent', GUI.GroupsBox );
        %         uix.Empty( 'Parent', GUI.GroupsBox );
        %
        %         uix.Empty( 'Parent', GUI.GroupBox );
        %
        %         Comp_Box = uix.HBox('Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
        %         uix.Empty( 'Parent', Comp_Box );
        %         uicontrol( 'Style', 'PushButton', 'Parent', Comp_Box, 'Callback', @GroupsCompute_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Compute', 'Enable', 'on');
        %         uix.Empty( 'Parent', Comp_Box );
        %         uix.Empty( 'Parent', Comp_Box );
        %
        %         max_extent_control = calc_max_control_x_extend(aa);
        %         field_size = [max_extent_control + 5, 225, 80 -1];
        %         set( DataTypeBox, 'Widths', field_size );
        %         set( FileTypeBox, 'Widths', field_size );
        %         set( GUI.LoadBox, 'Widths', field_size );
        %         set( GUI.MembersBox, 'Widths', field_size );
        %         set( GUI.NamesBox, 'Widths', field_size );
        %         set( GUI.GroupsBox, 'Widths', field_size );
        %         set( Comp_Box, 'Widths', field_size );
        %
        %         uix.Empty( 'Parent', GUI.GroupBox );
        %
        %         set( GUI.GroupBox, 'Heights', [-1 -7.5 -7.5 -7.5 -1 -20 -1 -7 -1 -20 -5 -7 -1] );
        
        %---------------------------
        tables_field_size = [-85 -15];
        
        GUI.TimeBox = uix.HBox( 'Parent', GUI.TimeTab, 'Spacing', DATA.Spacing);
        GUI.ParamTimeBox = uix.VBox( 'Parent', GUI.TimeBox, 'Spacing', DATA.Spacing);
        GUI.TimeParametersTable = uitable( 'Parent', GUI.ParamTimeBox, 'FontSize', SmallFontSize, 'FontName', 'Calibri');
        GUI.TimeParametersTable.ColumnName = {'    Measures Name    ', 'Values'};
        uix.Empty( 'Parent', GUI.ParamTimeBox );
        set( GUI.ParamTimeBox, 'Heights', tables_field_size );
        
        GUI.TimeAxes1 = axes('Parent', uicontainer('Parent', GUI.TimeBox) );
        set( GUI.TimeBox, 'Widths', [-14 -80] );
        %---------------------------
        
        GUI.FrequencyBox = uix.HBox( 'Parent', GUI.FrequencyTab, 'Spacing', DATA.Spacing);
        GUI.ParamFrequencyBox = uix.VBox( 'Parent', GUI.FrequencyBox, 'Spacing', DATA.Spacing);
        GUI.FrequencyParametersTable = uitable( 'Parent', GUI.ParamFrequencyBox, 'FontSize', SmallFontSize, 'FontName', 'Calibri');
        GUI.FrequencyParametersTable.ColumnName = {'                Measures Name                ', 'Values Welch', 'Values AR'};
        uix.Empty( 'Parent', GUI.ParamFrequencyBox );
        set( GUI.ParamFrequencyBox, 'Heights', tables_field_size );
        
        PSD_Box = uix.VBox( 'Parent', GUI.FrequencyBox, 'Spacing', DATA.Spacing);
        PSD_HBox = uix.HBox('Parent', PSD_Box, 'Spacing', DATA.Spacing);
        FrAxesBox = uix.HBox( 'Parent', PSD_Box, 'Spacing', DATA.Spacing-1);
        
        GUI.FrequencyAxes1 = axes('Parent', uicontainer('Parent', FrAxesBox) );
        GUI.FrequencyAxes2 = axes('Parent', uicontainer('Parent', FrAxesBox) );
        
        set( PSD_Box, 'Heights', [-7 -93] );
        set( FrAxesBox, 'Widths', [-50 -50], 'Padding', DATA.Padding+1 );
        
        uix.Empty( 'Parent', PSD_HBox );
        GUI.freq_yscale_Button = uicontrol( 'Style', 'ToggleButton', 'Parent', PSD_HBox, 'Callback', @PSD_pushbutton_Callback, 'FontSize', BigFontSize, 'Value', 1, 'String', 'Log');
        uix.Empty( 'Parent', PSD_HBox );
        set( PSD_HBox, 'Widths', [-30 100 -45] );
        
        set( GUI.FrequencyBox, 'Widths', [-34 -64] );
        %---------------------------
        
        GUI.NonLinearBox = uix.HBox( 'Parent', GUI.NonLinearTab, 'Spacing', DATA.Spacing);
        GUI.ParamNonLinearBox = uix.VBox( 'Parent', GUI.NonLinearBox, 'Spacing', DATA.Spacing);
        GUI.NonLinearTable = uitable( 'Parent', GUI.ParamNonLinearBox, 'FontSize', SmallFontSize, 'FontName', 'Calibri');
        GUI.NonLinearTable.ColumnName = {'    Measures Name    ', 'Values'};
        uix.Empty( 'Parent', GUI.ParamNonLinearBox );
        set( GUI.ParamNonLinearBox, 'Heights', tables_field_size );
        
        GUI.NonLinearAxes1 = axes('Parent', uicontainer('Parent', GUI.NonLinearBox) );
        GUI.NonLinearAxes2 = axes('Parent', uicontainer('Parent', GUI.NonLinearBox) );
        GUI.NonLinearAxes3 = axes('Parent', uicontainer('Parent', GUI.NonLinearBox) );
        set( GUI.NonLinearBox, 'Widths', [-14 -24 -24 -24] );
        %---------------------------
        GUI.StatisticsTable = uitable( 'Parent', GUI.StatisticsTab, 'FontSize', SmallFontSize, 'ColumnWidth',{800 'auto'}, 'FontName', 'Calibri');    % 550
        GUI.StatisticsTable.ColumnName = {'Description'; 'Values'};
        %---------------------------
        %         GUI.GroupSummaryTable = uitable( 'Parent', GUI.GroupSummaryTab, 'FontSize', SmallFontSize, 'ColumnWidth',{800 'auto'}, 'FontName', 'Calibri');    % 550
        %         GUI.GroupSummaryTable.ColumnName = {'Description'; 'Values'};
        %---------------------------
        
        % Upper Part
        
        set(findobj(Upper_Part_Box,'Style', 'edit'), 'BackgroundColor', myEditTextColor);
        set(findobj(Upper_Part_Box,'Style', 'text'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(Upper_Part_Box,'Style', 'slider'), 'BackgroundColor', mySliderColor);
        set(findobj(Upper_Part_Box,'Style', 'checkbox'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(Upper_Part_Box,'Style', 'ToggleButton'), 'BackgroundColor', myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
        set(findobj(Upper_Part_Box,'Style', 'PushButton'), 'BackgroundColor', myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
        
        set(GUI.BlueRectFocusButton, 'BackgroundColor', DATA.rectangle_color);
        
        set(findobj(Upper_Part_Box,'Type', 'uicontainer'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(Upper_Part_Box,'Type', 'uipanel'), 'BackgroundColor', myUpBackgroundColor);
        
        % Low Part
        set(findobj(Low_Part_BoxPanel,'Type', 'uicontainer'), 'BackgroundColor', myLowBackgroundColor);
        set(findobj(Low_Part_BoxPanel,'Type', 'uipanel'), 'BackgroundColor', myLowBackgroundColor);
        
        GUI.Active_Window_Start.BackgroundColor = DATA.rectangle_color;
        GUI.Active_Window_Length.BackgroundColor = DATA.rectangle_color;
        
        GUI.FirstSecond.BackgroundColor = [0.9 0.7 0.7];
        GUI.WindowSize.BackgroundColor = [0.9 0.7 0.7];
        
    end % createInterface
%%
    function max_extent_control = calc_max_control_x_extend(uitext_handle)
        max_extent_control = 0;
        for i = 1 : length(uitext_handle)
            extent_control = get(uitext_handle{i}, 'Extent');
            max_extent_control = max(max_extent_control, extent_control(3));
        end
    end
%%
    function clearParametersBox(VBoxHandle)
        param_boxes_handles = allchild(VBoxHandle);
        if ~isempty(param_boxes_handles)
            delete(param_boxes_handles);
        end
    end
%%
    function TabChange_Callback(~, eventData)
        %         if eventData.NewValue == 3
        %             GUI.UpCentral_TabPanel.Selection = 2;
        %         else
        %             GUI.UpCentral_TabPanel.Selection = 1;
        %         end
    end
%%
    function [param_keys_length, max_extent_control, handles_boxes] = FillParamFields(VBoxHandle, param_map)
        
        SmallFontSize = DATA.SmallFontSize;
        
        param_keys = keys(param_map);
        param_keys_length = length(param_keys);
        
        text_fields_handles_cell = cell(1, param_keys_length);
        handles_boxes = cell(4, param_keys_length);
        for i = 1 : param_keys_length
            
            HBox = uix.HBox( 'Parent', VBoxHandle, 'Spacing', DATA.Spacing, 'BackgroundColor', myUpBackgroundColor);
            handles_boxes{1, i} = HBox;
            
            field_name = param_keys{i};
            
            current_field = param_map(field_name);
            current_field_value = current_field.value;
            handles_boxes{2, i} = current_field_value;
            
            symbol_field_name = current_field.name;
            
            symbol_field_name = strrep(symbol_field_name, 'Alpha1', sprintf('\x3b1\x2081')); % https://unicode-table.com/en/
            symbol_field_name = strrep(symbol_field_name, 'Alpha2', sprintf('\x3b1\x2082'));
            symbol_field_name = strrep(symbol_field_name, 'Beta', sprintf('\x3b2'));
            
            text_fields_handles_cell{i} = uicontrol( 'Style', 'text', 'Parent', HBox, 'String', symbol_field_name, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'TooltipString', current_field.description);
            
            if length(current_field_value) < 2
                current_value = num2str(current_field_value);
                param_control = uicontrol( 'Style', 'edit', 'Parent', HBox, 'Callback', {@set_config_Callback, field_name}, 'FontSize', SmallFontSize, 'TooltipString', current_field.description);
                if strcmp(symbol_field_name, 'Spectral window length')
                    GUI.SpectralWindowLengthHandle = param_control;
                    set(param_control, 'String', calcDuration(current_field_value*60, 0), 'UserData', current_field_value*60);
                else
                    set(param_control, 'String', current_value, 'UserData', current_value);
                end
                
                
                GUI.ConfigParamHandlesMap(field_name) = param_control;
                
                
                %                 if ~isempty(strfind(field_name, 'hrv_time'))
                %                     GUI.ConfigParamHandlesMap(field_name) = param_control;
                %                 elseif ~isempty(strfind(field_name, 'filtrr'))
                %                     GUI.ConfigParamHandlesMap(field_name) = param_control;
                %                 end
                
                
                
                
                
            else
                field_name_min = [field_name '.min'];
                current_value = num2str(current_field_value(1));
                param_control1 = uicontrol( 'Style', 'edit', 'Parent', HBox, 'Callback', {@set_config_Callback, field_name_min}, 'FontSize', SmallFontSize, 'TooltipString', current_field.description, 'Tag', field_name_min);
                
                set(param_control1, 'String', current_value, 'UserData', current_value);
                uicontrol( 'Style', 'text', 'Parent', HBox, 'String', '-', 'FontSize', SmallFontSize, 'TooltipString', current_field.description);
                field_name_max = [field_name '.max'];
                current_value = num2str(current_field_value(2));
                param_control2 = uicontrol( 'Style', 'edit', 'Parent', HBox, 'Callback', {@set_config_Callback, field_name_max}, 'FontSize', SmallFontSize, 'TooltipString', current_field.description, 'Tag', field_name_max);
                
                set(param_control2, 'String', current_value, 'UserData', current_value);
                
                
                GUI.ConfigParamHandlesMap(field_name_min) = param_control1;
                GUI.ConfigParamHandlesMap(field_name_max) = param_control2;
                
                
                
                %                 if ~isempty(strfind(field_name, 'hrv_freq'))
                %                     GUI.ConfigParamHandlesMap(field_name_min) = param_control1;
                %                     GUI.ConfigParamHandlesMap(field_name_max) = param_control2;
                %                 end
                
            end
            if strcmp(symbol_field_name, 'Spectral window length')
                uicontrol( 'Style', 'text', 'Parent', HBox, 'String', 'h:min:sec', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'TooltipString', current_field.description);
            else
                uicontrol( 'Style', 'text', 'Parent', HBox, 'String', current_field.units, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'TooltipString', current_field.description);
            end
            
            if strcmp(symbol_field_name, 'LF Band')
                uicontrol('Style', 'PushButton', 'Parent', HBox, 'Callback', @EstimateLFBand_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'E',...
                    'TooltipString', 'Click here to estimate the frequency bands based on the mammalian typical heart rate');
                handles_boxes{3, i} = true; % estimateBands
            else
                handles_boxes{3, i} = false;
            end
            if strcmp(symbol_field_name, 'PNN Threshold')
                uicontrol('Style', 'PushButton', 'Parent', HBox, 'Callback', @EstimatePNNThreshold_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'E',...
                    'TooltipString', 'Click here to estimate the pNNxx threshold based on the mammalian breathing rate');
                handles_boxes{4, i} = true; % estimatepNNxx
            else
                handles_boxes{4, i} = false;
            end
        end
        
        max_extent_control = calc_max_control_x_extend(text_fields_handles_cell);
    end
%%
    function setWidthsConfigParams(max_extent_control, handles_boxes)
        handles_boxes_size = size(handles_boxes);
        fields_size = [max_extent_control + 2, 125, -1];
        for j = 1 : handles_boxes_size(2)
            if  handles_boxes{4, j} % estimatepNNxx
                set(handles_boxes{1, j}, 'Widths', [max_extent_control + 2, 125, 30, 20]);
            elseif handles_boxes{3, j}
                set(handles_boxes{1, j}, 'Widths', [max_extent_control + 2, 58, 5, 56, 20, 20]);
            elseif length(handles_boxes{2, j}) < 2
                set(handles_boxes{1, j}, 'Widths', fields_size);
            else
                set(handles_boxes{1, j}, 'Widths', [max_extent_control + 2, 58, 5, 56, -1]);
            end
        end
    end
%%
    function createConfigParametersInterface()
        
        gui_param = ReadYaml('gui_params.yml');
        gui_param_names = fieldnames(gui_param);
        param_struct = gui_param.(gui_param_names{1});
        param_name = fieldnames(param_struct);
        not_in_use_params_fr = param_struct.(param_name{1});
        not_in_use_params_mse = param_struct.(param_name{2});
        
        SmallFontSize = DATA.SmallFontSize;
        
        GUI.ConfigParamHandlesMap = containers.Map;
        
        defaults_map = mhrv_get_all_defaults();
        param_keys = keys(defaults_map);
        
        filtrr_keys = param_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'filtrr')), param_keys)));
        filt_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.range')), filtrr_keys)));
        ma_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.moving_average')), filtrr_keys)));
        quotient_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.quotient')), filtrr_keys)));
        
        filt_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), filt_range_keys))) = [];
        ma_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), ma_range_keys))) = [];
        quotient_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), quotient_range_keys))) = [];
        
        DATA.filter_quotient = mhrv_get_default('filtrr.quotient.enable', 'value');
        DATA.filter_ma = mhrv_get_default('filtrr.moving_average.enable', 'value');
        DATA.filter_range = mhrv_get_default('filtrr.range.enable', 'value');
        
        DATA.default_filters_thresholds.moving_average.win_threshold = mhrv_get_default('filtrr.moving_average.win_threshold', 'value');
        DATA.default_filters_thresholds.moving_average.win_length = mhrv_get_default('filtrr.moving_average.win_length', 'value');
        DATA.default_filters_thresholds.quotient.rr_max_change = mhrv_get_default('filtrr.quotient.rr_max_change', 'value');
        DATA.default_filters_thresholds.range.rr_max = mhrv_get_default('filtrr.range.rr_max', 'value');
        DATA.default_filters_thresholds.range.rr_min = mhrv_get_default('filtrr.range.rr_min', 'value');
        
        DATA.custom_filters_thresholds = DATA.default_filters_thresholds;
        %         DATA.custom_config_params = defaults_map;
        
        if DATA.filter_ma && DATA.filter_range
            DATA.filter_index = 4;
        elseif ~DATA.filter_quotient && ~DATA.filter_ma && ~DATA.filter_range
            DATA.filter_index = 5;
        elseif DATA.filter_ma
            DATA.filter_index = 1;
        elseif DATA.filter_range
            DATA.filter_index = 2;
        elseif DATA.filter_quotient
            DATA.filter_index = 3;
        end
        GUI.Filtering_popupmenu.Value = DATA.filter_index;
        
        hrv_time_keys = param_keys((cellfun(@(x) ~isempty(regexpi(x, 'hrv_time')), param_keys))); % find
        hrv_freq_keys = param_keys((cellfun(@(x) ~isempty(regexpi(x, 'hrv_freq')), param_keys)));% find
        dfa_keys = param_keys((cellfun(@(x) ~isempty(regexpi(x, 'dfa')), param_keys))); % find
        mse_keys = param_keys((cellfun(@(x) ~isempty(regexpi(x, 'mse')), param_keys))); % find
        
        for i = 1 : length(not_in_use_params_fr)
            hrv_freq_keys((cellfun(@(x) ~isempty(regexpi(x, not_in_use_params_fr{i})), hrv_freq_keys))) = []; % find
        end
        for i = 1 : length(not_in_use_params_mse)
            mse_keys((cellfun(@(x) ~isempty(regexpi(x, not_in_use_params_mse{i})), mse_keys))) = [];
        end
        
        mse_keys((cellfun(@(x) ~isempty(regexpi(x, 'normalize_std')), mse_keys))) = [];
        
        max_extent_control = [];
        % Filtering Parameters
        clearParametersBox(GUI.FilteringParamBox);
        uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Range', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        [filt_range_keys_length, max_extent_control(1), handles_boxes_1] = FillParamFields(GUI.FilteringParamBox, containers.Map(filt_range_keys, values(defaults_map, filt_range_keys)));
        uix.Empty( 'Parent', GUI.FilteringParamBox );
        
        uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Moving average', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        [filt_ma_keys_length, max_extent_control(2), handles_boxes_2] = FillParamFields(GUI.FilteringParamBox, containers.Map(ma_range_keys, values(defaults_map, ma_range_keys)));
        uix.Empty( 'Parent', GUI.FilteringParamBox );
        
        uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Quotient', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        [filt_quotient_keys_length, max_extent_control(3), handles_boxes_3] = FillParamFields(GUI.FilteringParamBox, containers.Map(quotient_range_keys, values(defaults_map, quotient_range_keys)));
        uix.Empty( 'Parent', GUI.FilteringParamBox );
        
        max_extent = max(max_extent_control);
        
        setWidthsConfigParams(max_extent, handles_boxes_1);
        setWidthsConfigParams(max_extent, handles_boxes_2);
        setWidthsConfigParams(max_extent, handles_boxes_3);
        
        rs = 19; %-22;
        ts = 19; % -18
        es = 2;
        set( GUI.FilteringParamBox, 'Height', [ts, rs * ones(1, filt_range_keys_length), es, ts,  rs * ones(1, filt_ma_keys_length), es, ts,  rs * ones(1, filt_quotient_keys_length), -20]  );
        
        % Time Parameters
        clearParametersBox(GUI.TimeParamBox);
        uix.Empty( 'Parent', GUI.TimeParamBox );
        [time_keys_length, max_extent_control, handles_boxes] = FillParamFields(GUI.TimeParamBox, containers.Map(hrv_time_keys, values(defaults_map, hrv_time_keys)));
        uix.Empty( 'Parent', GUI.TimeParamBox );
        
        setWidthsConfigParams(max_extent_control, handles_boxes);
        
        rs = 19; %-10;
        ts = 19;
        set( GUI.TimeParamBox, 'Height', [ts, rs * ones(1, time_keys_length), -167]  );
        
        %-----------------------------------
        
        % Frequency Parameters
        clearParametersBox(GUI.FrequencyParamBox);
        uix.Empty( 'Parent', GUI.FrequencyParamBox );
        [freq_param_length, max_extent_control, handles_boxes] = FillParamFields(GUI.FrequencyParamBox, containers.Map(hrv_freq_keys, values(defaults_map, hrv_freq_keys)));
        uix.Empty( 'Parent', GUI.FrequencyParamBox );
        
        setWidthsConfigParams(max_extent_control, handles_boxes);
        
        GUI.WinAverage_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', GUI.FrequencyParamBox, 'Callback', @WinAverage_checkbox_Callback, 'FontSize', DATA.BigFontSize, ...
            'String', 'Use window average', 'Value', 0, 'Tooltip', 'Divide the signal into segments of size Spectral window length in order to compute the power spectrum and average across them');
        
        uix.Empty( 'Parent', GUI.FrequencyParamBox );
        rs = 19;
        set( GUI.FrequencyParamBox, 'Height', [-10, rs * ones(1, freq_param_length), -1, -10, -55]  );
        
        %-----------------------------------
        
        % NonLinear Parameters - DFA
        clearParametersBox(GUI.NonLinearParamBox);
        uicontrol( 'Style', 'text', 'Parent', GUI.NonLinearParamBox, 'String', 'Detrended Fluctuation Analysis (DFA)', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        [dfa_param_length, max_extent_control(1), handles_boxes_1] = FillParamFields(GUI.NonLinearParamBox, containers.Map(dfa_keys, values(defaults_map, dfa_keys)));
        
        % NonLinear Parameters - MSE
        uix.Empty( 'Parent', GUI.NonLinearParamBox );
        uicontrol( 'Style', 'text', 'Parent', GUI.NonLinearParamBox, 'String', 'Multi Scale Entropy (MSE)', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        [mse_param_length, max_extent_control(2), handles_boxes_2] = FillParamFields(GUI.NonLinearParamBox, containers.Map(mse_keys, values(defaults_map, mse_keys)));
        
        uix.Empty( 'Parent', GUI.NonLinearParamBox );
        
        GUI.Normalize_STD_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', GUI.NonLinearParamBox, 'Callback', @Normalize_STD_checkbox_Callback, 'FontSize', DATA.BigFontSize, ...
            'String', defaults_map('mse.normalize_std').name, 'Value', defaults_map('mse.normalize_std').value, 'TooltipString', defaults_map('mse.normalize_std').description, 'Callback', @Normalize_STD_checkbox_Callback);
        
        uix.Empty( 'Parent', GUI.NonLinearParamBox );
        
        max_extent = max(max_extent_control);
        
        setWidthsConfigParams(max_extent, handles_boxes_1);
        setWidthsConfigParams(max_extent, handles_boxes_2);
        
        rs = 19; %-22;
        ts = 19; % -18
        es = 2; % -15
        
        set( GUI.NonLinearParamBox, 'Heights', [ts, rs * ones(1, dfa_param_length), es, ts,  rs * ones(1, mse_param_length), es, rs, -25] );
        
        set(findobj(GUI.FilteringParamBox,'Style', 'edit'), 'BackgroundColor', myEditTextColor);
        set(findobj(GUI.FilteringParamBox,'Style', 'text'), 'BackgroundColor', myUpBackgroundColor);
        
        set(findobj(GUI.TimeParamBox,'Style', 'edit'), 'BackgroundColor', myEditTextColor);
        set(findobj(GUI.TimeParamBox,'Style', 'text'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(GUI.TimeParamBox,'Style', 'PushButton'), 'BackgroundColor', myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
        
        set(findobj(GUI.FrequencyParamBox,'Style', 'edit'), 'BackgroundColor', myEditTextColor);
        set(findobj(GUI.FrequencyParamBox,'Style', 'text'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(GUI.FrequencyParamBox,'Style', 'PushButton'), 'BackgroundColor', myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
        set(findobj(GUI.FrequencyParamBox,'Style', 'Checkbox'), 'BackgroundColor', myUpBackgroundColor);
        
        set(findobj(GUI.NonLinearParamBox,'Style', 'edit'), 'BackgroundColor', myEditTextColor);
        set(findobj(GUI.NonLinearParamBox,'Style', 'text'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(GUI.NonLinearParamBox,'Style', 'Checkbox'), 'BackgroundColor', myUpBackgroundColor);
    end
%%
    function slider_Callback(~, ~)
        DATA.firstSecond2Show = get(GUI.RawDataSlider, 'Value');
        set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0));
        setXAxesLim();
        setAutoYAxisLimUpperAxes(DATA.firstSecond2Show, DATA.MyWindowSize);
        DATA.YLimUpperAxes = setYAxesLim(GUI.RRDataAxes, GUI.AutoScaleYUpperAxes_checkbox, GUI.MinYLimitUpperAxes_Edit, GUI.MaxYLimitUpperAxes_Edit, DATA.YLimUpperAxes, DATA.AutoYLimitUpperAxes);
        plotDataQuality();
        plotMultipleWindows();
        xdata = get(GUI.red_rect, 'XData');
        xdata([1, 4, 5]) = DATA.firstSecond2Show;
        xdata([2, 3]) = DATA.firstSecond2Show + DATA.MyWindowSize;
        set(GUI.red_rect, 'XData', xdata);
        EnablePageUpDown();
    end
%%
    function sldrFrame_Motion(~, ~)
        DATA.firstSecond2Show = get(GUI.RawDataSlider, 'Value');
        set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0));
        setXAxesLim();
        setAutoYAxisLimUpperAxes(DATA.firstSecond2Show, DATA.MyWindowSize);
        DATA.YLimUpperAxes = setYAxesLim(GUI.RRDataAxes, GUI.AutoScaleYUpperAxes_checkbox, GUI.MinYLimitUpperAxes_Edit, GUI.MaxYLimitUpperAxes_Edit, DATA.YLimUpperAxes, DATA.AutoYLimitUpperAxes);
        plotDataQuality();
        plotMultipleWindows();
        xdata = get(GUI.red_rect, 'XData');
        xdata([1, 4, 5]) = DATA.firstSecond2Show;
        xdata([2, 3]) = DATA.firstSecond2Show + DATA.MyWindowSize;
        set(GUI.red_rect, 'XData', xdata);
        EnablePageUpDown();
    end
%%
    function filt_slider_Callback(~, ~)
        DATA.AnalysisParams.activeWin_startTime = get(GUI.Filt_RawDataSlider, 'Value');
        DATA.AnalysisParams.segment_startTime = DATA.AnalysisParams.activeWin_startTime;
        DATA.AnalysisParams.segment_endTime = DATA.AnalysisParams.activeWin_startTime + DATA.AnalysisParams.activeWin_length;
        
        str = calcDuration(DATA.AnalysisParams.activeWin_startTime, 0);
        set(GUI.Active_Window_Start, 'String', str);
        set(GUI.segment_startTime, 'String', str);
        set(GUI.segment_endTime, 'String', calcDuration(DATA.AnalysisParams.segment_endTime, 0));
        
        clear_statistics_plots();
        clearStatTables();
        calcBatchWinNum();
        plotFilteredData();
        plotMultipleWindows();
        if get(GUI.AutoCalc_checkbox, 'Value')
            calcStatistics();
        end
        set(GUI.blue_line, 'XData', [DATA.AnalysisParams.segment_startTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_startTime]);
    end
%%
    function filt_sldrFrame_Motion(~, ~)
        DATA.AnalysisParams.activeWin_startTime = get(GUI.Filt_RawDataSlider, 'Value');
        DATA.AnalysisParams.segment_startTime = DATA.AnalysisParams.activeWin_startTime;
        str = calcDuration(DATA.AnalysisParams.activeWin_startTime, 0);
        set(GUI.Active_Window_Start, 'String', str);
        set(GUI.segment_startTime, 'String', str);
        
        plotFilteredData();
        plotMultipleWindows();
        
        DATA.AnalysisParams.segment_effectiveEndTime = DATA.AnalysisParams.segment_startTime + DATA.AnalysisParams.activeWin_length + (DATA.AnalysisParams.winNum - 1) * (1 - DATA.AnalysisParams.segment_overlap/100) * DATA.AnalysisParams.activeWin_length;
        set(GUI.blue_line, 'XData', [DATA.AnalysisParams.segment_startTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_startTime]);
    end
%%
    function setAutoYAxisLimLowAxes(axes_xlim)
        filt_signal_data = DATA.filter_ma_nni(DATA.filter_ma_tnn >= min(axes_xlim) & DATA.filter_ma_tnn <= max(axes_xlim));
        if ~isempty(filt_signal_data)
            max_nni = max(filt_signal_data);
            min_nni = min(filt_signal_data);
            delta = (max_nni - min_nni) * 0.1;
            
            max_nni_60 = max(60 ./ filt_signal_data);
            min_nni_60 = min(60 ./ filt_signal_data);
            delta_60 = (max_nni_60 - min_nni_60) * 0.1;
            
            DATA.AutoYLimitLowAxes.RRMinYLimit = min(min_nni, max_nni) - delta;
            DATA.AutoYLimitLowAxes.RRMaxYLimit = max(min_nni, max_nni) + delta;
            
            DATA.AutoYLimitLowAxes.HRMinYLimit = min(min_nni_60, max_nni_60) - delta_60;
            DATA.AutoYLimitLowAxes.HRMaxYLimit = max(min_nni_60, max_nni_60) + delta_60;
            
            if ~DATA.PlotHR %== 0
                DATA.AutoYLimitLowAxes.MinYLimit = DATA.AutoYLimitLowAxes.RRMinYLimit;
                DATA.AutoYLimitLowAxes.MaxYLimit = DATA.AutoYLimitLowAxes.RRMaxYLimit;
            else
                DATA.AutoYLimitLowAxes.MinYLimit = DATA.AutoYLimitLowAxes.HRMinYLimit;
                DATA.AutoYLimitLowAxes.MaxYLimit = DATA.AutoYLimitLowAxes.HRMaxYLimit;
            end
        end
    end
%%
    function setAutoYAxisLimUpperAxes(firstSecond2Show, WindowSize)
        
        signal_data = DATA.rri(DATA.trr >= firstSecond2Show & DATA.trr <= firstSecond2Show + WindowSize);
        filt_signal_data = DATA.nni(DATA.tnn >= firstSecond2Show & DATA.tnn <= firstSecond2Show + WindowSize);
        
        if ~isempty(signal_data) && ~isempty(filt_signal_data)
            
            if length(signal_data) == length(filt_signal_data)
                DATA.AutoYLimitUpperAxes.RRMinYLimit = min(min(signal_data), max(signal_data));
                DATA.AutoYLimitUpperAxes.RRMaxYLimit = max(min(signal_data), max(signal_data));
                
                max_rri_60 = max(60 ./ signal_data);
                min_rri_60 = min(60 ./ signal_data);
                DATA.AutoYLimitUpperAxes.HRMinYLimit = min(min_rri_60, max_rri_60);
                DATA.AutoYLimitUpperAxes.HRMaxYLimit = max(min_rri_60, max_rri_60);
            else
                max_nni = max(filt_signal_data);
                min_nni = min(filt_signal_data);
                delta = (max_nni - min_nni)*1;
                
                DATA.AutoYLimitUpperAxes.RRMinYLimit = min(min_nni, max_nni) - delta;
                DATA.AutoYLimitUpperAxes.RRMaxYLimit = max(min_nni, max_nni) + delta;
                
                max_nni_60 = max(60 ./ filt_signal_data);
                min_nni_60 = min(60 ./ filt_signal_data);
                delta_60 = (max_nni_60 - min_nni_60)*1;
                
                DATA.AutoYLimitUpperAxes.HRMinYLimit = min(min_nni_60, max_nni_60) - delta_60;
                DATA.AutoYLimitUpperAxes.HRMaxYLimit = max(min_nni_60, max_nni_60) + delta_60;
            end
            
            if ~DATA.PlotHR % == 0
                MinYLimit = DATA.AutoYLimitUpperAxes.RRMinYLimit;
                MaxYLimit = DATA.AutoYLimitUpperAxes.RRMaxYLimit;
            else
                MinYLimit = DATA.AutoYLimitUpperAxes.HRMinYLimit;
                MaxYLimit = DATA.AutoYLimitUpperAxes.HRMaxYLimit;
            end
            DATA.AutoYLimitUpperAxes.MaxYLimit = MaxYLimit;
            DATA.AutoYLimitUpperAxes.MinYLimit = MinYLimit;
        end
    end
%%
    function YLimAxes = setYAxesLim(axes_handle, AutoScaleY_checkbox, min_val_gui_handle, max_val_gui_handle, YLimAxes, AutoYLimitAxes)
        
        if get(AutoScaleY_checkbox, 'Value') == 1
            YLimAxes.RRMinYLimit = AutoYLimitAxes.RRMinYLimit;
            YLimAxes.RRMaxYLimit = AutoYLimitAxes.RRMaxYLimit;
            YLimAxes.HRMinYLimit = AutoYLimitAxes.HRMinYLimit;
            YLimAxes.HRMaxYLimit = AutoYLimitAxes.HRMaxYLimit;
        end
        
        if ~DATA.PlotHR %== 0
            MinYLimit = min(YLimAxes.RRMinYLimit, YLimAxes.RRMaxYLimit);
            MaxYLimit = max(YLimAxes.RRMinYLimit, YLimAxes.RRMaxYLimit);
        else
            MinYLimit = min(YLimAxes.HRMinYLimit, YLimAxes.HRMaxYLimit);
            MaxYLimit = max(YLimAxes.HRMinYLimit, YLimAxes.HRMaxYLimit);
        end
        
        set(min_val_gui_handle, 'String', num2str(MinYLimit));
        set(max_val_gui_handle, 'String', num2str(MaxYLimit));
        
        YLimAxes.MaxYLimit = MaxYLimit;
        YLimAxes.MinYLimit = MinYLimit;
        
        try
            set(axes_handle, 'YLim', [MinYLimit MaxYLimit]);
        catch
        end
    end
%%
    function setXAxesLim()
        ha = GUI.RRDataAxes;
        
        set(ha, 'XLim', [DATA.firstSecond2Show DATA.firstSecond2Show + DATA.MyWindowSize]);
        setAxesXTicks(ha);
        
        blue_line_handle = get(GUI.all_data_handle);
        all_x = blue_line_handle.XData;
        
        window_size_in_data_points = size(find(all_x > DATA.firstSecond2Show & all_x < DATA.firstSecond2Show + DATA.MyWindowSize));
        
        if window_size_in_data_points < 350
            set(GUI.raw_data_handle, 'Marker', 'o', 'MarkerSize', 4, 'MarkerEdgeColor', [180 74 255]/255, 'MarkerFaceColor', [1, 1, 1]);
        else
            set(GUI.raw_data_handle, 'Marker', 'none');
        end
    end
%%
    function plotAllData()
        ha = GUI.AllDataAxes;
        if ~DATA.PlotHR  % == 0
            data =  DATA.rri;
        else
            data =  60 ./ DATA.rri;
        end
        
        GUI.all_data_handle = line(DATA.trr, data, 'Color', 'b', 'LineWidth', 1.5, 'Parent', ha, 'DisplayName', 'Hole time series'); % , 'Tag', 'DoNotIgnore', 'ButtonDownFcn', {@my_clickOnAllData, 'aa'}
        
        set(ha, 'XLim', [0 DATA.RRIntPage_Length]);
        
        % PLot red rectangle
        ylim = get(ha, 'YLim');
        x_box = [0 DATA.MyWindowSize DATA.MyWindowSize 0 0];
        y_box = [ylim(1) ylim(1) ylim(2) ylim(2) ylim(1)];
        
        if isfield(GUI, 'red_rect')
            delete(GUI.red_rect);
            GUI = rmfield(GUI, 'red_rect');
        end
        
        if isfield(GUI, 'blue_line')
            delete(GUI.blue_line);
            GUI = rmfield(GUI, 'blue_line');
        end
        
        x_segment_start = DATA.AnalysisParams.segment_startTime;
        x_segment_stop = DATA.AnalysisParams.segment_effectiveEndTime;
        y_segment_start = ylim(1);
        y_segment_stop = ylim(2);
        
        v = [x_segment_start y_segment_start; x_segment_stop y_segment_start; x_segment_stop y_segment_stop; x_segment_start y_segment_stop];
        f = [1 2 3 4];
        
        GUI.blue_line = patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.rectangle_color, 'EdgeColor', DATA.rectangle_color, 'LineWidth', 2, 'FaceAlpha', 0.3, 'EdgeAlpha', 0.9, 'Parent', ha); % , 'Marker', '^', 'MarkerSize', 7, 'MarkerFaceColor', DATA.rectangle_color, 'Linewidth', 2
        
        setAxesXTicks(ha);
        
        GUI.red_rect = line(x_box, y_box, 'Color', 'r', 'Linewidth', 3, 'Parent', ha);
        
        setAllowAxesZoom(DATA.zoom_handle, GUI.AllDataAxes, false);
    end
%%
    function plotRawData()
        ha = GUI.RRDataAxes;
        
        signal_time = DATA.trr;
        signal_data = DATA.rri;
        
        if (DATA.PlotHR == 0)
            data =  signal_data;
            yString = 'RR (sec)';
        else
            data =  60 ./ signal_data;
            yString = 'HR (BPM)';
        end
        
        GUI.raw_data_handle = plot(ha, signal_time, data, 'b-', 'LineWidth', 2, 'DisplayName', 'Time series');
        hold(ha, 'on');
        
        GUI.filtered_handle = line(ones(1, length(DATA.tnn))*NaN, ones(1, length(DATA.nni))*NaN, 'LineWidth', 1, 'Color', 'g', 'LineStyle', '-', 'DisplayName', 'Selected filtered time series', 'Parent', ha);
        
        xlabel(ha, 'Time (h:min:sec)');
        ylabel(ha, yString);
        
        DATA.legend_handle = legend(ha, 'show', 'Location', 'southeast', 'Orientation', 'horizontal');
        if sum(ismember(properties(DATA.legend_handle), 'AutoUpdate'))
            DATA.legend_handle.AutoUpdate = 'off';
            DATA.legend_handle.Box = 'off';
        end
        
        set(ha, 'XLim', [DATA.firstSecond2Show, DATA.firstSecond2Show + DATA.MyWindowSize]);
        
        setAllowAxesZoom(DATA.zoom_handle, GUI.RRDataAxes, false);
    end
%%
    function plotFilteredData()
        if isfield(DATA.AnalysisParams, 'segment_startTime')
            Filt_time_data = DATA.tnn;
            Filt_data = DATA.nni;
            
            filt_win_indexes = find(Filt_time_data >= DATA.AnalysisParams.segment_startTime & Filt_time_data <= DATA.AnalysisParams.segment_effectiveEndTime);
            
            if ~isempty(filt_win_indexes)
                
                filt_signal_time = Filt_time_data(filt_win_indexes(1) : filt_win_indexes(end));
                filt_signal_data = Filt_data(filt_win_indexes(1) : filt_win_indexes(end));
                
                if (DATA.PlotHR == 0)
                    filt_data =  filt_signal_data;
                else
                    filt_data =  60 ./ filt_signal_data;
                end
                filt_data_time = ones(1, length(DATA.tnn))*NaN;
                filt_data_vector = ones(1, length(DATA.nni))*NaN;
                
                filt_data_time(filt_win_indexes) = filt_signal_time;
                filt_data_vector(filt_win_indexes) = filt_data;
                
                set(GUI.filtered_handle, 'XData', filt_data_time, 'YData', filt_data_vector);
            end
        end
    end
%%
    function plotDataQuality()
        if ~isempty(DATA.QualityAnnotations_Data)
            if ~isempty(DATA.rri)
                ha = GUI.RRDataAxes;
                MaxYLimit = DATA.YLimUpperAxes.MaxYLimit;
                time_data = DATA.trr;
                data = DATA.rri;
                
                qd_size = size(DATA.QualityAnnotations_Data);
                intervals_num = qd_size(1);
                
                if (DATA.PlotHR == 1)
                    data = 60 ./ data;
                end
                
                if ~isfield(GUI, 'GreenLineHandle') || ~isvalid(GUI.GreenLineHandle)
                    GUI.GreenLineHandle = line([DATA.firstSecond2Show DATA.firstSecond2Show + DATA.MyWindowSize], [MaxYLimit MaxYLimit], 'Color', DATA.MyGreen, 'LineWidth', 3, 'Parent', ha);
                else
                    GUI.GreenLineHandle.XData = [DATA.firstSecond2Show DATA.firstSecond2Show + DATA.MyWindowSize];
                    GUI.GreenLineHandle.YData = [MaxYLimit MaxYLimit];
                end
                uistack(GUI.GreenLineHandle, 'down')
                %---------------------------------
                
                if ~(DATA.QualityAnnotations_Data(1, 1) + DATA.QualityAnnotations_Data(1,2))==0
                    
                    if ~isfield(GUI, 'RedLineHandle') || ~isvalid(GUI.RedLineHandle(1))
                        %                         GUI.RedLineHandle = line((DATA.QualityAnnotations_Data-time_data(1))', [MaxYLimit MaxYLimit]', 'Color', 'red', 'LineWidth', 3, 'Parent', ha);
                        GUI.RedLineHandle = line((DATA.QualityAnnotations_Data)', [MaxYLimit MaxYLimit]', 'Color', 'red', 'LineWidth', 3, 'Parent', ha);
                        uistack(GUI.RedLineHandle, 'top');
                    else
                        for i = 1 : intervals_num
                            GUI.RedLineHandle(i).XData = (DATA.QualityAnnotations_Data(i, :))';
                            GUI.RedLineHandle(i).YData = [MaxYLimit MaxYLimit]';
                        end
                    end
                    
                    for i = 1 : intervals_num
                        a1=find(time_data >= DATA.QualityAnnotations_Data(i,1));
                        a2=find(time_data <= DATA.QualityAnnotations_Data(i,2));
                        
                        if isempty(a2); a2 = 1; end % case where the bad quality starts before the first annotated peak
                        if isempty(a1); a1 = length(time_data); end
                        if length(a1)<2
                            low_quality_indexes = [a2(end) : a1(1)];
                        elseif a2(end) == 1
                            low_quality_indexes = [1 : a1(1)];
                        elseif a2(end) < a1(1)
                            low_quality_indexes = [a2(end)-1 : a1(1)];
                        else
                            low_quality_indexes = [a1(1)-1 : a2(end)+1];
                        end
                        
                        if ~isempty(low_quality_indexes)
                            %                             GUI.PinkLineHandle(i) = line(time_data(low_quality_indexes), data(low_quality_indexes), 'LineStyle', '-', 'Color', [255 157 189]/255, 'LineWidth', 2.5, 'Parent', ha);
                            GUI.PinkLineHandle(i) = line(time_data(low_quality_indexes), data(low_quality_indexes), 'LineStyle', '-', 'Color', DATA.quality_color{DATA.quality_class_ind(i)}, 'LineWidth', 2.5, 'Parent', ha);
                            if isvalid(DATA.legend_handle) && length(DATA.legend_handle.String) < 3 %
                                legend([GUI.raw_data_handle, GUI.filtered_handle GUI.PinkLineHandle(1)], [DATA.legend_handle.String 'Bad quality']);
                            end
                        end
                    end
                end
            end
        end
        setAllowAxesZoom(DATA.zoom_handle, GUI.RRDataAxes, false);
    end
%%
    function onOpenDataQualityFile(~, ~)
        
        set_defaults_path();
        
        [DataQuality_FileName, PathName] = uigetfile({'*.*', 'All files';...
            '*.txt','Text Files (*.txt)'
            '*.mat','MAT-files (*.mat)'}, ...
            'Open Data-Quality-Annotations File', [DIRS.dataQualityDirectory filesep '*.' DIRS.Ext_open]);
        
        %         '*.sqi',  'WFDB Files (*.sqi)'
        
        if ~isequal(DataQuality_FileName, 0)
            
            [~, QualityFileName, ExtensionFileName] = fileparts(DataQuality_FileName);
            ExtensionFileName = ExtensionFileName(2:end);
            
            DIRS.dataQualityDirectory = PathName;
            DIRS.Ext_open = ExtensionFileName;
            
            if strcmpi(ExtensionFileName, 'mat')
                QualityAnnotations = load([PathName DataQuality_FileName]);
                QualityAnnotations_field_names = fieldnames(QualityAnnotations);
                
                %                 QualityAnnotations_field_names_number = length(QualityAnnotations_field_names);
                %                 i = 1;
                %                 QualityAnnotations_Data = [];
                %                 while i <= QualityAnnotations_field_names_number
                %                     if ~isempty(regexpi(QualityAnnotations_field_names{i}, 'signal_quality')) % Quality_anns|quality_anno
                %                         QualityAnnotations_Data = QualityAnnotations.(QualityAnnotations_field_names{i});
                %                         break;
                %                     end
                %                     i = i + 1;
                %                 end
                
                
                QualityAnnotations_Data = [];
                type = [];
                %                 source_file_name = '';
                
                for i = 1 : length(QualityAnnotations_field_names)
                    if ~isempty(regexpi(QualityAnnotations_field_names{i}, 'signal_quality')) % Quality_anns|quality_anno
                        QualityAnnotations_Data = QualityAnnotations.(QualityAnnotations_field_names{i});
                    elseif ~isempty(regexpi(QualityAnnotations_field_names{i}, 'class'))
                        Class = QualityAnnotations.(QualityAnnotations_field_names{i});
                    elseif ~isempty(regexpi(QualityAnnotations_field_names{i}, 'type'))
                        type = QualityAnnotations.(QualityAnnotations_field_names{i});
                        %                     elseif ~isempty(regexpi(QualityAnnotations_field_names{i}, 'source_file_name'))
                        %                         source_file_name = QualityAnnotations.(QualityAnnotations_field_names{i});
                    end
                end
                
                
                
                if ~isempty(QualityAnnotations_Data) && strcmpi(type, 'quality annotation')
                    DATA.QualityAnnotations_Data = QualityAnnotations_Data;
                else
                    errordlg('Please, choose the Data Quality Annotations File.', 'Input Error');
                    return;
                end
                if ~isempty(Class)
                    DATA_Class = Class;
                end
                %             elseif strcmpi(ExtensionFileName, 'sqi') % strcmpi(ExtensionFileName, 'qrs') || strcmpi(ExtensionFileName, 'atr')
                %                 if DATA.SamplingFrequency ~= 0
                % %                     quality_data = rdann( [PathName QualityFileName], ExtensionFileName, 'ann_types', '"F"')/DATA.SamplingFrequency;
                %                     quality_data = rdann( [PathName QualityFileName], ExtensionFileName)/DATA.SamplingFrequency;
                %                     DATA.QualityAnnotations_Data = [quality_data(1:2:end), quality_data(2:2:end)];
                %                 else
                %                     errordlg('Cann''t get sampling frequency.', 'Input Error');
                %                     return;
                %                 end
            elseif strcmpi(ExtensionFileName, 'txt')
                file_name = [PathName DataQuality_FileName];
                fileID = fopen(file_name);
                if fileID ~= -1
                    quality_data = textscan(fileID, '%f %f %s', 'Delimiter', '\t', 'HeaderLines', 7);
                    
                    frewind(fileID);
                    
                    tline1 = fgetl(fileID);
                    tline2 = fgetl(fileID);
                    type_line = strsplit(tline2, ': ');
                    
                    if strcmp(tline1, '---') && strcmp(type_line{1}, 'type') && strcmp(type_line{2}, 'quality annotation')
                        if ~isempty(quality_data{1}) && ~isempty(quality_data{2}) && ~isempty(quality_data{3})
                            DATA.QualityAnnotations_Data = [cell2mat(quality_data(1)) cell2mat(quality_data(2))];
                            class = quality_data(3);
                            DATA_Class = class{1};
                        else
                            errordlg('Please, choose the Data Quality Annotations File.', 'Input Error');
                            return;
                        end
                    else
                        errordlg('Please, choose the right format for Data Quality Annotations File.', 'Input Error');
                        return;
                    end
                    fclose(fileID);
                else
                    return;
                end
            else
                errordlg('Please, choose only *.mat or *.txt file.', 'Input Error');
                return;
            end
            set(GUI.DataQuality_text, 'String', DataQuality_FileName);
            
            if isfield(GUI, 'GreenLineHandle')
                delete(GUI.GreenLineHandle);
                GUI = rmfield(GUI, 'GreenLineHandle');
            end
            if isfield(GUI, 'RedLineHandle')
                delete(GUI.RedLineHandle);
                GUI = rmfield(GUI, 'RedLineHandle');
            end
            if isfield(GUI, 'PinkLineHandle')
                delete(GUI.PinkLineHandle);
                GUI = rmfield(GUI, 'PinkLineHandle');
            end
            
            total_class_ind = ones(1, length(DATA_Class)) * 3;
            for i = 1 : length(DATA_Class)
                [is_member, class_ind] = ismember(DATA_Class{i}, DATA.GUI_Class);
                if is_member
                    total_class_ind(i) = class_ind;
                end
            end
            
            DATA.quality_class_ind = total_class_ind;
            
            plotDataQuality();
        end
    end
%%
    function [mammal, mammal_index] = set_mammal(mammal)
        %         DATA.mammal = mammal;
        if strcmpi(mammal, 'rabbit')
            %             DATA.mammal = 'rabbit';
            mammal = 'rabbit';
        elseif ~isempty(regexpi(mammal, 'mice|mouse'))
            %             DATA.mammal = 'mouse';
            mammal = 'mouse';
        elseif ~isempty(regexpi(mammal, 'dog|dogs|canine'))
            %             DATA.mammal = 'dog';
            mammal = 'dog';
        end
        %         DATA.mammal_index = find(strcmp(DATA.mammals, DATA.mammal));
        mammal_index = find(strcmp(DATA.mammals, mammal));
        %         if mammal_index == 0 % DATA.mammal_index == 0
        % %             DATA.mammal_index = 1;
        %             mammal_index = 1;
        % %             DATA.mammal = 'human';
        %             mammal = 'human';
        %         end
    end
%%
    function [mammal, mammal_index, integration, isM1] = Load_Data_from_SingleFile(QRS_FileName, PathName, waitbar_handle)
        if QRS_FileName
            [files_num, ~] = size(QRS_FileName);
            if files_num == 1
                
                [~, DataFileName, ExtensionFileName] = fileparts(QRS_FileName);
                
                ExtensionFileName = ExtensionFileName(2:end);
                
                DIRS.dataDirectory = PathName;
                DIRS.Ext_open = ExtensionFileName;
                
                integration = '';
                mammal = '';
                mammal_index = '';
                
                %                 if strcmpi(ExtensionFileName, 'mat')
                %                     QRS = load([PathName QRS_FileName]);
                %                     QRS_field_names = fieldnames(QRS);
                %                     QRS_data = [];
                %                     for i = 1 :  length(QRS_field_names)
                %                         curr_field = QRS.(QRS_field_names{i});
                %                         if ~isempty(regexpi(QRS_field_names{i}, 'qrs|data'))
                %                             QRS_data = curr_field;
                %                         elseif strcmpi(QRS_field_names{i}, 'mammal')  % ~isempty(regexpi(QRS_field_names{i}, 'mammal'))
                %                             mammal = curr_field;
                %                             [mammal, mammal_index] = set_mammal(mammal);
                %                         elseif strcmpi(QRS_field_names{i}, 'Fs')   %~isempty(regexpi(QRS_field_names{i}, 'Fs'))
                %                             DATA.SamplingFrequency = curr_field;
                %                         elseif strcmpi(QRS_field_names{i}, 'Integration')  %~isempty(regexpi(QRS_field_names{i}, 'Integration'))
                %                             %                             DATA.Integration = curr_field;
                %                             integration = curr_field;
                %                         end
                %                     end
                %                     time_data = 0;
                %                 if strcmpi(ExtensionFileName, 'qrs') % || strcmpi(ExtensionFileName, 'atr') atr - for quality; qrs - for annotations (peaks)
                %
                %                         [ ~, Fs, ~ ] = get_signal_channel( [PathName DATA.DataFileName] );
                %                         DATA.SamplingFrequency = Fs;
                %                         [mammal, integration] = get_description_from_wfdb_header([PathName DATA.DataFileName]);
                %                         [mammal, mammal_index] = set_mammal(mammal);
                %                         %                         if ~isempty(integration)
                %                         %                             DATA.Integration = integration;
                %                         %                         end
                %                     try
                %                         QRS_data = rdann([PathName DATA.DataFileName], ExtensionFileName); % atr qrs
                %                     catch
                %                         close(waitbar_handle);
                %                         throw(MException('LoadFile:text', 'Cann''t read file.'));
                %                     end
                %                     time_data = 0;
                if strcmpi(ExtensionFileName, 'txt') || strcmpi(ExtensionFileName, 'mat') || strcmpi(ExtensionFileName, 'qrs') || strcmpi(ExtensionFileName, 'atr') || strcmpi(ExtensionFileName, 'dat')
                    
                    
                    Config = ReadYaml('Loader Config.yml');
                    
                    DataFileMap = loadDataFile([PathName QRS_FileName]);
                    MSG = DataFileMap('MSG');
                    if strcmp(Config.alarm.(MSG), 'OK')
                        data = DataFileMap('DATA');
                        if ~strcmp(data.Data.Type, 'electrography')
                            
                            clearData();
                            clear_statistics_plots();
                            clearStatTables();
                            clean_gui();
                            
                            DATA.DataFileName = DataFileName;
                            
                            mammal = data.General.mammal;
                            [mammal, mammal_index] = set_mammal(mammal);
                            integration = data.General.integration_level;
                            DATA.SamplingFrequency = data.Time.Fs;
                            QRS_data = data.Data.Data;
                            time_data = data.Time.Data;
                            isM1 = 0;
                        else
                            if isvalid(waitbar_handle)
                                close(waitbar_handle);
                            end
                            choice = questdlg('This recording contains raw electrophysiological data. It will be opened in the peak detection module.', ...
                                'Select module', 'OK', 'Cancel', 'OK');
                            
                            switch choice
                                case 'OK'
                                    %throw(MException('LoadFile:text', 'Please, choose another file type.'));
                                    fileNameFromM2.FileName = QRS_FileName;
                                    fileNameFromM2.PathName = PathName;
                                    PhysioZooGUI_PeakDetection(fileNameFromM2);
                                    isM1 = 1;
                                    return;
                                case 'Cancel'
                                    isM1 = 1;
                                    return;
                            end
                        end
                    else
                        throw(MException('LoadFile:text', Config.alarm.(MSG)));
                    end
                    %                     file_name = [PathName DATA.DataFileName '.txt'];
                    %                     fileID = fopen(file_name, 'r');
                    %                     if fileID ~= -1
                    %                         %                         mammal = fscanf(fileID, '%*s %s', 1);
                    %                         Mammal = fscanf(fileID, '%s', 1);
                    %                         if ~isempty(regexpi(Mammal, 'mammal'))
                    %                             mammal = fscanf(fileID, '%s', 1);
                    %                             [mammal, mammal_index] = set_mammal(mammal);
                    %                             DATA.SamplingFrequency = fscanf(fileID, '%*s %d', 1);
                    %                             %                         DATA.Integration = fscanf(fileID, '%*s %s', 1);
                    %                             integration = fscanf(fileID, '%*s %s', 1);
                    %                             if strcmpi(integration, 'AP') || strcmpi(integration, 'Action') % strcmpi(DATA.Integration, 'AP') || strcmpi(DATA.Integration, 'Action')
                    %                                 %                             DATA.Integration = 'Action Potential';
                    %                                 integration = 'Action Potential';
                    %                             end
                    %                             QRS_data = dlmread(file_name,' ', 4, 0);
                    %                         else
                    %                             QRS_data = dlmread(file_name,' ', 0, 0);
                    %                         end
                    %                         fclose(fileID);
                    %                     end
                else
                    close(waitbar_handle);
                    throw(MException('LoadFile:text', 'Please, choose another file type.'));
                end
                
                %                 if isempty(DATA.SamplingFrequency)
                %                     prompt = {'Please, enter Sampling Frequency:'};
                %                     dlg_title = 'Input';
                %                     num_lines = 1;
                %                     defaultans = {''};
                %                     answer = inputdlg(prompt, dlg_title, num_lines, defaultans);
                %
                %                     if ~isempty(answer)
                %                         DATA.SamplingFrequency = str2double(answer{1});
                %                         if ~isnan(DATA.SamplingFrequency)
                %                             set_qrs_data(QRS_data, time_data);
                %                         else
                %                             close(waitbar_handle);
                %                             throw(MException('LoadFile:SamplingFrequency', 'Please, enter valid SamplingFrequency!'));
                %                         end
                %                     else
                %                         close(waitbar_handle);
                %                         throw(MException('LoadFile:SamplingFrequency', 'Please, enter SamplingFrequency!'));
                %                     end
                %                 else
                set_qrs_data(QRS_data, time_data);
                %                 end
            end
        end
    end
%%
    function set_qrs_data(QRS_data, time_data)
        if time_data == 0
            if ~isempty(QRS_data) && sum(QRS_data > 0)
                % Convert indices to double so we can do calculations on them
                QRS_data = double(QRS_data);
                DATA.rri = diff(QRS_data)/DATA.SamplingFrequency;
                DATA.trr = QRS_data(1:end-1)/DATA.SamplingFrequency; % moving first peak at zero ms
            else
                close(waitbar_handle);
                throw(MException('LoadFile:Data', 'Could not Load the file. Please, choose the file with the QRS data and positive values'));
            end
        else
            DATA.rri = double(QRS_data);
            DATA.trr = time_data;
        end
    end
%%
%     function Set_MammalIntegration_After_Load()
%         GUI.Mammal_popupmenu.Value = DATA.mammal_index;
%         GUI.Integration_popupmenu.Value = DATA.integration_index;
%     end
%%
    function onOpenFile(~, ~, fileNameFromM1)
        if nargin < 3
            set_defaults_path();
            
            [QRS_FileName, PathName] = uigetfile({'*.*', 'All files';...
                '*.txt','Text Files (*.txt)'
                '*.mat','MAT-files (*.mat)'; ...
                '*.qrs; *.atr', 'WFDB Files (*.qrs; *.atr)'}, ...
                'Open QRS File', [DIRS.dataDirectory filesep '*.' DIRS.Ext_open]);
        else
            QRS_FileName = fileNameFromM1.FileName;
            PathName = fileNameFromM1.PathName;
        end
        try
            Load_Single_File(QRS_FileName, PathName);
        catch e
            errordlg(['onOpenFile: ' e.message], 'Input Error');
        end
    end
%%
    function Load_Single_File(QRS_FileName, PathName)
        if QRS_FileName
            [files_num, ~] = size(QRS_FileName);
            if files_num == 1
                %                 clearData();
                %                 clear_statistics_plots();
                %                 clearStatTables();
                %                 clean_gui();
                try
                    waitbar_handle = waitbar(1/2, 'Loading data', 'Name', 'Working on it...');
                    [mammal, mammal_index, integration, whichModule] = Load_Data_from_SingleFile(QRS_FileName, PathName, waitbar_handle);
                    if whichModule == 1
                        if isvalid(waitbar_handle)
                            close(waitbar_handle);
                        end
                        return;
                    end
                catch e
                    if isvalid(waitbar_handle)
                        close(waitbar_handle);
                    end
                    errordlg(['Load Single File error: ' e.message], 'Input Error');
                    clean_gui();
                    cla(GUI.RRDataAxes);
                    cla(GUI.AllDataAxes);
                    return;
                end
                
                if isempty(integration) || strcmp(integration, 'electrocardiogram')
                    integration = 'ECG';
                end
                
                if isempty(mammal) || isempty(DATA.mammal) || (~strcmp(mammal, DATA.mammal) || ~strcmp(integration, DATA.Integration))
                    if isempty(mammal_index) || ~mammal_index
                        mammal_index = 1;
                        mammal = 'human (task force)';
                    end
                    DATA.mammal = mammal;
                    DATA.mammal_index = mammal_index;
                    GUI.Mammal_popupmenu.Value = DATA.mammal_index;
                    
                    DATA.Integration = integration;
                    DATA.integration_index = find(strcmpi(DATA.GUI_Integration, DATA.Integration));
                    GUI.Integration_popupmenu.Value = DATA.integration_index;
                    
                    try
                        mhrv_load_defaults(DATA.mammals{DATA.mammal_index});
                    catch e
                        errordlg(['mhrv_load_defaults: ' e.message], 'Input Error');
                        if isvalid(waitbar_handle)
                            close(waitbar_handle);
                        end
                        return;
                    end
                    waitbar(2 / 2, waitbar_handle, 'Create Config Parameters Windows');
                    createConfigParametersInterface();
                    close(waitbar_handle);
                else
                    close(waitbar_handle);
                end
                
                reset_plot_Data();
                reset_plot_GUI();
                EnablePageUpDown();
                
                if isfield(GUI, 'RRDataAxes')
                    PathName = strrep(PathName, '\', '\\');
                    PathName = strrep(PathName, '_', '\_');
                    QRS_FileName_title = strrep(QRS_FileName, '_', '\_');
                    
                    TitleName = [PathName QRS_FileName_title] ;
                    title(GUI.RRDataAxes, TitleName, 'FontWeight', 'normal', 'FontSize', DATA.SmallFontSize);
                    
                    set(GUI.RecordName_text, 'String', QRS_FileName);
                end
                set(GUI.DataQualityMenu, 'Enable', 'on');
                set(GUI.SaveMeasures, 'Enable', 'on');
                set(GUI.SaveFiguresAsMenu, 'Enable', 'on');
                set(GUI.SaveParamFileMenu, 'Enable', 'on');
                set(GUI.LoadConfigFile, 'Enable', 'on');
            end
        end
    end
% %%
%     function [mammal, intg] = get_description_integration(rec_name)
%         fheader = fopen([rec_name, '.hea']);
%         fgetl(fheader);
%         line = fgetl(fheader);
%         record_line = strsplit(line, ' ');
%         str = strsplit(record_line{end}, '-');
%         if length(str) >= 2
%             intg = str{1};
%             mammal = str{2};
%         else % not our description
%             intg = '';
%             mammal = '';
%         end
%         fclose(fheader);
%     end
%%
%     function stat_data_cell = str2cellStatisticsParam(stat_struct)
%
%         stat_struct_names = fieldnames(stat_struct);
%         str_names_num = length(stat_struct_names);
%
%         stat_data_cell = cell(str_names_num, 1);
%
%         for i = 1 : str_names_num
%             stat_data_cell{i, 1} = stat_struct.(stat_struct_names{i});
%         end
%     end
%%
    function [stat_data_cell, stat_row_names_cell, stat_descriptions_cell] = table2cell_StatisticsParam(stat_table)
        
        variables_num = length(stat_table.Properties.VariableNames);
        stat_data_cell = cell(variables_num, 1);
        stat_row_names_cell = cell(variables_num, 1);
        stat_descriptions_cell = cell(variables_num, 1);
        
        table_properties = stat_table.Properties;
        for i = 1 : variables_num
            var_name = table_properties.VariableNames{i};
            if length(stat_table.(var_name)) == 1
                stat_data_cell{i, 1} = sprintf('%.2f', stat_table.(var_name));
            else
                stat_data_cell{i, 1} = sprintf('%.2f\x00B1%.2f', stat_table.(var_name)(1), stat_table.(var_name)(2));
            end
            stat_row_names_cell{i, 1} = [var_name ' (' table_properties.VariableUnits{i} ')'];
            stat_descriptions_cell{i, 1} = table_properties.VariableDescriptions{i};
        end
    end
%%
    function updateTimeStatistics()
        GUI.TimeParametersTableRowName = [GUI.TimeParametersTableRowName; GUI.FragParametersTableRowName];
        GUI.TimeParametersTableData = [GUI.TimeParametersTableData; GUI.FragParametersTableData];
        GUI.TimeParametersTable.Data = [GUI.TimeParametersTable.Data; GUI.FragParametersTable.Data];
    end
%%
    function clear_statistics_plots()
        clear_time_statistics_results();
        clear_frequency_statistics_results();
        clear_nonlinear_statistics_results();
    end
%%
    function clear_time_statistics_results()
        grid(GUI.TimeAxes1, 'off');
        legend(GUI.TimeAxes1, 'off')
        cla(GUI.TimeAxes1);
    end
%%
    function clear_frequency_statistics_results()
        grid(GUI.FrequencyAxes1, 'off');
        grid(GUI.FrequencyAxes2, 'off');
        legend(GUI.FrequencyAxes1, 'off');
        legend(GUI.FrequencyAxes2, 'off');
        cla(GUI.FrequencyAxes1);
        cla(GUI.FrequencyAxes2);
    end
%%
    function clear_nonlinear_statistics_results()
        grid(GUI.NonLinearAxes1, 'off');
        grid(GUI.NonLinearAxes2, 'off');
        grid(GUI.NonLinearAxes3, 'off');
        
        legend(GUI.NonLinearAxes1, 'off');
        legend(GUI.NonLinearAxes2, 'off');
        legend(GUI.NonLinearAxes3, 'off');
        
        cla(GUI.NonLinearAxes1);
        cla(GUI.NonLinearAxes2);
        cla(GUI.NonLinearAxes3);
    end
%%
    function plot_time_statistics_results(active_window)
        
        clear_time_statistics_results();
        plot_data = DATA.TimeStat.PlotData{active_window};
        
        if ~isempty(plot_data)
            plot_hrv_time_hist(GUI.TimeAxes1, plot_data, 'clear', true);
        end
        box(GUI.TimeAxes1, 'off' );
        setAllowAxesZoom(DATA.zoom_handle, GUI.TimeAxes1, false);
    end
%%
    function plot_frequency_statistics_results(active_window)
        
        clear_frequency_statistics_results();
        
        plot_data = DATA.FrStat.PlotData{active_window};
        
        if ~isempty(plot_data)
            plot_hrv_freq_spectrum(GUI.FrequencyAxes1, plot_data, 'detailed_legend', false, 'yscale', DATA.freq_yscale);
            plot_hrv_freq_beta(GUI.FrequencyAxes2, plot_data);
        end
        box(GUI.FrequencyAxes1, 'off' );
        box(GUI.FrequencyAxes2, 'off' );
        setAllowAxesZoom(DATA.zoom_handle, GUI.FrequencyAxes2, false);
    end
%%
    function plot_nonlinear_statistics_results(active_window)
        
        clear_nonlinear_statistics_results();
        
        plot_data = DATA.NonLinStat.PlotData{active_window};
        
        if ~isempty(plot_data)
            plot_dfa_fn(GUI.NonLinearAxes1, plot_data.dfa);
            plot_mse(GUI.NonLinearAxes3, plot_data.mse);
            plot_poincare_ellipse(GUI.NonLinearAxes2, plot_data.poincare);
        end
        box(GUI.NonLinearAxes1, 'off' );
        box(GUI.NonLinearAxes2, 'off' );
        box(GUI.NonLinearAxes3, 'off' );
        setAllowAxesZoom(DATA.zoom_handle, [GUI.NonLinearAxes1, GUI.NonLinearAxes2, GUI.NonLinearAxes3], false);
    end
%%
    function set_default_analysis_params()
        DATA.DEFAULT_AnalysisParams.segment_startTime = 0;
        DATA.DEFAULT_AnalysisParams.activeWin_startTime = 0;
        DATA.DEFAULT_AnalysisParams.segment_endTime = DATA.Filt_MyDefaultWindowSize; % DATA.Filt_MaxSignalLength
        DATA.DEFAULT_AnalysisParams.segment_effectiveEndTime = DATA.DEFAULT_AnalysisParams.segment_endTime;
        DATA.DEFAULT_AnalysisParams.activeWin_length = min(DATA.Filt_MaxSignalLength, DATA.Filt_MyDefaultWindowSize);
        DATA.DEFAULT_AnalysisParams.segment_overlap = 0;
        DATA.DEFAULT_AnalysisParams.winNum = 1;
        DATA.active_window = 1;
        
        DATA.AnalysisParams = DATA.DEFAULT_AnalysisParams;
    end
%%
    function set_default_values()
        if ~isempty(DATA.rri)
            DATA.default_frequency_method_index = 1;
            
            DATA.prev_point = 0;
            DATA.prev_point_segment = 0;
            DATA.prev_point_blue_line = 0;
            DATA.doCalc = false;
            
            %             trr = DATA.trr;
            DATA.maxSignalLength = DATA.trr(end);
            DATA.RRIntPage_Length = DATA.maxSignalLength;
            
            DATA.Filt_MyDefaultWindowSize = mhrv_get_default('hrv_freq.window_minutes', 'value') * 60; % min to sec
            
            DATA.PlotHR = 0;
            DATA.firstSecond2Show = 0;
            % Show only 6*hrv_freq.window_minutes portion of the raw data
            DATA.MyWindowSize = min(3 * DATA.Filt_MyDefaultWindowSize, DATA.maxSignalLength); % 6
            
            DATA.filter_level_index = DATA.default_filter_level_index;
            
            DATA.WinAverage = 0;
            
            DATA.freq_yscale = 'linear';
        end
    end
%%
    function reset_plot_Data()
        
        if ~isempty(DATA.rri)
            
            set_default_values();
            
            try
                % Only for calc min and max bounderies for plotting
                FiltSignal('filter_quotient', false, 'filter_ma', true, 'filter_range', false);
                
                DATA.filter_ma_nni = DATA.nni;
                DATA.filter_ma_tnn = DATA.tnn;
                
                setAutoYAxisLimUpperAxes(DATA.firstSecond2Show, DATA.MyWindowSize);
                
                if DATA.filter_index ~= 1 % Moving average
                    FiltSignal();
                end
                
                DATA.Filt_MaxSignalLength = DATA.tnn(end);
                
                set_default_analysis_params();
                
                setAutoYAxisLimLowAxes([0 DATA.Filt_MaxSignalLength]);
                
                DATA.YLimUpperAxes.RRMinYLimit = DATA.AutoYLimitUpperAxes.RRMinYLimit;
                DATA.YLimUpperAxes.RRMaxYLimit = DATA.AutoYLimitUpperAxes.RRMaxYLimit;
                DATA.YLimUpperAxes.HRMinYLimit = DATA.AutoYLimitUpperAxes.HRMinYLimit;
                DATA.YLimUpperAxes.HRMaxYLimit = DATA.AutoYLimitUpperAxes.HRMaxYLimit;
                
                DATA.YLimUpperAxes.MaxYLimit = 0;
                DATA.YLimUpperAxes.MinYLimit = 0;
                
                DATA.YLimLowAxes.RRMinYLimit = DATA.AutoYLimitLowAxes.RRMinYLimit;
                DATA.YLimLowAxes.RRMaxYLimit = DATA.AutoYLimitLowAxes.RRMaxYLimit;
                DATA.YLimLowAxes.HRMinYLimit = DATA.AutoYLimitLowAxes.HRMinYLimit;
                DATA.YLimLowAxes.HRMaxYLimit = DATA.AutoYLimitLowAxes.HRMaxYLimit;
                DATA.YLimLowAxes.MaxYLimit = DATA.AutoYLimitLowAxes.MaxYLimit;
                DATA.YLimLowAxes.MinYLimit = DATA.AutoYLimitLowAxes.MinYLimit;
                
                clear_statistics_plots();
                clearStatTables();
                
                calcStatistics();
            catch e
                errordlg(['Reset Plot: ' e.message], 'Input Error');
            end
        end
    end % reset Data
%%
    function reset_plot_GUI()
        
        if ~isempty(DATA.rri)
            
            set(GUI.AutoScaleYUpperAxes_checkbox, 'Value', 1);
            set(GUI.AutoScaleYLowAxes_checkbox, 'Value', 1);
            
            set(GUI.ShowLegend_checkbox, 'Value', 1);
            set(GUI.AutoCalc_checkbox, 'Value', 1);
            GUI.AutoCompute_pushbutton.Enable = 'off';
            GUI.WinAverage_checkbox.Value = 0;
            
            GUI.DefaultMethod_popupmenu.Value = DATA.default_frequency_method_index;
            
            if DATA.MyWindowSize == DATA.maxSignalLength
                enable_slider = 'off';
                set(GUI.FirstSecond, 'Enable', 'off');
            else
                enable_slider = 'on';
                set(GUI.FirstSecond, 'Enable', 'on');
            end
            
            GUI.FilteringLevel_popupmenu.Enable = 'on';
            
            GUI.FilteringLevel_popupmenu.String = DATA.FilterLevel;
            set(GUI.FilteringLevel_popupmenu, 'Value', DATA.default_filter_level_index);
            
            setSliderProperties(GUI.RawDataSlider, DATA.maxSignalLength, DATA.MyWindowSize, 0.1);
            GUI.RawDataSlider.Enable = enable_slider;
            
            try
                set(GUI.freq_yscale_Button, 'String', 'Log');
                set(GUI.freq_yscale_Button, 'Value', 1);
                
                set(GUI.segment_startTime, 'String', calcDuration(DATA.DEFAULT_AnalysisParams.segment_startTime, 0));
                set(GUI.segment_endTime, 'String', calcDuration(DATA.DEFAULT_AnalysisParams.segment_endTime, 0));
                set(GUI.activeWindow_length, 'String', calcDuration(DATA.DEFAULT_AnalysisParams.activeWin_length, 0));
                set(GUI.segment_overlap, 'String', num2str(DATA.DEFAULT_AnalysisParams.segment_overlap));
                set(GUI.segment_winNum, 'String', num2str(DATA.DEFAULT_AnalysisParams.winNum));
                set(GUI.active_winNum, 'String', '1');
                
                if isfield(DATA, 'legend_handle') && ishandle(DATA.legend_handle) && isvalid(DATA.legend_handle)
                    delete(DATA.legend_handle);
                end
                
                cla(GUI.RRDataAxes);
                cla(GUI.AllDataAxes);
                
                plotAllData();
                plotRawData();
                setXAxesLim();
                
                DATA.YLimUpperAxes = setYAxesLim(GUI.RRDataAxes, GUI.AutoScaleYUpperAxes_checkbox, GUI.MinYLimitUpperAxes_Edit, GUI.MaxYLimitUpperAxes_Edit, DATA.YLimUpperAxes, DATA.AutoYLimitUpperAxes);
                DATA.YLimLowAxes = setYAxesLim(GUI.AllDataAxes, GUI.AutoScaleYLowAxes_checkbox, GUI.MinYLimitLowAxes_Edit, GUI.MaxYLimitLowAxes_Edit, DATA.YLimLowAxes, DATA.AutoYLimitLowAxes);
                
                set_rectangles_YData();
                
                plotFilteredData();
                plotDataQuality();
                plotMultipleWindows();
                
                setSliderProperties(GUI.Filt_RawDataSlider, DATA.Filt_MaxSignalLength, DATA.AnalysisParams.activeWin_length, DATA.AnalysisParams.activeWin_length/DATA.Filt_MaxSignalLength);
                
                set(GUI.Filt_RawDataSlider, 'Enable', 'on');
                set(GUI.Active_Window_Length, 'String', calcDuration(DATA.AnalysisParams.activeWin_length, 0));
                
                set(GUI.MinYLimitUpperAxes_Edit, 'String', num2str(DATA.AutoYLimitUpperAxes.RRMinYLimit));
                set(GUI.MaxYLimitUpperAxes_Edit, 'String', num2str(DATA.AutoYLimitUpperAxes.RRMaxYLimit));
                
                set(GUI.MinYLimitLowAxes_Edit, 'String', num2str(DATA.AutoYLimitLowAxes.RRMinYLimit));
                set(GUI.MaxYLimitLowAxes_Edit, 'String', num2str(DATA.AutoYLimitLowAxes.RRMaxYLimit));
                
                set(GUI.WindowSize, 'String', calcDuration(DATA.MyWindowSize, 0));
                set(GUI.RecordLength_text, 'String', [calcDuration(DATA.maxSignalLength, 1) '    h:min:sec.msec']);
                set(GUI.RR_or_HR_plot_button, 'Enable', 'on', 'Value', 0, 'String', 'Plot HR');
                set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0)); % , 'Enable', 'off'
                set(GUI.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
                
                XData_active_window = get(GUI.rect_handle(1), 'XData');
                set(GUI.Active_Window_Start, 'String', calcDuration(XData_active_window(1), 0));
                
                if(DATA.AnalysisParams.activeWin_length >= DATA.Filt_MaxSignalLength)
                    set(GUI.Filt_RawDataSlider, 'Enable', 'off');
                else
                    set(GUI.Active_Window_Start, 'Enable', 'on');
                    set(GUI.Filt_RawDataSlider, 'Enable', 'on');
                end
                GUI.StatisticsTable.ColumnName = {'Description'; 'Values'};
                
                set(GUI.Active_Window_Length, 'Enable', 'on');
                if isfield(GUI, 'SpectralWindowLengthHandle') && isvalid(GUI.SpectralWindowLengthHandle)
                    GUI.SpectralWindowLengthHandle.Enable = 'off';
                end
            catch e
                errordlg(['Reset Plot: ' e.message], 'Input Error');
            end
        end
    end % reset GUI
%%
    function setSliderProperties(slider_handle, maxSignalLength, MyWindowSize, SliderStep)
        set(slider_handle, 'Min', 0);
        set(slider_handle, 'Max', maxSignalLength - MyWindowSize);
        set(slider_handle, 'Value', 0);
        set(slider_handle, 'SliderStep', [SliderStep/10 SliderStep]);
    end

%%
    function isInputNumeric = isInputNumeric(GUIFiled, NewFieldValue, OldFieldValue)
        if isnan(NewFieldValue)
            set(GUIFiled,'String', OldFieldValue);
            isInputNumeric = false;
            warndlg('Input must be numerical');
        else
            isInputNumeric = true;
        end
    end
%%
    function set_RRIntPage_Length(RRIntPage_Length, isInputNumeric)
        red_rect_xdata = get(GUI.red_rect, 'XData');
        min_red_rect_xdata = min(red_rect_xdata);
        max_red_rect_xdata = max(red_rect_xdata);
        red_rect_length = max_red_rect_xdata - min_red_rect_xdata;
        if isInputNumeric
            if RRIntPage_Length <= 1 || RRIntPage_Length > DATA.maxSignalLength
                set(GUI.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
                if isInputNumeric ~= 2
                    errordlg('The window size must be greater than 2 sec and less than signal length!', 'Input Error');
                end
                return;
            elseif RRIntPage_Length < red_rect_length
                set(GUI.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
                if isInputNumeric ~= 2
                    errordlg('The window size must be greater than zoom window length!', 'Input Error');
                end
                return;
            end
            DATA.RRIntPage_Length = RRIntPage_Length;
            
            delta_axes_red_rect = DATA.RRIntPage_Length - red_rect_length;
            right_length = DATA.maxSignalLength - max_red_rect_xdata;
            left_length = min_red_rect_xdata;
            if (delta_axes_red_rect - right_length) < (delta_axes_red_rect - left_length)
                set(GUI.AllDataAxes, 'XLim', [min_red_rect_xdata min((min_red_rect_xdata + DATA.RRIntPage_Length), DATA.maxSignalLength)]);
            else
                set(GUI.AllDataAxes, 'XLim', [max(0, max_red_rect_xdata - DATA.RRIntPage_Length) max_red_rect_xdata]);
            end
            
            setAxesXTicks(GUI.AllDataAxes);
            EnablePageUpDown();
            setAutoYAxisLimLowAxes(get(GUI.AllDataAxes, 'XLim'));
            DATA.YLimLowAxes = setYAxesLim(GUI.AllDataAxes, GUI.AutoScaleYLowAxes_checkbox, GUI.MinYLimitLowAxes_Edit, GUI.MaxYLimitLowAxes_Edit, DATA.YLimLowAxes, DATA.AutoYLimitLowAxes);
            set_rectangles_YData();
            
            AllDataAxes_XLim = get(GUI.AllDataAxes, 'XLim');
            RRIntPage_Length = max(AllDataAxes_XLim) - min(AllDataAxes_XLim);
            DATA.RRIntPage_Length = RRIntPage_Length;
            set(GUI.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
        end
    end
%%
    function RRIntPage_Length_Callback(~, ~)
        RRIntPage_Length = get(GUI.RRIntPage_Length, 'String');
        [RRIntPage_Length, isInputNumeric] = calcDurationInSeconds(GUI.RRIntPage_Length, RRIntPage_Length, DATA.RRIntPage_Length);
        set_RRIntPage_Length(RRIntPage_Length, isInputNumeric);
    end
%%
    function page_down_pushbutton_Callback(~, ~)
        xdata = get(GUI.red_rect, 'XData');
        right_border = min(xdata);
        left_border = right_border - DATA.MyWindowSize;
        
        if left_border < 0
            left_border = 0;
            right_border = DATA.MyWindowSize;
        end
        if left_border >= 0 && left_border < right_border && right_border <= DATA.maxSignalLength
            xdata = [left_border right_border right_border left_border left_border];
            set(GUI.red_rect, 'XData', xdata);
            ChangePlot(xdata);
            
            EnablePageUpDown();
            
            set_ticks = 0;
            AllDataAxes_XLim = get(GUI.AllDataAxes, 'XLim');
            prev_minLim = min(AllDataAxes_XLim);
            prev_maxLim = max(AllDataAxes_XLim);
            
            if max(xdata) > prev_maxLim
                AllDataAxes_offset = xdata(2) - prev_maxLim;
                set_ticks = 1;
            elseif min(xdata) < prev_minLim
                AllDataAxes_offset = xdata(1) - prev_minLim;
                set_ticks = 1;
            end
            if set_ticks
                set(GUI.AllDataAxes, 'XLim', AllDataAxes_XLim + AllDataAxes_offset);
                setAxesXTicks(GUI.AllDataAxes);
            end
        end
    end
%%
    function page_up_pushbutton_Callback(~, ~)
        xdata = get(GUI.red_rect, 'XData');
        left_border = max(xdata);
        right_border = left_border + DATA.MyWindowSize;
        if right_border > DATA.maxSignalLength
            left_border = DATA.maxSignalLength - DATA.MyWindowSize;
            right_border = DATA.maxSignalLength;
        end
        if left_border >= 0 && left_border < right_border && right_border <= DATA.maxSignalLength
            xdata = [left_border right_border right_border left_border left_border];
            set(GUI.red_rect, 'XData', xdata);
            ChangePlot(xdata);
            
            EnablePageUpDown();
            
            set_ticks = 0;
            AllDataAxes_XLim = get(GUI.AllDataAxes, 'XLim');
            prev_minLim = min(AllDataAxes_XLim);
            prev_maxLim = max(AllDataAxes_XLim);
            
            if max(xdata) > prev_maxLim
                AllDataAxes_offset = xdata(2) - prev_maxLim;
                set_ticks = 1;
            elseif min(xdata) < prev_minLim
                AllDataAxes_offset = xdata(1) - prev_minLim;
                set_ticks = 1;
            end
            if set_ticks
                set(GUI.AllDataAxes, 'XLim', AllDataAxes_XLim + AllDataAxes_offset);
                setAxesXTicks(GUI.AllDataAxes);
            end
        end
    end
%%
    function WindowSize_Callback(~, ~)
        if ~isempty(DATA.rri)
            MyWindowSize = get(GUI.WindowSize, 'String');
            [MyWindowSize, isInputNumeric]  = calcDurationInSeconds(GUI.WindowSize, MyWindowSize, DATA.MyWindowSize);
            
            if isInputNumeric
                if MyWindowSize <= 1 || (MyWindowSize + DATA.firstSecond2Show) > DATA.maxSignalLength % || MyWindowSize > DATA.maxSignalLength
                    set(GUI.WindowSize,'String', calcDuration(DATA.MyWindowSize, 0));
                    errordlg('The window size must be greater than 2 sec and less than signal length!', 'Input Error');
                    return;
                elseif MyWindowSize > DATA.RRIntPage_Length
                    set(GUI.WindowSize,'String', calcDuration(DATA.MyWindowSize, 0));
                    errordlg('The zoom window length must be smaller than display duration length!', 'Input Error');
                    return;
                end
                if abs(DATA.maxSignalLength - MyWindowSize ) <=  1 %0.0005
                    set(GUI.RawDataSlider, 'Enable', 'off');
                    set(GUI.FirstSecond, 'Enable', 'off');
                else
                    set(GUI.RawDataSlider, 'Enable', 'on');
                    set(GUI.FirstSecond, 'Enable', 'on');
                end
                
                DATA.MyWindowSize = MyWindowSize;
                setSliderProperties(GUI.RawDataSlider, DATA.maxSignalLength, DATA.MyWindowSize, DATA.MyWindowSize/DATA.maxSignalLength);
                set(GUI.RawDataSlider, 'Value', DATA.firstSecond2Show);
                setXAxesLim();
                setAutoYAxisLimUpperAxes(DATA.firstSecond2Show, DATA.MyWindowSize);
                DATA.YLimUpperAxes = setYAxesLim(GUI.RRDataAxes, GUI.AutoScaleYUpperAxes_checkbox, GUI.MinYLimitUpperAxes_Edit, GUI.MaxYLimitUpperAxes_Edit, DATA.YLimUpperAxes, DATA.AutoYLimitUpperAxes);
                plotDataQuality();
                plotMultipleWindows();
                
                xdata = get(GUI.red_rect, 'XData');
                xdata([2, 3]) = DATA.firstSecond2Show + DATA.MyWindowSize;
                set(GUI.red_rect, 'XData', xdata);
                EnablePageUpDown();
            end
        end
    end
%%
    function Spectral_Window_Length(GUI_Field_handle, Active_Window_Length)
        if ~isempty(DATA.rri)
            
            [Active_Window_Length, isInputNumeric] = calcDurationInSeconds(GUI_Field_handle, Active_Window_Length, DATA.AnalysisParams.activeWin_length);
            
            if isInputNumeric
                if Active_Window_Length < 10 || DATA.AnalysisParams.activeWin_startTime + Active_Window_Length > DATA.Filt_MaxSignalLength %Active_Window_Length > DATA.Filt_MaxSignalLength
                    set(GUI_Field_handle, 'String', calcDuration(DATA.AnalysisParams.activeWin_length, 0));
                    ME = MException('Spectral_Window_Length:text', 'The selected window length must be greater than 10 sec and less than signal length!');
                    throw(ME);
                else
                    
                    DATA.AnalysisParams.segment_endTime = DATA.AnalysisParams.activeWin_startTime + Active_Window_Length; %start_time + Active_Window_Length;
                    DATA.AnalysisParams.activeWin_length = Active_Window_Length;
                    
                    setSliderProperties(GUI.Filt_RawDataSlider, DATA.Filt_MaxSignalLength, DATA.AnalysisParams.activeWin_length, DATA.AnalysisParams.activeWin_length/DATA.Filt_MaxSignalLength);
                    
                    set(GUI.Filt_RawDataSlider, 'Value', DATA.AnalysisParams.activeWin_startTime);
                    
                    set(GUI.segment_endTime, 'String', calcDuration(DATA.AnalysisParams.segment_endTime, 0));
                    set(GUI.activeWindow_length, 'String', calcDuration(DATA.AnalysisParams.activeWin_length, 0));
                    
                    if Active_Window_Length == DATA.Filt_MaxSignalLength
                        set(GUI.Filt_RawDataSlider, 'Enable', 'off');
                        set(GUI.Active_Window_Start, 'Enable', 'off');
                    else
                        set(GUI.Filt_RawDataSlider, 'Enable', 'on');
                        set(GUI.Active_Window_Start, 'Enable', 'on');
                    end
                    
                    clear_statistics_plots();
                    clearStatTables();
                    calcBatchWinNum();
                    plotFilteredData();
                    plotMultipleWindows();
                    if get(GUI.AutoCalc_checkbox, 'Value')
                        calcStatistics();
                    end
                    set(GUI.blue_line, 'XData', [DATA.AnalysisParams.segment_startTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_startTime]);
                end
            else
                throw(MException('Spectral_Window_Length:text', 'The selected window length must be numeric!'));
            end
        end
    end
%%
    function Active_Window_Length_Callback(~, ~)
        if ~isempty(DATA.rri)
            Active_Window_Length = get(GUI.Active_Window_Length, 'String');
            try
                Spectral_Window_Length(GUI.Active_Window_Length, Active_Window_Length);
                %                 set(GUI.SpectralWindowLengthHandle, 'String', calcDuration(DATA.AnalysisParams.activeWin_length, 0));
            catch e
                errordlg(e.message, 'Input Error');
            end
        end
    end
%%
    function  [MinYLimit, MaxYLimit, YLimAxes] = ReadFromMinMaxYLimit(min_val_gui_handle, max_val_gui_handle, YLimAxes)
        MinYLimit = str2double(get(min_val_gui_handle,'String'));
        MaxYLimit = str2double(get(max_val_gui_handle,'String'));
        if (DATA.PlotHR == 0)
            OldMinYLimit = YLimAxes.RRMinYLimit;
            OldMaxYLimit = YLimAxes.RRMaxYLimit;
        else
            OldMinYLimit = YLimAxes.HRMinYLimit;
            OldMaxYLimit = YLimAxes.HRMaxYLimit;
        end
        if isInputNumeric(min_val_gui_handle, MinYLimit, OldMinYLimit) && isInputNumeric(max_val_gui_handle, MaxYLimit, OldMaxYLimit)
            
            if (DATA.PlotHR == 0)
                YLimAxes.RRMinYLimit = MinYLimit;
                YLimAxes.RRMaxYLimit = MaxYLimit;
                MinYLimit = min(YLimAxes.RRMinYLimit, YLimAxes.RRMaxYLimit);
                MaxYLimit = max(YLimAxes.RRMinYLimit, YLimAxes.RRMaxYLimit);
            else
                YLimAxes.HRMinYLimit = MinYLimit;
                YLimAxes.HRMaxYLimit = MaxYLimit;
                MinYLimit = min(YLimAxes.HRMinYLimit, YLimAxes.HRMaxYLimit);
                MaxYLimit = max(YLimAxes.HRMinYLimit, YLimAxes.HRMaxYLimit);
            end
        end
    end
%%
    function  SetMinMaxYLimitUpperAxes()
        if ~isempty(DATA.rri)
            [MinYLimit, MaxYLimit, DATA.YLimUpperAxes] = ReadFromMinMaxYLimit(GUI.MinYLimitUpperAxes_Edit, GUI.MaxYLimitUpperAxes_Edit, DATA.YLimUpperAxes);
            
            if(MinYLimit ~= MaxYLimit)
                set(GUI.RRDataAxes, 'YLim', [MinYLimit MaxYLimit]);
                DATA.YLimUpperAxes.MinYLimit = MinYLimit;
                DATA.YLimUpperAxes.MaxYLimit = MaxYLimit;
                plotDataQuality();
                plotMultipleWindows();
            else
                errordlg('Please, enter correct values!', 'Input Error');
            end
        end
    end
%%
    function SetMinMaxYLimitLowAxes()
        if ~isempty(DATA.rri)
            [MinYLimit, MaxYLimit, DATA.YLimLowAxes] = ReadFromMinMaxYLimit(GUI.MinYLimitLowAxes_Edit, GUI.MaxYLimitLowAxes_Edit, DATA.YLimLowAxes);
            
            if(MinYLimit ~= MaxYLimit)
                set(GUI.AllDataAxes, 'YLim', [MinYLimit MaxYLimit]);
                DATA.YLimLowAxes.MinYLimit = MinYLimit;
                DATA.YLimLowAxes.MaxYLimit = MaxYLimit;
                set_rectangles_YData();
            else
                errordlg('Please, enter correct values!', 'Input Error');
            end
        end
    end
%%
    function set_rectangles_YData()
        if isfield(GUI, 'red_rect')
            if ishandle(GUI.red_rect)
                set(GUI.red_rect, 'YData', [DATA.YLimLowAxes.MinYLimit DATA.YLimLowAxes.MinYLimit DATA.YLimLowAxes.MaxYLimit DATA.YLimLowAxes.MaxYLimit DATA.YLimLowAxes.MinYLimit]);
            end
        end
        if isfield(GUI, 'blue_line')
            if ishandle(GUI.blue_line)
                set(GUI.blue_line, 'YData', [DATA.YLimLowAxes.MinYLimit DATA.YLimLowAxes.MinYLimit DATA.YLimLowAxes.MaxYLimit DATA.YLimLowAxes.MaxYLimit]);
            end
        end
    end
%%
    function MinMaxYLimitLowAxes_Edit_Callback(~, ~)
        SetMinMaxYLimitLowAxes();
    end
%%
    function MinMaxYLimitUpperAxes_Edit_Callback(~, ~)
        SetMinMaxYLimitUpperAxes();
    end
%%
    function RR_or_HR_plot_button_Callback( ~, ~ )
        if ~isempty(DATA.rri)
            if DATA.PlotHR %== 1
                set(GUI.RR_or_HR_plot_button, 'String', 'Plot HR');
                DATA.PlotHR = 0;
                MinYLimit = min(DATA.YLimUpperAxes.RRMinYLimit, DATA.YLimUpperAxes.RRMaxYLimit);
                MaxYLimit = max(DATA.YLimUpperAxes.RRMinYLimit, DATA.YLimUpperAxes.RRMaxYLimit);
            else
                set(GUI.RR_or_HR_plot_button, 'String', 'Plot RR');
                DATA.PlotHR = 1;
                MinYLimit = min(DATA.YLimUpperAxes.HRMinYLimit, DATA.YLimUpperAxes.HRMaxYLimit);
                MaxYLimit = max(DATA.YLimUpperAxes.HRMinYLimit, DATA.YLimUpperAxes.HRMaxYLimit);
            end
            
            set(GUI.MinYLimitUpperAxes_Edit, 'String', num2str(MinYLimit));
            set(GUI.MaxYLimitUpperAxes_Edit, 'String', num2str(MaxYLimit));
            
            cla(GUI.RRDataAxes);
            cla(GUI.AllDataAxes);
            plotAllData();
            plotRawData();
            setXAxesLim();
            setAutoYAxisLimLowAxes(get(GUI.AllDataAxes, 'XLim'));
            DATA.YLimUpperAxes = setYAxesLim(GUI.RRDataAxes, GUI.AutoScaleYUpperAxes_checkbox, GUI.MinYLimitUpperAxes_Edit, GUI.MaxYLimitUpperAxes_Edit, DATA.YLimUpperAxes, DATA.AutoYLimitUpperAxes);
            DATA.YLimLowAxes = setYAxesLim(GUI.AllDataAxes, GUI.AutoScaleYLowAxes_checkbox, GUI.MinYLimitLowAxes_Edit, GUI.MaxYLimitLowAxes_Edit, DATA.YLimLowAxes, DATA.AutoYLimitLowAxes);
            plotFilteredData();
            plotDataQuality();
            plotMultipleWindows();
            
            set_rectangles_YData();
        end
    end
%%
    function set_defaults_path()
        if isdeployed
            res_dir = [userpath filesep 'PhysioZoo' filesep 'Results'];
        else
            res_dir = [basepath filesep 'Results'];
        end
        if ~isdir(res_dir)
            create_defaults_results_path();
        end
        if isempty(who('DIRS')) || isempty(DIRS)
            reset_defaults_path();
        end
        if isempty(who('DATA_Fig')) || isempty(DATA_Fig)
            reset_defaults_extensions();
        end
        if isempty(who('DATA_Measure')) || isempty(DATA_Measure)
            reset_defaults_extensions();
        end
    end
%%
    function reset_defaults_path()
        DIRS.configDirectory = [basepath filesep 'Config'];
        DIRS.DataBaseDirectory = basepath;
        DIRS.dataQualityDirectory = [basepath filesep 'ExamplesTXT'];
        DIRS.dataDirectory = [basepath filesep 'ExamplesTXT'];
        DIRS.Ext_open = 'txt';
        DIRS.Ext_group = 'txt';
        if isdeployed
            DIRS.ExportResultsDirectory = [userpath filesep 'PhysioZoo' filesep  'Results'];
        else
            DIRS.ExportResultsDirectory = [basepath filesep  'Results'];
        end
    end
%%
    function create_defaults_results_path()
        warning('off');
        if isdeployed
            mkdir(userpath, 'PhysioZoo\Results');
        else
            mkdir(basepath, 'Results');
        end
        warning('on');
    end
%%
    function reset_defaults_extensions()
        DATA_Fig.export_figures = [1 1 1 1 1 1 1];
        DATA_Fig.Ext = 'png';
        
        DATA_Measure.measures = [1 1 1 1];
        DATA_Measure.Ext_save = 'txt'; % mat
    end
%%
    function Reset_pushbutton_Callback( ~, ~ )
        reset_defaults_path();
        create_defaults_results_path();
        reset_defaults_extensions();
        
        DATA.filter_index = 1;
        set_filters(DATA.Filters{DATA.filter_index});
        
        if isempty(DATA.mammal)
            mammal_index = 1;
        else
            mammal_index = find(strcmp(DATA.mammals, DATA.mammal));
        end
        DATA.mammal_index = mammal_index;
        
        % Load user-specified default parameters
        mhrv_load_defaults(DATA.mammals{ DATA.mammal_index} );
        createConfigParametersInterface();
        
        GUI.Mammal_popupmenu.Value = mammal_index;
        GUI.Filtering_popupmenu.Value = DATA.filter_index;
        
        EnablePageUpDown();
        reset_plot_Data();
        reset_plot_GUI();
    end

%%
    function FiltSignal(varargin)
        
        DEFAULT_FILTER_QUOTIENT = DATA.filter_quotient;
        DEFAULT_FILTER_MA = DATA.filter_ma;
        DEFAULT_FILTER_RANGE = DATA.filter_range;
        p = inputParser;
        p.KeepUnmatched = true;
        p.addParameter('filter_quotient', DEFAULT_FILTER_QUOTIENT, @(x) islogical(x) && isscalar(x));
        p.addParameter('filter_ma', DEFAULT_FILTER_MA, @(x) islogical(x) && isscalar(x));
        p.addParameter('filter_range', DEFAULT_FILTER_RANGE, @(x) islogical(x) && isscalar(x));
        % Get input
        p.parse(varargin{:});
        filter_quotient = p.Results.filter_quotient;
        filter_ma = p.Results.filter_ma;
        filter_range = p.Results.filter_range;
        
        if ~isempty(DATA.rri)
            
            [nni, tnn, ~] = filtrr(DATA.rri, DATA.trr, 'filter_quotient', filter_quotient, 'filter_ma', filter_ma, 'filter_range', filter_range);
            
            if (isempty(nni))
                ME = MException('FiltCalcPlotSignalStat:FiltrrNoNNIntervalOutputted', 'No NN interval outputted');
                throw(ME);
            elseif (length(DATA.rri) * 0.1 > length(nni))
                ME = MException('FiltCalcPlotSignalStat:NotEnoughNNIntervals', 'Not enough NN intervals');
                throw(ME);
            else
                DATA.nni = nni;
                DATA.tnn = tnn;
            end
        end
    end
%%
    function choose_new_mammal(index_selected)
        set_defaults_path();
        if index_selected == length(DATA.mammals)
            [Config_FileName, PathName] = uigetfile({'*.yml','Yaml-files (*.yml)'}, 'Open Configuration File', [DIRS.configDirectory filesep]);
            if ~isequal(Config_FileName, 0)
                params_filename = fullfile(PathName, Config_FileName);
                [pathstr, name, ~] = fileparts(params_filename);
                mhrv_load_defaults([pathstr filesep name]);
                DIRS.configDirectory = PathName;
            else % Cancel by user
                GUI.Mammal_popupmenu.Value = DATA.mammal_index;
                return;
            end
        else
            % Load user-specified default parameters
            mhrv_load_defaults(DATA.mammals{index_selected});
        end
        createConfigParametersInterface();
        %         reset_plot();
        reset_plot_Data();
        reset_plot_GUI();
        DATA.mammal_index = index_selected;
    end
%%
    function Mammal_popupmenu_Callback( ~, ~ )
        index_selected = get(GUI.Mammal_popupmenu, 'Value');
        choose_new_mammal(index_selected);
    end
%%
    function Integration_popupmenu_Callback( ~, ~ )
        items = get(GUI.Integration_popupmenu, 'String');
        index_selected = get(GUI.Integration_popupmenu, 'Value');
        set_defaults_path();
        
        if index_selected == 1 % ECG
            [Config_FileName, PathName] = uigetfile({'*.yml','Yaml-files (*.yml)'}, 'Open Configuration File', [DIRS.configDirectory filesep]);
            if ~isequal(Config_FileName, 0)
                params_filename = fullfile(PathName, Config_FileName);
                [pathstr, name, ~] = fileparts(params_filename);
                mhrv_load_defaults([pathstr filesep name]);
                DIRS.configDirectory = PathName;
                createConfigParametersInterface();
                reset_plot_Data();
                reset_plot_GUI();
                
                preset_mammals = DATA.mammals(1:end-1);
                mammal_ind = find(cellfun(@(x) strcmp(x, name), preset_mammals));
                if ~isempty(mammal_ind)
                    set(GUI.Mammal_popupmenu, 'Value', mammal_ind);
                    DATA.mammal_index = mammal_ind;
                else
                    set(GUI.Mammal_popupmenu, 'Value', length(DATA.mammals)); % Custom
                    DATA.mammal_index = length(DATA.mammals);
                end
                
            else
                GUI.Mammal_popupmenu.Value = DATA.mammal_index;
                GUI.Integration_popupmenu.Value = DATA.integration_index;
                return;
            end
        else % NO ECG
            set(GUI.Mammal_popupmenu, 'Value', length(DATA.mammals)); % Custom
            
            [Config_FileName, PathName] = uigetfile({'*.yml','Yaml-files (*.yml)'}, 'Open Configuration File', [DIRS.configDirectory filesep]);
            if ~isequal(Config_FileName, 0)
                params_filename = fullfile(PathName, Config_FileName);
                [pathstr, name, ~] = fileparts(params_filename);
                mhrv_load_defaults([pathstr filesep name]);
                DIRS.configDirectory = PathName;
                DATA.mammal_index = length(DATA.mammals);
                createConfigParametersInterface();
                reset_plot_Data();
                reset_plot_GUI();
            else % Cancel by user
                GUI.Mammal_popupmenu.Value = DATA.mammal_index;
                GUI.Integration_popupmenu.Value = DATA.integration_index;
                return;
            end
        end
        DATA.Integration = items{index_selected};
        DATA.integration_index = index_selected;
    end
%%
    function set_default_filters_threshoulds(param_field, param_value)
        if isfield(GUI, 'ConfigParamHandlesMap')
            set(GUI.ConfigParamHandlesMap(param_field), 'String', num2str(param_value));
            mhrv_set_default(param_field, param_value);
        end
    end
%%
    function set_filtering_level_param(FilterLevel, Filter)
        if strcmp(FilterLevel, 'Default')
            filters_thresholds = DATA.default_filters_thresholds;
        elseif strcmp(FilterLevel, 'Custom')
            filters_thresholds = DATA.custom_filters_thresholds;
        end
        
        if strcmp(FilterLevel, 'Default') || strcmp(FilterLevel, 'Custom')
            if strcmp(Filter, 'Moving average')
                set_default_filters_threshoulds('filtrr.moving_average.win_threshold',  filters_thresholds.moving_average.win_threshold);
                set_default_filters_threshoulds('filtrr.moving_average.win_length',  filters_thresholds.moving_average.win_length);
            elseif strcmp(Filter, 'Range')
                set_default_filters_threshoulds('filtrr.range.rr_max',  filters_thresholds.range.rr_max);
                set_default_filters_threshoulds('filtrr.range.rr_min',  filters_thresholds.range.rr_min);
            elseif strcmp(Filter, 'Quotient')
                set_default_filters_threshoulds('filtrr.quotient.rr_max_change',  filters_thresholds.quotient.rr_max_change);
            elseif strcmp(Filter, 'Combined filters')
                set_default_filters_threshoulds('filtrr.moving_average.win_threshold',  filters_thresholds.moving_average.win_threshold);
                set_default_filters_threshoulds('filtrr.moving_average.win_length',  filters_thresholds.moving_average.win_length);
                set_default_filters_threshoulds('filtrr.range.rr_max',  filters_thresholds.range.rr_max);
                set_default_filters_threshoulds('filtrr.range.rr_min',  filters_thresholds.range.rr_min);
            end
        else
            fil_level = DATA.filters_level_value(find(cellfun(@(x) strcmp(x, FilterLevel), DATA.FilterLevel))-1);
            
            if strcmp(Filter, 'Moving average')
                set_default_filters_threshoulds('filtrr.moving_average.win_threshold', fil_level);
            elseif strcmp(Filter, 'Quotient')
                set_default_filters_threshoulds('filtrr.quotient.rr_max_change', fil_level);
            elseif strcmp(Filter, 'Combined filters')
                set_default_filters_threshoulds('filtrr.moving_average.win_threshold', fil_level);
                set_default_filters_threshoulds('filtrr.quotient.rr_max_change', fil_level);
            end
        end
    end
%%
    function FilteringLevel_popupmenu_Callback(src, ~)
        filteringLevel_items = get(src, 'String');
        index_selected_level = get(src, 'Value');
        FilterLevel = filteringLevel_items{index_selected_level};
        
        items = get(GUI.Filtering_popupmenu, 'String');
        Filter = items{get(GUI.Filtering_popupmenu,'Value')};
        
        set_filtering_level_param(FilterLevel, Filter);
        
        try
            calc_filt_signal();
            DATA.filter_level_index = index_selected_level;
        catch e
            set(src, 'Value', DATA.filter_level_index);
            set_filtering_level_param(filteringLevel_items{DATA.filter_level_index}, Filter)
            errordlg(['FilteringLevel_popupmenu_Callback Error: ' e.message], 'Input Error');
            return;
        end
    end
%%
    function calc_filt_signal()
        if(isfield(DATA, 'rri') && ~isempty(DATA.rri) )
            FiltSignal();
            clear_statistics_plots();
            clearStatTables();
            if isfield(GUI, 'filtered_handle')
                set(GUI.filtered_handle, 'XData', ones(1, length(DATA.tnn))*NaN, 'YData', ones(1, length(DATA.nni))*NaN);
            end
            plotFilteredData();
            if get(GUI.AutoCalc_checkbox, 'Value')
                calcStatistics();
            end
        end
    end
%%
    function Filtering_popupmenu_Callback(~, ~)
        items = get(GUI.Filtering_popupmenu, 'String');
        index_selected = get(GUI.Filtering_popupmenu, 'Value');
        Filter = items{index_selected};
        
        set(GUI.FilteringLevel_popupmenu, 'Value', DATA.default_filter_level_index);
        DATA.filter_level_index = DATA.default_filter_level_index;
        
        if strcmp(Filter, 'Range')
            GUI.FilteringLevel_popupmenu.String = DATA.FilterShortLevel;
            GUI.FilteringLevel_popupmenu.Enable = 'on';
            set_default_filters_threshoulds('filtrr.range.rr_max', DATA.default_filters_thresholds.range.rr_max);
            set_default_filters_threshoulds('filtrr.range.rr_min', DATA.default_filters_thresholds.range.rr_min);
        elseif strcmp(Filter, 'No filtering')
            GUI.FilteringLevel_popupmenu.String = DATA.FilterNoLevel;
            GUI.FilteringLevel_popupmenu.Enable = 'inactive';
        elseif strcmp(Filter, 'Moving average')
            GUI.FilteringLevel_popupmenu.String = DATA.FilterLevel;
            GUI.FilteringLevel_popupmenu.Enable = 'on';
            set_default_filters_threshoulds('filtrr.moving_average.win_threshold', DATA.default_filters_thresholds.moving_average.win_threshold);
            set_default_filters_threshoulds('filtrr.moving_average.win_length', DATA.default_filters_thresholds.moving_average.win_length);
        elseif strcmp(Filter, 'Quotient')
            GUI.FilteringLevel_popupmenu.String = DATA.FilterLevel;
            GUI.FilteringLevel_popupmenu.Enable = 'on';
            set_default_filters_threshoulds('filtrr.quotient.rr_max_change', DATA.default_filters_thresholds.quotient.rr_max_change);
        elseif strcmp(Filter, 'Combined filters')
            GUI.FilteringLevel_popupmenu.String = DATA.FilterLevel;
            GUI.FilteringLevel_popupmenu.Enable = 'on';
            set_default_filters_threshoulds('filtrr.range.rr_max', DATA.default_filters_thresholds.range.rr_max);
            set_default_filters_threshoulds('filtrr.range.rr_min', DATA.default_filters_thresholds.range.rr_min);
            set_default_filters_threshoulds('filtrr.moving_average.win_threshold', DATA.default_filters_thresholds.moving_average.win_threshold);
            set_default_filters_threshoulds('filtrr.moving_average.win_length', DATA.default_filters_thresholds.moving_average.win_length);
        end
        
        try
            set_filters(Filter);
        catch e
            errordlg(['Filtering_popupmenu_Callback Error: ' e.message], 'Input Error');
            GUI.Filtering_popupmenu.Value = DATA.filter_index;
            set_filters(items{DATA.filter_index});
            return;
        end
        try
            calc_filt_signal();
            DATA.filter_index = index_selected;
            
            if index_selected == length(DATA.Filters)
                DATA.legend_handle.String{2} = 'Selected time series';
            else
                DATA.legend_handle.String{2} = 'Selected filtered time series';
            end
            
        catch e
            errordlg(['Filtering_popupmenu_Callback Error: ' e.message], 'Input Error');
            GUI.Filtering_popupmenu.Value = DATA.filter_index;
            set_filters(items{DATA.filter_index});
            return;
        end
    end
%%
    function DefaultMethod_popupmenu_Callback( ~, ~ )
        DATA.default_frequency_method_index = get(GUI.DefaultMethod_popupmenu, 'Value');
        
        [StatRowsNames, StatData] = setFrequencyMethodData();
        if ~isempty(StatRowsNames) && ~isempty(StatData)
            updateMainStatisticsTable(DATA.timeStatPartRowNumber, StatRowsNames, StatData);
        end
    end
%%
    function [StatRowsNames, StatData] = setFrequencyMethodData()
        StatRowsNames = [];
        StatData = [];
        if ~isempty(DATA.FrStat)
            if DATA.default_frequency_method_index == 2 % AR
                if isfield(DATA.FrStat, 'ArWindowsData')
                    StatRowsNames = DATA.FrStat.ArWindowsData.RowsNames;
                    StatData = DATA.FrStat.ArWindowsData.Data;
                end
            elseif DATA.default_frequency_method_index == 1 % Welch
                if isfield(DATA.FrStat, 'WelchWindowsData')
                    StatRowsNames = DATA.FrStat.WelchWindowsData.RowsNames;
                    StatData = DATA.FrStat.WelchWindowsData.Data;
                end
            end
        end
    end
%%
    function updateMainStatisticsTable(prevPartRowNumber, RowsNames, Data)
        [rowNumber, colNumber] = size(Data);
        GUI.StatisticsTable.RowName(prevPartRowNumber + 1 : prevPartRowNumber + rowNumber) = RowsNames;
        GUI.StatisticsTable.Data(prevPartRowNumber + 1 : prevPartRowNumber + rowNumber, 1 : colNumber) = Data;
    end
%%
    function set_filters(Filter)
        if strcmp(Filter, DATA.Filters{5}) % No filtering
            DATA.filter_quotient = false;
            DATA.filter_ma = false;
            DATA.filter_range = false;
        elseif strcmp(Filter, DATA.Filters{1}) % Moving average
            DATA.filter_quotient = false;
            DATA.filter_ma = true;
            DATA.filter_range = false;
        elseif strcmp(Filter, DATA.Filters{2}) % Range
            DATA.filter_quotient = false;
            DATA.filter_ma = false;
            DATA.filter_range = true;
        elseif strcmp(Filter, DATA.Filters{3}) % Quotient
            DATA.filter_quotient = true;
            DATA.filter_ma = false;
            DATA.filter_range = false;
        elseif strcmp(Filter, DATA.Filters{4}) % Combined Filters
            DATA.filter_quotient = false;
            DATA.filter_ma = true;
            DATA.filter_range = true;
        else
            error('Unknown filter!');
        end
        mhrv_set_default('filtrr.range.enable', DATA.filter_range);
        mhrv_set_default('filtrr.quotient.enable', DATA.filter_quotient);
        mhrv_set_default('filtrr.ma.enable', DATA.filter_ma);
    end
%%
    function FirstSecond_Callback ( ~, ~ )
        if ~isempty(DATA.rri)
            screen_value = get(GUI.FirstSecond, 'String');
            [firstSecond2Show, isInputNumeric]  = calcDurationInSeconds(GUI.FirstSecond, screen_value, DATA.firstSecond2Show);
            if isInputNumeric
                if firstSecond2Show < 0 || firstSecond2Show > DATA.maxSignalLength - DATA.MyWindowSize  % + 1
                    set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0));
                    errordlg('The first second value must be grater than 0 and less than signal length!', 'Input Error');
                    return;
                end
                
                set(GUI.RawDataSlider, 'Value', firstSecond2Show);
                DATA.firstSecond2Show = firstSecond2Show;
                setXAxesLim();
                setAutoYAxisLimUpperAxes(DATA.firstSecond2Show, DATA.MyWindowSize);
                DATA.YLimUpperAxes = setYAxesLim(GUI.RRDataAxes, GUI.AutoScaleYUpperAxes_checkbox, GUI.MinYLimitUpperAxes_Edit, GUI.MaxYLimitUpperAxes_Edit, DATA.YLimUpperAxes, DATA.AutoYLimitUpperAxes);
                plotDataQuality();
                plotMultipleWindows();
                xdata = get(GUI.red_rect, 'XData');
                xdata([1, 4, 5]) = DATA.firstSecond2Show;
                xdata([2, 3]) = DATA.firstSecond2Show + DATA.MyWindowSize;
                set(GUI.red_rect, 'XData', xdata);
                EnablePageUpDown();
            end
        end
    end
%%
    function Active_Window_Start_Callback ( ~, ~ )
        if ~isempty(DATA.rri)
            active_window_start = get(GUI.Active_Window_Start, 'String');
            [active_window_start, isInputNumeric] = calcDurationInSeconds(GUI.Active_Window_Start, active_window_start, DATA.AnalysisParams.activeWin_startTime);
            if isInputNumeric
                if active_window_start < 0 || active_window_start > DATA.Filt_MaxSignalLength - DATA.AnalysisParams.activeWin_length % + 1
                    set(GUI.Active_Window_Start, 'String', calcDuration(DATA.AnalysisParams.activeWin_startTime, 0));
                    errordlg('The filt first second value must be grater than 0 and less than signal length!', 'Input Error');
                else
                    set(GUI.Filt_RawDataSlider, 'Value', active_window_start);
                    
                    DATA.AnalysisParams.activeWin_startTime = active_window_start;
                    DATA.AnalysisParams.segment_startTime = active_window_start;
                    DATA.AnalysisParams.segment_endTime = active_window_start + DATA.AnalysisParams.activeWin_length;
                    
                    set(GUI.segment_startTime, 'String', calcDuration(DATA.AnalysisParams.activeWin_startTime, 0));
                    set(GUI.segment_endTime, 'String', calcDuration(DATA.AnalysisParams.segment_endTime, 0));
                    
                    clear_statistics_plots();
                    clearStatTables();
                    calcBatchWinNum();
                    plotFilteredData();
                    plotMultipleWindows();
                    
                    if get(GUI.AutoCalc_checkbox, 'Value')
                        calcStatistics();
                    end
                    
                    set(GUI.blue_line, 'XData', [DATA.AnalysisParams.segment_startTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_startTime]);
                end
            end
        end
    end
%%
%     function signalDuration = calcDuration(varargin)
%
%         signal_length = double(varargin{1});
%         if length(varargin) == 2
%             need_ms = varargin{2};
%         else
%             need_ms = 1;
%         end
%         % Duration of signal
%         duration_h  = mod(floor(signal_length / 3600), 60);
%         duration_m  = mod(floor(signal_length / 60), 60);
%         duration_s  = mod(floor(signal_length), 60);
%         duration_ms = floor(mod(signal_length, 1)*1000);
%         if need_ms
%             signalDuration = sprintf('%02d:%02d:%02d.%03d', duration_h, duration_m, duration_s, duration_ms);
%         else
%             signalDuration = sprintf('%02d:%02d:%02d', duration_h, duration_m, duration_s);
%         end
%     end
% %%
%     function [signalDurationInSec, isInputNumeric]  = calcDurationInSeconds(GUIFiled, NewFieldValue, OldFieldValue)
%         duration = sscanf(NewFieldValue, '%d:%d:%d.%d');
%
%         isInputNumeric = true;
%
%         if length(duration) == 1 && duration(1) > 0
%             signalDuration = calcDuration(duration(1), 0);
%             set(GUIFiled,'String', signalDuration);
%             signalDurationInSec = duration(1);
%         elseif length(duration) == 3 && duration(1) >= 0 && duration(2) >= 0 && duration(3) >= 0
%             signalDurationInSec = duration(1)*3600 + duration(2)*60 + duration(3);
%         elseif length(duration) == 4 && duration(1) >= 0 && duration(2) >= 0 && duration(3) >= 0 && duration(4) >= 0
%             signalDurationInSec = duration(1)*3600 + duration(2)*60 + duration(3)+ duration(4)/1000;
%         else
%             set(GUIFiled, 'String', calcDuration(OldFieldValue, 0));
%             warndlg('Please, check your input');
%             isInputNumeric = false;
%             signalDurationInSec = [];
%         end
%     end
%%
    function cancel_button_Callback( ~, ~, Window2Close )
        delete( Window2Close );
    end
%%
    function dir_button_Callback( ~, ~ )
        set_defaults_path();
        
        [fig_full_name, fig_path, FilterIndex] = uiputfile({'*.*', 'All files';...
            '*.fig','MATLAB Figure (*.fig)';...
            '*.bmp','Bitmap file (*.bmp)';...
            '*.eps','EPS file (*.eps)';...
            '*.emf','Enhanced metafile (*.emf)';...
            '*.jpg','JPEG image (*.jpg)';...
            '*.pcx','Paintbrush 24-bit file (*.pcx)';...
            '*.pbm','Portable Bitmap file (*.pbm)';...
            '*.pdf','Portable Document Format (*.pdf)';...
            '*.pgm','Portable Graymap file (*.pgm)';...
            '*.png','Portable Network Grafics file (*.png)';...
            '*.ppm','Portable Pixmap file (*.ppm)';...
            '*.svg','Scalable Vector Graphics file (*.svg)';...
            '*.tif','TIFF image (*.tif)';...
            '*.tif','TIFF no compression image (*.tif)'},...
            'Choose Figures file Name',...
            [DIRS.ExportResultsDirectory, filesep, [DATA.DataFileName, '.', DATA_Fig.Ext]]);
        if ~isequal(fig_path, 0)
            DIRS.ExportResultsDirectory = fig_path;
            
            [~, fig_name, fig_ext] = fileparts(fig_full_name);
            
            DATA_Fig.FigFileName = fig_name;
            if ~isempty(fig_ext)
                DATA_Fig.Ext = fig_ext(2:end);
            else
                DATA_Fig.Ext = 'png';
            end
            saveAs_figures_button();
        end
    end
%%
    function onSaveFiguresAsFile( ~, ~ )
        
        set_defaults_path();
        
        GUIFiguresNames = {'NN Interval Distribution'; 'Power Spectral Density'; 'Beta'; 'DFA'; 'MSE'; 'Poincare Ellipse'; 'RR Time Series'};
        DATA.FiguresNames = {'_NND'; '_PSD'; '_Beta'; '_DFA'; '_MSE'; '_Poincare'; '_RR'};
        
        main_screensize = DATA.screensize;
        
        GUI.SaveFiguresWindow = figure( ...
            'Name', 'Save Figures Options', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', ...
            'Position', [(main_screensize(3)-400)/2, (main_screensize(4)-300)/2, 400, 300]); %[700, 300, 800, 400]
        
        
        setLogo(GUI.SaveFiguresWindow);
        
        mainSaveFigurestLayout = uix.VBox('Parent',GUI.SaveFiguresWindow, 'Spacing', DATA.Spacing);
        figures_panel = uix.Panel( 'Parent', mainSaveFigurestLayout, 'Padding', DATA.Padding+2, 'Title', 'Select figures to save:', 'FontSize', DATA.BigFontSize+2, 'FontName', 'Calibri', 'BorderType', 'beveledin' );
        figures_box = uix.VButtonBox('Parent', figures_panel, 'Spacing', DATA.Spacing-1, 'HorizontalAlignment', 'left', 'ButtonSize', [200 25]);
        
        for i = 1 : 7
            uicontrol( 'Style', 'checkbox', 'Parent', figures_box, 'Callback', {@figures_checkbox_Callback, i}, 'FontSize', DATA.BigFontSize, ...
                'Tag', ['Fig' num2str(i)], 'String', GUIFiguresNames{i}, 'FontName', 'Calibri', 'Value', DATA_Fig.export_figures(i));
        end
        
        CommandsButtons_Box = uix.HButtonBox('Parent', mainSaveFigurestLayout, 'Spacing', DATA.Spacing, 'VerticalAlignment', 'middle', 'ButtonSize', [100 30]);
        uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', @dir_button_Callback, 'FontSize', DATA.BigFontSize, 'String', 'Save As', 'FontName', 'Calibri');
        uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', {@cancel_button_Callback, GUI.SaveFiguresWindow}, 'FontSize', DATA.BigFontSize, 'String', 'Cancel', 'FontName', 'Calibri');
        
        set( mainSaveFigurestLayout, 'Heights',  [-70 -30]); % [-70 -45 -25]
    end
%%
    function figures_checkbox_Callback( src, ~, param_name )
        DATA_Fig.export_figures(param_name) = get(src, 'Value');
    end
%%
    function saveAs_figures_button()
        
        fig_path = DIRS.ExportResultsDirectory;
        fig_name = DATA_Fig.FigFileName;
        fig_ext = DATA_Fig.Ext;
        
        if ~isempty(fig_path) && ~isempty(fig_name) && ~isempty(fig_ext)
            ext = fig_ext;
            if strcmpi(ext, 'pcx')
                ext = 'pcx24b';
            elseif strcmpi(ext, 'emf')
                ext = 'meta';
            elseif strcmpi(ext, 'jpg')
                ext = 'jpeg';
            elseif strcmpi(ext, 'tif')
                ext = 'tiff';
            elseif strcmpi(ext, 'tiff')
                ext = 'tiffn';
            end
            
            export_path_name = fullfile(fig_path, fig_name);
            
            yes_no = zeros(length(DATA.FiguresNames));
            for i = 1 : length(DATA.FiguresNames)
                if DATA_Fig.export_figures(i)
                    full_file_name = [export_path_name DATA.FiguresNames{i} '.' ext];
                    button = 'Yes';
                    if exist(full_file_name, 'file')
                        button = questdlg([full_file_name ' already exist. Do you want to overwrite it?'], 'Overwrite existing file?', 'Yes', 'No', 'No');
                    end
                    if strcmp(button, 'Yes')
                        yes_no(i) = 1;
                    end
                end
            end
            if ~isempty(DATA.TimeStat) || ~isempty(DATA.FrStat) || ~isempty(DATA.NonLinStat)
                
                if ~strcmpi(ext, 'fig')
                    if ~isempty(DATA.TimeStat.PlotData{DATA.active_window}) && DATA_Fig.export_figures(1) && yes_no(1)
                        af = figure;
                        setLogo(af);
                        set(af, 'Visible', 'off')
                        plot_hrv_time_hist(gca, DATA.TimeStat.PlotData{DATA.active_window}, 'clear', true);
                        fig_print( af, [export_path_name, DATA.FiguresNames{1}], 'output_format', ext, 'title', figure_title(fig_name, 1));
                        close(af);
                    end
                    
                    if ~isempty(DATA.FrStat.PlotData{DATA.active_window})
                        if DATA_Fig.export_figures(2) && yes_no(2)
                            af = figure;
                            setLogo(af);
                            set(af, 'Visible', 'off')
                            plot_hrv_freq_spectrum(gca, DATA.FrStat.PlotData{DATA.active_window}, 'detailed_legend', false, 'yscale', DATA.freq_yscale);
                            fig_print( af, [export_path_name, DATA.FiguresNames{2}], 'output_format', ext, 'title', figure_title(fig_name, 2));
                            close(af);
                        end
                        if DATA_Fig.export_figures(3) && yes_no(3)
                            af = figure;
                            setLogo(af);
                            set(af, 'Visible', 'off')
                            plot_hrv_freq_beta(gca, DATA.FrStat.PlotData{DATA.active_window});
                            fig_print( af, [export_path_name, DATA.FiguresNames{3}], 'output_format', ext, 'title', figure_title(fig_name, 3));
                            close(af);
                        end
                    end
                    
                    if ~isempty(DATA.NonLinStat.PlotData{DATA.active_window})
                        if DATA_Fig.export_figures(4) && yes_no(4)
                            af = figure;
                            setLogo(af);
                            set(af, 'Visible', 'off')
                            plot_dfa_fn(gca, DATA.NonLinStat.PlotData{DATA.active_window}.dfa);
                            fig_print( af, [export_path_name, DATA.FiguresNames{4}], 'output_format', ext, 'title', figure_title(fig_name, 4));
                            close(af);
                        end
                        if DATA_Fig.export_figures(5) && yes_no(5)
                            af = figure;
                            setLogo(af);
                            set(af, 'Visible', 'off')
                            plot_mse(gca, DATA.NonLinStat.PlotData{DATA.active_window}.mse);
                            fig_print( af, [export_path_name, DATA.FiguresNames{5}], 'output_format', ext, 'title', figure_title(fig_name, 5));
                            close(af);
                        end
                        if DATA_Fig.export_figures(6) && yes_no(6)
                            af = figure;
                            setLogo(af);
                            set(af, 'Visible', 'off')
                            plot_poincare_ellipse(gca, DATA.NonLinStat.PlotData{DATA.active_window}.poincare);
                            fig_print( af, [export_path_name, DATA.FiguresNames{6}], 'output_format', ext, 'title', figure_title(fig_name, 6));
                            close(af);
                        end
                    end
                    if DATA_Fig.export_figures(7) && yes_no(7)
                        af = figure;
                        setLogo(af);
                        set(af, 'Visible', 'off')
                        plot_rr_time_series(gca);
                        fig_print( af, [export_path_name, DATA.FiguresNames{7}], 'output_format', ext, 'title', figure_title(fig_name, 7));
                        close(af);
                    end
                elseif strcmpi(ext, 'fig')
                    if ~isempty(DATA.TimeStat.PlotData{DATA.active_window}) && DATA_Fig.export_figures(1) && yes_no(1)
                        af = figure;
                        setLogo(af);
                        set(af, 'Name', [fig_name, DATA.FiguresNames{1}], 'NumberTitle', 'off');
                        plot_hrv_time_hist(gca, DATA.TimeStat.PlotData{DATA.active_window}, 'clear', true);
                        title(gca, figure_title(fig_name, 1));
                        savefig(af, [export_path_name, DATA.FiguresNames{1}], 'compact');
                        close(af);
                    end
                    if ~isempty(DATA.FrStat.PlotData{DATA.active_window})
                        if DATA_Fig.export_figures(2) && yes_no(2)
                            af = figure;
                            setLogo(af);
                            set(af, 'Name', [fig_name, DATA.FiguresNames{2}], 'NumberTitle', 'off');
                            plot_hrv_freq_spectrum(gca, DATA.FrStat.PlotData{DATA.active_window}, 'detailed_legend', false, 'yscale', DATA.freq_yscale);
                            title(gca, figure_title(fig_name, 2));
                            savefig(af, [export_path_name, DATA.FiguresNames{2}], 'compact');
                            close(af);
                        end
                        if DATA_Fig.export_figures(3) && yes_no(3)
                            af = figure;
                            setLogo(af);
                            set(af, 'Name', [fig_name, DATA.FiguresNames{3}], 'NumberTitle', 'off');
                            plot_hrv_freq_beta(gca, DATA.FrStat.PlotData{DATA.active_window});
                            title(gca, figure_title(fig_name, 3));
                            savefig(af, [export_path_name, DATA.FiguresNames{3}], 'compact');
                            close(af);
                        end
                    end
                    if ~isempty(DATA.NonLinStat.PlotData{DATA.active_window})
                        if DATA_Fig.export_figures(4) && yes_no(4)
                            af = figure;
                            setLogo(af);
                            set(af, 'Name', [fig_name, DATA.FiguresNames{4}], 'NumberTitle', 'off');
                            plot_dfa_fn(gca, DATA.NonLinStat.PlotData{DATA.active_window}.dfa);
                            title(gca, figure_title(fig_name, 4));
                            savefig(af, [export_path_name, DATA.FiguresNames{4}], 'compact');
                            close(af);
                        end
                        if DATA_Fig.export_figures(5) && yes_no(5)
                            af = figure;
                            setLogo(af);
                            set(af, 'Name', [fig_name, DATA.FiguresNames{5}], 'NumberTitle', 'off');
                            plot_mse(gca, DATA.NonLinStat.PlotData{DATA.active_window}.mse);
                            title(gca, figure_title(fig_name, 5));
                            savefig(af, [export_path_name, DATA.FiguresNames{5}], 'compact');
                            close(af);
                        end
                        if DATA_Fig.export_figures(6) && yes_no(6)
                            af = figure;
                            setLogo(af);
                            set(af, 'Name', [fig_name, DATA.FiguresNames{6}], 'NumberTitle', 'off');
                            plot_poincare_ellipse(gca, DATA.NonLinStat.PlotData{DATA.active_window}.poincare);
                            title(gca, figure_title(fig_name, 6));
                            savefig(af, [export_path_name, DATA.FiguresNames{6}], 'compact');
                            close(af);
                        end
                    end
                    if DATA_Fig.export_figures(7) && yes_no(7)
                        af = figure;
                        setLogo(af);
                        set(af, 'Name', [fig_name, DATA.FiguresNames{7}], 'NumberTitle', 'off');
                        plot_rr_time_series(gca);
                        title(gca, figure_title(fig_name, 7));
                        savefig(af, [export_path_name, DATA.FiguresNames{7}], 'compact');
                        close(af);
                    end
                end
            else
                errordlg('Please, press Compute before saving!', 'Input Error');
            end
            delete( GUI.SaveFiguresWindow );
        else
            errordlg('Please enter valid path to save figures', 'Input Error');
        end
    end
%%
    function figure_title = figure_title(fig_name, title_number)
        figure_title = [strrep(fig_name,  '_', '\_'), strrep(DATA.FiguresNames{title_number}, '_', '\_')] ;
    end
%%
    function plot_rr_time_series(ax)
        
        XData_active_window = get(GUI.rect_handle(DATA.active_window), 'XData');
        
        win_indexes = find(DATA.trr >= XData_active_window(1) & DATA.trr <= XData_active_window(3));
        filt_win_indexes = find(DATA.tnn >= XData_active_window(1) & DATA.tnn <= XData_active_window(3));
        
        if (DATA.PlotHR == 0)
            plot(ax, DATA.trr(win_indexes), DATA.rri(win_indexes), 'b-', 'LineWidth', 2);
            hold on
            plot(ax, DATA.tnn(filt_win_indexes), DATA.nni(filt_win_indexes), 'g-', 'LineWidth', 1);
            yString = 'RR (sec)';
        else
            plot(ax, DATA.trr(win_indexes), 60 ./ DATA.rri(win_indexes), 'b-', 'LineWidth', 2);
            hold on
            plot(ax, DATA.tnn(filt_win_indexes), 60 ./ DATA.nni(filt_win_indexes), 'g-', 'LineWidth', 1);
            yString = 'HR (BPM)';
        end
        xlabel(ax, 'Time (h:min:sec)');
        ylabel(ax, yString);
        
        set(ax, 'XLim', [XData_active_window(1), XData_active_window(3)]);
        setAxesXTicks(ax);
        
        legend_handle = legend(ax, 'show', 'Location', 'southeast', 'Orientation', 'horizontal');
        
        legend_handle.String{1} = 'Time series';
        if DATA.filter_index == length(DATA.Filters)
            legend_handle.String{2} = 'Selected time series';
        else
            legend_handle.String{2} = 'Selected filtered time series';
        end
        
    end
%%
    function onSavePSDAsFile( filename )
        if ~isempty(DATA.FrStat)
            if ~isequal(DIRS.ExportResultsDirectory, 0)
                [~, filename, ~] = fileparts(filename);
                ext = ['.' DATA_Measure.Ext_save];
                full_file_name_psd = fullfile(DIRS.ExportResultsDirectory, filename);
                button = 'Yes';
                if exist([full_file_name_psd '_psd_W1' ext], 'file') || exist([full_file_name_psd '_psd' ext], 'file')
                    button = questdlg([full_file_name_psd ext ' already exist. Do you want to overwrite it?'], 'Overwrite existing file?', 'Yes', 'No', 'No');
                end
                if strcmp(button, 'Yes')
                    full_file_name_psd_W = [full_file_name_psd '_psd_W'];
                    if strcmp(ext, '.txt')
                        for i = 1 : DATA.AnalysisParams.winNum
                            plot_data = DATA.FrStat.PlotData{i};
                            psd_fileID = fopen([full_file_name_psd_W num2str(i) ext], 'w');
                            fprintf(psd_fileID, 'Frequency\tPSD_AR\t\tPSD_Welch\r\n');
                            dlmwrite([full_file_name_psd_W num2str(i) ext], [plot_data.f_axis plot_data.pxx_ar plot_data.pxx_welch], ...
                                'precision', '%.5f\t\n', 'delimiter', '\t', 'newline', 'pc', 'roffset', 2, '-append');
                            fclose(psd_fileID);
                        end
                    elseif strcmp(ext, '.mat')
                        PSD = DATA.FrStat.PlotData;
                        save([[full_file_name_psd '_psd'] ext], 'PSD');
                    end
                end
            end
        else
            errordlg('Please, press Compute before saving!', 'Input Error');
        end
    end
%%
    function onSaveMSEFile(filename)
        if ~isempty(DATA.NonLinStat)
            if ~isequal(DIRS.ExportResultsDirectory, 0)
                [~, filename, ~] = fileparts(filename);
                ext = ['.' DATA_Measure.Ext_save];
                full_file_name_mse = fullfile(DIRS.ExportResultsDirectory, filename);
                
                button = 'Yes';
                if exist([full_file_name_mse '_mse_W1' ext], 'file') || exist([full_file_name_mse '_mse' ext], 'file')
                    button = questdlg([full_file_name_mse ext ' already exist. Do you want to overwrite it?'], 'Overwrite existing file?', 'Yes', 'No', 'No');
                end
                if strcmp(button, 'Yes')
                    full_file_name_mse_W = [full_file_name_mse '_mse_W'];
                    if strcmp(ext, '.txt')
                        for i = 1 : DATA.AnalysisParams.winNum
                            mse_win_file_name = [full_file_name_mse_W num2str(i) ext];
                            mse_fileID = fopen(mse_win_file_name, 'w');
                            plot_data = DATA.NonLinStat.PlotData{i};
                            fprintf(mse_fileID, 'scale_axis\tmse_result\r\n');
                            dlmwrite(mse_win_file_name, [plot_data.mse.scale_axis; plot_data.mse.mse_result]', ...
                                'precision', '%.3f\t\n', 'delimiter', '\t', 'newline', 'pc', 'roffset', 2, '-append');
                            fclose(mse_fileID);
                        end
                    elseif strcmp(ext, '.mat')
                        NonLinPlotData = DATA.NonLinStat.PlotData;
                        save([full_file_name_mse '_mse' ext], 'NonLinPlotData');
                    end
                end
            end
        end
    end
%%
    function onSaveMeasures( ~, ~ )
        set_defaults_path();
        GUIMeasuresNames = {'HRV Measures'; 'Power Spectral Density'; 'Multi Scale Entropy'; 'Preprocessed RR intervals'};
        
        main_screensize = DATA.screensize;
        
        GUI.SaveMeasuresWindow = figure( ...
            'Name', 'Save HRV Measures Options', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', ...
            'Position', [(main_screensize(3)-400)/2, (main_screensize(4)-300)/2, 400, 300]); %[700, 300, 800, 400]
        
        setLogo(GUI.SaveMeasuresWindow);
        
        mainSaveMeasuresLayout = uix.VBox('Parent',GUI.SaveMeasuresWindow, 'Spacing', DATA.Spacing);
        measures_panel = uix.Panel( 'Parent', mainSaveMeasuresLayout, 'Padding', DATA.Padding+2, 'Title', 'Select measures to save:', 'FontSize', DATA.BigFontSize+2, 'FontName', 'Calibri', 'BorderType', 'beveledin' );
        measures_box = uix.VButtonBox('Parent', measures_panel, 'Spacing', DATA.Spacing-1, 'HorizontalAlignment', 'left', 'ButtonSize', [200 25]);
        
        for i = 1 : length(GUIMeasuresNames)
            uicontrol( 'Style', 'checkbox', 'Parent', measures_box, 'Callback', {@measures_checkbox_Callback, i}, 'FontSize', DATA.BigFontSize, ...
                'Tag', ['Measure' num2str(i)], 'String', GUIMeasuresNames{i}, 'FontName', 'Calibri', 'Value', DATA_Measure.measures(i));
        end
        
        CommandsButtons_Box = uix.HButtonBox('Parent', mainSaveMeasuresLayout, 'Spacing', DATA.Spacing, 'VerticalAlignment', 'middle', 'ButtonSize', [100 30]);
        uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', @save_measures_button_Callback, 'FontSize', DATA.BigFontSize, 'String', 'Save As', 'FontName', 'Calibri');
        uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', {@cancel_button_Callback, GUI.SaveMeasuresWindow}, 'FontSize', DATA.BigFontSize, 'String', 'Cancel', 'FontName', 'Calibri');
        
        set( mainSaveMeasuresLayout, 'Heights',  [-70 -30]); % [-70 -45 -25]
    end
%%
    function measures_checkbox_Callback( src, ~, param_name )
        DATA_Measure.measures(param_name) = get(src, 'Value');
    end
%%
    function save_measures_button_Callback(~, ~)
        set_defaults_path();
        
        [res_full_name, results_folder_name, FilterIndex] = uiputfile({'*.*', 'All files';...
            '*.txt','Text Files (*.txt)'
            '*.mat','MAT-files (*.mat)'},...
            'Choose Results File Name',...
            [DIRS.ExportResultsDirectory, filesep, [DATA.DataFileName, '.', DATA_Measure.Ext_save]]);
        if ~isequal(results_folder_name, 0)
            DIRS.ExportResultsDirectory = results_folder_name;
            
            [~, res_name, res_ext] = fileparts(res_full_name);
            
            DATA_Measure.ResFileName = res_name;
            if ~isempty(res_ext)
                DATA_Measure.Ext_save = res_ext(2:end);
            else
                DATA_Measure.Ext_save = 'txt';
            end
            if DATA_Measure.measures(1)
                onSaveResultsAsFile(res_name);
            end
            if DATA_Measure.measures(2)
                onSavePSDAsFile(res_name);
            end
            if DATA_Measure.measures(3)
                onSaveMSEFile(res_name);
            end
            if DATA_Measure.measures(4)
                onSaveFilteredDataFile(res_name);
            end
        end
        delete( GUI.SaveMeasuresWindow );
    end
%%
    function onSaveResultsAsFile(filename)
        
        if ~isequal(DIRS.ExportResultsDirectory, 0)
            
            ext = ['.' DATA_Measure.Ext_save];
            full_file_name_hea = fullfile(DIRS.ExportResultsDirectory, [filename '_hea.txt']);
            full_file_name_hrv = fullfile(DIRS.ExportResultsDirectory, [filename '_hrv' ext]);
            
            button = 'Yes';
            if exist(full_file_name_hrv, 'file')
                button = questdlg([full_file_name_hrv ' already exist. Do you want to overwrite it?'], 'Overwrite existing file?', 'Yes', 'No', 'No');
            end
            
            if strcmp(button, 'Yes')
                if ~isempty(DATA.TimeStat) && ~isempty(DATA.FrStat) && ~isempty(DATA.NonLinStat)
                    
                    hrv_metrics_table = horzcat(DATA.TimeStat.hrv_time_metrics, DATA.FrStat.hrv_fr_metrics, DATA.NonLinStat.hrv_nonlin_metrics);
                    hrv_metrics_table.Properties.Description = sprintf('HRV metrics for %s', DATA.DataFileName);
                    
                    AllRowsNames = [DATA.TimeStat.RowsNames; DATA.FrStat.WelchWindowsData.RowsNames_NO_GreekLetters; DATA.FrStat.ArWindowsData.RowsNames_NO_GreekLetters; DATA.NonLinStat.RowsNames_NO_GreekLetters];
                    statistics_params = [DATA.TimeStat.Data; DATA.FrStat.WelchWindowsData.Data; DATA.FrStat.ArWindowsData.Data; DATA.NonLinStat.Data];
                    
                    column_names = {'Description'};
                    for i = 1 : DATA.AnalysisParams.winNum
                        column_names = cat(1, column_names, ['W' num2str(i)]);
                    end
                    
                    if strcmp(ext, '.txt')
                        header_fileID = fopen(full_file_name_hea, 'w');
                        fprintf(header_fileID, '#header\r\n');
                        fprintf(header_fileID, 'Record name: %s\r\n\r\n', DATA.DataFileName);
                        fprintf(header_fileID, 'Mammal: %s\r\n', DATA.mammals{ DATA.mammal_index});
                        fprintf(header_fileID, 'Integration level: %s\r\n', DATA.Integration);
                        fprintf(header_fileID, 'Preprocessing: %s\r\n', DATA.Filters{DATA.filter_index});
                        fprintf(header_fileID, 'Preprocessing level: %s\r\n', DATA.FilterLevel{DATA.filter_level_index});
                        fprintf(header_fileID, 'Window start: %s\r\n', calcDuration(DATA.AnalysisParams.segment_startTime));
                        fprintf(header_fileID, 'Window end: %s\r\n', calcDuration(DATA.AnalysisParams.segment_endTime));
                        fprintf(header_fileID, 'Window length: %s\r\n', calcDuration(DATA.AnalysisParams.activeWin_length));
                        fprintf(header_fileID, 'Overlap: %s\r\n', num2str(DATA.AnalysisParams.segment_overlap));
                        fprintf(header_fileID, 'Windows number: %s\r\n', num2str(DATA.AnalysisParams.winNum));
                        fprintf(header_fileID, 'Number of mammals: 1\r\n');
                        fclose(header_fileID);
                        
                        max_length_rows_names = max(cellfun(@(x) length(x), AllRowsNames));
                        padded_rows_names = cellfun(@(x) [pad(x, max_length_rows_names) ':'], AllRowsNames, 'UniformOutput', false );
                        
                        max_length_descr = max(cellfun(@(x) length(x), statistics_params(:, 1)));
                        statistics_params(:, 1) = cellfun(@(x) pad(x, max_length_descr), statistics_params(:, 1), 'UniformOutput', false );
                        
                        statisticsTable = cell2table(statistics_params, 'RowNames', padded_rows_names);
                        statisticsTable.Properties.DimensionNames(1) = {'Measures'};
                        writetable(statisticsTable, full_file_name_hrv, 'Delimiter', '\t', 'WriteRowNames', true, 'WriteVariableNames', false);
                    elseif strcmp(ext, '.mat')
                        RecordName = DATA.DataFileName;
                        Mammal = DATA.mammals{ DATA.mammal_index};
                        IntegrationLevel = DATA.Integration;
                        Preprocessing = DATA.Filters{DATA.filter_index};
                        PreprocessingLevel = DATA.FilterLevel{DATA.filter_level_index};
                        WindowStart = calcDuration(DATA.AnalysisParams.segment_startTime);
                        WindowEnd = calcDuration(DATA.AnalysisParams.segment_endTime);
                        WindowLength = calcDuration(DATA.AnalysisParams.activeWin_length);
                        Overlap = DATA.AnalysisParams.segment_overlap;
                        WindowNumber = DATA.AnalysisParams.winNum;
                        MammalsNumber = 1;
                        
                        save(full_file_name_hrv, 'RecordName', 'Mammal', 'IntegrationLevel', 'Preprocessing', 'PreprocessingLevel', 'WindowStart', 'WindowEnd', 'WindowLength', 'Overlap', 'WindowNumber', 'MammalsNumber',...
                            'hrv_metrics_table');
                    end
                else
                    errordlg('Please, press Compute before saving!', 'Input Error');
                end
            end
        end
    end
%%
    function onPhysioZooHome( ~, ~ )
        url = 'http://www.physiozoo.com/';
        %         url = 'https://physiozoo.readthedocs.io/';
        web(url,'-browser')
    end
%%
    function onAbout( ~, ~ )
        
        GUI.AboutWindow = figure( ...
            'Name', 'HRV About', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', ...
            'Position', [700, 300, 400, 400]);
        
        setLogo(GUI.AboutWindow);
        
        GUI.mainAboutLayout = uix.VBox('Parent', GUI.AboutWindow, 'Spacing', DATA.Spacing);
        GUI.ImageAxes = axes('Parent', GUI.mainAboutLayout, 'ActivePositionProperty', 'Position');
        
        logoImage = imread('D:\PhysioZoo\Physio Zoo Logo Dina 1.jpg');
        imagesc(logoImage, 'Parent', GUI.ImageAxes);
        set( GUI.ImageAxes, 'xticklabel', [], 'yticklabel', [] );
        set(GUI.ImageAxes,'handlevisibility','off','visible','off')
    end
%%
    function waitbar_handle = update_statistics(param_category)
        
        if isfield(DATA, 'AnalysisParams')
            
            GUI.StatisticsTable.ColumnName = {'Description'};
            
            if DATA.AnalysisParams.winNum == 1
                GUI.StatisticsTable.ColumnName = cat(1, GUI.StatisticsTable.ColumnName, 'Values');
            else
                for i = 1 : DATA.AnalysisParams.winNum
                    GUI.StatisticsTable.ColumnName = cat(1, GUI.StatisticsTable.ColumnName, ['W' num2str(i)]);
                end
            end
            
            if strcmp(param_category, 'filtrr') || isempty(DATA.TimeStat) || isempty(DATA.FrStat) || isempty(DATA.NonLinStat)
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                try
                    FiltSignal();
                    clear_statistics_plots();
                    clearStatTables();
                    plotFilteredData();
                    calcStatistics();
                    close(waitbar_handle);
                catch e
                    close(waitbar_handle);
                    rethrow(e);
                end
            elseif strcmp(param_category, 'hrv_time')
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                calcTimeStatistics(waitbar_handle);
                close(waitbar_handle);
            elseif strcmp(param_category, 'hrv_freq')
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                calcFrequencyStatistics(waitbar_handle);
                close(waitbar_handle);
            elseif strcmp(param_category, 'dfa') || strcmp(param_category, 'mse')
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                calcNonlinearStatistics(waitbar_handle);
                close(waitbar_handle);
            end
        end
    end
%%
    function set_config_Callback(src, ~, param_name)
        
        doCalc = true;
        cp_param_array = [];
        do_couple = false;
        param_category = strsplit(param_name, '.');
        
        min_suffix_ind = strfind(param_name, '.min');
        max_suffix_ind = strfind(param_name, '.max');
        
        screen_value = str2double(get(src, 'String'));
        prev_screen_value = get(src, 'UserData');
        
        string_screen_value = get(src, 'String');
        
        if regexpi(param_name, 'filtrr')
            custom_level = length(get(GUI.FilteringLevel_popupmenu, 'String'));
            items = get(GUI.Filtering_popupmenu, 'String');
            index_selected = get(GUI.Filtering_popupmenu, 'Value');
            Filter = items{index_selected};
        end
        
        if strcmp(param_name, 'hrv_freq.welch_overlap')
            if isnan(screen_value) || screen_value < 0 || screen_value >= 100
                errordlg(['set_config_Callback error: ' 'The value must be greater than 0 and less than 100!'], 'Input Error');
                set(src, 'String', prev_screen_value);
                return;
            end
        elseif strcmp(param_name, 'filtrr.quotient.rr_max_change')
            if isnan(screen_value) || screen_value <= 0 || screen_value > 100
                errordlg(['set_config_Callback error: ' 'The value must be greater than 0 and less than 100!'], 'Input Error');
                set(src, 'String', prev_screen_value);
                return;
            elseif strcmp(Filter, 'Quotient') || strcmp(Filter, 'Combined filters')
                set(GUI.FilteringLevel_popupmenu, 'Value', custom_level);
            end
        elseif regexp(param_name, 'filtrr.moving_average')
            if strcmp(param_name, 'filtrr.moving_average.win_threshold') && (isnan(screen_value) || screen_value < 0 || screen_value > 100)
                errordlg(['set_config_Callback error: ' 'The value must be greater than 0 and less than 100!'], 'Input Error');
                set(src, 'String', prev_screen_value);
                return;
            end
            if strcmp(param_name, 'filtrr.moving_average.win_length') && (isnan(screen_value) || screen_value < 1 || screen_value > length(DATA.rri))
                errordlg(['set_config_Callback error: ' 'The value must be greater than 0 and less than ' num2str(DATA.maxSignalLength/60) 'sec!'], 'Input Error');
                set(src, 'String', prev_screen_value);
                return;
            end
            if strcmp(Filter, 'Moving average') || strcmp(Filter, 'Combined filters')
                set(GUI.FilteringLevel_popupmenu, 'Value', custom_level);
            end
        elseif regexp(param_name, 'filtrr.range')
            if isnan(screen_value) || ~(screen_value > 0)
                errordlg(['set_config_Callback error: ' 'This parameter must be numeric positive single value!'], 'Input Error');
                set(src, 'String', prev_screen_value);
                return;
            elseif strcmp(Filter, 'Range') || strcmp(Filter, 'Combined filters')
                set(GUI.FilteringLevel_popupmenu, 'Value', custom_level);
            end
        elseif strcmp(param_name, 'hrv_freq.window_minutes')
            %             try
            %                 Spectral_Window_Length(GUI.SpectralWindowLengthHandle, string_screen_value);
            %                 set(GUI.Active_Window_Length, 'String', string_screen_value);
            
            [screen_value, isInputNumeric] = calcDurationInSeconds(GUI.SpectralWindowLengthHandle, string_screen_value, prev_screen_value*60);
            
            if isInputNumeric && screen_value <= 0
                errordlg('The spectral window length must be greater than 0 sec!', 'Input Error');
                return;
            elseif ~isInputNumeric
                return;
            end
            
            screen_value = screen_value / 60; % to minutes
            %                 doCalc = false;
            %             catch e
            %                 errordlg(e.message, 'Input Error');
            %                 return;
            %             end
        elseif  isnan(screen_value) || ~(screen_value > 0)
            errordlg(['set_config_Callback error: ' 'This parameter must be numeric positive single value!'], 'Input Error');
            set(src, 'String', prev_screen_value);
            return;
        end
        
        if ~isempty(min_suffix_ind)
            param_name = param_name(1 : min_suffix_ind - 1);
            min_param_value = screen_value;
            prev_param_array = mhrv_get_default(param_name);
            max_param_value = prev_param_array.value(2);
            
            if min_param_value > max_param_value
                errordlg(['set_config_Callback error: ' 'The min value must be less than max value!'], 'Input Error');
                set(src, 'String', prev_screen_value);
                return;
            end
            
            param_value = [min_param_value max_param_value];
            
            prev_param_value = prev_param_array.value(1);
            
            if strcmp(param_name, 'hrv_freq.lf_band')
                couple_name = 'hrv_freq.vlf_band';
                do_couple = true;
            elseif strcmp(param_name, 'hrv_freq.hf_band')
                couple_name = 'hrv_freq.lf_band';
                do_couple = true;
            end
            
            if do_couple
                cp_param_array = mhrv_get_default(couple_name);
                mhrv_set_default( couple_name, [cp_param_array.value(1) screen_value] );
                couple_handle = get(get(get(src, 'Parent'), 'Parent'), 'Children');
                set(findobj(couple_handle, 'Tag', [couple_name '.max']), 'String', num2str(screen_value));
            end
            
        elseif ~isempty(max_suffix_ind)
            param_name = param_name(1 : max_suffix_ind - 1);
            max_param_value = screen_value;
            prev_param_array = mhrv_get_default(param_name);
            min_param_value = prev_param_array.value(1);
            
            if max_param_value < min_param_value
                errordlg(['set_config_Callback error: ' 'The max value must be greater than min value!'], 'Input Error');
                set(src, 'String', prev_screen_value);
                return;
            end
            
            param_value = [min_param_value max_param_value];
            
            prev_param_value = prev_param_array.value(2);
            
            if strcmp(param_name, 'hrv_freq.vlf_band')
                couple_name = 'hrv_freq.lf_band';
                do_couple = true;
            elseif strcmp(param_name, 'hrv_freq.lf_band')
                couple_name = 'hrv_freq.hf_band';
                do_couple = true;
            end
            if do_couple
                cp_param_array = mhrv_get_default(couple_name);
                mhrv_set_default( couple_name, [screen_value cp_param_array.value(2)] );
                couple_handle = get(get(get(src, 'Parent'), 'Parent'), 'Children');
                set(findobj(couple_handle, 'Tag', [couple_name '.min']), 'String', num2str(screen_value));
            end
        else
            param_value = screen_value;
            prev_param_array = mhrv_get_default(param_name);
            prev_param_value = prev_param_array.value;
        end
        
        mhrv_set_default( param_name, param_value );
        
        %         if ~get(GUI.AutoCalc_checkbox, 'Value')
        %             DATA.custom_config_params(param_name) = param_value;
        %         end
        
        doFilt = 0;
        if regexpi(param_name, 'filtrr')
            DATA.custom_filters_thresholds.(param_category{2}).(param_category{3}) = param_value;
            if strcmp(Filter, 'Combined filters') && (strcmp(param_category{2}, 'moving_average') || strcmp(param_category{2}, 'range'))
                doFilt = 1;
            elseif strcmp(Filter, 'Moving average') && strcmp(param_category{2}, 'moving_average')
                doFilt = 1;
            elseif strcmp(Filter, 'Range') && strcmp(param_category{2}, 'range')
                doFilt = 1;
            elseif strcmp(Filter, 'Quotient') && strcmp(param_category{2}, 'quotient')
                doFilt = 1;
            end
        else
            doFilt = 1;
        end
        
        if get(GUI.AutoCalc_checkbox, 'Value')
            try
                if doCalc && doFilt
                    update_statistics(param_category(1));
                end
                set(src, 'UserData', screen_value);
            catch e
                errordlg(['set_config_Callback error: ' e.message], 'Input Error');
                
                mhrv_set_default( param_name, prev_param_array );
                
                if strcmp(param_name, 'hrv_freq.window_minutes')
                    set(src, 'String', calcDuration(prev_param_value*60, 0));
                else
                    set(src, 'String', num2str(prev_param_value));
                end
                
                if ~isempty(cp_param_array)
                    mhrv_set_default( couple_name, cp_param_array );
                    couple_handle = get(get(get(src, 'Parent'), 'Parent'), 'Children');
                    if ~isempty(min_suffix_ind)
                        set(findobj(couple_handle, 'Tag', [couple_name '.max']), 'String', num2str(prev_param_value))
                    elseif ~isempty(max_suffix_ind)
                        set(findobj(couple_handle, 'Tag', [couple_name '.min']), 'String', num2str(prev_param_value))
                    end
                end
            end
        end
    end
%%
    function onLoadCustomConfigFile( ~, ~)
        set_defaults_path();
        
        [Config_FileName, PathName] = uigetfile({'*.yml','Yaml-files (*.yml)'}, 'Open Configuration File', [DIRS.configDirectory filesep]);
        if ~isequal(Config_FileName, 0)
            params_filename = fullfile(PathName, Config_FileName);
            [pathstr, name, ~] = fileparts(params_filename);
            mhrv_load_defaults([pathstr filesep name]);
            DIRS.configDirectory = PathName;
            GUI.Mammal_popupmenu.Value = length(DATA.mammals);
            
            createConfigParametersInterface();
            reset_plot_Data();
            reset_plot_GUI();
            DATA.mammal_index = length(DATA.mammals);
        end
    end
%%
    function onSaveFilteredDataFile(filename)
        set_defaults_path();
        
        if ~isequal(DIRS.ExportResultsDirectory, 0)
            [~, filename, ~] = fileparts(filename);
            ext = ['.' DATA_Measure.Ext_save];
            full_file_name_filtered = fullfile(DIRS.ExportResultsDirectory, [filename '_flt' ext]);
            
            button = 'Yes';
            if exist(full_file_name_filtered, 'file')
                button = questdlg([full_file_name_filtered ' already exist. Do you want to overwrite it?'], 'Overwrite existing file?', 'Yes', 'No', 'No');
            end
            
            if strcmp(button, 'Yes')
                FilteredData_tnn = GUI.filtered_handle.XData';
                FilteredData_nni = GUI.filtered_handle.YData';
                
                FilteredData_tnn = FilteredData_tnn(~isnan(FilteredData_tnn));
                FilteredData_nni = FilteredData_nni(~isnan(FilteredData_nni));
                
                if strcmp(ext, '.txt')
                    psd_fileID = fopen(full_file_name_filtered, 'w');
                    
                    dlmwrite(full_file_name_filtered, [FilteredData_tnn FilteredData_nni], ...
                        'precision', '%10.5f\t\n', 'delimiter', '\t', 'newline', 'pc', '-append');
                    
                    fclose(psd_fileID);
                else
                    save(full_file_name_filtered, 'FilteredData_tnn', 'FilteredData_nni');
                end
            end
        end
    end
%%
    function onSaveParamFile( ~, ~ )
        
        set_defaults_path();
        
        [filename, results_folder_name] = uiputfile({'*.yml','Yaml Files (*.yml)'},'Choose Parameters File Name', [DIRS.configDirectory, filesep, [DATA.DataFileName '_' DATA.mammal] ]);
        
        if ~isequal(results_folder_name, 0)
            DIRS.configDirectory = results_folder_name;
            full_file_name = fullfile(results_folder_name, filename);
            mhrv_save_defaults( full_file_name );
            
            temp_mhrv_default_values = ReadYaml(full_file_name);
            
            temp_hrv_freq = temp_mhrv_default_values.hrv_freq;
            temp_mse = temp_mhrv_default_values.mse;
            
            temp_mhrv_default_values = rmfield(temp_mhrv_default_values, {'hrv_freq'; 'rqrs'; 'mhrv'});
            
            temp_hrv_freq = rmfield(temp_hrv_freq, {'methods'; 'power_methods'; 'extra_bands'});
            temp_mse = rmfield(temp_mse, {'mse_metrics'});
            
            temp_mhrv_default_values.hrv_freq = temp_hrv_freq;
            temp_mhrv_default_values.mse = temp_mse;
            
            result = WriteYaml(full_file_name, temp_mhrv_default_values);
        end
    end
%%
    function PSD_pushbutton_Callback( src, ~ )
        if get(src, 'Value')
            set(src, 'String', 'Log');
            DATA.freq_yscale = 'linear';
        else
            set(src, 'String', 'Linear');
            DATA.freq_yscale = 'log';
        end
        if ~isempty(DATA.FrStat.PlotData{DATA.active_window})
            plot_hrv_freq_spectrum(GUI.FrequencyAxes1, DATA.FrStat.PlotData{DATA.active_window}, 'detailed_legend', false, 'yscale', DATA.freq_yscale, 'clear', true);
        end
    end
%%
    function batch_Edit_Callback( src, ~ )
        
        src_tag = get(src, 'Tag');
        
        if strcmp(src_tag, 'segment_overlap')
            param_value = str2double(get(src, 'String'));
            if param_value >= 0 && param_value < 100
                isInputNumeric = 1;
            else
                old_param_val = DATA.AnalysisParams.(src_tag);
                set(src, 'String', num2str(old_param_val));
                warndlg('Please, check your input.');
                return;
            end
        else
            gui_value = get(src, 'String');
            [param_value, isInputNumeric] = calcDurationInSeconds(src, gui_value, DATA.AnalysisParams.(src_tag));
        end
        if isInputNumeric
            if strcmp(src_tag, 'segment_startTime')
                if param_value < 0 || param_value > DATA.AnalysisParams.segment_endTime || param_value > DATA.Filt_MaxSignalLength
                    set(src, 'String', calcDuration(DATA.AnalysisParams.(src_tag), 0));
                    errordlg('Selected segment start time must be grater than 0 and less than segment end!', 'Input Error');
                    return;
                end
            elseif strcmp(src_tag, 'segment_endTime')
                if param_value < DATA.AnalysisParams.segment_startTime || param_value > DATA.Filt_MaxSignalLength
                    set(src, 'String', calcDuration(DATA.AnalysisParams.(src_tag), 0));
                    %                     errordlg('Selected segment end time must be grater than 0 and less than segment length!', 'Input Error');
                    errordlg('Segment end time must be more than zero and less than the segment total length!', 'Input Error');
                    return;
                end
            elseif strcmp(src_tag, 'activeWin_length')
                if  param_value > DATA.Filt_MaxSignalLength
                    set(src, 'String', calcDuration(DATA.AnalysisParams.(src_tag), 0));
                    errordlg('Selected window length must be less than total signal length!', 'Input Error');
                    return;
                elseif param_value > DATA.AnalysisParams.segment_endTime - DATA.AnalysisParams.segment_startTime
                    set(src, 'String', calcDuration(DATA.AnalysisParams.(src_tag), 0));
                    errordlg('Selected window length must be less than or equal to the segment length!', 'Input Error');
                    return;
                elseif param_value <= 10
                    set(src, 'String', calcDuration(DATA.AnalysisParams.(src_tag), 0));
                    errordlg('Selected window size must be greater than 10 sec!', 'Input Error');
                    return;
                end
            end
            
            old_param_val = DATA.AnalysisParams.(src_tag);
            old_winNum = DATA.AnalysisParams.winNum;
            
            DATA.AnalysisParams.(src_tag) = param_value;
            calcBatchWinNum();
            
            if DATA.AnalysisParams.winNum < 1
                DATA.AnalysisParams.(src_tag) = old_param_val;
                set(src, 'String', calcDuration(old_param_val, 0));
                DATA.AnalysisParams.winNum = old_winNum;
                set(GUI.segment_winNum, 'String', num2str(DATA.AnalysisParams.winNum));
                return;
            else
                DATA.active_window = 1;
                clear_statistics_plots();
                clearStatTables();
                plotFilteredData();
                plotMultipleWindows();
                
                XData_active_window = get(GUI.rect_handle(1), 'XData');
                window_length = calcDuration(DATA.AnalysisParams.activeWin_length, 0);
                
                set(GUI.active_winNum, 'String', DATA.active_window);
                DATA.AnalysisParams.activeWin_startTime = XData_active_window(1);
                
                set(GUI.Active_Window_Start, 'String', calcDuration(DATA.AnalysisParams.activeWin_startTime, 0));
                set(GUI.Active_Window_Length, 'String', window_length);
                %                 set(GUI.SpectralWindowLengthHandle, 'String', window_length);
                setSliderProperties(GUI.Filt_RawDataSlider, DATA.Filt_MaxSignalLength, DATA.AnalysisParams.activeWin_length, DATA.AnalysisParams.activeWin_length/DATA.Filt_MaxSignalLength);
                set(GUI.Filt_RawDataSlider, 'Value', DATA.AnalysisParams.activeWin_startTime);
                set(GUI.blue_line, 'XData', [DATA.AnalysisParams.segment_startTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_startTime]);
            end
        end
    end
%%
    function calcBatchWinNum()
        
        if isfield(DATA.AnalysisParams, 'segment_startTime')
            
            analysis_segment_start_time = DATA.AnalysisParams.segment_startTime;
            analysis_segment_end_time = DATA.AnalysisParams.segment_endTime;
            activeWin_length = DATA.AnalysisParams.activeWin_length;
            segment_overlap = DATA.AnalysisParams.segment_overlap/100;
            
            % Last formula version
            %         DATA.AnalysisParams.winNum = floor((DATA.AnalysisParams.segment_endTime - DATA.AnalysisParams.segment_startTime - DATA.AnalysisParams.activeWin_length)/(DATA.AnalysisParams.activeWin_length*(1 - DATA.AnalysisParams.segment_overlap/100))) + 1;
            
            i = 0;
            while double(analysis_segment_start_time + activeWin_length) <= double(analysis_segment_end_time)  % int32
                analysis_segment_start_time = analysis_segment_start_time + (1-segment_overlap) * activeWin_length;
                i = i + 1;
            end
            
            DATA.AnalysisParams.winNum = i;
            if DATA.AnalysisParams.winNum > 0
                DATA.AnalysisParams.segment_effectiveEndTime = DATA.AnalysisParams.segment_startTime + activeWin_length + (DATA.AnalysisParams.winNum - 1) * (1 - segment_overlap) * activeWin_length;
            end
            
            set(GUI.segment_winNum, 'String', num2str(DATA.AnalysisParams.winNum));
            if DATA.AnalysisParams.winNum <= 0
                errordlg('Please, check your input! Windows number must be greater than 0!', 'Input Error');
            elseif DATA.AnalysisParams.winNum == 1
                GUI.Filt_RawDataSlider.Enable = 'on';
                GUI.Active_Window_Start.Enable = 'on';
                GUI.Active_Window_Length.Enable = 'on';
                GUI.SpectralWindowLengthHandle.Enable = 'on';
                GUI.active_winNum.Enable = 'inactive';
            else
                GUI.Filt_RawDataSlider.Enable = 'off';
                GUI.Active_Window_Start.Enable = 'inactive';
                GUI.Active_Window_Length.Enable = 'inactive';
                GUI.SpectralWindowLengthHandle.Enable = 'inactive';
                GUI.active_winNum.Enable = 'on';
                
                set(GUI.AutoCalc_checkbox, 'Value', 0);
                GUI.AutoCompute_pushbutton.Enable = 'on';
            end
        end
    end
%%
    function plotMultipleWindows()
        if isfield(DATA.AnalysisParams, 'winNum')
            batch_win_num = DATA.AnalysisParams.winNum;
            
            if batch_win_num > 0
                if isfield(GUI, 'rect_handle')
                    for i = 1 : length(GUI.rect_handle)
                        delete(GUI.rect_handle(i));
                    end
                end
                
                batch_window_start_time = DATA.AnalysisParams.segment_startTime;
                batch_window_length = DATA.AnalysisParams.activeWin_length;
                batch_overlap = DATA.AnalysisParams.segment_overlap/100;
                
                GUI.rect_handle = gobjects(batch_win_num, 1);
                f = [1 2 3 4];
                
                for i = 1 : batch_win_num
                    
                    v = [batch_window_start_time DATA.YLimUpperAxes.MinYLimit; batch_window_start_time + batch_window_length DATA.YLimUpperAxes.MinYLimit; batch_window_start_time + batch_window_length DATA.YLimUpperAxes.MaxYLimit; batch_window_start_time DATA.YLimUpperAxes.MaxYLimit];
                    
                    GUI.rect_handle(i) = patch('Faces' ,f, 'Vertices', v, 'FaceColor', DATA.rectangle_color, 'EdgeColor', DATA.rectangle_color, 'LineWidth', 0.5, 'FaceAlpha', 0.15, ...
                        'Parent', GUI.RRDataAxes, 'UserData', i);
                    
                    %                  GUI.rect_handle(i) = fill([batch_window_start_time batch_window_start_time batch_window_start_time + batch_window_length batch_window_start_time + batch_window_length], ...
                    %                     [DATA.MinYLimit DATA.MaxYLimit DATA.MaxYLimit DATA.MinYLimit], DATA.rectangle_color, 'LineWidth', 0.5, 'FaceAlpha', 0.15, 'Parent', GUI.RRDataAxes, ...
                    %                       'UserData', i); % 'ButtonDownFcn', @WindowButtonDownFcn_rect_handle, 'Tag', 'DoNotIgnore',
                    
                    if i == DATA.active_window
                        set(GUI.rect_handle(i), 'LineWidth', 2.5); % , 'FaceAlpha', 0.15
                        GUI.prev_act = GUI.rect_handle(i);
                    end
                    
                    batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
                end
                if isfield(GUI, 'RedLineHandle')
                    if isvalid(GUI.RedLineHandle)
                        uistack(GUI.RedLineHandle, 'top');
                    end
                end
            end
        end
    end
%%
    function calcTimeStatistics(waitbar_handle)
        if isfield(DATA, 'AnalysisParams')
            batch_window_start_time = DATA.AnalysisParams.segment_startTime;
            batch_window_length = DATA.AnalysisParams.activeWin_length;
            batch_overlap = DATA.AnalysisParams.segment_overlap/100;
            batch_win_num = DATA.AnalysisParams.winNum;
            
            hrv_time_metrics_tables = cell(batch_win_num, 1);
            
            for i = 1 : batch_win_num
                t0 = cputime;
                
                try
                    nni_window = DATA.nni(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
                    
                    waitbar(1 / 3, waitbar_handle, ['Calculating time measures for window ' num2str(i)]);
                    % Time Domain metrics
                    fprintf('[win % d: %.3f] >> mhrv: Calculating time-domain metrics...\n', i, cputime-t0);
                    [hrv_td, pd_time] = hrv_time(nni_window);
                    % Heart rate fragmentation metrics
                    fprintf('[win % d: %.3f] >> mhrv: Calculating fragmentation metrics...\n', i, cputime-t0);
                    hrv_frag = hrv_fragmentation(nni_window);
                    
                    DATA.TimeStat.PlotData{i} = pd_time;
                    
                    [timeData, timeRowsNames, timeDescriptions] = table2cell_StatisticsParam(hrv_td);
                    [fragData, fragRowsNames, fragDescriptions] = table2cell_StatisticsParam(hrv_frag);
                    
                    if ~DATA.GroupsCalc
                        if i == DATA.active_window
                            
                            GUI.TimeParametersTableRowName = timeRowsNames;
                            GUI.TimeParametersTableData = [timeDescriptions timeData];
                            GUI.TimeParametersTable.Data = [timeRowsNames timeData];
                            
                            GUI.FragParametersTableRowName = fragRowsNames;
                            GUI.FragParametersTableData = [fragDescriptions fragData];
                            GUI.FragParametersTable.Data = [fragRowsNames fragData];
                            
                            updateTimeStatistics();
                            plot_time_statistics_results(i);
                        end
                    end
                catch e
                    DATA.timeStatPartRowNumber = 0;
                    close(waitbar_handle);
                    errordlg(['hrv_time: ' e.message], 'Input Error');
                    rethrow(e);
                end
                
                curr_win_table = horzcat(hrv_td, hrv_frag);
                curr_win_table.Properties.RowNames{1} = sprintf('W%d', i);
                
                hrv_time_metrics_tables{i} = curr_win_table;
                
                if i == 1
                    DATA.TimeStat.RowsNames = [timeRowsNames; fragRowsNames];
                    DATA.TimeStat.Data = [[timeDescriptions; fragDescriptions] [timeData; fragData]];
                else
                    DATA.TimeStat.Data = [DATA.TimeStat.Data [timeData; fragData]];
                end
                batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
            end
            if ~DATA.GroupsCalc
                updateMainStatisticsTable(0, DATA.TimeStat.RowsNames, DATA.TimeStat.Data);
                [rn, ~] = size(DATA.TimeStat.RowsNames);
                DATA.timeStatPartRowNumber = rn;
            end
            % Create full table
            DATA.TimeStat.hrv_time_metrics = vertcat(hrv_time_metrics_tables{:});
            DATA.TimeStat.hrv_time_metrics.Properties.Description = sprintf('HRV time metrics for %s', DATA.DataFileName);
        end
    end
%%
    function fr_prop_variables_names = fix_fr_prop_var_names(fr_prop_variables_names)
        fr_prop_variables_names = cellfun(@(x) strrep(x, 'BETA', sprintf('\x3b2')), fr_prop_variables_names, 'UniformOutput', false);
        fr_prop_variables_names = cellfun(@(x) strrep(x, '_', sprintf(' ')), fr_prop_variables_names, 'UniformOutput', false);
        fr_prop_variables_names = cellfun(@(x) strrep(x, ' TO ', sprintf('/')), fr_prop_variables_names, 'UniformOutput', false);
        fr_prop_variables_names = cellfun(@(x) strrep(x, ' POWER', sprintf('')), fr_prop_variables_names, 'UniformOutput', false);
        fr_prop_variables_names = cellfun(@(x) strrep(x, 'TOTAL', sprintf('TOTAL POWER')), fr_prop_variables_names, 'UniformOutput', false);
    end
%%
    function calcFrequencyStatistics(waitbar_handle)
        
        if isfield(DATA, 'AnalysisParams')
            batch_window_start_time = DATA.AnalysisParams.segment_startTime;
            batch_window_length = DATA.AnalysisParams.activeWin_length;
            batch_overlap = DATA.AnalysisParams.segment_overlap/100;
            batch_win_num = DATA.AnalysisParams.winNum;
            
            hrv_fr_metrics_tables = cell(batch_win_num, 1);
            
            for i = 1 : batch_win_num
                
                t0 = cputime;
                
                try
                    nni_window = DATA.nni(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
                    
                    waitbar(2 / 3, waitbar_handle, ['Calculating frequency measures for window ' num2str(i)]);
                    % Freq domain metrics
                    fprintf('[win % d: %.3f] >> mhrv: Calculating frequency-domain metrics...\n', i, cputime-t0);
                    
                    if DATA.WinAverage
                        window_minutes = mhrv_get_default('hrv_freq.window_minutes');
                        [ hrv_fd, ~, ~, pd_freq ] = hrv_freq(nni_window, 'methods', {'welch','ar'}, 'power_methods', {'welch','ar'}, 'window_minutes', window_minutes.value);
                    else
                        [ hrv_fd, ~, ~, pd_freq ] = hrv_freq(nni_window, 'methods', {'welch','ar'}, 'power_methods', {'welch','ar'}, 'window_minutes', []);
                    end
                    
                    DATA.FrStat.PlotData{i} = pd_freq;
                    
                    %hrv_fd_lomb = hrv_fd(:, find(cellfun(@(x) ~isempty(regexpi(x, '_lomb')), hrv_fd.Properties.VariableNames)));
                    hrv_fd_ar = hrv_fd(:, find(cellfun(@(x) ~isempty(regexpi(x, '_ar')), hrv_fd.Properties.VariableNames)));
                    hrv_fd_welch = hrv_fd(:, find(cellfun(@(x) ~isempty(regexpi(x, 'welch')), hrv_fd.Properties.VariableNames)));
                    
                    %[fd_lombData, fd_LombRowsNames, fd_lombDescriptions] = table2cell_StatisticsParam(hrv_fd_lomb);
                    [fd_arData, fd_ArRowsNames, fd_ArDescriptions] = table2cell_StatisticsParam(hrv_fd_ar);
                    [fd_welchData, fd_WelchRowsNames, fd_WelchDescriptions] = table2cell_StatisticsParam(hrv_fd_welch);
                    fd_ArRowsNames_NO_GreekLetters = fd_ArRowsNames;
                    fd_WelchRowsNames_NO_GreekLetters = fd_WelchRowsNames;
                    
                    fd_ArRowsNames = fix_fr_prop_var_names(fd_ArRowsNames);
                    fd_WelchRowsNames = fix_fr_prop_var_names(fd_WelchRowsNames);
                    
                    if ~DATA.GroupsCalc
                        if i == DATA.active_window
                            GUI.FrequencyParametersTableRowName = strrep(fd_WelchRowsNames, 'WELCH', '');
                            GUI.FrequencyParametersTable.Data = [GUI.FrequencyParametersTableRowName fd_welchData fd_arData];
                            plot_frequency_statistics_results(i);
                        end
                    end
                catch e
                    DATA.frequencyStatPartRowNumber = 0;
                    close(waitbar_handle);
                    errordlg(['hrv_freq: ' e.message], 'Input Error');
                    rethrow(e);
                end
                
                curr_win_table = horzcat(hrv_fd_ar, hrv_fd_welch);
                curr_win_table.Properties.RowNames{1} = sprintf('W%d', i);
                
                hrv_fr_metrics_tables{i} = curr_win_table;
                
                if i == 1
                    DATA.FrStat.ArWindowsData.RowsNames = fd_ArRowsNames;
                    DATA.FrStat.WelchWindowsData.RowsNames = fd_WelchRowsNames;
                    
                    DATA.FrStat.ArWindowsData.RowsNames_NO_GreekLetters = fd_ArRowsNames_NO_GreekLetters;
                    DATA.FrStat.WelchWindowsData.RowsNames_NO_GreekLetters = fd_WelchRowsNames_NO_GreekLetters;
                    
                    DATA.FrStat.ArWindowsData.Data = [fd_ArDescriptions fd_arData];
                    DATA.FrStat.WelchWindowsData.Data = [fd_WelchDescriptions fd_welchData];
                else
                    DATA.FrStat.ArWindowsData.Data = [DATA.FrStat.ArWindowsData.Data fd_arData];
                    DATA.FrStat.WelchWindowsData.Data = [DATA.FrStat.WelchWindowsData.Data fd_welchData];
                end
                
                batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
            end
            if ~DATA.GroupsCalc
                [StatRowsNames, StatData] = setFrequencyMethodData();
                updateMainStatisticsTable(DATA.timeStatPartRowNumber, StatRowsNames, StatData);
                [rn, ~] = size(StatRowsNames);
                DATA.frequencyStatPartRowNumber = rn;
            end
            % Create full table
            DATA.FrStat.hrv_fr_metrics = vertcat(hrv_fr_metrics_tables{:});
            DATA.FrStat.hrv_fr_metrics.Properties.Description = sprintf('HRV frequency metrics for %s', DATA.DataFileName);
        end
    end
%%
    function calcNonlinearStatistics(waitbar_handle)
        
        batch_window_start_time = DATA.AnalysisParams.segment_startTime;
        batch_window_length = DATA.AnalysisParams.activeWin_length;
        batch_overlap = DATA.AnalysisParams.segment_overlap/100;
        batch_win_num = DATA.AnalysisParams.winNum;
        
        hrv_nonlin_metrics_tables = cell(batch_win_num, 1);
        
        for i = 1 : batch_win_num
            
            t0 = cputime;
            
            try
                nni_window = DATA.nni(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
                
                waitbar(3 / 3, waitbar_handle, ['Calculating nolinear measures for window ' num2str(i)]);
                fprintf('[win % d: %.3f] >> mhrv: Calculating nonlinear metrics...\n', i, cputime-t0);
                [hrv_nl, pd_nl] = hrv_nonlinear(nni_window);
                
                DATA.NonLinStat.PlotData{i} = pd_nl;
                
                [nonlinData, nonlinRowsNames, nonlinDescriptions] = table2cell_StatisticsParam(hrv_nl);
                nonlinRowsNames_NO_GreekLetters = nonlinRowsNames;
                
                nonlinRowsNames = cellfun(@(x) strrep(x, 'alpha1', sprintf('\x3b1\x2081')), nonlinRowsNames, 'UniformOutput', false);
                nonlinRowsNames = cellfun(@(x) strrep(x, 'alpha2', sprintf('\x3b1\x2082')), nonlinRowsNames, 'UniformOutput', false);
                nonlinRowsNames = cellfun(@(x) strrep(x, 'SD1', sprintf('SD\x2081')), nonlinRowsNames, 'UniformOutput', false);
                nonlinRowsNames = cellfun(@(x) strrep(x, 'SD2', sprintf('SD\x2082')), nonlinRowsNames, 'UniformOutput', false);
                
                if ~DATA.GroupsCalc
                    if i == DATA.active_window
                        GUI.NonLinearTableRowName = nonlinRowsNames;
                        GUI.NonLinearTableData = [nonlinDescriptions nonlinData];
                        GUI.NonLinearTable.Data = [nonlinRowsNames nonlinData];
                        
                        plot_nonlinear_statistics_results(i);
                    end
                end
            catch e
                close(waitbar_handle);
                errordlg(['hrv_nonlinear: ' e.message], 'Input Error');
                rethrow(e);
            end
            
            curr_win_table = hrv_nl;
            curr_win_table.Properties.RowNames{1} = sprintf('W%d', i);
            
            hrv_nonlin_metrics_tables{i} = curr_win_table;
            
            if i == 1
                DATA.NonLinStat.RowsNames = nonlinRowsNames;
                DATA.NonLinStat.RowsNames_NO_GreekLetters = nonlinRowsNames_NO_GreekLetters;
                DATA.NonLinStat.Data = [nonlinDescriptions nonlinData];
            else
                DATA.NonLinStat.Data = [DATA.NonLinStat.Data nonlinData];
            end
            
            batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
        end
        if ~DATA.GroupsCalc
            updateMainStatisticsTable(DATA.timeStatPartRowNumber + DATA.frequencyStatPartRowNumber, DATA.NonLinStat.RowsNames, DATA.NonLinStat.Data);
        end
        % Create full table
        DATA.NonLinStat.hrv_nonlin_metrics = vertcat(hrv_nonlin_metrics_tables{:});
        DATA.NonLinStat.hrv_nonlin_metrics.Properties.Description = sprintf('HRV non linear metrics for %s', DATA.DataFileName);
    end

%%
    function calcStatistics()
        if isfield(DATA, 'AnalysisParams')
            GUI.StatisticsTable.ColumnName = {'Description'};
            
            if DATA.AnalysisParams.winNum == 1
                GUI.StatisticsTable.ColumnName = cat(1, GUI.StatisticsTable.ColumnName, 'Values');
            else
                for i = 1 : DATA.AnalysisParams.winNum
                    GUI.StatisticsTable.ColumnName = cat(1, GUI.StatisticsTable.ColumnName, ['W' num2str(i)]);
                end
            end
            
            waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            
            try
                calcTimeStatistics(waitbar_handle);
            catch
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            end
            try
                calcFrequencyStatistics(waitbar_handle);
            catch
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            end
            try
                calcNonlinearStatistics(waitbar_handle);
            catch
            end
            if ishandle(waitbar_handle)
                close(waitbar_handle);
            end
        end
    end
%%
%     function RunMultSegments_pushbutton_Callback( ~, ~ )
%         clear_statistics_plots();
%         clearStatTables();
%
% %         set(GUI.Active_Window_Length, 'Enable', 'inactive');
% %         set(GUI.Active_Window_Start, 'Enable', 'inactive');
% %         set(GUI.SpectralWindowLengthHandle, 'Enable', 'inactive');
%         calcStatistics();
%     end
%%
    function AutoCompute_pushbutton_Callback( ~, ~ )
        clear_statistics_plots();
        clearStatTables();
        
        calcStatistics();
    end
%%
    function set_active_window(hObject)
        if isfield(GUI, 'prev_act')
            set(GUI.prev_act, 'LineWidth', 0.5, 'FaceAlpha', 0.15);
        end
        set(hObject, 'LineWidth', 2.5, 'FaceAlpha', 0.15);
        GUI.prev_act = hObject;
        
        XData_active_window = get(hObject, 'XData');
        DATA.AnalysisParams.activeWin_startTime = XData_active_window(1);
        set(GUI.Active_Window_Start, 'String', calcDuration(DATA.AnalysisParams.activeWin_startTime, 0));
        
        if isfield(DATA, 'TimeStat') && ~isempty(DATA.TimeStat) && isfield(DATA.TimeStat, 'RowsNames')
            GUI.TimeParametersTable.Data = [DATA.TimeStat.RowsNames DATA.TimeStat.Data(:, DATA.active_window + 1)];
            plot_time_statistics_results(DATA.active_window);
        end
        if isfield(DATA, 'FrStat') && ~isempty(DATA.FrStat)&& isfield(DATA.FrStat, 'WelchWindowsData')
            GUI.FrequencyParametersTable.Data = [strrep(DATA.FrStat.WelchWindowsData.RowsNames,'_WELCH', '') DATA.FrStat.WelchWindowsData.Data(:, DATA.active_window + 1) DATA.FrStat.ArWindowsData.Data(:, DATA.active_window + 1)];
            plot_frequency_statistics_results(DATA.active_window);
        end
        if isfield(DATA, 'NonLinStat') && ~isempty(DATA.NonLinStat)&& isfield(DATA.NonLinStat, 'RowsNames')
            GUI.NonLinearTable.Data = [DATA.NonLinStat.RowsNames DATA.NonLinStat.Data(:, DATA.active_window + 1)];
            plot_nonlinear_statistics_results(DATA.active_window);
        end
    end
%%
    function active_winNum_Edit_Callback( src, ~ )
        value = str2double(get(src, 'String'));
        if ~isnan(value) && value > 0 && value <= DATA.AnalysisParams.winNum
            DATA.active_window = value;
            set_active_window(GUI.rect_handle(value));
        else
            set(src, 'String', num2str(DATA.active_window));
            errordlg(['Selected window number must be greater than 0 and less than ', num2str(DATA.AnalysisParams.winNum), '!'], 'Input Error');
        end
    end
%%
    function Full_Length_pushbutton_Callback( ~, ~ )
        
        if ~isempty(DATA.maxSignalLength)
            src_tag1 = 'segment_endTime';
            src_tag2 = 'segment_startTime';
            
            set(GUI.segment_endTime, 'String', calcDuration(DATA.maxSignalLength, 0));
            set(GUI.segment_startTime, 'String', calcDuration(0, 0));
            
            DATA.active_window = 1;
            DATA.AnalysisParams.(src_tag1) = DATA.maxSignalLength;
            DATA.AnalysisParams.(src_tag2) = 0;
            clear_statistics_plots();
            clearStatTables();
            calcBatchWinNum();
            plotFilteredData();
            plotMultipleWindows();
            
            if isfield(GUI, 'rect_handle')
                XData_active_window = get(GUI.rect_handle(1), 'XData');
                set(GUI.Active_Window_Start, 'String', calcDuration(XData_active_window(1), 0));
                set(GUI.active_winNum, 'String', DATA.active_window);
                set(GUI.blue_line, 'XData', [DATA.AnalysisParams.segment_startTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_startTime]);
            end
        end
    end
%%
    function AutoScaleYLowAxes_pushbutton_Callback( src, ~ )
        if get(src, 'Value') == 1 % Auto Scale Y Low Axes
            set(GUI.MinYLimitLowAxes_Edit, 'String', num2str(DATA.AutoYLimitLowAxes.RRMinYLimit));
            set(GUI.MaxYLimitLowAxes_Edit, 'String', num2str(DATA.AutoYLimitLowAxes.RRMaxYLimit));
        else
            SetMinMaxYLimitLowAxes();
        end
        setAutoYAxisLimLowAxes(get(GUI.AllDataAxes, 'XLim'));
        DATA.YLimLowAxes = setYAxesLim(GUI.AllDataAxes, GUI.AutoScaleYLowAxes_checkbox, GUI.MinYLimitLowAxes_Edit, GUI.MaxYLimitLowAxes_Edit, DATA.YLimLowAxes, DATA.AutoYLimitLowAxes);
        set_rectangles_YData();
    end
%%
    function AutoScaleYUpperAxes_pushbutton_Callback( src, ~ )
        
        if get(src, 'Value') == 1 % Auto Scale Y
            set(GUI.MinYLimitUpperAxes_Edit, 'String', num2str(DATA.AutoYLimitUpperAxes.MinYLimit));
            set(GUI.MaxYLimitUpperAxes_Edit, 'String', num2str(DATA.AutoYLimitUpperAxes.MaxYLimit));
        else
            SetMinMaxYLimitUpperAxes();
        end
        
        DATA.YLimUpperAxes = setYAxesLim(GUI.RRDataAxes, GUI.AutoScaleYUpperAxes_checkbox, GUI.MinYLimitUpperAxes_Edit, GUI.MaxYLimitUpperAxes_Edit, DATA.YLimUpperAxes, DATA.AutoYLimitUpperAxes);
        plotDataQuality();
        plotMultipleWindows();
    end
%%
    function ShowLegend_checkbox_Callback( src, ~ )
        if get(src, 'Value') == 1
            DATA.legend_handle.Visible = 'on';
        else
            DATA.legend_handle.Visible = 'off';
        end
    end
%%
    function EnablePageUpDown()
        xdata = get(GUI.red_rect, 'XData');
        
        if ~isempty(xdata)
            if xdata(2) == DATA.maxSignalLength
                GUI.PageUpButton.Enable = 'off';
            else
                GUI.PageUpButton.Enable = 'on';
            end
            if xdata(1) == 0
                GUI.PageDownButton.Enable = 'off';
            else
                GUI.PageDownButton.Enable = 'on';
            end
        end
    end
%%
    function my_WindowKeyPressFcn(~, ~, ~)
        DATA.Action = 'zoom';
    end
%%
    function my_WindowKeyReleaseFcn(~, ~, ~)
        DATA.Action = 'move';
    end
%%
    function my_WindowScrollWheelFcn(~, callbackdata, ~)
        
        try
            hObj = hittest(GUI.Window);
            status = any(ismember([GUI.rect_handle,GUI.RRDataAxes],hObj));
        catch
            status = 1;
        end
        
        if callbackdata.VerticalScrollCount > 0
            direction = 1;
        elseif callbackdata.VerticalScrollCount < 0
            direction = -1;
        end
        
        % Up axes
        if (isfield(GUI, 'red_rect') && isvalid(GUI.red_rect)) && status
            switch DATA.Action
                case 'zoom'
                    cp = get(GUI.RRDataAxes, 'CurrentPoint');
                    xdata = get(GUI.red_rect, 'XData');
                    
                    delta_x1 = cp(1, 1) - xdata(1);
                    delta_x2 = xdata(2) - cp(1, 1);
                    
                    xdata([1, 4, 5]) = xdata(1) + direction * 0.1 * delta_x1;
                    xdata([2, 3]) = xdata(2) - direction * 0.1 * delta_x2;
                    
                    RR_XLim = get(GUI.AllDataAxes,  'XLim');
                    min_XLim = min(RR_XLim);
                    max_XLim = max(RR_XLim);
                    
                    if xdata(2) <= xdata(1)
                        return;
                    end
                    
                    if min(xdata) < min_XLim
                        xdata([1, 4, 5]) = min_XLim;
                    end
                    if max(xdata) > max_XLim
                        xdata([2, 3]) = max_XLim ;
                    end
                    
                    ChangePlot(xdata);
                    set(GUI.red_rect, 'XData', xdata);
                    
                    EnablePageUpDown();
                otherwise
            end
            % down axes
        elseif (isfield(GUI, 'red_rect') && isvalid(GUI.red_rect)) % && (any(ismember([hObj, hObj.Parent], GUI.AllDataAxes)))
            switch DATA.Action
                case 'zoom'
                    RRIntPage_Length = get(GUI.RRIntPage_Length, 'String');
                    [RRIntPage_Length, isInputNumeric] = calcDurationInSeconds(GUI.RRIntPage_Length, RRIntPage_Length, DATA.RRIntPage_Length);
                    if direction > 0
                        RRIntPage_Length = RRIntPage_Length * 0.9;
                    else
                        RRIntPage_Length = RRIntPage_Length * 1.1;
                    end
                    set_RRIntPage_Length(RRIntPage_Length, 2);
                case 'move'
                    if direction > 0
                        page_down_pushbutton_Callback({}, 0);
                    else
                        page_up_pushbutton_Callback({}, 0);
                    end
                otherwise
            end
        end
        
    end
%%
    function my_WindowButtonUpFcn (src, callbackdata, handles)
        set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
        %         pause(0.75);
        refresh(GUI.Window);
        if DATA.doCalc
            if strcmp(DATA.hObject, 'window_blue_rect') || strcmp(DATA.hObject, 'right_resize_blue_rect') || strcmp(DATA.hObject, 'left_resize_blue_rect')|| strcmp(DATA.hObject, 'segment_marker')
                clear_statistics_plots();
                clearStatTables();
                calcBatchWinNum();
                plotFilteredData();
                plotMultipleWindows();
                if get(GUI.AutoCalc_checkbox, 'Value')
                    calcStatistics();
                end
            end
        end
        DATA.doCalc = false;
    end
%%
    function my_WindowButtonMotionFcn(src, callbackdata, type)
        switch type
            case 'init'
                if (hittest(GUI.Window) == GUI.RRDataAxes || get(hittest(GUI.Window), 'Parent') == GUI.RRDataAxes)
                    DATA.zoom_handle.Enable = 'off';
                    if isfield(DATA, 'AnalysisParams') && DATA.AnalysisParams.winNum == 1
                        try
                            if isfield(GUI, 'rect_handle')
                                DATA.zoom_handle.Enable = 'off';
                                xdata = get(GUI.rect_handle, 'XData');
                                point1 = get(GUI.RRDataAxes, 'CurrentPoint');
                                eps = (max(get(GUI.RRDataAxes,  'XLim')) - min(get(GUI.RRDataAxes,  'XLim')))*0.01;
                                if point1(1, 1) >= DATA.firstSecond2Show && point1(1, 1) <= DATA.firstSecond2Show + DATA.MyWindowSize
                                    if  point1(1,1) <= max(xdata) + eps && point1(1,1) >= max(xdata) - eps
                                        setptr(GUI.Window, 'lrdrag');
                                        DATA.hObject = 'right_resize_blue_rect';
                                    elseif  point1(1,1) <= min(xdata) + eps && point1(1,1) >= min(xdata) - eps
                                        setptr(GUI.Window, 'lrdrag');
                                        DATA.hObject = 'left_resize_blue_rect';
                                    elseif point1(1,1) < max(xdata) && point1(1,1) > min(xdata)
                                        setptr(GUI.Window, 'hand');
                                        DATA.hObject = 'window_blue_rect';
                                    else
                                        setptr(GUI.Window, 'arrow');
                                        DATA.hObject = 'overall';
                                    end
                                end
                            end
                        catch
                        end
                    end
                elseif hittest(GUI.Window) == GUI.blue_line
                    DATA.zoom_handle.Enable = 'off';
                    setptr(GUI.Window, 'closedhand');
                    DATA.hObject = 'segment_marker';
                elseif hittest(GUI.Window) == GUI.AllDataAxes || get(hittest(GUI.Window), 'Parent') == GUI.AllDataAxes
                    try
                        xdata = get(GUI.red_rect, 'XData');
                        max_xdata_red_rect = max(xdata);
                        min_xdata_red_rect = min(xdata);
                        point1 = get(GUI.AllDataAxes, 'CurrentPoint');
                        if point1(1, 1) >= 0 && point1(1, 1) <= DATA.maxSignalLength
                            DATA.zoom_handle.Enable = 'off';
                            eps = (max_xdata_red_rect - min_xdata_red_rect) * 0.1;
                            if  point1(1,1) <= max_xdata_red_rect + eps && point1(1,1) >= max_xdata_red_rect - eps
                                setptr(GUI.Window, 'lrdrag');
                                DATA.hObject = 'right_resize';
                            elseif  point1(1,1) <= min_xdata_red_rect + eps && point1(1,1) >= min_xdata_red_rect - eps
                                setptr(GUI.Window, 'lrdrag');
                                DATA.hObject = 'left_resize';
                            elseif point1(1,1) < max_xdata_red_rect && point1(1,1) > min_xdata_red_rect
                                setptr(GUI.Window, 'hand');
                                DATA.hObject = 'window';
                            else
                                setptr(GUI.Window, 'arrow');
                                DATA.hObject = 'overall';
                            end
                        end
                    catch
                    end
                else
                    setptr(GUI.Window, 'arrow');
                    DATA.hObject = 'figure';
                    DATA.zoom_handle.Enable = 'on';
                end
            case 'window_move'
                Window_Move('normal');
            case 'window_resize'
                Window_Move('open');
            case 'right_resize_move'
                LR_Resize('right');
            case 'left_resize_move'
                LR_Resize('left');
            case 'window_move_blue_rect'
                Segment_Move('normal');
            case 'right_resize_move_blue_rect'
                Segment_LR_Resize('right');
            case 'left_resize_move_blue_rect'
                Segment_LR_Resize('left');
            case 'segment_marker_move'
                Segment_Marker_Move('normal');
            otherwise
        end
    end
%%
    function my_clickOnAllData(src, callbackdata, handles)
        
        if isfield(GUI, 'rect_handle') && isfield(DATA, 'AnalysisParams')
            current_object = hittest(GUI.Window);
            if ismember(current_object, GUI.rect_handle) && DATA.AnalysisParams.winNum ~= 1
                DATA.active_window = get(current_object, 'UserData');
                set(GUI.active_winNum, 'String', DATA.active_window);
                uistack(current_object, 'down');
                set_active_window(current_object);
            end
            
            prev_point = get(GUI.AllDataAxes, 'CurrentPoint');
            DATA.prev_point = prev_point(1, 1);
            prev_point = get(GUI.RRDataAxes, 'CurrentPoint');
            DATA.prev_point_segment = prev_point(1, 1);
            
            if DATA.AnalysisParams.winNum == 1
                blue_rect_xdata = get(GUI.rect_handle, 'XData');
                RawDataAxes_XLim = get(GUI.RRDataAxes, 'XLim');
                DATA.minXLimRawDataAxes = min(RawDataAxes_XLim);
                DATA.left_limit = min(blue_rect_xdata);
                DATA.maxXLimRawDataAxes = max(RawDataAxes_XLim);
                DATA.right_limit = max(blue_rect_xdata);
            end
            
            switch DATA.hObject
                case 'window'
                    switch get(GUI.Window, 'selectiontype')
                        case 'normal'
                            set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'window_move'});
                        case 'open'
                            Window_Move('open');
                        otherwise
                    end
                case 'left_resize'
                    set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'left_resize_move'});
                case 'right_resize'
                    set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'right_resize_move'});
                case 'window_blue_rect'
                    switch get(GUI.Window, 'selectiontype')
                        case 'normal'
                            set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'window_move_blue_rect'});
                        case 'open'
                        otherwise
                    end
                case 'left_resize_blue_rect'
                    set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'left_resize_move_blue_rect'});
                case 'right_resize_blue_rect'
                    set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'right_resize_move_blue_rect'});
                case 'segment_marker'
                    switch get(GUI.Window, 'selectiontype')
                        case 'normal'
                            set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'segment_marker_move'});
                    end
                otherwise
            end
        end
    end
%%
    function rect_xdata = set_rect_limits(rect_xdata, ind, xofs)
        rect_xdata(ind) = rect_xdata(ind) + xofs;
    end
%%
    function Segment_LR_Resize(type)
        point1 = get(GUI.RRDataAxes, 'CurrentPoint');
        xdata = get(GUI.rect_handle, 'XData');
        xdata_saved = xdata;
        xofs = point1(1,1) - DATA.prev_point_segment;
        DATA.prev_point_segment = point1(1, 1);
        
        RawDataAxes_XLim = get(GUI.RRDataAxes,  'XLim');
        
        min_XLim = min(RawDataAxes_XLim);
        max_XLim = max(RawDataAxes_XLim);
        
        switch type
            case 'left'
                xdata = set_rect_limits(xdata, [1, 4], xofs);
            case 'right'
                xdata = set_rect_limits(xdata, [2, 3], xofs);
        end
        if xdata(2) - xdata(1) < 11 % 11 sec min segment length
            return;
        end
        if DATA.right_limit > DATA.maxXLimRawDataAxes
            if min(xdata) < min_XLim || min(xdata) > max_XLim
                return;
            end
        elseif DATA.left_limit < DATA.minXLimRawDataAxes
            if max(xdata) < min_XLim || max(xdata) > max_XLim
                return;
            end
        elseif min(xdata) < min_XLim
            xofs_updated = min_XLim - min(xdata_saved);
            xdata([1, 4]) = xdata_saved([1, 4]) + xofs_updated;
        elseif max(xdata) > max_XLim
            xofs_updated = max_XLim - max(xdata_saved);
            xdata([2, 3]) = xdata_saved([2, 3]) + xofs_updated;
        end
        set(GUI.rect_handle, 'XData', xdata);
        DATA.doCalc = true;
        UpdateParametersFields(xdata);
    end
%%
    function LR_Resize(type)
        xdata = get(GUI.red_rect, 'XData');
        xdata_saved = xdata;
        point1 = get(GUI.AllDataAxes, 'CurrentPoint');
        xofs = point1(1,1) - DATA.prev_point;
        DATA.prev_point = point1(1, 1);
        
        min_XLim = min(get(GUI.AllDataAxes,  'XLim'));
        max_XLim = max(get(GUI.AllDataAxes,  'XLim'));
        
        switch type
            case 'left'
                xdata([1, 4, 5]) = xdata([1, 4, 5]) + xofs;
            case 'right'
                xdata([2, 3]) = xdata([2, 3]) + xofs;
        end
        if xdata(2) <= xdata(1)
            return;
        end
        if min(xdata) < min_XLim
            xofs_updated = min_XLim - min(xdata_saved);
            xdata([1, 4, 5]) = xdata_saved([1, 4, 5]) + xofs_updated;
        elseif max(xdata) > max_XLim
            xofs_updated = max_XLim - max(xdata_saved);
            xdata([2, 3]) = xdata_saved([2, 3]) + xofs_updated;
        end
        
        ChangePlot(xdata);
        set(GUI.red_rect, 'XData', xdata);
        
        EnablePageUpDown();
    end
%%
    function Segment_Marker_Move(type)
        xdata = get(GUI.blue_line, 'XData');
        xdata_saved = xdata;
        point1 = get(GUI.AllDataAxes, 'CurrentPoint');
        xofs = point1(1,1) - DATA.prev_point;
        DATA.prev_point = point1(1, 1);
        
        switch type
            case 'normal'
                xdata = xdata + xofs;
        end
        if xdata(1) < 0
            xdata([1, 4]) = 0;
            xdata([2, 3]) = DATA.AnalysisParams.segment_endTime;
        elseif DATA.AnalysisParams.segment_endTime + xofs > DATA.Filt_MaxSignalLength
            xofs_updated = DATA.Filt_MaxSignalLength - DATA.AnalysisParams.segment_endTime;
            xdata = xdata_saved + xofs_updated;
        end
        set(GUI.blue_line, 'XData', xdata);
        
        DATA.AnalysisParams.segment_startTime = xdata(1);
        
        segment_effectiveEndTime = DATA.AnalysisParams.segment_startTime + DATA.AnalysisParams.activeWin_length + (DATA.AnalysisParams.winNum - 1) * (1 - DATA.AnalysisParams.segment_overlap/100) * DATA.AnalysisParams.activeWin_length;
        DATA.AnalysisParams.segment_endTime = segment_effectiveEndTime;
        
        DATA.AnalysisParams.activeWin_startTime = DATA.AnalysisParams.activeWin_startTime + (xdata(1) - xdata_saved(1));
        
        set(GUI.Filt_RawDataSlider, 'Value', min(xdata(1), get(GUI.Filt_RawDataSlider, 'Max')));
        set(GUI.segment_startTime, 'String', calcDuration(DATA.AnalysisParams.segment_startTime, 0));
        set(GUI.segment_endTime, 'String', calcDuration(DATA.AnalysisParams.segment_endTime, 0));
        set(GUI.Active_Window_Start, 'String', calcDuration(DATA.AnalysisParams.activeWin_startTime, 0));
        
        plotMultipleWindows();
        DATA.doCalc = true;
    end
%%
    function Segment_Move(type)
        xdata = get(GUI.rect_handle, 'XData');
        xdata_saved = xdata;
        point1 = get(GUI.RRDataAxes, 'CurrentPoint');
        xofs = point1(1,1) - DATA.prev_point_segment;
        DATA.prev_point_segment = point1(1, 1);
        
        min_XLim = min(get(GUI.RRDataAxes,  'XLim'));
        max_XLim = max(get(GUI.RRDataAxes,  'XLim'));
        try
            switch type
                case 'normal'
                    xdata = xdata + xofs;
            end
        catch e
            disp(e);
        end
        if DATA.left_limit < DATA.minXLimRawDataAxes
            if max(xdata) < min_XLim || max(xdata) > max_XLim
                return;
            end
        elseif DATA.right_limit > DATA.maxXLimRawDataAxes
            if min(xdata) < min_XLim || min(xdata) > max_XLim
                return;
            end
        elseif min(xdata) < min_XLim
            xofs_updated = min_XLim - min(xdata_saved);
            xdata = xdata_saved + xofs_updated;
        elseif max(xdata) > max_XLim
            xofs_updated = max_XLim - max(xdata_saved);
            xdata = xdata_saved + xofs_updated;
        end
        %         DATA.left_limit = xdata(1);
        %         DATA.right_limit = xdata(3);
        DATA.left_limit = min(xdata);
        DATA.right_limit = max(xdata);
        set(GUI.rect_handle, 'XData', xdata);
        DATA.doCalc = true;
        UpdateParametersFields(xdata);
    end
%%
    function Window_Move(type)
        
        xdata = get(GUI.red_rect, 'XData');
        xdata_saved = xdata;
        point1 = get(GUI.AllDataAxes, 'CurrentPoint');
        xofs = (point1(1,1) -  DATA.prev_point);
        DATA.prev_point = point1(1, 1);
        
        %         min_XLim = min(get(GUI.AllDataAxes, 'XLim'));
        %         max_XLim = max(get(GUI.AllDataAxes, 'XLim'));
        %
        min_XLim = 0;
        max_XLim = DATA.maxSignalLength;
        
        AllDataAxes_XLim = get(GUI.AllDataAxes, 'XLim');
        prev_minLim = min(AllDataAxes_XLim);
        prev_maxLim = max(AllDataAxes_XLim);
        
        switch type
            case 'normal'
                xdata = xdata + xofs;
            case 'open'
                xdata([1, 4, 5]) = prev_minLim;
                %                 xdata([2, 3]) = DATA.maxSignalLength;
                xdata([2, 3]) = prev_maxLim;
        end
        if min(xdata) < min_XLim
            xofs_updated = min_XLim - min(xdata_saved);
            xdata = xdata_saved + xofs_updated;
        elseif max(xdata) > max_XLim
            xofs_updated = max_XLim - max(xdata_saved);
            xdata = xdata_saved + xofs_updated;
        end
        ChangePlot(xdata);
        set(GUI.red_rect, 'XData', xdata);
        
        EnablePageUpDown();
        
        set_ticks = 0;
        if xdata(2) > prev_maxLim %% xdata(1) > prev_maxLim &&
            AllDataAxes_offset = xdata(2) - prev_maxLim;
            set_ticks = 1;
        elseif xdata(1) < prev_minLim %% xdata(2) < prev_minLim &&
            AllDataAxes_offset = xdata(1) - prev_minLim;
            set_ticks = 1;
        end
        if set_ticks
            set(GUI.AllDataAxes, 'XLim', AllDataAxes_XLim + AllDataAxes_offset);
            setAxesXTicks(GUI.AllDataAxes);
        end
    end
%%
%     function setAxesXTicks(axes_handle)
%         x_ticks_array = get(axes_handle, 'XTick');
%         set(axes_handle, 'XTickLabel', arrayfun(@(x) calcDuration(x, 0), x_ticks_array, 'UniformOutput', false));
%     end
%%
    function UpdateParametersFields(xdata)
        
        min_x = min(xdata);
        max_x = max(xdata);
        delta_x = max_x - min_x;
        
        min_x_string = calcDuration(floor(min_x), 0);
        max_x_string = calcDuration(floor(max_x), 0);
        delta_x_string = calcDuration(floor(delta_x), 0);
        
        DATA.AnalysisParams.activeWin_startTime = min_x;
        DATA.AnalysisParams.segment_startTime = min_x;
        DATA.AnalysisParams.segment_endTime = max_x;
        DATA.AnalysisParams.activeWin_length = delta_x;
        DATA.AnalysisParams.segment_effectiveEndTime = DATA.AnalysisParams.segment_endTime;
        
        set(GUI.Active_Window_Start, 'String', min_x_string);
        set(GUI.Active_Window_Length, 'String', delta_x_string);
        
        set(GUI.segment_startTime, 'String', min_x_string);
        set(GUI.segment_endTime, 'String', max_x_string);
        set(GUI.activeWindow_length, 'String', delta_x_string);
        %         set(GUI.SpectralWindowLengthHandle, 'String', delta_x_string);
        
        set(GUI.blue_line, 'XData', [DATA.AnalysisParams.segment_startTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_effectiveEndTime DATA.AnalysisParams.segment_startTime]);
        
        setSliderProperties(GUI.Filt_RawDataSlider, DATA.Filt_MaxSignalLength, DATA.AnalysisParams.activeWin_length, DATA.AnalysisParams.activeWin_length/DATA.Filt_MaxSignalLength);
        set(GUI.Filt_RawDataSlider, 'Value', min(DATA.AnalysisParams.activeWin_startTime, get(GUI.Filt_RawDataSlider, 'Max')));
        
        if ~get(GUI.Filt_RawDataSlider, 'Max')
            status = 'off';
        else
            status = 'on';
        end
        set(GUI.Filt_RawDataSlider, 'Enable', status);
        set(GUI.Active_Window_Start, 'Enable', status);
    end
%%
    function ChangePlot(xdata)
        
        set(GUI.RRDataAxes, 'XLim', [xdata(1) xdata(2)]);
        
        DATA.firstSecond2Show = xdata(1);
        DATA.MyWindowSize = xdata(2) - xdata(1);
        
        set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0));
        set(GUI.WindowSize,'String', calcDuration(DATA.MyWindowSize, 0));
        
        if abs(DATA.maxSignalLength - DATA.MyWindowSize ) <=  1 %0.0005
            set(GUI.RawDataSlider, 'Enable', 'off');
            set(GUI.FirstSecond, 'Enable', 'off');
        else
            set(GUI.RawDataSlider, 'Enable', 'on');
            set(GUI.FirstSecond, 'Enable', 'on');
            setSliderProperties(GUI.RawDataSlider, DATA.maxSignalLength, DATA.MyWindowSize, DATA.MyWindowSize/DATA.maxSignalLength);
            
            if DATA.firstSecond2Show > get(GUI.RawDataSlider, 'Max')
                set(GUI.RawDataSlider, 'Value', get(GUI.RawDataSlider, 'Max'));
            else
                set(GUI.RawDataSlider, 'Value', DATA.firstSecond2Show);
            end
        end
        setXAxesLim();
        setAutoYAxisLimUpperAxes(DATA.firstSecond2Show, DATA.MyWindowSize);
        setAutoYAxisLimLowAxes(get(GUI.AllDataAxes, 'XLim'));
        DATA.YLimLowAxes = setYAxesLim(GUI.AllDataAxes, GUI.AutoScaleYLowAxes_checkbox, GUI.MinYLimitLowAxes_Edit, GUI.MaxYLimitLowAxes_Edit, DATA.YLimLowAxes, DATA.AutoYLimitLowAxes);
        DATA.YLimUpperAxes = setYAxesLim(GUI.RRDataAxes, GUI.AutoScaleYUpperAxes_checkbox, GUI.MinYLimitUpperAxes_Edit, GUI.MaxYLimitUpperAxes_Edit, DATA.YLimUpperAxes, DATA.AutoYLimitUpperAxes);
        set_rectangles_YData();
        plotDataQuality();
        plotMultipleWindows();
    end
%%
    function blue_rect_focus_pushbutton_Callback(~, ~)
        blue_line_xdata = get(GUI.blue_line, 'XData');
        blue_line_xdata_saved = blue_line_xdata;
        red_rect_xdata = get(GUI.red_rect, 'XData');
        min_blue_line_xdata = min(blue_line_xdata);
        max_blue_line_xdata = max(blue_line_xdata);
        min_red_rect_xdata = min(red_rect_xdata);
        max_red_rect_xdata = max(red_rect_xdata);
        
        blue_rect_length = max_blue_line_xdata - min_blue_line_xdata;
        
        if min_blue_line_xdata ~= min_red_rect_xdata
            blue_line_xdata([1, 4]) = min_red_rect_xdata;
            blue_line_xdata([2, 3]) = min_red_rect_xdata + blue_rect_length;
            
            if max(blue_line_xdata) > DATA.Filt_MaxSignalLength
                blue_line_xdata([1, 4]) = max_red_rect_xdata - blue_rect_length;
                blue_line_xdata([2, 3]) = max_red_rect_xdata;
            end
            
            set(GUI.blue_line, 'XData', blue_line_xdata);
            
            DATA.AnalysisParams.segment_startTime = min(blue_line_xdata);
            
            segment_effectiveEndTime = DATA.AnalysisParams.segment_startTime + DATA.AnalysisParams.activeWin_length + (DATA.AnalysisParams.winNum - 1) * (1 - DATA.AnalysisParams.segment_overlap/100) * DATA.AnalysisParams.activeWin_length;
            DATA.AnalysisParams.segment_endTime = segment_effectiveEndTime;
            
            DATA.AnalysisParams.activeWin_startTime = DATA.AnalysisParams.activeWin_startTime + (min(blue_line_xdata) - min(blue_line_xdata_saved));
            
            set(GUI.Filt_RawDataSlider, 'Value', min(min(blue_line_xdata), get(GUI.Filt_RawDataSlider, 'Max')));
            set(GUI.segment_startTime, 'String', calcDuration(DATA.AnalysisParams.segment_startTime, 0));
            set(GUI.segment_endTime, 'String', calcDuration(DATA.AnalysisParams.segment_endTime, 0));
            set(GUI.Active_Window_Start, 'String', calcDuration(DATA.AnalysisParams.activeWin_startTime, 0));
            
            plotMultipleWindows();
            %             DATA.doCalc = true;
            clear_statistics_plots();
            clearStatTables();
            calcBatchWinNum();
            plotFilteredData();
            plotMultipleWindows();
            if get(GUI.AutoCalc_checkbox, 'Value')
                calcStatistics();
            end
        end
    end
%%
    function Normalize_STD_checkbox_Callback(src, ~)
        
        mhrv_set_default('mse.normalize_std', get(src, 'Value'));
        
        if get(GUI.AutoCalc_checkbox, 'Value')
            waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            calcNonlinearStatistics(waitbar_handle);
            close(waitbar_handle);
        end
    end
%%
    function WinAverage_checkbox_Callback(src, ~)
        
        DATA.WinAverage = get(src, 'Value');
        
        if DATA.WinAverage
            GUI.SpectralWindowLengthHandle.Enable = 'on';
        else
            GUI.SpectralWindowLengthHandle.Enable = 'off';
        end
        
        if get(GUI.AutoCalc_checkbox, 'Value')
            %             DATA.WinAverage = 1;
            waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            calcFrequencyStatistics(waitbar_handle);
            close(waitbar_handle);
            %         else
            %             DATA.WinAverage = 0;
        end
    end
%%
    function openEstimateWindow(title, typical_parameter_rate, tag)
        main_screensize = DATA.screensize;
        SmallFontSize = DATA.SmallFontSize;
        
        GUI.EstimateLFBandWindow = figure( ...
            'Name', title, ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', ...
            'Position', [(main_screensize(3)-350)/2, (main_screensize(4)-150)/2, 350, 150]); %[700, 300, 800, 400]
        
        setLogo(GUI.EstimateLFBandWindow);
        
        EstimateLayout = uix.VBox('Parent', GUI.EstimateLFBandWindow, 'Spacing', DATA.Spacing);
        
        EstimatePanel = uix.Panel('Parent', EstimateLayout, 'Padding', DATA.Padding+2);
        EstimateBox = uix.VBox('Parent', EstimatePanel, 'Spacing', DATA.Spacing);
        
        uix.Empty( 'Parent', EstimateBox );
        HRBox = uix.HBox('Parent', EstimateBox, 'Spacing', DATA.Spacing);
        
        uicontrol( 'Style', 'text', 'Parent', HRBox, 'String', typical_parameter_rate, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.Estimate_edit = uicontrol( 'Style', 'edit', 'Parent', HRBox, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'Callback', @estimate_Edit_Callback, 'Tag', tag);
        uicontrol( 'Style', 'text', 'Parent', HRBox, 'String', 'BPM', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        set(HRBox, 'Widths', [150, 110, -1]);
        
        uix.Empty( 'Parent', EstimateBox );
        
        set(EstimateBox, 'Heights', [-15 -20 -45]);
        
        CommandsButtons_Box = uix.HButtonBox('Parent', EstimateLayout, 'Spacing', DATA.Spacing, 'VerticalAlignment', 'middle', 'ButtonSize', [100 30]);
        uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', {@ok_estimate_button_Callback, tag}, 'FontSize', DATA.BigFontSize, 'String', 'OK', 'FontName', 'Calibri');
        uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', {@cancel_button_Callback, GUI.EstimateLFBandWindow}, 'FontSize', DATA.BigFontSize, 'String', 'Cancel', 'FontName', 'Calibri');
        
        set(EstimateLayout, 'Heights',  [-70 -30]);
        
        set(findobj(EstimateLayout, 'Type', 'uicontainer'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(EstimateLayout, 'Type', 'uipanel'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(EstimateLayout, 'Style', 'edit'), 'BackgroundColor', myEditTextColor);
        set(findobj(EstimateLayout, 'Style', 'text'), 'BackgroundColor', myUpBackgroundColor);
        
        if isempty(who('defaultRate')) || isempty(defaultRate)
            defaultRate.HeartRate = 0;
            defaultRate.BreathingRate = 15;
        end
        if isvalid(GUI.Estimate_edit)
            if strcmp(tag, 'Frequency_Bands')
                GUI.Estimate_edit.String = defaultRate.HeartRate;
            else
                GUI.Estimate_edit.String = defaultRate.BreathingRate;
            end
        end
    end
%%
    function EstimateLFBand_pushbutton_Callback(~, ~)
        openEstimateWindow('Estimate PSD Frequency Bands', 'Typical Heart Rate', 'Frequency_Bands');
    end
%%
    function EstimatePNNThreshold_pushbutton_Callback(~, ~)
        openEstimateWindow('Estimate pNNxx Threshold Bands', 'Typical Breathing Rate', 'PNN_Threshold');
    end
%%
    function HR = check_input(edit_field_handle)
        value = str2double(get(edit_field_handle, 'String'));
        if strcmp(get(edit_field_handle, 'Tag'), 'Frequency_Bands')
            min_val = 5;
            max_val = 1500;
            rate = 'Heart';
        else
            min_val = 1;
            max_val = 200;
            rate = 'Breathing';
        end
        if isnan(value) || value < min_val || value > max_val
            errordlg(['Typical ' rate ' Rate must be greater than '  num2str(min_val) ' BPM and less than ' num2str(max_val) ' BPM!'], 'Input Error');
            HR = 0;
            return;
        else
            HR = value;
            if strcmp(get(edit_field_handle, 'Tag'), 'Frequency_Bands')
                defaultRate.HeartRate = HR;
            else
                defaultRate.BreathingRate = HR;
            end
        end
    end
%%
    function estimate_Edit_Callback(src, ~)
        estimate_button(get(src, 'Tag'));
    end
%%
    function estimate_button(tag)
        
        HR = check_input(GUI.Estimate_edit);
        if HR
            if strcmp(tag, 'Frequency_Bands')
                [f_VLF_LF, f_LF_HF, f_HF_up] = compute_bands(HR);
                
                prev_vlf = mhrv_get_default('hrv_freq.vlf_band');
                prev_lf = mhrv_get_default('hrv_freq.lf_band');
                prev_hf = mhrv_get_default('hrv_freq.hf_band');
                beta_band = mhrv_get_default('hrv_freq.beta_band');
                
                mhrv_set_default('hrv_freq.hf_band', [f_LF_HF f_HF_up]);
                mhrv_set_default('hrv_freq.lf_band', [f_VLF_LF f_LF_HF]);
                mhrv_set_default('hrv_freq.vlf_band', [prev_vlf.value(1) f_VLF_LF]);
                mhrv_set_default('hrv_freq.beta_band', [prev_vlf.value(1) f_VLF_LF]);
                
                if get(GUI.AutoCalc_checkbox, 'Value')
                    try
                        update_statistics('hrv_freq');
                    catch e
                        errordlg(['ok_estimate_button_Callback error: ' e.message], 'Input Error');
                        
                        mhrv_set_default('hrv_freq.hf_band', prev_hf);
                        mhrv_set_default('hrv_freq.lf_band', prev_lf);
                        mhrv_set_default('hrv_freq.vlf_band', prev_vlf);
                        mhrv_set_default('hrv_freq.beta_band', beta_band);
                        delete(GUI.EstimateLFBandWindow);
                        return;
                    end
                end
                set(GUI.ConfigParamHandlesMap('hrv_freq.vlf_band.max'), 'String', num2str(f_VLF_LF), 'UserData', num2str(f_VLF_LF));
                set(GUI.ConfigParamHandlesMap('hrv_freq.lf_band.min'), 'String', num2str(f_VLF_LF), 'UserData', num2str(f_VLF_LF));
                set(GUI.ConfigParamHandlesMap('hrv_freq.beta_band.max'), 'String', num2str(f_VLF_LF), 'UserData', num2str(f_VLF_LF));
                
                set(GUI.ConfigParamHandlesMap('hrv_freq.lf_band.max'), 'String', num2str(f_LF_HF), 'UserData', num2str(f_LF_HF));
                set(GUI.ConfigParamHandlesMap('hrv_freq.hf_band.min'), 'String', num2str(f_LF_HF), 'UserData', num2str(f_LF_HF));
                
                set(GUI.ConfigParamHandlesMap('hrv_freq.hf_band.max'), 'String', num2str(f_HF_up), 'UserData', num2str(f_HF_up));
            else
                xx = compute_pnnxx(HR);
                param_name = 'hrv_time.pnn_thresh_ms';
                
                prev_pnn_thresh = mhrv_get_default(param_name);
                mhrv_set_default(param_name, xx);
                
                if get(GUI.AutoCalc_checkbox, 'Value')
                    try
                        update_statistics('hrv_time');
                    catch e
                        errordlg(['ok_estimate_button_Callback error: ' e.message], 'Input Error');
                        mhrv_set_default(param_name, prev_pnn_thresh);
                        delete(GUI.EstimateLFBandWindow);
                        return;
                    end
                end
                set(GUI.ConfigParamHandlesMap(param_name), 'String', num2str(xx));
            end
            delete(GUI.EstimateLFBandWindow);
        end
    end
%%
    function ok_estimate_button_Callback(~, ~, tag)
        estimate_button(tag);
    end
%%
    function [f_VLF_LF,f_LF_HF,f_HF_up] = compute_bands(HR)
        % input
        % - typical HR of a given mammal
        % - wz: window size
        %
        % output
        % - f_VLF_LF: cutoff frequency between VLF and LF bands
        % - f_LF_HF: cutoff frequency between LF and HF bands
        % - f_HF_up: upper bound of the HF band
        %
        % These formula were published in:
        % Behar et al. "A universal scaling relation for
        % defining power spectral bands in mammalian
        % heart rate variability analysis". In submission.
        
        try
            % use power law to predict bands
            f_VLF_LF = 0.0037*HR^0.58;
            f_LF_HF = 0.0017*HR^1.01;
            f_HF_up = 0.0128*HR^0.86;
        catch
            f_VLF_LF = [];
            f_LF_HF = [];
            f_HF_up = [];
        end
    end
%%
    function [xx] = compute_pnnxx(BR)
        % this function returns an estimate of the xx for the pNNxx measures
        % provided an estimate of the typical breathing rate (BR) of a given
        % mammal.
        % It is assumed that the xx value is proportional to the breathing cycle
        % length.
        %
        % input
        %   BR: breathing rate (bpm)
        % output
        %   xx: parameter for the pNNxx (ms)
        BR_human = 15;
        CL_human = 60/BR_human;
        CL_mammal = 60/BR;
        xx = 50*(CL_mammal/CL_human);
    end
%%
    function AutoCalc_checkbox_Callback( src, ~ )
        if get(src, 'Value') == 1
            GUI.AutoCompute_pushbutton.Enable = 'off';
        else
            GUI.AutoCompute_pushbutton.Enable = 'on';
        end
    end
%%
    function onPeakDetection( ~, ~ )
        PhysioZooGUI_PeakDetection();
    end
%%
    function onHelp( ~, ~ )
        url = 'https://physiozoo.readthedocs.io/';
        web(url,'-browser')
    end
%%
    function LoadDir_pushbutton_Callback(~, ~)
        Group_LoadDir();
    end

%%
    function Name_edit_Callback(src, ~)
        status = 'On';
        DATA.Group.CurrentName = get(src, 'String');
        if isempty( DATA.Group.CurrentName)
            status = 'Off';
        end
        set(GUI.Group.btnAddGroup, 'Enable', status);
    end
%%
    function Add_PushButton_Callback(~, ~)
        
        persistent color_index;
        
        if isfield(DATA.Group, 'AllNames') && ~isempty(find(cellfun(@(x) strcmp(x, DATA.Group.CurrentName), DATA.Group.AllNames), 1))
            errordlg('Please, choose unique group name.', 'Input Error');
            return;
        end
        
        if isempty(color_index)
            color_index = 1;
        else
            color_index = color_index + 1;
        end
        
        if ~isfield(DATA.Group, 'AllNames')
            DATA.Group.AllNames = [];
        end
        if ~isfield(DATA.Group, 'Groups')
            DATA.Group.Groups = [];
        end
        DATA.Group.CurrentName = get(GUI.Group.ebName, 'String');
        DATA.Group.AllNames = unique(sort([DATA.Group.AllNames; {DATA.Group.CurrentName}]));
        [ind, ~] = find(strcmp(DATA.Group.AllNames, DATA.Group.CurrentName));
        set(GUI.Group.lbGroups, 'String', DATA.Group.AllNames, 'Value', ind);
        
        DATA.Group.Groups(end+1).Name = DATA.Group.CurrentName;
        DATA.Group.Groups(end).Path = DATA.Group.Path.CurrentDir;
        strMembers = get(GUI.Group.lbMembers, 'String');
        DATA.Group.Groups(end).Members = strMembers(get(GUI.Group.lbMembers, 'Value'));
        
        all_colors = lines;
        group_color = all_colors(color_index, :);
        
        DATA.Group.Groups(end).Color = group_color; %[0.8 0.8 0.8];
        [~, ind] = unique(sort({DATA.Group.Groups.Name}'));
        DATA.Group.Groups = DATA.Group.Groups(ind);
    end

%%
    function Del_pushbutton_Callback(~,~)
        if isfield(DATA.Group, 'Groups')
            iGroup = ismember({DATA.Group.Groups.Name}', DATA.Group.CurrentName);
            DATA.Group.Groups = DATA.Group.Groups(~iGroup);
            
            DATA.Group.AllNames = DATA.Group.AllNames(~iGroup);
            set(GUI.Group.ebName, 'String', '');
            
            oldVal = get(GUI.Group.lbGroups, 'String');
            set(GUI.Group.lbGroups, 'String', oldVal(~iGroup), 'Value', 1);
        end
    end
%%
    function Groups_listbox_Callback(~,~)
        switch get(GUI.Window,'selectiontype')
            case 'normal'
                Select_Single_Group(@LoadGroupDir_popupmenu_Callback);
            case 'open'
                Select_Single_Group(@LoadGroupDir_popupmenu_Callback);
            otherwise
        end
    end
%%
    function Select_Single_Group(pmLoadDir)
        set_defaults_path();
        strGroups = get(GUI.Group.lbGroups, 'String');
        valGroups = get(GUI.Group.lbGroups, 'Value');
        strDirs = get(GUI.Group.pmWorkDir, 'String');
        DATA.Group.CurrentName = cell2mat(strGroups(valGroups));
        set(GUI.Group.ebName, 'String', DATA.Group.CurrentName);
        iGroup = ismember( {DATA.Group.Groups.Name}', DATA.Group.CurrentName);
        if ~isempty(DATA.Group.Groups(iGroup))
            DATA.Group.Path.CurrentDir = DATA.Group.Groups(iGroup).Path;
            [iPath, ~] = find((ismember( strDirs, DATA.Group.Path.CurrentDir)));
            set(GUI.Group.pmWorkDir, 'Value', iPath);
            feval(pmLoadDir);
            AllFiles = get(GUI.Group.lbMembers, 'String');
            [iMembers, ~] = find(ismember(AllFiles, DATA.Group.Groups(iGroup).Members));
            set(GUI.Group.lbMembers, 'Max', 5, 'Value', iMembers);
        end
    end
%%
    function LoadGroupDir_popupmenu_Callback(~, ~)
        strDirs = get(GUI.Group.pmWorkDir, 'String');
        valDirs = get(GUI.Group.pmWorkDir, 'Value');
        DATA.Group.Path.CurrentDir = cell2mat(strDirs(valDirs));
        DIRS.DataBaseDirectory = DATA.Group.Path.CurrentDir;
        
        curr_ext = DATA.Group.Path.AllExts{valDirs};
        
        dr = dir([DATA.Group.Path.CurrentDir, '\*.' curr_ext]);
        set(GUI.Group.lbMembers, 'String', {dr.name}, 'Value', 1);
        
        set(GUI.Group.pmFileType, 'Value', valDirs);
    end
%%
    function Members_listbox_Callback(~,~)
        switch get(GUI.Window,'selectiontype')
            case 'normal'
            case 'open'
                strFiles = get(GUI.Group.lbMembers,'str');
                valFiles = get(GUI.Group.lbMembers,'value');
                clearStatTables();
                Load_Calc(cell2mat(strFiles(valFiles)), [DATA.Group.Path.CurrentDir,'\']);
            otherwise
        end
    end
%%
    function Group_LoadDir()
        
        set_defaults_path();
        
        % if isempty(DATA.Group.Path.CurrentDir)
        %     DATA.Group.Path.CurrentDir = 'D:\';
        % end
        % tempPath = uigetdir([DATA.Group.Path.CurrentDir]);
        tempPath = uigetdir([DIRS.DataBaseDirectory]);
        if tempPath
            DATA.Group.Path.CurrentDir = tempPath;
            DIRS.DataBaseDirectory = tempPath;
        else
            return
        end
        dr = dir([DATA.Group.Path.CurrentDir, '\*.' DIRS.Ext_group]);
        set(GUI.Group.lbMembers, 'String', {dr.name}, 'Value', 1);
        
        DATA.Group.Path.AllDirs = unique(sort([DATA.Group.Path.AllDirs; {DATA.Group.Path.CurrentDir}]));
        DATA.Group.Path.AllExts = unique(sort([DATA.Group.Path.AllExts; {DIRS.Ext_group}]));
        
        [ind, ~] = find(strcmp(DATA.Group.Path.AllDirs, DATA.Group.Path.CurrentDir));
        set(GUI.Group.pmWorkDir, 'String', DATA.Group.Path.AllDirs, 'Value', ind);
        
        [ind, ~] = find(strcmp(DATA.Group.Path.AllExts, DIRS.Ext_group));
        set(GUI.Group.pmFileType, 'Value', ind);
    end
%%
    function FileType_popupmenu_Callback(src, ~)
        items = get(src, 'String');
        DATA.file_types_index = get(src, 'Value');
        DIRS.Ext_group = items{DATA.file_types_index};
    end
%%
    function Load_Calc(curr_file_name, curr_path)
        waitbar_handle = waitbar(1/2, 'Loading data', 'Name', 'Working on it...');
        [mammal, mammal_index] = Load_Data_from_SingleFile(curr_file_name, curr_path, waitbar_handle);
        
        if ~isfield(GUI, 'ConfigParamHandlesMap')
            mhrv_load_defaults(DATA.mammals{DATA.mammal_index});
        end
        
        set_default_values();
        
        FiltSignal();
        DATA.Filt_MaxSignalLength = DATA.tnn(end);
        
        if ~isfield(DATA, 'AnalysisParams')
            set_default_analysis_params();
        end
        
        calcStatistics();
        
        close(waitbar_handle);
    end
%%
    function GroupsCompute_pushbutton_Callback(~, ~)
        
        DATA.GroupsCalc = 1;
        
        if isfield(DATA, 'Group') && isfield(DATA.Group, 'Groups')
            n_groups = length(DATA.Group.Groups);
            
            % Allocate cell array the will contain all the tables (one for each record type).
            hrv_tables = cell(1,n_groups);
            stats_tables = cell(1,n_groups);
            gr_names = cell(1,n_groups);
            groups_mean = cell(n_groups, 1);
            
            for gr = 1 : n_groups
                gr_names{gr} = DATA.Group.Groups(gr).Name;
                
                nfiles = length(DATA.Group.Groups(gr).Members);
                rec_type_tables = cell(nfiles, 1);
                
                for gr_member = 1 : nfiles
                    
                    curr_file_name = DATA.Group.Groups(gr).Members{gr_member};
                    
                    curr_path = [DATA.Group.Groups(gr).Path filesep];
                    Load_Calc(curr_file_name, curr_path);
                    
                    curr_hrv = horzcat(DATA.TimeStat.hrv_time_metrics, DATA.FrStat.hrv_fr_metrics, DATA.NonLinStat.hrv_nonlin_metrics);
                    
                    % Handle naming of rows to prevent duplicate names from different files
                    % The number of rows depends on the lenghth of the data and the value of 'window_minutes'
                    row_names = curr_hrv.Properties.RowNames;
                    if length(row_names) == 1
                        % If there's only one row, set name of row to be the record name (without full path)
                        row_names{1} = curr_file_name;
                    else
                        row_names = cellfun(@(row_name)sprintf('%s_%s', curr_file_name, row_name), row_names, 'UniformOutput', false);
                    end
                    curr_hrv.Properties.RowNames = row_names;
                    
                    % Append current file's metrics to the metrics & plot data for the rec type
                    rec_type_tables{gr_member} = curr_hrv;
                    
                end
                
                % Concatenate all tables to one
                rec_type_table = vertcat(rec_type_tables{:});
                
                % Save rec_type tables
                hrv_tables{gr} = rec_type_table;
                stats_tables{gr} = table_stats(rec_type_table);
                
                groups_mean{gr} = stats_tables{gr}{1, :};
                
                [stat_data_cell, stat_row_names_cell, stat_descriptions_cell] = table2cell_StatisticsParam(stats_tables{gr});
                
                if gr == 1
                    GUI.GroupSummaryTable.RowName = stat_row_names_cell;
                    GUI.GroupSummaryTable.Data = [stat_descriptions_cell stat_data_cell];
                else
                    GUI.GroupSummaryTable.Data = [GUI.GroupSummaryTable.Data stat_data_cell];
                end
                
            end
            
            GUI.GroupSummaryTable.ColumnName = ['Description', gr_names];
            
            %         % Convert output to maps
            %
            %         % Convert from cell array of tables to a map, from the rec type to the matching table.
            %         hrv_tables = containers.Map(gr_names, hrv_tables);
            %         stats_tables = containers.Map(gr_names, stats_tables);
            %
            %
            %         %% Display tables
            %         for groups_idx = 1:n_groups
            %             gr_name = gr_names{groups_idx};
            %             if isempty(hrv_tables(gr_name))
            %                 continue;
            %             end
            %             fprintf(['\n-> ' gr_name ' metrics:\n']);
            %             disp([hrv_tables(gr_name); stats_tables(gr_name)]);
            %         end
            
            DATA.GroupsCalc = 0;
        end
    end
%%
    function onExit( ~, ~ )
        % User wants to quit out of the application
        if isfield(GUI, 'SaveFiguresWindow') && isvalid(GUI.SaveFiguresWindow)
            delete( GUI.SaveFiguresWindow );
        end
        
        if isfield(GUI, 'SaveMeasuresWindow') && isvalid(GUI.SaveMeasuresWindow)
            delete( GUI.SaveMeasuresWindow );
        end
        delete( GUI.Window );
    end % onExit

end % EOF
