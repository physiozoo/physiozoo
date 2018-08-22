function PhysioZooGUI_PeakDetection()

myUpBackgroundColor = [205 237 240]/255; % Blue %[0.863 0.941 0.906]; % [219 237 240]/255
myLowBackgroundColor = [205 237 240]/255; %[219 237 240]/255
myEditTextColor = [1 1 1];
mySliderColor = [0.8 0.9 0.9];
myPushButtonColor = [0.26 0.37 0.41];

clearData();
DATA = createData();
GUI = createInterface();
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
        
        DATA.Mammal = '';
        DATA.mammal_index = 1;
        
        DATA.Integration = 'ECG';
        DATA.integration_index = 1;
        
        DATA.peakDetection_index = 1;
        
        DATA.config_map = [];
        DATA.customConfigFile = '';
        DATA.wfdb_record_name = '';
        
        DATA.peak_search_win = 100;
        
        DATA.PlotHR = 0;
        
        DATA.maxRRTime = 0;
        
        DATA.prev_point_ecg = 0;
        DATA.prev_point = 0;
        
        DATA.RRIntPage_Length = 0;
        
        DATA.quality_win_num = 0;
    end
%%
    function clean_gui()
        
        cla(GUI.ECG_Axes); % RawData_axes
        cla(GUI.RRInt_Axes); % RR_axes
        
        set(GUI.GUIRecord.RecordFileName_text, 'String', '');
        set(GUI.GUIRecord.PeaksFileName_text, 'String', '');
        set(GUI.GUIRecord.DataQualityFileName_text, 'String', '');
        set(GUI.GUIRecord.TimeSeriesLength_text, 'String', '');
        
        set(GUI.GUIDisplay.RRIntPage_Length, 'String', '');
        set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'String', '');
        set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'String', '');
        
        set(GUI.GUIDisplay.FirstSecond, 'String', '');
        set(GUI.GUIDisplay.WindowSize, 'String', '');
        set(GUI.GUIDisplay.MinYLimit_Edit, 'String', '');
        set(GUI.GUIDisplay.MaxYLimit_Edit, 'String', '');
        
        GUI.AutoPeakWin_checkbox.Value = 1;
        set(GUI.GUIConfig.PeaksWindow, 'String', '');
        
        GUI.GUIRecord.Annotation_popupmenu.Value = 1;
        GUI.GUIRecord.Class_popupmenu.Visible = 'off';
        GUI.Class_Text.Visible = 'off';
        
        
        title(GUI.ECG_Axes, '');
        
        %         GUI.AutoCalc_checkbox.Value = 1;
        %         GUI.AutoCompute_pushbutton.Enable = 'inactive';
        
        set(GUI.GUIRecord.Mammal_popupmenu, 'Value', 1);
        set(GUI.GUIRecord.PeakDetector_popupmenu, 'Value', 1);
        
        GUI.LoadConfigurationFile.Enable = 'off';
        GUI.SaveConfigurationFile.Enable = 'off';
        GUI.SavePeaks.Enable = 'off';
        GUI.LoadPeaks.Enable = 'off';
        GUI.SaveDataQuality.Enable = 'off';
        GUI.OpenDataQuality.Enable = 'off';
        
        GUI.PeaksTable.Data(:, 2) = {0};
        
        set(GUI.Window, 'WindowButtonMotionFcn', '');
        set(GUI.Window, 'WindowButtonUpFcn', '');
        set(GUI.Window, 'WindowButtonDownFcn', '');
    end
