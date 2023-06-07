%%
function PhysioZooGUI(fileNameFromM1, DataFileMapFromM1)

% Add third-party dependencies to path
gui_basepath = fileparts(mfilename('fullpath'));
% addpath(genpath([gui_basepath filesep 'lib']));
% addpath(genpath([gui_basepath filesep 'Loader']));
% addpath(genpath([gui_basepath filesep 'myWFDB']));
% addpath(genpath([gui_basepath filesep 'mhrv']));
basepath = fileparts(gui_basepath);

Module3 = 0;

if isdeployed
    disp(['ctfroot: ', ctfroot]);
    disp(['pwd: ', pwd]);
    disp(['userpath: ', userpath]);
    disp(['tempdir: ', tempdir]);
    
    mhrv_init;
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

%% Load default toolbox parameters
%mhrv.defaults.mhrv_load_defaults --clear;

%%
DATA = createData();
clearData();
GUI = createInterface();

if nargin >= 1
    onOpenFile([], [], fileNameFromM1, DataFileMapFromM1);
end

displayEndOfDemoMessage('');

%%-------------------------------------------------------------------------%
    function DATA = createData()
        
        DATA.screensize = get( 0, 'ScreenSize' );
        %         get(0 , 'ScreenPixelsPerInch')
        %         get(0, 'MonitorPositions')
        
        DATA.PlotHR = 0;
        
        DATA.rec_name = [];
        
        %         DATA.file_types = {'txt'; 'mat'; 'qrs'};
        DATA.file_types_groups = {'txt'; 'mat'; 'qrs'; 'dat'; 'atr'};
        DATA.file_types_index = 1;
        
        %         DATA.data_types = {'peak'; 'interval'; 'beating rate'; 'electrography'; 'oxygen saturation'};
        %         DATA.data_types_index = 1;
        
        DATA.mammal = [];
        DATA.mammals = {'human (task force)', 'human', 'dog', 'rabbit', 'mouse', 'custom'};
        DATA.GUI_mammals = {'Human (Task Force)'; 'Human'; 'Dog'; 'Rabbit'; 'Mouse'; 'Custom'};
        DATA.mammal_index = 1;
        
        DATA.Integration = [];
        DATA.integration_level = {'ecg'; 'electrogram'; 'oximetry'}; % ; 'ap'
        DATA.GUI_Integration = {'ECG'; 'Electrogram'; 'Oximetry'}; % ; 'Action Potential'
        %         DATA.Integration = 'ECG';
        DATA.integration_index = 1;
        
        DATA.Filters_ECG = {'Moving average', 'Range', 'Quotient', 'Combined filters', 'No filtering'};
        DATA.Filters_SpO2 = {'Range', 'Block Data', 'DFilter', 'No filtering'}; % , 'Median'
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
        
        DATA.filter_spo2_range = true;
        %         DATA.filter_spo2_median = false;
        DATA.filter_spo2_block = false;
        DATA.filter_spo2_dfilter = false;                
        
        %         DEBUGGING MODE - Small Screen
%         DATA.screensize = [0 0 1250 800];
        
        DATA.window_size = [DATA.screensize(3)*0.99 DATA.screensize(4)*0.85];                
        
        if DATA.screensize(3) < 1535 %1920 %1080
            DATA.BigFontSize = 9;
            DATA.SmallFontSize = 9;
            DATA.SmallScreen = 1;
        else
            DATA.BigFontSize = 10; % 11
            DATA.SmallFontSize = 10; % 11
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
        
        DATA.ox_raw_data_color = [0 0.4470 0.7410]; % [0 0.4470 0.7410] %0, 0, 1
        DATA.ox_rd_lw = 3;
        
        DATA.ox_filt_data_color = [0 1 0]; % [0 1 0] % [0.9290 0.6940 0.1250] % 0 0.75 0.75
        DATA.ox_fd_lw = 1.25;
        
        DATA.font_name = 'Times New Roman';
        
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
        DATA.nni_saved = [];
        DATA.nni4calc = [];
        
        DATA.mammal = [];
        DATA.Integration = [];
        
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
        
        DATA.CMStat.PlotData = [];
        DATA.PMStat.PlotData = [];
        
        GUI.TimeParametersTableRowName = [];
        GUI.FrequencyParametersTableRowName = [];
        GUI.NonLinearTableRowName = [];
        GUI.CMTableRowName = [];
        GUI.ODIParametersTableRowName = [];
        GUI.DSMParametersTableRowName = [];
        GUI.PMTableRowName = [];
        
        DATA.flag = '';
        
        DATA.freq_yscale = 'linear';
        
        DATA.active_window = 1;
        DATA.AutoYLimitUpperAxes = [];
        DATA.AutoYLimitLowAxes = [];
        
        %         DATA.Group.Path.AllDirs = [];  %Eugene 04.05.18
        
        %         DATA.GroupsCalc = 0;
        
        DATA.custom_filters_thresholds = [];
        
        DATA.Action = 'move';
        
        DATA.quality_class_ind = [];
        DATA.config_file_name = '';
        
        GUI.Analysis_TabPanel.Selection = 1;
        
        DATA.default_filters_thresholds = [];
    end
%%
    function clean_gui()
        
        set(GUI.SaveMeasures, 'Enable', 'off');
        
        set(GUI.DataQualityMenu,'Enable', 'off');
        set(GUI.SaveFiguresAsMenu,'Enable', 'off');
        set(GUI.SaveParamFileMenu,'Enable', 'off');
        set(GUI.LoadConfigFile, 'Enable', 'off');
        
        set(GUI.open_quality_pushbutton_handle, 'Enable', 'off');
        set(GUI.open_config_pushbutton_handle, 'Enable', 'off');
        
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
        set(GUI.Config_text, 'String', '');
        set(GUI.Mammal_popupmenu, 'String', '');
        
        try
            set(GUI.freq_yscale_Button, 'String', 'Log');
            set(GUI.freq_yscale_Button, 'Value', 1);
            set(GUI.freq_yscale_Button, 'Visible', 'on');
        catch
        end
        
        try
            set(GUI.oxim_per_log_Button, 'String', 'Log');
            set(GUI.oxim_per_log_Button, 'Value', 1);
        catch
        end
        
        GUI.PageDownButton.Enable = 'off';
        GUI.PageUpButton.Enable = 'on';
        
        if isfield(GUI, 'raw_data_handle') && ishandle(GUI.raw_data_handle) && isvalid(GUI.raw_data_handle)
            delete(GUI.raw_data_handle);
        end
        
        if isfield(GUI, 'filtered_handle') && ishandle(GUI.filtered_handle) && isvalid(GUI.filtered_handle)
            delete(GUI.filtered_handle);
        end
        
        if isfield(GUI, 'only_filtered_handle') && ishandle(GUI.only_filtered_handle) && isvalid(GUI.only_filtered_handle)
            delete(GUI.only_filtered_handle);
        end
        
        if isfield(GUI, 'FourthTab') && ishandle(GUI.FourthTab) && isvalid(GUI.FourthTab)
            delete(GUI.FourthTab);
        end
        if isfield(GUI, 'FifthTab') && ishandle(GUI.FifthTab) && isvalid(GUI.FifthTab)
            delete(GUI.FifthTab);
        end
        if isfield(GUI, 'FourthParamTab') && ishandle(GUI.FourthParamTab) && isvalid(GUI.FourthParamTab)
            delete(GUI.FourthParamTab);
        end
        if isfield(GUI, 'FifthParamTab') && ishandle(GUI.FifthParamTab) && isvalid(GUI.FifthParamTab)
            delete(GUI.FifthParamTab);
        end
        if isfield(GUI, 'OBMTab') && ishandle(GUI.OBMTab) && isvalid(GUI.OBMTab)
            delete(GUI.OBMTab);
        end
        
        GUI.quality_vent_text.String = 'Signal quality file name';
        GUI.DataQualityMenu.Label = 'Open signal quality file';
        
        GUI.ShowFilteredData.Value = 1;
        GUI.ShowRawData.Value = 1;
        
        if isfield(GUI, 'measures_cb_array') && all(isvalid(GUI.measures_cb_array))
            for i = 1 : length(GUI.measures_cb_array)
                GUI.measures_cb_array(i).Value = 1;
            end
            GUI.measures_cb_array(end).Value = 0;
            GUI.Complexity_CB.Value = 0;
        end
        
        GUI.MedianFilter_checkbox.Value = 0;
        GUI.Detrending_checkbox.Value = 0;
    end
