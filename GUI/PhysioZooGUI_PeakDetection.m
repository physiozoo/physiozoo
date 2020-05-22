function PhysioZooGUI_PeakDetection(fileNameFromM2, DataFileMapFromM2)

myUpBackgroundColor = [205 237 240]/255; % Blue %[0.863 0.941 0.906]; % [219 237 240]/255
myLowBackgroundColor = [205 237 240]/255; %[219 237 240]/255
myEditTextColor = [1 1 1];
mySliderColor = [0.8 0.9 0.9];
myPushButtonColor = [0.26 0.37 0.41];

clearData();
DATA = createData();
GUI = createInterface();
if nargin >= 1
    OpenFile_Callback([], [], fileNameFromM2, DataFileMapFromM2);
end
%%
    function clearHandles()
        GUI.RRInt_handle = [];
        GUI.RawData_handle = [];
        GUI.red_peaks_handle = [];
        GUI.red_rect_handle = [];
        GUI.del_rect_handle = [];
    end
%%
    function clearData()
        
        DATA.peaks_added = 0;
        DATA.peaks_deleted = 0;
        DATA.peaks_total = 0;
        DATA.peaks_bad_quality = 0;
        
        DATA.DataFileName = '';
        DATA.peaks_file_name = '';
        DATA.rec_name = '';
        DATA.ecg_channel = '';
        DATA.tm = [];
        DATA.sig = [];
        DATA.Fs = 0;
        DATA.qrs = [];
        DATA.qrs_saved = [];
        DATA.Adjust = 0;
        
        DATA.Mammal = '';
        %         DATA.mammal_index = 1;
        
        DATA.Integration = '';
        DATA.integration_index = 1;
        
        DATA.peakDetector = '';
        DATA.peakDetector_index = 1;
        
        DATA.config_map = containers.Map;
        DATA.config_struct = struct;
        DATA.customConfigFile = '';
        DATA.wfdb_record_name = '';
        
        %         DATA.peak_search_win = 100;
        
        DATA.PlotHR = 0;
        
        DATA.maxRRTime = 0;
        
        DATA.prev_point_ecg = 0;
        DATA.prev_point = 0;
        
        DATA.RRIntPage_Length = 0;
        
        DATA.quality_win_num = 0;
        DATA.rhythms_win_num = 0;
        
        DATA.rr_data_filtered = [];
        DATA.rr_time_filtered = [];
        
        DATA.Rhythms_Map = containers.Map('KeyType', 'double', 'ValueType', 'any');        
    end
%%
    function clean_gui()
        
        cla(GUI.ECG_Axes); % RawData_axes
        cla(GUI.RRInt_Axes); % RR_axes
        
        if isfield(GUI, 'quality_win')
            delete(GUI.quality_win);
            GUI = rmfield(GUI, 'quality_win');
        end
        
        if isfield(GUI, 'rhythms_win')
            delete(GUI.rhythms_win);
            GUI = rmfield(GUI, 'rhythms_win');
        end
        
        if isfield(GUI, 'PinkLineHandle_AllDataAxes')
            delete(GUI.PinkLineHandle_AllDataAxes);
            GUI = rmfield(GUI, 'PinkLineHandle_AllDataAxes');
        end
        
        if isfield(GUI, 'RhythmsHandle_AllDataAxes')
            delete(GUI.RhythmsHandle_AllDataAxes);
            GUI = rmfield(GUI, 'RhythmsHandle_AllDataAxes');
        end
        
        set(GUI.GUIRecord.RecordFileName_text, 'String', '');
        set(GUI.GUIRecord.PeaksFileName_text, 'String', '');
        set(GUI.GUIRecord.DataQualityFileName_text, 'String', '');
        set(GUI.GUIRecord.RhythmsFileName_text, 'String', '');
        set(GUI.GUIRecord.Config_text, 'String', '');
        set(GUI.GUIRecord.TimeSeriesLength_text, 'String', '');
        
        set(GUI.GUIDisplay.RRIntPage_Length, 'String', '');
        set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'String', '');
        set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'String', '');
        
        set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'UserData', []);
        set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'UserData', []);
        
        set(GUI.GUIDisplay.FirstSecond, 'String', '');
        set(GUI.GUIDisplay.WindowSize, 'String', '');
        
        set(GUI.GUIDisplay.MinYLimit_Edit, 'String', '');
        set(GUI.GUIDisplay.MaxYLimit_Edit, 'String', '');
        
        set(GUI.GUIDisplay.MinYLimit_Edit, 'UserData', '');
        set(GUI.GUIDisplay.MaxYLimit_Edit, 'UserData', '');
        
        GUI.AutoPeakWin_checkbox.Value = 1;
        set(GUI.GUIConfig.PeaksWindow, 'String', '');
        
        GUI.GUIRecord.Annotation_popupmenu.Value = 1;
        
        GUI.GUIRecord.Class_popupmenu.Visible = 'off';
        GUI.Class_Text.Visible = 'off';
        GUI.GUIRecord.Class_popupmenu.Value = 3;
        
        GUI.GUIRecord.Rhythms_popupmenu.Visible = 'off';
        GUI.Rhythms_Text.Visible = 'off';
        GUI.GUIRecord.Rhythms_popupmenu.Value = 1;
        
        GUI.GUIRecord.PeakAdjustment_popupmenu.Visible = 'on';
        GUI.Adjustment_Text.Visible = 'on';
        GUI.GUIRecord.PeakAdjustment_popupmenu.Value = 1;
        
        set(GUI.Adjust_textBox, 'Position', GUI.Adjust_textBox_position);
        set(GUI.Class_textBox, 'Position', GUI.Class_textBox_position);
        set(GUI.Rhythms_textBox, 'Position', GUI.Rhythms_textBox_position);
        
        title(GUI.ECG_Axes, '');
        
        set(GUI.GUIRecord.Mammal_popupmenu, 'String', '');
        set(GUI.GUIRecord.PeakDetector_popupmenu, 'Value', 1);
        
        GUI.LoadConfigurationFile.Enable = 'off';
        GUI.SaveConfigurationFile.Enable = 'off';
        GUI.SavePeaks.Enable = 'off';
        
        GUI.SaveRhythms.Enable = 'off';
        GUI.OpenRhythms.Enable = 'off';
        
        GUI.SaveDataQuality.Enable = 'off';
        GUI.OpenDataQuality.Enable = 'off';
        
        GUI.SaveFiguresFile.Enable = 'off';
        GUI.GUIRecord.PeaksFileName_text_pushbutton_handle.Enable = 'off';
        GUI.GUIRecord.Config_text_pushbutton_handle.Enable = 'off';
        GUI.GUIRecord.DataQualityFileName_text_pushbutton_handle.Enable = 'off';
        GUI.GUIRecord.RhythmsFileName_text_pushbutton_handle.Enable = 'off';
                
        GUI.RhythmsTable.Data = {};
        GUI.RhythmsTable.RowName = {};
        DATA.Rhythms_file_name = '';
        set(GUI.GUIRecord.RhythmsFileName_text, 'String', '');
        
        DATA.Action = 'move';
        
        set(GUI.Window, 'WindowButtonMotionFcn', '');
        set(GUI.Window, 'WindowButtonUpFcn', '');
        set(GUI.Window, 'WindowButtonDownFcn', '');
        set(GUI.Window, 'WindowScrollWheelFcn', '');
        set(GUI.Window, 'WindowKeyPressFcn', '');
        set(GUI.Window, 'WindowKeyReleaseFcn', '');
        if isfield(GUI, 'timer_object')
            delete(GUI.timer_object);
        end
        
        reset_movie_buttons();
        GUI.GUIDisplay.Movie_Delay.String = 2;
        
        GUI.AutoScaleY_checkbox.Value = 1;
        GUI.AutoScaleYLowAxes_checkbox.Value = 1;
        GridX_checkbox_Callback();
        %         GridY_checkbox_Callback();
        GUI.RawSignal_checkbox.Value = 1;
        GUI.FilteredSignal_checkbox.Value = 0;
        GUI.GUIDisplay.FilterLevel_popupmenu.Value = 1;
        %         GUI.GUIDisplay.LowCutoffFr_Edit.String = 0.5;
        %         GUI.GUIDisplay.HightCutoffFr_Edit.String = 100;
        %         GUI.GUIDisplay.LowCutoffFr_Edit.UserData = 0.5;
        %         GUI.GUIDisplay.HightCutoffFr_Edit.UserData = 100;
        GUI.FilterLevelBox.Visible = 'off';
        GUI.CutoffFrBox.Visible = 'off';
        
        set_default_filter_level_user_data();
        
        reset_rhythm_button();
        GUI.RhythmsHBox.Visible = 'off';
        Rhythms_ToggleButton_Reset();
    end
%%
    function DATA = createData()
        
        DATA.screensize = get( 0, 'Screensize' );
        
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
        
        DATA.mammals = {'human', 'dog', 'rabbit', 'mouse', 'default'};
        %         DATA.mammals = {'', 'human', 'dog', 'rabbit', 'mouse', 'custom'};
        %         DATA.GUI_mammals = {'Please, choose mammal'; 'Human'; 'Dog'; 'Rabbit'; 'Mouse'; 'Custom'};
        %         DATA.mammal_index = 1;
        
        DATA.Integration_From_Files = {'electrocardiogram'; 'electrogram'; 'action potential'};
        DATA.GUI_Integration = {'ECG'; 'Electrogram'; 'Action Potential'};
        DATA.integration_level = {'ecg'; 'electrogram'; 'ap'};
        
        DATA.GUI_PeakDetector = {'rqrs'; 'jqrs'; 'wjqrs'; 'EGM peaks'}; % 'EGM peaks'
        DATA.peakDetector_index = 1;
        
        DATA.GUI_Annotation = {'Peak'; 'Signal quality'; 'Rhythms'};
        DATA.GUI_Class = {'A'; 'B'; 'C'};
        DATA.Adjustment_type = {'Default'; 'Local max'; 'Local min'};
        DATA.Rhythms_Type = {'AB'; 'AFIB'; 'AFL'; 'SVTA';...
            'B'; 'T'; 'IVR'; 'VFL'; 'VT';...
            'SBR'; 'BII'; 'NOD';...
            'P'; 'PREX';...
            'J'; 'PAT'; 'AT'; 'VTS'; 'AIVRS'; 'IVRS'; 'AIVR'}; % 'N'
        
        %         rec_colors = lines(5);
        %         DATA.quality_color = {rec_colors(5, :); rec_colors(3, :); rec_colors(2, :)};
        
        DATA.quality_color = {[140 228 140]/255; [255 220 169]/255; [255 200 200]/255};
        
        %         DATA.rhythms_color = {[41 202 255]/255; ...
        %             [249 68 255]/255; ...
        %             [25 4 255]/255; ... % 88 66 255
        %             [255 48 6]/255; ... % 40 255 76
        %             [255 0 0]/255; ... % 255 27 50
        %
        %             [101 196 255]/255; ...
        %             [255 128 242]/255; ...
        %             [97 83 255]/255; ... % 158 126 255
        %             [255 119 82]/255; ... % 100 255 147
        %             [255 79 79]/255; ... % 255 93 87
        %
        %             [139 199 255]/255; ...
        %             [255 166 237]/255; ...
        %             [170 162 255]/255; ... % 196 164 255
        %             [255 150 124]/255; ... % 138 255 185
        %             [255 158 158]/255; ...
        %
        %             [139 199 255]/255; ...
        %             [139 199 255]/255; ...
        %             [139 199 255]/255; ... % 196 164 255
        %             [139 199 255]/255; ... % 138 255 185
        %             [139 199 255]/255;...
        %
        %             [139 199 255]/255; ... % 138 255 185
        %             [139 199 255]/255}; % 255 142 125
        
        DATA.rhythms_color = {[240 124 0]/255; ...
            [255 227 18]/255; ...
            [242 146 129]/255; ... % 88 66 255
            [255 197 7]/255; ... % 40 255 76
            
            [255 68 168]/255; ... % 255 27 50
            [209 17 164]/255; ...
            [112 25 86]/255; ...
            [203 13 255]/255; ... % 158 126 255
            [147 16 235]/255; ... % 100 255 147
            
            [89 106 255]/255; ... % 255 93 87
            [29 21 255]/255; ...
            [46 11 173]/255; ...
            
            [15 255 255]/255; ... % 196 164 255
            [3 188 255]/255; ... % 138 255 185
            
            [67 143 36]/255; ...
            [46 230 18]/255; ...
            [145 186 149]/255; ...
            [76 235 139]/255; ... % 196 164 255
            
            [149 230 106]/255; ... % 138 255 185
            [127 235 199]/255;...
            [33 237 196]/255}; % 255 142 125
        
        
        DATA.rhythms_tooltip = {'Atrial bigeminy'; ...
            'Atrial fibrillation'; ...
            'Atrial flutter'; ...
            'Supraventricular tachyarrhythmia'; ...
            
            'Ventricular bigeminy'; ...
            'Ventricular trigeminy'; ...
            'Idioventricular rhythm'; ...
            'Ventricular flutter'; ...
            'Ventricular tachycardia'; ...
            
            'Sinus bradycardia'; ...
            '2° heart block'; ...
            'Nodal (A-V junctional) rhythm'; ...
            
            'Paced rhythm'; ...
            'Pre-excitation (WPW)'...;
            
            ''; ...
            ''; ...
            ''; ...
            ''; ...
            ''; ...
            ''; ...
            ''};
        
        DATA.temp_rec_name4wfdb = 'temp_ecg_wfdb';
        
        DATA.Spacing = 3;
        DATA.Padding = 3;
        
        DATA.firstZoom = 60; % sec
        DATA.zoom_rect_limits = [0 DATA.firstZoom];
    end