%%
    function DATA = createData()
        
        DATA.screensize = get( 0, 'Screensize' );
        
        % DEBUGGING MODE - Small Screen
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
        
        DATA.mammals = {'', 'human', 'dog', 'rabbit', 'mouse', 'custom'};
        DATA.GUI_mammals = {'Please, choose mammal'; 'Human'; 'Dog'; 'Rabbit'; 'Mouse'; 'Custom'};
        DATA.mammal_index = 1;
        
        DATA.GUI_Integration = {'ECG'; 'Electrogram'; 'Action Potential'};
        DATA.Integration_From_Files = {'electrocardiogram'; 'ECG'; 'Electrogram'; 'Action Potential'};
        %         DATA.Integration = 'ECG';
        %         DATA.integration_index = 1;
        
        
        DATA.GUI_PeakDetector = {'rgrs'; 'ptqrs'; 'wptqrs'};
        DATA.peakDetection_index = 1;
        
        DATA.GUI_Annotation = {'Peak'; 'Signal quality'};
        DATA.GUI_Class = {'A'; 'B'; 'C'};
        
        rec_colors = lines(5);
        DATA.quality_color = {rec_colors(5, :); rec_colors(3, :); rec_colors(2, :)};
        
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
        GUI.OpenDataQuality = uimenu( GUI.FileMenu, 'Label', 'Open signal quality file', 'Callback', @OpenDataQuality_Callback, 'Accelerator', 'Q');
        GUI.SaveDataQuality = uimenu( GUI.FileMenu, 'Label', 'Save signal quality file', 'Callback', @SaveDataQuality_Callback, 'Accelerator', 'D');
        GUI.LoadPeaks = uimenu( GUI.FileMenu, 'Label', 'Load peaks', 'Callback', @LoadPeaks_Callback, 'Accelerator', 'L');
        GUI.SavePeaks = uimenu( GUI.FileMenu, 'Label', 'Save peaks', 'Callback', @SavePeaks_Callback, 'Accelerator', 'S');
        GUI.LoadConfigurationFile = uimenu( GUI.FileMenu, 'Label', 'Load configuration file', 'Callback', @LoadConfigurationFile_Callback, 'Accelerator', 'F');
        GUI.SaveConfigurationFile = uimenu( GUI.FileMenu, 'Label', 'Save configuration file', 'Callback', @SaveConfigurationFile_Callback, 'Accelerator', 'C');
        
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
        
        upper_part = 0.5;
        low_part = 1 - upper_part;
        set(mainLayout, 'Heights', [(-1)*upper_part, (-1)*low_part]  );
        
        % + Upper Panel - Left and Right Parts
        temp_panel_left = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding);
        temp_panel_right = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding); % , 'BorderType', 'none'
        temp_panel_buttons = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding); % , 'BorderType', 'none'
        temp_vbox_buttons = uix.VBox( 'Parent', temp_panel_buttons, 'Spacing', DATA.Spacing);
        
        if DATA.SmallScreen
            left_part = 0.4;
        else
            left_part = 0.265;  % 0.26
        end
        right_part = 0.9;
        buttons_part = 0.08; % 0.07
        Left_Part_widths_in_pixels = 0.3 * DATA.window_size(1);
        
        set(Upper_Part_Box, 'Widths', [-1*left_part -1*right_part -1*buttons_part]);
        
        RightLeft_TabPanel = uix.TabPanel('Parent', temp_panel_left, 'Padding', DATA.Padding);
        two_axes_box = uix.VBox('Parent', temp_panel_right, 'Spacing', DATA.Spacing);
        CommandsButtons_Box = uix.VButtonBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        PageUpDownButtons_Box = uix.HButtonBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'Padding', DATA.Padding, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        
        set(temp_vbox_buttons, 'Heights', [-100, -35]);
        
        RecordTab = uix.Panel( 'Parent', RightLeft_TabPanel, 'Padding', DATA.Padding);
        ConfigParamTab = uix.Panel( 'Parent', RightLeft_TabPanel, 'Padding', DATA.Padding);
        DisplayTab = uix.Panel( 'Parent', RightLeft_TabPanel, 'Padding', DATA.Padding);
        
        RightLeft_TabPanel.TabTitles = {'Record', 'Configuration', 'Display'};
        RightLeft_TabPanel.TabWidth = 100;
        RightLeft_TabPanel.FontSize = BigFontSize;
        
        GUI.ECG_Axes = axes('Parent', uicontainer('Parent', two_axes_box), 'Tag', 'GUI.ECG_Axes');
        GUI.RRInt_Axes = axes('Parent', uicontainer('Parent', two_axes_box), 'Tag', 'GUI.RRInt_Axes');
        
        set(two_axes_box, 'Heights', [-1, 100]);
        
        GUI.AutoCompute_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', CommandsButtons_Box, 'Callback', @AutoCompute_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'Compute', 'Enable', 'off');
        GUI.AutoCalc_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', CommandsButtons_Box, 'Callback', @AutoCalc_checkbox_Callback, 'FontSize', SmallFontSize-1, 'String', 'Auto Compute', 'Value', 1);
        
        GUI.RR_or_HR_plot_button = uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', @RR_or_HR_plot_button_Callback, 'FontSize', BigFontSize, 'String', 'Plot HR');
        GUI.Reset_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', CommandsButtons_Box, 'Callback', @Reset_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Reset');
        set(CommandsButtons_Box, 'ButtonSize', [110, 25], 'Spacing', DATA.Spacing); % [70, 25]
        
        GUI.PageDownButton = uicontrol( 'Style', 'PushButton', 'Parent', PageUpDownButtons_Box, 'Callback', @page_down_pushbutton_Callback, 'FontSize', BigFontSize, 'String', sprintf('\x25C0'), 'Visible', 'on');  % 2190'
        GUI.PageUpButton = uicontrol( 'Style', 'PushButton', 'Parent', PageUpDownButtons_Box, 'Callback', @page_up_pushbutton_Callback, 'FontSize', BigFontSize, 'String', sprintf('\x25B6'), 'Visible', 'on');  % 2192
        set( PageUpDownButtons_Box, 'ButtonSize', [70, 25], 'Spacing', DATA.Spacing  );
        
        
        tabs_widths = Left_Part_widths_in_pixels;
        tabs_heights = 370;
        
        RecordSclPanel = uix.ScrollingPanel( 'Parent', RecordTab);
        RecordBox = uix.VBox( 'Parent', RecordSclPanel, 'Spacing', DATA.Spacing);
        set(RecordSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        ConfigSclPanel = uix.ScrollingPanel( 'Parent', ConfigParamTab);
        GUI.ConfigBox = uix.VBox( 'Parent', ConfigSclPanel, 'Spacing', DATA.Spacing);
        set(ConfigSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        DisplaySclPanel = uix.ScrollingPanel( 'Parent', DisplayTab);
        DisplayBox = uix.VBox( 'Parent', DisplaySclPanel, 'Spacing', DATA.Spacing);
        set(DisplaySclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        %-------------------------------------------------------
        % Record Tab
        
        [GUI, textBox{1}, text_handles{1}] = createGUITextLine(GUI, 'GUIRecord', 'RecordFileName_text', 'Record file name:', RecordBox );
        [GUI, textBox{2}, text_handles{2}] = createGUITextLine(GUI, 'GUIRecord', 'PeaksFileName_text', 'Peaks file name:', RecordBox);
        [GUI, textBox{3}, text_handles{3}] = createGUITextLine(GUI, 'GUIRecord', 'DataQualityFileName_text', 'Signal quality file name:', RecordBox);
        [GUI, textBox{4}, text_handles{4}] = createGUITextLine(GUI, 'GUIRecord', 'TimeSeriesLength_text', 'Time series length:', RecordBox);
        
        [GUI, textBox{5}, text_handles{5}] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'Mammal_popupmenu', 'Mammal', RecordBox, @Mammal_popupmenu_Callback, DATA.GUI_mammals);
        [GUI, textBox{6}, text_handles{6}] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'Integration_popupmenu', 'Integration level', RecordBox, @Integration_popupmenu_Callback, DATA.GUI_Integration);
        [GUI, textBox{7}, text_handles{7}] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'PeakDetector_popupmenu', 'Peak detector', RecordBox, @PeakDetector_popupmenu_Callback, DATA.GUI_PeakDetector);
        [GUI, textBox{8}, text_handles{8}] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'Annotation_popupmenu', 'Annotation', RecordBox, @Annotation_popupmenu_Callback, DATA.GUI_Annotation);
        [GUI, textBox{9}, text_handles{9}] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'Class_popupmenu', 'Class', RecordBox, @Class_popupmenu_Callback, DATA.GUI_Class);
        
        GUI.GUIRecord.Class_popupmenu.Visible = 'off';
        GUI.GUIRecord.Class_popupmenu.Value = 3;
        GUI.Class_Text = text_handles{9};
        GUI.Class_Text.Visible = 'off';
        
        max_extent_control = calc_max_control_x_extend(text_handles);
        
        field_size = [max_extent_control, -1, 1];
        for i = 1 : 4
            set(textBox{i}, 'Widths', field_size);
        end
        
        if DATA.SmallScreen
            field_size = [max_extent_control + 5, -0.56, -0.2];
        else
            field_size = [max_extent_control + 5, -0.45, -0.5];
        end
        
        for i = 5 : 9
            set(textBox{i}, 'Widths', field_size);
        end
                
        uix.Empty( 'Parent', RecordBox);
        set(RecordBox, 'Heights', [-7 -7 -7 -7 -7 -7 -7 -7 -7 -20] );
        
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
        
        uicontrol( 'Style', 'text', 'Parent', GUI.ConfigBox, 'String', 'ptqrs/wptqrs', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
        [GUI, textBox{8}, text_handles{8}] = createGUISingleEditLine(GUI, 'GUIConfig', 'lcf', 'Lower cutoff frequency', 'Hz', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'lcf');
        [GUI, textBox{9}, text_handles{9}] = createGUISingleEditLine(GUI, 'GUIConfig', 'hcf', 'Upper cutoff frequency', 'Hz', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'hcf');
        [GUI, textBox{10}, text_handles{10}] = createGUISingleEditLine(GUI, 'GUIConfig', 'thr', 'Threshold', 'n.u.', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'thr');
        [GUI, textBox{11}, text_handles{11}] = createGUISingleEditLine(GUI, 'GUIConfig', 'rp', 'Refractory period', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'rp');
        [GUI, textBox{12}, text_handles{12}] = createGUISingleEditLine(GUI, 'GUIConfig', 'ws', 'Window size', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'ws');
                        
        uix.Empty('Parent', GUI.ConfigBox );
        
        GUI.AutoPeakWin_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', GUI.ConfigBox, 'FontSize', SmallFontSize, 'String', 'Auto', 'Value', 1);
        [GUI, textBox{13}, text_handles{13}] = createGUISingleEditLine(GUI, 'GUIConfig', 'PeaksWindow', 'Peaks window', 'ms', GUI.ConfigBox, @Peaks_Window_edit_Callback, '', '');
        
        %         uix.Empty('Parent', GUI.ConfigBox );
        %
        %         tempBox = uix.HBox('Parent', GUI.ConfigBox, 'Spacing', DATA.Spacing);
        %         uix.Empty('Parent', tempBox );
        %         GUI.AutoCompute_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', tempBox, 'Callback', @Del_win_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'Del Win');
        %         uix.Empty('Parent', tempBox );
        %         uix.Empty('Parent', tempBox );
        
%         uix.Empty('Parent', GUI.ConfigBox );
        set(GUI.ConfigBox, 'Heights', [-7 -7 -7 -7 -7 -7 -7 -7   -1 -7 -7 -7 -7 -7 -7   -8 -7 -7] );
        %-------------------------------------------------------
        % Display Tab
        %         field_size = [110, 140, 10, -1];
        
        uix.Empty( 'Parent', DisplayBox );
        
        [GUI, textBox{14}, text_handles{14}] = createGUISingleEditLine(GUI, 'GUIDisplay', 'FirstSecond', 'Window start:', 'h:min:sec', DisplayBox, @FirstSecond_Callback, '', '');
        [GUI, textBox{15}, text_handles{15}] = createGUISingleEditLine(GUI, 'GUIDisplay', 'WindowSize', 'Window length:', 'h:min:sec', DisplayBox, @WindowSize_Callback, '', '');
        
        %         field_size = [110, 64, 4, 63, 10];
        [GUI, YLimitBox, text_handles{16}] = createGUIDoubleEditLine(GUI, 'GUIDisplay', {'MinYLimit_Edit'; 'MaxYLimit_Edit'}, 'Y Limit:', '', DisplayBox, {@MinMaxYLimit_Edit_Callback; @MinMaxYLimit_Edit_Callback}, '', '');                
        
        uix.Empty('Parent', DisplayBox );
        
        
        [GUI, textBox{17}, text_handles{17}] = createGUISingleEditLine(GUI, 'GUIDisplay', 'RRIntPage_Length', 'Display duration:', 'h:min:sec', DisplayBox, @RRIntPage_Length_Callback, '', '');
        [GUI, YLimitBox2, text_handles{18}] = createGUIDoubleEditLine(GUI, 'GUIDisplay', {'MinYLimitLowAxes_Edit'; 'MaxYLimitLowAxes_Edit'}, 'Y Limit:', '', DisplayBox, {@MinMaxYLimitLowAxes_Edit_Callback; @MinMaxYLimitLowAxes_Edit_Callback}, '', '');                
        
        set(GUI.GUIDisplay.FirstSecond, 'Enable', 'off');
        set(GUI.GUIDisplay.WindowSize, 'Enable', 'off');
        set(GUI.GUIDisplay.MinYLimit_Edit, 'Enable', 'off');
        set(GUI.GUIDisplay.MaxYLimit_Edit, 'Enable', 'off');
        set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'Enable', 'off');
        set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'Enable', 'off');
                
        max_extent_control = calc_max_control_x_extend(text_handles);
        
        field_size = [max_extent_control, 150, 10 -1];
        for i = 1 : length(text_handles) - 1
            set(textBox{i}, 'Widths', field_size);
        end
        
        field_size = [max_extent_control, 72, 2, 70, 10];
        set(YLimitBox, 'Widths', field_size);
        
        field_size = [max_extent_control, 72, 2, 70, 10];
        set(YLimitBox2, 'Widths', field_size);
        
        GUI.AutoScaleY_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', YLimitBox, 'Callback', @AutoScaleY_pushbutton_Callback, 'FontSize', 10, 'String', 'Auto Scale Y', 'Value', 1, 'Enable', 'off');
        set(YLimitBox, 'Widths', [field_size, 95]);
        
        GUI.AutoScaleYLowAxes_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', YLimitBox2, 'Callback', @AutoScaleYLowAxes_pushbutton_Callback, 'FontSize', 10, 'String', 'Auto Scale Y', 'Value', 1, 'Enable', 'off');
        set(YLimitBox2, 'Widths', [field_size, 95]);
        
        uix.Empty( 'Parent', DisplayBox );
        set(DisplayBox, 'Heights', [-7 -7 -7 -7 -7 -7 -7 -50] );
        
        %-------------------------------------------------------
        
        % Low Part
        Low_Part_Box = uix.VBox('Parent', Low_Part_BoxPanel, 'Spacing', DATA.Spacing);
        
        GUI.PeaksTable = uitable( 'Parent', Low_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{550 'auto'}, 'FontName', 'Calibri');
        GUI.PeaksTable.ColumnName = {'Description'; 'Values'};
        %         GUI.PeaksTable.RowName = {'NB PEAKS (n.u.)'; 'NB PEAKS_ADD (n.u.)'; 'PR PEAKS ADD (%)'; 'NB PEAKS RM (n.u.)'; 'PR PEAKS RM (%)'; 'PR BAD SQ (%)'};
        GUI.PeaksTable.RowName = {'NB PEAKS (n.u.)'; 'NB PEAKS ADD (n.u.)'; 'NB PEAKS RM (n.u.)'; 'PR BAD SQ (%)'};
        GUI.PeaksTable.Data = {''};
        GUI.PeaksTable.Data(1, 1) = {'Total number of peaks'};    % Number of peaks detected by the peak detection algorithm
        GUI.PeaksTable.Data(2, 1) = {'Number of peaks manually added by the user'}; % Number of peaks manually added by the user
        %         GUI.PeaksTable.Data(3, 1) = {'Percentage of manually added peaks'}; % Percentage of peaks manually added by the user
        GUI.PeaksTable.Data(3, 1) = {'Number of peaks manually removed by the user'}; % Number of peaks manually removed by the user
        %         GUI.PeaksTable.Data(5, 1) = {'Percentage of manually removed peaks'}; % Percentage of peaks manually removed by the user
        GUI.PeaksTable.Data(4, 1) = {['Percentage of the record annotated as bad quality (i.e. signal quality ' sprintf('\x2260') ' ''A'')']};
        GUI.PeaksTable.Data(:, 2) = {0};
        
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
        
        GUI.OpenDataQuality.Enable = 'off';
        GUI.SaveDataQuality.Enable = 'off';
        GUI.LoadConfigurationFile.Enable = 'off';
        GUI.SaveConfigurationFile.Enable = 'off';
        GUI.SavePeaks.Enable = 'off';
        GUI.LoadPeaks.Enable = 'off';
    end