%%
    function clearStatTables()
        GUI.TimeParametersTable.Data = [];
        GUI.TimeParametersTableData = [];
        GUI.TimeParametersTable.RowName = [];
        
        GUI.FragParametersTableData = [];
        GUI.FragParametersTable.RowName=[];
        GUI.FragParametersTable.Data = [];
        
        GUI.FrequencyParametersTable.Data = [];
        GUI.FrequencyParametersTableData = [];
        GUI.FrequencyParametersTable.RowName = [];
        
        GUI.NonLinearTable.Data = [];
        GUI.NonLinearTableData = [];
        GUI.NonLinearTable.RowName = [];
        
        if isfield(GUI, 'CMTable') && ishandle(GUI.CMTable) && isvalid(GUI.CMTable)
            GUI.CMTable.Data = [];
            GUI.CMTableData = [];
            GUI.CMTable.RowName = [];
        end
        
        if isfield(GUI, 'PMTable') && ishandle(GUI.PMTable) && isvalid(GUI.PMTable)
            GUI.PMTable.Data = [];
            GUI.PMTableData = [];
            GUI.PMTable.RowName = [];
        end
        GUI.StatisticsTable.RowName = {''};
        GUI.StatisticsTable.Data = {''};
        GUI.StatisticsTable.ColumnName = {'Description'; 'Values'};
        
        DATA.TimeStat = [];
        DATA.FrStat = [];
        DATA.NonLinStat = [];
        
        DATA.CMStat = [];
        DATA.PMStat = [];
        
        DATA.timeStatPartRowNumber = 0;
        DATA.frequencyStatPartRowNumber = 0;
        DATA.NonLinearStatPartRowNumber = 0;
        DATA.ComplexityStatPartRowNumber = 0;
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
        
        setLogo(GUI.Window, 'M2');
        
        
        DATA.zoom_handle = zoom(GUI.Window);
        %DATA.zoom_handle.Motion = 'vertical';
        DATA.zoom_handle.Enable = 'on';
        %         DATA.zoom_handle.ButtonDownFilter = @zoom_handle_ButtonDownFilter;
        
        % + File menu
        GUI.FileMenu = uimenu( GUI.Window, 'Label', 'File' );
        uimenu( GUI.FileMenu, 'Label', 'Open data file', 'Callback', @onOpenFile, 'Accelerator','O');
        GUI.DataQualityMenu = uimenu( GUI.FileMenu, 'Label', 'Open signal quality file', 'Callback', @onOpenDataQualityFile, 'Accelerator','Q', 'Enable', 'off');
        GUI.LoadConfigFile = uimenu( GUI.FileMenu, 'Label', 'Load custom config file', 'Callback', @onLoadCustomConfigFile, 'Accelerator','L', 'Enable', 'off');
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
        tempMenu = uimenu( GUI.Window, 'Label', 'Pulse');
        GUI.PeakDetectionMenu = uimenu( tempMenu, 'Label', 'Pulse', 'Callback', @onPeakDetection);
        
        % Create the layout (Arrange the main interface)
        GUI.mainLayout = uix.VBoxFlex('Parent', GUI.Window, 'Spacing', DATA.Spacing);
        
        % + Create the panels
        Upper_Part_Box = uix.HBoxFlex('Parent', GUI.mainLayout, 'Spacing', DATA.Spacing); % Upper Part
        Low_Part_BoxPanel = uix.BoxPanel( 'Parent', GUI.mainLayout, 'Title', '  ', 'Padding', DATA.Padding+2); %Low Part
        
        if DATA.SmallScreen
            upper_part = 0.55;
        else
            upper_part = 0.55;
        end
        lower_part = 1 - upper_part;
        set( GUI.mainLayout, 'Heights', [(-1)*upper_part, (-1)*lower_part]  );
        
        %---------------------------------
        
        % + Upper Panel - Left and Right Parts
        temp_panel_left = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding);
        temp_panel_right = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding);
        temp_panel_buttons = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding);
        temp_vbox_buttons = uix.VBox( 'Parent', temp_panel_buttons, 'Spacing', DATA.Spacing);
        
        if DATA.SmallScreen
            left_part = 0.37; % 0.4
            Left_Part_widths_in_pixels = 0.35 * DATA.window_size(1); % 0.27
            buttons_part = 0.11;
        else
            left_part = 0.35; % 0.25
            Left_Part_widths_in_pixels = 0.35 * DATA.window_size(1); % 0.25
            buttons_part = 0.1; % 0.07
        end
        right_part = 0.7; % 0.7
        
        Right_Part_widths_in_pixels = DATA.window_size(1) - Left_Part_widths_in_pixels;
        
        set(Upper_Part_Box, 'Widths', [-1*left_part -1*right_part -1*buttons_part]);
        
        GUI.UpLeft_TabPanel = uix.TabPanel('Parent', temp_panel_left, 'Padding', DATA.Padding, 'TabWidth', 60, 'FontSize', BigFontSize, 'SelectionChangedFcn', @TabChange_Callback);
        GUI.UpCentral_TabPanel = uix.CardPanel('Parent', temp_panel_right, 'Padding', DATA.Padding);
        MainCommandsButtons_Box = uix.VButtonBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        BlueRectButtons_Box = uix.VButtonBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'Padding', DATA.Padding, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        PageUpDownButtons_Box = uix.HButtonBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'Padding', DATA.Padding, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
        %         DATA.Padding+10
        set(temp_vbox_buttons, 'Heights', [-100, -35, -20]); % -15
        %------------------------------------
        
        GUI.OptionsTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
        GUI.BatchTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
        GUI.AdvancedTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
        GUI.DisplayTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
        
        if Module3
            GUI.GroupTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
            GUI.UpLeft_TabPanel.TabTitles = {'Main', 'Single', 'Options', 'Display', 'Group'};
        else
            GUI.UpLeft_TabPanel.TabTitles = {'Main', 'Single', 'Options', 'Display'};
        end
        
        %------------------------------------
        two_axes_box = uix.VBox('Parent', GUI.UpCentral_TabPanel, 'Spacing', DATA.Spacing);
        GUI.RRDataAxes = axes('Parent', uicontainer('Parent', two_axes_box), 'Tag', 'MainAxes');
        GUI.AllDataAxes = axes('Parent', uicontainer('Parent', two_axes_box));
        set(two_axes_box, 'Heights', [-1, 100]);
        
        %------------------------------------
        if Module3
            GUI.GroupAnalysisSclPanel = uix.ScrollingPanel( 'Parent', GUI.UpCentral_TabPanel);
            GUI.GroupAnalysisBox = uix.VBox( 'Parent', GUI.GroupAnalysisSclPanel, 'Spacing', DATA.Spacing);
            set( GUI.GroupAnalysisSclPanel, 'Widths', Right_Part_widths_in_pixels, 'Heights', 500 );
            
            GUI.UpCentral_TabPanel.Selection = 1;
        end
        %------------------------------------
        
        GUI.AutoCompute_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', MainCommandsButtons_Box, 'Callback', @AutoCompute_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Compute', 'Enable', 'inactive');
        GUI.AutoCalc_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', MainCommandsButtons_Box, 'Callback', @AutoCalc_checkbox_Callback, 'FontSize', BigFontSize-1.5, 'String', 'Auto Compute', 'Value', 1);
        GUI.RR_or_HR_plot_button = uicontrol( 'Style', 'ToggleButton', 'Parent', MainCommandsButtons_Box, 'Callback', @RR_or_HR_plot_button_Callback, 'FontSize', BigFontSize, 'String', 'Plot HR');
        GUI.Reset_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', MainCommandsButtons_Box, 'Callback', @Reset_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Reset');
        
        if DATA.SmallScreen
            set( MainCommandsButtons_Box, 'ButtonSize', [150, 25], 'Spacing', DATA.Spacing  );
        else
            set( MainCommandsButtons_Box, 'ButtonSize', [150, 25], 'Spacing', DATA.Spacing  );
        end
        
        
        GUI.ShowRawData = uicontrol( 'Style', 'Checkbox', 'Parent', BlueRectButtons_Box, 'Callback', @ShowRawData_checkbox_Callback, 'FontSize', BigFontSize-1.5, 'String', 'Show raw data', 'Value', 1);
        GUI.ShowFilteredData = uicontrol( 'Style', 'Checkbox', 'Parent', BlueRectButtons_Box, 'Callback', @ShowFilteredData_checkbox_Callback, 'FontSize', BigFontSize-1.5, 'String', 'Show filtered data', 'Value', 1);
        
        GUI.BlueRectFocusButton = uicontrol( 'Style', 'PushButton', 'Parent', BlueRectButtons_Box, 'Callback', @blue_rect_focus_pushbutton_Callback, 'FontSize', BigFontSize, 'Visible', 'on');
        if DATA.SmallScreen
            set( BlueRectButtons_Box, 'ButtonSize', [150, 25], 'Spacing', DATA.Spacing  );
        else
            set( BlueRectButtons_Box, 'ButtonSize', [150, 25], 'Spacing', DATA.Spacing  ); % 105
        end
        
        GUI.PageDownButton = uicontrol( 'Style', 'PushButton', 'Parent', PageUpDownButtons_Box, 'Callback', @page_down_pushbutton_Callback, 'FontSize', BigFontSize, 'String', sprintf('\x25C0'), 'Visible', 'on');  % 2190'
        GUI.PageUpButton = uicontrol( 'Style', 'PushButton', 'Parent', PageUpDownButtons_Box, 'Callback', @page_up_pushbutton_Callback, 'FontSize', BigFontSize, 'String', sprintf('\x25B6'), 'Visible', 'on');  % 2192
        if DATA.SmallScreen
            set( PageUpDownButtons_Box, 'ButtonSize', [75, 25], 'Spacing', DATA.Spacing);
        else
            set( PageUpDownButtons_Box, 'ButtonSize', [75, 25], 'Spacing', DATA.Spacing);
        end
        
        %---------------------------------
        Analysis_Box = uix.HBoxFlex('Parent', Low_Part_BoxPanel, 'Spacing', DATA.Spacing);
        GUI.Analysis_TabPanel = uix.TabPanel('Parent', Analysis_Box, 'Padding', DATA.Padding, 'TabWidth', 150, 'FontSize', BigFontSize);
        
        GUI.StatisticsTab = uix.Panel( 'Parent', GUI.Analysis_TabPanel, 'Padding', DATA.Padding+2);
        GUI.TimeTab = uix.Panel( 'Parent', GUI.Analysis_TabPanel, 'Padding', DATA.Padding+2);
        GUI.FrequencyTab = uix.Panel( 'Parent', GUI.Analysis_TabPanel, 'Padding', DATA.Padding+2);
        GUI.NonLinearTab = uix.Panel( 'Parent', GUI.Analysis_TabPanel, 'Padding', DATA.Padding+2);
        %         GUI.FourthTab = uix.Panel( 'Parent', GUI.Analysis_TabPanel, 'Padding', DATA.Padding+2);
        %         GUI.FifthTab = uix.Panel( 'Parent', GUI.Analysis_TabPanel, 'Padding', DATA.Padding+2);
        if Module3
            GUI.GroupSummaryTab = uix.Panel( 'Parent', GUI.Analysis_TabPanel, 'Padding', DATA.Padding+2);
            GUI.Analysis_TabPanel.TabTitles = {'Statistics', 'Stat1', 'Stat2', 'Stat3', 'Group'};
            %             GUI.Analysis_TabPanel.TabEnables = {'on', 'on', 'on', 'on', 'on'};
        else
            %             GUI.Analysis_TabPanel.TabTitles = {'Statistics', 'Stat1', 'Stat2', 'Stat3', 'Stat4', 'Stat5'};
            %             GUI.Analysis_TabPanel.TabEnables = {'on', 'on', 'on', 'on', 'on', 'on'};
            GUI.Analysis_TabPanel.TabTitles = {'Statistics', 'Stat1', 'Stat2', 'Stat3'};
            %             GUI.Analysis_TabPanel.TabEnables = {'on', 'on', 'on', 'on'};
        end
        
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
        
        if Module3
            GUI.GroupSclPanel = uix.ScrollingPanel( 'Parent', GUI.GroupTab);
            GUI.GroupBox = uix.VBox( 'Parent', GUI.GroupSclPanel, 'Spacing', DATA.Spacing);
            set( GUI.GroupSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        end
        %--------------------------------------------------------------------------------------------
        
        GUI.AdvancedBox = uix.VBox( 'Parent', GUI.AdvancedTab, 'Spacing', DATA.Spacing);
        if DATA.SmallScreen
            tab_width = 56;
        else
            tab_width = 68;
        end
        GUI.Advanced_TabPanel = uix.TabPanel('Parent', GUI.AdvancedBox, 'Padding', DATA.Padding, 'TabWidth', tab_width); % , 'FontSize', SmallFontSize
        
        GUI.FilteringParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', DATA.Padding+0);
        GUI.TimeParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', DATA.Padding+0);
        GUI.FrequencyParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', DATA.Padding+0);
        GUI.NonLinearParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', DATA.Padding+0);
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
        %         uix.Empty( 'Parent', GUI.RecordNameBox );
        GUI.open_record_pushbutton_handle = uicontrol( 'Style', 'PushButton', 'Parent', GUI.RecordNameBox, 'Callback', @onOpenFile, 'FontSize', SmallFontSize, 'String', '...', 'Enable', 'on');
        
        GUI.DataQualityBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{2} = uicontrol( 'Style', 'text', 'Parent', GUI.DataQualityBox, 'String', 'Signal quality file name', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.DataQuality_text = uicontrol( 'Style', 'text', 'Parent', GUI.DataQualityBox, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        %         uix.Empty( 'Parent', GUI.DataQualityBox );
        GUI.open_quality_pushbutton_handle = uicontrol( 'Style', 'PushButton', 'Parent', GUI.DataQualityBox, 'Callback', @onOpenDataQualityFile, 'FontSize', SmallFontSize, 'String', '...', 'Enable', 'off');
        
        GUI.quality_vent_text = a{2};
        
        GUI.ConfigFileNameBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{3} = uicontrol( 'Style', 'text', 'Parent', GUI.ConfigFileNameBox, 'String', 'Config file name', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.Config_text = uicontrol( 'Style', 'text', 'Parent', GUI.ConfigFileNameBox, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        %         uix.Empty( 'Parent', GUI.ConfigFileNameBox );
        %         GUI.open_config_button_Box = uix.HButtonBox('Parent', GUI.ConfigFileNameBox, 'Spacing', DATA.Spacing, 'Padding', DATA.Padding); % , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom'
        %         set( GUI.open_config_button_Box, 'ButtonSize', [25, 17] );
        GUI.open_config_pushbutton_handle = uicontrol( 'Style', 'PushButton', 'Parent', GUI.ConfigFileNameBox, 'Callback', @onLoadCustomConfigFile, 'FontSize', SmallFontSize, 'String', '...', 'Enable', 'off');
        
        GUI.DataLengthBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{4} = uicontrol( 'Style', 'text', 'Parent', GUI.DataLengthBox, 'String', 'Time series length', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.RecordLength_text = uicontrol( 'Style', 'text', 'Parent', GUI.DataLengthBox, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        uicontrol( 'Style', 'text', 'Parent', GUI.DataLengthBox, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'String', 'h:min:sec.msec');
%         uix.Empty( 'Parent', GUI.DataLengthBox );
        
        GUI.MammalBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{5} = uicontrol( 'Style', 'text', 'Parent', GUI.MammalBox, 'String', 'Mammal', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.Mammal_popupmenu = uicontrol( 'Style', 'edit', 'Parent', GUI.MammalBox, 'Callback', @Mammal_popupmenu_Callback, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left'); % , 'String', DATA.GUI_mammals, 'Value', 1
        uix.Empty( 'Parent', GUI.MammalBox );
        
        GUI.IntegrationBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{6} = uicontrol( 'Style', 'text', 'Parent', GUI.IntegrationBox, 'String', 'Integration level', 'FontSize', SmallFontSize, 'Enable', 'on', 'HorizontalAlignment', 'left');
        GUI.Integration_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', GUI.IntegrationBox, 'Callback', @Integration_popupmenu_Callback, 'FontSize', SmallFontSize, 'Enable', 'on', 'Value', 1);
        GUI.Integration_popupmenu.String = DATA.GUI_Integration;
        uix.Empty( 'Parent', GUI.IntegrationBox );
        
        GUI.FilteringBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{7} = uicontrol( 'Style', 'text', 'Parent', GUI.FilteringBox, 'String', 'Preprocessing', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.Filtering_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', GUI.FilteringBox, 'Callback', @Filtering_popupmenu_Callback, 'FontSize', SmallFontSize);
        
        GUI.Filtering_popupmenu.String = DATA.Filters_ECG;
        
        uix.Empty( 'Parent', GUI.FilteringBox );
        GUI.MedianFilter_checkbox = uicontrol('Style', 'Checkbox', 'Parent', GUI.FilteringBox, 'Callback', @Median_checkbox_Callback, 'FontSize', DATA.BigFontSize, ...
            'String', 'Median Filter', 'TooltipString', 'Whether to apply median filter', 'Visible', 'off');
        
        %         uix.Empty( 'Parent', GUI.FilteringBox );
        
        GUI.FilteringLevelBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{8} = uicontrol( 'Style', 'text', 'Parent', GUI.FilteringLevelBox, 'String', 'Preprocessing level', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.FilteringLevel_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', GUI.FilteringLevelBox, 'Callback', @FilteringLevel_popupmenu_Callback, 'FontSize', SmallFontSize);
        GUI.FilteringLevel_popupmenu.String = DATA.FilterLevel;
        GUI.FilteringLevel_popupmenu.Value = DATA.default_filter_level_index;
        uix.Empty( 'Parent', GUI.FilteringLevelBox );
        
        GUI.DefaultMethodBox = uix.HBox( 'Parent', GUI.OptionsBox, 'Spacing', DATA.Spacing);
        a{9} = uicontrol( 'Style', 'text', 'Parent', GUI.DefaultMethodBox, 'String', 'Default frequency method', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.DefaultMethod_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', GUI.DefaultMethodBox, 'Callback', @DefaultMethod_popupmenu_Callback, 'FontSize', SmallFontSize, 'TooltipString', 'Default frequency method to use to display under statistics');
        GUI.DefaultMethod_popupmenu.String = DATA.frequency_methods;
        GUI.DefaultMethod_popupmenu.Value = 1;
        uix.Empty( 'Parent', GUI.DefaultMethodBox );
        
        GUI.Detrending_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', GUI.OptionsBox, 'Callback', @Detrending_checkbox_Callback, 'FontSize', DATA.BigFontSize, ...
            'String', 'Detrend NN time series', 'TooltipString', 'Enable or disable the detrending of the time series');
        
        max_extent_control = calc_max_control_x_extend(a);
        field_size = [max_extent_control + 5, -1, 1];
        
%         set( GUI.DataLengthBox, 'Widths', field_size );
        
        if DATA.SmallScreen
            field_size = [max_extent_control + 5, -0.2, -0.35]; % -0.65, -0.35
        else
            field_size = [max_extent_control + 5, -0.31, -0.35]; % [max_extent_control + 5, -0.65, -0.35]
        end
        
        set( GUI.MammalBox, 'Widths', field_size );
        set( GUI.IntegrationBox, 'Widths', field_size );
        %         set( GUI.FilteringBox, 'Widths', field_size );
        set( GUI.FilteringLevelBox, 'Widths', field_size );
        set( GUI.DefaultMethodBox, 'Widths', field_size );
        
        if DATA.SmallScreen
            uix.Empty( 'Parent', GUI.OptionsBox );
            set( GUI.OptionsBox, 'Heights', [-7 -7 -7 -7 -6 -7 -7 -7 -7 -5 -4] ); %  [-7 -7 -7 -7 -7 -7 -7 24 -7]
        else
            set( GUI.OptionsBox, 'Heights', [-7 -7 -7 -7 -6 -7 -7 -7 -7 -4] ); %  [-7 -7 -7 -7 -7 -7 -7 24 -7]
        end
        
        popupmenu_position = get(GUI.Mammal_popupmenu, 'Position');
        
        field_size = [max_extent_control + 5, popupmenu_position(3) + 15, 25];
        set( GUI.ConfigFileNameBox, 'Widths', field_size );
        set( GUI.RecordNameBox, 'Widths',     field_size );
        set( GUI.DataQualityBox, 'Widths',    field_size );
        
        set( GUI.DataLengthBox, 'Widths', [max_extent_control + 5, popupmenu_position(3) + 15, -1] );
        
        set( GUI.FilteringBox, 'Widths', [max_extent_control + 5, popupmenu_position(3), 15,  -1] );
        
        %         config_file_name_extent = get(GUI.Config_text, 'Extent');
        %         config_file_name_position = get(GUI.Config_text, 'Position');
        load_config_name_button_position = get(GUI.open_config_pushbutton_handle, 'Position');
        updated_position = [load_config_name_button_position(1) load_config_name_button_position(2)+12 load_config_name_button_position(3) load_config_name_button_position(4)-12];
        %         set(GUI.open_config_pushbutton_handle, 'Position', [config_file_name_position(1)+config_file_name_extent(3) load_config_name_button_position(2)+7 load_config_name_button_position(3) load_config_name_button_position(4)-7])
        set(GUI.open_record_pushbutton_handle, 'Position', updated_position);
        set(GUI.open_quality_pushbutton_handle, 'Position', updated_position);
        set(GUI.open_config_pushbutton_handle, 'Position', updated_position);
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
        %---------------------------
        %---------------------------
        %---------------------------
        %---------------------------
        %---------------------------
        
        %                 uix.Empty( 'Parent', GUI.GroupBox );
        if Module3
            DataTypeBox = uix.HBox( 'Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
            aa{1} = uicontrol( 'Style', 'text', 'Parent', DataTypeBox, 'String', 'Data Type', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.DataType_popupmenu = uicontrol( 'Style', 'PopUpMenu', 'Parent', DataTypeBox, 'Callback', @DataType_popupmenu_Callback, 'FontSize', SmallFontSize, 'String', {'QRS'; 'ECG'}, 'Enable', 'on');
            uix.Empty( 'Parent', DataTypeBox );
            uix.Empty( 'Parent', DataTypeBox );
            
            FileTypeBox = uix.HBox( 'Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
            aa{2} = uicontrol( 'Style', 'text', 'Parent', FileTypeBox, 'String', 'File Type', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.Group.pmFileType = uicontrol( 'Style', 'PopUpMenu', 'Parent', FileTypeBox, 'Callback', @FileType_popupmenu_Callback, 'FontSize', SmallFontSize, 'String', DATA.file_types_groups);
            uix.Empty( 'Parent', FileTypeBox );
            uix.Empty( 'Parent', FileTypeBox );
            
            %         DataType_bg = uibuttongroup( 'Parent', DataTypeBox, 'Title', 'Data Type');
            %         uix.Empty( 'Parent', DataTypeBox );
            %         uix.Empty( 'Parent', DataTypeBox );
            %         ECG_radiobutton = uicontrol('Parent', DataType_bg, 'Style', 'radiobutton', 'String', 'ECG');
            %         QRS_radiobutton = uicontrol('Parent', DataType_bg, 'Style', 'radiobutton', 'String', 'QRS');
            %         get(ECG_radiobutton, 'Units')
            %         get(ECG_radiobutton, 'Position')
            %         DataType_bg.Visible = 'on';
            
            GUI.LoadBox = uix.HBox( 'Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
            aa{3} = uicontrol( 'Style', 'text', 'Parent', GUI.LoadBox, 'String', 'Load', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.Group.pmWorkDir = uicontrol( 'Style', 'PopUpMenu', 'Parent', GUI.LoadBox, 'Callback', @LoadGroupDir_popupmenu_Callback, 'FontSize', SmallFontSize, 'String', '  ');
            GUI.LoadButtons_Box = uix.HButtonBox('Parent', GUI.LoadBox, 'Spacing', DATA.Spacing, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'ButtonSize', [70, 30]);
            GUI.Group.btnLoadDir = uicontrol( 'Style', 'PushButton', 'Parent', GUI.LoadButtons_Box, 'Callback', @LoadDir_pushbutton_Callback, 'FontSize', BigFontSize, 'String', '  ...  ');
            uix.Empty( 'Parent', GUI.LoadBox );
            
            uix.Empty( 'Parent', GUI.GroupBox );
            
            GUI.MembersBox = uix.HBox( 'Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
            aa{4} = uicontrol( 'Style', 'text', 'Parent', GUI.MembersBox, 'String', 'Members', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.Group.lbMembers = uicontrol( 'Style', 'ListBox', 'Parent', GUI.MembersBox, 'Callback', @Members_listbox_Callback, 'FontSize', SmallFontSize, 'String', {' '; ' '; ' '; ' '}, 'Max', 5);
            uix.Empty( 'Parent', GUI.MembersBox );
            uix.Empty( 'Parent', GUI.MembersBox );
            
            uix.Empty( 'Parent', GUI.GroupBox );
            
            GUI.NamesBox = uix.HBox( 'Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
            aa{5} = uicontrol( 'Style', 'text', 'Parent', GUI.NamesBox, 'String', 'Name', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.Group.ebName = uicontrol( 'Style', 'edit', 'Parent', GUI.NamesBox, 'Callback', @Name_edit_Callback, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.AddDelButtons_Box = uix.HButtonBox('Parent', GUI.NamesBox, 'Spacing', DATA.Spacing, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'ButtonSize', [70, 30]);
            GUI.Group.btnAddGroup = uicontrol( 'Style', 'PushButton', 'Parent', GUI.AddDelButtons_Box, 'Callback', @Add_PushButton_Callback, 'FontSize', BigFontSize, 'String', 'Add', 'Enable', 'off');
            GUI.Group.btnDelGroup = uicontrol( 'Style', 'PushButton', 'Parent', GUI.AddDelButtons_Box, 'Callback', @Del_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Del');
            uix.Empty( 'Parent', GUI.NamesBox );
            
            uix.Empty( 'Parent', GUI.GroupBox );
            
            GUI.GroupsBox = uix.HBox( 'Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
            aa{6} = uicontrol( 'Style', 'text', 'Parent', GUI.GroupsBox, 'String', 'Groups', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.Group.lbGroups = uicontrol( 'Style', 'ListBox', 'Parent', GUI.GroupsBox, 'Callback', @Groups_listbox_Callback, 'FontSize', SmallFontSize, 'String', {' '; ' '; ' '; ' '});
            uix.Empty( 'Parent', GUI.GroupsBox );
            uix.Empty( 'Parent', GUI.GroupsBox );
            
            GUI.GroupsConfigFileNameBox = uix.HBox( 'Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
            aa{7} = uicontrol( 'Style', 'text', 'Parent', GUI.GroupsConfigFileNameBox, 'String', 'Config file name', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.GroupsConfig_text = uicontrol( 'Style', 'text', 'Parent', GUI.GroupsConfigFileNameBox, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.groups_open_config_pushbutton_handle = uicontrol( 'Style', 'PushButton', 'Parent', GUI.GroupsConfigFileNameBox, 'Callback', @onLoadCustomConfigFile, 'FontSize', SmallFontSize, 'String', '...', 'Enable', 'on');
            uix.Empty( 'Parent', GUI.GroupsConfigFileNameBox );
            
            %                 uix.Empty( 'Parent', GUI.GroupBox );
            
            Comp_Box = uix.HBox('Parent', GUI.GroupBox, 'Spacing', DATA.Spacing);
            uix.Empty( 'Parent', Comp_Box );
            uicontrol( 'Style', 'PushButton', 'Parent', Comp_Box, 'Callback', @GroupsCompute_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Compute', 'Enable', 'on');
            uix.Empty( 'Parent', Comp_Box );
            uix.Empty( 'Parent', Comp_Box );
            
            max_extent_control = calc_max_control_x_extend(aa);
            field_size = [max_extent_control + 5, 225, 80 -1];
            set( DataTypeBox, 'Widths', field_size );
            set( FileTypeBox, 'Widths', field_size );
            set( GUI.LoadBox, 'Widths', field_size );
            set( GUI.MembersBox, 'Widths', field_size );
            set( GUI.NamesBox, 'Widths', field_size );
            set( GUI.GroupsBox, 'Widths', field_size );
            set( GUI.GroupsConfigFileNameBox, 'Widths', field_size );
            set( Comp_Box, 'Widths', field_size );
            
            %                 uix.Empty( 'Parent', GUI.GroupBox );
            
            h1 = -20;
            h2 = -40;
            he = -0.005;
            
            set( GUI.GroupBox, 'Heights', [h1 h1 h1 he h2 he h1 he h2 h1 h1] );
        end
        %---------------------------
        %---------------------------
        %---------------------------
        %---------------------------
        %---------------------------
        
        tables_field_size = [-85 -1]; % [-85 -15]
        
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
        GUI.FrequencyParametersTable.ColumnName = {'                Measures Name                ', 'Values Welch', 'Valxues AR'};
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
        
        set( GUI.FrequencyBox, 'Widths', [-1 -3] ); % [-34 -64]
        %---------------------------
        
        GUI.NonLinearBox = uix.HBox( 'Parent', GUI.NonLinearTab, 'Spacing', DATA.Spacing);
        GUI.ParamNonLinearBox = uix.VBox( 'Parent', GUI.NonLinearBox, 'Spacing', DATA.Spacing);
        
        GUI.NonLinearAxesBox = uix.HBox( 'Parent', GUI.NonLinearBox, 'Spacing', DATA.Spacing);
        
        GUI.NonLinearTable = uitable( 'Parent', GUI.ParamNonLinearBox, 'FontSize', SmallFontSize, 'FontName', 'Calibri');
        GUI.NonLinearTable.ColumnName = {'    Measures Name    ', 'Values'};
        uix.Empty( 'Parent', GUI.ParamNonLinearBox );
        set( GUI.ParamNonLinearBox, 'Heights', tables_field_size );
        
        GUI.NonLinearAxes1 = axes('Parent', uicontainer('Parent', GUI.NonLinearAxesBox) );
        GUI.NonLinearAxes2 = axes('Parent', uicontainer('Parent', GUI.NonLinearAxesBox) );
        GUI.NonLinearAxes3 = axes('Parent', uicontainer('Parent', GUI.NonLinearAxesBox) );
        set(GUI.NonLinearAxesBox, 'Widths', [-24 -24 -24]); % -14 -24 -24 -24
        set(GUI.NonLinearBox, 'Widths', [-1 -5]); % [-1 -3]
        %         %---------------------------
        %
        %         GUI.FourthBox = uix.HBox( 'Parent', GUI.FourthTab, 'Spacing', DATA.Spacing);
        %         GUI.ParamFourthBox = uix.VBox( 'Parent', GUI.FourthBox, 'Spacing', DATA.Spacing);
        %         GUI.CMTable = uitable( 'Parent', GUI.ParamFourthBox, 'FontSize', SmallFontSize, 'FontName', 'Calibri');
        %         GUI.CMTable.ColumnName = {'    Measures Name    ', 'Values'};
        %         uix.Empty( 'Parent', GUI.ParamFourthBox );
        %         set(GUI.ParamFourthBox, 'Heights', tables_field_size );
        %
        %         GUI.FourthAxes1 = axes('Parent', uicontainer('Parent', GUI.FourthBox) );
        %         set(GUI.FourthBox, 'Widths', [-14 -80] );
        %         %---------------------------
        %
        %         GUI.FifthBox = uix.HBox( 'Parent', GUI.FifthTab, 'Spacing', DATA.Spacing);
        %         GUI.ParamFifthBox = uix.VBox( 'Parent', GUI.FifthBox, 'Spacing', DATA.Spacing);
        %         GUI.PMTable = uitable('Parent', GUI.ParamFifthBox, 'FontSize', SmallFontSize, 'FontName', 'Calibri');
        %         GUI.PMTable.ColumnName = {'    Measures Name    ', 'Values'};
        %         uix.Empty( 'Parent', GUI.ParamFifthBox );
        %         set(GUI.ParamFifthBox, 'Heights', tables_field_size );
        %
        %         GUI.FifthAxes1 = axes('Parent', uicontainer('Parent', GUI.FifthBox) );
        %         set(GUI.FifthBox, 'Widths', [-14 -80] );
        %---------------------------
        GUI.StatisticsTable = uitable( 'Parent', GUI.StatisticsTab, 'FontSize', SmallFontSize, 'ColumnWidth',{800 'auto'}, 'FontName', 'Calibri');    % 550
        GUI.StatisticsTable.ColumnName = {'Description'; 'Values'};
        %---------------------------
        if Module3
            GUI.GroupSummaryTable = uitable( 'Parent', GUI.GroupSummaryTab, 'FontSize', SmallFontSize, 'ColumnWidth',{800 'auto'}, 'FontName', 'Calibri');    % 550
            GUI.GroupSummaryTable.ColumnName = {'Description'; 'Values'};
        end
        %---------------------------
        
        % Upper Part
        
        set(findobj(Upper_Part_Box,'Style', 'edit'), 'BackgroundColor', myEditTextColor);
        set(findobj(Upper_Part_Box,'Style', 'text'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(Upper_Part_Box,'Style', 'slider'), 'BackgroundColor', mySliderColor);
        set(findobj(Upper_Part_Box,'Style', 'checkbox'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(Upper_Part_Box,'Style', 'ToggleButton'), 'BackgroundColor', myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
        set(findobj(Upper_Part_Box,'Style', 'PushButton'), 'BackgroundColor', myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
        
        if ismac()
            set(findobj(Upper_Part_Box,'Style', 'ToggleButton'), 'ForegroundColor', [0 0 0]);
        end
        
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
%     function max_extent_control = calc_max_control_x_extend(uitext_handle)
%         max_extent_control = 0;
%         for i = 1 : length(uitext_handle)
%             extent_control = get(uitext_handle{i}, 'Extent');
%             max_extent_control = max(max_extent_control, extent_control(3));
%         end
%     end
% %%
%     function clearParametersBox(VBoxHandle)
%         param_boxes_handles = allchild(VBoxHandle);
%         if ~isempty(param_boxes_handles)
%             delete(param_boxes_handles);
%         end
%     end
%%
    function TabChange_Callback(~, eventData)
        if eventData.NewValue == 6
            GUI.UpCentral_TabPanel.Selection = 2;
            GUI.Analysis_TabPanel.Selection = 5;
        else
            GUI.UpCentral_TabPanel.Selection = 1;
            GUI.Analysis_TabPanel.Selection = 1;
        end
    end
%%
%     function [param_keys_length, max_extent_control, handles_boxes] = FillParamFields(VBoxHandle, param_map)
%
%         SmallFontSize = DATA.SmallFontSize;
%
%         param_keys = keys(param_map);
%         param_keys_length = length(param_keys);
%
%         text_fields_handles_cell = cell(1, param_keys_length);
%         handles_boxes = cell(4, param_keys_length);
%         for i = 1 : param_keys_length
%
%             HBox = uix.HBox( 'Parent', VBoxHandle, 'Spacing', DATA.Spacing, 'BackgroundColor', myUpBackgroundColor);
%             handles_boxes{1, i} = HBox;
%
%             field_name = param_keys{i};
%
%             current_field = param_map(field_name);
%             current_field_value = current_field.value;
%             handles_boxes{2, i} = current_field_value;
%
%             symbol_field_name = current_field.name;
%
%             symbol_field_name = strrep(symbol_field_name, 'Alpha1', sprintf('\x3b1\x2081')); % https://unicode-table.com/en/
%             symbol_field_name = strrep(symbol_field_name, 'Alpha2', sprintf('\x3b1\x2082'));
%             symbol_field_name = strrep(symbol_field_name, 'Beta', sprintf('\x3b2'));
%
%             text_fields_handles_cell{i} = uicontrol( 'Style', 'text', 'Parent', HBox, 'String', symbol_field_name, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'TooltipString', current_field.description);
%
%             if length(current_field_value) < 2
%                 current_value = num2str(current_field_value);
%                 param_control = uicontrol( 'Style', 'edit', 'Parent', HBox, 'Callback', {@set_config_Callback, field_name}, 'FontSize', SmallFontSize, 'TooltipString', current_field.description);
%                 if strcmp(symbol_field_name, 'Spectral window length')
%                     GUI.SpectralWindowLengthHandle = param_control;
%                     set(param_control, 'String', calcDuration(current_field_value*60, 0), 'UserData', current_field_value*60);
%                 else
%                     set(param_control, 'String', current_value, 'UserData', current_value);
%                 end
%
%
%                 GUI.ConfigParamHandlesMap(field_name) = param_control;
%
%
%                 %                 if ~isempty(strfind(field_name, 'hrv_time'))
%                 %                     GUI.ConfigParamHandlesMap(field_name) = param_control;
%                 %                 elseif ~isempty(strfind(field_name, 'filtrr'))
%                 %                     GUI.ConfigParamHandlesMap(field_name) = param_control;
%                 %                 end
%
%
%
%
%
%             else
%                 field_name_min = [field_name '.min'];
%                 current_value = num2str(current_field_value(1));
%                 param_control1 = uicontrol( 'Style', 'edit', 'Parent', HBox, 'Callback', {@set_config_Callback, field_name_min}, 'FontSize', SmallFontSize, 'TooltipString', current_field.description, 'Tag', field_name_min);
%
%                 set(param_control1, 'String', current_value, 'UserData', current_value);
%                 uicontrol( 'Style', 'text', 'Parent', HBox, 'String', '-', 'FontSize', SmallFontSize, 'TooltipString', current_field.description);
%                 field_name_max = [field_name '.max'];
%                 current_value = num2str(current_field_value(2));
%                 param_control2 = uicontrol( 'Style', 'edit', 'Parent', HBox, 'Callback', {@set_config_Callback, field_name_max}, 'FontSize', SmallFontSize, 'TooltipString', current_field.description, 'Tag', field_name_max);
%
%                 set(param_control2, 'String', current_value, 'UserData', current_value);
%
%
%                 GUI.ConfigParamHandlesMap(field_name_min) = param_control1;
%                 GUI.ConfigParamHandlesMap(field_name_max) = param_control2;
%
%
%
%                 %                 if ~isempty(strfind(field_name, 'hrv_freq'))
%                 %                     GUI.ConfigParamHandlesMap(field_name_min) = param_control1;
%                 %                     GUI.ConfigParamHandlesMap(field_name_max) = param_control2;
%                 %                 end
%
%             end
%             if strcmp(symbol_field_name, 'Spectral window length')
%                 uicontrol( 'Style', 'text', 'Parent', HBox, 'String', 'h:min:sec', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'TooltipString', current_field.description);
%             else
%                 uicontrol( 'Style', 'text', 'Parent', HBox, 'String', current_field.units, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'TooltipString', current_field.description);
%             end
%
%             if strcmp(symbol_field_name, 'LF Band')
%                 uicontrol('Style', 'PushButton', 'Parent', HBox, 'Callback', @EstimateLFBand_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'E',...
%                     'TooltipString', 'Click here to estimate the frequency bands based on the mammalian typical heart rate');
%                 handles_boxes{3, i} = true; % estimateBands
%             else
%                 handles_boxes{3, i} = false;
%             end
%             if strcmp(symbol_field_name, 'PNN Threshold')
%                 uicontrol('Style', 'PushButton', 'Parent', HBox, 'Callback', @EstimatePNNThreshold_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'E',...
%                     'TooltipString', 'Click here to estimate the pNNxx threshold based on the mammalian breathing rate');
%                 handles_boxes{4, i} = true; % estimatepNNxx
%             else
%                 handles_boxes{4, i} = false;
%             end
%         end
%
%         max_extent_control = calc_max_control_x_extend(text_fields_handles_cell);
%     end
%%
%     function setWidthsConfigParams(max_extent_control, handles_boxes)
%         handles_boxes_size = size(handles_boxes);
%         fields_size = [max_extent_control + 2, 125, -1];
%         for j = 1 : handles_boxes_size(2)
%             if  handles_boxes{4, j} % estimatepNNxx
%                 set(handles_boxes{1, j}, 'Widths', [max_extent_control + 2, 125, 30, 20]);
%             elseif handles_boxes{3, j}
%                 set(handles_boxes{1, j}, 'Widths', [max_extent_control + 2, 58, 5, 56, 20, 20]);
%             elseif length(handles_boxes{2, j}) < 2
%                 set(handles_boxes{1, j}, 'Widths', fields_size);
%             else
%                 set(handles_boxes{1, j}, 'Widths', [max_extent_control + 2, 58, 5, 56, -1]);
%             end
%         end
%     end
%%
    function createConfigParametersInterface()
        
        if strcmp(DATA.Integration, 'oximetry')
            myColors.myEditTextColor = myEditTextColor;
            myColors.myUpBackgroundColor = myUpBackgroundColor;
            [DATA, GUI] = createConfigParametersInterface_Oximetry(DATA, GUI, myColors);
        else
            
            gui_param = ReadYaml('gui_params.yml');
            gui_param_names = fieldnames(gui_param);
            param_struct = gui_param.(gui_param_names{1});
            param_name = fieldnames(param_struct);
            not_in_use_params_fr = param_struct.(param_name{1});
            not_in_use_params_mse = param_struct.(param_name{2});
            
            SmallFontSize = DATA.SmallFontSize;
            
            GUI.ConfigParamHandlesMap = containers.Map;
            
            defaults_map = mhrv.defaults.mhrv_get_all_defaults();
            param_keys = keys(defaults_map);
            
            filtrr_keys = param_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'filtrr')), param_keys)));
            filt_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.range')), filtrr_keys)));
            ma_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.moving_average')), filtrr_keys)));
            quotient_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.quotient')), filtrr_keys)));
            detrending_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.detrending')), filtrr_keys)));
            
            filt_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), filt_range_keys))) = [];
            ma_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), ma_range_keys))) = [];
            quotient_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), quotient_range_keys))) = [];
            detrending_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), detrending_range_keys))) = [];
            
            DATA.filter_quotient = mhrv.defaults.mhrv_get_default('filtrr.quotient.enable', 'value');
            DATA.filter_ma = mhrv.defaults.mhrv_get_default('filtrr.moving_average.enable', 'value');
            DATA.filter_range = mhrv.defaults.mhrv_get_default('filtrr.range.enable', 'value');
            
            DATA.default_filters_thresholds.moving_average.win_threshold = mhrv.defaults.mhrv_get_default('filtrr.moving_average.win_threshold', 'value');
            DATA.default_filters_thresholds.moving_average.win_length = mhrv.defaults.mhrv_get_default('filtrr.moving_average.win_length', 'value');
            DATA.default_filters_thresholds.quotient.rr_max_change = mhrv.defaults.mhrv_get_default('filtrr.quotient.rr_max_change', 'value');
            DATA.default_filters_thresholds.range.rr_max = mhrv.defaults.mhrv_get_default('filtrr.range.rr_max', 'value');
            DATA.default_filters_thresholds.range.rr_min = mhrv.defaults.mhrv_get_default('filtrr.range.rr_min', 'value');
            
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
            [GUI, filt_range_keys_length, max_extent_control(1), handles_boxes_1] = FillParamFields(GUI.FilteringParamBox, containers.Map(filt_range_keys, values(defaults_map, filt_range_keys)), GUI, DATA, myUpBackgroundColor);
            uix.Empty( 'Parent', GUI.FilteringParamBox );
            
            uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Moving average', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
            [GUI, filt_ma_keys_length, max_extent_control(2), handles_boxes_2] = FillParamFields(GUI.FilteringParamBox, containers.Map(ma_range_keys, values(defaults_map, ma_range_keys)), GUI, DATA, myUpBackgroundColor);
            uix.Empty( 'Parent', GUI.FilteringParamBox );
            
            uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Quotient', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
            [GUI, filt_quotient_keys_length, max_extent_control(3), handles_boxes_3] = FillParamFields(GUI.FilteringParamBox, containers.Map(quotient_range_keys, values(defaults_map, quotient_range_keys)), GUI, DATA, myUpBackgroundColor);
            uix.Empty( 'Parent', GUI.FilteringParamBox );
            
            uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Detrending', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
            [GUI, filt_deternding_keys_length, max_extent_control(4), handles_boxes_4] = FillParamFields(GUI.FilteringParamBox, containers.Map(detrending_range_keys, values(defaults_map, detrending_range_keys)), GUI, DATA, myUpBackgroundColor);
            uix.Empty( 'Parent', GUI.FilteringParamBox );
            
            %             GUI.Detrending_checkbox.Value = defaults_map('filtrr.detrending.enable').value;
            
            uix.Empty( 'Parent', GUI.FilteringParamBox );
            
            max_extent = max(max_extent_control);
            
            setWidthsConfigParams(max_extent, handles_boxes_1);
            setWidthsConfigParams(max_extent, handles_boxes_2);
            setWidthsConfigParams(max_extent, handles_boxes_3);
            setWidthsConfigParams(max_extent, handles_boxes_4);
            
            rs = 19; %-22;
            ts = 19; % -18
            es = 2;
            set(GUI.FilteringParamBox, 'Height', [ts, rs * ones(1, filt_range_keys_length), es,...
                ts, rs * ones(1, filt_ma_keys_length), es,...
                ts, rs * ones(1, filt_quotient_keys_length), es, ...
                ts, rs * ones(1, filt_deternding_keys_length), es, -20]);
            
            % Time Parameters
            clearParametersBox(GUI.TimeParamBox);
            uix.Empty( 'Parent', GUI.TimeParamBox );
            [GUI, time_keys_length, max_extent_control, handles_boxes] = FillParamFields(GUI.TimeParamBox, containers.Map(hrv_time_keys, values(defaults_map, hrv_time_keys)), GUI, DATA, myUpBackgroundColor);
            uix.Empty( 'Parent', GUI.TimeParamBox );
            
            % estimateBands
            uicontrol('Style', 'PushButton', 'Parent', handles_boxes{1, 1}, 'Callback', @EstimatePNNThreshold_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'E',...
                'TooltipString', 'Click here to estimate the pNNxx threshold based on the mammalian breathing rate');
            
            setWidthsConfigParams(max_extent_control, handles_boxes);
            
            rs = 19; %-10;
            ts = 19;
            set( GUI.TimeParamBox, 'Height', [ts, rs * ones(1, time_keys_length), -167]  );
            
            %-----------------------------------
            
            % Frequency Parameters
            clearParametersBox(GUI.FrequencyParamBox);
            uix.Empty( 'Parent', GUI.FrequencyParamBox );
            [GUI, freq_param_length, max_extent_control, handles_boxes] = FillParamFields(GUI.FrequencyParamBox, containers.Map(hrv_freq_keys, values(defaults_map, hrv_freq_keys)), GUI, DATA, myUpBackgroundColor);
            uix.Empty( 'Parent', GUI.FrequencyParamBox );
            
            for i = 1 : length(handles_boxes)
                if handles_boxes{3, i} == 1 % estimatepNNxx
                    uicontrol('Style', 'PushButton', 'Parent', handles_boxes{1, i}, 'Callback', @EstimateLFBand_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'E',...
                        'TooltipString', 'Click here to estimate the frequency bands based on the mammalian typical heart rate');
                end
            end
            
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
            [GUI, dfa_param_length, max_extent_control(1), handles_boxes_1] = FillParamFields(GUI.NonLinearParamBox, containers.Map(dfa_keys, values(defaults_map, dfa_keys)), GUI, DATA, myUpBackgroundColor);
            
            % NonLinear Parameters - MSE
            uix.Empty( 'Parent', GUI.NonLinearParamBox );
            uicontrol( 'Style', 'text', 'Parent', GUI.NonLinearParamBox, 'String', 'Multi Scale Entropy (MSE)', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
            [GUI, mse_param_length, max_extent_control(2), handles_boxes_2] = FillParamFields(GUI.NonLinearParamBox, containers.Map(mse_keys, values(defaults_map, mse_keys)), GUI, DATA, myUpBackgroundColor);
            
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
            
            set(findobj(GUI.FilteringParamBox, 'Style', 'edit'), 'BackgroundColor', myEditTextColor);
            set(findobj(GUI.FilteringParamBox, 'Style', 'text'), 'BackgroundColor', myUpBackgroundColor);
            set(findobj(GUI.FilteringParamBox, 'Style', 'Checkbox'), 'BackgroundColor', myUpBackgroundColor);
            
            set(findobj(GUI.TimeParamBox, 'Style', 'edit'), 'BackgroundColor', myEditTextColor);
            set(findobj(GUI.TimeParamBox, 'Style', 'text'), 'BackgroundColor', myUpBackgroundColor);
            set(findobj(GUI.TimeParamBox, 'Style', 'PushButton'), 'BackgroundColor', myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
            
            set(findobj(GUI.FrequencyParamBox, 'Style', 'edit'), 'BackgroundColor', myEditTextColor);
            set(findobj(GUI.FrequencyParamBox, 'Style', 'text'), 'BackgroundColor', myUpBackgroundColor);
            set(findobj(GUI.FrequencyParamBox, 'Style', 'PushButton'), 'BackgroundColor', myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
            set(findobj(GUI.FrequencyParamBox, 'Style', 'Checkbox'), 'BackgroundColor', myUpBackgroundColor);
            
            set(findobj(GUI.NonLinearParamBox, 'Style', 'edit'), 'BackgroundColor', myEditTextColor);
            set(findobj(GUI.NonLinearParamBox, 'Style', 'text'), 'BackgroundColor', myUpBackgroundColor);
            set(findobj(GUI.NonLinearParamBox, 'Style', 'Checkbox'), 'BackgroundColor', myUpBackgroundColor);
            
        end
        
        config_keys = GUI.ConfigParamHandlesMap.keys();
        
        for i = 1 : length(config_keys)
            field_handle = GUI.ConfigParamHandlesMap(config_keys{i});
            field_handle.Callback = {@set_config_Callback, config_keys{i}};
        end
        
        if isfield(GUI, 'Relativecheckbox') && isvalid(GUI.Relativecheckbox)
            GUI.Relativecheckbox.Callback = @Relative_checkbox_Callback;
        end
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
        DetrendIfNeed_data_chunk();
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
        
        DetrendIfNeed_data_chunk();
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
            
            min_nni_delta = min(min_nni, max_nni) - delta;
            max_nni_delta = max(min_nni, max_nni) + delta;
            min_nni_delta_60 = min(min_nni_60, max_nni_60) - delta_60;
            max_nni_delta_60 = max(min_nni_60, max_nni_60) + delta_60;
            
            if min_nni_delta ~= max_nni_delta
                DATA.AutoYLimitLowAxes.RRMinYLimit = min_nni_delta;
                DATA.AutoYLimitLowAxes.RRMaxYLimit = max_nni_delta;
            end
            
            if min_nni_delta_60 ~= max_nni_delta_60
                DATA.AutoYLimitLowAxes.HRMinYLimit = min_nni_delta_60;
                DATA.AutoYLimitLowAxes.HRMaxYLimit = max_nni_delta_60;
            end
            
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
                
                min_signal_data = min(signal_data, [], 'omitnan');
                max_signal_data = max(signal_data, [], 'omitnan');
                delta = (max_signal_data - min_signal_data) * 0.1;
                
                min_signal_data = min(min_signal_data, max_signal_data) - delta;
                max_signal_data = max(min_signal_data, max_signal_data) + delta;
                
                if min_signal_data ~= max_signal_data
                    DATA.AutoYLimitUpperAxes.RRMinYLimit = min_signal_data;
                    DATA.AutoYLimitUpperAxes.RRMaxYLimit = max_signal_data;
                else
                    DATA.AutoYLimitUpperAxes.RRMinYLimit = min_signal_data*0.9;
                    DATA.AutoYLimitUpperAxes.RRMaxYLimit = max_signal_data*1.1;
                end
                
                max_rri_60 = max(60 ./ signal_data, [], 'omitnan');
                min_rri_60 = min(60 ./ signal_data, [], 'omitnan');
                
                delta_60 = (max_rri_60 - min_rri_60)*0.1;
                
                min_rri_60 = min(min_rri_60, max_rri_60) - delta_60;
                max_rri_60 = max(min_rri_60, max_rri_60) + delta_60;
                
                if min_rri_60 ~= max_rri_60
                    DATA.AutoYLimitUpperAxes.HRMinYLimit = min_rri_60;
                    DATA.AutoYLimitUpperAxes.HRMaxYLimit = max_rri_60;
                else
                    DATA.AutoYLimitUpperAxes.HRMinYLimit = min_rri_60 * 0.9;
                    DATA.AutoYLimitUpperAxes.HRMaxYLimit = max_rri_60 * 1.1;
                end
            else
                max_nni = max(filt_signal_data, [], 'omitnan');
                min_nni = min(filt_signal_data, [], 'omitnan');
                delta = (max_nni - min_nni)*1;
                
                
                min_nni_delta = min(min_nni, max_nni) - delta;
                max_nni_delta = max(min_nni, max_nni) + delta;
                if min_nni_delta ~= max_nni_delta
                    DATA.AutoYLimitUpperAxes.RRMinYLimit = min_nni_delta;
                    DATA.AutoYLimitUpperAxes.RRMaxYLimit = max_nni_delta;
                else
                    DATA.AutoYLimitUpperAxes.RRMinYLimit = min_nni_delta * 0.9;
                    DATA.AutoYLimitUpperAxes.RRMaxYLimit = max_nni_delta * 1.1;
                end
                
                max_nni_60 = max(60 ./ filt_signal_data, [], 'omitnan');
                min_nni_60 = min(60 ./ filt_signal_data, [], 'omitnan');
                delta_60 = (max_nni_60 - min_nni_60)*1;
                
                min_nni_delta_60 = min(min_nni_60, max_nni_60) - delta_60;
                max_nni_delta_60 = max(min_nni_60, max_nni_60) + delta_60;
                if min_nni_delta_60 ~= max_nni_delta_60
                    DATA.AutoYLimitUpperAxes.HRMinYLimit = min_nni_delta_60;
                    DATA.AutoYLimitUpperAxes.HRMaxYLimit = max_nni_delta_60;
                else
                    DATA.AutoYLimitUpperAxes.HRMinYLimit = min_nni_delta_60*0.9;
                    DATA.AutoYLimitUpperAxes.HRMaxYLimit = max_nni_delta_60*1.1;
                end
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
            %             set(axes_handle, 'YLim', [MinYLimit MaxYLimit]);
            set(axes_handle, 'YLim', [MinYLimit MaxYLimit]);
        catch
            if ~isnan(MinYLimit) && ~isnan(MaxYLimit)
                %                 disp('temp');
                set(axes_handle, 'YLim', [MinYLimit-10 MaxYLimit+10]);
            end
        end
    end
%%
    function setXAxesLim()
        ha = GUI.RRDataAxes;
        
        set(ha, 'XLim', [DATA.firstSecond2Show DATA.firstSecond2Show + DATA.MyWindowSize]);
        setAxesXTicks(ha);
        
        %         blue_line_handle = get(GUI.all_data_handle);
        %         all_x = blue_line_handle.XData;
        %
        %         window_size_in_data_points = size(find(all_x > DATA.firstSecond2Show & all_x < DATA.firstSecond2Show + DATA.MyWindowSize));
        
        window_size_in_data_points = data_points_number();
        
        if strcmp(DATA.Integration, 'oximetry')
            ed_color = DATA.ox_raw_data_color;
            mr_color = DATA.ox_raw_data_color;
        else
            ed_color = 'b';
            mr_color = [1, 1, 1];
        end
        
        if window_size_in_data_points < 350
            %             set(GUI.raw_data_handle, 'Marker', 'o', 'MarkerSize', 2, 'MarkerEdgeColor', ed_color, 'MarkerFaceColor', [1, 1, 1]); % 4 'MarkerEdgeColor', [180 74 255]/255
            set(GUI.raw_data_handle, 'Marker', 'o', 'MarkerSize', 2, 'MarkerEdgeColor', ed_color, 'MarkerFaceColor', mr_color); % 4 'MarkerEdgeColor', [180 74 255]/255
        else
            set(GUI.raw_data_handle, 'Marker', 'none');
        end
    end
%%
    function plotAllData()
        ha = GUI.AllDataAxes;
        ha.FontName = DATA.font_name;
        
        if ~DATA.PlotHR  % == 0
            data =  DATA.rri;
        else
            data =  60 ./ DATA.rri;
        end
                
        if strcmp(DATA.Integration, 'oximetry')
            data_color = DATA.ox_raw_data_color;
        else
            data_color = 'b';
        end
        
        GUI.all_data_handle = line(DATA.trr, data, 'Color', data_color, 'Parent', ha, 'Marker', '*', 'MarkerSize', 2, 'DisplayName', 'Hole time series'); % 'LineWidth', 1.5
        
        set(ha, 'XLim', [0 DATA.RRIntPage_Length]);
%         ha.TickLabelInterpreter = 'Latex';
        
        % PLot red rectangle
        %         my_ylim = get(ha, 'YLim');
        my_ylim = ylim(ha);
        x_box = [0 DATA.MyWindowSize DATA.MyWindowSize 0 0];
        y_box = [my_ylim(1) my_ylim(1) my_ylim(2) my_ylim(2) my_ylim(1)];
        
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
        y_segment_start = my_ylim(1);
        y_segment_stop = my_ylim(2);
        
        v = [x_segment_start y_segment_start; x_segment_stop y_segment_start; x_segment_stop y_segment_stop; x_segment_start y_segment_stop];
        f = [1 2 3 4];
        
        if strcmp(DATA.Integration, 'oximetry')
            f_a = 0.3;
        else
            f_a = 0.3;
        end
        GUI.blue_line = patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.rectangle_color, 'EdgeColor', DATA.rectangle_color, 'LineWidth', 2, 'FaceAlpha', f_a, 'EdgeAlpha', 0.9, 'Parent', ha); % , 'Marker', '^', 'MarkerSize', 7, 'MarkerFaceColor', DATA.rectangle_color, 'Linewidth', 2
        
        setAxesXTicks(ha);
        
        GUI.red_rect = line(x_box, y_box, 'Color', 'r', 'Linewidth', 3, 'Parent', ha);
        
        setAllowAxesZoom(DATA.zoom_handle, GUI.AllDataAxes, false);
    end
%%
    function color_data = create_color_array4oximetry()
        %         data = DATA.rri;
        data = DATA.nni;
        
        data_size = length(data);
        
        color_data = zeros(data_size, 1, 3);
        for i = 1 : data_size
            color_data(i, 1, :) = DATA.ox_filt_data_color; % [0 0 1]
        end
        
        [DesReg_number, ~] = size(DATA.DesaturationsRegions);
        
        for i = 1 : DesReg_number
            for j = DATA.DesaturationsRegions(i, 1) : DATA.DesaturationsRegions(i, 2)
                if mod(i, 2) == 0
                    my_color = [1 0 1]; % [1 0 1]
                else
                    my_color = [1 0 0]; % [1 0 0]
                end
                color_data(j, :, :) = my_color;
            end
        end
    end
%%
    function plotRawData()
        ha = GUI.RRDataAxes;
                        
        signal_time = DATA.trr;
        signal_data = DATA.rri;
        
        switch DATA.Integration
            case 'oximetry'
                data =  signal_data;
                data(end) = NaN;
%                 yString = '$SpO_2(\%)$';
                yString = 'SpO_2 (%)';
                color_data = create_color_array4oximetry();
                %               GUI.raw_data_handle = patch(signal_time, data, color_data, 'EdgeColor', 'flat', 'LineWidth', 2.5, 'Parent', ha, 'DisplayName', 'Time series');
                GUI.raw_data_handle = plot(ha, signal_time, data, 'Color', DATA.ox_raw_data_color, 'LineStyle', '-', 'LineWidth', DATA.ox_rd_lw, 'DisplayName', 'Time series');
                
                GUI.filtered_handle = patch(ones(1, length(DATA.tnn))*NaN, ones(1, length(DATA.nni))*NaN, color_data,...
                    'EdgeColor', 'flat', 'FaceColor','flat', 'LineWidth', DATA.ox_fd_lw, 'LineStyle', '-', 'DisplayName', 'Selected filtered time series', 'Parent', ha);
                uistack(GUI.filtered_handle, 'top');
                %                 GUI.filtered_handle.HandleVisibility = 'off';
            otherwise
                if ~DATA.PlotHR
                    data =  signal_data;
%                     yString = '$RR $\space$ (sec)$';
                    yString = 'RR (sec)';
                else
                    data =  60 ./ signal_data;
%                     yString = '$HR $\space$ (BPM)$';
                    yString = 'HR (BPM)';
                end
                GUI.raw_data_handle = plot(ha, signal_time, data, 'b-', 'LineWidth', 2, 'DisplayName', 'Time series');
                GUI.filtered_handle = line(ones(1, length(DATA.tnn))*NaN, ones(1, length(DATA.nni))*NaN, 'LineWidth', 1, 'Color', 'g', 'LineStyle', '-', 'DisplayName', 'Selected filtered time series', 'Parent', ha);
                GUI.only_filtered_handle = line(ones(1, length(DATA.tnn))*NaN, ones(1, length(DATA.nni))*NaN, 'LineWidth', 1, 'Color', 'g', 'LineStyle', '-', 'DisplayName', 'Selected only filtered time series', 'Parent', ha);
        end
        
        hold(ha, 'on');
        
        %         GUI.filtered_handle = line(ones(1, length(DATA.tnn))*NaN, ones(1, length(DATA.nni))*NaN, 'LineWidth', 1, 'Color', 'g', 'LineStyle', '-', 'DisplayName', 'Selected filtered time series', 'Parent', ha);
        %
        %         if ~strcmp(DATA.Integration, 'oximetry')
        %             GUI.only_filtered_handle = line(ones(1, length(DATA.tnn))*NaN, ones(1, length(DATA.nni))*NaN, 'LineWidth', 1, 'Color', 'g', 'LineStyle', '-', 'DisplayName', 'Selected only filtered time series', 'Parent', ha);
        %         end
        
%         xlabel(ha, '$Time (h:min:sec)$', 'Interpreter', 'Latex');
        xlabel(ha, 'Time (h:min:sec)');
        ylabel(ha, yString); % , 'Interpreter', 'Latex'
%         ha.TickLabelInterpreter = 'Latex';
        
        if ~strcmp(DATA.Integration, 'oximetry')
            DATA.legend_handle = legend(ha, 'show', 'Location', 'southeast', 'Orientation', 'horizontal'); % , 'interpreter', 'latex'
            if sum(ismember(properties(DATA.legend_handle), 'AutoUpdate'))
                DATA.legend_handle.AutoUpdate = 'off';
                DATA.legend_handle.Box = 'off';
            end
            DATA.legend_handle.String = DATA.legend_handle.String(1:end-1);            
            %             legend([GUI.raw_data_handle, GUI.filtered_handle], DATA.legend_handle.String(1 : end - 1));
        else
            [DATA.legend_handle, legObj] = legend(ha, 'show', 'Location', 'southeast', 'Orientation', 'horizontal'); % , 'interpreter', 'latex'
            if sum(ismember(properties(DATA.legend_handle), 'AutoUpdate'))
                DATA.legend_handle.AutoUpdate = 'off';
                DATA.legend_handle.Box = 'off';
            end
            DATA.p_h = findobj(legObj, 'Type', 'Patch');
            DATA.p_h.FaceAlpha = 0;
            
            x = get(DATA.p_h, 'xdata');
            y = get(DATA.p_h, 'ydata');
            y = mean(y);
            x = [x(1); x(3)];
            y = [y; y];
            ff = [1 2];
            
            set(DATA.p_h, 'Vertices', [x y], 'Faces', ff, 'EdgeColor', DATA.ox_filt_data_color);
            
            %         https://www.mathworks.com/matlabcentral/answers/515053-legend-of-a-patch-object-with-a-line-in-the-center
        end
        
        DATA.legend_handle.FontName = DATA.font_name;
        ha.FontName = DATA.font_name;
        
        set(ha, 'XLim', [DATA.firstSecond2Show, DATA.firstSecond2Show + DATA.MyWindowSize]);
        
        setAllowAxesZoom(DATA.zoom_handle, GUI.RRDataAxes, false);
    end


% leg_MSE,objh] = legend(s_MSE(i),'BSL','ABK','Filtered','Location','NorthEast','FontName','Calibri');
%     set(leg_MSE,'Box','off');
%     set(leg_MSE,'FontSize',font_size);
%     if i == 1 leg_MSE.Location = 'SouthEast'; end
%     if i == 2 leg_MSE.Location = 'SouthEast'; end
%     lineh = findobj(objh,'type','line');
%         lineh(2).XData = [0.237 0.38];
%         lineh(4).XData = [0.237 0.38];
%         lineh(6).XData = [0.237 0.38];



%%
    function plotFilteredData()
        if isfield(DATA.AnalysisParams, 'segment_startTime')
            Filt_time_data = DATA.tnn;
            Filt_data = DATA.nni;
            %             Filt_data_saved = DATA.nni_saved;
            
            filt_win_indexes = find(Filt_time_data >= DATA.AnalysisParams.segment_startTime & Filt_time_data <= DATA.AnalysisParams.segment_effectiveEndTime);
            
            if ~isempty(filt_win_indexes)
                
                filt_signal_time = Filt_time_data(filt_win_indexes(1) : filt_win_indexes(end));
                filt_signal_data = Filt_data(filt_win_indexes(1) : filt_win_indexes(end));
                %                 filt_signal_data_saved = Filt_data_saved(filt_win_indexes);
                
                if DATA.PlotHR == 0
                    filt_data =  filt_signal_data;
                    %                     filt_data_saved =  filt_signal_data_saved;
                else
                    filt_data =  60 ./ filt_signal_data;
                    %                     filt_data_saved =  60 ./ filt_signal_data_saved;
                end
                filt_data_time = ones(1, length(DATA.tnn))*NaN;
                filt_data_vector = ones(1, length(DATA.nni))*NaN;
                %                 filt_data_vector_saved = ones(1, length(DATA.nni))*NaN;
                
                filt_data_time(filt_win_indexes) = filt_signal_time;
                filt_data_vector(filt_win_indexes) = filt_data;
                %                 filt_data_vector_saved(filt_win_indexes) = filt_data_saved;
                
                set(GUI.filtered_handle, 'XData', filt_data_time, 'YData', filt_data_vector);
                %                 set(GUI.only_filtered_handle, 'XData', filt_data_time, 'YData', filt_data_vector_saved);
            end
            if ~strcmp(DATA.Integration, 'oximetry')
                if ~isempty(filt_win_indexes)
                    Filt_data_saved = DATA.nni_saved;
                    filt_signal_data_saved = Filt_data_saved(filt_win_indexes);
                    if DATA.PlotHR == 0
                        filt_data_saved =  filt_signal_data_saved;
                    else
                        filt_data_saved =  60 ./ filt_signal_data_saved;
                    end
                    filt_data_vector_saved = ones(1, length(DATA.nni))*NaN;
                    filt_data_vector_saved(filt_win_indexes) = filt_data_saved;
                    set(GUI.only_filtered_handle, 'XData', filt_data_time, 'YData', filt_data_vector_saved);
                end
            end
        end
    end
%%
    function plotDesaturationsRegions()
        if ~isempty(DATA.DesaturationsRegions)
            if isfield(GUI, 'DesaturationsLineHandle')
                delete(GUI.DesaturationsLineHandle);
            end
            
            if isfield(GUI, 'DesaturationsLineHandle_AllDataAxes')
                delete(GUI.DesaturationsLineHandle_AllDataAxes);
            end
            
            ha = GUI.RRDataAxes;
            MaxYLimit = DATA.YLimUpperAxes.MaxYLimit;
            MinYLimit = DATA.YLimUpperAxes.MinYLimit;
            
            qd_size = size(DATA.DesaturationsRegions);
            intervals_num = qd_size(2);
            f = [1 2 3 4];
            
            for i = 1 : intervals_num
                
                v = [DATA.QualityAnnotations_Data(i,1) MinYLimit; DATA.QualityAnnotations_Data(i,2) MinYLimit; DATA.QualityAnnotations_Data(i,2) MaxYLimit; DATA.QualityAnnotations_Data(i,1) MaxYLimit];
                
                GUI.PinkLineHandle(i) =  patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.quality_color{DATA.quality_class_ind(i)}, 'EdgeColor', DATA.quality_color{DATA.quality_class_ind(i)}, ...
                    'LineWidth', 1, 'FaceAlpha', 0.27, 'EdgeAlpha', 0.5, 'UserData', DATA.quality_class_ind(i), 'Parent', GUI.RRDataAxes);
                
                uistack(GUI.PinkLineHandle(i), 'bottom');
                
                ylim = get(GUI.AllDataAxes, 'YLim');
                
                v = [DATA.QualityAnnotations_Data(i,1) min(ylim); DATA.QualityAnnotations_Data(i,2) min(ylim); DATA.QualityAnnotations_Data(i,2) max(ylim); DATA.QualityAnnotations_Data(i,1) max(ylim)];
                GUI.PinkLineHandle_AllDataAxes(i) = patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.quality_color{DATA.quality_class_ind(i)}, 'EdgeColor', DATA.quality_color{DATA.quality_class_ind(i)}, ...
                    'LineWidth', 1, 'FaceAlpha', 0.7, 'EdgeAlpha', 0.8, 'UserData', DATA.quality_class_ind(i), 'Parent', GUI.AllDataAxes);
                uistack(GUI.PinkLineHandle_AllDataAxes(i), 'bottom');
            end
        end
    end
%%
    function plotDataQuality()
        if ~isempty(DATA.QualityAnnotations_Data)
            if ~isempty(DATA.rri)
                ha = GUI.RRDataAxes;
                MaxYLimit = DATA.YLimUpperAxes.MaxYLimit;
                MinYLimit = DATA.YLimUpperAxes.MinYLimit;
                
                qd_size = size(DATA.QualityAnnotations_Data);
                intervals_num = qd_size(1);
                
                if ~isfield(GUI, 'GreenLineHandle') || ~isvalid(GUI.GreenLineHandle)
                    GUI.GreenLineHandle = line([DATA.firstSecond2Show DATA.firstSecond2Show + DATA.MyWindowSize], [MaxYLimit MaxYLimit], 'Color', DATA.MyGreen, 'LineWidth', 3, 'Parent', ha);
                else
                    GUI.GreenLineHandle.XData = [DATA.firstSecond2Show DATA.firstSecond2Show + DATA.MyWindowSize];
                    GUI.GreenLineHandle.YData = [MaxYLimit MaxYLimit];
                end
                uistack(GUI.GreenLineHandle, 'down');
                %---------------------------------
                
                if ~(DATA.QualityAnnotations_Data(1, 1) + DATA.QualityAnnotations_Data(1,2))==0
                    
                    if ~isfield(GUI, 'RedLineHandle') || ~isvalid(GUI.RedLineHandle(1))
                        GUI.RedLineHandle = line((DATA.QualityAnnotations_Data)', [MaxYLimit MaxYLimit]', 'Color', 'red', 'LineWidth', 3, 'Parent', ha);
                        uistack(GUI.RedLineHandle, 'top');
                    else
                        for i = 1 : intervals_num
                            GUI.RedLineHandle(i).XData = (DATA.QualityAnnotations_Data(i, :))';
                            GUI.RedLineHandle(i).YData = [MaxYLimit MaxYLimit]';
                        end
                    end
                    
                    if isfield(GUI, 'PinkLineHandle')
                        delete(GUI.PinkLineHandle);
                    end
                    
                    if isfield(GUI, 'PinkLineHandle_AllDataAxes')
                        delete(GUI.PinkLineHandle_AllDataAxes);
                    end
                    
                    for i = 1 : intervals_num
                        f = [1 2 3 4];
                        v = [DATA.QualityAnnotations_Data(i,1) MinYLimit; DATA.QualityAnnotations_Data(i,2) MinYLimit; DATA.QualityAnnotations_Data(i,2) MaxYLimit; DATA.QualityAnnotations_Data(i,1) MaxYLimit];
                        
                        GUI.PinkLineHandle(i) =  patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.quality_color{DATA.quality_class_ind(i)}, 'EdgeColor', DATA.quality_color{DATA.quality_class_ind(i)}, ...
                            'LineWidth', 1, 'FaceAlpha', 0.27, 'EdgeAlpha', 0.5, 'UserData', DATA.quality_class_ind(i), 'Parent', GUI.RRDataAxes);
                        
                        uistack(GUI.PinkLineHandle(i), 'bottom');
                        
                        ylim = get(GUI.AllDataAxes, 'YLim');
                        f = [1 2 3 4];
                        v = [DATA.QualityAnnotations_Data(i,1) min(ylim); DATA.QualityAnnotations_Data(i,2) min(ylim); DATA.QualityAnnotations_Data(i,2) max(ylim); DATA.QualityAnnotations_Data(i,1) max(ylim)];
                        GUI.PinkLineHandle_AllDataAxes(i) = patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.quality_color{DATA.quality_class_ind(i)}, 'EdgeColor', DATA.quality_color{DATA.quality_class_ind(i)}, ...
                            'LineWidth', 1, 'FaceAlpha', 0.7, 'EdgeAlpha', 0.8, 'UserData', DATA.quality_class_ind(i), 'Parent', GUI.AllDataAxes);
                        uistack(GUI.PinkLineHandle_AllDataAxes(i), 'bottom');
                    end
                    
                    if isvalid(DATA.legend_handle)
                        if strcmp(DATA.Integration, 'oximetry')
                            quality_string = 'ventilation';
                        else
                            quality_string = 'Bad quality';
                        end
                        if DATA.Detrending
                            if length(DATA.legend_handle.String) < 4 %
                                legend([GUI.raw_data_handle, GUI.only_filtered_handle, GUI.filtered_handle GUI.PinkLineHandle(1)], [DATA.legend_handle.String quality_string]);
                            end
                        else
                            if length(DATA.legend_handle.String) < 3 %
                                legend([GUI.raw_data_handle, GUI.filtered_handle GUI.PinkLineHandle(1)], [DATA.legend_handle.String quality_string]);
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
                    h_e = errordlg('Please, choose the Data Quality Annotations File.', 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    return;
                end
                if ~isempty(Class)
                    DATA_Class = Class;
                end
                %             elseif strcmpi(ExtensionFileName, 'sqi') % strcmpi(ExtensionFileName, 'qrs') || strcmpi(ExtensionFileName, 'atr')
                %                 if DATA.SamplingFrequency ~= 0
                % %                     quality_data = mhrv.wfdb.rdann( [PathName QualityFileName], ExtensionFileName, 'ann_types', '"F"')/DATA.SamplingFrequency;
                %                     quality_data = mhrv.wfdb.rdann( [PathName QualityFileName], ExtensionFileName)/DATA.SamplingFrequency;
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
                            h_e = errordlg('Please, choose the Data Quality Annotations File.', 'Input Error');
                            if strcmp(DATA.Integration, 'oximetry')
                                setLogo(h_e, 'M_OBM');
                            else
                                setLogo(h_e, 'M2');
                            end
                            return;
                        end
                    else
                        h_e = errordlg('Please, choose the right format for Data Quality Annotations File.', 'Input Error');
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(h_e, 'M_OBM');
                        else
                            setLogo(h_e, 'M2');
                        end
                        return;
                    end
                    fclose(fileID);
                else
                    return;
                end
            else
                h_e = errordlg('Please, choose only *.mat or *.txt file.', 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
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
            
            if isfield(GUI, 'PinkLineHandle_AllDataAxes')
                delete(GUI.PinkLineHandle_AllDataAxes);
                GUI = rmfield(GUI, 'PinkLineHandle_AllDataAxes');
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
        if strcmpi(mammal, 'rabbit')
            mammal = 'rabbit';
        elseif ~isempty(regexpi(mammal, 'mice|mouse'))
            mammal = 'mouse';
        elseif ~isempty(regexpi(mammal, 'dog|dogs|canine'))
            mammal = 'dog';
        end
        mammal_index = find(strcmp(DATA.mammals, mammal));
    end
%%
    function [mammal, mammal_index, integration, isM1] = Load_Data_from_SingleFile(QRS_FileName, PathName, DataFileMap, waitbar_handle)
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
                
                if strcmpi(ExtensionFileName, 'txt') || strcmpi(ExtensionFileName, 'mat') || strcmpi(ExtensionFileName, 'qrs') || strcmpi(ExtensionFileName, 'atr') || strcmpi(ExtensionFileName, 'dat')
                    
                    Config = ReadYaml('Loader Config.yml');
                    
                    if isempty(fields(DataFileMap))
                        DataFileMap = loadDataFile([PathName QRS_FileName]);
                    end
                    
                    MSG = DataFileMap('MSG');
                    if strcmp(Config.alarm.(MSG), 'OK')
                        data = DataFileMap('DATA');
                        if ~strcmp(data.Data.Type, 'electrography')
                            
                            clearData();
                            clear_statistics_plots();
                            clearStatTables();
                            clean_gui();
                            delete_temp_files();
                            
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
                            choice = questdlg('This recording contains raw electrophysiological data. It will be opened in the pulse module.', ...
                                'Select module', 'OK', 'Cancel', 'OK');
                            
                            switch choice
                                case 'OK'
                                    fileNameFromM2.FileName = QRS_FileName;
                                    fileNameFromM2.PathName = PathName;
                                    PhysioZooGUIPulse(fileNameFromM2, DataFileMap);
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
                else
                    close(waitbar_handle);
                    throw(MException('LoadFile:text', 'Please, choose another file type.'));
                end
                
                set_qrs_data(QRS_data, time_data);
                
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
            %             DATA.trr = time_data;
            DATA.trr = time_data-time_data(1);
        end
    end
%%
%     function Set_MammalIntegration_After_Load()
%         GUI.Mammal_popupmenu.Value = DATA.mammal_index;
%         GUI.Integration_popupmenu.Value = DATA.integration_index;
%     end
%%
    function onOpenFile(~, ~, fileNameFromM1, DataFileMapFromM1)
        if nargin < 3
            set_defaults_path();
            
            [QRS_FileName, PathName] = uigetfile({'*.*', 'All files';...
                '*.txt','Text Files (*.txt)'
                '*.mat','MAT-files (*.mat)'; ...
                '*.qrs; *.atr', 'WFDB Files (*.qrs; *.atr)'}, ...
                'Open QRS File', [DIRS.dataDirectory filesep '*.' DIRS.Ext_open]);
            DataFileMap = struct();
        else
            QRS_FileName = fileNameFromM1.FileName;
            PathName = fileNameFromM1.PathName;
            DataFileMap = DataFileMapFromM1;
        end
        
        DATA.GroupsCalc = 0;
        
        try
            Load_Single_File(QRS_FileName, PathName, DataFileMap);
        catch e
            h_e = errordlg(['onOpenFile: ' e.message], 'Input Error');
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(h_e, 'M_OBM');
            else
                setLogo(h_e, 'M2');
            end
        end
    end
%%
    function Load_Single_File(QRS_FileName, PathName, DataFileMap)
        if QRS_FileName
            [files_num, ~] = size(QRS_FileName);
            if files_num == 1
                
                try
                    waitbar_handle = waitbar(1/2, ['Loading file "' strrep(QRS_FileName, '_', '\_') '" '], 'Name', 'Loading...');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(waitbar_handle, 'M_OBM');
                    else
                        setLogo(waitbar_handle, 'M2');
                    end
                    [mammal, mammal_index, integration, whichModule] = Load_Data_from_SingleFile(QRS_FileName, PathName, DataFileMap, waitbar_handle);
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
                    h_e = errordlg(['Load Single File error: ' e.message], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    clean_gui();
                    cla(GUI.RRDataAxes, 'reset');
                    cla(GUI.AllDataAxes, 'reset');
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
                    
                    DATA.Integration = integration;
                    DATA.integration_index = find(strcmpi(DATA.GUI_Integration, DATA.Integration));
                    
                    if ~DATA.GroupsCalc
                        GUI.Mammal_popupmenu.String = mammal;
                        GUI.Integration_popupmenu.Value = DATA.integration_index;
                    end
                    
                    if mammal_index == length(DATA.mammals) % Custom mammal
                        config_file_name = 'default_ecg';
                        if ~DATA.GroupsCalc
                            GUI.Mammal_popupmenu.String = 'default';
                        end
                    else
                        config_file_name = [DATA.mammals{DATA.mammal_index} '_' DATA.integration_level{DATA.integration_index}];
                    end
                    
                    try
                        if ~strcmp(DATA.Integration, 'oximetry')
                            mhrv.defaults.mhrv_load_defaults('--clear');
                            mhrv.defaults.mhrv_load_defaults(config_file_name);
                        else
                            mhrv.defaults.mhrv_load_defaults('--clear', config_file_name);
                        end
                        
                        conf_name = [config_file_name '.yml'];
                        if ~DATA.GroupsCalc
                            set(GUI.Config_text, 'String', conf_name);
                        end
                        if Module3
                            set(GUI.GroupsConfig_text, 'String', conf_name); % for Groups analysis
                        end
                        DATA.config_file_name = config_file_name;
                        
                    catch e
                        h_e = errordlg(['mhrv.defaults.mhrv_load_defaults: ' e.message], 'Input Error');
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(h_e, 'M_OBM');
                        else
                            setLogo(h_e, 'M2');
                        end
                        if isvalid(waitbar_handle); close(waitbar_handle); end
                        return;
                    end
                    %                     if ~DATA.GroupsCalc
                    %                         waitbar(2 / 2, waitbar_handle, 'Create Config Parameters Windows'); setLogo(waitbar_handle, 'M2');
                    %                         if strcmp(DATA.Integration, 'oximetry')
                    %                             myColors.myEditTextColor = myEditTextColor;
                    %                             myColors.myUpBackgroundColor = myUpBackgroundColor;
                    %                             [DATA, GUI] = createConfigParametersInterface_Oximetry(DATA, GUI, myColors);
                    %                         else
                    %                             createConfigParametersInterface();
                    %                         end
                    %                         if isvalid(waitbar_handle); close(waitbar_handle); end
                    %                     end
                else
                    close(waitbar_handle);
                end
                
                if strcmp(DATA.Integration, 'oximetry')
                    
                    %                     GUI.RR_or_HR_plot_button.Enable = 'off';
                    
                    GUI.quality_vent_text.String = 'Ventilation file name';
                    GUI.DataQualityMenu.Label = 'Open ventilation file';
                    
                    %                     GUI.Detrending_checkbox.String = 'Median Filter';
                    %                     GUI.Detrending_checkbox.Callback = @Median_checkbox_Callback;
                    %                     GUI.Detrending_checkbox.Tooltip = 'Whether to apply median filter';
                    
                    GUI.MedianFilter_checkbox.Visible = 'on';
                    GUI.Detrending_checkbox.Visible = 'off';
                    
                    if Module3
                        GUI.Analysis_TabPanel.TabTitles = {'Statistics', 'General', 'Desaturations', 'Hypoxic Burden', 'Complexity', 'Periodicity', 'Group'};
                        
                        GUI.OBMTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
                        GUI.GroupTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
                        GUI.UpLeft_TabPanel.TabTitles = {'Main', 'Single', 'Options', 'Display', 'OBM', 'Group'};
                    else
                        
                        GUI.OBMTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
                        GUI.UpLeft_TabPanel.TabTitles = {'Main', 'Single', 'Options', 'Display', 'OBM'};
                        
                        GUI.FourthTab = uix.Panel( 'Parent', GUI.Analysis_TabPanel, 'Padding', DATA.Padding+2);
                        GUI.FifthTab = uix.Panel( 'Parent', GUI.Analysis_TabPanel, 'Padding', DATA.Padding+2);
                        GUI.Analysis_TabPanel.TabTitles = {'Statistics', 'General', 'Desaturations', 'Hypoxic Burden', 'Complexity', 'Periodicity'};
                        
                        %---------------------------
                        
                        tables_field_size = [-85 -1];
                        
                        GUI.FourthBox = uix.HBox('Parent', GUI.FourthTab, 'Spacing', DATA.Spacing);
                        GUI.ParamFourthBox = uix.VBox( 'Parent', GUI.FourthBox, 'Spacing', DATA.Spacing);
                        GUI.CMTable = uitable( 'Parent', GUI.ParamFourthBox, 'FontSize', DATA.SmallFontSize, 'FontName', 'Calibri');
                        GUI.CMTable.ColumnName = {'    Measures Name    ', 'Values'};
                        uix.Empty( 'Parent', GUI.ParamFourthBox );
                        set(GUI.ParamFourthBox, 'Heights', tables_field_size );
                        
                        fourth_hor_plots_boxes = uix.HBox('Parent', GUI.FourthBox, 'Spacing', DATA.Spacing);
                        
                        uix.Empty('Parent', fourth_hor_plots_boxes);
                        GUI.FourthAxes1 = axes('Parent', uicontainer('Parent', fourth_hor_plots_boxes) );
                        uix.Empty('Parent', fourth_hor_plots_boxes);
                        
                        set(fourth_hor_plots_boxes, 'Widths', [-1 -1.5 -1] );
                        
                        set(GUI.FourthBox, 'Widths', [-14 -80] );
                        %---------------------------
                        
                        GUI.FifthBox = uix.HBox('Parent', GUI.FifthTab, 'Spacing', DATA.Spacing);
                        
                        GUI.ParamFifthBox = uix.VBox('Parent', GUI.FifthBox, 'Spacing', DATA.Spacing);
                        GUI.PMTable = uitable('Parent', GUI.ParamFifthBox, 'FontSize', DATA.SmallFontSize, 'FontName', 'Calibri');
                        GUI.PMTable.ColumnName = {'    Measures Name    ', 'Values'};
                        uix.Empty('Parent', GUI.ParamFifthBox );
                        set(GUI.ParamFifthBox, 'Heights', tables_field_size );
                        
                        
                        vert_box = uix.VBox('Parent', GUI.FifthBox, 'Spacing', DATA.Spacing);
                        hor_box = uix.HBox('Parent', vert_box, 'Spacing', DATA.Spacing);
                        HorAxesBox = uix.HBox( 'Parent', vert_box, 'Spacing', DATA.Spacing);
                        
                        uix.Empty('Parent', hor_box);
                        GUI.oxim_per_log_Button = uicontrol('Style', 'ToggleButton', 'Parent', hor_box, 'Callback', @PSD_pushbutton_Callback, 'FontSize', DATA.BigFontSize, 'Value', 1, 'String', 'Log');
                        uix.Empty('Parent', hor_box);
                        set(hor_box, 'Widths', [-30 100 -45]); %   [-1 100]
                        
                        GUI.FifthAxes1 = axes('Parent', uicontainer('Parent', HorAxesBox));
                        GUI.FifthAxes2 = axes('Parent', uicontainer('Parent', HorAxesBox));
                        
                        set(vert_box, 'Heights', [-7 -93]);
                        
                        set(GUI.FifthBox, 'Widths', [-14 -80] );
                        set(findobj(GUI.FourthTab, 'Type', 'uicontainer'), 'BackgroundColor', myLowBackgroundColor);
                        set(findobj(GUI.FifthTab, 'Type', 'uicontainer'), 'BackgroundColor', myLowBackgroundColor);
                        
                        %                         set(findobj(GUI.OBMTab, 'Type', 'uipanel'), 'BackgroundColor', myUpBackgroundColor);
                        %---------------------------
                    end
                    
                    build_OBM_Tab();
                    
                    setLogo(GUI.Window, 'M_OBM');
                    
                    GUI.FourthParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', DATA.Padding+0);
                    GUI.FifthParamTab = uix.Panel( 'Parent', GUI.Advanced_TabPanel, 'Padding', DATA.Padding+0);
                    GUI.Advanced_TabPanel.TabTitles = {'Filtering', 'General', 'Desaturations', 'HypoxicBurden', 'Complexity', 'Periodicity'};
                    if DATA.SmallScreen
                        GUI.Advanced_TabPanel.FontSize = DATA.SmallFontSize - 3;
                    else
                        GUI.Advanced_TabPanel.FontSize = DATA.SmallFontSize - 3;
                    end
                    
                    tabs_widths = GUI.TimeSclPanel.Widths;
                    tabs_heights = GUI.TimeSclPanel.Heights;
                    
                    GUI.FourthSclPanel = uix.ScrollingPanel('Parent', GUI.FourthParamTab);
                    GUI.ComplexityParamBox = uix.VBox('Parent', GUI.FourthSclPanel, 'Spacing', DATA.Spacing+2);
                    set(GUI.FourthSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights);
                    
                    GUI.FifthParamSclPanel = uix.ScrollingPanel('Parent', GUI.FifthParamTab);
                    GUI.PeriodicityParamBox = uix.VBox('Parent', GUI.FifthParamSclPanel, 'Spacing', DATA.Spacing+2);
                    set(GUI.FifthParamSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights);
                    
                    set(findobj(GUI.Advanced_TabPanel, 'Type', 'uicontainer'), 'BackgroundColor', myUpBackgroundColor);
                    set(findobj(GUI.Advanced_TabPanel, 'Type', 'uipanel'), 'BackgroundColor', myUpBackgroundColor);
                    
                    % -----------------------
                    try
                        delete(GUI.NonLinearAxesBox);
                    catch
                    end
                    
                    GUI.NonLinearAxesBox = uix.HBox( 'Parent', GUI.NonLinearBox, 'Spacing', DATA.Spacing);
                    uix.Empty( 'Parent', GUI.NonLinearAxesBox );
                    GUI.NonLinearAxes1 = axes('Parent', uicontainer('Parent', GUI.NonLinearAxesBox));
                    uix.Empty( 'Parent', GUI.NonLinearAxesBox );
                    set(GUI.NonLinearAxesBox, 'Widths', [-1 -1.5 -1]);
                    set(GUI.NonLinearBox, 'Widths', [-1 -5]);  % [-1 -3]
                    set(findobj(GUI.NonLinearTab, 'Type', 'uicontainer'), 'BackgroundColor', myLowBackgroundColor);
                    
                    % -----------------------
                    %                     DATA.SpO2NewSamplingFrequency = mhrv.defaults.mhrv_get_default('filtSpO2.ResampSpO2.Original_fs', 'value');
                    
                    %                     DATA.rri_saved = DATA.rri;
                    %                     DATA.trr_saved = DATA.trr;
                    
                    
                    %                     if DATA.SamplingFrequency ~= DATA.SpO2NewSamplingFrequency
                    %
                    %                         wb = waitbar(0, 'SpO2: Resampling ... ', 'Name', 'SpO2'); setLogo(wb, 'M2');
                    %
                    %                         DATA.rri = ResampSpO2(DATA.rri, wb);
                    %
                    %                         if isvalid(wb); close(wb); end
                    %
                    %                         if isempty(DATA.rri)
                    %                             throw(MException('Load_Data_from_SingleFile:Data', 'Could not Resample SpO2 data.'));
                    %                         end
                    %                     end
                    %
                    %                     time_data = 1/DATA.SpO2NewSamplingFrequency : 1/DATA.SpO2NewSamplingFrequency : length(DATA.rri)/DATA.SpO2NewSamplingFrequency;
                    %                     set_qrs_data(DATA.rri, time_data);
                    
                else
                    
                    setLogo(GUI.Window, 'M2');
                    
                    %                     GUI.Detrending_checkbox.String = 'Detrend NN time series';
                    %                     GUI.Detrending_checkbox.Callback = @Detrending_checkbox_Callback;
                    %                     GUI.Detrending_checkbox.Tooltip = 'Enable or disable the detrending of the time series';
                    
                    %                     GUI.RR_or_HR_plot_button.Enable = 'on';
                    
                    GUI.MedianFilter_checkbox.Visible = 'off';
                    GUI.Detrending_checkbox.Visible = 'on';
                    
                    GUI.quality_vent_text.String = 'Signal quality file name';
                    GUI.DataQualityMenu.Label = 'Open signal quality file';
                    
                    if Module3
                        GUI.Analysis_TabPanel.TabTitles = {'Statistics', 'Time', 'Frequency', 'NonLinear', 'Group'};
                        
                        GUI.GroupTab = uix.Panel( 'Parent', GUI.UpLeft_TabPanel, 'Padding', DATA.Padding+2);
                        GUI.UpLeft_TabPanel.TabTitles = {'Main', 'Single', 'Options', 'Display', 'Group'};
                        
                    else
                        
                        GUI.UpLeft_TabPanel.TabTitles = {'Main', 'Single', 'Options', 'Display'};
                        
                        GUI.Analysis_TabPanel.TabTitles = {'Statistics', 'Time', 'Frequency', 'NonLinear'};
                        
                    end
                    GUI.Advanced_TabPanel.TabTitles = {'Filtering', 'Time', 'Frequency', 'NonLinear'};
                    %                     GUI.Advanced_TabPanel.FontSize = DATA.SmallFontSize - 1;
                    
                    % % -----------------------
                    try
                        delete(GUI.NonLinearAxesBox);
                    catch
                    end
                    GUI.NonLinearAxesBox = uix.HBox( 'Parent', GUI.NonLinearBox, 'Spacing', DATA.Spacing);
                    GUI.NonLinearAxes1 = axes('Parent', uicontainer('Parent', GUI.NonLinearAxesBox));
                    GUI.NonLinearAxes2 = axes('Parent', uicontainer('Parent', GUI.NonLinearAxesBox));
                    GUI.NonLinearAxes3 = axes('Parent', uicontainer('Parent', GUI.NonLinearAxesBox));
                    set(GUI.NonLinearAxesBox, 'Widths', [-24 -24 -24]);
                    set(GUI.NonLinearBox, 'Widths', [-1 -5]);
                    set(findobj(GUI.NonLinearTab, 'Type', 'uicontainer'), 'BackgroundColor', myLowBackgroundColor);
                    % % -----------------------
                end
                
                if ~DATA.GroupsCalc
                    waitbar(2 / 2, waitbar_handle, 'Create Config Parameters Windows');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(waitbar_handle, 'M_OBM');
                    else
                        setLogo(waitbar_handle, 'M2');
                    end
                    createConfigParametersInterface();
                    if isvalid(waitbar_handle); close(waitbar_handle); end
                end
                
                try
                    reset_plot_Data();
                catch e
                    h_e = errordlg(['Load_Single_File: ' e.message], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    return;
                end
                
                if ~DATA.GroupsCalc
                    reset_plot_GUI();
                    EnablePageUpDown();
                    
                    if isfield(GUI, 'RRDataAxes')
                        PathName = strrep(PathName, '\', '\\');                        
%                         PathName = strrep(PathName, '\', '$ \backslash $');
                        PathName = strrep(PathName, '_', '\_');
                        QRS_FileName_title = strrep(QRS_FileName, '_', '\_');
                        
                        TitleName = [PathName QRS_FileName_title] ;
                        title(GUI.RRDataAxes, TitleName, 'FontWeight', 'normal', 'FontSize', DATA.SmallFontSize, 'FontName', DATA.font_name); % , 'Interpreter', 'Latex'
                        
                        set(GUI.RecordName_text, 'String', QRS_FileName);
                    end
                    
                    set(GUI.SaveMeasures, 'Enable', 'on');
                    set(GUI.SaveParamFileMenu, 'Enable', 'on');
                    set(GUI.LoadConfigFile, 'Enable', 'on');
                    
                    set(GUI.open_config_pushbutton_handle, 'Enable', 'on');
                    
                    if strcmp(DATA.Integration, 'oximetry')
                        GUI.SaveMeasures.Label = 'Save SpO2 measures';
                        set(GUI.SaveFiguresAsMenu, 'Enable', 'on');
                        set(GUI.DataQualityMenu, 'Enable', 'on');
                        set(GUI.open_quality_pushbutton_handle, 'Enable', 'on');
                        %                         GUI.FilteringLevelBox.Visible = 'on';
                        GUI.DefaultMethodBox.Visible = 'off';
                        %                         GUI.Detrending_checkbox.Visible = 'on';
                        GUI.Filtering_popupmenu.String = DATA.Filters_SpO2;
                        GUI.FilteringLevel_popupmenu.String = DATA.FilterShortLevel;
                        %                         GUI.FilteringLevel_popupmenu.Enable = 'on';
                    else
                        GUI.SaveMeasures.Label = 'Save HRV measures';
                        set(GUI.SaveFiguresAsMenu, 'Enable', 'on');
                        set(GUI.DataQualityMenu, 'Enable', 'on');
                        set(GUI.open_quality_pushbutton_handle, 'Enable', 'on');
                        %                         GUI.FilteringLevelBox.Visible = 'on';
                        GUI.DefaultMethodBox.Visible = 'on';
                        %                         GUI.Detrending_checkbox.Visible = 'on';
                        GUI.Filtering_popupmenu.String = DATA.Filters_ECG;
                        GUI.FilteringLevel_popupmenu.String = DATA.FilterLevel;
                        %                         GUI.FilteringLevel_popupmenu.Enable = 'on';
                    end
                    reset_defaults_extensions();
                end
            end
        end
    end
%%
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
%     function [stat_data_cell, stat_row_names_cell, stat_descriptions_cell] = table2cell_StatisticsParam(stat_table)
%
%         variables_num = length(stat_table.Properties.VariableNames);
%         stat_data_cell = cell(variables_num, 1);
%         stat_row_names_cell = cell(variables_num, 1);
%         stat_descriptions_cell = cell(variables_num, 1);
%
%         table_properties = stat_table.Properties;
%         for i = 1 : variables_num
%             var_name = table_properties.VariableNames{i};
%             if length(stat_table.(var_name)) == 1
%                 if strcmp(stat_table.(var_name), ' ')
%                     stat_data_cell{i, 1} = ' ';
%                 else
%                     stat_data_cell{i, 1} = sprintf('%.2f', stat_table.(var_name));
%                 end
%             else
%                 stat_data_cell{i, 1} = sprintf('%.2f\x00B1%.2f', stat_table.(var_name)(1), stat_table.(var_name)(2));
%             end
%             stat_row_names_cell{i, 1} = [var_name ' (' table_properties.VariableUnits{i} ')'];
%             stat_descriptions_cell{i, 1} = table_properties.VariableDescriptions{i};
%         end
%     end
%%
    function updateTimeStatistics()
        GUI.TimeParametersTableRowName = [GUI.TimeParametersTableRowName; GUI.FragParametersTableRowName];
        GUI.TimeParametersTableData = [GUI.TimeParametersTableData; GUI.FragParametersTableData];
        GUI.TimeParametersTable.Data = [GUI.TimeParametersTable.Data; GUI.FragParametersTable.Data];
    end
%%
%     function updateODIDSMStatistics()
%         GUI.FrequencyParametersTableRowName = [GUI.ODIParametersTableRowName; GUI.DSMParametersTableRowName];
%         GUI.FrequencyParametersTableData = [GUI.ODIParametersTableData; GUI.DSMParametersTableData];
%         GUI.FrequencyParametersTable.Data = [GUI.ODIParametersTable.Data; GUI.DSMParametersTable.Data];
%     end
%%
    function clear_statistics_plots()
        clear_time_statistics_results(GUI);
        clear_frequency_statistics_results(GUI);
        clear_nonlinear_statistics_results(GUI);
        try
            clear_periodicity_statistics_results(GUI);
            clear_complexity_statistics_results(GUI);
        catch
        end
    end
% %%
%     function clear_time_statistics_results()
%         grid(GUI.TimeAxes1, 'off');
%         legend(GUI.TimeAxes1, 'off')
%         cla(GUI.TimeAxes1);
%         GUI.TimeAxes1.Visible = 'off';
%     end
% %%
%     function clear_periodicity_statistics_results(GUI)
%         grid(GUI.FifthAxes1, 'off');
%         grid(GUI.FifthAxes2, 'off');
%         legend(GUI.FifthAxes1, 'off');
%         legend(GUI.FifthAxes2, 'off');
%         cla(GUI.FifthAxes1);
%         cla(GUI.FifthAxes2);
%         GUI.FifthAxes1.Visible = 'off';
%         GUI.FifthAxes2.Visible = 'off';
%     end
% %%
%     function clear_complexity_statistics_results(GUI)
%         grid(GUI.FourthAxes1, 'off');
%         legend(GUI.FourthAxes1, 'off');
%         cla(GUI.FourthAxes1);
%         GUI.FourthAxes1.Visible = 'off';
%     end
% %%
%     function clear_frequency_statistics_results(GUI)
%         grid(GUI.FrequencyAxes1, 'off');
%         grid(GUI.FrequencyAxes2, 'off');
%         legend(GUI.FrequencyAxes1, 'off');
%         legend(GUI.FrequencyAxes2, 'off');
%         cla(GUI.FrequencyAxes1);
%         cla(GUI.FrequencyAxes2);
%         GUI.FrequencyAxes1.Visible = 'off';
%         GUI.FrequencyAxes2.Visible = 'off';
%         xlim(GUI.FrequencyAxes1, 'auto');
%     end
% %%
%     function clear_nonlinear_statistics_results(GUI)
%         try
%             cla(GUI.NonLinearAxes1);
%             grid(GUI.NonLinearAxes1, 'off');
%             legend(GUI.NonLinearAxes1, 'off');
%             GUI.NonLinearAxes1.Visible = 'off';
%
%             cla(GUI.NonLinearAxes2);
%             grid(GUI.NonLinearAxes2, 'off');
%             legend(GUI.NonLinearAxes2, 'off');
%             GUI.NonLinearAxes2.Visible = 'off';
%
%             cla(GUI.NonLinearAxes3);
%             grid(GUI.NonLinearAxes3, 'off');
%             legend(GUI.NonLinearAxes3, 'off');
%             GUI.NonLinearAxes3.Visible = 'off';
%         catch
%         end
%     end
%%
    function plot_complexity_results(active_window)
        
        clear_complexity_statistics_results(GUI);
        plot_data = DATA.CMStat.PlotData{active_window};
        
        if ~isempty(plot_data) && ~all(isnan(plot_data.fn))
            GUI.FourthAxes1.Visible = 'on';
            plot_oximetry_dfa(GUI.FourthAxes1, plot_data)
        else
            GUI.FourthAxes1.Visible = 'off';
        end
        box(GUI.FourthAxes1, 'off');
        GUI.FourthAxes1.FontName = DATA.font_name;
        %         setAllowAxesZoom(DATA.zoom_handle, GUI.FifthAxes1, false);
    end
%%
    function plot_desaturations_results(active_window)
        
        clear_frequency_statistics_results(GUI);
        plot_data = DATA.FrStat.PlotData{active_window};
        
        if ~isempty(plot_data.des_length) && sum(plot_data.des_length) > 0
            GUI.FrequencyAxes1.Visible = 'on';
            plot_oximetry_desat_hist(GUI.FrequencyAxes1, plot_data.des_length);
        else
            GUI.FrequencyAxes1.Visible = 'off';
        end
        if ~isempty(plot_data.des_depth) && sum(plot_data.des_depth) > 0
            GUI.FrequencyAxes2.Visible = 'on';
            plot_oximetry_desaturation_depths(GUI.FrequencyAxes2, plot_data.des_depth);
        else
            GUI.FrequencyAxes2.Visible = 'off';
        end
        box(GUI.FrequencyAxes1, 'off');
        box(GUI.FrequencyAxes2, 'off');
        GUI.FrequencyAxes1.FontName = DATA.font_name;
        GUI.FrequencyAxes2.FontName = DATA.font_name;
        %         setAllowAxesZoom(DATA.zoom_handle, GUI.FifthAxes1, false);
    end
%%
    function plot_general_statistics_results(active_window)
        
        clear_time_statistics_results(GUI);
        plot_data = DATA.TimeStat.PlotData{active_window};
        
        if ~all(isnan(plot_data))
            GUI.TimeAxes1.Visible = 'on';
            plot_oximetry_time_hist(GUI.TimeAxes1, plot_data)
        else
            GUI.TimeAxes1.Visible = 'off';
        end
        box(GUI.TimeAxes1, 'off');
        GUI.TimeAxes1.FontName = DATA.font_name;
        %         setAllowAxesZoom(DATA.zoom_handle, GUI.FifthAxes1, false);
    end
%%
    function plot_periodicity_statistics_results(active_window)
        
        clear_periodicity_statistics_results(GUI);
        plot_data = DATA.PMStat.PlotData{active_window};
        
        if ~isempty(plot_data)
            if ~all(isnan(plot_data.fft.y))
                GUI.FifthAxes1.Visible = 'on';
                GUI.oxim_per_log_Button.Visible = 'on';
                plot_spo2_psd_graph(GUI.FifthAxes1, plot_data.fft, DATA.freq_yscale);
            else
                GUI.FifthAxes1.Visible = 'off';
                GUI.oxim_per_log_Button.Visible = 'off';
            end
            if ~isempty(plot_data.PRSA_window)
                GUI.FifthAxes2.Visible = 'on';
                plot_oximetry_PRSA(GUI.FifthAxes2, plot_data.PRSA_window);
            else
                GUI.FifthAxes2.Visible = 'off';
            end
        else
            GUI.FifthAxes1.Visible = 'off';
            GUI.FifthAxes2.Visible = 'off';
            GUI.oxim_per_log_Button.Visible = 'off';
        end
        box(GUI.FifthAxes1, 'off' );
        box(GUI.FifthAxes2, 'off' );
        GUI.FifthAxes1.FontName = DATA.font_name;
        GUI.FifthAxes2.FontName = DATA.font_name;
        %         setAllowAxesZoom(DATA.zoom_handle, GUI.FifthAxes1, false);
    end
%%
    function plot_time_statistics_results(active_window)
        
        clear_time_statistics_results(GUI);
        plot_data = DATA.TimeStat.PlotData{active_window};
        
        if ~isempty(plot_data)
            GUI.TimeAxes1.Visible = 'on';
            mhrv.plots.plot_hrv_time_hist(GUI.TimeAxes1, plot_data, 'clear', true);
        end
        box(GUI.TimeAxes1, 'off');
        GUI.TimeAxes1.FontName = DATA.font_name;
        setAllowAxesZoom(DATA.zoom_handle, GUI.TimeAxes1, false);
    end
%%
    function plot_frequency_statistics_results(active_window)
        
        clear_frequency_statistics_results(GUI);
        
        plot_data = DATA.FrStat.PlotData{active_window};
        
        GUI.FrequencyAxes1.Visible = 'on';
        GUI.FrequencyAxes2.Visible = 'on';
        
        if ~isempty(plot_data)
            mhrv.plots.plot_hrv_freq_spectrum(GUI.FrequencyAxes1, plot_data, 'detailed_legend', false, 'yscale', DATA.freq_yscale);
            mhrv.plots.plot_hrv_freq_beta(GUI.FrequencyAxes2, plot_data);
            xlabel(GUI.FrequencyAxes2, 'log(Frequency (Hz))');
            GUI.FrequencyAxes1.YLabel.String = strrep(GUI.FrequencyAxes1.YLabel.String, '^2', sprintf('\x00B2'));
            GUI.FrequencyAxes2.YLabel.String = strrep(GUI.FrequencyAxes2.YLabel.String, '^2', sprintf('\x00B2'));
        end
        box(GUI.FrequencyAxes1, 'off');
        box(GUI.FrequencyAxes2, 'off');
        GUI.FrequencyAxes1.FontName = DATA.font_name;
        GUI.FrequencyAxes2.FontName = DATA.font_name;        
        set(findobj(GUI.FrequencyAxes1.Children, 'Type', 'Text'), 'FontName', DATA.font_name);
%         GUI.FrequencyAxes1.Title.Interpreter = 'Latex';
%         GUI.FrequencyAxes1.XLabel.Interpreter = 'Latex';
%         GUI.FrequencyAxes1.YLabel.Interpreter = 'Latex';
        setAllowAxesZoom(DATA.zoom_handle, GUI.FrequencyAxes2, false);
    end
%%
    function plot_nonlinear_statistics_results(active_window)
        
        clear_nonlinear_statistics_results(GUI);
        
        plot_data = DATA.NonLinStat.PlotData{active_window};
        
        %         if ~isempty(plot_data)
        if ~strcmp(DATA.Integration, 'oximetry') && ~isempty(plot_data)
            GUI.NonLinearAxes1.Visible = 'on';
            GUI.NonLinearAxes2.Visible = 'on';
            GUI.NonLinearAxes3.Visible = 'on';
            mhrv.plots.plot_dfa_fn(GUI.NonLinearAxes1, plot_data.dfa);
            mhrv.plots.plot_mse(GUI.NonLinearAxes3, plot_data.mse);
            mhrv.plots.plot_poincare_ellipse(GUI.NonLinearAxes2, plot_data.poincare);
            
            GUI.NonLinearAxes1.XLabel.String = strrep(GUI.NonLinearAxes1.XLabel.String, '_2', sprintf('\x2082')); 
            
        else
            if ~all(isnan(plot_data))
                GUI.NonLinearAxes1.Visible = 'on';
                plot_oximetry_CT(GUI.NonLinearAxes1, plot_data);
            else
                GUI.NonLinearAxes1.Visible = 'off';
            end
        end
        try
            box(GUI.NonLinearAxes1, 'off');
            box(GUI.NonLinearAxes2, 'off');
            box(GUI.NonLinearAxes3, 'off');
            GUI.NonLinearAxes1.FontName = DATA.font_name;
            GUI.NonLinearAxes2.FontName = DATA.font_name;
            GUI.NonLinearAxes3.FontName = DATA.font_name;
            setAllowAxesZoom(DATA.zoom_handle, [GUI.NonLinearAxes1, GUI.NonLinearAxes2, GUI.NonLinearAxes3], false);
        catch
        end
    end

%%
    function set_default_analysis_params()
        DATA.DEFAULT_AnalysisParams.segment_startTime = 0;
        DATA.DEFAULT_AnalysisParams.activeWin_startTime = 0;
        %         DATA.DEFAULT_AnalysisParams.segment_endTime = DATA.Filt_MyDefaultWindowSize; % DATA.Filt_MaxSignalLength
        DATA.DEFAULT_AnalysisParams.segment_endTime = min(DATA.Filt_MyDefaultWindowSize, DATA.Filt_MaxSignalLength); % DATA.Filt_MaxSignalLength
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
            
            if ~strcmp(DATA.Integration, 'oximetry')
                DATA.Filt_MyDefaultWindowSize = min(mhrv.defaults.mhrv_get_default('hrv_freq.window_minutes', 'value') * 60, DATA.maxSignalLength); % min to sec
            else
                DATA.Filt_MyDefaultWindowSize = min(5 * 60, DATA.maxSignalLength); % min to sec
            end
            
            DATA.PlotHR = 0;
            DATA.firstSecond2Show = 0;
            % Show only 6*hrv_freq.window_minutes portion of the raw data
            DATA.MyWindowSize = min(3 * DATA.Filt_MyDefaultWindowSize, DATA.maxSignalLength); % 6
            
            DATA.filter_level_index = DATA.default_filter_level_index;
            
            DATA.WinAverage = 0;
            DATA.Detrending = 0;
            
            DATA.freq_yscale = 'linear';
        end
    end
%%
    function reset_plot_Data()
        
        if ~isempty(DATA.rri)
            
            set_default_values();
            
            try
                
                if strcmp(DATA.Integration, 'oximetry')
                    if DATA.SamplingFrequency ~= 1
                        %                     if get(GUI.Detrending_checkbox, 'Value')
                        %                         [DATA.rri, DATA.trr] = ResampleSpO2Data(DATA.rri_saved, DATA.SamplingFrequency, DATA.custom_filters_thresholds.ResampSpO2.Original_fs);
                        [DATA.rri, DATA.trr] = ResampleSpO2Data(DATA.rri, DATA.SamplingFrequency);
                        DATA.SamplingFrequency = 1;
                    end
                    %                     else
                    %                         DATA.rri = DATA.rri_saved;
                    %                         DATA.trr = DATA.trr_saved;
                    %                     end
                end
                
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
                h_e = errordlg(['Reset Plot: ' e.message], 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
                rethrow(e);
            end
        end
    end % reset Data
%%
    function reset_plot_GUI()
        
        if ~isempty(DATA.rri)
            
            GUI.MedianFilter_checkbox.Value = 0;
            GUI.Detrending_checkbox.Value = 0;
            
            GUI.ShowFilteredData.Value = 1;
            GUI.ShowRawData.Value = 1;
            
            set(GUI.AutoScaleYUpperAxes_checkbox, 'Value', 1);
            set(GUI.AutoScaleYLowAxes_checkbox, 'Value', 1);
            
            set(GUI.ShowLegend_checkbox, 'Value', 1);
            set(GUI.AutoCalc_checkbox, 'Value', 1);
            GUI.AutoCompute_pushbutton.Enable = 'off';
            if isfield(GUI, 'WinAverage_checkbox') && ishandle(GUI.WinAverage_checkbox) && isvalid(GUI.WinAverage_checkbox)
                GUI.WinAverage_checkbox.Value = 0;
            end
            
            if isvalid(GUI.DefaultMethod_popupmenu)
                GUI.DefaultMethod_popupmenu.Value = DATA.default_frequency_method_index;
            end
            
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
                if strcmp(DATA.Integration, 'oximetry')
                    set(GUI.oxim_per_log_Button, 'String', 'Log');
                    set(GUI.oxim_per_log_Button, 'Value', 1);
                    set(GUI.freq_yscale_Button, 'Visible', 'off');
                    set(GUI.RR_or_HR_plot_button, 'Enable', 'inactive', 'Value', 0, 'String', 'Plot HR');
                else
                    set(GUI.freq_yscale_Button, 'String', 'Log');
                    set(GUI.freq_yscale_Button, 'Value', 1);
                    set(GUI.freq_yscale_Button, 'Visible', 'on');
                    set(GUI.RR_or_HR_plot_button, 'Enable', 'on', 'Value', 0, 'String', 'Plot HR');
                end
                
                set(GUI.segment_startTime, 'String', calcDuration(DATA.DEFAULT_AnalysisParams.segment_startTime, 0));
                set(GUI.segment_endTime, 'String', calcDuration(DATA.DEFAULT_AnalysisParams.segment_endTime, 0));
                set(GUI.activeWindow_length, 'String', calcDuration(DATA.DEFAULT_AnalysisParams.activeWin_length, 0));
                set(GUI.segment_overlap, 'String', num2str(DATA.DEFAULT_AnalysisParams.segment_overlap));
                set(GUI.segment_winNum, 'String', num2str(DATA.DEFAULT_AnalysisParams.winNum));
                set(GUI.active_winNum, 'String', '1');
                
                if isfield(DATA, 'legend_handle') && ishandle(DATA.legend_handle) && isvalid(DATA.legend_handle)
                    delete(DATA.legend_handle);
                end
                
                RRDataAxes_title = GUI.RRDataAxes.Title.String;
                
                cla(GUI.RRDataAxes, 'reset');
                cla(GUI.AllDataAxes, 'reset');
                
                plotAllData();
                plotRawData();
                setXAxesLim();
                
                title(GUI.RRDataAxes, RRDataAxes_title, 'FontWeight', 'normal', 'FontSize', DATA.SmallFontSize, 'FontName', DATA.font_name); % , 'Interpreter', 'Latex'
                                
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
%                 set(GUI.RecordLength_text, 'String', [calcDuration(DATA.maxSignalLength, 1) '    h:min:sec.msec']);
                set(GUI.RecordLength_text, 'String', calcDuration(DATA.maxSignalLength, 1));
                %                 set(GUI.RR_or_HR_plot_button, 'Enable', 'on', 'Value', 0, 'String', 'Plot HR');
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
                
                %                 if isfield(GUI, 'measures_cb_array') && all(isvalid(GUI.measures_cb_array))
                %                     for i = 1 : length(GUI.measures_cb_array)
                %                         GUI.measures_cb_array(i).Value = 1;
                %                     end
                %                 end
                
            catch e
                h_e = errordlg(['Reset Plot: ' e.message], 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
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
            h_w = warndlg('Input must be numerical');
            setLogo(h_w, 'M2');
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
            
            if RRIntPage_Length <= 2
                display_msec = 1;
            else
                display_msec = 0;
            end
            
            if RRIntPage_Length > DATA.maxSignalLength
                RRIntPage_Length = DATA.maxSignalLength;
            end
            
            if RRIntPage_Length <= 1 || RRIntPage_Length > DATA.maxSignalLength
                set(GUI.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, display_msec));
                if isInputNumeric ~= 2
                    h_e = errordlg('The window size must be greater than 2 sec and less than signal length!', 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                end
                return;
            elseif RRIntPage_Length < red_rect_length
                set(GUI.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, display_msec));
                if isInputNumeric ~= 2
                    h_e = errordlg('The window size must be greater than zoom window length!', 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
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
            
            
            if RRIntPage_Length <= 2
                display_msec = 1;
            else
                display_msec = 0;
            end
            
            set(GUI.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, display_msec));
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
                    h_e = errordlg('The window size must be greater than 2 sec and less than signal length!', 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    return;
                elseif MyWindowSize > DATA.RRIntPage_Length
                    set(GUI.WindowSize,'String', calcDuration(DATA.MyWindowSize, 0));
                    h_e = errordlg('The zoom window length must be smaller than display duration length!', 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
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
                    DetrendIfNeed_data_chunk();
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
                h_e = errordlg(e.message, 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
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
                h_e = errordlg('Please, enter correct values!', 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
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
                h_e = errordlg('Please, enter correct values!', 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
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
            
            RRDataAxes_title = GUI.RRDataAxes.Title.String;
            
            cla(GUI.RRDataAxes, 'reset');
            cla(GUI.AllDataAxes, 'reset');
            delete(DATA.legend_handle);
            plotAllData();
            plotRawData();
            
            title(GUI.RRDataAxes, RRDataAxes_title, 'FontWeight', 'normal', 'FontSize', DATA.SmallFontSize, 'FontName', DATA.font_name); %, 'Interpreter', 'Latex'
            
            DetrendIfNeed_data_chunk();
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
        
        DATA_Fig.Ext = 'png';
        DATA_Measure.Ext_save = 'txt'; % mat
        
        if isfield(DATA, 'Integration') && strcmp(DATA.Integration, 'oximetry')
            DATA_Measure.measures = [1 1];
            DATA_Fig.export_figures = [1 1 1 1 1 1 1 1];
        else
            DATA_Measure.measures = [1 1 1 1];
            DATA_Fig.export_figures = [1 1 1 1 1 1 1];
        end
    end
%%
    function Reset_pushbutton_Callback( ~, ~ )
        reset_defaults_path();
        create_defaults_results_path();
        reset_defaults_extensions();
        
        DATA.filter_index = 1;
        if strcmp(DATA.Integration, 'oximetry')
            set_filters(DATA.Filters_SpO2{DATA.filter_index});
        else
            set_filters(DATA.Filters_ECG{DATA.filter_index});
        end
        
        if isempty(DATA.mammal)
            mammal_index = 1;
        else
            mammal_index = find(strcmp(DATA.mammals, DATA.mammal));
        end
        DATA.mammal_index = mammal_index;
        mammal = DATA.mammals{DATA.mammal_index};
        
        DATA.integration_index = find(strcmpi(DATA.GUI_Integration, DATA.Integration));
        integration = DATA.integration_level{DATA.integration_index};
        GUI.Integration_popupmenu.Value = DATA.integration_index;
        
        try
            % Load user-specified default parameters
            config_file_name = DATA.config_file_name;
            %mhrv.defaults.mhrv_load_defaults([DATA.mammals{DATA.mammal_index} '_' integration]);
            mhrv.defaults.mhrv_load_defaults(config_file_name);
            
            conf_name = [config_file_name '.yml'];
            set(GUI.Config_text, 'String', conf_name);
            
            if Module3
                set(GUI.GroupsConfig_text, 'String', conf_name); % for Group analysis
            end
            
            createConfigParametersInterface();
            
        catch e
            h_e = errordlg(['Reset_pushbutton_Callback: ' e.message], 'Input Error');
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(h_e, 'M_OBM');
            else
                setLogo(h_e, 'M2');
            end
            if isvalid(waitbar_handle)
                close(waitbar_handle);
            end
            return;
        end
        
        if strcmp(config_file_name, 'default_ecg')
            mammal = 'default';
        end
        %         GUI.Mammal_popupmenu.Value = mammal_index;
        GUI.Mammal_popupmenu.String = mammal;
        GUI.Filtering_popupmenu.Value = DATA.filter_index;
        
        if isfield(GUI, 'measures_cb_array') && all(isvalid(GUI.measures_cb_array))
            for i = 1 : length(GUI.measures_cb_array)
                GUI.measures_cb_array(i).Value = 1;
            end
            GUI.measures_cb_array(end).Value = 0;
            GUI.Complexity_CB.Value = 0;
        end
        
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
            
            if strcmp(DATA.Integration, 'oximetry')
                
                if DATA.filter_spo2_range
                    wb = waitbar(0, 'SpO2: Set Range', 'Name', 'SpO2 - Set Range');                    
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(wb, 'M_OBM');
                    else
                        setLogo(wb, 'M2');
                    end
                    nni = SetRange(DATA.rri, wb);
                    %                     tnn = 1/DATA.SpO2NewSamplingFrequency : 1/DATA.SpO2NewSamplingFrequency : length(nni)/DATA.SpO2NewSamplingFrequency;
                    tnn = 0 : DATA.SamplingFrequency : (length(nni)-1)*DATA.SamplingFrequency;
                    if isvalid(wb); close(wb); end
                    %                 elseif DATA.filter_spo2_median
                    %                     wb = waitbar(0, 'SpO2: Median', 'Name', 'SpO2 - Median'); setLogo(wb, 'M2');
                    %                     nni = MedianSpO2(DATA.rri, wb);
                    % %                     tnn = 1/DATA.SpO2NewSamplingFrequency : 1/DATA.SpO2NewSamplingFrequency : length(nni)/DATA.SpO2NewSamplingFrequency;
                    %                     tnn = 0 : DATA.SamplingFrequency : (length(nni)-1)*DATA.SamplingFrequency;
                    %                     if isvalid(wb); close(wb); end
                elseif DATA.filter_spo2_block
                    wb = waitbar(0, 'SpO2: Block Data', 'Name', 'SpO2 - Block Data');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(wb, 'M_OBM');
                    else
                        setLogo(wb, 'M2');
                    end
                    nni = BlockDataSpO2(DATA.rri, wb);
                    %                     tnn = 1/DATA.SpO2NewSamplingFrequency : 1/DATA.SpO2NewSamplingFrequency : length(nni)/DATA.SpO2NewSamplingFrequency;
                    tnn = 0 : DATA.SamplingFrequency : (length(nni)-1)*DATA.SamplingFrequency;
                    if isvalid(wb); close(wb); end
                elseif DATA.filter_spo2_dfilter
                    wb = waitbar(0, 'SpO2: DFilter', 'Name', 'SpO2 - DFilter');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(wb, 'M_OBM');
                    else
                        setLogo(wb, 'M2');
                    end
                    nni = DFilterSpO2(DATA.rri, wb);
                    %                     tnn = 1/DATA.SpO2NewSamplingFrequency : 1/DATA.SpO2NewSamplingFrequency : length(nni)/DATA.SpO2NewSamplingFrequency;
                    tnn = 0 : DATA.SamplingFrequency : (length(nni)-1)*DATA.SamplingFrequency;
                    if isvalid(wb); close(wb); end
                else
                    nni = DATA.rri;
                    tnn = DATA.trr;
                end
                if GUI.MedianFilter_checkbox.Value % Median - ON
                    wb = waitbar(0, 'SpO2: Median', 'Name', 'SpO2 - Median');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(wb, 'M_OBM');
                    else
                        setLogo(wb, 'M2');
                    end
                    nni = MedianSpO2(nni, wb);
                    tnn = 0 : DATA.SamplingFrequency : (length(nni)-1)*DATA.SamplingFrequency;
                    if isvalid(wb); close(wb); end
                end
            else
                [nni, tnn, ~] = mhrv.rri.filtrr(DATA.rri, DATA.trr, 'filter_quotient', filter_quotient, 'filter_ma', filter_ma, 'filter_range', filter_range);
            end
            
            if isempty(nni)
                throw(MException('FiltCalcPlotSignalStat:FiltrrNoNNIntervalOutputted', 'No NN interval outputted'));
            elseif ~strcmp(DATA.Integration, 'oximetry') && length(DATA.rri) * 0.1 > length(nni)
                throw(MException('FiltCalcPlotSignalStat:NotEnoughNNIntervals', 'Not enough NN intervals'));
            else
                DATA.nni = nni;
                DATA.tnn = tnn;
                
                DATA.nni_saved = nni;
                DATA.nni4calc = nni;
            end
        else
            throw(MException('FiltCalcPlotSignalStat:NoData', 'No data'));
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
                mhrv.defaults.mhrv_load_defaults([pathstr filesep name]);
                DIRS.configDirectory = PathName;
            else % Cancel by user
                GUI.Mammal_popupmenu.Value = DATA.mammal_index;
                return;
            end
        else
            % Load user-specified default parameters
            mhrv.defaults.mhrv_load_defaults(DATA.mammals{index_selected});
        end
        createConfigParametersInterface();
        reset_plot_Data();
        reset_plot_GUI();
        DATA.mammal_index = index_selected;
    end
%%
    function Mammal_popupmenu_Callback( src, ~ )
        %         index_selected = get(GUI.Mammal_popupmenu, 'Value');
        %         choose_new_mammal(index_selected);
        mhrv.defaults.mhrv_set_default('parameters_type.mammal', get(src, 'String'));
    end
%%
    function Integration_popupmenu_Callback( ~, ~ )
        items = get(GUI.Integration_popupmenu, 'String');
        index_selected = get(GUI.Integration_popupmenu, 'Value');
        
        %         set_defaults_path();
        %         if index_selected == 1 % ECG
        %             [Config_FileName, PathName] = uigetfile({'*.yml','Yaml-files (*.yml)'}, 'Open Configuration File', [DIRS.configDirectory filesep]);
        %             if ~isequal(Config_FileName, 0)
        %                 params_filename = fullfile(PathName, Config_FileName);
        %                 [pathstr, name, ~] = fileparts(params_filename);
        %                 mhrv.defaults.mhrv_load_defaults([pathstr filesep name]);
        %                 DIRS.configDirectory = PathName;
        %                 createConfigParametersInterface();
        %                 reset_plot_Data();
        %                 reset_plot_GUI();
        %
        %                 preset_mammals = DATA.mammals(1:end-1);
        %                 mammal_ind = find(cellfun(@(x) strcmp(x, name), preset_mammals));
        %                 if ~isempty(mammal_ind)
        %                     set(GUI.Mammal_popupmenu, 'Value', mammal_ind);
        %                     DATA.mammal_index = mammal_ind;
        %                 else
        %                     set(GUI.Mammal_popupmenu, 'Value', length(DATA.mammals)); % Custom
        %                     DATA.mammal_index = length(DATA.mammals);
        %                 end
        %
        %             else
        %                 GUI.Mammal_popupmenu.Value = DATA.mammal_index;
        %                 GUI.Integration_popupmenu.Value = DATA.integration_index;
        %                 return;
        %             end
        %         else % NO ECG
        %             set(GUI.Mammal_popupmenu, 'Value', length(DATA.mammals)); % Custom
        %
        %             [Config_FileName, PathName] = uigetfile({'*.yml','Yaml-files (*.yml)'}, 'Open Configuration File', [DIRS.configDirectory filesep]);
        %             if ~isequal(Config_FileName, 0)
        %                 params_filename = fullfile(PathName, Config_FileName);
        %                 [pathstr, name, ~] = fileparts(params_filename);
        %                 mhrv.defaults.mhrv_load_defaults([pathstr filesep name]);
        %                 DIRS.configDirectory = PathName;
        %                 DATA.mammal_index = length(DATA.mammals);
        %                 createConfigParametersInterface();
        %                 reset_plot_Data();
        %                 reset_plot_GUI();
        %             else % Cancel by user
        %                 GUI.Mammal_popupmenu.Value = DATA.mammal_index;
        %                 GUI.Integration_popupmenu.Value = DATA.integration_index;
        %                 return;
        %             end
        %         end
        
        %         DATA.Integration = items{index_selected};
        
        DATA.integration_index = index_selected;
        mhrv.defaults.mhrv_set_default('parameters_type.integration_level', items{index_selected});
    end
%%
    function set_default_filters_threshoulds(param_field, param_value)
        if isfield(GUI, 'ConfigParamHandlesMap')
            set(GUI.ConfigParamHandlesMap(param_field), 'String', num2str(param_value));
            mhrv.defaults.mhrv_set_default(param_field, param_value);
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
                try
                    set_default_filters_threshoulds('filtrr.range.rr_max',  filters_thresholds.range.rr_max);
                    set_default_filters_threshoulds('filtrr.range.rr_min',  filters_thresholds.range.rr_min);
                catch
                end
                try
                    set_default_filters_threshoulds('filtSpO2.RangeSpO2.Range_min',  filters_thresholds.RangeSpO2.Range_min);
                    set_default_filters_threshoulds('filtSpO2.RangeSpO2.Range_max',  filters_thresholds.RangeSpO2.Range_max);
                catch
                end
            elseif strcmp(Filter, 'Quotient')
                set_default_filters_threshoulds('filtrr.quotient.rr_max_change',  filters_thresholds.quotient.rr_max_change);
            elseif strcmp(Filter, 'Combined filters')
                set_default_filters_threshoulds('filtrr.moving_average.win_threshold',  filters_thresholds.moving_average.win_threshold);
                set_default_filters_threshoulds('filtrr.moving_average.win_length',  filters_thresholds.moving_average.win_length);
                set_default_filters_threshoulds('filtrr.range.rr_max',  filters_thresholds.range.rr_max);
                set_default_filters_threshoulds('filtrr.range.rr_min',  filters_thresholds.range.rr_min);
                %             elseif strcmp(Filter, 'Median')
                %                 set_default_filters_threshoulds('filtSpO2.MedianSpO2.FilterLength',  filters_thresholds.MedianSpO2.FilterLength);
            elseif strcmp(Filter, 'Block Data')
                set_default_filters_threshoulds('filtSpO2.BlockSpO2.Treshold',  filters_thresholds.BlockSpO2.Treshold);
            elseif strcmp(Filter, 'DFilter')
                set_default_filters_threshoulds('filtSpO2.DFilterSpO2.Diff',  filters_thresholds.DFilterSpO2.Diff);
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
            h_e = errordlg(['FilteringLevel_popupmenu_Callback Error: ' e.message], 'Input Error');
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(h_e, 'M_OBM');
            else
                setLogo(h_e, 'M2');
            end
            return;
        end
    end
%%
    function calc_filt_signal()
        if isfield(DATA, 'rri') && ~isempty(DATA.rri)
            FiltSignal();
            DetrendIfNeed_data_chunk();
            clear_statistics_plots();
            clearStatTables();
            if isfield(GUI, 'filtered_handle')
                if ~strcmp(DATA.Integration, 'oximetry')
                    set(GUI.filtered_handle, 'XData', ones(1, length(DATA.tnn))*NaN, 'YData', ones(1, length(DATA.nni))*NaN);
                else
                    set(GUI.filtered_handle, 'XData', ones(1, length(DATA.tnn))*NaN, 'YData', ones(1, length(DATA.nni))*NaN, 'CData', create_color_array4oximetry());
                end
            end
            if isfield(GUI, 'only_filtered_handle') && isvalid(GUI.only_filtered_handle)
                set(GUI.only_filtered_handle, 'XData', ones(1, length(DATA.tnn))*NaN, 'YData', ones(1, length(DATA.nni))*NaN);
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
        
        if isfield(DATA, 'default_filters_thresholds')
            
            if strcmp(Filter, 'Range')
                GUI.FilteringLevel_popupmenu.String = DATA.FilterShortLevel;
                GUI.FilteringLevel_popupmenu.Enable = 'on';
                try
                    set_default_filters_threshoulds('filtrr.range.rr_max', DATA.default_filters_thresholds.range.rr_max);
                    set_default_filters_threshoulds('filtrr.range.rr_min', DATA.default_filters_thresholds.range.rr_min);
                catch
                end
                try
                    set_default_filters_threshoulds('filtSpO2.RangeSpO2.Range_min', DATA.default_filters_thresholds.RangeSpO2.Range_min);
                    set_default_filters_threshoulds('filtSpO2.RangeSpO2.Range_max', DATA.default_filters_thresholds.RangeSpO2.Range_max);
                catch e
                    disp(['NO SpO2', e.message]);
                end
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
                %             elseif strcmp(Filter, 'Median')
                %                 GUI.FilteringLevel_popupmenu.String = DATA.FilterShortLevel;
                %                 GUI.FilteringLevel_popupmenu.Enable = 'on';
                %                 set_default_filters_threshoulds('filtSpO2.MedianSpO2.FilterLength', DATA.default_filters_thresholds.MedianSpO2.FilterLength);
            elseif strcmp(Filter, 'Block Data')
                GUI.FilteringLevel_popupmenu.String = DATA.FilterShortLevel;
                GUI.FilteringLevel_popupmenu.Enable = 'on';
                set_default_filters_threshoulds('filtSpO2.BlockSpO2.Treshold', DATA.default_filters_thresholds.BlockSpO2.Treshold);
            elseif strcmp(Filter, 'DFilter')
                GUI.FilteringLevel_popupmenu.String = DATA.FilterShortLevel;
                GUI.FilteringLevel_popupmenu.Enable = 'on';
                set_default_filters_threshoulds('filtSpO2.DFilterSpO2.Diff', DATA.default_filters_thresholds.DFilterSpO2.Diff);
            end
            try
                set_filters(Filter);
            catch e
                h_e = errordlg(['Filtering_popupmenu_Callback Error: ' e.message], 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
                GUI.Filtering_popupmenu.Value = DATA.filter_index;
                set_filters(items{DATA.filter_index});
                return;
            end
            try
                calc_filt_signal();
                DATA.filter_index = index_selected;
                if strcmp(Filter, 'No filtering')
                    DATA.legend_handle.String{2} = 'Selected time series';
                else
                    DATA.legend_handle.String{2} = 'Selected filtered time series';
                end
            catch e
                h_e = errordlg(['Filtering_popupmenu_Callback Error: ' e.message], 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
                GUI.Filtering_popupmenu.Value = DATA.filter_index;
                set_filters(items{DATA.filter_index});
                return;
            end
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
        if ~strcmp(DATA.Integration, 'oximetry')
            if strcmp(Filter, DATA.Filters_ECG{5}) % No filtering
                DATA.filter_quotient = false;
                DATA.filter_ma = false;
                DATA.filter_range = false;
            elseif strcmp(Filter, DATA.Filters_ECG{1}) % Moving average
                DATA.filter_quotient = false;
                DATA.filter_ma = true;
                DATA.filter_range = false;
            elseif strcmp(Filter, DATA.Filters_ECG{2}) % Range
                DATA.filter_quotient = false;
                DATA.filter_ma = false;
                DATA.filter_range = true;
            elseif strcmp(Filter, DATA.Filters_ECG{3}) % Quotient
                DATA.filter_quotient = true;
                DATA.filter_ma = false;
                DATA.filter_range = false;
            elseif strcmp(Filter, DATA.Filters_ECG{4}) % Combined Filters
                DATA.filter_quotient = false;
                DATA.filter_ma = true;
                DATA.filter_range = true;
            else
                error('Unknown filter!');
            end
            mhrv.defaults.mhrv_set_default('filtrr.range.enable', DATA.filter_range);
            mhrv.defaults.mhrv_set_default('filtrr.quotient.enable', DATA.filter_quotient);
            mhrv.defaults.mhrv_set_default('filtrr.ma.enable', DATA.filter_ma);
        else
            if strcmp(Filter, DATA.Filters_SpO2{4}) % No filtering
                DATA.filter_spo2_range = false;
                %                 DATA.filter_spo2_median = false;
                DATA.filter_spo2_block = false;
                DATA.filter_spo2_dfilter = false;
            elseif strcmp(Filter, DATA.Filters_SpO2{1})
                DATA.filter_spo2_range = true;
                %                 DATA.filter_spo2_median = false;
                DATA.filter_spo2_block = false;
                DATA.filter_spo2_dfilter = false;
                %             elseif strcmp(Filter, DATA.Filters_SpO2{2})
                %                 DATA.filter_spo2_range = false;
                %                 DATA.filter_spo2_median = true;
                %                 DATA.filter_spo2_block = false;
                %                 DATA.filter_spo2_dfilter = false;
            elseif strcmp(Filter, DATA.Filters_SpO2{2})
                DATA.filter_spo2_range = false;
                %                 DATA.filter_spo2_median = false;
                DATA.filter_spo2_block = true;
                DATA.filter_spo2_dfilter = false;
            elseif strcmp(Filter, DATA.Filters_SpO2{3})
                DATA.filter_spo2_range = false;
                %                 DATA.filter_spo2_median = false;
                DATA.filter_spo2_block = false;
                DATA.filter_spo2_dfilter = true;
            end
            mhrv.defaults.mhrv_set_default('filtSpO2.RangeSpO2.enable', DATA.filter_spo2_range);
            mhrv.defaults.mhrv_set_default('filtSpO2.MedianSpO2.enable', DATA.filter_spo2_median);
            mhrv.defaults.mhrv_set_default('filtSpO2.BlockSpO2.enable', DATA.filter_spo2_block);
            mhrv.defaults.mhrv_set_default('filtSpO2.DFilterSpO2.enable', DATA.filter_spo2_dfilter);
        end
    end
%%
    function FirstSecond_Callback ( ~, ~ )
        if ~isempty(DATA.rri)
            screen_value = get(GUI.FirstSecond, 'String');
            [firstSecond2Show, isInputNumeric] = calcDurationInSeconds(GUI.FirstSecond, screen_value, DATA.firstSecond2Show);
            if isInputNumeric
                if firstSecond2Show < 0 || firstSecond2Show > DATA.maxSignalLength - DATA.MyWindowSize  % + 1
                    set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0));
                    h_e = errordlg('The first second value must be grater than 0 and less than signal length!', 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
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
                    h_e = errordlg('The filt first second value must be grater than 0 and less than signal length!', 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
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
                    DetrendIfNeed_data_chunk();
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
        
        if ~strcmp(DATA.Integration, 'oximetry')
            GUIFiguresNames = {'NN Interval Distribution'; 'Power Spectral Density'; 'Beta'; 'DFA'; 'MSE'; 'Poincare Ellipse'; 'RR Time Series'};
            DATA.FiguresNames = {'_NND'; '_PSD'; '_Beta'; '_DFA'; '_MSE'; '_Poincare'; '_RR'};
        else
            GUIFiguresNames = {'Statistics SpO2'; 'Desaturations Lengths'; 'Desaturations Depths'; 'CT'; 'DFA'; 'PSD'; 'PRSA'; 'SpO2 Signal'};
            DATA.FiguresNames = {'_StatSpO2'; '_DesatLengths'; '_DesatDepths'; '_CT'; '_DFA'; '_PSD'; '_PRSA'; '_SpO2Signal'};
        end
        
        main_screensize = DATA.screensize;
        
        GUI.SaveFiguresWindow = figure( ...
            'Name', 'Save Figures Options', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', ...
            'Position', [(main_screensize(3)-400)/2, (main_screensize(4)-300)/2, 400, 300]); %[700, 300, 800, 400]
        
        if strcmp(DATA.Integration, 'oximetry')
            setLogo(GUI.SaveFiguresWindow, 'M_OBM');
        else
            setLogo(GUI.SaveFiguresWindow, 'M2');
        end
        
        mainSaveFigurestLayout = uix.VBox('Parent',GUI.SaveFiguresWindow, 'Spacing', DATA.Spacing);
        figures_panel = uix.Panel( 'Parent', mainSaveFigurestLayout, 'Padding', DATA.Padding+2, 'Title', 'Select figures to save:', 'FontSize', DATA.BigFontSize+2, 'FontName', 'Calibri', 'BorderType', 'beveledin' );
        figures_box = uix.VButtonBox('Parent', figures_panel, 'Spacing', DATA.Spacing-1, 'HorizontalAlignment', 'left', 'ButtonSize', [200 25]);
        
        for i = 1 : length(DATA.FiguresNames)
            uicontrol( 'Style', 'checkbox', 'Parent', figures_box, 'Callback', {@figures_checkbox_Callback, i}, 'FontSize', DATA.BigFontSize, ...
                'Tag', ['Fig' num2str(i)], 'String', GUIFiguresNames{i}, 'FontName', 'Calibri', 'Value', DATA_Fig.export_figures(i));
        end
        
        CommandsButtons_Box = uix.HButtonBox('Parent', mainSaveFigurestLayout, 'Spacing', DATA.Spacing, 'VerticalAlignment', 'middle', 'ButtonSize', [100 30]);
        uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', @dir_button_Callback, 'FontSize', DATA.BigFontSize, 'String', 'Save As', 'FontName', 'Calibri');
        uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', {@cancel_button_Callback, GUI.SaveFiguresWindow}, 'FontSize', DATA.BigFontSize, 'String', 'Cancel', 'FontName', 'Calibri');
        
        set( mainSaveFigurestLayout, 'Heights',  [-80 -20]); % [-70 -45 -25]
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
            
            if ~strcmp(DATA.Integration, 'oximetry')
                
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
                            setLogo(af, 'M2');
                            set(af, 'Visible', 'off')
                            mhrv.plots.plot_hrv_time_hist(gca, DATA.TimeStat.PlotData{DATA.active_window}, 'clear', true);
                            mhrv.util.fig_print( af, [export_path_name, DATA.FiguresNames{1}], 'output_format', ext, 'title', figure_title(fig_name, 1), 'font_weight', 'normal');
                            close(af);
                        end
                        
                        if ~isempty(DATA.FrStat.PlotData{DATA.active_window})
                            if DATA_Fig.export_figures(2) && yes_no(2)
                                af = figure;
                                setLogo(af, 'M2');
                                set(af, 'Visible', 'off')
                                mhrv.plots.plot_hrv_freq_spectrum(gca, DATA.FrStat.PlotData{DATA.active_window}, 'detailed_legend', false, 'yscale', DATA.freq_yscale);
                                mhrv.util.fig_print( af, [export_path_name, DATA.FiguresNames{2}], 'output_format', ext, 'title', figure_title(fig_name, 2), 'font_weight', 'normal');
                                close(af);
                            end
                            if DATA_Fig.export_figures(3) && yes_no(3)
                                af = figure;
                                setLogo(af, 'M2');
                                set(af, 'Visible', 'off')
                                mhrv.plots.plot_hrv_freq_beta(gca, DATA.FrStat.PlotData{DATA.active_window});
                                xlabel(gca, 'log(Frequency (Hz))');
                                mhrv.util.fig_print( af, [export_path_name, DATA.FiguresNames{3}], 'output_format', ext, 'title', figure_title(fig_name, 3), 'font_weight', 'normal');
                                close(af);
                            end
                        end
                        
                        if ~isempty(DATA.NonLinStat.PlotData{DATA.active_window})
                            if DATA_Fig.export_figures(4) && yes_no(4)
                                af = figure;
                                setLogo(af, 'M2');
                                set(af, 'Visible', 'off')
                                mhrv.plots.plot_dfa_fn(gca, DATA.NonLinStat.PlotData{DATA.active_window}.dfa);
                                mhrv.util.fig_print( af, [export_path_name, DATA.FiguresNames{4}], 'output_format', ext, 'title', figure_title(fig_name, 4), 'font_weight', 'normal');
                                close(af);
                            end
                            if DATA_Fig.export_figures(5) && yes_no(5)
                                af = figure;
                                setLogo(af, 'M2');
                                set(af, 'Visible', 'off')
                                mhrv.plots.plot_mse(gca, DATA.NonLinStat.PlotData{DATA.active_window}.mse);
                                mhrv.util.fig_print( af, [export_path_name, DATA.FiguresNames{5}], 'output_format', ext, 'title', figure_title(fig_name, 5), 'font_weight', 'normal');
                                close(af);
                            end
                            if DATA_Fig.export_figures(6) && yes_no(6)
                                af = figure;
                                setLogo(af, 'M2');
                                set(af, 'Visible', 'off')
                                mhrv.plots.plot_poincare_ellipse(gca, DATA.NonLinStat.PlotData{DATA.active_window}.poincare);
                                mhrv.util.fig_print( af, [export_path_name, DATA.FiguresNames{6}], 'output_format', ext, 'title', figure_title(fig_name, 6), 'font_weight', 'normal');
                                close(af);
                            end
                        end
                        if DATA_Fig.export_figures(7) && yes_no(7)
                            af = figure;
                            setLogo(af, 'M2');
                            set(af, 'Visible', 'off')
                            plot_rr_time_series(gca);
                            mhrv.util.fig_print( af, [export_path_name, DATA.FiguresNames{7}], 'output_format', ext, 'title', figure_title(fig_name, 7), 'font_weight', 'normal');
                            close(af);
                        end
                    elseif strcmpi(ext, 'fig')
                        if ~isempty(DATA.TimeStat.PlotData{DATA.active_window}) && DATA_Fig.export_figures(1) && yes_no(1)
                            af = figure;
                            setLogo(af, 'M2');
                            set(af, 'Name', [fig_name, DATA.FiguresNames{1}], 'NumberTitle', 'off');
                            mhrv.plots.plot_hrv_time_hist(gca, DATA.TimeStat.PlotData{DATA.active_window}, 'clear', true);
                            title(gca, figure_title(fig_name, 1), 'FontName', DATA.font_name, 'FontWeight', 'normal'); % , 'Interpreter', 'Latex'
                            set(gca, 'FontName', DATA.font_name);
%                             set(gca, 'TickLabelInterpreter', 'Latex');
%                             xl = get(gca, 'XLabel');
%                             xl.Interpreter = 'Latex';
%                             yl = get(gca, 'YLabel');
%                             yl.Interpreter = 'Latex';
                            lh = get(gca, 'Legend');
                            lh.FontName = DATA.font_name;
%                             lh.Interpreter = 'Latex';
                            savefig(af, [export_path_name, DATA.FiguresNames{1}], 'compact');
                            close(af);
                        end
                        if ~isempty(DATA.FrStat.PlotData{DATA.active_window})
                            if DATA_Fig.export_figures(2) && yes_no(2)
                                af = figure;
                                setLogo(af, 'M2');
                                set(af, 'Name', [fig_name, DATA.FiguresNames{2}], 'NumberTitle', 'off');
                                mhrv.plots.plot_hrv_freq_spectrum(gca, DATA.FrStat.PlotData{DATA.active_window}, 'detailed_legend', false, 'yscale', DATA.freq_yscale);
                                title(gca, figure_title(fig_name, 2), 'FontName', DATA.font_name, 'FontWeight', 'normal');
                                set(gca, 'FontName', DATA.font_name);
%                                 set(gca, 'TickLabelInterpreter', 'Latex');
%                                 xl = get(gca, 'XLabel');
%                                 xl.Interpreter = 'Latex';
%                                 yl = get(gca, 'YLabel');
                                %                                 yl.String = ['$' yl.String '$'];
%                                 yl.String = 'PSD ( $\frac {ms^2} {Hz}$)';
%                                 yl.String = 'PSD (ms^2/Hz)';
%                                 yl.Interpreter = 'Latex';
                                lh = get(gca, 'Legend');
%                                 lh.Interpreter = 'Latex';
                                lh.FontName = DATA.font_name;
                                fC = get(gca, 'Children');
                                set(findobj(fC, 'Type', 'Text'), 'FontName', DATA.font_name);
                                
                                savefig(af, [export_path_name, DATA.FiguresNames{2}], 'compact');
                                close(af);
                            end
                            if DATA_Fig.export_figures(3) && yes_no(3)
                                af = figure;
                                setLogo(af, 'M2');
                                set(af, 'Name', [fig_name, DATA.FiguresNames{3}], 'NumberTitle', 'off');
                                mhrv.plots.plot_hrv_freq_beta(gca, DATA.FrStat.PlotData{DATA.active_window});
                                title(gca, figure_title(fig_name, 3), 'FontName', DATA.font_name, 'FontWeight', 'normal');
                                set(gca, 'FontName', DATA.font_name);
%                                 set(gca, 'TickLabelInterpreter', 'latex');
                                xlabel(gca, 'log(Frequency (Hz))');
%                                 xl = get(gca, 'XLabel');
%                                 xl.Interpreter = 'latex';
%                                 yl = get(gca, 'YLabel');
%                                 yl.String = 'log(PSD [ $\frac {ms^2} {Hz}$])';
%                                 yl.String = 'log(PSD [ms^2/Hz])';
%                                 yl.Interpreter = 'latex';
                                lh = get(gca, 'Legend');
                                lh.FontName = DATA.font_name;
                                savefig(af, [export_path_name, DATA.FiguresNames{3}], 'compact');
                                close(af);
                            end
                        end
                        if ~isempty(DATA.NonLinStat.PlotData{DATA.active_window})
                            if DATA_Fig.export_figures(4) && yes_no(4)
                                af = figure;
                                setLogo(af, 'M2');
                                set(af, 'Name', [fig_name, DATA.FiguresNames{4}], 'NumberTitle', 'off');
                                mhrv.plots.plot_dfa_fn(gca, DATA.NonLinStat.PlotData{DATA.active_window}.dfa);
                                title(gca, figure_title(fig_name, 4), 'FontName', DATA.font_name, 'FontWeight', 'normal');
                                set(gca, 'FontName', DATA.font_name);
%                                 set(gca, 'TickLabelInterpreter', 'latex');
%                                 xl = get(gca, 'XLabel');
%                                 xl.String = ['$' xl.String '$'];
%                                 xl.Interpreter = 'latex';
%                                 yl = get(gca, 'YLabel');
%                                 yl.Interpreter = 'latex';
                                lh = get(gca, 'Legend');
                                lh.FontName = DATA.font_name;
                                savefig(af, [export_path_name, DATA.FiguresNames{4}], 'compact');
                                close(af);
                            end
                            if DATA_Fig.export_figures(5) && yes_no(5)
                                af = figure;
                                setLogo(af, 'M2');
                                set(af, 'Name', [fig_name, DATA.FiguresNames{5}], 'NumberTitle', 'off');
                                mhrv.plots.plot_mse(gca, DATA.NonLinStat.PlotData{DATA.active_window}.mse);
                                title(gca, figure_title(fig_name, 5), 'FontName', DATA.font_name, 'FontWeight', 'normal');
                                set(gca, 'FontName', DATA.font_name);
%                                 set(gca, 'TickLabelInterpreter', 'latex');
%                                 xl = get(gca, 'XLabel');
%                                 xl.Interpreter = 'latex';
%                                 yl = get(gca, 'YLabel');
%                                 yl.Interpreter = 'latex';
                                lh = get(gca, 'Legend');
                                lh.FontName = DATA.font_name;
                                savefig(af, [export_path_name, DATA.FiguresNames{5}], 'compact');
                                close(af);
                            end
                            if DATA_Fig.export_figures(6) && yes_no(6)
                                af = figure;
                                setLogo(af, 'M2');
                                set(af, 'Name', [fig_name, DATA.FiguresNames{6}], 'NumberTitle', 'off');
                                mhrv.plots.plot_poincare_ellipse(gca, DATA.NonLinStat.PlotData{DATA.active_window}.poincare);
                                title(gca, figure_title(fig_name, 6), 'FontName', DATA.font_name, 'FontWeight', 'normal');
                                set(gca, 'FontName', DATA.font_name);
%                                 set(gca, 'TickLabelInterpreter', 'latex');
%                                 xl = get(gca, 'XLabel');
%                                 xl.Interpreter = 'latex';
%                                 yl = get(gca, 'YLabel');
%                                 yl.Interpreter = 'latex';
                                lh = get(gca, 'Legend');
                                lh.FontName = DATA.font_name;
                                savefig(af, [export_path_name, DATA.FiguresNames{6}], 'compact');
                                close(af);
                            end
                        end
                        if DATA_Fig.export_figures(7) && yes_no(7)
                            af = figure;
                            setLogo(af, 'M2');
                            set(af, 'Name', [fig_name, DATA.FiguresNames{7}], 'NumberTitle', 'off');
                            plot_rr_time_series(gca);
                            title(gca, figure_title(fig_name, 7), 'FontName', DATA.font_name, 'FontWeight', 'normal');
                            set(gca, 'FontName', DATA.font_name);
%                             set(gca, 'TickLabelInterpreter', 'latex');
%                             xl = get(gca, 'XLabel');
%                             xl.Interpreter = 'latex';
%                             yl = get(gca, 'YLabel');
%                             yl.Interpreter = 'latex';
                            lh = get(gca, 'Legend');
                            lh.FontName = DATA.font_name;
                            savefig(af, [export_path_name, DATA.FiguresNames{7}], 'compact');
                            close(af);
                        end
                    end
                else
                    h_e = errordlg('Please, press Compute before saving!', 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                end
            else
                save_spo2_figures_to_file(GUI, DATA, export_path_name, ext, fig_name, DATA_Fig);
            end
            delete( GUI.SaveFiguresWindow );
        else
            h_e = errordlg('Please enter valid path to save figures', 'Input Error');
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(h_e, 'M_OBM');
            else
                setLogo(h_e, 'M2');
            end
        end
    end
%%
    function figure_title = figure_title(fig_name, title_number)
        figure_title = [strrep(fig_name,  '_', '\_'), strrep(DATA.FiguresNames{title_number}, '_', '\_')] ;
    end
%%
    function plot_rr_time_series(ax)
        
        ax.FontName = DATA.font_name;
        
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
        xlabel(ax, 'Time (h:min:sec)'); % , 'Interpreter', 'Latex'
        ylabel(ax, yString); % , 'Interpreter', 'Latex'
%         set(ax, 'TickLabelInterpreter', 'Latex');
        
        set(ax, 'XLim', [XData_active_window(1), XData_active_window(3)]);
        setAxesXTicks(ax);
        
        legend_handle = legend(ax, 'show', 'Location', 'southeast', 'Orientation', 'horizontal'); %, 'Interpreter', 'Latex'
        
        legend_handle.String{1} = 'Time series';
        
        Filter = GUI.Filtering_popupmenu.String{GUI.Filtering_popupmenu.Value};
        if strcmp(Filter, 'No filtering')
            legend_handle.String{2} = 'Selected time series';
        else
            legend_handle.String{2} = 'Selected filtered time series';
        end
        
        legend_handle.FontName = DATA.font_name;
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
                                'precision', '%.5f\t', 'delimiter', '\t', 'newline', 'pc', 'roffset', 2, '-append');
%                             'precision', '%.5f\t\n', 'delimiter', '\t', 'newline', 'pc', 'roffset', 2, '-append');
                            fclose(psd_fileID);
                        end
                    elseif strcmp(ext, '.mat')
                        PSD = DATA.FrStat.PlotData;
                        save([[full_file_name_psd '_psd'] ext], 'PSD');
                    end
                end
            end
        else
            h_e = errordlg('Please, press Compute before saving!', 'Input Error');
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(h_e, 'M_OBM');
            else
                setLogo(h_e, 'M2');
            end
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
                                'precision', '%.3f\t', 'delimiter', '\t', 'newline', 'pc', 'roffset', 2, '-append');
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
        
        if strcmp(DATA.Integration, 'oximetry')
            GUIMeasuresNames = {'SpO2 Measures'; 'Preprocessed SpO2'};
            figure_name = 'Save SpO2 Measures Options';
        else
            GUIMeasuresNames = {'HRV Measures'; 'Preprocessed RR intervals'; 'Multi Scale Entropy'; 'Power Spectral Density'};
            figure_name = 'Save HRV Measures Options';
        end
        
        main_screensize = DATA.screensize;
        
        GUI.SaveMeasuresWindow = figure( ...
            'Name', figure_name, ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', ...
            'Position', [(main_screensize(3)-400)/2, (main_screensize(4)-300)/2, 400, 300]); %[700, 300, 800, 400]
        
        if strcmp(DATA.Integration, 'oximetry')
            setLogo(GUI.SaveMeasuresWindow, 'M_OBM');
        else
            setLogo(GUI.SaveMeasuresWindow, 'M2');
        end
        
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
            if length(DATA_Measure.measures) >= 1 && DATA_Measure.measures(1)
                onSaveResultsAsFile(res_name);
            end
            if length(DATA_Measure.measures) >= 2 && DATA_Measure.measures(2)
                onSaveFilteredDataFile(res_name);
            end
            if length(DATA_Measure.measures) >= 3 && DATA_Measure.measures(3)
                onSaveMSEFile(res_name);
            end
            if length(DATA_Measure.measures) >= 4 && DATA_Measure.measures(4)
                onSavePSDAsFile(res_name);
            end
        end
        delete( GUI.SaveMeasuresWindow );
    end
%%
    function onSaveResultsAsFile(filename)
        
        if ~isequal(DIRS.ExportResultsDirectory, 0)
            
            if strcmp(DATA.Integration, 'oximetry')
                integ = '_SpO2';
            else
                integ = '_hrv';
            end
            
            ext = ['.' DATA_Measure.Ext_save];
            full_file_name_hea = fullfile(DIRS.ExportResultsDirectory, [filename '_hea.txt']);
            full_file_name_hrv = fullfile(DIRS.ExportResultsDirectory, [filename integ ext]);
            
            button = 'Yes';
            if exist(full_file_name_hrv, 'file')
                button = questdlg([full_file_name_hrv ' already exist. Do you want to overwrite it?'], 'Overwrite existing file?', 'Yes', 'No', 'No');
            end
            
            if strcmp(button, 'Yes')
                if ~isempty(DATA.TimeStat) && ~isempty(DATA.FrStat) && ~isempty(DATA.NonLinStat)
                    
                    hrv_metrics_table = horzcat(DATA.TimeStat.hrv_time_metrics, DATA.FrStat.hrv_fr_metrics, DATA.NonLinStat.hrv_nonlin_metrics);
                    
                    if strcmp(DATA.Integration, 'oximetry') && ~isempty(DATA.CMStat) && ~isempty(DATA.PMStat)
                        hrv_metrics_table = horzcat(hrv_metrics_table, DATA.CMStat.SpO2_CM_metrics, DATA.PMStat.SpO2_PM_metrics);
                        title = 'SpO2 metrics for ';
                    else
                        title = 'HRV metrics for ';
                        DATA.CMStat.RowsNames = [];
                        DATA.CMStat.Data = [];
                        DATA.PMStat.RowsNames = [];
                        DATA.PMStat.Data = [];
                    end
                    hrv_metrics_table.Properties.Description = sprintf('%s%s', title, DATA.DataFileName);
                    
                    AllRowsNames = [DATA.TimeStat.RowsNames_NO_GreekLetters; DATA.FrStat.RowsNames_NO_GreekLetters; DATA.NonLinStat.RowsNames_NO_GreekLetters; DATA.CMStat.RowsNames; DATA.PMStat.RowsNames];
                    statistics_params = [DATA.TimeStat.Data; DATA.FrStat.Data; DATA.NonLinStat.Data; DATA.CMStat.Data; DATA.PMStat.Data];
                    
                    column_names = {'Description'};
                    for i = 1 : DATA.AnalysisParams.winNum
                        column_names = cat(1, column_names, ['W' num2str(i)]);
                    end
                    
                    if strcmp(ext, '.txt')
                        header_fileID = fopen(full_file_name_hea, 'w');
                        fprintf(header_fileID, '#header\r\n');
                        fprintf(header_fileID, 'Record name: %s\r\n\r\n', DATA.DataFileName);
                        %                         fprintf(header_fileID, 'Mammal: %s\r\n', DATA.mammals{DATA.mammal_index});
                        fprintf(header_fileID, 'Mammal: %s\r\n', get(GUI.Mammal_popupmenu, 'String'));
                        fprintf(header_fileID, 'Integration level: %s\r\n', DATA.GUI_Integration{DATA.integration_index});
                        if ~strcmp(DATA.Integration, 'oximetry')
                            fprintf(header_fileID, 'Preprocessing: %s\r\n', DATA.Filters_ECG{DATA.filter_index});
                        else
                            fprintf(header_fileID, 'Preprocessing: %s\r\n', DATA.Filters_SpO2{DATA.filter_index});
                        end
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
                        %                         Mammal = DATA.mammals{ DATA.mammal_index};
                        Mammal = get(GUI.Mammal_popupmenu, 'String');
                        IntegrationLevel = DATA.GUI_Integration{DATA.integration_index};
                        Preprocessing = DATA.Filters_ECG{DATA.filter_index};
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
                    h_e = errordlg('Please, press Compute before saving!', 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
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
        
        setLogo(GUI.AboutWindow, 'M2');
        
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
            
            if strcmp(param_category, 'filtrr') || strcmp(param_category, 'filtSpO2') % || isempty(DATA.TimeStat) || isempty(DATA.FrStat) || isempty(DATA.NonLinStat)
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(waitbar_handle, 'M_OBM');
                else
                    setLogo(waitbar_handle, 'M2');
                end
                try
                    FiltSignal();
                    DetrendIfNeed_data_chunk();
                    clear_statistics_plots();
                    clearStatTables();
                    plotFilteredData();
                    calcStatistics();
                    close(waitbar_handle);
                catch e
                    close(waitbar_handle);
                    rethrow(e);
                end
            elseif strcmp(param_category, 'hrv_time') || strcmp(param_category, 'OveralGeneralMeasures')
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(waitbar_handle, 'M_OBM');
                else
                    setLogo(waitbar_handle, 'M2');
                end
                calcTimeStatistics(waitbar_handle);
                close(waitbar_handle);
            elseif strcmp(param_category, 'hrv_freq')
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(waitbar_handle, 'M_OBM');
                else
                    setLogo(waitbar_handle, 'M2');
                end
                calcFrequencyStatistics(waitbar_handle);
                close(waitbar_handle);
            elseif strcmp(param_category, 'dfa') || strcmp(param_category, 'mse') || strcmp(param_category, 'HypoxicBurdenMeasures')
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(waitbar_handle, 'M_OBM');
                else
                    setLogo(waitbar_handle, 'M2');
                end
                calcNonlinearStatistics(waitbar_handle);
                close(waitbar_handle);
            elseif strcmp(param_category, 'ODIMeasures')
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(waitbar_handle, 'M_OBM');
                else
                    setLogo(waitbar_handle, 'M2');
                end
                calcDesaturationsStatistics(waitbar_handle);
                close(waitbar_handle);
            elseif strcmp(param_category, 'ComplexityMeasures')
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(waitbar_handle, 'M_OBM');
                else
                    setLogo(waitbar_handle, 'M2');
                end
                calcComplexityStatistics(waitbar_handle);
                close(waitbar_handle);
            elseif strcmp(param_category, 'PeriodicityMeasures')
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(waitbar_handle, 'M_OBM');
                else
                    setLogo(waitbar_handle, 'M2');
                end
                calcPeriodicityMeasuresStatistics(waitbar_handle);
                close(waitbar_handle);
            elseif strcmp(param_category, 'ODI_HypoxicBurdenMeasures')
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(waitbar_handle, 'M_OBM');
                else
                    setLogo(waitbar_handle, 'M2');
                end
                calcDesaturationsStatistics(waitbar_handle);
                close(waitbar_handle);
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(waitbar_handle, 'M_OBM');
                else
                    setLogo(waitbar_handle, 'M2');
                end
                calcNonlinearStatistics(waitbar_handle);
                close(waitbar_handle);
            end
        end
    end
%%
    function set_config_Callback(src, ~, param_name)
        
        if ~isempty(DATA.nni)
            
            doCalc = true;
            cp_param_array = [];
            do_couple = false;
            param_category = strsplit(param_name, '.');
            
            min_suffix_ind = strfind(param_name, '.min');
            max_suffix_ind = strfind(param_name, '.max');
            
            screen_value = str2double(get(src, 'String'));
            prev_screen_value = get(src, 'UserData');
            
            string_screen_value = get(src, 'String');
            
            if regexpi(param_name, 'filt') % regexpi(param_name, 'filtrr')
                custom_level = length(get(GUI.FilteringLevel_popupmenu, 'String'));
                items = get(GUI.Filtering_popupmenu, 'String');
                index_selected = get(GUI.Filtering_popupmenu, 'Value');
                Filter = items{index_selected};
            else
                Filter = [];
            end
            
            if strcmp(param_name, 'OveralGeneralMeasures.ZC_Baseline') || strcmp(param_name, 'OveralGeneralMeasures.M_Threshold')...
                    || strcmp(param_name, 'ODIMeasures.ODI_Threshold') || strcmp(param_name, 'HypoxicBurdenMeasures.CT_Threshold')...
                    || strcmp(param_name, 'filtSpO2.RangeSpO2.Range_min') || strcmp(param_name, 'filtSpO2.RangeSpO2.Range_max')...
                    || strcmp(param_name, 'filtSpO2.BlockSpO2.Treshold') || strcmp(param_name, 'filtSpO2.DFilterSpO2.Diff')...
                    || strcmp(param_name, 'ODIMeasures.Hard_Threshold')
                
                if isnan(screen_value) || screen_value < 0 || screen_value > 100
                    h_e = errordlg(['set_config_Callback error: ' 'The value must be greater than 0 and less than 100!'], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    set(src, 'String', prev_screen_value);
                    return;
                end
                
                %-------------------------------------------------------
                if ~isempty(Filter)
                    if (strcmp(Filter, 'Range') && (strcmp(param_name, 'filtSpO2.RangeSpO2.Range_min') || strcmp(param_name, 'filtSpO2.RangeSpO2.Range_max')))...
                            || (strcmp(Filter, 'Block Data') && strcmp(param_name, 'filtSpO2.BlockSpO2.Treshold'))...
                            || (strcmp(Filter, 'DFilter') && strcmp(param_name, 'filtSpO2.DFilterSpO2.Diff'))
                        set(GUI.FilteringLevel_popupmenu, 'Value', custom_level);
                    end
                end
                %-------------------------------------------------------
            elseif strcmp(param_name, 'filtSpO2.MedianSpO2.FilterLength')
                if isnan(screen_value) || ~(screen_value > 0) || mod(screen_value, 2) == 0
                    h_e = errordlg(['set_config_Callback error: ' 'This parameter must be numeric odd positive value!'], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    set(src, 'String', prev_screen_value);
                    return;
                elseif strcmp(Filter, 'Median')
                    set(GUI.FilteringLevel_popupmenu, 'Value', custom_level);
                end
                %-------------------------------------------------------
            elseif strcmp(param_name, 'hrv_freq.welch_overlap')
                if isnan(screen_value) || screen_value < 0 || screen_value >= 100
                    h_e = errordlg(['set_config_Callback error: ' 'The value must be greater than 0 and less than 100!'], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    set(src, 'String', prev_screen_value);
                    return;
                end
            elseif strcmp(param_name, 'filtrr.quotient.rr_max_change')
                if isnan(screen_value) || screen_value <= 0 || screen_value > 100
                    h_e = errordlg(['set_config_Callback error: ' 'The value must be greater than 0 and less than 100!'], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    set(src, 'String', prev_screen_value);
                    return;
                elseif strcmp(Filter, 'Quotient') || strcmp(Filter, 'Combined filters')
                    set(GUI.FilteringLevel_popupmenu, 'Value', custom_level);
                end
            elseif regexp(param_name, 'filtrr.moving_average')
                if strcmp(param_name, 'filtrr.moving_average.win_threshold') && (isnan(screen_value) || screen_value < 0 || screen_value > 100)
                    h_e = errordlg(['set_config_Callback error: ' 'The value must be greater than 0 and less than 100!'], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    set(src, 'String', prev_screen_value);
                    return;
                end
                if strcmp(param_name, 'filtrr.moving_average.win_length') && (isnan(screen_value) || screen_value < 1 || screen_value > length(DATA.rri))
                    h_e = errordlg(['set_config_Callback error: ' 'The value must be greater than 0 and less than ' num2str(DATA.maxSignalLength/60) 'sec!'], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    set(src, 'String', prev_screen_value);
                    return;
                end
                if strcmp(Filter, 'Moving average') || strcmp(Filter, 'Combined filters')
                    set(GUI.FilteringLevel_popupmenu, 'Value', custom_level);
                end
            elseif regexp(param_name, 'filtrr.range')
                if isnan(screen_value) || ~(screen_value > 0)
                    h_e = errordlg(['set_config_Callback error: ' 'This parameter must be numeric positive single value!'], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    set(src, 'String', prev_screen_value);
                    return;
                elseif strcmp(Filter, 'Range') || strcmp(Filter, 'Combined filters')
                    set(GUI.FilteringLevel_popupmenu, 'Value', custom_level);
                end
            elseif strcmp(param_name, 'hrv_freq.window_minutes')
                
                [screen_value, isInputNumeric] = calcDurationInSeconds(GUI.SpectralWindowLengthHandle, string_screen_value, prev_screen_value*60);
                
                if isInputNumeric && screen_value <= 0
                    h_e = errordlg('The spectral window length must be greater than 0 sec!', 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    return;
                elseif ~isInputNumeric
                    return;
                end
                
                screen_value = screen_value / 60; % to minutes
                
            elseif strcmp(param_name, 'PeriodicityMeasures.Frequency_Low') ||  strcmp(param_name, 'PeriodicityMeasures.Frequency_High')
                if isnan(screen_value) || ~(screen_value >= 0)
                    h_e = errordlg(['set_config_Callback error: ' 'This parameter must be numeric positive single value or zero!'], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    set(src, 'String', prev_screen_value);
                    return;
                elseif strcmp(param_name, 'PeriodicityMeasures.Frequency_Low')
                    f_h = mhrv.defaults.mhrv_get_default('PeriodicityMeasures.Frequency_High').value;
                    if screen_value >= f_h
                        h_e = errordlg(['set_config_Callback error: ' 'Frequency Low must be less than Frequency High!'], 'Input Error');
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(h_e, 'M_OBM');
                        else
                            setLogo(h_e, 'M2');
                        end
                        set(src, 'String', prev_screen_value);
                        return;
                    end
                elseif strcmp(param_name, 'PeriodicityMeasures.Frequency_High')
                    f_h = mhrv.defaults.mhrv_get_default('PeriodicityMeasures.Frequency_Low').value;
                    if screen_value <= f_h
                        h_e = errordlg(['set_config_Callback error: ' 'Frequency Low must be less than Frequency High!'], 'Input Error');
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(h_e, 'M_OBM');
                        else
                            setLogo(h_e, 'M2');
                        end
                        set(src, 'String', prev_screen_value);
                        return;
                    end
                end
            elseif  isnan(screen_value) || ~(screen_value > 0)
                h_e = errordlg(['set_config_Callback error: ' 'This parameter must be numeric positive single value!'], 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
                set(src, 'String', prev_screen_value);
                return;
            end
            
            if ~isempty(min_suffix_ind)
                param_name = param_name(1 : min_suffix_ind - 1);
                min_param_value = screen_value;
                prev_param_array = mhrv.defaults.mhrv_get_default(param_name);
                max_param_value = prev_param_array.value(2);
                
                if min_param_value > max_param_value
                    h_e = errordlg(['set_config_Callback error: ' 'The min value must be less than max value!'], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
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
                    cp_param_array = mhrv.defaults.mhrv_get_default(couple_name);
                    mhrv.defaults.mhrv_set_default( couple_name, [cp_param_array.value(1) screen_value] );
                    couple_handle = get(get(get(src, 'Parent'), 'Parent'), 'Children');
                    set(findobj(couple_handle, 'Tag', [couple_name '.max']), 'String', num2str(screen_value));
                end
                
            elseif ~isempty(max_suffix_ind)
                param_name = param_name(1 : max_suffix_ind - 1);
                max_param_value = screen_value;
                prev_param_array = mhrv.defaults.mhrv_get_default(param_name);
                min_param_value = prev_param_array.value(1);
                
                if max_param_value < min_param_value
                    h_e = errordlg(['set_config_Callback error: ' 'The max value must be greater than min value!'], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
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
                    cp_param_array = mhrv.defaults.mhrv_get_default(couple_name);
                    mhrv.defaults.mhrv_set_default( couple_name, [screen_value cp_param_array.value(2)] );
                    couple_handle = get(get(get(src, 'Parent'), 'Parent'), 'Children');
                    set(findobj(couple_handle, 'Tag', [couple_name '.min']), 'String', num2str(screen_value));
                end
            else
                param_value = screen_value;
                prev_param_array = mhrv.defaults.mhrv_get_default(param_name);
                prev_param_value = prev_param_array.value;
            end
            
            mhrv.defaults.mhrv_set_default( param_name, param_value );
            
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
                elseif strcmp(param_category{2}, 'detrending') && strcmp(param_category{3}, 'lambda')
                    doFilt = 2;
                end
            elseif regexpi(param_name, 'filtSpO2')
                DATA.custom_filters_thresholds.(param_category{2}).(param_category{3}) = param_value;
                if strcmp(Filter, 'Range') && strcmp(param_category{2}, 'RangeSpO2')
                    doFilt = 1;
                elseif GUI.MedianFilter_checkbox.Value  && strcmp(param_category{2}, 'MedianSpO2') % Median - ON
                    doFilt = 1;
                elseif strcmp(Filter, 'Block Data') && strcmp(param_category{2}, 'BlockSpO2')
                    doFilt = 1;
                elseif strcmp(Filter, 'DFilter') && strcmp(param_category{2}, 'DFilterSpO2')
                    doFilt = 1;
                    %                 elseif strcmp(param_category{2}, 'ResampSpO2') && strcmp(param_category{3}, 'Original_fs')
                    %                     doFilt = 2;
                end
            else
                doFilt = 1;
            end
            
            if get(GUI.AutoCalc_checkbox, 'Value')
                try
                    %                     if doCalc && doFilt == 3 %% Change Original_fs
                    %                         Resamping_checkbox_Callback();
                    %                     end
                    
                    if doCalc && doFilt == 2 %% Change lambda
                        Detrending_checkbox_Callback();
                    end
                    
                    if doCalc && doFilt == 1
                        update_statistics(param_category(1));
                    end
                    set(src, 'UserData', screen_value);
                catch e
                    h_e = errordlg(['set_config_Callback error: ' e.message], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    
                    mhrv.defaults.mhrv_set_default( param_name, prev_param_array );
                    
                    if strcmp(param_name, 'hrv_freq.window_minutes')
                        set(src, 'String', calcDuration(prev_param_value*60, 0));
                    else
                        set(src, 'String', num2str(prev_param_value));
                    end
                    
                    if ~isempty(cp_param_array)
                        mhrv.defaults.mhrv_set_default( couple_name, cp_param_array );
                        couple_handle = get(get(get(src, 'Parent'), 'Parent'), 'Children');
                        if ~isempty(min_suffix_ind)
                            set(findobj(couple_handle, 'Tag', [couple_name '.max']), 'String', num2str(prev_param_value))
                        elseif ~isempty(max_suffix_ind)
                            set(findobj(couple_handle, 'Tag', [couple_name '.min']), 'String', num2str(prev_param_value))
                        end
                    end
                end
            end
        else
            %             throw(MException('set_config_Callback:NoData', 'No data'));
        end
    end
%%
    function set_text_position(text_hndle, pushbutton_handle, text)
        set(text_hndle, 'String', text);
        config_file_name_extent = get(text_hndle, 'Extent');
        config_file_name_position = get(text_hndle, 'Position');
        load_config_name_button_position = get(pushbutton_handle, 'Position');
        set(pushbutton_handle, 'Position', [config_file_name_position(1)+config_file_name_extent(3)+10 load_config_name_button_position(2) load_config_name_button_position(3) load_config_name_button_position(4)]);
    end
%%
    function onLoadCustomConfigFile(~, ~)
        set_defaults_path();
        
        [Config_FileName, PathName] = uigetfile({'*.yml','Yaml-files (*.yml)'}, 'Open Configuration File', [DIRS.configDirectory filesep]);
        
        if ~isequal(Config_FileName, 0) && ~strcmpi(Config_FileName, 'gui_params.yml')
            params_filename = fullfile(PathName, Config_FileName);
            DIRS.configDirectory = PathName;
            [pathstr, name, conf_ext] = fileparts(params_filename);
            
            if ~strcmp(conf_ext, '.yml')
                h_e = errordlg('Only .yml files are supported as configuration parameters files', 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
                return;
            else
                
                conf_name = [name conf_ext];
                set(GUI.Config_text, 'String', conf_name);
                if Module3
                    set(GUI.GroupsConfig_text, 'String', conf_name);
                end
                %                 set_text_position(GUI.Config_text, GUI.open_config_pushbutton_handle, [name conf_ext]);
                
                %                 set(GUI.Config_text, 'String', [name conf_ext]);
                %                 config_file_name_extent = get(GUI.Config_text, 'Extent');
                %                 config_file_name_position = get(GUI.Config_text, 'Position');
                %                 load_config_name_button_position = get(GUI.open_config_pushbutton_handle, 'Position');
                %                 set(GUI.open_config_pushbutton_handle, 'Position', [config_file_name_position(1)+config_file_name_extent(3)+10 load_config_name_button_position(2) load_config_name_button_position(3) load_config_name_button_position(4)]);
                
                mhrv.defaults.mhrv_set_default('parameters_type.mammal', '');
                mhrv.defaults.mhrv_set_default('parameters_type.integration_level', '');
                
                mhrv.defaults.mhrv_load_defaults([pathstr filesep name]);
                
                mammal = mhrv.defaults.mhrv_get_default('parameters_type.mammal');
                mammal = mammal.value;
                integration = mhrv.defaults.mhrv_get_default('parameters_type.integration_level');
                integration = integration.value;
                
                if isempty(mammal) || isempty(integration)
                    mammal = 'custom';
                    integration = 'ECG';
                    mhrv.defaults.mhrv_set_default('parameters_type.mammal', mammal);
                    mhrv.defaults.mhrv_set_default('parameters_type.integration_level', integration);
                end
                
                %             GUI.Mammal_popupmenu.Value = length(DATA.mammals);
                GUI.Mammal_popupmenu.String = mammal;
                
                createConfigParametersInterface();
                reset_plot_Data();
                reset_plot_GUI();
                DATA.mammal_index = length(DATA.mammals);
                DATA.integration_index = find(strcmpi(DATA.GUI_Integration, integration));
                GUI.Integration_popupmenu.Value = DATA.integration_index;
            end
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
                
                FilteredData_tnn = FilteredData_tnn(:);
                FilteredData_nni = FilteredData_nni(:);
                
                if strcmp(ext, '.txt')
                    psd_fileID = fopen(full_file_name_filtered, 'w');
                    
                    dlmwrite(full_file_name_filtered, [FilteredData_tnn FilteredData_nni], ...
                        'precision', '%10.5f\t', 'delimiter', '\t', 'newline', 'pc', '-append');
                    
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
        
        mammal = get(GUI.Mammal_popupmenu, 'String');
        integration = DATA.integration_level{DATA.integration_index};
        
        [filename, results_folder_name] = uiputfile({'*.yml','Yaml Files (*.yml)'},'Choose Parameters File Name', [DIRS.configDirectory, filesep, [DATA.DataFileName '_' mammal '_' integration] ]);
        
        if ~isequal(results_folder_name, 0)
            DIRS.configDirectory = results_folder_name;
            full_file_name = fullfile(results_folder_name, filename);
            mhrv.defaults.mhrv_save_defaults( full_file_name );
            
            temp_mhrv_default_values = ReadYaml(full_file_name);
            
            temp_hrv_freq = temp_mhrv_default_values.hrv_freq;
            temp_mse = temp_mhrv_default_values.mse;
            
            temp_mhrv_default_values = rmfield(temp_mhrv_default_values, {'hrv_freq'; 'rqrs'; 'mhrv'});
            
            temp_hrv_freq = rmfield(temp_hrv_freq, {'methods'; 'power_methods'; 'norm_method'; 'extra_bands'; 'osf'; 'resample_factor'; 'win_func'});
            temp_mse = rmfield(temp_mse, {'mse_metrics'});
            
            temp_mhrv_default_values.hrv_freq = temp_hrv_freq;
            temp_mhrv_default_values.mse = temp_mse;
            
            result = WriteYaml(full_file_name, temp_mhrv_default_values);
        end
    end
%%
    function PSD_pushbutton_Callback(src, ~)
        if get(src, 'Value')
            set(src, 'String', 'Log');
            DATA.freq_yscale = 'linear';
        else
            set(src, 'String', 'Linear');
            DATA.freq_yscale = 'log';
        end
        if ~strcmp(DATA.Integration, 'oximetry')
            if ~isempty(DATA.FrStat.PlotData{DATA.active_window})
                mhrv.plots.plot_hrv_freq_spectrum(GUI.FrequencyAxes1, DATA.FrStat.PlotData{DATA.active_window}, 'detailed_legend', false, 'yscale', DATA.freq_yscale, 'clear', true);
                set(findobj(GUI.FrequencyAxes1.Children, 'Type', 'Text'), 'FontName', DATA.font_name);
                GUI.FrequencyAxes1.YLabel.String = strrep(GUI.FrequencyAxes1.YLabel.String, '^2', sprintf('\x00B2'));
            end
        else
            if ~isempty(DATA.PMStat.PlotData{DATA.active_window})
                plot_spo2_psd_graph(GUI.FifthAxes1, DATA.PMStat.PlotData{DATA.active_window}.fft, DATA.freq_yscale);
                GUI.FifthAxes1.FontName = DATA.font_name;
                set(findobj(GUI.FifthAxes1.Children, 'Type', 'Text'), 'FontName', DATA.font_name);
            end
        end
    end
%%
    function batch_Edit_Callback( src, ~ )
        if ~isempty(DATA.nni)
            src_tag = get(src, 'Tag');
            
            if strcmp(src_tag, 'segment_overlap')
                param_value = str2double(get(src, 'String'));
                if param_value >= 0 && param_value < 100
                    isInputNumeric = 1;
                else
                    old_param_val = DATA.AnalysisParams.(src_tag);
                    set(src, 'String', num2str(old_param_val));
                    h_w = warndlg('Please, check your input.');
                    setLogo(h_w, 'M2');
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
                        h_e = errordlg('Selected segment start time must be grater than 0 and less than segment end!', 'Input Error');
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(h_e, 'M_OBM');
                        else
                            setLogo(h_e, 'M2');
                        end
                        return;
                    end
                elseif strcmp(src_tag, 'segment_endTime')
                    if param_value < DATA.AnalysisParams.segment_startTime || param_value > DATA.Filt_MaxSignalLength
                        set(src, 'String', calcDuration(DATA.AnalysisParams.(src_tag), 0));
                        h_e = errordlg('Segment end time must be more than zero and less than the segment total length!', 'Input Error');
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(h_e, 'M_OBM');
                        else
                            setLogo(h_e, 'M2');
                        end
                        return;
                    end
                elseif strcmp(src_tag, 'activeWin_length')
                    if  param_value > DATA.Filt_MaxSignalLength
                        set(src, 'String', calcDuration(DATA.AnalysisParams.(src_tag), 0));
                        h_e = errordlg('Selected window length must be less than total signal length!', 'Input Error');
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(h_e, 'M_OBM');
                        else
                            setLogo(h_e, 'M2');
                        end
                        return;
                    elseif param_value > DATA.AnalysisParams.segment_endTime - DATA.AnalysisParams.segment_startTime
                        set(src, 'String', calcDuration(DATA.AnalysisParams.(src_tag), 0));
                        h_e = errordlg('Selected window length must be less than or equal to the segment length!', 'Input Error');
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(h_e, 'M_OBM');
                        else
                            setLogo(h_e, 'M2');
                        end
                        return;
                    elseif param_value <= 10
                        set(src, 'String', calcDuration(DATA.AnalysisParams.(src_tag), 0));
                        h_e = errordlg('Selected window size must be greater than 10 sec!', 'Input Error');
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(h_e, 'M_OBM');
                        else
                            setLogo(h_e, 'M2');
                        end
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
                    DetrendIfNeed_data_chunk();
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
                
                if DATA.AnalysisParams.winNum == 1 && get(GUI.AutoCalc_checkbox, 'Value')
                    calcStatistics();
                end
                
            end
        else
            %             throw(MException('batch_Edit_Callback:NoData', 'No data'));
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
                h_e = errordlg('Please, check your input! Windows number must be greater than 0!', 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
            elseif DATA.AnalysisParams.winNum == 1
                GUI.Filt_RawDataSlider.Enable = 'on';
                GUI.Active_Window_Start.Enable = 'on';
                GUI.Active_Window_Length.Enable = 'on';
                GUI.active_winNum.Enable = 'inactive';
                if isfield(GUI, 'SpectralWindowLengthHandle') && ishandle(GUI.SpectralWindowLengthHandle) && isvalid(GUI.SpectralWindowLengthHandle)
                    GUI.SpectralWindowLengthHandle.Enable = 'on';
                end
            else
                GUI.Filt_RawDataSlider.Enable = 'off';
                GUI.Active_Window_Start.Enable = 'inactive';
                GUI.Active_Window_Length.Enable = 'inactive';
                GUI.active_winNum.Enable = 'on';
                if isfield(GUI, 'SpectralWindowLengthHandle') && ishandle(GUI.SpectralWindowLengthHandle) && isvalid(GUI.SpectralWindowLengthHandle)
                    GUI.SpectralWindowLengthHandle.Enable = 'inactive';
                end
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
                    
                    
                    if strcmp(DATA.Integration, 'oximetry')
                        f_a = 0.1;
                    else
                        f_a = 0.3;
                    end
                    
                    GUI.rect_handle(i) = patch('Faces' ,f, 'Vertices', v, 'FaceColor', DATA.rectangle_color, 'EdgeColor', DATA.rectangle_color, 'LineWidth', 0.5, 'FaceAlpha', f_a, ...
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
                start_time = tic;
                try
                    nni_window =  DATA.nni4calc(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
                    
                    if strcmp(DATA.Integration, 'oximetry')
                        waitbar(1 / 5, waitbar_handle, ['Calculating overal general measures for window ' num2str(i)]);
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(waitbar_handle, 'M_OBM');
                        else
                            setLogo(waitbar_handle, 'M2');
                        end
                        hrv_td = OverallGeneralMeasures(nni_window, GUI.measures_cb_array(1).Value);
                        disp(['SpO2: Calculating overal general measures metrics: win ', num2str(i), ', ', num2str(toc(start_time)), 'sec.']);
                        
                        if GUI.measures_cb_array(1).Value
                            DATA.TimeStat.PlotData{i} = nni_window;
                        else
                            DATA.TimeStat.PlotData{i} = [];
                        end
                        hrv_frag = [];
                        fragData = [];
                        fragRowsNames = [];
                        fragDescriptions = [];
                    else
                        waitbar(1 / 3, waitbar_handle, ['Calculating time measures for window ' num2str(i)]);
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(waitbar_handle, 'M_OBM');
                        else
                            setLogo(waitbar_handle, 'M2');
                        end
                        
                        % Time Domain metrics
                        fprintf('[win % d: %.3f] >> mhrv: Calculating time-domain metrics...\n', i, toc(start_time));
                        [hrv_td, pd_time] = mhrv.hrv.hrv_time(nni_window);
                        % Heart rate fragmentation metrics
                        fprintf('[win % d: %.3f] >> mhrv: Calculating fragmentation metrics...\n', i, toc(start_time));
                        hrv_frag = mhrv.hrv.hrv_fragmentation(nni_window);
                        
                        DATA.TimeStat.PlotData{i} = pd_time;
                        [fragData, fragRowsNames, fragDescriptions] = table2cell_StatisticsParam(hrv_frag);
                    end
                    
                    [timeData, timeRowsNames, timeDescriptions] = table2cell_StatisticsParam(hrv_td);
                    timeRowsNames_NO_GreekLetters = [timeRowsNames; fragRowsNames];
                    timeRowsNames = cellfun(@(x) strrep(x, 'DI', sprintf('\x394I')), timeRowsNames, 'UniformOutput', false);
                    
                    if ~DATA.GroupsCalc
                        if i == DATA.active_window
                            
                            GUI.TimeParametersTableRowName = timeRowsNames;
                            GUI.TimeParametersTableData = [timeDescriptions timeData];
                            GUI.TimeParametersTable.Data = [timeRowsNames timeData];
                            
                            
                            if ~strcmp(DATA.Integration, 'oximetry')
                                GUI.FragParametersTableRowName = fragRowsNames;
                                GUI.FragParametersTableData = [fragDescriptions fragData];
                                GUI.FragParametersTable.Data = [fragRowsNames fragData];
                            else
                                GUI.FragParametersTableRowName = [];
                                GUI.FragParametersTableData = [];
                                GUI.FragParametersTable.Data = [];
                            end
                            
                            updateTimeStatistics();
                            if ~strcmp(DATA.Integration, 'oximetry')
                                plot_time_statistics_results(i);
                            else
                                plot_general_statistics_results(i);
                            end
                        end
                    end
                catch e
                    DATA.timeStatPartRowNumber = 0;
                    close(waitbar_handle);
                    h_e = errordlg(['hrv_time: ' e.message], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    rethrow(e);
                end
                
                curr_win_table = horzcat(hrv_td, hrv_frag);
                curr_win_table.Properties.RowNames{1} = sprintf('W%d', i);
                
                hrv_time_metrics_tables{i} = curr_win_table;
                
                if i == 1
                    DATA.TimeStat.RowsNames = [timeRowsNames; fragRowsNames];
                    DATA.TimeStat.RowsNames_NO_GreekLetters = timeRowsNames_NO_GreekLetters;
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
            if strcmp(DATA.Integration, 'oximetry')
                descr_str = 'Oximetry time measures ';
            else
                descr_str = 'HRV time metrics for ';
            end
            DATA.TimeStat.hrv_time_metrics.Properties.Description = sprintf('%s%s', descr_str, DATA.DataFileName);
        end
    end
%%
    function fr_prop_variables_names = fix_fr_prop_var_names(fr_prop_variables_names)
        fr_prop_variables_names = cellfun(@(x) strrep(x, 'BETA', sprintf('\x3b2')), fr_prop_variables_names, 'UniformOutput', false);
        fr_prop_variables_names = cellfun(@(x) strrep(x, '_', sprintf(' ')), fr_prop_variables_names, 'UniformOutput', false);
        fr_prop_variables_names = cellfun(@(x) strrep(x, ' TO ', sprintf('/')), fr_prop_variables_names, 'UniformOutput', false);
        fr_prop_variables_names = cellfun(@(x) strrep(x, ' POWER', sprintf('')), fr_prop_variables_names, 'UniformOutput', false);
        fr_prop_variables_names = cellfun(@(x) strrep(x, 'TOTAL', sprintf('TOTAL POWER')), fr_prop_variables_names, 'UniformOutput', false);
        fr_prop_variables_names = cellfun(@(x) strrep(x, '^2', sprintf('\x00B2')), fr_prop_variables_names, 'UniformOutput', false);
    end
%%
    function calcFrequencyStatistics(waitbar_handle)
        
        if isfield(DATA, 'AnalysisParams')
            batch_window_start_time = DATA.AnalysisParams.segment_startTime;
            batch_window_length = DATA.AnalysisParams.activeWin_length;
            batch_overlap = DATA.AnalysisParams.segment_overlap/100;
            batch_win_num = DATA.AnalysisParams.winNum;
            
            GUI.FrequencyParametersTable.ColumnName = {'                Measures Name                ', 'Values Welch', 'Values AR'};
            
            hrv_fr_metrics_tables = cell(batch_win_num, 1);
            
            for i = 1 : batch_win_num
                
                t0 = tic;
                
                try
                    nni_window =  DATA.nni4calc(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
                    tnn_window =  DATA.tnn(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
                    tnn_window = tnn_window - tnn_window(1);
                    
                    waitbar(2 / 3, waitbar_handle, ['Calculating frequency measures for window ' num2str(i)]);
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(waitbar_handle, 'M_OBM');
                    else
                        setLogo(waitbar_handle, 'M2');
                    end
                    % Freq domain metrics
                    fprintf('[win % d: %.3f] >> mhrv: Calculating frequency-domain metrics...\n', i, toc(t0));
                    
                    if DATA.WinAverage
                        window_minutes = mhrv.defaults.mhrv_get_default('hrv_freq.window_minutes');
                        [ hrv_fd, ~, ~, pd_freq ] = mhrv.hrv.hrv_freq(nni_window, 'methods', {'welch','ar'}, 'power_methods', {'welch','ar'}, 'window_minutes', window_minutes.value, 'time_intervals', tnn_window);
                    else
                        [ hrv_fd, ~, ~, pd_freq ] = mhrv.hrv.hrv_freq(nni_window, 'methods', {'welch','ar'}, 'power_methods', {'welch','ar'}, 'window_minutes', [], 'time_intervals', tnn_window);
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
                    h_e = errordlg(['hrv_freq: ' e.message], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
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
                    
                    DATA.FrStat.RowsNames_NO_GreekLetters = [fd_ArRowsNames_NO_GreekLetters; fd_WelchRowsNames_NO_GreekLetters];
                    
                    DATA.FrStat.ArWindowsData.Data = [fd_ArDescriptions fd_arData];
                    DATA.FrStat.WelchWindowsData.Data = [fd_WelchDescriptions fd_welchData];
                else
                    DATA.FrStat.ArWindowsData.Data = [DATA.FrStat.ArWindowsData.Data fd_arData];
                    DATA.FrStat.WelchWindowsData.Data = [DATA.FrStat.WelchWindowsData.Data fd_welchData];
                end
                
                DATA.FrStat.Data = [DATA.FrStat.ArWindowsData.Data; DATA.FrStat.WelchWindowsData.Data];
                
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
            
            start_time = tic;
            try
                nni_window =  DATA.nni4calc(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
                
                if strcmp(DATA.Integration, 'oximetry')
                    
                    fun_name = 'SpO2_HypoxicBurden';
                    
                    waitbar(3 / 5, waitbar_handle, ['Calculating hypoxic burden measures for window ' num2str(i)]);
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(waitbar_handle, 'M_OBM');
                    else
                        setLogo(waitbar_handle, 'M2');
                    end
                    
                    ODI_region = DATA.DesaturationsRegionsCell{1, i};
                    if isempty(ODI_region)
                        ODI_begin = [];
                        ODI_end = [];
                    else
                        ODI_begin = ODI_region(:, 1);
                        ODI_end = ODI_region(:, 2);
                    end
                    
                    %                     hrv_nl = HypoxicBurdenMeasures(nni_window, DATA.ODI_begin, DATA.ODI_end); %ODI_begin, ODI_end
                    hrv_nl = HypoxicBurdenMeasures(nni_window, ODI_begin, ODI_end, GUI.measures_cb_array(2).Value); %ODI_begin, ODI_end
                    disp(['Spo2: Calculating hypoxic burden metrics: win ', num2str(i), ', ', num2str(toc(start_time)), 'sec.']);
                    
                    if GUI.measures_cb_array(2).Value
                        DATA.NonLinStat.PlotData{i} = nni_window;
                    else
                        DATA.NonLinStat.PlotData{i} = [];
                    end
                else
                    fun_name = 'hrv.hrv_nonlinear';
                    waitbar(3 / 3, waitbar_handle, ['Calculating nolinear measures for window ' num2str(i)]);
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(waitbar_handle, 'M_OBM');
                    else
                        setLogo(waitbar_handle, 'M2');
                    end
                    fprintf('[win % d: %.3f] >> mhrv: Calculating nonlinear metrics...\n', i, toc(start_time));
                    [hrv_nl, pd_nl] = mhrv.hrv.hrv_nonlinear(nni_window);
                    
                    DATA.NonLinStat.PlotData{i} = pd_nl;
                end
                
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
                DATA.NonLinearStatPartRowNumber = 0;
                close(waitbar_handle);
                h_e = errordlg([fun_name ' : ' e.message], 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
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
            [rn, ~] = size(DATA.NonLinStat.RowsNames);
            DATA.NonLinearStatPartRowNumber = rn;
        end
        
        % Create full table
        DATA.NonLinStat.hrv_nonlin_metrics = vertcat(hrv_nonlin_metrics_tables{:});
        if strcmp(DATA.Integration, 'oximetry')
            descr_str = 'Oximetry hypoxic burden measures for ';
        else
            descr_str = 'HRV non linear metrics for ';
        end
        DATA.NonLinStat.hrv_nonlin_metrics.Properties.Description = sprintf('%s%s', descr_str, DATA.DataFileName);
    end
%%
    function calcComplexityStatistics(waitbar_handle)
        batch_window_start_time = DATA.AnalysisParams.segment_startTime;
        batch_window_length = DATA.AnalysisParams.activeWin_length;
        batch_overlap = DATA.AnalysisParams.segment_overlap/100;
        batch_win_num = DATA.AnalysisParams.winNum;
        
        SpO2_Complexity_metrics_tables = cell(batch_win_num, 1);
        
        for i = 1 : batch_win_num
            start_time = tic;
            
            nni_window =  DATA.nni4calc(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
            
            %             if ~all(isnan(nni_window))
            
            try
                waitbar(4 / 5, waitbar_handle, ['Calculating complexity measures for window ' num2str(i)]);
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(waitbar_handle, 'M_OBM');
                else
                    setLogo(waitbar_handle, 'M2');
                end
                
                SpO2_CM = ComplexityMeasures(nni_window, [GUI.measures_cb_array(4:8).Value]);
                disp(['Spo2: Calculating complexity measures for window: win ', num2str(i), ', ', num2str(toc(start_time)), 'sec.']);
                
                if GUI.measures_cb_array(4).Value && ~all(isnan(nni_window))
                    [~, ~, plot_data] = oximetry_dfa(nni_window);
                    DATA.CMStat.PlotData{i} = plot_data;
                else
                    DATA.CMStat.PlotData{i} = [];
                end
                
                [CMData, CMRowsNames, CMDescriptions] = table2cell_StatisticsParam(SpO2_CM);
                %                 nonlinRowsNames_NO_GreekLetters = nonlinRowsNames;
                
                if ~DATA.GroupsCalc
                    if i == DATA.active_window
                        GUI.CMTableRowName = CMRowsNames;
                        GUI.CMTableData = [CMDescriptions CMData];
                        GUI.CMTable.Data = [CMRowsNames CMData];
                        plot_complexity_results(i);
                    end
                end
            catch e
                close(waitbar_handle);
                DATA.ComplexityStatPartRowNumber = 0;
                h_e = errordlg(['SpO2_complexity: ' e.message], 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
                rethrow(e);
            end
            
            curr_win_table = SpO2_CM;
            curr_win_table.Properties.RowNames{1} = sprintf('W%d', i);
            
            SpO2_Complexity_metrics_tables{i} = curr_win_table;
            
            if i == 1
                DATA.CMStat.RowsNames = CMRowsNames;
                DATA.CMStat.Data = [CMDescriptions CMData];
            else
                %                     if isempty(DATA.CMStat.RowsNames)
                %                         DATA.CMStat.RowsNames = CMRowsNames;
                %                     end
                %                         DATA.CMStat.Data = [CMDescriptions CMData];
                %                     else
                DATA.CMStat.Data = [DATA.CMStat.Data CMData];
                %                     end
            end
            %             else
            %                 DATA.CMStat.PlotData{i} = [];
            %                 curr_win_table = [];
            %                 curr_win_table.Properties.RowNames{1} = sprintf('W%d', i);
            %                 SpO2_Complexity_metrics_tables{i} = curr_win_table;
            %
            %                 if ~isfield(DATA.CMStat, 'Data')
            %                     DATA.CMStat.RowsNames = [];
            %                     DATA.CMStat.Data = [];
            %                 else
            %                     DATA.CMStat.Data = [DATA.CMStat.Data []];
            %                 end
            %             end
            batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
        end
        if ~DATA.GroupsCalc
            updateMainStatisticsTable(DATA.timeStatPartRowNumber + DATA.frequencyStatPartRowNumber + DATA.NonLinearStatPartRowNumber, DATA.CMStat.RowsNames, DATA.CMStat.Data);
            [rn, ~] = size(DATA.CMStat.RowsNames);
            DATA.ComplexityStatPartRowNumber = rn;
        end
        % Create full table
        DATA.CMStat.SpO2_CM_metrics = vertcat(SpO2_Complexity_metrics_tables{:});
        if strcmp(DATA.Integration, 'oximetry')
            descr_str = 'Oximetry complexity measures for ';
        end
        DATA.CMStat.SpO2_CM_metrics.Properties.Description = sprintf('%s%s', descr_str, DATA.DataFileName);
    end
%%
    function calcDesaturationsStatistics(waitbar_handle)
        if isfield(DATA, 'AnalysisParams')
            batch_window_start_time = DATA.AnalysisParams.segment_startTime;
            batch_window_length = DATA.AnalysisParams.activeWin_length;
            batch_overlap = DATA.AnalysisParams.segment_overlap/100;
            batch_win_num = DATA.AnalysisParams.winNum;
            
            GUI.FrequencyParametersTable.ColumnName = {'                Measures Name                ', 'Values'};
            
            SpO2_desat_metrics_tables = cell(batch_win_num, 1);
            DATA.DesaturationsRegionsCell = cell(1, batch_win_num);
            DATA.DesaturationsRegions = [];
            
            %             samples_num = 0;
            
            for i = 1 : batch_win_num
                start_time = tic;
                try
                    nni_window =  DATA.nni4calc(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
                    
                    if strcmp(DATA.Integration, 'oximetry')
                        waitbar(2 / 5, waitbar_handle, ['Calculating desaturations measures for window ' num2str(i)]);
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(waitbar_handle, 'M_OBM');
                        else
                            setLogo(waitbar_handle, 'M2');
                        end
                        
                        
                        prev_ind_num = length(DATA.nni4calc(DATA.tnn <= batch_window_start_time));
                        
                        %                         [SpO2_ODI, ODI_begin, ODI_end] = ODIMeasure(nni_window);
                        
                        
                        [SpO2_DSM, ODI_begin, ODI_end] = DesaturationsMeasures(nni_window, GUI.measures_cb_array(2).Value);
                        
                        DATA.ODI_begin = ODI_begin + prev_ind_num;
                        DATA.ODI_end = ODI_end + prev_ind_num;
                        
                        new_ind_array = [DATA.ODI_begin, DATA.ODI_end];
                        
                        DATA.DesaturationsRegionsCell{1, i} = [ODI_begin ODI_end];
                        DATA.DesaturationsRegions = [DATA.DesaturationsRegions; new_ind_array];
                        
                        disp(['Spo2: Calculating desaturations measures for window: win ', num2str(i), ', ', num2str(toc(start_time)), 'sec.']);
                        
                        desat_intervals_depth = zeros(1, length(ODI_begin));
                        for index = 1 : length(ODI_begin)
                            desat_intervals_depth(index) = ...
                                max(nni_window(ODI_begin(index) : ODI_end(index))) - min(nni_window(ODI_begin(index) : ODI_end(index)));
                        end
                        
                        des_pd.des_length = diff(new_ind_array, 1, 2);
                        des_pd.des_depth = desat_intervals_depth;
                        DATA.FrStat.PlotData{i} = des_pd;
                    end
                    
                    %                     [ODIData, ODIRowsNames, ODIDescriptions] = table2cell_StatisticsParam(SpO2_ODI);
                    [DSMData, DSMRowsNames, DSMDescriptions] = table2cell_StatisticsParam(SpO2_DSM);
                    
                    DSMRowsNames_NO_GreekLetters = DSMRowsNames;
                    DSMRowsNames = cellfun(@(x) strrep(x, '_u', sprintf('\x3BC')), DSMRowsNames, 'UniformOutput', false);
                    DSMRowsNames = cellfun(@(x) strrep(x, '_sd', sprintf('\x3C3')), DSMRowsNames, 'UniformOutput', false);
                    DSMRowsNames = cellfun(@(x) strrep(x, '**2', sprintf('\x0B2')), DSMRowsNames, 'UniformOutput', false);
                    
                    if ~DATA.GroupsCalc
                        if i == DATA.active_window
                            
                            %                             GUI.ODIParametersTableRowName = ODIRowsNames;
                            %                             GUI.ODIParametersTableData = [ODIDescriptions ODIData];
                            %                             GUI.ODIParametersTable.Data = [ODIRowsNames ODIData];
                            
                            GUI.FrequencyParametersTableRowName = DSMRowsNames;
                            GUI.FrequencyParametersTableData = [DSMDescriptions DSMData];
                            GUI.FrequencyParametersTable.Data = [DSMRowsNames DSMData];
                            
                            %                             updateODIDSMStatistics();
                            
                            plot_desaturations_results(i);
                            
                        end
                    end
                catch e
                    DATA.frequencyStatPartRowNumber = 0;
                    close(waitbar_handle);
                    h_e = errordlg(['SPO2_DSM: ' e.message], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    rethrow(e);
                end
                
                curr_win_table = SpO2_DSM;
                curr_win_table.Properties.RowNames{1} = sprintf('W%d', i);
                
                SpO2_desat_metrics_tables{i} = curr_win_table;
                
                if i == 1
                    %                     DATA.FrStat.RowsNames = [ODIRowsNames; DSMRowsNames];
                    DATA.FrStat.RowsNames = DSMRowsNames;
                    %                     DATA.FrStat.RowsNames_NO_GreekLetters = [ODIRowsNames; DSMRowsNames_NO_GreekLetters];
                    DATA.FrStat.RowsNames_NO_GreekLetters = DSMRowsNames_NO_GreekLetters;
                    %                     DATA.FrStat.Data = [[ODIDescriptions; DSMDescriptions] [ODIData; DSMData]];
                    DATA.FrStat.Data = [DSMDescriptions DSMData];
                else
                    %                     DATA.FrStat.Data = [DATA.FrStat.Data [ODIData; DSMData]];
                    DATA.FrStat.Data = [DATA.FrStat.Data DSMData];
                end
                batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
            end
            
            if isfield(GUI, 'filtered_handle') && ishandle(GUI.filtered_handle) &&  isvalid(GUI.filtered_handle)
                GUI.filtered_handle.CData = create_color_array4oximetry();
            end
            
            if ~DATA.GroupsCalc
                updateMainStatisticsTable(DATA.timeStatPartRowNumber, DATA.FrStat.RowsNames, DATA.FrStat.Data);
                [rn, ~] = size(DATA.FrStat.RowsNames);
                DATA.frequencyStatPartRowNumber = rn;
            end
            % Create full table
            DATA.FrStat.hrv_fr_metrics = vertcat(SpO2_desat_metrics_tables{:});
            DATA.FrStat.hrv_fr_metrics.Properties.Description = sprintf('Oximetry desaturations measures%s', DATA.DataFileName);
        end
    end
%%
    function calcPeriodicityMeasuresStatistics(waitbar_handle)
        batch_window_start_time = DATA.AnalysisParams.segment_startTime;
        batch_window_length = DATA.AnalysisParams.activeWin_length;
        batch_overlap = DATA.AnalysisParams.segment_overlap/100;
        batch_win_num = DATA.AnalysisParams.winNum;
        
        SpO2_PeriodicityMeasures_tables = cell(batch_win_num, 1);
        
        for i = 1 : batch_win_num
            start_time = tic;
            try
                nni_window =  DATA.nni4calc(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
                
                if strcmp(DATA.Integration, 'oximetry')
                    
                    waitbar(5 / 5, waitbar_handle, ['Calculating periodicity measures for window ' num2str(i)]);
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(waitbar_handle, 'M_OBM');
                    else
                        setLogo(waitbar_handle, 'M2');
                    end
                    
                    [SpO2_PRSA, pd_periodicity] = PeriodicityMeasures(nni_window, GUI.measures_cb_array(3).Value);
                    DATA.PMStat.PlotData{i} = pd_periodicity;
                    
                    %                     SpO2_PRSA = PRSAMeasures(nni_window);
                    disp(['Spo2: Calculating periodicity measures for window: win ', num2str(i), ', ', num2str(toc(start_time)), 'sec.']);
                end
                
                [PMData, PMRowsNames, PMDescriptions] = table2cell_StatisticsParam(SpO2_PRSA);
                
                PMRowsNames_NO_GreekLetters = PMRowsNames;
                PMRowsNames = cellfun(@(x) strrep(x, '**2', sprintf('\x0B2')), PMRowsNames, 'UniformOutput', false);
                
                if ~DATA.GroupsCalc
                    if i == DATA.active_window
                        GUI.PMTableRowName = PMRowsNames;
                        GUI.PMTableData = [PMDescriptions PMData];
                        GUI.PMTable.Data = [PMRowsNames PMData];
                        plot_periodicity_statistics_results(i);
                    end
                end
            catch e
                close(waitbar_handle);
                h_e = errordlg(['SpO2_PRSAMeasures: ' e.message], 'Input Error');
                if strcmp(DATA.Integration, 'oximetry')
                    setLogo(h_e, 'M_OBM');
                else
                    setLogo(h_e, 'M2');
                end
                rethrow(e);
            end
            
            curr_win_table = SpO2_PRSA;
            curr_win_table.Properties.RowNames{1} = sprintf('W%d', i);
            
            SpO2_PeriodicityMeasures_tables{i} = curr_win_table;
            
            if i == 1
                DATA.PMStat.RowsNames = PMRowsNames;
                DATA.PMStat.RowsNames_NO_GreekLetters = PMRowsNames_NO_GreekLetters;
                DATA.PMStat.Data = [PMDescriptions PMData];
            else
                DATA.PMStat.Data = [DATA.PMStat.Data PMData];
            end
            
            batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
        end
        if ~DATA.GroupsCalc
            updateMainStatisticsTable(DATA.timeStatPartRowNumber + DATA.frequencyStatPartRowNumber + DATA.NonLinearStatPartRowNumber + DATA.ComplexityStatPartRowNumber, DATA.PMStat.RowsNames, DATA.PMStat.Data);
        end
        % Create full table
        DATA.PMStat.SpO2_PM_metrics = vertcat(SpO2_PeriodicityMeasures_tables{:});
        if strcmp(DATA.Integration, 'oximetry')
            descr_str = 'Oximetry periodicity measures for ';
        end
        DATA.PMStat.SpO2_PM_metrics.Properties.Description = sprintf('%s%s', descr_str, DATA.DataFileName);
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
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(waitbar_handle, 'M_OBM');
            else
                setLogo(waitbar_handle, 'M2');
            end
            
            if ~strcmp(DATA.Integration, 'oximetry')
                try
                    calcTimeStatistics(waitbar_handle);
                catch e
                    disp(e);
                    waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(waitbar_handle, 'M_OBM');
                    else
                        setLogo(waitbar_handle, 'M2');
                    end
                end
                try
                    calcFrequencyStatistics(waitbar_handle);
                catch e
                    disp(e);
                    waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(waitbar_handle, 'M_OBM');
                    else
                        setLogo(waitbar_handle, 'M2');
                    end
                end
                try
                    calcNonlinearStatistics(waitbar_handle);
                catch e
                    disp(e);
                    if strcmp(DATA.Integration, 'oximetry')
                        waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(waitbar_handle, 'M_OBM');
                        else
                            setLogo(waitbar_handle, 'M2');
                        end
                    end
                end
                
            else % oximetry
                try
                    %                     if GUI.measures_cb_array(1).Value
                    calcTimeStatistics(waitbar_handle);
                    %                     end
                catch e
                    disp(e);
                    waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(waitbar_handle, 'M_OBM');
                    else
                        setLogo(waitbar_handle, 'M2');
                    end
                end
                try
                    %                     if GUI.measures_cb_array(2).Value
                    calcDesaturationsStatistics(waitbar_handle);
                    %                     end
                catch e
                    disp(e);
                    waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(waitbar_handle, 'M_OBM');
                    else
                        setLogo(waitbar_handle, 'M2');
                    end
                end
                try
                    %                     if GUI.measures_cb_array(3).Value
                    calcNonlinearStatistics(waitbar_handle);
                    %                     end
                catch e
                    disp(e);
                    waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(waitbar_handle, 'M_OBM');
                    else
                        setLogo(waitbar_handle, 'M2');
                    end
                end
                try
                    %                     if GUI.measures_cb_array(6).Value
                    calcComplexityStatistics(waitbar_handle);
                    %                     end
                catch e
                    disp(e);
                    waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(waitbar_handle, 'M_OBM');
                    else
                        setLogo(waitbar_handle, 'M2');
                    end
                end
                try
                    %                     if GUI.measures_cb_array(4).Value
                    calcPeriodicityMeasuresStatistics(waitbar_handle);
                    %                     end
                catch e
                    disp(e);
                end
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
            if ~strcmp(DATA.Integration, 'oximetry')
                plot_time_statistics_results(DATA.active_window);
            else
                plot_general_statistics_results(DATA.active_window);
            end
        end
        
        if ~strcmp(DATA.Integration, 'oximetry')
            if isfield(DATA, 'FrStat') && ~isempty(DATA.FrStat) && isfield(DATA.FrStat, 'WelchWindowsData')
                GUI.FrequencyParametersTable.Data = [strrep(DATA.FrStat.WelchWindowsData.RowsNames,'_WELCH', '') DATA.FrStat.WelchWindowsData.Data(:, DATA.active_window + 1) DATA.FrStat.ArWindowsData.Data(:, DATA.active_window + 1)];
                plot_frequency_statistics_results(DATA.active_window);
            end
        else
            if isfield(DATA, 'FrStat') && ~isempty(DATA.FrStat) && isfield(DATA.FrStat, 'RowsNames')
                GUI.FrequencyParametersTable.Data = [DATA.FrStat.RowsNames DATA.FrStat.Data(:, DATA.active_window + 1)];
                plot_desaturations_results(DATA.active_window);
            end
        end
        
        if isfield(DATA, 'NonLinStat') && ~isempty(DATA.NonLinStat) && isfield(DATA.NonLinStat, 'RowsNames')
            GUI.NonLinearTable.Data = [DATA.NonLinStat.RowsNames DATA.NonLinStat.Data(:, DATA.active_window + 1)];
            plot_nonlinear_statistics_results(DATA.active_window);
        end
        
        if strcmp(DATA.Integration, 'oximetry')
            if isfield(DATA, 'PMStat') && ~isempty(DATA.PMStat) && isfield(DATA.PMStat, 'RowsNames')
                GUI.PMTable.Data = [DATA.PMStat.RowsNames DATA.PMStat.Data(:, DATA.active_window + 1)];
                plot_periodicity_statistics_results(DATA.active_window);
            end
            if isfield(DATA, 'CMStat') && ~isempty(DATA.CMStat) && isfield(DATA.CMStat, 'RowsNames')
                GUI.CMTable.Data = [DATA.CMStat.RowsNames DATA.CMStat.Data(:, DATA.active_window + 1)];
                plot_complexity_results(DATA.active_window);
            end
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
            h_e = errordlg(['Selected window number must be greater than 0 and less than ', num2str(DATA.AnalysisParams.winNum), '!'], 'Input Error');
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(h_e, 'M_OBM');
            else
                setLogo(h_e, 'M2');
            end
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
            DetrendIfNeed_data_chunk();
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
    function window_size_in_data_points = data_points_number()
        blue_line_handle = get(GUI.all_data_handle);
        all_x = blue_line_handle.XData;
        
        window_size_in_data_points = length(find(all_x > DATA.firstSecond2Show & all_x < DATA.firstSecond2Show + DATA.MyWindowSize));
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
        
        direction = 1;
        if callbackdata.VerticalScrollCount > 0
            direction = -1;
        elseif callbackdata.VerticalScrollCount < 0
            direction = 1;
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
                    
                    if direction > 0
                        window_size_in_data_points = data_points_number();
                        if window_size_in_data_points < 6
                            return;
                        end
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
                    
                    AllDataAxes_XLim = get(GUI.AllDataAxes, 'XLim');
                    RRIntPage_Length = max(AllDataAxes_XLim) - min(AllDataAxes_XLim);
                    
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
                DetrendIfNeed_data_chunk();
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
        if max(xdata) - min(xdata) < max(xdata_saved) - min(xdata_saved)
            window_size_in_data_points = data_points_number();
            if window_size_in_data_points < 5
                return;
            end
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
        
        if xdata(2) - xdata(1) < 2
            display_msec = 1;
        else
            display_msec = 0;
        end
        
        set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, display_msec));
        set(GUI.WindowSize,'String', calcDuration(DATA.MyWindowSize, display_msec));
        
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
            DetrendIfNeed_data_chunk();
            plotFilteredData();
            plotMultipleWindows();
            if get(GUI.AutoCalc_checkbox, 'Value')
                calcStatistics();
            end
        end
    end
%%
    function Normalize_STD_checkbox_Callback(src, ~)
        
        mhrv.defaults.mhrv_set_default('mse.normalize_std', get(src, 'Value'));
        
        if get(GUI.AutoCalc_checkbox, 'Value')
            waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(waitbar_handle, 'M_OBM');
            else
                setLogo(waitbar_handle, 'M2');
            end
            calcNonlinearStatistics(waitbar_handle);
            close(waitbar_handle);
        end
    end
%%
    function Relative_checkbox_Callback(src, ~)
        
        rel_val = get(src, 'Value');
        
        mhrv.defaults.mhrv_set_default('ODIMeasures.Relative', rel_val);
        
        
        if rel_val
            GUI.Hard_Threshold.Enable = 'on';
            GUI.ODI_Threshold.Enable = 'off';
            GUI.Desat_Max_Length.Enable = 'off';
        else
            GUI.Hard_Threshold.Enable = 'of';
            GUI.ODI_Threshold.Enable = 'on';
            GUI.Desat_Max_Length.Enable = 'on';
        end
        
        if get(GUI.AutoCalc_checkbox, 'Value')
            waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(waitbar_handle, 'M_OBM');
            else
                setLogo(waitbar_handle, 'M2');
            end
            calcDesaturationsStatistics(waitbar_handle);
            close(waitbar_handle);
        end
    end
%%
    function Detrending_checkbox_Callback(~, ~)
        detrend = get(GUI.Detrending_checkbox, 'Value');
        %         if ~strcmp(DATA.Integration, 'oximetry')
        mhrv.defaults.mhrv_set_default('filtrr.detrending.enable', detrend);
        %         else
        %             mhrv.defaults.mhrv_set_default('filtSpO2.ResampSpO2.enable', detrend);
        %         end
        DATA.Detrending = detrend;
        try
            %             if ~strcmp(DATA.Integration, 'oximetry')
            DetrendIfNeed_data_chunk();
            
            clear_statistics_plots();
            clearStatTables();
            if isfield(GUI, 'filtered_handle')
                set(GUI.filtered_handle, 'XData', ones(1, length(DATA.tnn))*NaN, 'YData', ones(1, length(DATA.nni))*NaN);
            end
            plotFilteredData();
            if get(GUI.AutoCalc_checkbox, 'Value')
                calcStatistics();
            end
            %             else
            %                 if detrend
            %                     DATA.SpO2NewSamplingFrequency = DATA.custom_filters_thresholds.ResampSpO2.Original_fs;
            %                 else
            %                     DATA.SpO2NewSamplingFrequency = DATA.default_filters_thresholds.ResampSpO2.Original_fs;
            %                 end
            %
            %                 if isfield(GUI, 'raw_data_handle') && ishandle(GUI.raw_data_handle) && isvalid(GUI.raw_data_handle)
            %                     delete(GUI.raw_data_handle);
            %                 end
            % %                 if get(GUI.AutoCalc_checkbox, 'Value')
            %                     reset_plot_Data();
            %                     reset_plot_GUI();
            %                     EnablePageUpDown();
            % %                 end
            %             end
        catch e
            if ~strcmp(DATA.Integration, 'oximetry')
                error_text = 'Detrending_checkbox_Callback Error: ';
            else
                error_text = 'Resampling_checkbox_Callback Error: ';
            end
            h_e = errordlg([error_text e.message], 'Input Error');
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(h_e, 'M_OBM');
            else
                setLogo(h_e, 'M2');
            end
            return;
        end
    end
%%
    function [nni_detrended_trans, nni_detrended] = detrend_data(nni)
        try
            lambda = mhrv.defaults.mhrv_get_default('filtrr.detrending.lambda');
            %             nni_detrended_trans = mhrv.rri.detrendrr(nni, lambda.value, DATA.SamplingFrequency);
            
            waitbar_handle = waitbar(0, 'Detrending', 'Name', 'Working on it...'); setLogo(waitbar_handle, 'M1');
            nni_detrended_trans = split_detrend(nni, lambda.value, DATA.SamplingFrequency, waitbar_handle);
            if isvalid(waitbar_handle)
                close(waitbar_handle);
            end
            
            nni_detrended = nni - nni_detrended_trans;
            nni_detrended_trans = nni_detrended_trans + mean(nni);
        catch
            throw(MException('detrend_data:error', 'Detrending error.'));
        end
    end
%%
    function DetrendIfNeed_data_chunk()
        if ~strcmp(DATA.Integration, 'oximetry')
            if isfield(DATA, 'AnalysisParams') && isfield(DATA.AnalysisParams, 'segment_startTime')
                Filt_time_data = DATA.tnn;
                Filt_data = DATA.nni_saved;
                %           Filt_data = DATA.nni;
                
                filt_win_indexes = find(Filt_time_data >= DATA.AnalysisParams.segment_startTime & Filt_time_data <= DATA.AnalysisParams.segment_effectiveEndTime);
                
                if ~isempty(filt_win_indexes)
                    %                 filt_signal_data = Filt_data(filt_win_indexes(1) : filt_win_indexes(end));
                    filt_signal_data = Filt_data(filt_win_indexes);
                    try
                        if DATA.Detrending
                            [data2calc, data2plot] = detrend_data(filt_signal_data);
                            GUI.filtered_handle.LineWidth = 1.5;
                            GUI.filtered_handle.Color = 'red';
                            uistack(GUI.filtered_handle, 'top');
                            %                         DATA.legend_handle.String
                            if isfield(GUI, 'PinkLineHandle') && isvalid(GUI.PinkLineHandle(1)) && length(DATA.legend_handle.String) == 3
                                legend([GUI.raw_data_handle, GUI.only_filtered_handle, GUI.filtered_handle, GUI.PinkLineHandle(1)], [DATA.legend_handle.String(1:end-1), 'Detrended time series', DATA.legend_handle.String(end)]);
                            elseif length(DATA.legend_handle.String) == 2
                                legend([GUI.raw_data_handle, GUI.only_filtered_handle, GUI.filtered_handle], [DATA.legend_handle.String, 'Detrended time series']);
                            end
                        else
                            data2plot = filt_signal_data;
                            data2calc = filt_signal_data;
                            GUI.filtered_handle.LineWidth = 1;
                            GUI.filtered_handle.Color = 'green';
                            %                         DATA.legend_handle.String
                            if isfield(GUI, 'PinkLineHandle') && isvalid(GUI.PinkLineHandle(1)) && length(DATA.legend_handle.String) == 4
                                legend([GUI.raw_data_handle, GUI.filtered_handle, GUI.PinkLineHandle(1)], [DATA.legend_handle.String(1 : end - 2), DATA.legend_handle.String(end)]);
                            elseif ~isfield(GUI, 'PinkLineHandle') && length(DATA.legend_handle.String) > 2
                                legend([GUI.raw_data_handle, GUI.filtered_handle], DATA.legend_handle.String(1 : end - 1));
                            elseif  length(DATA.legend_handle.String) > 2
                                legend([GUI.raw_data_handle, GUI.filtered_handle], DATA.legend_handle.String(1 : end - 1));
                            end
                        end
                    catch
                        throw(MException('FiltSignal:Detrending', 'Detrending error.'));
                    end
                    DATA.nni(filt_win_indexes) = data2plot;
                    DATA.nni4calc(filt_win_indexes) = data2calc;
                end
            end
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
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(waitbar_handle, 'M_OBM');
            else
                setLogo(waitbar_handle, 'M2');
            end
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
        
        setLogo(GUI.EstimateLFBandWindow, 'M2');
        
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
            h_e = errordlg(['Typical ' rate ' Rate must be greater than '  num2str(min_val) ' BPM and less than ' num2str(max_val) ' BPM!'], 'Input Error');
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(h_e, 'M_OBM');
            else
                setLogo(h_e, 'M2');
            end
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
                
                prev_vlf = mhrv.defaults.mhrv_get_default('hrv_freq.vlf_band');
                prev_lf = mhrv.defaults.mhrv_get_default('hrv_freq.lf_band');
                prev_hf = mhrv.defaults.mhrv_get_default('hrv_freq.hf_band');
                beta_band = mhrv.defaults.mhrv_get_default('hrv_freq.beta_band');
                
                mhrv.defaults.mhrv_set_default('hrv_freq.hf_band', [f_LF_HF f_HF_up]);
                mhrv.defaults.mhrv_set_default('hrv_freq.lf_band', [f_VLF_LF f_LF_HF]);
                mhrv.defaults.mhrv_set_default('hrv_freq.vlf_band', [prev_vlf.value(1) f_VLF_LF]);
                mhrv.defaults.mhrv_set_default('hrv_freq.beta_band', [prev_vlf.value(1) f_VLF_LF]);
                
                if get(GUI.AutoCalc_checkbox, 'Value')
                    try
                        update_statistics('hrv_freq');
                    catch e
                        h_e = errordlg(['ok_estimate_button_Callback error: ' e.message], 'Input Error');
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(h_e, 'M_OBM');
                        else
                            setLogo(h_e, 'M2');
                        end
                        
                        mhrv.defaults.mhrv_set_default('hrv_freq.hf_band', prev_hf);
                        mhrv.defaults.mhrv_set_default('hrv_freq.lf_band', prev_lf);
                        mhrv.defaults.mhrv_set_default('hrv_freq.vlf_band', prev_vlf);
                        mhrv.defaults.mhrv_set_default('hrv_freq.beta_band', beta_band);
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
                
                prev_pnn_thresh = mhrv.defaults.mhrv_get_default(param_name);
                mhrv.defaults.mhrv_set_default(param_name, xx);
                
                if get(GUI.AutoCalc_checkbox, 'Value')
                    try
                        update_statistics('hrv_time');
                    catch e
                        h_e = errordlg(['ok_estimate_button_Callback error: ' e.message], 'Input Error');
                        if strcmp(DATA.Integration, 'oximetry')
                            setLogo(h_e, 'M_OBM');
                        else
                            setLogo(h_e, 'M2');
                        end
                        mhrv.defaults.mhrv_set_default(param_name, prev_pnn_thresh);
                        delete(GUI.EstimateLFBandWindow);
                        return;
                    end
                end
                set(GUI.ConfigParamHandlesMap(param_name), 'String', num2str(xx), 'UserData', num2str(xx));
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
    function ShowFilteredData_checkbox_Callback(src, ~)
        if isfield(GUI, 'filtered_handle') && ishandle(GUI.filtered_handle) && isvalid(GUI.filtered_handle)
            GUI.filtered_handle.Visible = src.Value;
        end
        if isfield(GUI, 'only_filtered_handle') && ishandle(GUI.only_filtered_handle) && isvalid(GUI.only_filtered_handle)
            GUI.only_filtered_handle.Visible = src.Value;
        end
    end
%%
    function ShowRawData_checkbox_Callback(src, ~)
        GUI.raw_data_handle.Visible = src.Value;
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
        PhysioZooGUIPulse();
    end
%%
    function build_OBM_Tab()
        
        GUI.OBMSclPanel = uix.ScrollingPanel( 'Parent', GUI.OBMTab);
        GUI.OBMBox = uix.VBox( 'Parent', GUI.OBMSclPanel, 'Spacing', DATA.Spacing);
        set(GUI.OBMSclPanel, 'Widths', GUI.OptionsSclPanel.Widths, 'Heights', GUI.OptionsSclPanel.Heights );
        
        uicontrol('Style', 'text', 'Parent', GUI.OBMBox, 'FontSize', DATA.BigFontSize, 'FontWeight', 'Bold', 'String', 'Compute Measures:', 'HorizontalAlignment', 'left');
        uix.Empty('Parent', GUI.OBMBox);
        GUI.measures_cb_array(1) = uicontrol('Style', 'checkbox', 'Parent', GUI.OBMBox, 'String', 'General');
        GUI.measures_cb_array(2) = uicontrol('Style', 'checkbox', 'Parent', GUI.OBMBox, 'String', 'Desaturations & Hypoxic Burden');
        %         GUI.measures_cb_array(3) = uicontrol('Style', 'checkbox', 'Parent', GUI.OBMBox, 'String', 'Hypoxic Burden');
        GUI.measures_cb_array(3) = uicontrol('Style', 'checkbox', 'Parent', GUI.OBMBox, 'String', 'Periodicity');
        GUI.Complexity_CB = uicontrol('Style', 'checkbox', 'Parent', GUI.OBMBox, 'String', 'Complexity (heavy algorithms, may takes some additional time)', 'FontSize', DATA.BigFontSize, 'Value', 0, 'Callback', @Complexity_CB_Callback);
        uix.Empty('Parent', GUI.OBMBox);
        
        hB = uix.HBox( 'Parent', GUI.OBMBox, 'Spacing', DATA.Spacing);
        uix.Empty('Parent', hB);
        GUI.measures_cb_array(4) = uicontrol('Style', 'checkbox', 'Parent', hB, 'String', 'DFA');
        set(hB, 'Width', [-0.5 -10]);
        
        hB = uix.HBox( 'Parent', GUI.OBMBox, 'Spacing', DATA.Spacing);
        uix.Empty('Parent', hB);
        GUI.measures_cb_array(5) = uicontrol('Style', 'checkbox', 'Parent', hB, 'String', 'LZ');
        set(hB, 'Width', [-0.5 -10]);
        
        hB = uix.HBox( 'Parent', GUI.OBMBox, 'Spacing', DATA.Spacing);
        uix.Empty('Parent', hB);
        GUI.measures_cb_array(6) = uicontrol('Style', 'checkbox', 'Parent', hB, 'String', 'CTM');
        set(hB, 'Width', [-0.5 -10]);
        
        hB = uix.HBox( 'Parent', GUI.OBMBox, 'Spacing', DATA.Spacing);
        uix.Empty('Parent', hB);
        GUI.measures_cb_array(7) = uicontrol('Style', 'checkbox', 'Parent', hB, 'String', 'SampEn');
        set(hB, 'Width', [-0.5 -10]);
        
        hB = uix.HBox( 'Parent', GUI.OBMBox, 'Spacing', DATA.Spacing);
        uix.Empty('Parent', hB);
        GUI.measures_cb_array(8) = uicontrol('Style', 'checkbox', 'Parent', hB, 'String', 'ApEn');
        set(hB, 'Width', [-0.5 -10]);
        
        uix.Empty('Parent', GUI.OBMBox);
        
        set(GUI.OBMBox, 'Heights', [-1 -0.5 -1 -1 -1 -1 -0.5 -1 -1 -1 -1 -1 -7]);
        
        for i = 1 : length(GUI.measures_cb_array)
            GUI.measures_cb_array(i).Callback = {@calc_spesific_measure, i};
            GUI.measures_cb_array(i).FontSize = DATA.BigFontSize;
            GUI.measures_cb_array(i).Value = 1;
        end
        
        GUI.measures_cb_array(8).Value = 0;
        
        set(findobj(GUI.OBMSclPanel, 'Type', 'uicontainer'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(GUI.OBMSclPanel, 'Type', 'UIControl'), 'BackgroundColor', myUpBackgroundColor);
    end
%%
    function calc_spesific_measure(src, ~, measure_num)
        
        comp_mes_cb = [GUI.measures_cb_array(4:8).Value];
        
        if sum(comp_mes_cb) == length(comp_mes_cb)
            GUI.Complexity_CB.Value = 1;
        elseif sum(comp_mes_cb) == 0
            GUI.Complexity_CB.Value = 0;
        end
        
        if src.Value
            if measure_num == 1
                param_category = 'OveralGeneralMeasures';
            elseif measure_num == 2
                param_category = 'ODI_HypoxicBurdenMeasures';
                %             elseif measure_num == 3
                %                 param_category = 'HypoxicBurdenMeasures';
            elseif measure_num == 3
                param_category = 'PeriodicityMeasures';
            elseif measure_num == 4 || measure_num == 5 || measure_num == 6  || measure_num == 7 || measure_num == 8
                param_category = 'ComplexityMeasures';
            end
            if get(GUI.AutoCalc_checkbox, 'Value')
                try
                    update_statistics(param_category);
                catch e
                    h_e = errordlg(['calc_spesific_measure error: ' e.message], 'Input Error');
                    if strcmp(DATA.Integration, 'oximetry')
                        setLogo(h_e, 'M_OBM');
                    else
                        setLogo(h_e, 'M2');
                    end
                    src.Value = 0;
                end
            end
        else
            %             if measure_num == 1
            %                 clear_time_statistics_results(GUI);
            %                 GUI.TimeParametersTable.Data = [];
            %                 DATA.timeStatPartRowNumber = 0;
            %             elseif measure_num == 2
            %                 clear_frequency_statistics_results(GUI);
            %                 GUI.FrequencyParametersTable.Data = [];
            %                 DATA.frequencyStatPartRowNumber = 0;
            %             elseif measure_num == 3
            %                 clear_nonlinear_statistics_results(GUI);
            %                 GUI.NonLinearTable.Data = [];
            %                 DATA.NonLinearStatPartRowNumber = 0;
            %             elseif measure_num == 4
            %                 clear_complexity_statistics_results(GUI);
            %                 GUI.CMTable.Data = [];
            %                 DATA.ComplexityStatPartRowNumber = 0;
            %             elseif measure_num == 5
            %                 clear_periodicity_statistics_results(GUI);
            %                 GUI.PMTable.Data = [];
            %             end
        end
    end
%%
    function Complexity_CB_Callback(src, ~ )
        for i = 4 : 8
            GUI.measures_cb_array(i).Value = src.Value;
        end
    end
%%
    function Median_checkbox_Callback(src, ~)
        %         disp('Median');
        try
            update_statistics('filtSpO2');
        catch
            h_e = errordlg(['Median_checkbox_Callback error: ' e.message], 'Input Error');
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(h_e, 'M_OBM');
            else
                setLogo(h_e, 'M2');
            end
            src.Value = ~src.Value;
            update_statistics('filtSpO2');
        end
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
            h_e = errordlg('Please, choose unique group name.', 'Input Error');
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(h_e, 'M_OBM');
            else
                setLogo(h_e, 'M2');
            end
            return;
        end
        if ~isfield(DATA.Group.Path, 'CurrentDir')   %% Need to check if Path is exist!!!!!!!!!!!!!
            h_e = errordlg('Please, choose directiry name and files first.', 'Input Error');
            if strcmp(DATA.Integration, 'oximetry')
                setLogo(h_e, 'M_OBM');
            else
                setLogo(h_e, 'M2');
            end
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
        DATA.Group.Groups(end).Ext = DATA.Group.Path.CurrentExt;
        
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
        strExts = get(GUI.Group.pmFileType, 'String');
        
        DATA.Group.CurrentName = cell2mat(strGroups(valGroups));
        set(GUI.Group.ebName, 'String', DATA.Group.CurrentName);
        iGroup = ismember( {DATA.Group.Groups.Name}', DATA.Group.CurrentName);
        if ~isempty(DATA.Group.Groups(iGroup))
            DATA.Group.Path.CurrentDir = DATA.Group.Groups(iGroup).Path;
            DATA.Group.Path.CurrentExt = DATA.Group.Groups(iGroup).Ext;
            [iPath, ~] = find((ismember( strDirs, DATA.Group.Path.CurrentDir)));
            [iExt, ~] = find((ismember( strExts, DATA.Group.Path.CurrentExt)));
            set(GUI.Group.pmWorkDir, 'Value', iPath);
            set(GUI.Group.pmFileType, 'Value', iExt);
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
        
        strExt = get(GUI.Group.pmFileType, 'String');
        valExt = get(GUI.Group.pmFileType, 'Value');
        
        DATA.Group.Path.CurrentDir = cell2mat(strDirs(valDirs));
        DATA.Group.Path.CurrentExt = cell2mat(strExt(valExt));
        
        DIRS.DataBaseDirectory = DATA.Group.Path.CurrentDir;
        DIRS.Ext_group = DATA.Group.Path.CurrentExt; % ???????????
        
        %         curr_ext = DATA.Group.Path.AllExts{valDirs};
        
        dr = dir([DATA.Group.Path.CurrentDir, '\*.' DATA.Group.Path.CurrentExt]);
        set(GUI.Group.lbMembers, 'String', {dr.name}, 'Value', 1);
        
        %         set(GUI.Group.pmFileType, 'Value', valDirs);
    end
%%
    function Members_listbox_Callback(~,~)
        switch get(GUI.Window,'selectiontype')
            case 'normal'
            case 'open'
                strFiles = get(GUI.Group.lbMembers,'str');
                valFiles = get(GUI.Group.lbMembers,'value');
                clearStatTables();
                %                 Load_Calc(cell2mat(strFiles(valFiles)), [DATA.Group.Path.CurrentDir,'\']);
                
                
                Load_Single_File(cell2mat(strFiles(valFiles)), [DATA.Group.Path.CurrentDir,'\'], struct());
                
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
        
        if ~isfield(DIRS, 'DataBaseDirectory')
            DIRS.DataBaseDirectory = basepath;
        end
        
        tempPath = uigetdir([DIRS.DataBaseDirectory]);
        if tempPath
            DATA.Group.Path.CurrentDir = tempPath;
            DIRS.DataBaseDirectory = tempPath;
            
            DATA.Group.Path.CurrentExt = DIRS.Ext_group;
        else
            return
        end
        dr = dir([DATA.Group.Path.CurrentDir, '\*.' DIRS.Ext_group]);
        set(GUI.Group.lbMembers, 'String', {dr.name}, 'Value', 1);
        
        if ~isfield(DATA.Group.Path, 'AllDirs')
            DATA.Group.Path.AllDirs = [];
        end
        
        DATA.Group.Path.AllDirs = unique(sort([DATA.Group.Path.AllDirs; {DATA.Group.Path.CurrentDir}]));
        %         DATA.Group.Path.AllExts = (sort([DATA.Group.Path.AllExts; {DIRS.Ext_group}]));
        
        [ind, ~] = find(strcmp(DATA.Group.Path.AllDirs, DATA.Group.Path.CurrentDir));
        set(GUI.Group.pmWorkDir, 'String', DATA.Group.Path.AllDirs, 'Value', ind);
        
        %         [ind, ~] = find(strcmp(DATA.Group.Path.AllExts, DIRS.Ext_group));
        %         set(GUI.Group.pmFileType, 'Value', ind);
    end
%%
    function FileType_popupmenu_Callback(src, ~)
        items = get(src, 'String');
        DATA.file_types_index = get(src, 'Value');
        DIRS.Ext_group = items{DATA.file_types_index};
        LoadGroupDir_popupmenu_Callback();
    end
%%
%     function onLoadGroupConfigFile(~, ~)
%         conf_name = onLoadCustomConfigFile();
%         set(GUI.GroupsConfig_text, 'String', conf_name);
%     end
%%
    function Load_Calc(curr_file_name, curr_path)
        
        waitbar_handle = waitbar(1/2, 'Loading data', 'Name', 'Working on it...');
        if strcmp(DATA.Integration, 'oximetry')
            setLogo(waitbar_handle, 'M_OBM');
        else
            setLogo(waitbar_handle, 'M2');
        end
        [mammal, mammal_index, integration, whichModule] = Load_Data_from_SingleFile(curr_file_name, curr_path, struct(), waitbar_handle);
        
        if ~isfield(GUI, 'ConfigParamHandlesMap')
            mhrv.defaults.mhrv_load_defaults(DATA.mammals{DATA.mammal_index});
        end
        
        set_default_values();
        
        FiltSignal();
        DetrendIfNeed_data_chunk();
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
                    %                     Load_Calc(curr_file_name, curr_path);
                    Load_Single_File(curr_file_name, curr_path, struct());
                    
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
                stats_tables{gr} = mhrv.util.table_stats(rec_type_table);
                
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
    function delete_temp_files()
        if exist([tempdir 'temp.dat'], 'file')
            delete([tempdir 'temp.dat']);
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
        delete_temp_files();
        delete( GUI.Window );
    end % onExit
end % EOF