%% Open the window
    function GUI = createInterface()
        SmallFontSize = DATA.SmallFontSize;
        BigFontSize = DATA.BigFontSize;
        GUI = struct();
        GUI.Window = figure( ...
            'Name', 'PhysioZoo_PeakDetection', ...
            'NumberTitle', 'off', ...
            'HandleVisibility', 'callback', ...
            'Toolbar', 'none', ...
            'MenuBar', 'none', ...
            'Position', [20, 50, DATA.window_size(1), DATA.window_size(2)], ...
            'Tag', 'fPhysioZooPD');
        
        
        set(GUI.Window, 'CloseRequestFcn', {@Exit_Callback});
        
        setLogo(GUI.Window, 'M1');
        %         warning('off');
        %         javaFrame = get(GUI.Window,'JavaFrame');
        %         javaFrame.setFigureIcon(javax.swing.ImageIcon([fileparts(fileparts(mfilename('fullpath'))) filesep 'GUI' filesep 'Logo' filesep 'logoBlue.png']));
        %         warning('on');
        
        %         set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
        %         set(GUI.Window, 'WindowButtonUpFcn', @my_WindowButtonUpFcn);
        %         set(GUI.Window, 'WindowButtonDownFcn', @my_WindowButtonDownFcn);
        
        
        % 'Toolbar', 'none', ...
        % 'HandleVisibility', 'off', ...
        % 'MenuBar', 'none', ...
        %         set(GUI.Window, 'MenuBar', 'none', 'Toolbar', 'figure');
        %         a = findall(GUI.Window);
        %         set(findall(a,'Type','uipushtool'),'Visible','Off');
        % %         set(findall(a,'Type','ToggleSplitTool'),'Visible','Off');
        %
        %         set(findall(a,'TooltipString','Rotate 3D'),'Visible','Off');
        %         set(findall(a,'TooltipString','Brush/Select Data'),'Visible','Off');
        %         set(findall(a,'TooltipString','Link Plot'),'Visible','Off');
        %         set(findall(a,'TooltipString','Insert Colorbar'),'Visible','Off');
        %         set(findall(a,'TooltipString','Insert legend'),'Visible','Off');
        %         set(findall(a,'TooltipString','Insert Legend'),'Visible','Off');
        %         set(findall(a,'TooltipString','Edit Plot'),'Visible','Off');
        
        
        %         uitoolbar_handle = uitoolbar('Parent', GUI.Window);
        %         C = uitoolfactory(uitoolbar_handle, 'Exploration.ZoomIn');
        % %         C.Separator = 'on';
        %         C = uitoolfactory(uitoolbar_handle, 'Exploration.ZoomOut');
        %         C = uitoolfactory(uitoolbar_handle, 'Exploration.Pan');
        %         C = uitoolfactory(uitoolbar_handle, 'Exploration.DataCursor');
        %         %         C = uitoolfactory(H,'Standard.EditPlot');
        
        % + File menu
        GUI.FileMenu = uimenu( GUI.Window, 'Label', 'File' );
        uimenu( GUI.FileMenu, 'Label', 'Open data file', 'Callback', @OpenFile_Callback, 'Accelerator', 'O');
        
        GUI.LoadPeaks = uimenu( GUI.FileMenu, 'Label', 'Load peaks', 'Callback', @OpenFile_Callback, 'Accelerator', 'O');
        GUI.SavePeaks = uimenu( GUI.FileMenu, 'Label', 'Save peaks', 'Callback', @SavePeaks_Callback, 'Accelerator', 'S');
        
        GUI.LoadConfigurationFile = uimenu( GUI.FileMenu, 'Label', 'Load configuration file', 'Callback', @LoadConfigurationFile_Callback, 'Accelerator', 'F');
        GUI.SaveConfigurationFile = uimenu( GUI.FileMenu, 'Label', 'Save configuration file', 'Callback', @SaveConfigurationFile_Callback, 'Accelerator', 'C');
        
        GUI.SaveFiguresFile = uimenu( GUI.FileMenu, 'Label', 'Save figures', 'Callback', @onSaveFiguresAsFile, 'Accelerator', 'G');
        
        GUI.OpenDataQuality = uimenu( GUI.FileMenu, 'Label', 'Open signal quality file', 'Callback', @OpenDataQuality_Callback, 'Accelerator', 'Q', 'Separator', 'on');
        GUI.SaveDataQuality = uimenu( GUI.FileMenu, 'Label', 'Save signal quality file', 'Callback', @SaveDataQuality_Callback, 'Accelerator', 'D');
        
        GUI.OpenRhythms = uimenu( GUI.FileMenu, 'Label', 'Open Rhythms file', 'Callback', @OpenRhythms_Callback, 'Accelerator', 'R', 'Separator', 'on');
        GUI.SaveRhythms = uimenu( GUI.FileMenu, 'Label', 'Save Rhythms file', 'Callback', @SaveRhythms_Callback, 'Accelerator', 'T');
        
        
        uimenu( GUI.FileMenu, 'Label', 'Exit', 'Callback', @Exit_Callback, 'Separator', 'on', 'Accelerator', 'E');
        
        % + Help menu
        %         helpMenu = uimenu( GUI.Window, 'Label', 'Help' );
        %         uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @onHelp, 'Visible', 'off' );
        %         uimenu( helpMenu, 'Label', 'PhysioZoo Home', 'Callback', @onPhysioZooHome );
        
        % Create the layout (Arrange the main interface)
        mainLayout = uix.VBoxFlex('Parent', GUI.Window, 'Spacing', DATA.Spacing);
        
        % + Create the panels
        Upper_Part_Box = uix.HBoxFlex('Parent', mainLayout, 'Spacing', DATA.Spacing); % Upper Part
        Low_Part_BoxPanel = uix.BoxPanel( 'Parent', mainLayout, 'Title', '  ', 'Padding', DATA.Padding); %Low Part
        
        upper_part = 0.7; % 0.8 0.55
        low_part = 1 - upper_part;
        set(mainLayout, 'Heights', [(-1)*upper_part, (-1)*low_part]);
        
        % + Upper Panel - Left and Right Parts
        temp_panel_left = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding);
        temp_panel_right = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding); % , 'BorderType', 'none'
        temp_panel_buttons = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding); % , 'BorderType', 'none'
        temp_vbox_buttons = uix.VBox( 'Parent', temp_panel_buttons, 'Spacing', DATA.Spacing);
        
        if DATA.SmallScreen
            left_part = 0.48; % 0.4
        else
            left_part = 0.285;  % 0.265
        end
        right_part = 0.9;
        buttons_part = 0.08; % 0.07
        Left_Part_widths_in_pixels = 0.3 * DATA.window_size(1);
        
        set(Upper_Part_Box, 'Widths', [-1*left_part -1*right_part -1*buttons_part]);
        
        RightLeft_TabPanel = uix.TabPanel('Parent', temp_panel_left, 'Padding', DATA.Padding);
        two_axes_box = uix.VBox('Parent', temp_panel_right, 'Spacing', DATA.Spacing);
        CommandsButtons_Box = uix.VButtonBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        play_box = uix.VButtonBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Padding', DATA.Padding);
        
        %         set(temp_vbox_buttons, 'Heights', [-100, -35]);
        
        RecordTab = uix.Panel('Parent', RightLeft_TabPanel, 'Padding', DATA.Padding);
        ConfigParamTab = uix.Panel('Parent', RightLeft_TabPanel, 'Padding', DATA.Padding);
        DisplayTab = uix.Panel('Parent', RightLeft_TabPanel, 'Padding', DATA.Padding);
        
        RightLeft_TabPanel.TabTitles = {'Record', 'Configuration', 'Display'};
        RightLeft_TabPanel.TabWidth = 100;
        RightLeft_TabPanel.FontSize = BigFontSize;
        
        GUI.ECG_Axes = axes('Parent', uicontainer('Parent', two_axes_box), 'Tag', 'GUI.ECG_Axes');
        GUI.RRInt_Axes = axes('Parent', uicontainer('Parent', two_axes_box), 'Tag', 'GUI.RRInt_Axes');
        %         axis(GUI.ECG_Axes, 'square', 'equal');
        
        set(two_axes_box, 'Heights', [-1, 100]);
        
        GUI.AutoCompute_pushbutton = uicontrol('Style', 'PushButton', 'Parent', CommandsButtons_Box, 'Callback', @AutoCompute_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'Compute', 'Enable', 'off');
        GUI.AutoCalc_checkbox = uicontrol('Style', 'Checkbox', 'Parent', CommandsButtons_Box, 'Callback', @AutoCalc_checkbox_Callback, 'FontSize', SmallFontSize-1, 'String', 'Auto Compute', 'Value', 1);
        
        GUI.RR_or_HR_plot_button = uicontrol('Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', @RR_or_HR_plot_button_Callback, 'FontSize', BigFontSize, 'String', 'Plot HR');
        GUI.Reset_pushbutton = uicontrol('Style', 'PushButton', 'Parent', CommandsButtons_Box, 'Callback', @Reset_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Reset');
        set(CommandsButtons_Box, 'ButtonSize', [110, 25], 'Spacing', DATA.Spacing); % [70, 25]
        
        GUI.Rhythms_handle = uicontrol('Style', 'PushButton', 'Parent', play_box, 'String', 'Rhythms', 'FontSize', DATA.SmallFontSize,...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Enable', 'inactive');
        
        MovieStartStioHButtons_Box = uix.HButtonBox('Parent', play_box, 'Spacing', DATA.Spacing); % , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom'
        GUI.PlayStopReverseMovieButton = uicontrol('Style', 'ToggleButton', 'Parent', MovieStartStioHButtons_Box, 'Callback', @play_stop_reverse_movie_pushbutton_Callback,...
            'FontSize', BigFontSize, 'String', sprintf('\x25C4'), 'Enable', 'inactive', 'Tooltip', 'Start/Stop scrolling (reverse)'); % sprintf('\x25A0') 25B2
        GUI.PlayStopForwMovieButton = uicontrol('Style', 'ToggleButton', 'Parent', MovieStartStioHButtons_Box, 'Callback', @play_stop_movie_pushbutton_Callback,...
            'FontSize', BigFontSize, 'String', sprintf('\x25BA'), 'Enable', 'inactive', 'Tooltip', 'Start/Stop scrolling (forward)'); % sprintf('\x25A0') 25B2
        
        PageUpDownButtons_Box = uix.HButtonBox('Parent', play_box, 'Spacing', DATA.Spacing); % , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom'
        GUI.PageDownButton = uicontrol('Style', 'PushButton', 'Parent', PageUpDownButtons_Box, 'Callback', {@page_down_pushbutton_Callback, ''}, 'FontSize', BigFontSize, 'String', sprintf('\x25C0'), 'Enable', 'off');  % 2190'
        GUI.PageUpButton = uicontrol('Style', 'PushButton', 'Parent', PageUpDownButtons_Box, 'Callback', {@page_up_pushbutton_Callback, ''}, 'FontSize', BigFontSize, 'String', sprintf('\x25B6'), 'Enable', 'off');  % 2192
        set(PageUpDownButtons_Box, 'ButtonSize', [70, 25], 'Spacing', DATA.Spacing);
        set(MovieStartStioHButtons_Box, 'ButtonSize', [70, 25], 'Spacing', DATA.Spacing);
        set(play_box, 'ButtonSize', [110, 25], 'Spacing', DATA.Spacing); % [70, 25]
        
        GUI.CommandsButtons_Box = CommandsButtons_Box;
        GUI.PageUpDownButtons_Box = PageUpDownButtons_Box;
        
        tabs_widths = Left_Part_widths_in_pixels;
        tabs_heights = 525; % 430
        
        RecordSclPanel = uix.ScrollingPanel( 'Parent', RecordTab);
        RecordBox = uix.VBox( 'Parent', RecordSclPanel, 'Spacing', DATA.Spacing);
        set(RecordSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        ConfigSclPanel = uix.ScrollingPanel( 'Parent', ConfigParamTab);
        GUI.ConfigBox = uix.VBox( 'Parent', ConfigSclPanel, 'Spacing', DATA.Spacing);
        set(ConfigSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        DisplaySclPanel = uix.ScrollingPanel( 'Parent', DisplayTab);
        DisplayBox = uix.VBox( 'Parent', DisplaySclPanel, 'Spacing', DATA.Spacing);
        set(DisplaySclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        GUI.RecordTab = RecordTab;
        GUI.ConfigParamTab = ConfigParamTab;
        GUI.DisplayTab = DisplayTab;
        
        %-------------------------------------------------------
        % Record Tab
        
        [GUI, textBox{1}, text_handles{1}] = createGUITextLine(GUI, 'GUIRecord', 'RecordFileName_text', 'Record file name:', RecordBox, 'text', 1, @OpenFile_Callback);
        [GUI, textBox{2}, text_handles{2}] = createGUITextLine(GUI, 'GUIRecord', 'PeaksFileName_text', 'Peaks file name:', RecordBox, 'text', 1, @OpenFile_Callback);
        
        [GUI, textBox{3}, text_handles{3}] = createGUITextLine(GUI, 'GUIRecord', 'DataQualityFileName_text', 'Signal quality file name:', RecordBox, 'text', 1, @OpenDataQuality_Callback);
        
        [GUI, textBox{4}, text_handles{4}] = createGUITextLine(GUI, 'GUIRecord', 'RhythmsFileName_text', 'Rhythms file name:', RecordBox, 'text', 1, @OpenRhythms_Callback);
        
        [GUI, textBox{5}, text_handles{5}] = createGUITextLine(GUI, 'GUIRecord', 'Config_text', 'Config file name:', RecordBox, 'text', 1, @LoadConfigurationFile_Callback);
        [GUI, textBox{6}, text_handles{6}] = createGUITextLine(GUI, 'GUIRecord', 'TimeSeriesLength_text', 'Time series length:', RecordBox, 'text', 0, '');
        [GUI, textBox{7}, text_handles{7}] = createGUITextLine(GUI, 'GUIRecord', 'Mammal_popupmenu', 'Mammal', RecordBox, 'edit', 0, '');
        GUI.GUIRecord.Mammal_popupmenu.Callback = @Mammal_popupmenu_Callback;
        
        [GUI, textBox{8}, text_handles{8}] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'Integration_popupmenu', 'Integration level', RecordBox, @Integration_popupmenu_Callback, DATA.GUI_Integration);
        [GUI, textBox{9}, text_handles{9}] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'PeakDetector_popupmenu', 'Peak detector', RecordBox, @PeakDetector_popupmenu_Callback, DATA.GUI_PeakDetector);
        [GUI, textBox{10}, text_handles{10}] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'Annotation_popupmenu', 'Annotation', RecordBox, @Annotation_popupmenu_Callback, DATA.GUI_Annotation);
        [GUI, textBox{11}, text_handles{11}] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'PeakAdjustment_popupmenu', 'Peak adjustment', RecordBox, @PeakAdjustment_popupmenu_Callback, DATA.Adjustment_type);
        [GUI, textBox{12}, text_handles{12}] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'Class_popupmenu', 'Class', RecordBox, @Class_popupmenu_Callback, DATA.GUI_Class);
        [GUI, textBox{13}, text_handles{13}] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'Rhythms_popupmenu', 'Rhythms', RecordBox, @Rhythms_popupmenu_Callback, DATA.Rhythms_Type);
        
        GUI.Adjust_textBox = textBox{11};
        GUI.Class_textBox = textBox{12};
        GUI.Rhythms_textBox = textBox{13};
        
        GUI.GUIRecord.Class_popupmenu.Visible = 'off';
        GUI.GUIRecord.Class_popupmenu.Value = 3;
        GUI.Class_Text = text_handles{12};
        GUI.Class_Text.Visible = 'off';
        
        GUI.GUIRecord.Rhythms_popupmenu.Visible = 'off';
        GUI.GUIRecord.Rhythms_popupmenu.Value = 1;
        GUI.Rhythms_Text = text_handles{13};
        GUI.Rhythms_Text.Visible = 'off';
        
        GUI.Adjustment_Text = text_handles{11};
        GUI.Adjustment_Text.Visible = 'on';
        
        max_extent_control = calc_max_control_x_extend(text_handles);
        
        field_size = [max_extent_control, -1, 1];
        for i = 6 : 6
            set(textBox{i}, 'Widths', field_size);
        end
        
        if DATA.SmallScreen
            field_size1 = [max_extent_control + 5, -0.56, -0.2];
        else
            field_size1 = [max_extent_control + 5, -0.45, -0.5];
        end
        
        for i = 7 : 13
            set(textBox{i}, 'Widths', field_size1);
        end
        
        popupmenu_position = get(GUI.GUIRecord.Mammal_popupmenu, 'Position');
        field_size = [max_extent_control + 5, popupmenu_position(3)+ 15, 25];
        for i = 1 : 5
            set(textBox{i}, 'Widths', field_size);
        end
        
        GUI.RhythmsHBox = uix.HBox('Parent', RecordBox, 'Spacing', DATA.Spacing, 'Visible', 'off');
        
        uix.Empty('Parent', GUI.RhythmsHBox);
        Rhythms_grid = uix.Grid('Parent', GUI.RhythmsHBox, 'Spacing', DATA.Spacing);
        uix.Empty('Parent', GUI.RhythmsHBox);
        
        for i = 1 : length(DATA.Rhythms_Type)
            GUI.rhythms_legend(i) = uicontrol('Style', 'ToggleButton', 'Parent', Rhythms_grid, 'Enable', 'on', 'String', DATA.Rhythms_Type{i}, ...
                'Tooltip', DATA.rhythms_tooltip{i}, 'Callback', @Rhythms_ToggleButton_Callback, 'Value', 0, 'UserData', i);
        end
        set(Rhythms_grid, 'Widths', 60*ones(1, 3), 'Heights', -1*ones(1, length(DATA.Rhythms_Type)/3));
        set(GUI.RhythmsHBox, 'Widths', field_size1);
        
        if DATA.SmallScreen
            hf = -0.45;
            %             uix.Empty( 'Parent', RecordBox);
            set(RecordBox, 'Heights', [hf * ones(1, 13), -4] );
        else
            hf = -1;
            set(RecordBox, 'Heights', [hf * ones(1, 13), -4]);
        end
        
        load_config_name_button_position = get(GUI.GUIRecord.Config_text_pushbutton_handle, 'Position');
        updated_position = [load_config_name_button_position(1) load_config_name_button_position(2) + 10 load_config_name_button_position(3) load_config_name_button_position(4) - 10];
        set(GUI.GUIRecord.RecordFileName_text_pushbutton_handle, 'Position', updated_position, 'Enable', 'on');
        set(GUI.GUIRecord.PeaksFileName_text_pushbutton_handle, 'Position', updated_position);
        set(GUI.GUIRecord.Config_text_pushbutton_handle, 'Position', updated_position);
        set(GUI.GUIRecord.DataQualityFileName_text_pushbutton_handle, 'Position', updated_position);
        set(GUI.GUIRecord.RhythmsFileName_text_pushbutton_handle, 'Position', updated_position);
        
        GUI.Adjust_textBox_position = get(GUI.Adjust_textBox, 'Position');
        GUI.Class_textBox_position = get(GUI.Class_textBox, 'Position');
        GUI.Rhythms_textBox_position = get(GUI.Rhythms_textBox, 'Position');
        
        %-------------------------------------------------------
        % Config Params Tab
        
        %         field_size = [80, 150, 10 -1];
        
        uicontrol( 'Style', 'text', 'Parent', GUI.ConfigBox, 'String', 'rqrs', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
        
        %         uix.Empty( 'Parent', GUI.ConfigBox );
        
        [GUI, textBox{1}, text_handles{1}] = createGUISingleEditLine(GUI, 'GUIConfig', 'HR', 'HR', 'BPM', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'HR');
        [GUI, textBox{2}, text_handles{2}] = createGUISingleEditLine(GUI, 'GUIConfig', 'QS', 'QS', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'QS');
        [GUI, textBox{3}, text_handles{3}] = createGUISingleEditLine(GUI, 'GUIConfig', 'QT', 'QT', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'QT');
        [GUI, textBox{4}, text_handles{4}] = createGUISingleEditLine(GUI, 'GUIConfig', 'QRSa', 'QRSa', 'microVolts', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'QRSa');
        [GUI, textBox{5}, text_handles{5}] = createGUISingleEditLine(GUI, 'GUIConfig', 'QRSamin', 'QRSamin', 'microVolts', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'QRSamin');
        [GUI, textBox{6}, text_handles{6}] = createGUISingleEditLine(GUI, 'GUIConfig', 'RRmin', 'RRmin', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'RRmin');
        [GUI, textBox{7}, text_handles{7}] = createGUISingleEditLine(GUI, 'GUIConfig', 'RRmax', 'RRmax', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'RRmax');
        
        uix.Empty('Parent', GUI.ConfigBox );
        
        uicontrol( 'Style', 'text', 'Parent', GUI.ConfigBox, 'String', 'jqrs/wjqrs', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
        [GUI, textBox{8}, text_handles{8}] = createGUISingleEditLine(GUI, 'GUIConfig', 'lcf', 'Lower cutoff frequency', 'Hz', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'lcf');
        [GUI, textBox{9}, text_handles{9}] = createGUISingleEditLine(GUI, 'GUIConfig', 'hcf', 'Upper cutoff frequency', 'Hz', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'hcf');
        [GUI, textBox{10}, text_handles{10}] = createGUISingleEditLine(GUI, 'GUIConfig', 'thr', 'Threshold', 'n.u.', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'thr');
        [GUI, textBox{11}, text_handles{11}] = createGUISingleEditLine(GUI, 'GUIConfig', 'rp', 'Refractory period', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'rp');
        [GUI, textBox{12}, text_handles{12}] = createGUISingleEditLine(GUI, 'GUIConfig', 'ws', 'Window size', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'ws');
        
        uix.Empty('Parent', GUI.ConfigBox );
        
        % ORI's algorithm for EGM peaks
        uicontrol( 'Style', 'text', 'Parent', GUI.ConfigBox, 'String', 'EGM peaks', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
        %         [GUI, textBox{13}, text_handles{13}] = createGUISingleEditLine(GUI, 'GUIConfig', 'alpha', 'Alpha', 'n.u.', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'alpha');
        [GUI, textBox{13}, text_handles{13}] = createGUISingleEditLine(GUI, 'GUIConfig', 'ref_per', 'Refractory period', 'msec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'ref_per');
        [GUI, textBox{14}, text_handles{14}] = createGUISingleEditLine(GUI, 'GUIConfig', 'bi', 'BI', 'msec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'bi');
        
        uix.Empty('Parent', GUI.ConfigBox );
        
        GUI.AutoPeakWin_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', GUI.ConfigBox, 'FontSize', SmallFontSize, 'String', 'Auto', 'Value', 1);
        [GUI, textBox{15}, text_handles{15}] = createGUISingleEditLine(GUI, 'GUIConfig', 'PeaksWindow', 'Peaks window', 'ms', GUI.ConfigBox, @Peaks_Window_edit_Callback, '', 'peaks_window');
        
        %         uix.Empty('Parent', GUI.ConfigBox );
        %         uicontrol( 'Style', 'text', 'Parent', GUI.ConfigBox, 'String', 'Adjust R-peak location', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
        
        
        %         uix.Empty('Parent', GUI.ConfigBox );
        %
        %         tempBox = uix.HBox('Parent', GUI.ConfigBox, 'Spacing', DATA.Spacing);
        %         uix.Empty('Parent', tempBox );
        %         GUI.AutoCompute_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', tempBox, 'Callback', @Del_win_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'Del Win');
        %         uix.Empty('Parent', tempBox );
        %         uix.Empty('Parent', tempBox );
        
        %         uix.Empty('Parent', GUI.ConfigBox );
        %         set(GUI.ConfigBox, 'Heights', [-7 -7 -7 -7 -7 -7 -7 -7   -1 -7 -7 -7 -7 -7 -7   -8 -7 -7   -7 -7] );
        
        
        
        set(GUI.ConfigBox, 'Heights', [-15 * ones(1, 8)   -0.5 -15 * ones(1, 6) -0.5 -15 * ones(1, 3)  -0.5 -15 -15]);
        %         set(GUI.ConfigBox, 'Heights', [-7 * ones(1, 8)   -1 -7 * ones(1, 6) -1 -7 * ones(1, 4)  -8 -7 -7 ] );
        %         set(GUI.ConfigBox, 'Heights', [-7 * ones(1, 8)    -7 * ones(1, 6) -7 * ones(1, 4)  -7 -7 ] );
        %-------------------------------------------------------
        % Display Tab
        %         field_size = [110, 140, 10, -1];
        
        uix.Empty('Parent', DisplayBox);
        
        [GUI, textBox{16}, text_handles{16}] = createGUISingleEditLine(GUI, 'GUIDisplay', 'FirstSecond', 'Window start:', 'h:min:sec', DisplayBox, @FirstSecond_Callback, '', 0);
        [GUI, textBox{17}, text_handles{17}] = createGUISingleEditLine(GUI, 'GUIDisplay', 'WindowSize', 'Window length:', 'h:min:sec', DisplayBox, @WindowSize_Callback, '', 0);
        
        %         field_size = [110, 64, 4, 63, 10];
        [GUI, YLimitBox, text_handles{18}] = createGUIDoubleEditLine(GUI, 'GUIDisplay', {'MinYLimit_Edit'; 'MaxYLimit_Edit'}, 'Y Limit:', '', DisplayBox, {@MinMaxYLimit_Edit_Callback; @MinMaxYLimit_Edit_Callback}, '', []);
        
        uix.Empty('Parent', DisplayBox);
        
        [GUI, textBox{19}, text_handles{19}] = createGUISingleEditLine(GUI, 'GUIDisplay', 'RRIntPage_Length', 'Display duration:', 'h:min:sec', DisplayBox, @RRIntPage_Length_Callback, '', '');
        [GUI, YLimitBox2, text_handles{20}] = createGUIDoubleEditLine(GUI, 'GUIDisplay', {'MinYLimitLowAxes_Edit'; 'MaxYLimitLowAxes_Edit'}, 'Y Limit:', '', DisplayBox, {@MinMaxYLimitLowAxes_Edit_Callback; @MinMaxYLimitLowAxes_Edit_Callback}, '', []);
        
        uix.Empty('Parent', DisplayBox);
        
        [GUI, textBox{21}, text_handles{21}] = createGUISingleEditLine(GUI, 'GUIDisplay', 'Movie_Delay', 'Movie Speed:', 'n.u.', DisplayBox, @Movie_Delay_Callback, '', 2);
        GUI.GUIDisplay.Movie_Delay.String = 2;
        
        uix.Empty('Parent', DisplayBox);
        
        GUI.GridX_checkbox = uicontrol('Style', 'Checkbox', 'Parent', DisplayBox, 'Callback', @GridX_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'Grid X', 'Value', 1);
        GUI.GridY_checkbox = uicontrol('Style', 'Checkbox', 'Parent', DisplayBox, 'Callback', @GridY_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'Grid Y', 'Value', 1);
        
        uix.Empty('Parent', DisplayBox);
        
        GUI.RawSignal_checkbox = uicontrol('Style', 'Checkbox', 'Parent', DisplayBox, 'Callback', @ShowRawSignal_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'Show raw signal', 'Value', 1);
        GUI.FilteredSignal_checkbox = uicontrol('Style', 'Checkbox', 'Parent', DisplayBox, 'Callback', @ShowFilteredSignal_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'Show filtered signal', 'Value', 0);
        
        uix.Empty('Parent', DisplayBox);
        
        [GUI, textBox{22}, text_handles{22}] = createGUIPopUpMenuLine(GUI, 'GUIDisplay', 'FilterLevel_popupmenu', 'Filter level', DisplayBox,...
            @FilterLevel_popupmenu_Callback, {'Weak'; 'Moderate'; 'Strong'});
        
        [GUI, CutoffFr, text_handles{23}] = createGUIDoubleEditLine(GUI, 'GUIDisplay', {'LowCutoffFr_Edit'; 'HightCutoffFr_Edit'}, 'Cutoff Frequency:', 'Hz', DisplayBox, {@LowHightCutoffFr_Edit; @LowHightCutoffFr_Edit}, '', []);
        set_default_filter_level_user_data();
        
        GUI.FilterLevelBox = textBox{22};
        GUI.CutoffFrBox = CutoffFr;
        
        GUI.FilterLevelBox.Visible = 'off';
        GUI.CutoffFrBox.Visible = 'off';
        
        set(GUI.GUIDisplay.FirstSecond, 'Enable', 'on');
        set(GUI.GUIDisplay.WindowSize, 'Enable', 'on');
        set(GUI.GUIDisplay.MinYLimit_Edit, 'Enable', 'inactive');
        set(GUI.GUIDisplay.MaxYLimit_Edit, 'Enable', 'inactive');
        set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'Enable', 'inactive');
        set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'Enable', 'inactive');
        
        max_extent_control = calc_max_control_x_extend(text_handles);
        
        field_size = [max_extent_control, 150, 10 -1];
        for i = 1 : length(text_handles) - 3
            set(textBox{i}, 'Widths', field_size);
        end
        
        set(textBox{21}, 'Widths', field_size);
        
        if DATA.SmallScreen
            field_size = [max_extent_control, 150, -1];
        else
            field_size = [max_extent_control, 150, -1];
        end
        set(textBox{22}, 'Widths', field_size);
        
        field_size = [max_extent_control, 72, 2, 70, 10];
        set(YLimitBox, 'Widths', field_size);
        set(YLimitBox2, 'Widths', field_size);
        
        GUI.AutoScaleY_checkbox = uicontrol('Style', 'Checkbox', 'Parent', YLimitBox, 'Callback', @AutoScaleY_pushbutton_Callback, 'FontSize', 10, 'String', 'Auto Scale Y', 'Value', 1, 'Enable', 'on');
        set(YLimitBox, 'Widths', [field_size, 95]);
        
        GUI.AutoScaleYLowAxes_checkbox = uicontrol('Style', 'Checkbox', 'Parent', YLimitBox2, 'Callback', @AutoScaleYLowAxes_pushbutton_Callback, 'FontSize', 10, 'String', 'Auto Scale Y', 'Value', 1, 'Enable', 'on');
        set(YLimitBox2, 'Widths', [field_size, 95]);
        
        field_size = [max_extent_control, 72, 2, 70, 10, -1];
        set(CutoffFr, 'Widths', field_size);
        
        set(DisplayBox, 'Heights', [-2 -6 -6 -6 -2 -6 -6 -2 -6 -3 -3 -6 -2 -6 -6 -2 -7 -6]);
        
        %-------------------------------------------------------
        
        % Low Part
        
        Low_TabPanel = uix.TabPanel('Parent', Low_Part_BoxPanel, 'Padding', DATA.Padding);
        
        PeaksTab = uix.Panel('Parent', Low_TabPanel, 'Padding', DATA.Padding);
        RhythmsTab = uix.Panel('Parent', Low_TabPanel, 'Padding', DATA.Padding);
        
        Low_TabPanel.TabTitles = {'Peaks', 'Rhythms'};
        Low_TabPanel.TabWidth = 100;
        Low_TabPanel.FontSize = BigFontSize;
        
        Low_Part_Box = uix.VBox('Parent', PeaksTab, 'Spacing', DATA.Spacing);
        
        GUI.PeaksTable = uitable('Parent', Low_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{550 'auto'}, 'FontName', 'Calibri');
        GUI.PeaksTable.ColumnName = {'Description'; 'Values'};
        GUI.PeaksTable.RowName = {'NB PEAKS (n.u.)'; 'NB PEAKS ADD (n.u.)'; 'NB PEAKS RM (n.u.)'; 'PR BAD SQ (%)'};
        GUI.PeaksTable.Data = {''};
        GUI.PeaksTable.Data(1, 1) = {'Total number of peaks'};    % Number of peaks detected by the peak detection algorithm
        GUI.PeaksTable.Data(2, 1) = {'Number of peaks manually added by the user'}; % Number of peaks manually added by the user
        GUI.PeaksTable.Data(3, 1) = {'Number of peaks manually removed by the user'}; % Number of peaks manually removed by the user
        GUI.PeaksTable.Data(4, 1) = {['Percentage of the record annotated as bad quality (i.e. signal quality ' sprintf('\x2260') ' ''A'')']};
        GUI.PeaksTable.Data(:, 2) = {0};
        
        %--------------------------------------------------------------------------
        
        Rhythms_Part_Box = uix.VBox('Parent', RhythmsTab, 'Spacing', DATA.Spacing);
        GUI.RhythmsTable = uitable('Parent', Rhythms_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{250 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto'}, 'FontName', 'Calibri');
        GUI.RhythmsTable.ColumnName = {'Description'; 'Min (sec)'; 'Max (sec)'; 'Median (sec)'; 'Q1 (sec)'; 'Q3 (sec)'; 'Burden (%)'; 'Nb events'};
        GUI.RhythmsTable.Data = {};
        GUI.RhythmsTable.RowName = {}; 
                                
        %--------------------------------------------------------------------------
        
        set(findobj(Upper_Part_Box,'Style', 'edit'), 'BackgroundColor', myEditTextColor);
        set(findobj(Upper_Part_Box,'Style', 'text'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(Upper_Part_Box,'Style', 'slider'), 'BackgroundColor', mySliderColor);
        set(findobj(Upper_Part_Box,'Style', 'checkbox'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(Upper_Part_Box,'Style', 'ToggleButton'), 'BackgroundColor', myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
        set(findobj(Upper_Part_Box,'Style', 'PushButton'), 'BackgroundColor', myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
        set(findobj(Upper_Part_Box,'Type', 'uicontainer'), 'BackgroundColor', myUpBackgroundColor);
        set(findobj(Upper_Part_Box,'Type', 'uipanel'), 'BackgroundColor', myUpBackgroundColor);
        
        % Low Part
        set(findobj(Low_Part_BoxPanel,'Type', 'uicontainer'), 'BackgroundColor', myLowBackgroundColor);
        set(findobj(Low_Part_BoxPanel,'Type', 'uipanel'), 'BackgroundColor', myLowBackgroundColor);
        set(findobj(Low_Part_BoxPanel,'Style', 'edit'), 'BackgroundColor', myEditTextColor);
        set(findobj(Low_Part_BoxPanel,'Style', 'text'), 'BackgroundColor', myLowBackgroundColor);
        
        GUI.Rhythms_handle.BackgroundColor = [52 204 255]/255; % [131 255 226]/255   255 131 160
        GUI.Rhythms_handle.ForegroundColor = [255 255 255]/255;
        
        for i = 1 : length(DATA.Rhythms_Type)
            GUI.rhythms_legend(i).BackgroundColor = DATA.rhythms_color{i};
        end
        
        GUI.OpenDataQuality.Enable = 'off';
        GUI.SaveDataQuality.Enable = 'off';
        
        GUI.SaveRhythms.Enable = 'off';
        GUI.OpenRhythms.Enable = 'off';
        
        GUI.LoadConfigurationFile.Enable = 'off';
        GUI.SaveConfigurationFile.Enable = 'off';
        GUI.SavePeaks.Enable = 'off';
        GUI.SaveFiguresFile.Enable = 'off';
        %GUI.LoadPeaks.Enable = 'off';
        
        GUI.PlayStopForwMovieButton.ForegroundColor = [0 1 0];
        GUI.PlayStopReverseMovieButton.ForegroundColor = [0 1 0];
        GUI.PageDownButton.ForegroundColor = [0 0 1];
        GUI.PageUpButton.ForegroundColor = [0 0 1];
    end
%%
    function [GUI, TempBox, uicontrol_handle] = createGUITextLine(GUI, gui_struct, field_name, string_field_name, box_container, style, isOpenButton, callback_openButton)
        
        TempBox = uix.HBox( 'Parent', box_container, 'Spacing', DATA.Spacing);
        uicontrol_handle = uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', string_field_name, 'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.(gui_struct).(field_name) = uicontrol( 'Style', style, 'Parent', TempBox, 'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
        
        if isOpenButton
            button_field_name = [field_name '_pushbutton_handle'];
            GUI.(gui_struct).(button_field_name) = uicontrol('Style', 'PushButton', 'Parent', TempBox, 'Callback', callback_openButton, 'FontSize', DATA.SmallFontSize, 'String', '...', 'Enable', 'off');
        else
            uix.Empty( 'Parent', TempBox );
        end
        %         set( TempBox, 'Widths', field_size  );
    end
%%
    function [GUI, TempBox, uicontrol_handle] = createGUISingleEditLine(GUI, gui_struct, field_name, string_field_name, field_units, box_container, callback_function, tag, user_data)
        
        TempBox = uix.HBox( 'Parent', box_container, 'Spacing', DATA.Spacing);
        uicontrol_handle = uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', string_field_name, 'FontSize', DATA.BigFontSize, 'HorizontalAlignment', 'left');
        GUI.(gui_struct).(field_name) = uicontrol( 'Style', 'edit', 'Parent', TempBox, 'Callback', callback_function, 'FontSize', DATA.BigFontSize, 'Tag', tag, 'UserData', user_data);
        uix.Empty( 'Parent', TempBox );
        if ~isempty(strfind(field_units, 'micro')) % https://unicode-table.com/en/
            field_units = strrep(field_units, 'micro', '');
            field_units = [sprintf('\x3bc') field_units];
        end
        uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', field_units, 'FontSize', DATA.BigFontSize, 'HorizontalAlignment', 'left');
        %         set( TempBox, 'Widths', field_size  );
    end
%%
    function [GUI, TempBox, uicontrol_handle] = createGUIDoubleEditLine(GUI, gui_struct, field_name, string_field_name, field_units, box_container, callback_function, tag, user_data)
        
        TempBox = uix.HBox( 'Parent', box_container, 'Spacing', DATA.Spacing);
        uicontrol_handle = uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', string_field_name, 'FontSize', DATA.BigFontSize, 'HorizontalAlignment', 'left');
        GUI.(gui_struct).(field_name{1}) = uicontrol( 'Style', 'edit', 'Parent', TempBox, 'Callback', callback_function{1}, 'FontSize', DATA.BigFontSize, 'Tag', tag, 'UserData', user_data);
        uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', '-', 'FontSize', DATA.BigFontSize);
        GUI.(gui_struct).(field_name{2}) = uicontrol( 'Style', 'edit', 'Parent', TempBox, 'Callback', callback_function{2}, 'FontSize', DATA.BigFontSize, 'Tag', tag, 'UserData', user_data);
        
        uix.Empty( 'Parent', TempBox );
        
        if ~isempty(field_units)
            uicontrol('Style', 'text', 'Parent', TempBox, 'String', field_units, 'FontSize', DATA.BigFontSize, 'HorizontalAlignment', 'left');
        end
        
        %         set(TempBox, 'Widths', field_size);
    end
%%
    function [GUI, TempBox, uicontrol_handle] = createGUIPopUpMenuLine(GUI, gui_struct, field_name, string_field_name, box_container, callback_function, popupmenu_sting)
        
        TempBox = uix.HBox( 'Parent', box_container, 'Spacing', DATA.Spacing);
        uicontrol_handle = uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', string_field_name, 'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.(gui_struct).(field_name) = uicontrol( 'Style', 'PopUpMenu', 'Parent', TempBox, 'Callback', callback_function, 'FontSize', DATA.SmallFontSize, 'String', popupmenu_sting);
        uix.Empty('Parent', TempBox);
        
        %         set(TempBox, 'Widths', field_size);
    end
%%
    function max_extent_control = calc_max_control_x_extend(uitext_handle)
        max_extent_control = 0;
        for i = 1 : length(uitext_handle)
            extent_control = get(uitext_handle{i}, 'Extent');
            max_extent_control = max(max_extent_control, extent_control(3));
        end
    end
%%
    function set_new_mammal(Config_FileName)
        
        [~, config_name, config_ext] = fileparts(Config_FileName);
        DATA.customConfigFile = [config_name config_ext];
        
        if ~exist(Config_FileName, 'file')
            mammal = 'default';
            integration = 'ecg';
            h_e = warndlg(['The config file ''' DATA.customConfigFile ''' doesn''t exist. The default config file will be loaded.'], 'Warning');
            setLogo(h_e, 'M1');
            uiwait(h_e);
            %             DATA.customConfigFile = ['gqrs.' mammal '-' integration '.conf'];
            DATA.customConfigFile = ['qrs.' mammal '-' integration '.yml'];
            basepath = fileparts(mfilename('fullpath'));
            %             config_file_name = [fileparts(basepath) filesep 'Config' filesep 'gqrs.' mammal '-' integration '.conf'];
            config_file_name = [fileparts(basepath) filesep 'Config' filesep 'qrs.' mammal '-' integration '.yml'];
        else
            config_file_name = Config_FileName;
        end
        set(GUI.GUIRecord.Config_text, 'String', DATA.customConfigFile);
        
        try
            waitbar_handle = waitbar(1/2, 'Loading configuration...', 'Name', 'Loading data');
            %             DATA.config_map = parse_gqrs_config_file(config_file_name);
            
            DATA.config_struct = ReadYaml(config_file_name);
            DATA.config_map = containers.Map;
            config_fields = fieldnames(DATA.config_struct);
            for i = 1 : length(config_fields)
                curr_field = config_fields{i};
                if isstruct(DATA.config_struct.(curr_field))
                    DATA.config_map(curr_field) = DATA.config_struct.(curr_field).value;
                else
                    DATA.config_map(curr_field) = DATA.config_struct.(curr_field);
                end
            end
            
            DATA.peak_search_win = DATA.config_map('peaks_window');
            
            load_updateGUI_config_param();
            if isvalid(waitbar_handle)
                close(waitbar_handle);
            end
            
            mammal = DATA.config_map('mammal');
            integration = DATA.config_map('integration_level');
            
            if ~strcmp(DATA.Mammal, mammal) || ~strcmp(DATA.Integration, integration)
                h_e = warndlg('Mammal and/or integration level of data file does not match the one of the configuration file.', 'Warning');
                setLogo(h_e, 'M1');
                uiwait(h_e);
            end
            
            GUI.GUIRecord.Mammal_popupmenu.String = mammal;
            
            %             DATA.Integration = integration;
            DATA.integration_index = find(strcmpi(DATA.GUI_Integration, integration));
            set(GUI.GUIRecord.Integration_popupmenu, 'Value', DATA.integration_index);
            
            DATA.peakDetector = DATA.config_map('peak_detector');
            DATA.peakDetector_index = find(strcmpi(DATA.GUI_PeakDetector, DATA.peakDetector));
            set(GUI.GUIRecord.PeakDetector_popupmenu, 'Value', DATA.peakDetector_index);
            
            adjust_index = find(strcmpi(DATA.Adjustment_type, DATA.config_map('peak_adjustment')));
            set(GUI.GUIRecord.PeakAdjustment_popupmenu, 'Value', adjust_index);
            
            if adjust_index == 1 % default
                DATA.Adjust = 0;
            elseif adjust_index == 2 % local max
                DATA.Adjust = 1;
            elseif adjust_index == 3 % local min
                DATA.Adjust = -1;
            end
            
        catch e
            rethrow(e);
        end
        
        DATA.zoom_rect_limits = [0 DATA.firstZoom];
        right_limit2plot = min(DATA.firstZoom, max(DATA.tm));
        setECGXLim(0, right_limit2plot);
        setECGYLim(0, right_limit2plot);
    end
%%
    function Mammal_popupmenu_Callback(src, ~)
        if isfield(DATA, 'config_map')
            DATA.config_map('mammal') = src.String;
        end
    end
%%
    function Integration_popupmenu_Callback(src, ~)
        if isfield(DATA, 'config_map')
            items = get(src, 'String');
            index_selected = get(src, 'Value');
            DATA.integration_index = index_selected;
            DATA.config_map('integration_level') = items{index_selected};
        end
    end
%%
    function PeakDetector_popupmenu_Callback(src, ~)
        if isfield(DATA, 'config_map')
            items = get(src, 'String');
            index_selected = get(src, 'Value');
            DATA.config_map('peak_detector') = items{index_selected};
            DATA.peakDetector_index = index_selected;
            
            if get(GUI.AutoCalc_checkbox, 'Value')
                try
                    RunAndPlotPeakDetector();
                    set(GUI.GUIRecord.PeakAdjustment_popupmenu, 'Value', 1);
                catch e
                    h_e = errordlg(['PeakDetector error: ' e.message], 'Input Error'); setLogo(h_e, 'M1');
                    return;
                end
            end
        end
    end
%%
    function OpenFile_Callback(~, ~, fileNameFromM2, DataFileMapFromM2)
        
        persistent DIRS;
        persistent EXT;
        
        % Add third-party dependencies to path
        gui_basepath = fileparts(mfilename('fullpath'));
        basepath = fileparts(gui_basepath);
        
        if ~isfield(DIRS, 'dataDirectory')
            DIRS.dataDirectory = [basepath filesep 'ExamplesTXT'];
        end
        if isempty(EXT)
            EXT = 'txt';
        end
        
        if nargin < 3
            [ECG_FileName, PathName] = uigetfile( ...
                {'*.*', 'All files';...
                '*.txt','Text Files (*.txt)'; ...
                '*.mat',  'MAT-files (*.mat)'; ...
                '*.dat; *.qrs; *.atr',  'WFDB Files (*.dat; *.qrs; *.atr)'}, ...
                'Open Data File', [DIRS.dataDirectory filesep '*.' EXT]); %
        else
            ECG_FileName = fileNameFromM2.FileName;
            PathName = fileNameFromM2.PathName;
            DataFileMap = DataFileMapFromM2;
        end
        
        if isequal(ECG_FileName, 0)
            return;
        else
            
            DIRS.dataDirectory = PathName;
            
            [~, DataFileName, ExtensionFileName] = fileparts(ECG_FileName);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            
            if strcmpi(ExtensionFileName, 'mat') || strcmpi(ExtensionFileName, 'txt') || strcmpi(ExtensionFileName, 'dat') || strcmpi(ExtensionFileName, 'qrs') || strcmpi(ExtensionFileName, 'atr')
                
                Config = ReadYaml('Loader Config.yml');
                if nargin < 3
                    try
                        waitbar_handle = waitbar(1/2, 'Loading data', 'Name', 'Working on it...');
                        setLogo(waitbar_handle, 'M1');
                        
                        DataFileMap = loadDataFile([PathName DataFileName '.' EXT]);
                        close(waitbar_handle);
                    catch e
                        if isvalid(waitbar_handle)
                            close(waitbar_handle);
                        end
                        h_e = errordlg(['onOpenFile error: ' e.message], 'Input Error');
                        setLogo(h_e, 'M1');
                        return;
                    end
                end
                MSG = DataFileMap('MSG');
                if strcmp(Config.alarm.(MSG), 'OK')
                    data = DataFileMap('DATA');
                    if strcmp(data.Data.Type, 'electrography')
                        
                        clearData();
                        clean_gui();
                        clean_config_param_fields();
                        delete_temp_wfdb_files();
                        
                        DATA.DataFileName = DataFileName;
                        DATA.rec_name = [PathName, DATA.DataFileName];
                        
                        mammal = data.General.mammal;
                        if strcmpi(mammal, 'custom')
                            DATA.Mammal = 'default';
                        else
                            DATA.Mammal = mammal;
                        end
                        %                         DATA.mammal_index = find(strcmp(DATA.mammals, DATA.Mammal));
                        
                        integration = data.General.integration_level;
                        DATA.integration_index = find(strcmpi(DATA.Integration_From_Files, integration));
                        DATA.Integration = DATA.GUI_Integration{DATA.integration_index};
                        
                        DATA.Fs = double(data.Time.Fs);
                        DATA.sig = data.Data.Data;
                        time_data = data.Time.Data;
                        DATA.tm = time_data - time_data(1);
                        
                        %                         [t_max, h, m, s ,ms] = mhrv.wfdb.signal_duration(length(DATA.tm), DATA.Fs);
                        %                         header_info = struct('duration', struct('h', h, 'm', m, 's', s, 'ms', ms), 'total_seconds', t_max);
                        
                        DATA.ecg_channel = 1;
                        
                        if strcmpi(EXT, 'txt') || strcmpi(EXT, 'mat')
                            
                            DATA.wfdb_record_name = [tempdir DATA.temp_rec_name4wfdb];
                            mat2wfdb(DATA.sig, DATA.wfdb_record_name, DATA.Fs, [], ' ' ,{} ,[]);
                            
                            if ~exist([DATA.wfdb_record_name '.dat'], 'file') && ~exist([DATA.wfdb_record_name '.hea'], 'file')   % && ~exist(fullfile(tempdir, [DATA.temp_rec_name4wfdb '.hea']), 'file')
                                throw(MException('set_data:text', 'Wfdb file cannot be created.'));
                            end
                        else
                            DATA.wfdb_record_name = DATA.rec_name;
                        end
                        DATA.ExtensionFileName = ExtensionFileName;
                        isM2 = 0;
                    else
                        
                        choice = questdlg('This recording contains peak annotations or an RR intervals time series. Do you want to open it in the Peak detection module or the HRV analysis module?', ...
                            'Select module', 'Peak detection module', 'HRV analysis module', 'Cancel', 'Peak detection module');
                        
                        switch choice
                            case 'HRV analysis module'
                                
                                fileNameFromM1.FileName = ECG_FileName;
                                fileNameFromM1.PathName = PathName;
                                if isvalid(waitbar_handle)
                                    close(waitbar_handle);
                                end
                                PhysioZooGUI_HRVAnalysis(fileNameFromM1, DataFileMap);
                                isM2 = 1;
                                return;
                            case 'Peak detection module'
                                if isfield(DATA, 'Mammal')
                                    isM2 = 0;
                                    try
                                        load_peaks(ECG_FileName, PathName, DataFileMap);
                                        if isvalid(waitbar_handle)
                                            close(waitbar_handle);
                                        end
                                        return;
                                    catch e
                                        if isvalid(waitbar_handle)
                                            close(waitbar_handle);
                                        end
                                        h_e = errordlg(['load_peaks error: ' e.message], 'Input Error');
                                        setLogo(h_e, 'M1');
                                        return;
                                    end
                                else
                                    isM2 = 0;
                                    h_e = errordlg('Please, load ECG file first.', 'Input Error');
                                    setLogo(h_e, 'M1');
                                    if isvalid(waitbar_handle)
                                        close(waitbar_handle);
                                    end
                                    return;
                                end
                            case 'Cancel'
                                isM2 = 1;
                                if isvalid(waitbar_handle)
                                    close(waitbar_handle);
                                end
                                return;
                        end
                    end
                elseif strcmp(Config.alarm.(MSG), 'Canceled')
                    return;
                else
                    h_e = errordlg(['onOpenFile error: ' Config.alarm.(MSG)], 'Input Error');
                    setLogo(h_e, 'M1');
                    return;
                end
                
                if ~isM2
                    try
                        basepath = fileparts(mfilename('fullpath'));
                        %                         DATA.init_config_file_name = [fileparts(basepath) filesep 'Config' filesep 'gqrs.' DATA.Mammal '-' DATA.integration_level{DATA.integration_index} '.conf'];
                        DATA.init_config_file_name = [fileparts(basepath) filesep 'Config' filesep 'qrs.' DATA.Mammal '-' DATA.integration_level{DATA.integration_index} '.yml'];
                        set_new_mammal(DATA.init_config_file_name);
                    catch e
                        if isvalid(waitbar_handle)
                            close(waitbar_handle);
                        end
                        h_e = errordlg(['onOpenFile error: ' e.message], 'Input Error');
                        setLogo(h_e, 'M1');
                        return;
                    end
                end
                
                set(GUI.GUIRecord.RecordFileName_text, 'String', ECG_FileName);
                
                GUI.RawData_handle = line(DATA.tm, DATA.sig, 'Parent', GUI.ECG_Axes, 'Tag', 'RawData', 'Color', [75 75 75]/255);
                
                PathName = strrep(PathName, '\', '\\');
                PathName = strrep(PathName, '_', '\_');
                ECG_FileName_title = strrep(ECG_FileName, '_', '\_');
                
                TitleName = [PathName ECG_FileName_title] ;
                title(GUI.ECG_Axes, TitleName, 'FontWeight', 'normal', 'FontSize', 11);
                
                right_limit2plot = min(DATA.firstZoom, max(DATA.tm));
                setECGXLim(0, right_limit2plot);
                setECGYLim(0, right_limit2plot);
                
                xlabel(GUI.ECG_Axes, 'Time (h:min:sec)');
                ylabel(GUI.ECG_Axes, 'ECG (mV)');
                hold(GUI.ECG_Axes, 'on');
                
                %                 set(GUI.GUIRecord.TimeSeriesLength_text, 'String', [[num2str(header_info.duration.h) ':' num2str(header_info.duration.m) ':' ...
                %                     num2str(header_info.duration.s) '.' num2str(header_info.duration.ms)] '    h:min:sec.msec']);
                
                set(GUI.GUIRecord.TimeSeriesLength_text, 'String', [calcDuration(DATA.tm(end), 1) '    h:min:sec.msec']);
                
                if GUI.AutoCalc_checkbox.Value
                    try
                        RunAndPlotPeakDetector();
                    catch e
                        h_e = errordlg(['OpenFile error: ' e.message], 'Input Error');
                        setLogo(h_e, 'M1');
                        %                         return;
                    end
                end
                
                %                 set(GUI.RRInt_Axes, 'XLim', [0 max(DATA.tm)]);
                
                GUI.LoadConfigurationFile.Enable = 'on';
                GUI.SaveConfigurationFile.Enable = 'on';
                GUI.SavePeaks.Enable = 'on';
                GUI.SaveDataQuality.Enable = 'on';
                GUI.OpenDataQuality.Enable = 'on';
                GUI.SaveRhythms.Enable = 'on';
                GUI.OpenRhythms.Enable = 'on';
                GUI.SaveFiguresFile.Enable = 'on';
                GUI.GUIRecord.PeaksFileName_text_pushbutton_handle.Enable = 'on';
                GUI.GUIRecord.Config_text_pushbutton_handle.Enable = 'on';
                GUI.GUIRecord.DataQualityFileName_text_pushbutton_handle.Enable = 'on';
                GUI.GUIRecord.RhythmsFileName_text_pushbutton_handle.Enable = 'on';
                
                DATA.zoom_rect_limits = [0 DATA.firstZoom];
                set_default_filter_level_user_data();
                
                GUI.hT = text(0, 0, 'Test', 'Parent', GUI.ECG_Axes);
            end
        end
    end
%%
    function AutoScaleYLowAxes_pushbutton_Callback(src, ~)
        if isfield(GUI, 'red_rect_handle')
            if src.Value
                setRRIntYLim();
                GUI.GUIDisplay.MinYLimitLowAxes_Edit.Enable = 'inactive';
                GUI.GUIDisplay.MaxYLimitLowAxes_Edit.Enable = 'inactive';
            else
                set_rectangles_YData();
                GUI.GUIDisplay.MinYLimitLowAxes_Edit.Enable = 'on';
                GUI.GUIDisplay.MaxYLimitLowAxes_Edit.Enable = 'on';
            end
            GridX_checkbox_Callback;
            GridY_checkbox_Callback();
        end
    end
%%
    function AutoScaleY_pushbutton_Callback(src, ~)
        if isfield(GUI, 'red_rect_handle')
            if src.Value
                xdata = get(GUI.red_rect_handle, 'XData');
                setECGYLim(xdata(1), xdata(2));
                GUI.GUIDisplay.MinYLimit_Edit.UserData = GUI.GUIDisplay.MinYLimit_Edit.String;
                GUI.GUIDisplay.MaxYLimit_Edit.UserData = GUI.GUIDisplay.MaxYLimit_Edit.String;
                GUI.GUIDisplay.MinYLimit_Edit.Enable = 'inactive';
                GUI.GUIDisplay.MaxYLimit_Edit.Enable = 'inactive';
            else
                GUI.GUIDisplay.MinYLimit_Edit.Enable = 'on';
                GUI.GUIDisplay.MaxYLimit_Edit.Enable = 'on';
            end
            GridX_checkbox_Callback;
            GridY_checkbox_Callback;
            redraw_quality_rect();
            redraw_rhythms_rect();
        end
    end
%%
    function MinMaxYLimit_Edit_Callback(src, ~)
        
        minLimit = str2double(GUI.GUIDisplay.MinYLimit_Edit.String);
        maxLimit = str2double(GUI.GUIDisplay.MaxYLimit_Edit.String);
        
        if ~isnan(minLimit) && ~isnan(maxLimit) && minLimit < maxLimit
            
            src.UserData = src.String;
            set(GUI.ECG_Axes, 'YLim', [minLimit maxLimit]);
            redraw_quality_rect();
            redraw_rhythms_rect();
        else
            src.String = src.UserData;
            h_e = errordlg('Please, enter correct values!', 'Input Error'); setLogo(h_e, 'M1');
        end
        GridX_checkbox_Callback;
        GridY_checkbox_Callback;
    end
%%
    function setECGXLim(minLimit, maxLimit)
        set(GUI.ECG_Axes, 'XLim', [minLimit maxLimit]);
        setXECGGrid(GUI.ECG_Axes, GUI.GridX_checkbox);
    end
%%
    function setECGYLim(minLimit, maxLimit)
        sig = DATA.sig(DATA.tm >= minLimit & DATA.tm <= maxLimit);
        
        if isfield(GUI, 'FilteredData_handle') && ishandle(GUI.FilteredData_handle) && isvalid(GUI.FilteredData_handle)...
                && strcmp(GUI.FilteredData_handle.Visible,'on')
            
            filterd_sig = GUI.FilteredData_handle.YData(DATA.tm >= minLimit & DATA.tm <= maxLimit);
            min_sig = min(min(sig), min(filterd_sig));
            max_sig = max(max(sig), max(filterd_sig));
        else
            min_sig = min(sig);
            max_sig = max(sig);
        end
        
        delta = (max_sig - min_sig)*0.1;
        
        min_y_lim = min(min_sig, max_sig) - delta;
        max_y_lim = max(min_sig, max_sig) + delta;
        
        try
            set(GUI.ECG_Axes, 'YLim', [min_y_lim max_y_lim]);
        catch e
            disp(e);
        end
        GUI.GUIDisplay.MinYLimit_Edit.UserData = GUI.GUIDisplay.MinYLimit_Edit.String;
        GUI.GUIDisplay.MaxYLimit_Edit.UserData = GUI.GUIDisplay.MaxYLimit_Edit.String;
        set(GUI.GUIDisplay.MinYLimit_Edit, 'String', min_y_lim);
        set(GUI.GUIDisplay.MaxYLimit_Edit, 'String', max_y_lim);
        setYECGGrid(GUI.ECG_Axes, GUI.GridY_checkbox);
    end
%%
    function setRRIntYLim()
        if GUI.AutoScaleYLowAxes_checkbox.Value
            [low_y_lim, hight_y_lim] = calc_auto_y_low_axes_lim();
            set(GUI.RRInt_Axes, 'YLim', [low_y_lim hight_y_lim]);
            
            set_min_max_low_axes_y_lim_string(low_y_lim, hight_y_lim);
        end
        
        set_rectangles_YData();
    end
%%
    function [low_y_lim, hight_y_lim] = calc_auto_y_low_axes_lim()
        xlim = get(GUI.RRInt_Axes, 'XLim');
        ylim = get(GUI.RRInt_Axes, 'YLim');
        
        if isfield(DATA, 'rr_data_filtered') && ~isempty(DATA.rr_data_filtered)
            
            current_y_data = DATA.rr_data_filtered(DATA.rr_time_filtered >= xlim(1) & DATA.rr_time_filtered <= xlim(2));
            
            if length(current_y_data) < 2
                min_y_lim = min(ylim);
                max_y_lim = max(ylim);
            else
                min_sig = min(current_y_data);
                max_sig = max(current_y_data);
                delta = (max_sig - min_sig)*0.1;
                
                min_y_lim = min(min_sig, max_sig) - delta;
                max_y_lim = max(min_sig, max_sig) + delta;
            end
            
            if DATA.PlotHR == 1
                max_y_lim = 60 ./ max_y_lim;
                min_y_lim = 60 ./ min_y_lim;
            end
            
            low_y_lim = min(min_y_lim, max_y_lim);
            hight_y_lim = max(min_y_lim, max_y_lim);
        end
    end
%%
    function set_rectangles_YData()
        
        ylim = get(GUI.RRInt_Axes, 'YLim');
        low_y_lim = min(ylim);
        hight_y_lim = max(ylim);
        
        if isfield(GUI, 'red_rect_handle') && any(isvalid(GUI.red_rect_handle))
            set(GUI.red_rect_handle, 'YData', [low_y_lim low_y_lim hight_y_lim hight_y_lim low_y_lim]);
        end
        
        if isfield(GUI, 'PinkLineHandle_AllDataAxes') && any(isvalid(GUI.PinkLineHandle_AllDataAxes))
            for i = 1 : length(GUI.PinkLineHandle_AllDataAxes)
                set(GUI.PinkLineHandle_AllDataAxes(i), 'YData', [low_y_lim low_y_lim hight_y_lim hight_y_lim]);
            end
        end
        if isfield(GUI, 'RhythmsHandle_AllDataAxes') && any(isvalid(GUI.RhythmsHandle_AllDataAxes))
            for i = 1 : length(GUI.RhythmsHandle_AllDataAxes)
                set(GUI.RhythmsHandle_AllDataAxes(i), 'YData', [low_y_lim low_y_lim hight_y_lim hight_y_lim]);
            end
        end
    end
%%
    function MinMaxYLimitLowAxes_Edit_Callback(src, ~)
        minLimit = str2double(GUI.GUIDisplay.MinYLimitLowAxes_Edit.String);
        maxLimit = str2double(GUI.GUIDisplay.MaxYLimitLowAxes_Edit.String);
        
        if ~isnan(minLimit) && ~isnan(maxLimit) && minLimit < maxLimit
            src.UserData(DATA.PlotHR+1) = str2double(src.String);
            set(GUI.RRInt_Axes, 'YLim', [minLimit maxLimit]);
        else
            src.String = src.UserData(DATA.PlotHR+1);
            h_e = errordlg('Please, enter correct values!', 'Input Error'); setLogo(h_e, 'M1');
        end
        GridX_checkbox_Callback;
        GridY_checkbox_Callback;
        set_rectangles_YData();
    end
%%
    function clean_config_param_fields()
        
        params_GUI_edit_values = findobj(GUI.ConfigBox, 'Style', 'edit');
        fields_names = get(params_GUI_edit_values, 'UserData');
        
        for i = 1 : length(params_GUI_edit_values)
            if ~isempty(fields_names{i})
                set(params_GUI_edit_values(i), 'String', num2str(0));
            end
        end
    end
%%
    function load_updateGUI_config_param()
        
        if isfield(DATA, 'config_map') && ~isempty(DATA.config_map)
            params_GUI_edit_values = findobj(GUI.ConfigBox, 'Style', 'edit');
            fields_names = get(params_GUI_edit_values, 'UserData');
            
            for i = 1 : length(params_GUI_edit_values)
                if ~isempty(fields_names{i})
                    try
                        param_value = DATA.config_map(fields_names{i});
                        tooltip = DATA.config_struct.(fields_names{i}).description;
                        set(params_GUI_edit_values(i), 'String', param_value, 'Tooltip', tooltip);
                    catch
                    end
                end
            end
            
            % Check that the upper frequency of the filter is below Fs/2
            if DATA.Fs/2 < str2double(get(GUI.GUIConfig.hcf, 'String'))
                set(GUI.GUIConfig.hcf, 'String', floor(DATA.Fs/2) - 2);
            end
            
            DATA.config_map(get(GUI.GUIConfig.hcf, 'UserData')) = str2double(get(GUI.GUIConfig.hcf, 'String'));
            
            DATA.customConfigFile = [tempdir 'gqrs.temp_custom.conf'];
            temp_custom_conf_fileID = saveCustomParameters(DATA.customConfigFile);
            
            if temp_custom_conf_fileID == -1
                h_e = errordlg('Problems with creation of custom config file.', 'Input Error');
                setLogo(h_e, 'M1');
                return;
            end
            
        else
            throw(MException('LoadConfig:text', 'Config file does''t exist.'));
        end
    end
%%
    function RunAndPlotPeakDetector()
        if isfield(DATA, 'wfdb_record_name') && ~strcmp(DATA.wfdb_record_name, '')
            
            cla(GUI.RRInt_Axes);
            if isfield(GUI, 'red_peaks_handle') && ishandle(GUI.red_peaks_handle) && isvalid(GUI.red_peaks_handle)
                delete(GUI.red_peaks_handle);
            end
            try
                if isfield(DATA, 'customConfigFile') && ~strcmp(DATA.customConfigFile, '')
                    
                    pd_items = get(GUI.GUIRecord.PeakDetector_popupmenu, 'String');
                    pd_index_selected = get(GUI.GUIRecord.PeakDetector_popupmenu, 'Value');
                    
                    peak_detector = pd_items{pd_index_selected};
                    
                    waitbar_handle = waitbar(1/2, 'Compute peaks...', 'Name', 'Computing');
                    setLogo(waitbar_handle, 'M1');
                    
                    if ~strcmpi(peak_detector, 'rqrs') && ~strcmpi(peak_detector, 'EGM peaks')
                        
                        lcf = DATA.config_map('lcf');
                        hcf = DATA.config_map('hcf');
                        thr = DATA.config_map('thr');
                        rp  = DATA.config_map('rp');
                        ws  = DATA.config_map('ws');
                        
                        bpecg = mhrv.ecg.bpfilt(DATA.sig, DATA.Fs, lcf, hcf, [], 0);  % bpecg = prefilter2(ecg,fs,lcf,hcf,0);
                    end
                    
                    if strcmp(peak_detector, 'jqrs')
                        qrs_pos = mhrv.ecg.jqrs(bpecg, DATA.Fs, thr, rp, 0); % qrs_pos = ptqrs(bpecg,fs,thr,rp,0);
                        DATA.qrs = qrs_pos';
                    elseif strcmp(peak_detector, 'wjqrs')
                        qrs_pos = mhrv.ecg.wjqrs(bpecg, DATA.Fs, thr, rp, ws);
                        DATA.qrs = qrs_pos';
                    elseif strcmp(peak_detector, 'EGM peaks')
                        params_struct = struct();
                        
                        params_struct.Fs = DATA.Fs;
                        try
                            %                             params_struct.alpha = DATA.config_map('alpha');
                            params_struct.refractory_period = DATA.config_map('ref_per');
                            params_struct.BI = DATA.config_map('bi');
                            tic
                            qrs_pos = EGM_peaks(DATA.sig, params_struct, 0);
                            toc
                            DATA.qrs = qrs_pos;
                        catch
                            h_e = errordlg('The parameters for the EGM algorithms were not defined.', 'Input Error');
                            setLogo(h_e, 'M1');
                        end
                    else
                        if exist(fullfile([DATA.wfdb_record_name '.dat']), 'file') && exist(fullfile([DATA.wfdb_record_name '.hea']), 'file')
                            
                            %                             mhrv.defaults.mhrv_set_default('rqrs.window_size_sec', 0.8 * str2double(get(GUI.GUIConfig.QS, 'String')));
                            mhrv.defaults.mhrv_set_default('rqrs.window_size_sec', DATA.config_map('window_size_sec'));
                            
                            [DATA.qrs, tm, sig, Fs] = mhrv.wfdb.rqrs(DATA.wfdb_record_name, 'gqconf', DATA.customConfigFile, 'ecg_channel', DATA.ecg_channel, 'plot', false);
                        else
                            throw(MException('calc_peaks:text', 'Problems with peaks calculation. Wfdb file not exists.'));
                        end
                    end
                    if isvalid(waitbar_handle)
                        close(waitbar_handle);
                    end
                    
                    if ~isempty(DATA.qrs)
                        DATA.qrs_saved = DATA.qrs;
                        DATA.qrs = double(DATA.qrs);
                        GUI.red_peaks_handle = line(DATA.tm(DATA.qrs), DATA.sig(DATA.qrs, 1), 'Parent', GUI.ECG_Axes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'LineWidth', 2, 'Tag', 'Peaks');
                        uistack(GUI.red_peaks_handle, 'top');  % bottom
                        
                        plot_rr_data();
                        plot_red_rectangle(DATA.zoom_rect_limits);
                        GUI.PeaksTable.Data(:, 2) = {0};
                        DATA.peaks_added = 0;
                        DATA.peaks_deleted = 0;
                        DATA.peaks_total = length(DATA.qrs);
                        GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
                        
                        set(GUI.GUIDisplay.FirstSecond, 'String', calcDuration(min(DATA.zoom_rect_limits), 0));
                        
                        WindowSize_value = max(DATA.zoom_rect_limits) - min(DATA.zoom_rect_limits);
                        GUI.GUIDisplay.WindowSize.String = calcDuration(WindowSize_value, 0);
                        GUI.GUIDisplay.WindowSize.UserData = WindowSize_value;
                        
                        set(GUI.GUIDisplay.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
                        set(GUI.RRInt_Axes, 'XLim', [0 DATA.maxRRTime]);
                        setAxesXTicks(GUI.RRInt_Axes);
                        setRRIntYLim();
                        EnablePageUpDown();
                    else
                        GUI.PeaksTable.Data(:, 2) = {0};
                        DATA.peaks_added = 0;
                        DATA.peaks_deleted = 0;
                        DATA.peaks_total = length(DATA.qrs);
                        GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
                        h_e = errordlg('The algorithm could not run. Please, check input parameters.', 'Input Error');
                        setLogo(h_e, 'M1');
                    end
                end
            catch e
                if isvalid(waitbar_handle)
                    close(waitbar_handle);
                end
                GUI.PeaksTable.Data(:, 2) = {0};
                DATA.peaks_added = 0;
                DATA.peaks_deleted = 0;
                DATA.peaks_total = length(DATA.qrs);
                GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
                rethrow(e);
            end
            set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
            set(GUI.Window, 'WindowButtonUpFcn', @my_WindowButtonUpFcn);
            set(GUI.Window, 'WindowButtonDownFcn', @my_WindowButtonDownFcn);
            set(GUI.Window, 'WindowScrollWheelFcn', @my_WindowScrollWheelFcn);
            set(GUI.Window, 'WindowKeyPressFcn', @my_WindowKeyPressFcn);
            set(GUI.Window, 'WindowKeyReleaseFcn', @my_WindowKeyReleaseFcn);
            
            GUI.timer_object = timer;
            GUI.timer_object.ExecutionMode = 'fixedRate';
            GUI.timer_object.StopFcn = @EnablePageUpDown;
        end
    end
%%
    function plot_red_rectangle(xlim)
        ylim = get(GUI.RRInt_Axes, 'YLim');
        x_box = [min(xlim) max(xlim) max(xlim) min(xlim) min(xlim)];
        y_box = [ylim(1) ylim(1) ylim(2) ylim(2) ylim(1)];
        GUI.red_rect_handle = line(x_box, y_box, 'Color', 'r', 'Linewidth', 2, 'Parent', GUI.RRInt_Axes, 'Tag', 'red_zoom_rect');
    end
%%
    function plot_rr_data()
        if isfield(DATA, 'qrs')
            
            qrs = double(DATA.qrs(~isnan(DATA.qrs)));
            
            rr_time = qrs(1:end-1)/DATA.Fs;
            rr_data = diff(qrs)/DATA.Fs;
            
            if isempty(rr_data)
                throw(MException('plot_rr_data:text', 'Not enough datapoints!'));
            else
                try
                    [rr_data_filtered, rr_time_filtered, ~] = mhrv.rri.filtrr(rr_data, rr_time, 'filter_quotient', false, 'filter_ma', true, 'filter_range', false);
                catch e
                    rethrow(e);
                end
                
                if isempty(rr_data_filtered)
                    throw(MException('mhrv.rri.filtrr:text', 'Not enough datapoints!'));
                elseif length(rr_data) * 0.1 > length(rr_data_filtered)
                    throw(MException('mhrv.rri.filtrr:text', 'Not enough datapoints!'));
                else
                    
                    if (DATA.PlotHR == 1)
                        rr_data = 60 ./ rr_data;
                        yString = 'HR (BPM)';
                    else
                        yString = 'RR (sec)';
                    end
                    
                    GUI.RRInt_handle = line(rr_time, rr_data, 'Parent', GUI.RRInt_Axes, 'Marker', '*', 'MarkerSize', 2, 'Tag', 'RRInt');
                    
                    %                     DATA.maxRRTime = max(rr_time_filterd);
                    
                    DATA.maxRRTime = max(DATA.tm);
                    
                    DATA.RRIntPage_Length = DATA.maxRRTime;
                    
                    %                     min_sig = min(rr_data_filtered);
                    %                     max_sig = max(rr_data_filtered);
                    %                     delta = (max_sig - min_sig)*0.1;
                    %
                    %                     RRMinYLimit = min(min_sig, max_sig) - delta;
                    %                     RRMaxYLimit = max(min_sig, max_sig) + delta;
                    %
                    %                     set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'String', num2str(RRMinYLimit));
                    %                     set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'String', num2str(RRMaxYLimit));
                    %
                    %                     if RRMaxYLimit > RRMinYLimit
                    %                         set(GUI.RRInt_Axes, 'YLim', [RRMinYLimit RRMaxYLimit]);
                    %                     end
                    
                    ylabel(GUI.RRInt_Axes, yString);
                    
                    
                    DATA.rr_data_filtered = rr_data_filtered;
                    DATA.rr_time_filtered = rr_time_filtered;
                    
                    %                     setRRIntYLim();
                end
            end
        end
    end
%%
    function LoadConfigurationFile_Callback(~, ~)
        
        persistent DIRS;
        
        % Add third-party dependencies to path
        gui_basepath = fileparts(mfilename('fullpath'));
        basepath = fileparts(gui_basepath);
        
        if isdeployed
            res_parh = [userpath filesep 'PhysioZoo' filesep 'Results'];
        else
            res_parh = [basepath filesep 'Results'];
        end
        
        if ~isdir(res_parh)
            warning('off');
            mkdir(res_parh);
            warning('on');
        end
        
        if ~isfield(DIRS, 'analyzedDataDirectory')
            DIRS.analyzedDataDirectory = res_parh;
        end
        
        %         [Config_FileName, PathName] = uigetfile({'*.conf','Conf files (*.conf)'}, 'Open Configuration File', [DIRS.analyzedDataDirectory filesep 'gqrs.custom.conf']);
        [Config_FileName, PathName] = uigetfile({'*.yml','Conf files (*.yml)'}, 'Open Configuration File', [DIRS.analyzedDataDirectory filesep 'qrs.custom.yml']);
        if ~isequal(Config_FileName, 0)
            DATA.customConfigFile = fullfile(PathName, Config_FileName);
            
            set_new_mammal(DATA.customConfigFile);
            
            if get(GUI.AutoCalc_checkbox, 'Value')
                try
                    RunAndPlotPeakDetector();
                    
                    if DATA.Adjust % no default
                        PeakAdjustment(DATA.qrs_saved);
                    end
                catch e
                    h_e = errordlg(['LoadConfigurationFile error: ' e.message], 'Input Error');
                    setLogo(h_e, 'M1');
                    return;
                end
            end
        end
    end
%%
    function SaveConfigurationFile_Callback(~, ~)
        
        persistent DIRS;
        
        % Add third-party dependencies to path
        gui_basepath = fileparts(mfilename('fullpath'));
        basepath = fileparts(gui_basepath);
        
        if isdeployed
            res_parh = [userpath filesep 'PhysioZoo' filesep 'Results'];
        else
            res_parh = [basepath filesep 'Results'];
        end
        
        if ~isdir(res_parh)
            warning('off');
            mkdir(res_parh);
            warning('on');
        end
        
        if ~isfield(DIRS, 'analyzedDataDirectory')
            DIRS.analyzedDataDirectory = res_parh;
        end
        
        %         [filename, results_folder_name, ~] = uiputfile({'*.','Conf Files (*.conf)'},'Choose Config File Name', [DIRS.analyzedDataDirectory filesep 'gqrs.custom.conf']);
        [filename, results_folder_name, ~] = uiputfile({'*.yml','Conf Files (*.yml)'},'Choose Config File Name', [DIRS.analyzedDataDirectory filesep 'qrs.custom.yml']);
        
        if ~isequal(results_folder_name, 0)
            full_file_name_conf = fullfile(results_folder_name, filename);
            button = 'Yes';
            if exist(full_file_name_conf, 'file')
                button = questdlg([full_file_name_conf ' already exist. Do you want to overwrite it?'], 'Overwrite existing file?', 'Yes', 'No', 'No');
            end
            
            config_keys = keys(DATA.config_map);
            %             config_fields = fieldnames(config_keys);
            
            for i = 1 : length(config_keys)
                curr_field = config_keys{i};
                if isstruct(DATA.config_struct.(curr_field))
                    DATA.config_struct.(curr_field).value = DATA.config_map(curr_field);
                else
                    DATA.config_struct.(curr_field) = DATA.config_map(curr_field);
                end
            end
            
            if strcmp(button, 'Yes')
                %                 saveCustomParameters(full_file_name_conf);
                WriteYaml(full_file_name_conf, DATA.config_struct);
            end
            
        end
    end
%%
    function temp_custom_conf_fileID = saveCustomParameters2ConfFile(FullFileName)
        
        if isfield(DATA, 'config_map')
            
            config_param_names = DATA.config_map.keys();
            %             config_param_values = values(DATA.config_map);
            
            temp_custom_conf_fileID = fopen(FullFileName, 'w');
            if temp_custom_conf_fileID ~= -1
                fprintf(temp_custom_conf_fileID, '# config file for custom parameters:\r\n');
                for i = 1 : length(DATA.config_map)
                    curr_key = config_param_names{i};
                    fprintf(temp_custom_conf_fileID, '%s\t%s\r\n', curr_key, DATA.config_map(curr_key).value);
                end
            end
            fclose(temp_custom_conf_fileID);
        end
    end
%%
    function temp_custom_conf_fileID = saveCustomParameters(FullFileName)
        
        if isfield(DATA, 'config_map')
            
            config_param_names = keys(DATA.config_map);
            config_param_values = values(DATA.config_map);
            
            temp_custom_conf_fileID = fopen(FullFileName, 'w');
            if temp_custom_conf_fileID ~= -1
                fprintf(temp_custom_conf_fileID, '# config file for custom parameters:\r\n');
                for i = 1 : length(DATA.config_map)
                    fprintf(temp_custom_conf_fileID, '%s\t%s\r\n', config_param_names{i}, num2str(config_param_values{i}));
                end
            end
            fclose(temp_custom_conf_fileID);
        end
    end
%%
    function config_map = parse_gqrs_config_file(file_name)
        
        config_map = containers.Map;
        
        f_h = fopen(file_name);
        
        if f_h ~= -1
            while ~feof(f_h)
                tline = fgetl(f_h);
                if ~isempty(tline) && ~strcmp(tline(1), '#')
                    comments_index = regexp(tline, '#');
                    if ~isempty(comments_index)
                        tline = tline(1 : comments_index - 1);
                    end
                    
                    if ~isempty(tline)
                        parameters_cell = strsplit(tline);
                        if ~isempty(parameters_cell{1})
                            value = '';
                            for i = 2 : length(parameters_cell)
                                if ~isempty(parameters_cell{i})
                                    value = [value parameters_cell{i} ' '];
                                end
                            end
                            config_map(parameters_cell{1}) = value(1 : end - 1);
                        end
                    end
                end
            end
            fclose(f_h);
        end
    end
%%
    function config_edit_Callback(src, ~)
        
        if isfield(DATA, 'config_map')
            field_value = get(src, 'String');
            numeric_field_value = str2double(field_value);
            
            if isnan(numeric_field_value)
                h_e = errordlg('Please, enter numeric value.', 'Input Error'); setLogo(h_e, 'M1');
                set(src, 'String', DATA.config_map(get(src, 'UserData')));
                return;
            elseif strcmp(get(src, 'UserData'), 'rp') && ~(numeric_field_value >= 0)
                h_e = errordlg('The refractory period must be greater or equal to 0.', 'Input Error');
                setLogo(h_e, 'M1');
                set(src, 'String', DATA.config_map(get(src, 'UserData')));
                return;
            elseif (numeric_field_value <= 0) && ~(strcmp(get(src, 'UserData'), 'rp'))
                h_e = errordlg('The value must be greater then 0.', 'Input Error');
                setLogo(h_e, 'M1');
                set(src, 'String', DATA.config_map(get(src, 'UserData')));
                return;
            end
            if strcmp(get(src, 'UserData'), 'hcf') && (numeric_field_value > DATA.Fs/2)
                h_e = errordlg('The upper cutoff frequency must be inferior to half of the sampling frequency.', 'Input Error');
                setLogo(h_e, 'M1');
                set(src, 'String', DATA.config_map(get(src, 'UserData')));
                return;
            end
            
            if strcmp(get(src, 'UserData'), 'bi')
                if (numeric_field_value < 0 || numeric_field_value > 20000)
                    h_e = errordlg('The beating interval must be in the range of 0 - 20000.', 'Input Error');
                    setLogo(h_e, 'M1');
                    set(src, 'String', DATA.config_map(get(src, 'UserData')));
                    return;
                end
                if numeric_field_value <= DATA.config_map('ref_per')
                    h_e = errordlg('The beating interval must be greater than refractory period.', 'Input Error');
                    setLogo(h_e, 'M1');
                    set(src, 'String', DATA.config_map(get(src, 'UserData')));
                    return;
                end
            end
            
            %         if strcmp(get(src, 'UserData'), 'alpha') && (numeric_field_value < 0 || numeric_field_value > 20)
            %             h_e = errordlg('Alpha must be in the range of 0 - 20.', 'Input Error');
            %             setLogo(h_e, 'M1');
            %             set(src, 'String', DATA.config_map(get(src, 'UserData')));
            %             return;
            %         end
            
            if strcmp(get(src, 'UserData'), 'ref_per')
                if (numeric_field_value < 0 || numeric_field_value > 20000)
                    h_e = errordlg('The refractory period must be in the range of 0 - 20000', 'Input Error');
                    setLogo(h_e, 'M1');
                    set(src, 'String', DATA.config_map(get(src, 'UserData')));
                    return;
                elseif numeric_field_value > DATA.config_map('bi')
                    h_e = errordlg('The beating interval must be greater than refractory period.', 'Input Error');
                    setLogo(h_e, 'M1');
                    set(src, 'String', DATA.config_map(get(src, 'UserData')));
                    return;
                end
            end
            
            if isfield(DATA, 'config_map') && ~isempty(DATA.config_map)
                DATA.config_map(get(src, 'UserData')) = numeric_field_value;
                DATA.customConfigFile = [tempdir 'gqrs.temp_custom.conf'];
                temp_custom_conf_fileID = saveCustomParameters(DATA.customConfigFile);
                if temp_custom_conf_fileID == -1
                    h_e = errordlg('Problems with creation of custom config file.', 'Input Error');
                    setLogo(h_e, 'M1');
                    return;
                end
                if get(GUI.AutoCalc_checkbox, 'Value')
                    try
                        RunAndPlotPeakDetector();
                        set(GUI.GUIRecord.PeakAdjustment_popupmenu, 'Value', 1);
                    catch e
                        h_e = errordlg(['config_edit_Callback error: ' e.message], 'Input Error');
                        setLogo(h_e, 'M1');
                        return;
                    end
                end
            end
        end
    end
%%
    function Peaks_Window_edit_Callback(src, ~)
        
        if isfield(DATA, 'peak_search_win')
            str_field_value = get(src, 'String');
            field_value = str2double(str_field_value);
            
            if field_value > 0 && field_value < 1000
                DATA.peak_search_win = field_value;
                
                if DATA.Adjust % no default
                    PeakAdjustment(DATA.qrs_saved);
                end
                
                DATA.config_map(get(src, 'UserData')) = field_value;
                DATA.customConfigFile = [tempdir 'gqrs.temp_custom.conf'];
                temp_custom_conf_fileID = saveCustomParameters(DATA.customConfigFile);
                if temp_custom_conf_fileID == -1
                    h_e = errordlg('Problems with creation of custom config file.', 'Input Error');
                    setLogo(h_e, 'M1');
                    return;
                end
            else
                set(src, 'String', num2str(DATA.peak_search_win));
                h_e = errordlg('The window length for peak detection must be greater than 0 and less than 1 sec.', 'Input Error');
                setLogo(h_e, 'M1');
            end
        end
    end
%%
    function delete_temp_wfdb_files()
        if exist([tempdir DATA.temp_rec_name4wfdb '.hea'], 'file')
            delete([tempdir DATA.temp_rec_name4wfdb '.hea']);
        end
        if exist([tempdir DATA.temp_rec_name4wfdb '.dat'], 'file')
            delete([tempdir DATA.temp_rec_name4wfdb '.dat']);
        end
        if exist([tempdir 'tempYAML.yml'], 'file')
            delete([tempdir 'tempYAML.yml']);
        end
    end
%%
    function load_peaks(Peaks_FileName, PathName, DataFileMap)
        
        persistent DIRS;
        
        % Add third-party dependencies to path
        gui_basepath = fileparts(mfilename('fullpath'));
        basepath = fileparts(gui_basepath);
        if ~isfield(DIRS, 'analyzedDataDirectory')
            DIRS.analyzedDataDirectory = [basepath filesep 'ExamplesTXT'];
        end
        
        if ~isequal(Peaks_FileName, 0)
            
            [~, PeaksFileName, ExtensionFileName] = fileparts(Peaks_FileName);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            DIRS.analyzedDataDirectory = PathName;
            
            DATA.peaks_file_name = [PathName, PeaksFileName];
            %             cla(GUI.RRInt_Axes);
            
            set(GUI.GUIRecord.PeaksFileName_text, 'String', Peaks_FileName);
            
            if strcmpi(ExtensionFileName, 'mat') || strcmpi(ExtensionFileName, 'txt') || strcmpi(ExtensionFileName, 'qrs') || strcmpi(ExtensionFileName, 'atr')
                
                try
                    Config = ReadYaml('Loader Config.yml');
                    
                    if isempty(fields(DataFileMap))
                        DataFileMap = loadDataFile([DATA.peaks_file_name '.' EXT]);
                    end
                    
                    MSG = DataFileMap('MSG');
                    if strcmp(Config.alarm.(MSG), 'OK')
                        data = DataFileMap('DATA');
                        if ~strcmp(data.Data.Type, 'electrography')
                            Mammal = data.General.mammal;
                            integration = data.General.integration_level;
                            DATA.Fs = data.Time.Fs;
                            
                            time_data = data.Time.Data;
                            DATA.qrs = int64(time_data * DATA.Fs);
                            DATA.qrs_saved = DATA.qrs;
                            
                            if ~strcmp(Mammal, DATA.config_map('mammal')) || ~strcmp(integration, DATA.Integration_From_Files{DATA.integration_index})
                                h_e = warndlg('Mammal and/or integration level of data file does not match the one of the peaks file.', 'Warning');
                                setLogo(h_e, 'M1');
                                uiwait(h_e);
                            end
                        else
                            h_e = errordlg(['on Load Peaks error: ' 'Please, choose another file type.'], 'Input Error');
                            setLogo(h_e, 'M1');
                            return;
                        end
                    elseif strcmp(Config.alarm.(MSG), 'Canceled')
                        return;
                    else
                        h_e = errordlg(['on Load Peaks error: ' Config.alarm.(MSG)], 'Input Error');
                        setLogo(h_e, 'M1');
                        return;
                    end
                catch e
                    h_e = errordlg(['onOpenFile error: ' e.message], 'Input Error');
                    setLogo(h_e, 'M1');
                    return;
                end
            else
                h_e = errordlg(['on Load Peaks error: ' 'Please, choose another file type.'], 'Input Error');
                setLogo(h_e, 'M1');
                return;
            end
            
            DATA.peaks_total = length(DATA.qrs);
            DATA.peaks_added = 0;
            DATA.peaks_deleted = 0;
            GUI.PeaksTable.Data(:, 2) = {0};
            GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
            
            DATA.zoom_rect_limits = [0 DATA.firstZoom];
            right_limit2plot = min(DATA.firstZoom, max(DATA.tm));
            setECGXLim(0, right_limit2plot);
            setECGYLim(0, right_limit2plot);
            
            if ~isempty(DATA.qrs)
                if isfield(GUI, 'red_peaks_handle') && ishandle(GUI.red_peaks_handle) && isvalid(GUI.red_peaks_handle)
                    delete(GUI.red_peaks_handle);
                end
                DATA.qrs = double(DATA.qrs);
                GUI.red_peaks_handle = line(DATA.tm(DATA.qrs), DATA.sig(DATA.qrs, 1), 'Parent', GUI.ECG_Axes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'LineWidth', 2, 'Tag', 'Peaks');
                uistack(GUI.red_peaks_handle, 'bottom');
                
                if isfield(GUI, 'RRInt_handle') && ishandle(GUI.RRInt_handle) && isvalid(GUI.RRInt_handle)
                    delete(GUI.RRInt_handle);
                end
                try
                    delete(GUI.red_rect_handle);
                    delete(GUI.RRInt_handle);
                    
                    plot_rr_data();
                    
                    if isfield(GUI, 'red_rect_handle') && ishandle(GUI.red_rect_handle) && isvalid(GUI.red_rect_handle)
                        delete(GUI.red_rect_handle);
                    end
                    
                    plot_red_rectangle(DATA.zoom_rect_limits);
                    
                    set(GUI.RRInt_Axes, 'XLim', [0 DATA.maxRRTime]);
                    setAxesXTicks(GUI.RRInt_Axes);
                    setRRIntYLim();
                    
                    set(GUI.GUIDisplay.FirstSecond, 'String', calcDuration(min(DATA.zoom_rect_limits), 0));
                    
                    WindowSize_value = max(DATA.zoom_rect_limits)-min(DATA.zoom_rect_limits);
                    GUI.GUIDisplay.WindowSize.String = calcDuration(WindowSize_value, 0);
                    GUI.GUIDisplay.WindowSize.UserData = WindowSize_value;
                    
                    set(GUI.GUIDisplay.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
                    
                    set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
                    set(GUI.Window, 'WindowButtonUpFcn', @my_WindowButtonUpFcn);
                    set(GUI.Window, 'WindowButtonDownFcn', @my_WindowButtonDownFcn);
                catch
                end
            else
                h_e = errordlg('The algorithm could not run. Please, check input parameters.', 'Input Error');
                setLogo(h_e, 'M1');
            end
        end
    end
%%
    function SavePeaks_Callback(~, ~)
        
        persistent DIRS;
        persistent EXT;
        
        % Add third-party dependencies to path
        gui_basepath = fileparts(mfilename('fullpath'));
        basepath = fileparts(gui_basepath);
        
        if isdeployed
            res_parh = [userpath filesep 'PhysioZoo' filesep 'Results'];
        else
            res_parh = [basepath filesep 'Results'];
        end
        
        if ~isdir(res_parh)
            warning('off');
            mkdir(res_parh);
            warning('on');
        end
        
        if ~isfield(DIRS, 'analyzedDataDirectory')
            DIRS.analyzedDataDirectory = res_parh;
        end
        if isempty(EXT)
            EXT = 'txt';
        end
        
        original_file_name = DATA.DataFileName;
        file_name = [original_file_name, '_peaks'];
        
        [filename, results_folder_name, ~] = uiputfile({'*.*', 'All files';...
            '*.txt','Text Files (*.txt)';...
            '*.mat','MAT-files (*.mat)';
            '*.qrs; *.atr',  'WFDB Files (*.qrs; *.atr)'},...
            'Choose Analyzed Data File Name',...
            [DIRS.analyzedDataDirectory, filesep, file_name, '.', EXT]);
        
        % ;'*.qrs; *.atr',  'WFDB Files (*.qrs; *.atr)'
        
        if ~isequal(results_folder_name, 0)
            DIRS.analyzedDataDirectory = results_folder_name;
            [~, ~, ExtensionFileName] = fileparts(filename);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            
            Data = DATA.qrs;
            Fs = DATA.Fs;
            Integration_level = DATA.Integration_From_Files{DATA.integration_index};
            Mammal = get(GUI.GUIRecord.Mammal_popupmenu, 'String');
            
            Channels{1}.name = 'interval';
            Channels{1}.enable = 'yes';
            Channels{1}.type = 'peak';
            Channels{1}.unit = 'index';
            
            full_file_name = [results_folder_name, filename];
            
            if strcmpi(ExtensionFileName, 'mat')
                save(full_file_name, 'Data', 'Fs', 'Integration_level', 'Mammal', 'Channels');
            elseif strcmpi(ExtensionFileName, 'txt')
                header_fileID = fopen(full_file_name, 'wt');
                
                fprintf(header_fileID, '---\n');
                
                fprintf(header_fileID, 'Mammal:            %s\n', Mammal);
                fprintf(header_fileID, 'Fs:                %d\n', Fs);
                fprintf(header_fileID, 'Integration_level: %s\n\n', Integration_level);
                
                fprintf(header_fileID, 'Channels:\n\n');
                fprintf(header_fileID, '    - type:   %s\n', Channels{1}.type);
                fprintf(header_fileID, '      name:   %s\n', Channels{1}.name);
                fprintf(header_fileID, '      unit:   %s\n', Channels{1}.unit);
                fprintf(header_fileID, '      enable: %s\n\n', Channels{1}.enable);
                
                fprintf(header_fileID, '---\n');
                
                dlmwrite(full_file_name, Data, 'delimiter', '\t', 'precision', '%d', 'newline', 'pc', '-append', 'roffset', 1);
                
                fclose(header_fileID);
            elseif strcmpi(ExtensionFileName, 'qrs') || strcmpi(ExtensionFileName, 'atr')
                [~, filename_noExt, ~] = fileparts(filename);
                
                try
                    %                                         wfdb_path = 'D:\Temp\wfdb-app-toolbox-0-9-10\mcode';
                    %                                         addpath(wfdb_path);
                    %                                         mat2wfdb(Data, filename_noExt, Fs, [], ' ', {}, [], {strcat(Integration_level, '-', Mammal)});
                    %                                         mhrv.wfdb.wrann(filename_noExt, 'qrs', int64(Data));
                    %                                         rmpath(wfdb_path);
                    %                                         delete([filename_noExt '.dat']);
                    
                    %                     if ~mhrv.wfdb.isrecord([results_folder_name filename_noExt], 'hea')
                    %                         % Create header
                    %                         saved_path = pwd;
                    %                         cd(results_folder_name);
                    %                         mat2wfdb(Data, filename_noExt, Fs, [], ' ', {}, [], {strcat(Integration_level, '-', Mammal)});
                    %                         delete([filename_noExt '.dat']);
                    %                         cd(saved_path);
                    %                     end
                    
                    comments = {['Mammal:' Mammal ',Integration_level:' Integration_level]};
                    
                    %                     mhrv.wfdb.wrann([results_folder_name filename_noExt], 'qrs', int64(Data), 'fs', Fs, 'comments', [DATA.Integration '-' DATA.Mammal]);
                    
                    mhrv.wfdb.wrann([results_folder_name filename_noExt], ExtensionFileName, int64(Data), 'fs', Fs, 'comments', comments); % , 'comments', {[DATA.Integration '-' DATA.Mammal]}
                    
                catch e
                    disp(e);
                end
            else
                h_e = errordlg('Please, choose only *.mat or *.txt file .', 'Input Error');
                setLogo(h_e, 'M1');
                return;
            end
        end
    end
%%
    function AutoCompute_pushbutton_Callback( ~, ~ )
        try
            RunAndPlotPeakDetector();
            PeakAdjustment(DATA.qrs);
        catch e
            h_e = errordlg(['AutoCompute pushbutton callback error: ' e.message], 'Input Error');
            setLogo(h_e, 'M1');
            return;
        end
    end
%%
    function AutoCalc_checkbox_Callback(src, ~ )
        if get(src, 'Value') == 1
            GUI.AutoCompute_pushbutton.Enable = 'off';
        else
            GUI.AutoCompute_pushbutton.Enable = 'on';
        end
    end
%%
    function RR_or_HR_plot_button_Callback(~, ~)
        
        if isfield(DATA, 'sig') && ~isempty(DATA.sig)
            if(DATA.PlotHR == 1)
                set(GUI.RR_or_HR_plot_button, 'String', 'Plot HR');
                DATA.PlotHR = 0;
            else
                set(GUI.RR_or_HR_plot_button, 'String', 'Plot RR');
                DATA.PlotHR = 1;
            end
            try
                delete(GUI.red_rect_handle);
                delete(GUI.RRInt_handle);
                
                plot_rr_data();
                plot_red_rectangle(DATA.zoom_rect_limits);
                [low_y_lim, hight_y_lim] = calc_auto_y_low_axes_lim();
                
                set(GUI.RRInt_Axes, 'YLim', [low_y_lim hight_y_lim]);
                
                set_min_max_low_axes_y_lim_string(low_y_lim, hight_y_lim);
                
                set_rectangles_YData();
            catch e
                disp(e.mesage);
            end
        end
    end
%%
    function set_min_max_low_axes_y_lim_string(low_y_lim, hight_y_lim)
        GUI.GUIDisplay.MinYLimitLowAxes_Edit.String = num2str(low_y_lim);
        GUI.GUIDisplay.MaxYLimitLowAxes_Edit.String = num2str(hight_y_lim);
        
        GUI.GUIDisplay.MinYLimitLowAxes_Edit.UserData(DATA.PlotHR+1) = low_y_lim;
        GUI.GUIDisplay.MaxYLimitLowAxes_Edit.UserData(DATA.PlotHR+1) = hight_y_lim;
    end
%%
    function Reset_pushbutton_Callback(~, ~)
        
        if isfield(DATA, 'sig') && ~isempty(DATA.sig)
            
            GUI.RawData_handle.Visible = 'on';
            
            if isfield(GUI, 'quality_win')
                delete(GUI.quality_win);
                
                GUI = rmfield(GUI, 'quality_win');
                
                DATA.quality_win_num = 0;
                DATA.peaks_total = 0;
                DATA.peaks_bad_quality = 0;
            end
            
            DATA.Rhythms_Map = containers.Map('KeyType', 'double', 'ValueType', 'any');
            
            if isfield(GUI, 'rhythms_win')
                delete(GUI.rhythms_win);
                
                GUI = rmfield(GUI, 'rhythms_win');
                
                DATA.rhythms_win_num = 0;                
            end
            
            if isfield(GUI, 'PinkLineHandle_AllDataAxes')
                delete(GUI.PinkLineHandle_AllDataAxes);
                GUI = rmfield(GUI, 'PinkLineHandle_AllDataAxes');
            end
            
            if isfield(GUI, 'RhythmsHandle_AllDataAxes')
                delete(GUI.RhythmsHandle_AllDataAxes);
                GUI = rmfield(GUI, 'RhythmsHandle_AllDataAxes');
            end
            
            GUI.AutoCalc_checkbox.Value = 1;
            GUI.RR_or_HR_plot_button.String = 'Plot HR';
            DATA.PlotHR = 0;
            set(GUI.GUIRecord.PeaksFileName_text, 'String', '');
            set(GUI.GUIRecord.DataQualityFileName_text, 'String', '');
            set(GUI.GUIRecord.RhythmsFileName_text, 'String', '');
            
            GUI.GUIRecord.Annotation_popupmenu.Value = 1;
            GUI.GUIRecord.Class_popupmenu.Visible = 'off';
            GUI.Class_Text.Visible = 'off';
            GUI.GUIRecord.Class_popupmenu.Value = 3;
            
            GUI.GUIRecord.Rhythms_popupmenu.Visible = 'off';
            GUI.Rhythms_Text.Visible = 'off';
            GUI.GUIRecord.Rhythms_popupmenu.Value = 1;
            
            GUI.GUIRecord.PeakAdjustment_popupmenu.Visible = 'on';
            GUI.Adjustment_Text.Visible = 'on';
            GUI.GUIRecord.PeakAdjustment_popupmenu.Value = 1;
            
            set(GUI.Adjust_textBox, 'Position', GUI.Adjust_textBox_position);
            set(GUI.Class_textBox, 'Position', GUI.Class_textBox_position);
            set(GUI.Rhythms_textBox, 'Position', GUI.Rhythms_textBox_position);
            DATA.Adjust = 0;
            
            GUI.GridX_checkbox.Value = 1;
            GUI.GridY_checkbox.Value = 1;
            set_new_mammal(DATA.init_config_file_name);
            
            reset_movie_buttons();
            GUI.GUIDisplay.Movie_Delay.String = 2;
            
            GUI.AutoScaleY_checkbox.Value = 1;
            GUI.AutoScaleYLowAxes_checkbox.Value = 1;
            
            set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'UserData', []);
            set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'UserData', []);
            
            set(GUI.GUIDisplay.MinYLimit_Edit, 'UserData', '');
            set(GUI.GUIDisplay.MaxYLimit_Edit, 'UserData', '');
            
            reset_rhythm_button();
            Rhythms_ToggleButton_Reset();
            GUI.RhythmsHBox.Visible = 'off';
                        
            GUI.RhythmsTable.Data = {};
            GUI.RhythmsTable.RowName = {};
            DATA.Rhythms_file_name = '';
            set(GUI.GUIRecord.RhythmsFileName_text, 'String', '');
            
            GUI.RawSignal_checkbox.Value = 1;
            GUI.FilteredSignal_checkbox.Value = 0;
            GUI.GUIDisplay.FilterLevel_popupmenu.Value = 1;
            %             GUI.GUIDisplay.LowCutoffFr_Edit.String = 0.5;
            %             GUI.GUIDisplay.HightCutoffFr_Edit.String = 100;
            %             GUI.GUIDisplay.LowCutoffFr_Edit.UserData = 0.5;
            %             GUI.GUIDisplay.HightCutoffFr_Edit.UserData = 100;
            GUI.FilterLevelBox.Visible = 'off';
            GUI.CutoffFrBox.Visible = 'off';
            set_default_filter_level_user_data();
            try
                delete(GUI.FilteredData_handle);
            catch
            end
            
            try
                RunAndPlotPeakDetector();
            catch e
                h_e = errordlg(['AutoCompute_pushbutton_Callback error: ' e.message], 'Input Error');
                setLogo(h_e, 'M1');
                return;
            end
        end
    end
%%
    function reset_movie_buttons()
        GUI.PlayStopForwMovieButton.String = sprintf('\x25BA');
        GUI.PlayStopForwMovieButton.ForegroundColor = [0 1 0];
        GUI.PlayStopForwMovieButton.Value = 0;
        GUI.PlayStopForwMovieButton.Enable = 'on';
        
        GUI.PlayStopReverseMovieButton.String = sprintf('\x25C4');
        GUI.PlayStopReverseMovieButton.ForegroundColor = [0 1 0];
        GUI.PlayStopReverseMovieButton.Value = 0;
        GUI.PlayStopReverseMovieButton.Enable = 'on';
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
        
        if strcmp(GUI.timer_object.Running, 'on')
            stop(GUI.timer_object);
            reset_movie_buttons();
            EnableDisableControls();
            EnableMovieForwardReverse();
        end
        
        hObj = hittest(GUI.Window);
        direction = 1;
        if callbackdata.VerticalScrollCount > 0
            direction = -1;
        elseif callbackdata.VerticalScrollCount < 0
            direction = 1;
        end
        
        % ECG Axes (up axes)
        if (isfield(GUI, 'red_rect_handle') && isvalid(GUI.red_rect_handle)) && (any(ismember([hObj, hObj.Parent], GUI.ECG_Axes)))
            switch DATA.Action
                case 'zoom'
                    xdata = get(GUI.red_rect_handle, 'XData');
                    cp = get(GUI.ECG_Axes, 'CurrentPoint');
                    
                    delta_x1 = cp(1, 1) - xdata(1);
                    delta_x2 = xdata(2) - cp(1, 1);
                    
                    xdata([1, 4, 5]) = xdata(1) + direction * 0.1 * delta_x1;
                    xdata([2, 3]) = xdata(2) - direction * 0.1 * delta_x2;
                    
                    RR_XLim = get(GUI.RRInt_Axes,  'XLim');
                    min_XLim = min(RR_XLim);
                    max_XLim = max(RR_XLim);
                    
                    if xdata(2) <= xdata(1)
                        return;
                    end
                    if xdata(2) - xdata(1) < 0.01
                        return;
                    end
                    
                    if min(xdata) < min_XLim
                        xdata([1, 4, 5]) = min_XLim;
                    end
                    if max(xdata) > max_XLim
                        xdata([2, 3]) = max_XLim ;
                    end
                    
                    ChangePlot(xdata);
                    set(GUI.red_rect_handle, 'XData', xdata);
                    DATA.zoom_rect_limits = [xdata(1) xdata(2)];
                    EnablePageUpDown();
                    redraw_quality_rect();
                    redraw_rhythms_rect();
                otherwise
            end
        end
        
        % RR Interval Axes (down axes)
        if (isfield(GUI, 'red_rect_handle') && isvalid(GUI.red_rect_handle)) && (any(ismember([hObj, hObj.Parent], GUI.RRInt_Axes)))
            switch DATA.Action
                case 'zoom'
                    
                    RRInt_Axes_XLim = get(GUI.RRInt_Axes, 'XLim');
                    RRIntPage_Length = max(RRInt_Axes_XLim) - min(RRInt_Axes_XLim);
                    
                    %                     RRIntPage_Length = get(GUI.GUIDisplay.RRIntPage_Length, 'String');
                    %                     [RRIntPage_Length, isInputNumeric] = calcDurationInSeconds(GUI.GUIDisplay.RRIntPage_Length, RRIntPage_Length, DATA.RRIntPage_Length);
                    
                    if direction > 0
                        RRIntPage_Length = RRIntPage_Length * 0.9;
                    else
                        RRIntPage_Length = RRIntPage_Length * 1.1;
                    end
                    set_RRIntPage_Length(RRIntPage_Length, 2);
                case 'move'
                    if direction > 0
                        page_down_pushbutton_Callback({}, 0, '');
                    else
                        page_up_pushbutton_Callback({}, 0, '');
                    end
                otherwise
            end
        end
    end
%%
    function redraw_quality_rect()
        ylim = get(GUI.ECG_Axes, 'YLim');
        
        if isfield(GUI, 'quality_win')
            for i = 1 : DATA.quality_win_num
                set(GUI.quality_win(i), 'YData', [min(ylim) min(ylim) max(ylim) max(ylim)]);
            end
        end
    end
%%
    function need2drawPatch = need2drawRhythm(xlim, rhythms_struct)
        min_xLim = min(xlim);
        max_xLim = max(xlim);
        r_start = rhythms_struct.rhythm_range(1);
        r_end = rhythms_struct.rhythm_range(2);
        
        if (min_xLim < r_start && min_xLim < r_end && max_xLim < r_start && max_xLim < r_end) || ...
                (min_xLim > r_start && min_xLim > r_end && max_xLim > r_start && max_xLim > r_end)
            need2drawPatch = false;
        else
            need2drawPatch = true;
        end
    end
%%
    function redraw_rhythms_rect()
        ylim = get(GUI.ECG_Axes, 'YLim');
        xlim = get(GUI.ECG_Axes, 'XLim');
        
        if isfield(DATA, 'Rhythms_Map')
            rhythms_starts =  DATA.Rhythms_Map.keys();
            for i = 1 : length(rhythms_starts)
                
                rhythms_struct = DATA.Rhythms_Map(rhythms_starts{i});
                
                need2drawPatch = need2drawRhythm(xlim, rhythms_struct);
                if need2drawPatch
                    if ~rhythms_struct.rhythm_plotted
                        
                        rhythms_struct.rhythm_handle = plot_rhythms_rect(rhythms_struct.rhythm_range, 0, rhythms_struct.rhythm_class_ind);
                        rhythms_struct.rhythm_plotted = true;
                        DATA.Rhythms_Map(rhythms_starts{i}) = rhythms_struct;
                        
                        if isfield(GUI, 'rhythms_win')
                            curr_rhythms_num = length(GUI.rhythms_win);
                        else
                            curr_rhythms_num = 0;
                        end
                        GUI.rhythms_win(curr_rhythms_num + 1) = rhythms_struct.rhythm_handle;
                    end
                    if isgraphics(rhythms_struct.rhythm_handle, 'patch')
                        set(rhythms_struct.rhythm_handle, 'YData', [min(ylim) min(ylim) max(ylim) max(ylim)]);
                    end
                else
                    if rhythms_struct.rhythm_plotted
                        delete(rhythms_struct.rhythm_handle);
                        rhythms_struct.rhythm_plotted = false;
                        
                        reset_rhythm_button();
                        
                        DATA.Rhythms_Map(rhythms_starts{i}) = rhythms_struct;
                        
                        [is_member, win_ind] = ismember(rhythms_struct.rhythm_handle, GUI.rhythms_win);
                        if is_member
                            GUI.rhythms_win(win_ind)= [];
                        end
                    end
                end
            end
        end
    end
%%
    function plot_rhythms_line(DATA_QualityAnnotations_Data, DATA_Class)
        if ~isempty(DATA_QualityAnnotations_Data)
            
            if isfield(GUI, 'RhythmsHandle_AllDataAxes')  && any(isvalid(GUI.RhythmsHandle_AllDataAxes))
                prev_rhythms_win_num = length(GUI.RhythmsHandle_AllDataAxes);
            else
                prev_rhythms_win_num = 0;
            end
            
            qd_size = size(DATA_QualityAnnotations_Data);
            intervals_num = qd_size(1);
            
            for i = 1 : intervals_num
                [is_member, class_ind] = ismember(DATA_Class{i}, DATA.Rhythms_Type);
                if ~is_member
                    class_ind = 1;
                end
                ylim = get(GUI.RRInt_Axes, 'YLim');
                f = [1 2 3 4];
                
                rhythm_start = DATA_QualityAnnotations_Data(i,1);
                rhythm_end = DATA_QualityAnnotations_Data(i,2);
                
                v = [rhythm_start min(ylim); rhythm_end min(ylim); rhythm_end max(ylim); rhythm_start max(ylim)];
                
                patch_handle = patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.rhythms_color{class_ind}, 'EdgeColor', DATA.rhythms_color{class_ind}, ...
                    'LineWidth', 1, 'FaceAlpha', 0.4, 'EdgeAlpha', 0.85, 'UserData', class_ind, 'Parent', GUI.RRInt_Axes, 'Tag', 'RRIntRhythms');
                uistack(patch_handle, 'bottom');
                
                GUI.RhythmsHandle_AllDataAxes(prev_rhythms_win_num + i) = patch_handle;
                
                if isKey(DATA.Rhythms_Map, rhythm_start)
                    rhythms_struct = DATA.Rhythms_Map(rhythm_start);
                    rhythms_struct.low_axes_patch_handle = patch_handle;
                    DATA.Rhythms_Map(rhythm_start) = rhythms_struct;
                else
                    disp('The key not in the map');
                end
            end
        end
    end
%%
    function plot_quality_line(DATA_QualityAnnotations_Data, DATA_Class)
        if ~isempty(DATA_QualityAnnotations_Data)
            
            if isfield(GUI, 'PinkLineHandle_AllDataAxes')  && any(isvalid(GUI.PinkLineHandle_AllDataAxes))
                prev_quality_win_num = length(GUI.PinkLineHandle_AllDataAxes);
            else
                prev_quality_win_num = 0;
            end
            
            qd_size = size(DATA_QualityAnnotations_Data);
            intervals_num = qd_size(1);
            
            for i = 1 : intervals_num
                [is_member, class_ind] = ismember(DATA_Class{i}, DATA.GUI_Class);
                if ~is_member
                    class_ind = 3;
                end
                ylim = get(GUI.RRInt_Axes, 'YLim');
                f = [1 2 3 4];
                v = [DATA_QualityAnnotations_Data(i,1) min(ylim); DATA_QualityAnnotations_Data(i,2) min(ylim); DATA_QualityAnnotations_Data(i,2) max(ylim); DATA_QualityAnnotations_Data(i,1) max(ylim)];
                
                GUI.PinkLineHandle_AllDataAxes(prev_quality_win_num + i) = patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.quality_color{class_ind}, 'EdgeColor', DATA.quality_color{class_ind}, ...
                    'LineWidth', 1, 'FaceAlpha', 0.75, 'EdgeAlpha', 0.85, 'UserData', class_ind, 'Parent', GUI.RRInt_Axes, 'Tag', 'RRIntQuality');
                uistack(GUI.PinkLineHandle_AllDataAxes(prev_quality_win_num + i), 'bottom');
            end
        end
    end
%%
    function plot_quality_rect(quality_range, quality_win_num, quality_class)
        
        ylim = get(GUI.ECG_Axes, 'YLim');
        
        v = [min(quality_range) min(ylim); max(quality_range) min(ylim); max(quality_range) max(ylim); min(quality_range) max(ylim)];
        f = [1 2 3 4];
        
        GUI.quality_win(quality_win_num) = patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.quality_color{quality_class}, 'EdgeColor', DATA.quality_color{quality_class}, ...
            'LineWidth', 1, 'FaceAlpha', 0.45, 'EdgeAlpha', 0.5, 'UserData', quality_class, 'Parent', GUI.ECG_Axes, 'Tag', 'DataQuality'); % 'FaceAlpha', 0.1
        
        uistack(GUI.quality_win(quality_win_num), 'bottom');
    end
%%
    function patch_handle = plot_rhythms_rect(rhythms_range, rhythms_win_num, rhythms_class)
        
        ylim = get(GUI.ECG_Axes, 'YLim');
        
        v = [min(rhythms_range) min(ylim); max(rhythms_range) min(ylim); max(rhythms_range) max(ylim); min(rhythms_range) max(ylim)];
        f = [1 2 3 4];
        
        patch_handle = patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.rhythms_color{rhythms_class}, 'EdgeColor', DATA.rhythms_color{rhythms_class}, ...
            'LineWidth', 1, 'FaceAlpha', 0.4, 'EdgeAlpha', 0.5, 'UserData', rhythms_class, 'Parent', GUI.ECG_Axes, 'Tag', 'DataRhythms', ...
            'Visible', 'on'); % 'FaceAlpha', 0.1
        %         GUI.rhythms_win(rhythms_win_num)
        uistack(patch_handle, 'bottom'); % GUI.rhythms_win(rhythms_win_num)
    end
%%
    function reset_rhythm_button()
        GUI.Rhythms_handle.String = 'Rhythms';
        GUI.Rhythms_handle.BackgroundColor = [52 204 255]/255;
        try
            GUI.hT.Visible = 'off';
        catch
        end
    end
%%
    function update_rhythm_button(r_m_num)
        rhythm_name = DATA.Rhythms_Type{r_m_num};
        GUI.Rhythms_handle.String = (rhythm_name);
        GUI.Rhythms_handle.BackgroundColor = DATA.rhythms_color{r_m_num};
        
        hP = get(GUI.ECG_Axes, 'CurrentPoint');
        GUI.hT.Visible = 'on';
        GUI.hT.Position = [hP(1,1) + 0.9, hP(1,2) - 0.07];
        GUI.hT.String = rhythm_name;
    end
%%
    function my_WindowButtonUpFcn (src, callbackdata, handles)
        set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
        refresh(GUI.Window);
        switch DATA.hObject
            case 'del_win_peaks'
                try
                    Del_win(get(GUI.del_rect_handle, 'XData'));
                    delete(GUI.del_rect_handle);
                catch
                end
                set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
            case 'select_quality_win'
                try
                    quality_range = get(GUI.quality_rect_handle, 'XData');
                    
                    Select_Quality_Win(quality_range);
                    delete(GUI.quality_rect_handle);
                    
                    if min(quality_range) ~= max(quality_range)
                        DATA.quality_win_num = DATA.quality_win_num + 1;
                        classes = get(GUI.GUIRecord.Class_popupmenu, 'String');
                        quality_class = GUI.GUIRecord.Class_popupmenu.Value;
                        plot_quality_rect(quality_range, DATA.quality_win_num, quality_class);
                        plot_quality_line([min(quality_range) max(quality_range)], {classes{quality_class}});
                    end
                    set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
                catch e
                    disp(e.message);
                end
            case 'select_rhythms_win'
                try
                    rhythms_range = get(GUI.rhythms_rect_handle, 'XData');
                    
                    delete(GUI.rhythms_rect_handle);
                    
                    if min(rhythms_range) ~= max(rhythms_range)
                        DATA.rhythms_win_num = DATA.rhythms_win_num + 1;
                        classes = get(GUI.GUIRecord.Rhythms_popupmenu, 'String');
                        rhythms_class = GUI.GUIRecord.Rhythms_popupmenu.Value;
                        rhythms_handle = plot_rhythms_rect(rhythms_range, 0, rhythms_class); % DATA.rhythms_win_num
                        
                        rhythms_struct.rhythm_type = classes{rhythms_class};
                        rhythms_struct.rhythm_range = [min(rhythms_range) max(rhythms_range)];
                        rhythms_struct.rhythm_class_ind = rhythms_class;
                        rhythms_struct.rhythm_plotted = true;
                        rhythms_struct.rhythm_handle = rhythms_handle;
                                                
                        DATA.Rhythms_Map(min(rhythms_range)) = rhythms_struct;
                        
                        if isfield(GUI, 'rhythms_win')
                            curr_rhythms_num = length(GUI.rhythms_win);
                        else
                            curr_rhythms_num = 0;
                        end
                        GUI.rhythms_win(curr_rhythms_num + 1) = rhythms_handle;
                        
                        plot_rhythms_line([min(rhythms_range) max(rhythms_range)], {classes{rhythms_class}});
                        update_rhythm_button(rhythms_class);
                        
                        Update_Rhytms_Stat_Table();
                    end
                    set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
                catch e
                    disp(['select_rhythms_win:' e.message]);
                end
            otherwise
        end
    end
%%
    function my_WindowButtonMotionFcn(src, callbackdata, type)
        switch type
            case 'init'
                reset_rhythm_button();
                annotation = get(GUI.GUIRecord.Annotation_popupmenu, 'Value');
                if annotation == 1 && ((hittest(GUI.Window) == GUI.RawData_handle || get(hittest(GUI.Window), 'Parent') == GUI.RawData_handle)) % ECG data
                    setptr(GUI.Window, 'datacursor');
                    DATA.hObject = 'add_del_peak';
                elseif annotation == 1 && (hittest(GUI.Window) == GUI.ECG_Axes) %  || get(hittest(GUI.Window), 'Parent') == GUI.ECG_Axes % white space, draw del rect
                    setptr(GUI.Window, 'ddrag');
                    DATA.hObject = 'del_win_peaks';
                elseif annotation == 2 && hittest(GUI.Window) == GUI.ECG_Axes % signal quality
                    setptr(GUI.Window, 'rdrag'); % eraser circle
                    DATA.hObject = 'select_quality_win';
                elseif annotation == 2 && (isfield(GUI, 'quality_win') && ismember(hittest(GUI.Window), GUI.quality_win)) % delete signal quality win
                    setptr(GUI.Window, 'eraser');
                    DATA.hObject = 'delete_current_quality_win';
                elseif annotation == 3 && hittest(GUI.Window) == GUI.ECG_Axes % signal quality
                    setptr(GUI.Window, 'rdrag');
                    DATA.hObject = 'select_rhythms_win';
                elseif annotation == 3 && (isfield(GUI, 'rhythms_win') && ismember(hittest(GUI.Window), GUI.rhythms_win)) % delete signal rhythms win
                    setptr(GUI.Window, 'eraser');
                    DATA.hObject = 'delete_current_rhythms_win';
                    r_w = hittest(GUI.Window);
                    update_rhythm_button(r_w.UserData);
                elseif isfield(GUI, 'rhythms_win') && ismember(hittest(GUI.Window), GUI.rhythms_win)
                    r_w = hittest(GUI.Window);
                    update_rhythm_button(r_w.UserData);
                elseif hittest(GUI.Window) == GUI.red_rect_handle  % || get(hittest(GUI.Window), 'Parent') == GUI.RRInt_Axes  % GUI.red_rect_handle
                    try
                        xdata = get(GUI.red_rect_handle, 'XData');
                        max_xdata_red_rect = max(xdata);
                        min_xdata_red_rect = min(xdata);
                        point1 = get(GUI.RRInt_Axes, 'CurrentPoint');
                        if point1(1, 1) >= 0 && point1(1, 1) <= max(get(GUI.RRInt_Axes, 'XLim'))
                            eps = (max_xdata_red_rect - min_xdata_red_rect) * 0.1;
                            if  point1(1,1) <= max_xdata_red_rect + eps && point1(1,1) >= max_xdata_red_rect - eps
                                setptr(GUI.Window, 'lrdrag');
                                DATA.hObject = 'right_resize';
                            elseif  point1(1,1) <= min_xdata_red_rect + eps && point1(1,1) >= min_xdata_red_rect - eps
                                setptr(GUI.Window, 'lrdrag');
                                DATA.hObject = 'left_resize';
                            else
                                setptr(GUI.Window, 'arrow');
                                DATA.hObject = 'overall';
                            end
                        end
                    catch
                    end
                elseif hittest(GUI.Window) == GUI.RRInt_Axes || get(hittest(GUI.Window), 'Parent') == GUI.RRInt_Axes
                    if isfield(GUI, 'red_rect_handle') && isvalid(GUI.red_rect_handle)
                        xdata = get(GUI.red_rect_handle, 'XData');
                        point1 = get(GUI.RRInt_Axes, 'CurrentPoint');
                        if point1(1,1) < max(xdata) && point1(1,1) > min(xdata)
                            setptr(GUI.Window, 'hand');
                            DATA.hObject = 'zoom_rect_move';                            
                        else
                            setptr(GUI.Window, 'arrow');
                            DATA.hObject = 'jump2time';                            
                        end
                    end
                else
                    setptr(GUI.Window, 'arrow');
                    DATA.hObject = 'overall';                    
                end
            case 'window_move'
                Window_Move('normal', []);
            case 'drag_del_rect'
                draw_rect_to_del_peaks(GUI.del_rect_handle);
            case 'right_resize_move'
                LR_Resize('right');
            case 'left_resize_move'
                LR_Resize('left');
            case 'drag_quality_rect'
                draw_rect_to_del_peaks(GUI.quality_rect_handle);
            case 'drag_rhythms_rect'
                draw_rect_to_del_peaks(GUI.rhythms_rect_handle);
            otherwise
        end
    end
%%
    function my_WindowButtonDownFcn(src, callbackdata, handles)
        
        if strcmp(GUI.timer_object.Running, 'on')
            stop(GUI.timer_object);
            reset_movie_buttons();
            EnableDisableControls();
            EnableMovieForwardReverse();
        end
        
        prev_point = get(GUI.RRInt_Axes, 'CurrentPoint');
        DATA.prev_point = prev_point;
        curr_point = get(GUI.ECG_Axes, 'CurrentPoint');
        DATA.prev_point_ecg = curr_point;
        switch DATA.hObject
            case 'add_del_peak'
                Remove_Peak();
            case 'delete_current_rhythms_win'
                if isfield(GUI, 'rhythms_win') && ~isempty(GUI.rhythms_win)
                    [is_member, win_ind] = ismember(hittest(GUI.Window), GUI.rhythms_win);
                    
                    if is_member                        
                        rhythms_range = get(GUI.rhythms_win(win_ind), 'XData');                        
                                                
                        try                            
                            delete(GUI.rhythms_win(win_ind));
                            GUI.rhythms_win(win_ind) = [];
                            DATA.rhythms_win_num = DATA.rhythms_win_num - 1;
                            
                            if isKey(DATA.Rhythms_Map, min(rhythms_range))
                                rhythms_struct = DATA.Rhythms_Map(min(rhythms_range));
                                
                                low_axes_patch_handle = rhythms_struct.low_axes_patch_handle;
                                delete(low_axes_patch_handle);
                                
                                [is_member, low_axes_patch_ind] = ismember(low_axes_patch_handle, GUI.RhythmsHandle_AllDataAxes);
                                if is_member
                                    delete(GUI.RhythmsHandle_AllDataAxes(low_axes_patch_ind));
                                    GUI.RhythmsHandle_AllDataAxes(low_axes_patch_ind) = [];
                                    reset_rhythm_button();
                                end
                                DATA.Rhythms_Map.remove(min(rhythms_range));
                                Update_Rhytms_Stat_Table();
                            end
                        catch e
                            disp(e);
                        end
                    end
                end
            case 'delete_current_quality_win'
                if isfield(GUI, 'quality_win') && ~isempty(GUI.quality_win)
                    [is_member, win_ind] = ismember(hittest(GUI.Window), GUI.quality_win);
                    
                    
                    red_peaks_x_data = GUI.red_peaks_handle.XData;
                    quality_range = get(GUI.quality_win(win_ind), 'XData');
                    peak_ind = find(red_peaks_x_data >= min(quality_range) & red_peaks_x_data <= max(quality_range));
                    
                    DATA.peaks_bad_quality = DATA.peaks_bad_quality - length(peak_ind);
                    GUI.PeaksTable.Data(4, 2) = {DATA.peaks_bad_quality/DATA.peaks_total*100};
                    
                    if is_member
                        delete(GUI.quality_win(win_ind));
                        GUI.quality_win(win_ind) = [];
                        DATA.quality_win_num = DATA.quality_win_num - 1;
                        
                        delete(GUI.PinkLineHandle_AllDataAxes(win_ind));
                        GUI.PinkLineHandle_AllDataAxes(win_ind) = [];
                    end
                end
            case 'select_quality_win'
                GUI.quality_rect_handle = line(curr_point(1, 1), curr_point(1, 2), 'Color', 'r', 'Linewidth', 1.5, 'LineStyle', ':', 'Parent', GUI.ECG_Axes);
                set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'drag_quality_rect'});
            case 'select_rhythms_win'
                GUI.rhythms_rect_handle = line(curr_point(1, 1), curr_point(1, 2), 'Color', 'r', 'Linewidth', 1.5, 'LineStyle', ':', 'Parent', GUI.ECG_Axes);
                set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'drag_rhythms_rect'});
            case 'del_win_peaks'
                GUI.del_rect_handle = line(curr_point(1, 1), curr_point(1, 2), 'Color', 'r', 'Linewidth', 1.5, 'LineStyle', ':', 'Parent', GUI.ECG_Axes);
                set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'drag_del_rect'});
            case 'left_resize'
                set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'left_resize_move'});
            case 'right_resize'
                set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'right_resize_move'});
            case 'zoom_rect_move'
                switch get(GUI.Window, 'selectiontype')
                    case 'normal'
                        set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'window_move'}); % move zoom rectangle
                    case 'open'
                        Window_Move('open', []); % double-click: show all data
                    otherwise
                end
            case 'jump2time'
                switch get(GUI.Window, 'selectiontype')
                    case 'open'                        
                        cp = get(GUI.RRInt_Axes, 'CurrentPoint');
                        xdata = get(GUI.red_rect_handle, 'XData');
                        xofs = cp(1,1) - xdata(1, 1);
                        Window_Move('normal', xofs);
                    otherwise
                end
            otherwise
        end
    end
%%
    function LR_Resize(type)
        xdata = get(GUI.red_rect_handle, 'XData');
        xdata_saved = xdata;
        point1 = get(GUI.RRInt_Axes, 'CurrentPoint');
        xofs = point1(1,1) - DATA.prev_point(1, 1);
        DATA.prev_point = point1(1, 1);
        
        RR_XLim = get(GUI.RRInt_Axes,  'XLim');
        min_XLim = min(RR_XLim);
        max_XLim = max(RR_XLim);
        
        switch type
            case 'left'
                xdata([1, 4, 5]) = xdata([1, 4, 5]) + xofs;
            case 'right'
                xdata([2, 3]) = xdata([2, 3]) + xofs;
        end
        if xdata(2) <= xdata(1)
            return;
        end
        if xdata(2) - xdata(1) < 0.01
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
        set(GUI.red_rect_handle, 'XData', xdata);
        DATA.zoom_rect_limits = [xdata(1) xdata(2)];
        GUI.GUIDisplay.FirstSecond.UserData = min(xdata);
        GUI.GUIDisplay.WindowSize.UserData = max(xdata) - min(xdata);
        EnablePageUpDown();
        redraw_quality_rect();
        redraw_rhythms_rect();
    end
%%
    function Window_Move(type, xofs)
        
        xdata = get(GUI.red_rect_handle, 'XData');
        xdata_saved = xdata;
        point1 = get(GUI.RRInt_Axes, 'CurrentPoint');
        if isempty(xofs)
            xofs = point1(1,1) - DATA.prev_point(1, 1);
        end
        DATA.prev_point = point1(1, 1);
        
        min_XLim = 0;
        max_XLim = DATA.maxRRTime;
        
        RR_XLim = get(GUI.RRInt_Axes,  'XLim');
        prev_minLim = min(RR_XLim);
        prev_maxLim = max(RR_XLim);
        
        switch type
            case 'normal'
                xdata = xdata + xofs;
            case 'open'
                xdata([1, 4, 5]) = prev_minLim;
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
        set(GUI.red_rect_handle, 'XData', xdata);
        DATA.zoom_rect_limits = [xdata(1) xdata(2)];
        EnablePageUpDown();
        
        GUI.GUIDisplay.FirstSecond.UserData = min(xdata);
        
        set_ticks = 0;
        if xdata(2) > prev_maxLim
            RRIntAxes_offset = xdata(2) - prev_maxLim;
            set_ticks = 1;
        elseif xdata(1) < prev_minLim
            RRIntAxes_offset = xdata(1) - prev_minLim;
            set_ticks = 1;
        end
        if set_ticks
            set(GUI.RRInt_Axes, 'XLim', RR_XLim + RRIntAxes_offset);
            setAxesXTicks(GUI.RRInt_Axes);
        end
        setRRIntYLim();
        redraw_quality_rect();
        redraw_rhythms_rect();
    end
%%
    function draw_rect_to_del_peaks(rect_handle)
        point1 = get(GUI.ECG_Axes, 'CurrentPoint');
        xlim = get(GUI.ECG_Axes, 'XLim');
        
        if point1(1, 1) < min(xlim)
            point1(1, 1) = min(xlim);
        end
        if point1(1, 1) > max(xlim)
            point1(1, 1) = max(xlim);
        end
        
        x_box = [DATA.prev_point_ecg(1, 1) DATA.prev_point_ecg(1, 1) point1(1, 1) point1(1, 1) DATA.prev_point_ecg(1, 1)];
        y_box = [DATA.prev_point_ecg(1, 2) point1(1, 2) point1(1, 2) DATA.prev_point_ecg(1, 2) DATA.prev_point_ecg(1, 2)];
        
        set(rect_handle, 'XData', x_box, 'YData', y_box);
    end
%%
    function ChangePlot(xdata)
        
        setECGXLim(xdata(1), xdata(2));
        if GUI.AutoScaleY_checkbox.Value
            setECGYLim(xdata(1), xdata(2));
        end
        
        if xdata(2) - xdata(1) < 2
            display_msec = 1;
        else
            display_msec = 0;
        end
        
        GUI.GUIDisplay.FirstSecond.String = calcDuration(xdata(1), display_msec);
        GUI.GUIDisplay.WindowSize.String = calcDuration(xdata(2) - xdata(1), display_msec);
    end
%%
    function Remove_Peak()
        
        point1 = get(GUI.ECG_Axes, 'CurrentPoint');
        my_point = point1(1, 1);
        peak_search_win_sec = DATA.peak_search_win / 1000;
        
        if ~get(GUI.AutoPeakWin_checkbox, 'Value')
            
            [left_limit, left_limit_ind] = max(DATA.tm(DATA.tm < my_point));
            
            right_limit = min(DATA.tm(DATA.tm > my_point));
            right_limit_ind = find(DATA.tm > my_point, 1);
            
            left_dist = my_point-left_limit;
            right_dist = right_limit - my_point;
            
            min_dist = min(left_dist, right_dist);
            
            if left_dist == min_dist
                nearest_point_ind = left_limit_ind;
                nearest_point_time = left_limit;
            else
                nearest_point_ind = right_limit_ind;
                nearest_point_time = right_limit;
            end
            nearest_point_value = DATA.sig(nearest_point_ind);
        end
        
        x_min = max(0, my_point - peak_search_win_sec);
        x_max = min(max(DATA.tm), my_point + peak_search_win_sec);
        
        if isfield(GUI, 'red_peaks_handle') && isvalid(GUI.red_peaks_handle)
            red_peaks_x_data = GUI.red_peaks_handle.XData;
            peak_ind = find(red_peaks_x_data >= x_min & red_peaks_x_data <= x_max);
        else
            peak_ind = [];
        end
        
        if isempty(peak_ind)
            
            if get(GUI.AutoPeakWin_checkbox, 'Value')
                
                if DATA.Adjust == -1 % local min
                    [new_peak, ind_new_peak] = min(DATA.sig((DATA.tm>=x_min & DATA.tm<=x_max)));
                else
                    [new_peak, ind_new_peak] = max(DATA.sig((DATA.tm>=x_min & DATA.tm<=x_max)));
                end
                time_area = DATA.tm((DATA.tm>=x_min & DATA.tm<=x_max));
                time_new_peak = time_area(ind_new_peak);
            else
                time_new_peak = nearest_point_time;
                new_peak = nearest_point_value;
            end
            if isfield(GUI, 'red_peaks_handle') && isvalid(GUI.red_peaks_handle)
                temp_XData = [GUI.red_peaks_handle.XData, time_new_peak];
                temp_YData = [GUI.red_peaks_handle.YData, new_peak];
            else
                temp_XData = time_new_peak;
                temp_YData = new_peak;
            end
            [temp_XData, ind_sort] = sort(temp_XData);
            temp_YData = temp_YData(ind_sort);
            
            global_ind = find(DATA.tm == time_new_peak);
            
            DATA.qrs = sort([DATA.qrs', global_ind])';
            DATA.qrs_saved = sort([DATA.qrs_saved', global_ind])';
            
            DATA.peaks_added = DATA.peaks_added + length(global_ind);
            GUI.PeaksTable.Data(2, 2) = {DATA.peaks_added};
            
            DATA.peaks_total = DATA.peaks_total + length(global_ind);
            GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
            
            if isfield(GUI, 'red_peaks_handle') && isvalid(GUI.red_peaks_handle)
                set(GUI.red_peaks_handle, 'XData', temp_XData, 'YData', temp_YData);
            else
                GUI.red_peaks_handle = line(temp_XData, temp_YData, 'Parent', GUI.ECG_Axes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'LineWidth', 2, 'Tag', 'Peaks');
                uistack(GUI.red_peaks_handle, 'top');
            end
        else
            GUI.red_peaks_handle.XData(peak_ind) = [];
            GUI.red_peaks_handle.YData(peak_ind) = [];
            DATA.qrs(peak_ind) = [];
            DATA.qrs_saved(peak_ind) = [];
            
            DATA.peaks_deleted = DATA.peaks_deleted + length(peak_ind);
            GUI.PeaksTable.Data(3, 2) = {DATA.peaks_deleted};
            
            DATA.peaks_total = DATA.peaks_total - length(peak_ind);
            GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
            
        end
        try
            delete(GUI.red_rect_handle);
            delete(GUI.RRInt_handle);
            
            plot_rr_data();
            plot_red_rectangle(DATA.zoom_rect_limits);
            setRRIntYLim();
        catch
        end
    end
%%
    function Del_win(range2del)
        xlim = get(GUI.ECG_Axes, 'XLim');
        
        if isfield(GUI, 'red_peaks_handle') && isvalid(GUI.red_peaks_handle)
            
            if min(range2del) >= xlim(1) || max(range2del) <= xlim(2)
                red_peaks_x_data = GUI.red_peaks_handle.XData;
                peak_ind = find(red_peaks_x_data >= min(range2del) & red_peaks_x_data <= max(range2del));
                GUI.red_peaks_handle.XData(peak_ind) = [];
                GUI.red_peaks_handle.YData(peak_ind) = [];
                DATA.qrs(peak_ind) = [];
                DATA.qrs_saved(peak_ind) = [];
                
                DATA.peaks_deleted = DATA.peaks_deleted + length(peak_ind);
                GUI.PeaksTable.Data(3, 2) = {DATA.peaks_deleted};
                
                DATA.peaks_total = DATA.peaks_total - length(peak_ind);
                GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
                
                try
                    delete(GUI.red_rect_handle);
                    delete(GUI.RRInt_handle);
                    plot_rr_data();
                    plot_red_rectangle(DATA.zoom_rect_limits);
                    setRRIntYLim();
                catch
                end
            else
                disp('Not in range!');
            end
        end
    end
%%
    function Update_Rhytms_Stat_Table()
        
        GUI.RhythmsTable.Data = {};
        GUI.RhythmsTable.RowName = {};
        
        if isfield(DATA, 'Rhythms_Map') && length(DATA.Rhythms_Map) > 0
            
            if ~(isfield(DATA, 'Rhythms_Stat') && length(Rhythms_Stat) > 0)
                Rhythms_Stat = containers.Map();
            end
            
            rhythms_values = DATA.Rhythms_Map.values();
            for i = 1 : length(DATA.Rhythms_Map)
                rh_class = rhythms_values{i}.rhythm_type;
                rh_length = max(rhythms_values{i}.rhythm_range) - min(rhythms_values{i}.rhythm_range);
                if isKey(Rhythms_Stat, rh_class)
                    val = Rhythms_Stat(rh_class);
                    Rhythms_Stat(rhythms_values{i}.rhythm_type) = [val rh_length];
                else
                    Rhythms_Stat(rh_class) = rh_length;
                end
            end
            
            rh_class = Rhythms_Stat.keys();
            rhythms_class_lengths = Rhythms_Stat.values();
            
            GUI.RhythmsTable.RowName = rh_class;
            
            for i = 1 : length(rh_class)
                [is_member, class_ind] = ismember(rh_class{i}, DATA.Rhythms_Type);
                if is_member
                    stat_res = sumstat(rhythms_class_lengths{i}, DATA.tm(end));
                    GUI.RhythmsTable.Data(i, :) = [DATA.rhythms_tooltip(class_ind), stat_res];
                end
            end            
        end
    end
%%
    function Select_Quality_Win(quality_range)
        xlim = get(GUI.ECG_Axes, 'XLim');
        
        if min(quality_range) >= xlim(1) || max(quality_range) <= xlim(2)
            red_peaks_x_data = GUI.red_peaks_handle.XData;
            peak_ind = find(red_peaks_x_data >= min(quality_range) & red_peaks_x_data <= max(quality_range));
            DATA.peaks_bad_quality = DATA.peaks_bad_quality + length(peak_ind);
            GUI.PeaksTable.Data(4, 2) = {DATA.peaks_bad_quality/DATA.peaks_total*100};
        else
            disp('Not in range!');
        end
    end
%%
    function set_RRIntPage_Length(RRIntPage_Length, isInputNumeric)
        red_rect_xdata = get(GUI.red_rect_handle, 'XData');
        min_red_rect_xdata = min(red_rect_xdata);
        max_red_rect_xdata = max(red_rect_xdata);
        red_rect_length = max_red_rect_xdata - min_red_rect_xdata;
        if isInputNumeric
            
            if RRIntPage_Length <= 2
                display_msec = 1;
            else
                display_msec = 0;
            end
            
            if RRIntPage_Length <= 1 || RRIntPage_Length > DATA.maxRRTime
                set(GUI.GUIDisplay.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, display_msec));
                if isInputNumeric ~= 2
                    h_e = errordlg('The window size must be greater than 2 sec and less than signal length!', 'Input Error');
                    setLogo(h_e, 'M1');
                end
                return;
            elseif RRIntPage_Length < red_rect_length
                set(GUI.GUIDisplay.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, display_msec));
                if isInputNumeric ~= 2
                    h_e = errordlg('The window size must be greater than zoom window length!', 'Input Error');
                    setLogo(h_e, 'M1');
                end
                return;
            end
            
            DATA.RRIntPage_Length = RRIntPage_Length;
            
            delta_axes_red_rect = DATA.RRIntPage_Length - red_rect_length;
            right_length = DATA.maxRRTime - max_red_rect_xdata;
            left_length = min_red_rect_xdata;
            if (delta_axes_red_rect - right_length) < (delta_axes_red_rect - left_length)
                set(GUI.RRInt_Axes, 'XLim', [min_red_rect_xdata min((min_red_rect_xdata + DATA.RRIntPage_Length), DATA.maxRRTime)]);
            else
                set(GUI.RRInt_Axes, 'XLim', [max(0, max_red_rect_xdata - DATA.RRIntPage_Length) max_red_rect_xdata]);
            end
            
            setAxesXTicks(GUI.RRInt_Axes);
            EnablePageUpDown();
            
            AllDataAxes_XLim = get(GUI.RRInt_Axes, 'XLim');
            RRIntPage_Length = max(AllDataAxes_XLim) - min(AllDataAxes_XLim);
            DATA.RRIntPage_Length = RRIntPage_Length;
            
            
            if RRIntPage_Length <= 2
                display_msec = 1;
            else
                display_msec = 0;
            end
            
            set(GUI.GUIDisplay.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, display_msec));
            setRRIntYLim();
            redraw_quality_rect();
            redraw_rhythms_rect();
        end
    end
%%
    function RRIntPage_Length_Callback(~, ~)
        if isfield(DATA, 'RRIntPage_Length')
            RRIntPage_Length = get(GUI.GUIDisplay.RRIntPage_Length, 'String');
            [RRIntPage_Length, isInputNumeric] = calcDurationInSeconds(GUI.GUIDisplay.RRIntPage_Length, RRIntPage_Length, DATA.RRIntPage_Length);
            set_RRIntPage_Length(RRIntPage_Length, isInputNumeric);
        end
    end
%%
    function page_down_pushbutton_Callback(~, ~, movie_offset)
        xdata = get(GUI.red_rect_handle, 'XData');
        red_rect_length = max(xdata) - min(xdata);
        if ~isempty(movie_offset)
            x_ofs = 0.25;
        else
            x_ofs = red_rect_length;
        end
        
        left_border = min(xdata) - x_ofs;
        right_border = max(xdata) - x_ofs;                
        
        if left_border < 0
            left_border = 0;
            right_border = red_rect_length;
        end
        if left_border >= 0 && left_border < right_border && right_border <= DATA.maxRRTime
            xdata = [left_border right_border right_border left_border left_border];
            set(GUI.red_rect_handle, 'XData', xdata);
            ChangePlot(xdata);
            if strcmp(GUI.timer_object.Running, 'off')
                EnablePageUpDown();
            end
            EnableMovieForwardReverse();
            DATA.zoom_rect_limits = [xdata(1) xdata(2)];
            
            GUI.GUIDisplay.FirstSecond.UserData = left_border;
            
            set_ticks = 0;
            AllDataAxes_XLim = get(GUI.RRInt_Axes, 'XLim');
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
                set(GUI.RRInt_Axes, 'XLim', AllDataAxes_XLim + AllDataAxes_offset);
                setAxesXTicks(GUI.RRInt_Axes);
            end
            setRRIntYLim();
            redraw_quality_rect();
            redraw_rhythms_rect();
        end
    end
%%
    function page_up_pushbutton_Callback(~, ~, movie_offset)
        xdata = get(GUI.red_rect_handle, 'XData');
        red_rect_length = max(xdata) - min(xdata);
        
        if ~isempty(movie_offset)
            x_ofs = 0.25;            
        else
            x_ofs = red_rect_length;            
        end
        
        left_border = min(xdata) + x_ofs;
        right_border = max(xdata) + x_ofs;
        
        if right_border > DATA.maxRRTime
            left_border = DATA.maxRRTime - red_rect_length;
            right_border = DATA.maxRRTime;
        end
        
        if left_border >= 0 && left_border < right_border && right_border <= DATA.maxRRTime
            xdata = [left_border right_border right_border left_border left_border];
            set(GUI.red_rect_handle, 'XData', xdata);
            ChangePlot(xdata);
            if strcmp(GUI.timer_object.Running, 'off')
                EnablePageUpDown();
            end
            EnableMovieForwardReverse();
            DATA.zoom_rect_limits = [xdata(1) xdata(2)];
            
            GUI.GUIDisplay.FirstSecond.UserData = left_border;
            
            set_ticks = 0;
            AllDataAxes_XLim = get(GUI.RRInt_Axes, 'XLim');
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
                set(GUI.RRInt_Axes, 'XLim', AllDataAxes_XLim + AllDataAxes_offset);
                setAxesXTicks(GUI.RRInt_Axes);
            end
            setRRIntYLim();
            redraw_quality_rect();
            redraw_rhythms_rect();
        end
    end
%%
    function EnablePageUpDown(~, ~)
        xdata = get(GUI.red_rect_handle, 'XData');
        
        if ~isempty(xdata)
            if xdata(2) == DATA.maxRRTime
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
    function play_stop_movie_pushbutton_Callback(~, ~)
        if GUI.PlayStopForwMovieButton.Value
            GUI.PlayStopForwMovieButton.String = sprintf('\x25A0');
            GUI.PlayStopForwMovieButton.ForegroundColor = [1 0 0];
            
            movie_delay = 0.25/str2double(GUI.GUIDisplay.Movie_Delay.String); % in seconds
            GUI.timer_object.Period = str2double(sprintf('%.3f', movie_delay));
            GUI.timer_object.TimerFcn = {@page_up_pushbutton_Callback, 'movie_offset'};
            start(GUI.timer_object);
            
            GUI.PlayStopReverseMovieButton.Enable = 'inactive';
        else
            GUI.PlayStopForwMovieButton.String = sprintf('\x25BA');
            GUI.PlayStopForwMovieButton.ForegroundColor = [0 1 0];
            
            GUI.PlayStopReverseMovieButton.Enable = 'on';
            
            stop(GUI.timer_object);
        end
        EnableMovieForwardReverse();
        EnableDisableControls();
    end
%%
    function play_stop_reverse_movie_pushbutton_Callback(~, ~)
        if GUI.PlayStopReverseMovieButton.Value
            GUI.PlayStopReverseMovieButton.String = sprintf('\x25A0');
            GUI.PlayStopReverseMovieButton.ForegroundColor = [1 0 0];
            
            movie_delay = 0.25/str2double(GUI.GUIDisplay.Movie_Delay.String); % in seconds
            GUI.timer_object.Period = str2double(sprintf('%.3f', movie_delay));
            
            GUI.PlayStopForwMovieButton.Enable = 'inactive';
            
            GUI.timer_object.TimerFcn = {@page_down_pushbutton_Callback, 'movie_offset'};
            start(GUI.timer_object);
        else
            GUI.PlayStopReverseMovieButton.String = sprintf('\x25C4');
            GUI.PlayStopReverseMovieButton.ForegroundColor = [0 1 0];
            
            GUI.PlayStopForwMovieButton.Enable = 'on';
            
            stop(GUI.timer_object);
        end
        EnableMovieForwardReverse();
        EnableDisableControls();
    end
%%
    function EnableMovieForwardReverse()
        xdata = get(GUI.red_rect_handle, 'XData');
        
        if ~isempty(xdata)
            if xdata(2) == DATA.maxRRTime
                if isfield(GUI, 'timer_object')
                    stop(GUI.timer_object);
                end
                
                GUI.PlayStopForwMovieButton.Enable = 'inactive';
                GUI.PlayStopForwMovieButton.Value = 0;
                GUI.PlayStopForwMovieButton.String = sprintf('\x25BA');
                GUI.PlayStopForwMovieButton.ForegroundColor = [0 1 0];
                
                GUI.PlayStopReverseMovieButton.Enable = 'on';
                GUI.PlayStopReverseMovieButton.Value = 0;
            elseif strcmp(GUI.timer_object.Running, 'off')
                GUI.PlayStopForwMovieButton.Enable = 'on';
            end
            if xdata(1) == 0
                if isfield(GUI, 'timer_object')
                    stop(GUI.timer_object);
                end
                
                GUI.PlayStopForwMovieButton.Enable = 'on';
                GUI.PlayStopForwMovieButton.Value = 0;
                
                GUI.PlayStopReverseMovieButton.Enable = 'inactive';
                GUI.PlayStopReverseMovieButton.Value = 0;
                GUI.PlayStopReverseMovieButton.String = sprintf('\x25C4');
                GUI.PlayStopReverseMovieButton.ForegroundColor = [0 1 0];
            elseif strcmp(GUI.timer_object.Running, 'off')
                GUI.PlayStopReverseMovieButton.Enable = 'on';
            end
        end
    end
%%
    function EnableDisableControls()
        if strcmp(GUI.timer_object.Running, 'on')
            set(findobj(GUI.RecordTab, 'Style', 'edit'), 'Enable', 'inactive');
            set(findobj(GUI.RecordTab, 'Style', 'PushButton'), 'Enable', 'inactive');
            set(findobj(GUI.RecordTab, 'Style', 'PopUpMenu'), 'Enable', 'inactive');
            
            set(findobj(GUI.ConfigParamTab, 'Style', 'edit'), 'Enable', 'inactive');
            set(findobj(GUI.ConfigParamTab, 'Style', 'checkbox'), 'Enable', 'inactive');
            
            set(findobj(GUI.DisplayTab, 'Style', 'edit'), 'Enable', 'inactive');
            
            %             GUI.GUIDisplay.RRIntPage_Length.Enable = 'inactive';
            %             GUI.GUIDisplay.Movie_Delay.Enable = 'inactive';
            %             GUI.GUIDisplay.FirstSecond.Enable = 'inactive';
            %             GUI.GUIDisplay.WindowSize.Enable = 'inactive';
            
            set(findobj(GUI.CommandsButtons_Box, 'Enable', 'on'), 'Enable', 'inactive');
            set(findobj(GUI.PageUpDownButtons_Box, 'Style', 'PushButton'), 'Enable', 'off');
            
            set(GUI.FileMenu, 'Enable', 'off');
        else
            set(findobj(GUI.RecordTab, 'Style', 'edit'), 'Enable', 'on');
            set(findobj(GUI.RecordTab, 'Style', 'PushButton'), 'Enable', 'on');
            set(findobj(GUI.RecordTab, 'Style', 'PopUpMenu'), 'Enable', 'on');
            
            set(findobj(GUI.ConfigParamTab, 'Style', 'edit'), 'Enable', 'on');
            set(findobj(GUI.ConfigParamTab, 'Style', 'checkbox'), 'Enable', 'on');
            
            set(findobj(GUI.DisplayTab, 'Style', 'edit'), 'Enable', 'on');
            
            set(findobj(GUI.CommandsButtons_Box, 'Enable', 'inactive'), 'Enable', 'on');
            set(findobj(GUI.PageUpDownButtons_Box, 'Style', 'PushButton'), 'Enable', 'on');
            
            %             GUI.GUIDisplay.RRIntPage_Length.Enable = 'on';
            %             GUI.GUIDisplay.Movie_Delay.Enable = 'on';
            %             GUI.GUIDisplay.FirstSecond.Enable = 'on';
            %             GUI.GUIDisplay.WindowSize.Enable = 'on';
            
            set(GUI.FileMenu, 'Enable', 'on');
        end
    end
%%
    function Annotation_popupmenu_Callback(~, ~)
        
        index_selected = get(GUI.GUIRecord.Annotation_popupmenu, 'Value');
        
        if index_selected == 1
            GUI.GUIRecord.Class_popupmenu.Visible = 'off';
            GUI.Class_Text.Visible = 'off';
            
            GUI.GUIRecord.Rhythms_popupmenu.Visible = 'off';
            GUI.Rhythms_Text.Visible = 'off';
            
            GUI.GUIRecord.PeakAdjustment_popupmenu.Visible = 'on';
            GUI.Adjustment_Text.Visible = 'on';
            
            set(GUI.Adjust_textBox, 'Position', GUI.Adjust_textBox_position);
            set(GUI.Class_textBox, 'Position', GUI.Class_textBox_position);
            set(GUI.Rhythms_textBox, 'Position', GUI.Rhythms_textBox_position);
            GUI.RhythmsHBox.Visible = 'off';
        elseif index_selected == 2
            GUI.GUIRecord.Class_popupmenu.Visible = 'on';
            GUI.Class_Text.Visible = 'on';
            
            GUI.GUIRecord.Rhythms_popupmenu.Visible = 'off';
            GUI.Rhythms_Text.Visible = 'off';
            
            GUI.GUIRecord.PeakAdjustment_popupmenu.Visible = 'off';
            GUI.Adjustment_Text.Visible = 'off';
            
            set(GUI.Adjust_textBox, 'Position', GUI.Class_textBox_position);
            set(GUI.Class_textBox, 'Position', GUI.Adjust_textBox_position);
            set(GUI.Rhythms_textBox, 'Position', GUI.Rhythms_textBox_position);
            GUI.RhythmsHBox.Visible = 'off';
        else
            GUI.GUIRecord.Class_popupmenu.Visible = 'off';
            GUI.Class_Text.Visible = 'off';
            
            GUI.GUIRecord.Rhythms_popupmenu.Visible = 'on';
            GUI.Rhythms_Text.Visible = 'on';
            
            GUI.GUIRecord.PeakAdjustment_popupmenu.Visible = 'off';
            GUI.Adjustment_Text.Visible = 'off';
            
            set(GUI.Adjust_textBox, 'Position', GUI.Rhythms_textBox_position);
            set(GUI.Class_textBox, 'Position', GUI.Class_textBox_position);
            set(GUI.Rhythms_textBox, 'Position', GUI.Adjust_textBox_position);
            GUI.RhythmsHBox.Visible = 'on';
            
            Rhythms_ToggleButton_Reset();
            GUI.rhythms_legend(GUI.GUIRecord.Rhythms_popupmenu.Value).Value = 1;
        end
    end
%%
    function Class_popupmenu_Callback( ~, ~ )
    end
%%
    function Rhythms_popupmenu_Callback(src, ~ )
        Rhythms_ToggleButton_Reset();
        GUI.rhythms_legend(src.Value).Value = 1;
    end
%%
    function PeakAdjustment_popupmenu_Callback(src, ~ )
        
        if isfield(DATA, 'config_map')
            items = get(src, 'String');
            index_selected = get(src, 'Value');
            
            DATA.config_map('peak_adjustment') = items{index_selected};
            
            if index_selected == 1 % default
                DATA.Adjust = 0;
            elseif index_selected == 2 % local max
                DATA.Adjust = 1;
            elseif index_selected == 3 % local min
                DATA.Adjust = -1;
            end
            if get(GUI.AutoCalc_checkbox, 'Value')
                PeakAdjustment(DATA.qrs);
            end
        end
    end
%%
    function PeakAdjustment(QRS)
        if DATA.Adjust
            try
                waitbar_handle = waitbar(1/2, 'Compute peaks...', 'Name', 'Computing');
                setLogo(waitbar_handle, 'M1');
                
                %                 DATA.qrs = mhrv.ecg.qrs_adjust(DATA.sig, DATA.qrs, DATA.Fs, DATA.Adjust, DATA.peak_search_win/1000, false);
                DATA.qrs = mhrv.ecg.qrs_adjust(DATA.sig, double(QRS), DATA.Fs, DATA.Adjust, DATA.peak_search_win/1000, false);
                
                if isvalid(waitbar_handle)
                    close(waitbar_handle);
                end
            catch e
                if isvalid(waitbar_handle)
                    close(waitbar_handle);
                end
                h_e = errordlg(['mhrv.ecg.qrs_adjust error: ' e.message], 'Input Error');
                setLogo(h_e, 'M1');
                return;
            end
        else % default
            DATA.qrs = DATA.qrs_saved;
        end
        if ~isempty(DATA.qrs)
            if isfield(GUI, 'red_peaks_handle') && ishandle(GUI.red_peaks_handle) && isvalid(GUI.red_peaks_handle)
                delete(GUI.red_peaks_handle);
            end
            DATA.qrs = double(DATA.qrs);
            GUI.red_peaks_handle = line(DATA.tm(DATA.qrs), DATA.sig(DATA.qrs, 1), 'Parent', GUI.ECG_Axes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'LineWidth', 2, 'Tag', 'Peaks');
            uistack(GUI.red_peaks_handle, 'top');
            
            delete(GUI.red_rect_handle);
            delete(GUI.RRInt_handle);
            
            plot_rr_data();
            plot_red_rectangle(DATA.zoom_rect_limits);
            setRRIntYLim();
        end
    end
%%
    function SaveRhythms_Callback(~, ~)
        persistent DIRS;
        persistent EXT;
        
        % Add third-party dependencies to path
        gui_basepath = fileparts(mfilename('fullpath'));
        basepath = fileparts(gui_basepath);
        
        if isdeployed
            res_parh = [userpath filesep 'PhysioZoo' filesep 'Results'];
        else
            res_parh = [basepath filesep 'Results'];
        end
        
        if ~isdir(res_parh)
            warning('off');
            mkdir(res_parh);
            warning('on');
        end
        
        if ~isfield(DIRS, 'analyzedDataDirectory')
            DIRS.analyzedDataDirectory = res_parh;
        end
        if isempty(EXT)
            EXT = 'txt';
        end
        
        original_file_name = DATA.DataFileName;
        file_name = [original_file_name, '_rhythms'];
        
        [filename, results_folder_name, ~] = uiputfile({'*.*', 'All files';...
            '*.txt','Text Files (*.txt)';...
            '*.mat','MAT-files (*.mat)';...
            %             '*.atr; *.qrs','WFDB Files (*.atr; *.qrs)',...
            },...
            'Choose Rhytms File Name',...
            [DIRS.analyzedDataDirectory, filesep, file_name, '.', EXT]);
        
        if ~isequal(results_folder_name, 0)
            DIRS.analyzedDataDirectory = results_folder_name;
            [~, ~, ExtensionFileName] = fileparts(filename);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            
            full_file_name = [results_folder_name, filename];
            
            if isfield(DATA, 'Rhythms_Map') && length(DATA.Rhythms_Map) > 0 && DATA.rhythms_win_num
                rhythms_values = DATA.Rhythms_Map.values();
                for i = 1 : length(DATA.Rhythms_Map)
                    class{i, 1} = rhythms_values{i}.rhythm_type;
                    rhythms(i, :) = rhythms_values{i}.rhythm_range;
                end
            else
                class{1, 1} = DATA.Rhythms_Type{1};
                rhythms = [0, 0];
            end
            
            type = 'rhythms annotation';
            source_file_name = [DATA.DataFileName '.' DATA.ExtensionFileName];
            
            if strcmpi(ExtensionFileName, 'mat')
                save(full_file_name, 'rhythms', 'class', 'type', 'source_file_name');
            elseif strcmpi(ExtensionFileName, 'txt')
                header_fileID = fopen(full_file_name, 'wt');
                
                fprintf(header_fileID, '---\n');
                fprintf(header_fileID, 'type: %s\n', type);
                fprintf(header_fileID, 'source file: %s\n\n', source_file_name);
                fprintf(header_fileID, '---\n\n');
                
                fprintf(header_fileID, 'Beginning\tEnd\t\tClass\n');
                for i = 1 : length(class)
                    fprintf(header_fileID, '%.6f\t%.6f\t%s\n', rhythms(i, 1), rhythms(i, 2), class{i, 1});
                end
                fclose(header_fileID);
                %             elseif strcmpi(ExtensionFileName, 'atr') || strcmpi(ExtensionFileName, 'qrs')
                %                 [~, filename_noExt, ~] = fileparts(full_file_name);
                %
                %                 Rhythms_annotations_for_wfdb = reshape(rhythms', [size(rhythms, 1) * size(rhythms, 2), 1]);
                %                 rhythms_class_for_wfdb = reshape([class class]', [2*size(class, 1), 1])';
                %
                %                 mhrv.wfdb.wrann([results_folder_name filename_noExt], 'atr', int64(Rhythms_annotations_for_wfdb*DATA.Fs), 'fs', DATA.Fs, 'aux', rhythms_class_for_wfdb);
            else
                h_e = errordlg('Please, choose only *.mat, *.txt, *.atr or *.qrs file .', 'Input Error');
                setLogo(h_e, 'M1');
                return;
            end
        end
    end
%%
    function SaveDataQuality_Callback(~, ~)
        persistent DIRS;
        persistent EXT;
        
        % Add third-party dependencies to path
        gui_basepath = fileparts(mfilename('fullpath'));
        basepath = fileparts(gui_basepath);
        
        if isdeployed
            res_parh = [userpath filesep 'PhysioZoo' filesep 'Results'];
        else
            res_parh = [basepath filesep 'Results'];
        end
        
        if ~isdir(res_parh)
            warning('off');
            mkdir(res_parh);
            warning('on');
        end
        
        if ~isfield(DIRS, 'analyzedDataDirectory')
            DIRS.analyzedDataDirectory = res_parh;
        end
        if isempty(EXT)
            EXT = 'txt';
        end
        
        original_file_name = DATA.DataFileName;
        file_name = [original_file_name, '_quality'];
        
        [filename, results_folder_name, ~] = uiputfile({'*.*', 'All files';...
            '*.txt','Text Files (*.txt)';...
            '*.mat','MAT-files (*.mat)'},...
            'Choose Signal Quality File Name',...
            [DIRS.analyzedDataDirectory, filesep, file_name, '.', EXT]);
        % ;...
        %             '*.sqi',  'WFDB Files (*.sqi)'
        if ~isequal(results_folder_name, 0)
            DIRS.analyzedDataDirectory = results_folder_name;
            [~, ~, ExtensionFileName] = fileparts(filename);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            
            full_file_name = [results_folder_name, filename];
            
            if isfield(GUI, 'quality_win') && DATA.quality_win_num
                
                for i = 1 : length(GUI.quality_win)
                    
                    if isvalid(GUI.quality_win(i))
                        quality_range{i} = get(GUI.quality_win(i), 'XData');
                        class_number = get(GUI.quality_win(i), 'UserData');
                        class{i, 1} = DATA.GUI_Class{class_number};
                        signal_quality(i, :) = [min(quality_range{i}) max(quality_range{i})];
                    end
                end
            else
                class{1, 1} = DATA.GUI_Class{3};
                signal_quality = [0, 0];
            end
            
            type = 'quality annotation';
            source_file_name = [DATA.DataFileName '.' DATA.ExtensionFileName];
            
            if strcmpi(ExtensionFileName, 'mat')
                save(full_file_name, 'signal_quality', 'class', 'type', 'source_file_name');
            elseif strcmpi(ExtensionFileName, 'txt')
                header_fileID = fopen(full_file_name, 'wt');
                
                fprintf(header_fileID, '---\n');
                fprintf(header_fileID, 'type: %s\n', type);
                fprintf(header_fileID, 'source file: %s\n\n', source_file_name);
                fprintf(header_fileID, '---\n\n');
                
                fprintf(header_fileID, 'Beginning\tEnd\t\tClass\n');
                for i = 1 : length(class)
                    fprintf(header_fileID, '%.6f\t%.6f\t%s\n', signal_quality(i, 1), signal_quality(i, 2), class{i, 1});
                end
                fclose(header_fileID);
                
                %             elseif strcmpi(ExtensionFileName, 'sqi')
                %                 [~, filename_noExt, ~] = fileparts(full_file_name);
                %
                %                 Quality_annotations_for_wfdb = reshape(signal_quality', [size(signal_quality, 1) * size(signal_quality, 2), 1]);
                %                 Class_for_wfdb = reshape([class class]', [2*size(class, 1), 1])';
                %
                %                 mhrv.wfdb.wrann([results_folder_name filename_noExt], 'sqi', int64(Quality_annotations_for_wfdb*DATA.Fs), 'fs', DATA.Fs, 'type', Class_for_wfdb);
            else
                h_e = errordlg('Please, choose only *.mat or *.txt file .', 'Input Error');
                setLogo(h_e, 'M1');
                return;
            end
        end
    end
%%
    function OpenRhythms_Callback(~, ~)
        persistent DIRS;
        persistent EXT;
        
        % Add third-party dependencies to path
        gui_basepath = fileparts(mfilename('fullpath'));
        basepath = fileparts(gui_basepath);
        
        if ~isfield(DIRS, 'analyzedDataDirectory')
            DIRS.analyzedDataDirectory = [basepath filesep 'ExamplesTXT'];
        end
        if isempty(EXT)
            EXT = 'txt';
        end
        [Rhythms_FileName, PathName] = uigetfile( ...
            {'*.txt','Text Files (*.txt)'; ...
            '*.mat','MAT-files (*.mat)';...
            %             '*.atr; *.qrs','WFDB Files (*.atr; *.qrs)',...
            }, ...
            'Open Rhythms File', [DIRS.analyzedDataDirectory filesep '*.' EXT]);
        
        if ~isequal(Rhythms_FileName, 0)
            
            [~, RhythmsFileName, ExtensionFileName] = fileparts(Rhythms_FileName);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            DIRS.analyzedDataDirectory = PathName;
            
            if isfield(DATA, 'Rhythms_file_name') && ~isempty(DATA.Rhythms_file_name)
                if strcmp(DATA.Rhythms_file_name, [PathName, RhythmsFileName])
                    choice = questdlg(['The file "' RhythmsFileName '" already loaded. Do you want to open the same rhythm file?'], ...
                        'Same Rhythm file', 'Open', 'Cancel', 'Cancel');
                    
                    switch choice
                        case 'Open'
                        case 'Cancel'
                            return;
                    end
                end
            end
                             
            DATA.Rhythms_file_name = [PathName, RhythmsFileName];
            
            if strcmpi(ExtensionFileName, 'mat')
                
                RhythmsAnnotations = load([PathName Rhythms_FileName]);
                RhythmsAnnotations_field_names = fieldnames(RhythmsAnnotations);
                
                RhythmsAnnotations_Data = [];
                type = [];
                
                for i = 1 : length(RhythmsAnnotations_field_names)
                    if ~isempty(regexpi(RhythmsAnnotations_field_names{i}, 'rhythms'))
                        RhythmsAnnotations_Data = RhythmsAnnotations.(RhythmsAnnotations_field_names{i});
                    elseif ~isempty(regexpi(RhythmsAnnotations_field_names{i}, 'class'))
                        RhythmsClass = RhythmsAnnotations.(RhythmsAnnotations_field_names{i});
                    elseif ~isempty(regexpi(RhythmsAnnotations_field_names{i}, 'type'))
                        type = RhythmsAnnotations.(RhythmsAnnotations_field_names{i});
                    end
                end
                if ~isempty(RhythmsAnnotations_Data) && strcmpi(type, 'rhythms annotation')
                    DATA_RhythmsAnnotations_Data = RhythmsAnnotations_Data;
                else
                    h_e = errordlg('Please, choose the Rhythms Annotations File.', 'Input Error');
                    setLogo(h_e, 'M1');
                    return;
                end
                if ~isempty(RhythmsClass)
                    DATA_RhythmsClass = RhythmsClass;
                end
            elseif strcmpi(ExtensionFileName, 'txt')
                
                file_name = [PathName Rhythms_FileName];
                fileID = fopen(file_name);
                if fileID ~= -1
                    
                    rhythms_data = textscan(fileID, '%f %f %s', 'Delimiter', '\t', 'HeaderLines', 7);
                    
                    frewind(fileID);
                    
                    tline1 = fgetl(fileID);
                    tline2 = fgetl(fileID);
                    %                     tline3 = fgetl(fileID);
                    type_line = strsplit(tline2, ': ');
                    %                     source_line = strsplit(tline3, ': ');
                    
                    if strcmp(tline1, '---') && strcmp(type_line{1}, 'type') && strcmp(type_line{2}, 'rhythms annotation')
                        %                         if strcmp(source_line{1}, 'source file') && strcmp(source_line{2}, 'rhythms annotation')
                        %                         end
                        if ~isempty(rhythms_data{1}) && ~isempty(rhythms_data{2}) && ~isempty(rhythms_data{3})
                            DATA_RhythmsAnnotations_Data = [cell2mat(rhythms_data(1)) cell2mat(rhythms_data(2))];
                            class = rhythms_data(3);
                            DATA_RhythmsClass = class{1};
                        else
                            h_e = errordlg('Please, choose the Rhythms Annotations File.', 'Input Error');
                            setLogo(h_e, 'M1');
                            return;
                        end
                    else
                        h_e = errordlg('Please, choose the right format for Rhythms Annotations File.', 'Input Error');
                        setLogo(h_e, 'M1');
                        return;
                    end
                    fclose(fileID);
                else
                    return;
                end
                %             elseif strcmpi(ExtensionFileName, 'atr') || strcmpi(ExtensionFileName, 'qrs')
                %                 [rhythms_data, class] = mhrv.wfdb.rdann([PathName RhythmsFileName], ExtensionFileName);
                %                 rhythms_data = double(rhythms_data)/DATA.Fs;
                %                 DATA_RhythmsAnnotations_Data = [rhythms_data(1:2:end), rhythms_data(2:2:end)];
                %                 DATA_RhythmsClass = class(1:2:end);
            else
                h_e = errordlg('Please, choose only *.mat, *.txt, *.qrs or *.atr file.', 'Input Error');
                setLogo(h_e, 'M1');
                return;
            end
            
            set(GUI.GUIRecord.RhythmsFileName_text, 'String', Rhythms_FileName);
            
            GUI.GUIRecord.Annotation_popupmenu.Value = 3;
            Annotation_popupmenu_Callback();
            
            if isfield(DATA, 'rhythms_win_num') && DATA.rhythms_win_num
                rhythms_win_num = DATA.rhythms_win_num + 1;
            else
                rhythms_win_num = 1;
                DATA.Rhythms_Map = containers.Map('KeyType', 'double', 'ValueType', 'any');
            end
            
            waitbar_handle = waitbar(0, 'Loadind', 'Name', 'Working on it...'); setLogo(waitbar_handle, 'M1');
            
            rhythms_annotations_num = length(DATA_RhythmsClass);
            
            Rhythms_Data = [];
            RhythmsClass = {};
            
            for i = 1 : rhythms_annotations_num
                [is_member, class_ind] = ismember(DATA_RhythmsClass{i}, DATA.Rhythms_Type);
                if ~is_member
                    class_ind = 1;
                end
                if DATA_RhythmsAnnotations_Data(i, 1) ~= DATA_RhythmsAnnotations_Data(i, 2)
                    
                    if ~isKey(DATA.Rhythms_Map, DATA_RhythmsAnnotations_Data(i, 1))
                        waitbar(i / rhythms_annotations_num, waitbar_handle, ['Ploting rhythms for ' num2str(i) ' annotation']); setLogo(waitbar_handle, 'M1');
                        
                        rhythms_struct.rhythm_type = DATA_RhythmsClass{i};
                        rhythms_struct.rhythm_range = DATA_RhythmsAnnotations_Data(i, :);
                        rhythms_struct.rhythm_class_ind = class_ind;
                        rhythms_struct.rhythm_plotted = false;
                        
                        DATA.Rhythms_Map(DATA_RhythmsAnnotations_Data(i, 1)) = rhythms_struct;
                        
                        %                     plot_rhythms_rect(DATA_RhythmsAnnotations_Data(i, :), rhythms_win_num, class_ind);
                        DATA.rhythms_win_num = DATA.rhythms_win_num + 1;
                        %                     rhythms_win_num = rhythms_win_num + 1;
                        %                     Update_Rhytms_Stat_Table(DATA_RhythmsAnnotations_Data(i, :));
                        
                        Rhythms_Data = [Rhythms_Data; DATA_RhythmsAnnotations_Data(i, :)];
                        RhythmsClass = [RhythmsClass; DATA_RhythmsClass{i}];
                    end
                end
            end
            redraw_rhythms_rect();
            if isvalid(waitbar_handle)
                close(waitbar_handle);
            end
%             plot_rhythms_line(DATA_RhythmsAnnotations_Data, DATA_RhythmsClass);
            plot_rhythms_line(Rhythms_Data, RhythmsClass);
            Update_Rhytms_Stat_Table();
        end
    end
%%
    function OpenDataQuality_Callback(~, ~)
        persistent DIRS;
        persistent EXT;
        
        % Add third-party dependencies to path
        gui_basepath = fileparts(mfilename('fullpath'));
        basepath = fileparts(gui_basepath);
        
        if ~isfield(DIRS, 'analyzedDataDirectory')
            DIRS.analyzedDataDirectory = [basepath filesep 'ExamplesTXT'];
        end
        if isempty(EXT)
            EXT = 'txt';
        end
        [Quality_FileName, PathName] = uigetfile( ...
            {'*.txt','Text Files (*.txt)'; ...
            '*.mat','MAT-files (*.mat)'}, ...
            'Open Signal Quality File', [DIRS.analyzedDataDirectory filesep '*.' EXT]); %
        
        %         '*.sqi',  'WFDB Files (*.sqi)'; ...
        
        if ~isequal(Quality_FileName, 0)
            
            [~, QualityFileName, ExtensionFileName] = fileparts(Quality_FileName);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            DIRS.analyzedDataDirectory = PathName;
            
            DATA.quality_file_name = [PathName, QualityFileName];
            
            if strcmpi(ExtensionFileName, 'mat')
                
                QualityAnnotations = load([PathName Quality_FileName]);
                QualityAnnotations_field_names = fieldnames(QualityAnnotations);
                
                QualityAnnotations_Data = [];
                type = [];
                
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
                
                %                 if ~strcmp(source_file_name, [DATA.DataFileName '.' DATA.ExtensionFileName])
                %                     h_e = errordlg('Please, choose appropriate Signal Quality Annotations File.', 'Input Error');
                %                     return;
                %                 end
                
                if ~isempty(QualityAnnotations_Data) && strcmpi(type, 'quality annotation')
                    DATA_QualityAnnotations_Data = QualityAnnotations_Data;
                else
                    h_e = errordlg('Please, choose the Signal Quality Annotations File.', 'Input Error');
                    setLogo(h_e, 'M1');
                    return;
                end
                if ~isempty(Class)
                    DATA_Class = Class;
                end
            elseif strcmpi(ExtensionFileName, 'txt')
                
                file_name = [PathName Quality_FileName];
                fileID = fopen(file_name);
                if fileID ~= -1
                    
                    quality_data = textscan(fileID, '%f %f %s', 'Delimiter', '\t', 'HeaderLines', 7);
                    
                    frewind(fileID);
                    
                    tline1 = fgetl(fileID);
                    tline2 = fgetl(fileID);
                    type_line = strsplit(tline2, ': ');
                    
                    if strcmp(tline1, '---') && strcmp(type_line{1}, 'type') && strcmp(type_line{2}, 'quality annotation')
                        if ~isempty(quality_data{1}) && ~isempty(quality_data{2}) && ~isempty(quality_data{3})
                            DATA_QualityAnnotations_Data = [cell2mat(quality_data(1)) cell2mat(quality_data(2))];
                            class = quality_data(3);
                            DATA_Class = class{1};
                        else
                            h_e = errordlg('Please, choose the Signal Quality Annotations File.', 'Input Error');
                            setLogo(h_e, 'M1');
                            return;
                        end
                    else
                        h_e = errordlg('Please, choose the right format for Signal Quality Annotations File.', 'Input Error');
                        setLogo(h_e, 'M1');
                        return;
                    end
                    fclose(fileID);
                else
                    return;
                end
                
                %             elseif strcmpi(ExtensionFileName, 'sqi')
                % %                 [quality_data, class] = mhrv.wfdb.rdann( [PathName QualityFileName], ExtensionFileName, 'ann_types', '"F"');
                % %                 [quality_data, class] = mhrv.wfdb.rdann( [PathName QualityFileName], ExtensionFileName, 'ann_types', '"ABC"');
                %                 [quality_data, class] = mhrv.wfdb.rdann( [PathName QualityFileName], ExtensionFileName);
                %                 quality_data = double(quality_data)/DATA.Fs;
                %                 DATA_QualityAnnotations_Data = [quality_data(1:2:end), quality_data(2:2:end)];
                %                 DATA_Class = class(1:2:end);
            else
                h_e = errordlg('Please, choose only *.mat or *.txt file.', 'Input Error');
                setLogo(h_e, 'M1');
                return;
            end
            
            set(GUI.GUIRecord.DataQualityFileName_text, 'String', Quality_FileName);
            GUI.GUIRecord.Annotation_popupmenu.Value = 2;
            Annotation_popupmenu_Callback();
            
            if isfield(DATA, 'quality_win_num') && DATA.quality_win_num
                quality_win_ind = DATA.quality_win_num + 1;
            else
                quality_win_ind = 1;
            end
            
            waitbar_handle = waitbar(0, 'Loading', 'Name', 'Working on it...'); setLogo(waitbar_handle, 'M1');
            
            quality_annotations_num = length(DATA_Class);
            
            for i = 1 : quality_annotations_num
                [is_member, class_ind] = ismember(DATA_Class{i}, DATA.GUI_Class);
                if ~is_member
                    class_ind = 3;
                end
                if DATA_QualityAnnotations_Data(i, 1) ~= DATA_QualityAnnotations_Data(i, 2)
                    
                    waitbar(i / quality_annotations_num, waitbar_handle, ['Ploting signal quality for ' num2str(i) ' annotation']); setLogo(waitbar_handle, 'M1');
                    
                    plot_quality_rect(DATA_QualityAnnotations_Data(i, :), quality_win_ind, class_ind);
                    DATA.quality_win_num = DATA.quality_win_num + 1;
                    quality_win_ind = quality_win_ind + 1;
                    Select_Quality_Win(DATA_QualityAnnotations_Data(i, :));
                end
            end
            if isvalid(waitbar_handle)
                close(waitbar_handle);
            end
            plot_quality_line(DATA_QualityAnnotations_Data, DATA_Class);
        end
    end
%%
    function onSaveFiguresAsFile( ~, ~ )
        
        main_screensize = DATA.screensize;
        
        GUI.SaveFiguresWindow = figure( ...
            'Name', 'Save Figures Options', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', ...
            'Position', [(main_screensize(3)-400)/2, (main_screensize(4)-300)/2, 400, 300]);
        
        setLogo(GUI.SaveFiguresWindow, 'M1');
        
        mainSaveFigurestLayout = uix.VBox('Parent', GUI.SaveFiguresWindow, 'Spacing', DATA.Spacing);
        figures_panel = uix.Panel( 'Parent', mainSaveFigurestLayout, 'Padding', DATA.Padding+2, 'Title', 'Select figures to save:', 'FontSize', DATA.BigFontSize+2, 'FontName', 'Calibri', 'BorderType', 'beveledin' );
        figures_box = uix.VButtonBox('Parent', figures_panel, 'Spacing', DATA.Spacing-1, 'HorizontalAlignment', 'left', 'ButtonSize', [200 25]);
        
        uicontrol( 'Style', 'checkbox', 'Parent', figures_box, 'FontSize', DATA.BigFontSize, ...
            'Tag', 'TimeSeries', 'String', 'Session Time Series', 'FontName', 'Calibri', 'Value', 1);
        tempBox1 = uix.HBox('Parent', figures_box, 'Spacing', DATA.Spacing);
        uix.Empty( 'Parent', tempBox1 );
        uicontrol( 'Style', 'checkbox', 'Parent', tempBox1, 'FontSize', DATA.BigFontSize, ...
            'Tag', 'Peaks', 'String', 'Peaks', 'FontName', 'Calibri', 'Value', 1);
        set(tempBox1, 'Widths', [-1 -5]);
        
        tempBox2 = uix.HBox('Parent', figures_box, 'Spacing', DATA.Spacing);
        uix.Empty( 'Parent', tempBox2 );
        uicontrol( 'Style', 'checkbox', 'Parent', tempBox2, 'FontSize', DATA.BigFontSize, ...
            'Tag', 'DataQuality', 'String', 'Signal Quality', 'FontName', 'Calibri', 'Value', 1);
        set(tempBox2, 'Widths', [-1 -5]);
        
        uix.Empty( 'Parent', figures_box );
        
        uicontrol( 'Style', 'checkbox', 'Parent', figures_box, 'FontSize', DATA.BigFontSize, ...
            'Tag', 'RRTimeSeries', 'String', 'RR Time Series', 'FontName', 'Calibri', 'Value', 1);
        tempBox3 = uix.HBox('Parent', figures_box, 'Spacing', DATA.Spacing);
        uix.Empty( 'Parent', tempBox3 );
        uicontrol( 'Style', 'checkbox', 'Parent', tempBox3, 'FontSize', DATA.BigFontSize, ...
            'Tag', 'RRIntQuality', 'String', 'Signal Quality', 'FontName', 'Calibri', 'Value', 1);
        set(tempBox3, 'Widths', [-1 -5]);
        
        CommandsButtons_Box = uix.HButtonBox('Parent', mainSaveFigurestLayout, 'Spacing', DATA.Spacing, 'VerticalAlignment', 'middle', 'ButtonSize', [100 30]);
        uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', @dir_button_Callback, 'FontSize', DATA.BigFontSize, 'String', 'Save As', 'FontName', 'Calibri');
        uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', @cancel_button_Callback, 'FontSize', DATA.BigFontSize, 'String', 'Cancel', 'FontName', 'Calibri');
        
        set( mainSaveFigurestLayout, 'Heights',  [-70 -30]);
    end
%%
    function dir_button_Callback( ~, ~ )
        
        persistent DIRS;
        persistent DATA_Fig;
        
        % Add third-party dependencies to path
        gui_basepath = fileparts(mfilename('fullpath'));
        basepath = fileparts(gui_basepath);
        
        if isdeployed
            res_parh = [userpath filesep 'PhysioZoo' filesep 'Results'];
        else
            res_parh = [basepath filesep 'Results'];
        end
        
        if ~isdir(res_parh)
            warning('off');
            mkdir(res_parh);
            warning('on');
        end
        
        if ~isfield(DIRS, 'analyzedDataDirectory')
            DIRS.analyzedDataDirectory = res_parh;
        end
        if isempty(DATA_Fig)
            DATA_Fig.Ext = 'png';
        end
        
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
            [DIRS.analyzedDataDirectory, filesep, [DATA.DataFileName, '.', DATA_Fig.Ext]]);
        if ~isequal(fig_path, 0)
            DIRS.analyzedDataDirectory = fig_path;
            
            [~, fig_name, fig_ext] = fileparts(fig_full_name);
            
            DATA_Fig.FigFileName = fig_name;
            if ~isempty(fig_ext)
                DATA_Fig.Ext = fig_ext(2:end);
            else
                DATA_Fig.Ext = 'png';
            end
            saveAs_figures_button(DIRS.analyzedDataDirectory, DATA_Fig.FigFileName, DATA_Fig.Ext);
        end
    end
%%
    function saveAs_figures_button(fig_path, fig_name, fig_ext)
        
        if ~isempty(fig_path) && ~isempty(fig_name) && ~isempty(fig_ext)
            
            figures_names = {'_data'; '_rr_int'};
            
            ext = fig_ext(1:end);
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
            
            axes_array = [GUI.ECG_Axes GUI.RRInt_Axes];
            
            for i = 1 : length(axes_array)
                
                axes_handle = axes_array(i);
                
                af = figure;
                set(af, 'Name', [fig_name figures_names{i}], 'NumberTitle', 'off');
                new_axes = copyobj(axes_handle, af);
                xlabel(new_axes, 'Time (h:min:sec)');
                
                uicontrolData = findobj(GUI.SaveFiguresWindow, 'Tag', 'TimeSeries');
                uicontrolPeaks = findobj(GUI.SaveFiguresWindow, 'Tag', 'Peaks');
                uicontrolRRInt = findobj(GUI.SaveFiguresWindow, 'Tag', 'RRTimeSeries');
                uicontrolDataQuality = findobj(GUI.SaveFiguresWindow, 'Tag', 'DataQuality');
                uicontrolRRIntQuality = findobj(GUI.SaveFiguresWindow, 'Tag', 'RRIntQuality');
                
                try
                    line_handle = findobj(new_axes.Children, 'Tag', 'red_zoom_rect');
                    delete(line_handle);
                    
                    if ~uicontrolData.Value
                        line_handle = findobj(new_axes.Children, 'Tag', 'RawData');
                        delete(line_handle);
                    end
                    if ~uicontrolPeaks.Value
                        line_handle = findobj(new_axes.Children, 'Tag', 'Peaks');
                        delete(line_handle);
                    end
                    if ~uicontrolRRInt.Value
                        line_handle = findobj(new_axes.Children, 'Tag', 'RRInt');
                        delete(line_handle);
                    end
                    if ~uicontrolDataQuality.Value
                        line_handle = findobj(new_axes.Children, 'Tag', 'DataQuality');
                        delete(line_handle);
                    end
                    if ~uicontrolRRIntQuality.Value
                        line_handle = findobj(new_axes.Children, 'Tag', 'RRIntQuality');
                        delete(line_handle);
                    end
                    
                    if ~isempty(new_axes.Children)
                        file_name = [export_path_name figures_names{i}];
                        
                        if exist([file_name '.' ext], 'file')
                            button = questdlg([file_name '.' ext ' already exist. Do you want to overwrite it?'], 'Overwrite existing file?', 'Yes', 'No', 'No');
                            if strcmp(button, 'No')
                                close(af);
                                continue;
                            end
                        end
                        if strcmpi(ext, 'fig')
                            savefig(af, file_name, 'compact');
                        elseif ~strcmpi(ext, 'fig')
                            mhrv.util.fig_print( af, file_name, 'output_format', ext, 'font_size', 16, 'width', 20);
                        end
                    end
                    close(af);
                catch e
                    disp(e);
                end
            end
        else
            h_e = errordlg('Please enter valid path to save figures', 'Input Error');
            setLogo(h_e, 'M1');
        end
        delete(GUI.SaveFiguresWindow);
    end
%%
    function Movie_Delay_Callback(src, ~)
        if ~isPositiveNumericValue(src.String)
            src.String = src.UserData;
        else
            speed = int32(str2double(src.String));
            if speed < 1
                speed = 1;
            elseif speed > 0.25/0.001
                speed = 0.25/0.001; % min delay for timer is 1 milisecond
            end
            src.String = speed;
        end
        src.UserData = src.String;
    end
%%
    function FirstSecond_Callback(~, ~)
        if isfield(GUI, 'red_rect_handle')
            xdata = get(GUI.red_rect_handle, 'XData');
            
            if ~isempty(xdata)
                red_rect_length = max(xdata) - min(xdata);
                screen_value = GUI.GUIDisplay.FirstSecond.String;
                [firstSecond2Show, isInputNumeric] = calcDurationInSeconds(GUI.GUIDisplay.FirstSecond, screen_value, GUI.GUIDisplay.FirstSecond.UserData);
                if isInputNumeric
                    if firstSecond2Show < 0 || firstSecond2Show > DATA.maxRRTime - red_rect_length  % + 1
                        set(GUI.GUIDisplay.FirstSecond, 'String', calcDuration(GUI.GUIDisplay.FirstSecond.UserData, 0));
                        h_e = errordlg('The first second value must be grater than 0 and less than signal length!', 'Input Error'); setLogo(h_e, 'M1');
                        return;
                    end
                    GUI.GUIDisplay.FirstSecond.UserData = firstSecond2Show;
                    xdata = [firstSecond2Show firstSecond2Show+red_rect_length firstSecond2Show+red_rect_length firstSecond2Show firstSecond2Show];
                    set(GUI.red_rect_handle, 'XData', xdata);
                    ChangePlot(xdata);
                    EnablePageUpDown();
                    DATA.zoom_rect_limits = [xdata(1) xdata(2)];
                    
                    set_ticks = 0;
                    AllDataAxes_XLim = get(GUI.RRInt_Axes, 'XLim');
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
                        set(GUI.RRInt_Axes, 'XLim', AllDataAxes_XLim + AllDataAxes_offset);
                        setAxesXTicks(GUI.RRInt_Axes);
                    end
                    setRRIntYLim();
                    redraw_quality_rect();
                    redraw_rhythms_rect();
                end
            end
        end
    end
%%
    function WindowSize_Callback(~, ~)
        if isfield(GUI, 'red_rect_handle')
            xdata = get(GUI.red_rect_handle, 'XData');
            
            if ~isempty(xdata)
                firstSecond2Show = min(xdata);
                screen_value = GUI.GUIDisplay.WindowSize.String;
                [MyWindowSize, isInputNumeric]  = calcDurationInSeconds(GUI.GUIDisplay.WindowSize, screen_value, GUI.GUIDisplay.WindowSize.UserData);
                
                if isInputNumeric
                    if MyWindowSize <= 0 || (MyWindowSize + firstSecond2Show) > DATA.maxRRTime % || MyWindowSize > DATA.maxSignalLength
                        set(GUI.GUIDisplay.WindowSize, 'String', calcDuration(GUI.GUIDisplay.WindowSize.UserData, 0));
                        h_e = errordlg('The window size must be greater than 0 sec and less than signal length!', 'Input Error'); setLogo(h_e, 'M1');
                        return;
                    elseif MyWindowSize > DATA.RRIntPage_Length
                        set(GUI.GUIDisplay.WindowSize, 'String', calcDuration(GUI.GUIDisplay.WindowSize.UserData, 0));
                        h_e = errordlg('The zoom window length must be smaller than display duration length!', 'Input Error'); setLogo(h_e, 'M1');
                        return;
                    end
                    if abs(DATA.maxRRTime - MyWindowSize) <=  1 %0.0005
                        set(GUI.GUIDisplay.FirstSecond, 'Enable', 'off');
                    else
                        set(GUI.GUIDisplay.FirstSecond, 'Enable', 'on');
                    end
                    GUI.GUIDisplay.WindowSize.UserData = MyWindowSize;
                    
                    xdata = [firstSecond2Show firstSecond2Show+MyWindowSize firstSecond2Show+MyWindowSize firstSecond2Show firstSecond2Show];
                    set(GUI.red_rect_handle, 'XData', xdata);
                    ChangePlot(xdata);
                    EnablePageUpDown();
                    DATA.zoom_rect_limits = [xdata(1) xdata(2)];
                    setRRIntYLim();
                    redraw_quality_rect();
                    redraw_rhythms_rect();
                end
            end
        end
    end
%%
    function GridX_checkbox_Callback(~, ~)
        setXECGGrid(GUI.ECG_Axes, GUI.GridX_checkbox);
    end
%%
    function GridY_checkbox_Callback(~, ~)
        setYECGGrid(GUI.ECG_Axes, GUI.GridY_checkbox);
    end
%%
    function LowHightCutoffFr_Edit(src, ~)
        lcf = GUI.GUIDisplay.LowCutoffFr_Edit.String;
        hcf = GUI.GUIDisplay.HightCutoffFr_Edit.String;
        
        if isPositiveNumericValue(lcf) && isPositiveNumericValue(hcf) && str2double(lcf) < str2double(hcf) && str2double(hcf) < DATA.Fs/2
            calc_plot_flitered_data();
            src.UserData(GUI.GUIDisplay.FilterLevel_popupmenu.Value) = str2double(src.String);
        else
            if str2double(hcf) >= DATA.Fs/2
                error_str = 'The upper cutoff frequency must be inferior to half of the sampling frequency.';
            else
                error_str = 'Please, enter correct values!';
            end
            h_e = errordlg(error_str, 'Input Error'); setLogo(h_e, 'M1');
            src.String = src.UserData(GUI.GUIDisplay.FilterLevel_popupmenu.Value);
        end
    end
%%
    function set_default_filter_level_user_data()
        GUI.GUIDisplay.LowCutoffFr_Edit.UserData = [0.5 1 2];
        GUI.GUIDisplay.HightCutoffFr_Edit.UserData = [100 80 45];
        if isfield(DATA, 'Fs') && DATA.Fs ~= 0
            GUI.GUIDisplay.HightCutoffFr_Edit.UserData(1) = min(100, int32(DATA.Fs/2)-1);
        end
        GUI.GUIDisplay.LowCutoffFr_Edit.String = GUI.GUIDisplay.LowCutoffFr_Edit.UserData(1);
        GUI.GUIDisplay.HightCutoffFr_Edit.String = GUI.GUIDisplay.HightCutoffFr_Edit.UserData(1);
    end
%%
    function FilterLevel_popupmenu_Callback(src, ~)
        GUI.GUIDisplay.LowCutoffFr_Edit.String = GUI.GUIDisplay.LowCutoffFr_Edit.UserData(src.Value);
        GUI.GUIDisplay.HightCutoffFr_Edit.String = GUI.GUIDisplay.HightCutoffFr_Edit.UserData(src.Value);
        calc_plot_flitered_data();
    end
%%
    function ShowRawSignal_checkbox_Callback(src, ~)
        if isfield(GUI, 'RawData_handle')
            if src.Value
                GUI.RawData_handle.Visible = 'on';
                uistack(GUI.RawData_handle, 'top');
            else
                GUI.RawData_handle.Visible = 'off';
            end
        end
    end
%%
    function ShowFilteredSignal_checkbox_Callback(src, ~)
        if isfield(GUI, 'RawData_handle')
            if src.Value
                GUI.FilterLevelBox.Visible = 'on';
                GUI.CutoffFrBox.Visible = 'on';
                
                if isfield(GUI, 'FilteredData_handle') && ishandle(GUI.FilteredData_handle) && isvalid(GUI.FilteredData_handle)
                    GUI.FilteredData_handle.Visible = 'on';
                else
                    if isfield(DATA, 'sig')
                        calc_plot_flitered_data();
                    end
                end
            else
                if isfield(GUI, 'FilteredData_handle') && ishandle(GUI.FilteredData_handle) && isvalid(GUI.FilteredData_handle)
                    GUI.FilteredData_handle.Visible = 'off';
                end
                GUI.FilterLevelBox.Visible = 'off';
                GUI.CutoffFrBox.Visible = 'off';
            end
        end
    end
%%
    function calc_plot_flitered_data()
        try
            delete(GUI.FilteredData_handle);
        catch
        end
        lcf = str2double(GUI.GUIDisplay.LowCutoffFr_Edit.String);
        hcf = str2double(GUI.GUIDisplay.HightCutoffFr_Edit.String);
        try
            bpecg = mhrv.ecg.bpfilt(DATA.sig, DATA.Fs, lcf, hcf, [], 0);
            GUI.FilteredData_handle = line(DATA.tm, bpecg, 'Parent', GUI.ECG_Axes, 'Tag', 'FilteredData', 'Color', 'b');
            xdata = get(GUI.red_rect_handle, 'XData');
            setECGYLim(xdata(1), xdata(2));
        catch e
            h_e = errordlg(['BP Filter error: ' e.message], 'Input Error'); setLogo(h_e, 'M1');
        end
    end
%%
    function Rhythms_ToggleButton_Callback(src, ~)
        for i = 1 : length(DATA.Rhythms_Type)
            GUI.rhythms_legend(i).Value = 0;
        end
        src.Value = 1;
        GUI.GUIRecord.Rhythms_popupmenu.Value = src.UserData;
    end
%%
    function Rhythms_ToggleButton_Reset()
        for i = 1 : length(DATA.Rhythms_Type)
            GUI.rhythms_legend(i).Value = 0;
        end
    end
%%
    function cancel_button_Callback(~, ~)
        delete(GUI.SaveFiguresWindow);
    end
%%
    function onPhysioZooHome( ~, ~ )
        %         url = 'http://www.physiozoo.com/';
        url = 'https://physiozoo.readthedocs.io/';
        web(url,'-browser')
    end
%%
    function onHelp( ~, ~ )
    end
%%
    function Exit_Callback( ~, ~ )
        % User wants to quit out of the application
        delete_temp_wfdb_files();
        if isfield(GUI, 'timer_object')
            delete(GUI.timer_object);
        end
        delete(GUI.Window);
    end % onExit
end