%%
    function [GUI, TempBox, uicontrol_handle] = createGUITextLine(GUI, gui_struct, field_name, string_field_name, box_container)
        
        TempBox = uix.HBox( 'Parent', box_container, 'Spacing', DATA.Spacing);
        uicontrol_handle = uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', string_field_name, 'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.(gui_struct).(field_name) = uicontrol( 'Style', 'text', 'Parent', TempBox, 'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
        uix.Empty( 'Parent', TempBox );
        
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
            uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', field_units, 'FontSize', DATA.BigFontSize, 'HorizontalAlignment', 'left');
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
    function set_mammal(index_selected)
        DATA.customConfigFile = [];
        
        if index_selected == length(DATA.mammals) % Custom mammal
            
            [Config_FileName, PathName] = uigetfile({'*.conf','Configuration files (*.conf)'}, 'Open Configuration File', []);
            if ~isequal(Config_FileName, 0)
                params_filename = fullfile(PathName, Config_FileName);
                DATA.customConfigFile = params_filename;
                mammal = 'custom';
            else % Cancel by user
                GUI.GUIRecord.Mammal_popupmenu.Value = DATA.mammal_index;
                throw(MException('set_mammal:text', 'Custom mammal: Cancel by user.'));
                %                 return;
            end
        else
            mammal = DATA.mammals{index_selected};
            DATA.customConfigFile = ['gqrs.' mammal '.conf'];
        end
        
        DATA.mammal_index = index_selected;
        DATA.zoom_rect_limits = [0 DATA.firstZoom];
        right_limit2plot = min(DATA.firstZoom, max(DATA.tm));
        setECGXLim(0, right_limit2plot);
        setECGYLim(0, right_limit2plot);
        
        load_updateGUI_config_param();
        
        if strcmp(mammal, 'dog')
            DATA.peak_search_win = 90;
%             hcf = 125; % Hz
%             rp = 0.170;
        elseif strcmp(mammal, 'rabbit')
            DATA.peak_search_win = 40;
%             hcf = 150; % Hz
%             rp = 0.088;
        elseif strcmp(mammal, 'mouse')
            DATA.peak_search_win = 17;
%             hcf = 300; % Hz
%             rp = 0.030;
        elseif strcmp(mammal, 'human')
            DATA.peak_search_win = 150;
%             hcf = 100; % Hz
%             rp = 0.250;
        else
            DATA.peak_search_win = 100;
%             hcf = 100; % Hz
%             rp = 0.250;
        end
%         lcf = 3; % Hz
%         thr = 0.5;
%         ws = 10; % sec
        set(GUI.GUIConfig.PeaksWindow, 'String', DATA.peak_search_win);
%         set(GUI.GUIConfig_ptqrs.lcf, 'String', lcf);
%         set(GUI.GUIConfig_ptqrs.hcf, 'String', hcf);
%         set(GUI.GUIConfig_ptqrs.thr, 'String', thr);
%         set(GUI.GUIConfig_ptqrs.rp, 'String', rp);
%         set(GUI.GUIConfig_ptqrs.ws, 'String', ws);
    end
%%
    function Mammal_popupmenu_Callback(src, ~)
        
        index_selected = get(src, 'Value');
        if index_selected ~= 1
            try
                set_mammal(index_selected);
            catch
                return; % Canceled by user
            end
            if get(GUI.AutoCalc_checkbox, 'Value')
                try
                    RunAndPlotPeakDetector();
                catch e
                    errordlg(['mammal set error: ' e.message], 'Input Error');
                    src.Value = DATA.mammal_index;
                    return;
                end
            end
        else
            src.Value = DATA.mammal_index;
            return;
        end
    end
%%
    function Integration_popupmenu_Callback(src, ~)
        items = get(src, 'String');
        index_selected = get(src, 'Value');
        DATA.Integration = items{index_selected};
    end
%%
    function PeakDetector_popupmenu_Callback(src, ~)
        if get(GUI.AutoCalc_checkbox, 'Value')
            try
                RunAndPlotPeakDetector();
                DATA.peakDetection_index = src.Value;
            catch e
                errordlg(['PeakDetector error: ' e.message], 'Input Error');                
                return;
            end
        end
    end
%%
    function OpenFile_Callback(~, ~)
        
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
        
        [ECG_FileName, PathName] = uigetfile( ...
            {'*.txt','Text Files (*.txt)'; ...
            '*.dat',  'WFDB Files (*.dat)'; ...
            '*.mat','MAT-files (*.mat)'}, ...
            'Open ECG File', [DIRS.dataDirectory filesep '*.' EXT]); %
        
        if ~isequal(ECG_FileName, 0)
            
            clearData();
            clean_gui();
            %             clearHandles();
            clean_config_param_fields();
            delete_temp_wfdb_files();
            
            %             set(GUI.GUIRecord.RecordFileName_text, 'String', '');
            %             set(GUI.GUIRecord.PeaksFileName_text, 'String', '');
            %             set(GUI.GUIRecord.DataQualityFileName_text, 'String', '');
            %             set(GUI.GUIRecord.TimeSeriesLength_text, 'String', '');
            
            DIRS.dataDirectory = PathName;
            
            [~, DATA.DataFileName, ExtensionFileName] = fileparts(ECG_FileName);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            DATA.rec_name = [PathName, DATA.DataFileName];
            %             if strcmpi(ExtensionFileName, 'dat')
            %                 header_info = wfdb_header(DATA.rec_name);
            %                 DATA.ecg_channel = get_signal_channel(DATA.rec_name, 'header_info', header_info);
            %                 if (isempty(DATA.ecg_channel))
            %                     error('Failed to find an ECG channel in the record %s', DATA.rec_name);
            %                 end
            %
            %                 waitbar_handle = waitbar(1/2, 'Loading data', 'Name', 'Loading data...');
            %
            %                 [DATA.Mammal, DATA.Integration] = get_description_from_wfdb_header(DATA.rec_name);
            %
            %                 % Read Signal
            %                 [DATA.tm, DATA.sig, DATA.Fs] = rdsamp(DATA.rec_name, DATA.ecg_channel, 'header_info', header_info);
            %
            %
            %                 if isvalid(waitbar_handle)
            %                     close(waitbar_handle);
            %                 end
            
            if strcmpi(ExtensionFileName, 'mat') || strcmpi(ExtensionFileName, 'txt') || strcmpi(ExtensionFileName, 'dat')
                                
                try
%                     waitbar_handle = waitbar(1/2, 'Loading data...', 'Name', 'Loading data');
                    Config = ReadYaml('Loader Config.yml');    
                    DataFileMap = loadDataFile([DATA.rec_name '.' EXT]);
%                     if isvalid(waitbar_handle)
%                         close(waitbar_handle);
%                     end
                    MSG = DataFileMap('MSG');
                    if strcmp(Config.alarm.(MSG), 'OK')
                        data = DataFileMap('DATA');
                        if strcmp(data.Data.Type, 'electrography')
                            DATA.Mammal = data.General.mammal;
                            DATA.mammal_index = find(strcmp(DATA.mammals, DATA.Mammal));
                            DATA.Integration = data.General.integration_level;
                            DATA.integration_index = find(strcmp(DATA.Integration_From_Files, DATA.Integration));
                            set(GUI.GUIRecord.Integration_popupmenu, 'Value', DATA.integration_index);
                            DATA.Fs = double(data.Time.Fs);
                            DATA.sig = data.Data.Data;
                            time_data = data.Time.Data;
                            DATA.tm = time_data - time_data(1);
                            
                            [t_max, h, m, s ,ms] = signal_duration(length(DATA.tm), DATA.Fs);
                            header_info = struct('duration', struct('h', h, 'm', m, 's', s, 'ms', ms), 'total_seconds', t_max);

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
                        else                            
                            errordlg(['onOpenFile error: ' 'Please, choose another file type.'], 'Input Error');
                            return;
                        end
                    elseif strcmp(Config.alarm.(MSG), 'Canceled')
                        return;
                    else                        
                        errordlg(['onOpenFile error: ' Config.alarm.(MSG)], 'Input Error');
                        return;
                    end
                catch e
                    errordlg(['onOpenFile error: ' e.message], 'Input Error');
                    return;
                end
                
                %                 ECG = load(DATA.rec_name);
                %                 ECG_field_names = fieldnames(ECG);
                %                 for i = 1 : length(ECG_field_names)
                %                     if ~isempty(regexpi(ECG_field_names{i}, 'ecg')) % |data
                %                         ECG_data = ECG.(ECG_field_names{i});
                %                         if ~isempty(ECG_data)
                %                             header_info = set_data(ECG_data);
                %                         end
                %                     elseif ~isempty(regexpi(ECG_field_names{i}, 'mammal'))
                %                         DATA.Mammal = ECG.(ECG_field_names{i});
                %                         DATA.mammal_index = find(strcmp(DATA.mammals, DATA.Mammal));
                %                     else
                %                         errordlg('Please, choose the file with the ECG data.', 'Input Error');
                %                         return;
                %                     end
                %                 end
                GUI.GUIRecord.Mammal_popupmenu.Value = DATA.mammal_index;
                try
                    set_mammal(DATA.mammal_index);
                catch
                    return; % Canceled by user
                end
                
                %             elseif strcmpi(ExtensionFileName, 'txt')
                
                %                 %               txt_data = dlmread([DATA.rec_name '.' EXT], '\t');
                %
                %                 DataFileMap = loadDataFile([DATA.rec_name '.' EXT]);
                %                 MSG = DataFileMap('MSG');
                %                 if strcmp(MSG, 'OK')
                %                     data = DataFileMap('DATA');
                %                     if strcmp(data.Data.Type, 'electrography')
                %                         DATA.mammal = data.General.mammal;
                %                         DATA.integration = data.General.integration_level;
                %                         DATA.Fs = data.Time.Fs;
                %                         ECG_data = data.Data.Data;
                %                         time_data = data.Time.Data;
                %                     else
                % %                         throw(MException('LoadFile:text', 'Please, choose right file format for this module.'));
                %                         errordlg(['onOpenFile error: ' 'Please, choose right file format for this module.'], 'Input Error');
                %                         return;
                %                     end
                %                 elseif strcmp(MSG, 'Canceled')
                %                     return;
                %                 else
                % %                     throw(MException('LoadFile:text', MSG));
                %                     errordlg(['onOpenFile error: ' MSG], 'Input Error');
                %                     return;
                %                 end
                %
                %
                % %                 if ~isempty(txt_data)
                % %                     header_info = set_data(txt_data);
                %                     header_info = set_data([time_data' ECG_data]);
                % %                 end
            end
            
            
            
            set(GUI.GUIRecord.RecordFileName_text, 'String', ECG_FileName);
            
            %             cla(GUI.ECG_Axes); % RawData_axes
            %             cla(GUI.RRInt_Axes); % RR_axes
            %
            %             DATA.mammal_index = 1;
            %             set(GUI.GUIRecord.Mammal_popupmenu, 'Value', 1);
            
            GUI.RawData_handle = line(DATA.tm, DATA.sig, 'Parent', GUI.ECG_Axes);
            
            PathName = strrep(PathName, '\', '\\');
            PathName = strrep(PathName, '_', '\_');
            ECG_FileName_title = strrep(ECG_FileName, '_', '\_');
            
            TitleName = [PathName ECG_FileName_title] ;
            title(GUI.ECG_Axes, TitleName, 'FontWeight', 'normal', 'FontSize', 11);
            
            right_limit2plot = min(DATA.firstZoom, max(DATA.tm));
            setECGXLim(0, right_limit2plot);
            setECGYLim(0, right_limit2plot);
            
            xlabel(GUI.ECG_Axes, 'Time (sec)');
            ylabel(GUI.ECG_Axes, 'ECG (mV)');
            hold(GUI.ECG_Axes, 'on');
            
            set(GUI.GUIRecord.TimeSeriesLength_text, 'String', [[num2str(header_info.duration.h) ':' num2str(header_info.duration.m) ':' ...
                num2str(header_info.duration.s) '.' num2str(header_info.duration.ms)] '    h:min:sec.msec']);
            
            
             if GUI.AutoCalc_checkbox.Value
                 try
                     RunAndPlotPeakDetector();
                     set(GUI.GUIDisplay.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
                     set(GUI.RRInt_Axes, 'XLim', [0 DATA.maxRRTime]);
                     
                     setAxesXTicks(GUI.RRInt_Axes);
                 catch e
                     errordlg(['OpenFile error: ' e.message], 'Input Error');
                     return;
                 end
             end
             
             
            GUI.LoadConfigurationFile.Enable = 'on';
            GUI.SaveConfigurationFile.Enable = 'on';
            GUI.SavePeaks.Enable = 'on';
            GUI.LoadPeaks.Enable = 'on';
            GUI.SaveDataQuality.Enable = 'on';
            GUI.OpenDataQuality.Enable = 'on';
            
           
            
            
            DATA.zoom_rect_limits = [0 DATA.firstZoom];
            EnablePageUpDown();
            %             GUI.PeaksTable.Data(:, 2) = {0};
        end
    end
%%
    function header_info = set_data(time_data, ECG_data)
        
        DATA.tm = time_data;
        DATA.sig = ECG_data;
        
        if ~DATA.Fs
            DATA.Fs = 1/median(diff(DATA.tm));
        end
        
        [t_max, h, m, s ,ms] = signal_duration(length(DATA.tm), DATA.Fs);
        header_info = struct('duration', struct('h', h, 'm', m, 's', s, 'ms', ms), 'total_seconds', t_max);
        
        DATA.ecg_channel = 1;
        DATA.rec_name = DATA.temp_rec_name4wfdb;                
                
%         waitbar_handle = waitbar(1/2, 'Loading...', 'Name', 'Loading data');
        
        curr_dir = pwd;
        cd(tempdir);

        mat2wfdb(DATA.sig, DATA.rec_name, DATA.Fs, [], ' ' ,{} ,[]);    
    
        cd(curr_dir);
        
%         [a, b, c] = fileparts(mfilename('fullpath'))
%         
%         mfilename('fullpath')
%         
%         disp(['exist(fullfile(pwd, [DATA.rec_name .dat])) = ' num2str(exist(fullfile(pwd, [DATA.rec_name '.dat']), 'file'))]);
%         disp(['exist(fullfile(pwd, [DATA.rec_name .hea])) = ' num2str(exist(fullfile(pwd, [DATA.rec_name '.hea']), 'file'))]);
        
%         curr_path_dat = which([pwd filesep DATA.rec_name '.dat'])
%         curr_path_hea = which([pwd filesep DATA.rec_name '.hea'])
        
        if ~exist(fullfile(tempdir, [DATA.rec_name '.dat']), 'file') && ~exist(fullfile(tempdir, [DATA.rec_name '.hea']), 'file')
            throw(MException('set_data:text', 'Wfdb file cannot be created.'));
        end
        
        
        
                
        
%         if exist([DATA.rec_name '.dat'], 'file') && exist([DATA.rec_name '.hea'], 'file')
% %             [DATA.tm, DATA.sig, DATA.Fs] = rdsamp(DATA.rec_name, DATA.ecg_channel);
%             [DATA.tm, DATA.sig, ~] = rdsamp(DATA.rec_name, DATA.ecg_channel);
%         end
%         if isvalid(waitbar_handle)
%              close(waitbar_handle); 
%         end
    end
%%
    function setECGXLim(minLimit, maxLimit)
        
        %         setECGYLim(minLimit, maxLimit);
        set(GUI.ECG_Axes, 'XLim', [minLimit maxLimit]);
        
        setAxesXTicks(GUI.ECG_Axes);
    end
%%
    function setECGYLim(minLimit, maxLimit)
        sig = DATA.sig(DATA.tm >= minLimit & DATA.tm <= maxLimit);
        
        min_sig = min(sig);
        max_sig = max(sig);
        delta = (max_sig - min_sig)*0.1;
        
        min_y_lim = min(min_sig, max_sig) - delta;
        max_y_lim = max(min_sig, max_sig) + delta;
        
        set(GUI.ECG_Axes, 'YLim', [min_y_lim max_y_lim]);
        
        set(GUI.GUIDisplay.MinYLimit_Edit, 'String', num2str(min_y_lim));
        set(GUI.GUIDisplay.MaxYLimit_Edit, 'String', num2str(max_y_lim));
    end
%%
    function setRRIntYLim()
        
        xlim = get(GUI.RRInt_Axes, 'XLim');
        xdata = get(GUI.RRInt_handle, 'XData');
        ydata = get(GUI.RRInt_handle, 'YData');
        
        current_y_data = ydata(xdata >= xlim(1) & xdata <= xlim(2));
        
        min_sig = min(current_y_data);
        max_sig = max(current_y_data);
        delta = (max_sig - min_sig)*0.1;
        
        min_y_lim = min(min_sig, max_sig) - delta;
        max_y_lim = max(min_sig, max_sig) + delta;
        
        set(GUI.RRInt_Axes, 'YLim', [min_y_lim max_y_lim]);
        
        set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'String', num2str(min_y_lim));
        set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'String', num2str(max_y_lim));
        
        set(GUI.red_rect_handle, 'YData', [min_y_lim min_y_lim max_y_lim max_y_lim min_y_lim]);
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
        DATA.config_map = parse_gqrs_config_file(DATA.customConfigFile);
        
        params_GUI_edit_values = findobj(GUI.ConfigBox, 'Style', 'edit');
        fields_names = get(params_GUI_edit_values, 'UserData');
        
        for i = 1 : length(params_GUI_edit_values)
            if ~isempty(fields_names{i})
                param_value = DATA.config_map(fields_names{i});
                set(params_GUI_edit_values(i), 'String', param_value);
            end
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
                    
                    waitbar_handle = waitbar(1/2, 'Loading configuration...', 'Name', 'Loading data');
                    
                    load_updateGUI_config_param();
                    
                    if isvalid(waitbar_handle)
                        close(waitbar_handle);
                    end
                    
                    %                 curr_path_dat = which([pwd filesep DATA.rec_name '.dat']);
                    %                 curr_path_hea = which([pwd filesep DATA.rec_name '.hea']);
                    
                    %                 if ~isempty(curr_path_dat) && ~isempty(curr_path_hea)
                                        
                    pd_items = get(GUI.GUIRecord.PeakDetector_popupmenu, 'String');
                    pd_index_selected = get(GUI.GUIRecord.PeakDetector_popupmenu, 'Value');
                    
                    peak_detector = pd_items{pd_index_selected};
                    
                    waitbar_handle = waitbar(1/2, 'Compute peaks...', 'Name', 'Computing');
                    
                    if ~strcmpi(peak_detector, 'rgrs')
                        
                        lcf = str2double(DATA.config_map('lcf'));
                        hcf = str2double(DATA.config_map('hcf'));
                        thr = str2double(DATA.config_map('thr'));
                        rp = str2double(DATA.config_map('rp'));
                        ws = str2double(DATA.config_map('ws'));
                        
                        bpecg = prefilter2(DATA.sig, DATA.Fs, lcf, hcf, 0);  % bpecg = prefilter2(ecg,fs,lcf,hcf,0);
                    end
                    
                    if strcmp(peak_detector, 'ptqrs')
                        qrs_pos = ptqrs(bpecg, DATA.Fs, thr, rp, 0); % qrs_pos = ptqrs(bpecg,fs,thr,rp,0);
                        DATA.qrs = qrs_pos';
                    elseif strcmp(peak_detector, 'wptqrs')
                        qrs_pos = run_qrsdet_by_seg(bpecg, DATA.Fs, thr, rp, ws);
                        DATA.qrs = qrs_pos';
                    else
                        
                        %                     if exist(fullfile([tempdir DATA.rec_name '.dat']), 'file') && exist(fullfile([tempdir DATA.rec_name '.hea']), 'file')
                        
                        
                        if exist(fullfile([DATA.wfdb_record_name '.dat']), 'file') && exist(fullfile([DATA.wfdb_record_name '.hea']), 'file')
                            
                            
                            %                         [DATA.qrs, tm, sig, Fs] = rqrs([tempdir DATA.rec_name], 'gqconf', DATA.customConfigFile, 'ecg_channel', DATA.ecg_channel, 'plot', false);
                            [DATA.qrs, tm, sig, Fs] = rqrs(DATA.wfdb_record_name, 'gqconf', DATA.customConfigFile, 'ecg_channel', DATA.ecg_channel, 'plot', false);
                            
                            %                         if isvalid(waitbar_handle)
                            %                             close(waitbar_handle);
                            %                         end
                        else
                            throw(MException('calc_peaks:text', 'Problems with peaks calculation. Wfdb file not exists.'));
                        end
                    end
                    
                    if isvalid(waitbar_handle)
                        close(waitbar_handle);
                    end
                    
                    if length(DATA.qrs) == 1
                        throw(MException('peaks_detection_algorithm:text', 'Not enough peaks!'));
                    end
                    
                    if ~isempty(DATA.qrs)
                        DATA.qrs = double(DATA.qrs);
                        GUI.red_peaks_handle = line(DATA.tm(DATA.qrs), DATA.sig(DATA.qrs, 1), 'Parent', GUI.ECG_Axes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'LineWidth', 2);
                        uistack(GUI.red_peaks_handle, 'top');  % bottom
                        
                        plot_rr_data();
                        plot_red_rectangle(DATA.zoom_rect_limits);
                        GUI.PeaksTable.Data(:, 2) = {0};
                        DATA.peaks_added = 0;
                        DATA.peaks_deleted = 0;
                        DATA.peaks_total = length(DATA.qrs);
                        GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
                        
                        set(GUI.GUIDisplay.FirstSecond, 'String', calcDuration(min(DATA.zoom_rect_limits), 0));
                        set(GUI.GUIDisplay.WindowSize, 'String', calcDuration(max(DATA.zoom_rect_limits) - min(DATA.zoom_rect_limits), 0));
                    else
                        errordlg('The algorithm could not run. Please, check input parameters.', 'Input Error');
                    end
                end
            catch e
                if isvalid(waitbar_handle)
                    close(waitbar_handle);
                end
                rethrow(e);
            end
            set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
            set(GUI.Window, 'WindowButtonUpFcn', @my_WindowButtonUpFcn);
            set(GUI.Window, 'WindowButtonDownFcn', @my_WindowButtonDownFcn);
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
            
            qrs = DATA.qrs(~isnan(DATA.qrs));
            
            rr_time = qrs(1:end-1)/DATA.Fs;
            rr_data = diff(qrs)/DATA.Fs;
            
            if (DATA.PlotHR == 1)
                rr_data = 60 ./ rr_data;
                yString = 'HR (BPM)';
            else
                yString = 'RR (sec)';
            end
            if ~isempty(rr_data)
                GUI.RRInt_handle = line(rr_time, rr_data, 'Parent', GUI.RRInt_Axes);
                
                DATA.maxRRTime = max(rr_time);
                DATA.RRIntPage_Length = DATA.maxRRTime;
                               
                min_sig = min(rr_data);
                max_sig = max(rr_data);
                delta = (max_sig - min_sig)*0.1;
                
                RRMinYLimit = min(min_sig, max_sig) - delta;
                RRMaxYLimit = max(min_sig, max_sig) + delta;
                
                set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'String', num2str(RRMinYLimit));
                set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'String', num2str(RRMaxYLimit));
                
                set(GUI.RRInt_Axes, 'YLim', [RRMinYLimit RRMaxYLimit]);
                
                ylabel(GUI.RRInt_Axes, yString);
            else
%                 errordlg('plot_rr_data: Not enough peaks!', 'Input Error');
                throw(MException('plot_rr_data:text', 'Not enough peaks!'));
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
        
        [Config_FileName, PathName] = uigetfile({'*.conf','Conf files (*.conf)'}, 'Open Configuration File', [DIRS.analyzedDataDirectory filesep 'gqrs.custom.conf']);
        if ~isequal(Config_FileName, 0)
            mammal_index = length(DATA.mammals);
            DATA.customConfigFile = fullfile(PathName, Config_FileName);
            load_updateGUI_config_param();
            if get(GUI.AutoCalc_checkbox, 'Value')
                try
                    RunAndPlotPeakDetector();
                catch e
                    errordlg(['LoadConfigurationFile error: ' e.message], 'Input Error');
                    return;
                end
            end
            GUI.GUIRecord.Mammal_popupmenu.Value = mammal_index;
            DATA.mammal_index = mammal_index;
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
        
        [filename, results_folder_name, ~] = uiputfile({'*.','Conf Files (*.conf)'},'Choose Config File Name', [DIRS.analyzedDataDirectory filesep 'gqrs.custom.conf']);
        
        if ~isequal(results_folder_name, 0)
            full_file_name_conf = fullfile(results_folder_name, filename);
            button = 'Yes';
            if exist(full_file_name_conf, 'file')
                button = questdlg([full_file_name_conf ' already exist. Do you want to overwrite it?'], 'Overwrite existing file?', 'Yes', 'No', 'No');
            end
            if strcmp(button, 'Yes')
                saveCustomParameters(full_file_name_conf);
            end
        end
    end
%%
    function temp_custom_conf_fileID = saveCustomParameters(FullFileName)
        
        if isfield(DATA, 'config_map')
            
            config_param_names = keys(DATA.config_map);
            config_param_values = values(DATA.config_map);
            
            temp_custom_conf_fileID = fopen(FullFileName, 'w');
            if temp_custom_conf_fileID ~= -1
                fprintf(temp_custom_conf_fileID, '# gqrs temp config file for custom parameters:\r\n');
                for i = 1 : length(DATA.config_map)
                    fprintf(temp_custom_conf_fileID, '%s\t%s\r\n', config_param_names{i}, config_param_values{i});
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
                    parameters_cell = strsplit(tline);
                    if ~isempty(parameters_cell{1})
                        config_map(parameters_cell{1}) = parameters_cell{2};
                    end
                end
            end
            fclose(f_h);
        end
    end
%%
    function config_edit_Callback(src, ~)
        
        field_value = get(src, 'String');        
        numeric_field_value = str2double(field_value);
        
        if isnan(numeric_field_value)
            errordlg('Please, enter numeric value.', 'Input Error');
            set(src, 'String', DATA.config_map(get(src, 'UserData')));
            return;
        elseif strcmp(get(src, 'UserData'), 'rp') && ~(numeric_field_value >= 0)
            errordlg('The refractory period must be greater or equal to 0.', 'Input Error');
            set(src, 'String', DATA.config_map(get(src, 'UserData')));
            return;
        elseif (numeric_field_value <= 0) && ~(strcmp(get(src, 'UserData'), 'rp'))
            errordlg('The value must be greater then 0.', 'Input Error');
            set(src, 'String', DATA.config_map(get(src, 'UserData')));
            return;
        end        
        if strcmp(get(src, 'UserData'), 'hcf') && (numeric_field_value > DATA.Fs/2)
            errordlg('The upper cutoff frequency must be inferior to half of the sampling frequency.', 'Input Error');
            set(src, 'String', DATA.config_map(get(src, 'UserData')));
            return;
        end
        
        if isfield(DATA, 'config_map') && ~isempty(DATA.config_map)
            DATA.config_map(get(src, 'UserData')) = get(src, 'String');
            DATA.customConfigFile = [tempdir 'gqrs.temp_custom.conf'];
            temp_custom_conf_fileID = saveCustomParameters(DATA.customConfigFile);
            if temp_custom_conf_fileID == -1
                errordlg('Problems with creation of custom config file.', 'Input Error');
                return;
            end
            if get(GUI.AutoCalc_checkbox, 'Value')
                try
                    RunAndPlotPeakDetector();
                catch e
                    errordlg(['config_edit_Callback error: ' e.message], 'Input Error');
                    return;
                end
            end
        end
    end
%%
%     function ptqrs_config_edit_Callback(src, ~)
%         field_value = get(src, 'String');
%         if ~strcmp(field_value, '')
%             if get(GUI.AutoCalc_checkbox, 'Value')
%                 try
%                     RunAndPlotPeakDetector();
%                 catch e
%                     errordlg(['config_edit_Callback error: ' e.message], 'Input Error');
%                     return;
%                 end
%             end
%         end
%     end
%%
    function Peaks_Window_edit_Callback(src, ~)
        field_value = str2double(get(src, 'String'));
        if field_value > 0 && field_value < 1000
            DATA.peak_search_win = field_value;
        else
            set(src, 'String', num2str(DATA.peak_search_win));
            errordlg('The window length for peak detection must be greater than 0 and less than 1 sec.', 'Input Error');
        end
    end
%%
%     function CalcWithNewValues_pushbutton_Callback(~, ~)
%
%         Config_FileName = 'gqrs.temp_custom.conf';
%
%         if isfield(DATA, 'config_map')
%             temp_custom_conf_fileID = saveCustomParameters(Config_FileName);
%             if temp_custom_conf_fileID ~= -1
%                 RunAndPlotPeakDetector(length(DATA.mammals), fullfile(pwd, Config_FileName));
%                 delete(Config_FileName);
%             end
%         end
%     end
%%
    function delete_temp_wfdb_files()
        if exist([tempdir DATA.temp_rec_name4wfdb '.hea'], 'file')
            delete([tempdir DATA.temp_rec_name4wfdb '.hea']);
%             disp('Deleting .hea');
        end
        if exist([tempdir DATA.temp_rec_name4wfdb '.dat'], 'file')
            delete([tempdir DATA.temp_rec_name4wfdb '.dat']);
%             disp('Deleting .dat');
        end
        if exist([tempdir 'tempYAML.yml'], 'file')
            delete([tempdir 'tempYAML.yml']);
%             disp('Deleting .yml');
        end
    end
%%
    function LoadPeaks_Callback(~, ~)
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
        [Peaks_FileName, PathName] = uigetfile( ...
            {'*.txt','Text Files (*.txt)'; ...
            '*.qrs; *.atr',  'WFDB Files (*.qrs; *.atr)'; ...
            '*.mat','MAT-files (*.mat)'}, ...
            'Open ECG File', [DIRS.analyzedDataDirectory filesep '*.' EXT]); %
        
        if ~isequal(Peaks_FileName, 0)
            
            [~, PeaksFileName, ExtensionFileName] = fileparts(Peaks_FileName);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            DIRS.analyzedDataDirectory = PathName;
            
            DATA.peaks_file_name = [PathName, PeaksFileName];
            cla(GUI.RRInt_Axes);
            
            set(GUI.GUIRecord.PeaksFileName_text, 'String', Peaks_FileName);
            
            if strcmpi(ExtensionFileName, 'mat') || strcmpi(ExtensionFileName, 'txt') || strcmpi(ExtensionFileName, 'qrs') || strcmpi(ExtensionFileName, 'atr')
                %                 QRS = load(DATA.peaks_file_name);
                %                 DATA.qrs = QRS.Data;
                %                 DATA.Fs = QRS.Fs;
                %                 DATA.Mammal = QRS.Mammal;
                %                 DATA.Integration = QRS.Integration_level;
                
                
                try
                    Config = ReadYaml('Loader Config.yml');
                    
                    DataFileMap = loadDataFile([DATA.peaks_file_name '.' EXT]);
                    MSG = DataFileMap('MSG');
                    if strcmp(Config.alarm.(MSG), 'OK')
                        data = DataFileMap('DATA');
                        if ~strcmp(data.Data.Type, 'electrography')
                            Mammal = data.General.mammal;
                            integration = data.General.integration_level;
                            DATA.Fs = data.Time.Fs;
                            %                         DATA.qrs = data.Data.Data;
                            time_data = data.Time.Data;
                            DATA.qrs = int64(time_data * DATA.Fs);
                            if ~strcmp(Mammal, DATA.Mammal) || ~strcmp(integration, DATA.Integration)
                                errordlg(['on Load Peaks error: ' 'Please, choose same mammal and integration level.'], 'Input Error');
                                return;
                            end
                        else
                            errordlg(['on Load Peaks error: ' 'Please, choose another file type.'], 'Input Error');
                            return;
                        end
                    elseif strcmp(Config.alarm.(MSG), 'Canceled')
                        return;
                    else
                        errordlg(['on Load Peaks error: ' Config.alarm.(MSG)], 'Input Error');
                        return;
                    end
                    
                catch e
                    errordlg(['onOpenFile error: ' e.message], 'Input Error');
                    return;
                end
                
                
                
                %             elseif strcmpi(ExtensionFileName, 'txt')
                %
                %                 DataFileMap = loadDataFile(DATA.peaks_file_name);
                %                 MSG = DataFileMap('MSG');
                %                 if strcmp(MSG, 'OK')
                %                     data = DataFileMap('DATA');
                %                     if strcmp(data.General.file_type, 'beating_rate')
                %
                %                         DATA.Mammal = data.General.mammal;
                %                         DATA.Integration = data.General.integration_level;
                %
                %                         DATA.qrs = data.Data.Data;
                %                     else
                %                         errordlg(['on Load Peaks error: ' 'Please, choose right file format for this module.'], 'Input Error');
                %                         return;
                %                     end
                %                 else
                %                     errordlg(['on Load Peaks error: ' MSG], 'Input Error');
                %                     return;
                %                 end
                
                %             elseif strcmpi(ExtensionFileName, 'qrs') % || strcmpi(ExtensionFileName, 'atr')
                %                 DATA.qrs = rdann(DATA.peaks_file_name, EXT);
            else
                errordlg(['on Load Peaks error: ' 'Please, choose another file type.'], 'Input Error');
                return;
            end
            
            DATA.peaks_total = length(DATA.qrs);
            DATA.peaks_added = 0;
            DATA.peaks_deleted = 0;
            GUI.PeaksTable.Data(:, 2) = {0};
            GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
            
            DATA.mammal_index = find(strcmp(DATA.mammals, DATA.Mammal));
            set_mammal(DATA.mammal_index);
            GUI.GUIRecord.Mammal_popupmenu.Value = DATA.mammal_index;
            
            %                 DATA.integration_index = find(strcmp(DATA.GUI_Integration, DATA.Integration));
            
            
            %                 DATA.integration_index = find(strcmp(DATA.Integration_From_Files, DATA.Integration));
            %                 set(GUI.GUIRecord.Integration_popupmenu, 'Value', DATA.integration_index);
            
            if ~isempty(DATA.qrs)
                if isfield(GUI, 'red_peaks_handle') && ishandle(GUI.red_peaks_handle) && isvalid(GUI.red_peaks_handle)
                    delete(GUI.red_peaks_handle);
                end
                DATA.qrs = double(DATA.qrs);
                GUI.red_peaks_handle = line(DATA.tm(DATA.qrs), DATA.sig(DATA.qrs, 1), 'Parent', GUI.ECG_Axes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'LineWidth', 2);
                uistack(GUI.red_peaks_handle, 'bottom');
                
                if isfield(GUI, 'RRInt_handle') && ishandle(GUI.RRInt_handle) && isvalid(GUI.RRInt_handle)
                    delete(GUI.RRInt_handle);
                end
                plot_rr_data();
                
                if isfield(GUI, 'red_rect_handle') && ishandle(GUI.red_rect_handle) && isvalid(GUI.red_rect_handle)
                    delete(GUI.red_rect_handle);
                end
                
                plot_red_rectangle(DATA.zoom_rect_limits);
                
                set(GUI.RRInt_Axes, 'XLim', [0 DATA.maxRRTime]);
                setAxesXTicks(GUI.RRInt_Axes);
                setRRIntYLim();
                
                set(GUI.GUIDisplay.FirstSecond, 'String', calcDuration(min(DATA.zoom_rect_limits), 0));
                set(GUI.GUIDisplay.WindowSize, 'String', calcDuration(max(DATA.zoom_rect_limits)-min(DATA.zoom_rect_limits), 0));
                
                set(GUI.GUIDisplay.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
                
                set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
                set(GUI.Window, 'WindowButtonUpFcn', @my_WindowButtonUpFcn);
                set(GUI.Window, 'WindowButtonDownFcn', @my_WindowButtonDownFcn);
            else
                errordlg('The algorithm could not run. Please, check input parameters.', 'Input Error');
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
            '*.mat','MAT-files (*.mat)'},...
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
            Integration_level = DATA.Integration;
            Mammal = DATA.mammals{DATA.mammal_index};
            %             File_type = 'beating rate';
            
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
                
                %                 fprintf(header_fileID, 'File_type:         %s\n', File_type);
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
%             elseif strcmpi(ExtensionFileName, 'qrs') || strcmpi(ExtensionFileName, 'atr')
%                 [~, filename_noExt, ~] = fileparts(filename);
%                 %                 saved_path = pwd;
%                 %                 cd(results_folder_name);
%                 try
%                     %                                         wfdb_path = 'D:\Temp\wfdb-app-toolbox-0-9-10\mcode';
%                     %                                         addpath(wfdb_path);
%                     %                                         mat2wfdb(Data, filename_noExt, Fs, [], ' ', {}, [], {strcat(Integration_level, '-', Mammal)});
%                     %                                         wrann(filename_noExt, 'qrs', int64(Data));
%                     %                                         rmpath(wfdb_path);
%                     %                                         delete([filename_noExt '.dat']);
%                     
% %                     if ~isrecord([results_folder_name filename_noExt], 'hea')
% %                         % Create header
% %                         saved_path = pwd;
% %                         cd(results_folder_name);
% %                         mat2wfdb(Data, filename_noExt, Fs, [], ' ', {}, [], {strcat(Integration_level, '-', Mammal)});
% %                         delete([filename_noExt '.dat']);
% %                         cd(saved_path);
% %                     end
%                     
%                     comments = {['Mammal:' Mammal ',Integration_level:' Integration_level]};
%                     
%                     %                     wrann([results_folder_name filename_noExt], 'qrs', int64(Data), 'fs', Fs, 'comments', [DATA.Integration '-' DATA.Mammal]);
%                     
%                     wrann([results_folder_name filename_noExt], ExtensionFileName, int64(Data), 'fs', Fs, 'comments', comments); % , 'comments', {[DATA.Integration '-' DATA.Mammal]}
%                     
%                 catch e
%                     disp(e);
%                 end
%                                 cd(saved_path);
            else
                errordlg('Please, choose only *.mat or *.txt file .', 'Input Error');
                return;
            end
        end
    end
%%
    function AutoCompute_pushbutton_Callback( ~, ~ )
        try
            RunAndPlotPeakDetector();
        catch e
            errordlg(['AutoCompute_pushbutton_Callback error: ' e.message], 'Input Error');
            return;
        end
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
    function RR_or_HR_plot_button_Callback(~, ~)
        
        if isfield(DATA, 'sig') && ~isempty(DATA.sig)
            cla(GUI.RRInt_Axes); % RR_axes
            if(DATA.PlotHR == 1)
                set(GUI.RR_or_HR_plot_button, 'String', 'Plot HR');
                DATA.PlotHR = 0;
            else
                set(GUI.RR_or_HR_plot_button, 'String', 'Plot RR');
                DATA.PlotHR = 1;
            end
            plot_rr_data();
            plot_red_rectangle(DATA.zoom_rect_limits);
            
            setRRIntYLim();
        end
    end
%%
    function Reset_pushbutton_Callback(~, ~)
        
        if isfield(DATA, 'sig') && ~isempty(DATA.sig)
            
            if isfield(GUI, 'quality_win')
                %                 for i = 1 : length(GUI.quality_win)
                %                     try
                %                         delete(GUI.quality_win(i));
                %                         GUI.quality_win(i) = [];
                %                     catch e
                %                         i
                %                         disp(e);
                %                     end
                %                 end
                delete(GUI.quality_win);
                GUI.quality_win = [];
                DATA.quality_win_num = 0;
                DATA.peaks_total = 0;
                DATA.peaks_bad_quality = 0;
            end
            
            GUI.AutoCalc_checkbox.Value = 1;
            GUI.RR_or_HR_plot_button.String = 'Plot HR';
            DATA.PlotHR = 0;
            DATA.quality_win_num = 0;
            
            GUI.GUIRecord.Annotation_popupmenu.Value = 1;
            GUI.GUIRecord.Class_popupmenu.Visible = 'off';
            GUI.Class_Text.Visible = 'off';
            GUI.GUIRecord.Class_popupmenu.Value = 1;
            GUI.GUIRecord.PeakDetector_popupmenu.Value = 1;
            DATA.peakDetection_index = 1;
            
            if isempty(DATA.Mammal)
                mammal_index = 1; % ?????
            else
                mammal_index = find(strcmp(DATA.mammals, DATA.Mammal));
            end
            DATA.mammal_index = mammal_index;
            set_mammal(mammal_index);
            GUI.GUIRecord.Mammal_popupmenu.Value = mammal_index;
            
            try
                RunAndPlotPeakDetector();
            catch e
                errordlg(['AutoCompute_pushbutton_Callback error: ' e.message], 'Input Error');
                return;
            end
            set(GUI.GUIDisplay.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
            set(GUI.RRInt_Axes, 'XLim', [0 DATA.maxRRTime]);
            setAxesXTicks(GUI.RRInt_Axes);
            EnablePageUpDown();
        end
    end
%%
    function redraw_quality_rect()
        
        ylim = get(GUI.ECG_Axes, 'YLim');
        %         f = [1 2 3 4];
        
        if isfield(GUI, 'quality_win')
            for i = 1 : DATA.quality_win_num
                %                 try
                set(GUI.quality_win(i), 'YData', [min(ylim) min(ylim) max(ylim) max(ylim)]);
                %                 catch
                %                 end
                
                %                 quality_range{i} = get(GUI.quality_win(i), 'XData');
                %                 FaceColor{i} = get(GUI.quality_win(i), 'FaceColor');
                %
                %                 delete(GUI.quality_win(i));
                %
                %                 v = [min(quality_range{i}) min(ylim); max(quality_range{i}) min(ylim); max(quality_range{i}) max(ylim); min(quality_range{i}) max(ylim)];
                %
                %                 GUI.quality_win(i) = patch('Faces', f, 'Vertices', v, 'FaceColor', FaceColor{i}, 'EdgeColor', FaceColor{i}, 'LineWidth', 1, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.3, 'Parent', GUI.ECG_Axes);
                %                 uistack(GUI.quality_win(i), 'down');
            end
            %             DATA.quality_win_num = 0;
        end
    end
%%
    function plot_quality_rect(quality_range, quality_win_num, quality_class)
        %         quality_class = GUI.GUIRecord.Class_popupmenu.Value;
        
        ylim = get(GUI.ECG_Axes, 'YLim');
        
        v = [min(quality_range) min(ylim); max(quality_range) min(ylim); max(quality_range) max(ylim); min(quality_range) max(ylim)];
        f = [1 2 3 4];
        
        %         DATA.quality_win_num = DATA.quality_win_num + 1;
        GUI.quality_win(quality_win_num) = patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.quality_color{quality_class}, 'EdgeColor', DATA.quality_color{quality_class}, ...
            'LineWidth', 1, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.3, 'UserData', quality_class, 'Parent', GUI.ECG_Axes);
        
        uistack(GUI.quality_win(quality_win_num), 'down');
        
    end
%%
    function my_WindowButtonUpFcn (src, callbackdata, handles)
        set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
        refresh(GUI.Window);
        switch DATA.hObject
            case 'del_win_peaks'
                Del_win(get(GUI.del_rect_handle, 'XData'));
                try
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
                        quality_class = GUI.GUIRecord.Class_popupmenu.Value;
                        plot_quality_rect(quality_range, DATA.quality_win_num, quality_class);
                    end
                    set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
                catch
                end
            otherwise
        end
    end
%%
    function my_WindowButtonMotionFcn(src, callbackdata, type)
        switch type
            case 'init'
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
                            DATA.hObject = 'overall';
                        end
                    end
                else
                    setptr(GUI.Window, 'arrow');
                    DATA.hObject = 'overall';
                end
            case 'window_move'
                Window_Move('normal');
            case 'drag_del_rect'
                draw_rect_to_del_peaks(GUI.del_rect_handle);
            case 'right_resize_move'
                LR_Resize('right');
            case 'left_resize_move'
                LR_Resize('left');
            case 'drag_quality_rect'
                draw_rect_to_del_peaks(GUI.quality_rect_handle);
            otherwise
        end
    end
%%
    function my_WindowButtonDownFcn(src, callbackdata, handles)
        
        prev_point = get(GUI.RRInt_Axes, 'CurrentPoint');
        DATA.prev_point = prev_point;
        curr_point = get(GUI.ECG_Axes, 'CurrentPoint');
        DATA.prev_point_ecg = curr_point;
        switch DATA.hObject
            case 'add_del_peak'
                Remove_Peak();
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
                    end
                end
            case 'select_quality_win'
                GUI.quality_rect_handle = line(curr_point(1, 1), curr_point(1, 2), 'Color', 'r', 'Linewidth', 1.5, 'LineStyle', ':', 'Parent', GUI.ECG_Axes);
                set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'drag_quality_rect'});
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
                        Window_Move('open'); % double-click: show all data
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
        EnablePageUpDown();
        redraw_quality_rect();
        %         GUI.GUIDisplay.FirstSecond.String = calcDuration(xdata(1), 0);
        %         GUI.GUIDisplay.WindowSize.String = calcDuration(xdata(2) - xdata(1), 0);
        
    end
%%
    function Window_Move(type)
        
        xdata = get(GUI.red_rect_handle, 'XData');
        xdata_saved = xdata;
        point1 = get(GUI.RRInt_Axes, 'CurrentPoint');
        xofs = point1(1,1) - DATA.prev_point(1, 1);
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
                %                 xdata([1, 4, 5]) = 0;
                %                 xdata([2, 3]) = DATA.maxRRTime;
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
        
        %         linkaxes([GUI.ECG_Axes, GUI.RRInt_Axes], 'off');
        
        
        %         set(GUI.ECG_Axes, 'XLim', [xdata(1) xdata(2)]);
        
        setECGXLim(xdata(1), xdata(2));
        setECGYLim(xdata(1), xdata(2));
        
        GUI.GUIDisplay.FirstSecond.String = calcDuration(xdata(1), 0);
        GUI.GUIDisplay.WindowSize.String = calcDuration(xdata(2) - xdata(1), 0);
        
        %         linkaxes([GUI.ECG_Axes, GUI.RRInt_Axes], 'on');
        
        %         if abs(DATA.maxSignalLength - DATA.MyWindowSize ) <=  1 %0.0005
        %             set(GUI.RawDataSlider, 'Enable', 'off');
        %             set(GUI.FirstSecond, 'Enable', 'off');
        %         else
        %             set(GUI.RawDataSlider, 'Enable', 'on');
        %             set(GUI.FirstSecond, 'Enable', 'on');
        %             setSliderProperties(GUI.RawDataSlider, DATA.maxSignalLength, DATA.MyWindowSize, DATA.MyWindowSize/DATA.maxSignalLength);
        %
        %             if DATA.firstSecond2Show > get(GUI.RawDataSlider, 'Max')
        %                 set(GUI.RawDataSlider, 'Value', get(GUI.RawDataSlider, 'Max'));
        %             else
        %                 set(GUI.RawDataSlider, 'Value', DATA.firstSecond2Show);
        %             end
        %         end
        %         setXAxesLim();
        %         setAutoYAxisLim(DATA.firstSecond2Show, DATA.MyWindowSize);
        %         setYAxesLim();
        %         plotDataQuality();
        %         plotMultipleWindows();
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
        
        red_peaks_x_data = GUI.red_peaks_handle.XData;
        
        x_min = max(0, my_point - peak_search_win_sec);
        x_max = min(max(DATA.tm), my_point + peak_search_win_sec);
        
        peak_ind = find(red_peaks_x_data >= x_min & red_peaks_x_data <= x_max);
        
        if isempty(peak_ind)
            
            if get(GUI.AutoPeakWin_checkbox, 'Value')
                [new_peak, ind_new_peak] = max(DATA.sig((DATA.tm>=x_min & DATA.tm<=x_max)));
                time_area = DATA.tm((DATA.tm>=x_min & DATA.tm<=x_max));
                time_new_peak = time_area(ind_new_peak);
            else
                time_new_peak = nearest_point_time;
                new_peak = nearest_point_value;
            end
            temp_XData = [GUI.red_peaks_handle.XData, time_new_peak];
            temp_YData = [GUI.red_peaks_handle.YData, new_peak];
            
            [temp_XData, ind_sort] = sort(temp_XData);
            temp_YData = temp_YData(ind_sort);
            
            global_ind = find(DATA.tm == time_new_peak);
            
            DATA.qrs = sort([DATA.qrs', global_ind])';
            
            DATA.peaks_added = DATA.peaks_added + length(global_ind);
            GUI.PeaksTable.Data(2, 2) = {DATA.peaks_added};
            
            DATA.peaks_total = DATA.peaks_total + length(global_ind);
            GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
            
            set(GUI.red_peaks_handle, 'XData', temp_XData, 'YData', temp_YData);
            
        else
            GUI.red_peaks_handle.XData(peak_ind) = [];
            GUI.red_peaks_handle.YData(peak_ind) = [];
            DATA.qrs(peak_ind) = [];
            %             DATA.qrs(peak_ind) = NaN;
            DATA.peaks_deleted = DATA.peaks_deleted + length(peak_ind);
            GUI.PeaksTable.Data(3, 2) = {DATA.peaks_deleted};
            
            DATA.peaks_total = DATA.peaks_total - length(peak_ind);
            GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
            
        end
        cla(GUI.RRInt_Axes);
        plot_rr_data();
        plot_red_rectangle(DATA.zoom_rect_limits);
        setRRIntYLim();
    end
%%
    function Del_win(range2del)
        xlim = get(GUI.ECG_Axes, 'XLim');
        
        if min(range2del) >= xlim(1) || max(range2del) <= xlim(2)
            red_peaks_x_data = GUI.red_peaks_handle.XData;
            peak_ind = find(red_peaks_x_data >= min(range2del) & red_peaks_x_data <= max(range2del));
            GUI.red_peaks_handle.XData(peak_ind) = [];
            GUI.red_peaks_handle.YData(peak_ind) = [];
            DATA.qrs(peak_ind) = [];
            %             DATA.qrs(peak_ind) = NaN;
            DATA.peaks_deleted = DATA.peaks_deleted + length(peak_ind);
            GUI.PeaksTable.Data(3, 2) = {DATA.peaks_deleted};
            
            DATA.peaks_total = DATA.peaks_total - length(peak_ind);
            GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
            
            cla(GUI.RRInt_Axes);
            plot_rr_data();
            plot_red_rectangle(DATA.zoom_rect_limits);
            
            setRRIntYLim();
        else
            disp('Not in range!');
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
    function RRIntPage_Length_Callback(~, ~)
        RRIntPage_Length = get(GUI.GUIDisplay.RRIntPage_Length, 'String');
        [RRIntPage_Length, isInputNumeric] = calcDurationInSeconds(GUI.GUIDisplay.RRIntPage_Length, RRIntPage_Length, DATA.RRIntPage_Length);
        red_rect_xdata = get(GUI.red_rect_handle, 'XData');
        min_red_rect_xdata = min(red_rect_xdata);
        max_red_rect_xdata = max(red_rect_xdata);
        red_rect_length = max_red_rect_xdata - min_red_rect_xdata;
        if isInputNumeric
            if RRIntPage_Length <= 1 || RRIntPage_Length > DATA.maxRRTime
                set(GUI.GUIDisplay.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
                errordlg('The window size must be greater than 2 sec and less than signal length!', 'Input Error');
                return;
            elseif RRIntPage_Length < red_rect_length
                set(GUI.GUIDisplay.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
                errordlg('The window size must be greater than zoom window length!', 'Input Error');
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
            %             setAutoYAxisLimLowAxes(get(GUI.RRInt_Axes, 'XLim'));
            %             DATA.YLimLowAxes = setYAxesLim(GUI.RRInt_Axes, GUI.AutoScaleYLowAxes_checkbox, GUI.MinYLimitLowAxes_Edit, GUI.MaxYLimitLowAxes_Edit, DATA.YLimLowAxes, DATA.AutoYLimitLowAxes);
            %             set_rectangles_YData();
            
            AllDataAxes_XLim = get(GUI.RRInt_Axes, 'XLim');
            RRIntPage_Length = max(AllDataAxes_XLim) - min(AllDataAxes_XLim);
            DATA.RRIntPage_Length = RRIntPage_Length;
            set(GUI.GUIDisplay.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
            setRRIntYLim();
            redraw_quality_rect();
        end
    end
%%
    function page_down_pushbutton_Callback(~, ~)
        xdata = get(GUI.red_rect_handle, 'XData');
        red_rect_length = max(xdata) - min(xdata);
        right_border = min(xdata);
        left_border = right_border - red_rect_length;
        
        if left_border < 0
            left_border = 0;
            right_border = red_rect_length;
        end
        if left_border >= 0 && left_border < right_border && right_border <= DATA.maxRRTime
            xdata = [left_border right_border right_border left_border left_border];
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
        end
    end
%%
    function page_up_pushbutton_Callback(~, ~)
        xdata = get(GUI.red_rect_handle, 'XData');
        red_rect_length = max(xdata) - min(xdata);
        left_border = max(xdata);
        right_border = left_border + red_rect_length;
        if right_border > DATA.maxRRTime
            left_border = DATA.maxRRTime - red_rect_length;
            right_border = DATA.maxRRTime;
        end
        if left_border >= 0 && left_border < right_border && right_border <= DATA.maxRRTime
            xdata = [left_border right_border right_border left_border left_border];
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
        end
    end
%%
    function EnablePageUpDown()
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
    function Annotation_popupmenu_Callback( src, ~ )
        index_selected = get(src, 'Value');
        
        if index_selected == 1
            GUI.GUIRecord.Class_popupmenu.Visible = 'off';
            GUI.Class_Text.Visible = 'off';
        else
            GUI.GUIRecord.Class_popupmenu.Visible = 'on';
            GUI.Class_Text.Visible = 'on';
        end
    end
%%
    function Class_popupmenu_Callback( ~, ~ )
    end
%%
    function SaveDataQuality_Callback( ~, ~ )
        
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
                    
                    quality_range{i} = get(GUI.quality_win(i), 'XData');
                    class_number = get(GUI.quality_win(i), 'UserData');
                    class{i, 1} = DATA.GUI_Class{class_number};
                    signal_quality(i, :) = [min(quality_range{i}) max(quality_range{i})];
                end
            else
                class{1, 1} = DATA.GUI_Class{3};
                signal_quality = [0, 0];
            end
            
            if strcmpi(ExtensionFileName, 'mat')
                save(full_file_name, 'signal_quality', 'class');
            elseif strcmpi(ExtensionFileName, 'txt')
                header_fileID = fopen(full_file_name, 'wt');
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
                %                 wrann([results_folder_name filename_noExt], 'sqi', int64(Quality_annotations_for_wfdb*DATA.Fs), 'fs', DATA.Fs, 'type', Class_for_wfdb);
            else
                errordlg('Please, choose only *.mat or *.txt file .', 'Input Error');
                return;
            end
        end
    end
%%
    function OpenDataQuality_Callback( ~, ~ )
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
            'Open ECG File', [DIRS.analyzedDataDirectory filesep '*.' EXT]); %
        
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
                
                for i = 1 : length(QualityAnnotations_field_names)
                    if ~isempty(regexpi(QualityAnnotations_field_names{i}, 'signal_quality')) % Quality_anns|quality_anno
                        QualityAnnotations_Data = QualityAnnotations.(QualityAnnotations_field_names{i});
                    elseif ~isempty(regexpi(QualityAnnotations_field_names{i}, 'class'))
                        Class = QualityAnnotations.(QualityAnnotations_field_names{i});
                    end
                end
                
                if ~isempty(QualityAnnotations_Data)
                    DATA_QualityAnnotations_Data = QualityAnnotations_Data;
                else
                    errordlg('Please, choose the Signal Quality Annotations File.', 'Input Error');
                    return;
                end
                if ~isempty(Class)
                    DATA_Class = Class;
                end
            elseif strcmpi(ExtensionFileName, 'txt')
                
                file_name = [PathName Quality_FileName];
                fileID = fopen(file_name);
                if fileID ~= -1
                    quality_data = textscan(fileID, '%f %f %s', 'Delimiter', '\t', 'HeaderLines', 1);
                    if ~isempty(quality_data{1}) && ~isempty(quality_data{2}) && ~isempty(quality_data{3})
                        DATA_QualityAnnotations_Data = [cell2mat(quality_data(1)) cell2mat(quality_data(2))];
                        class = quality_data(3);
                        DATA_Class = class{1};
                    else
                        errordlg('Please, choose the Data Quality Annotations File.', 'Input Error');
                        return;
                    end
                    fclose(fileID);
                else
                    return;
                end
                
                %             elseif strcmpi(ExtensionFileName, 'sqi')
                % %                 [quality_data, class] = rdann( [PathName QualityFileName], ExtensionFileName, 'ann_types', '"F"');
                % %                 [quality_data, class] = rdann( [PathName QualityFileName], ExtensionFileName, 'ann_types', '"ABC"');
                %                 [quality_data, class] = rdann( [PathName QualityFileName], ExtensionFileName);
                %                 quality_data = double(quality_data)/DATA.Fs;
                %                 DATA_QualityAnnotations_Data = [quality_data(1:2:end), quality_data(2:2:end)];
                %                 DATA_Class = class(1:2:end);
            else
                errordlg('Please, choose only *.mat or *.txt file .', 'Input Error');
                return;
            end
            
            set(GUI.GUIRecord.DataQualityFileName_text, 'String', Quality_FileName);
            
            if isfield(DATA, 'quality_win_num') && DATA.quality_win_num
                quality_win_ind = DATA.quality_win_num + 1;
            else
                quality_win_ind = 1;
            end
            
            for i = 1 : length(DATA_Class)
                [is_member, class_ind] = ismember(DATA_Class{i}, DATA.GUI_Class);
                if ~is_member
                    class_ind = 3;
                end
                if DATA_QualityAnnotations_Data(i, 1) ~= DATA_QualityAnnotations_Data(i, 2)
                    plot_quality_rect(DATA_QualityAnnotations_Data(i, :), quality_win_ind, class_ind);
                    DATA.quality_win_num = DATA.quality_win_num + 1;
                    quality_win_ind = quality_win_ind + 1;
                end
            end
        end
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
        delete( GUI.Window );
    end % onExit
end