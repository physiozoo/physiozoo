function PhysioZooGUI_PeakDetection()

myUpBackgroundColor = [219 237 240]/255; % Blue %[0.863 0.941 0.906];
myLowBackgroundColor = [219 237 240]/255; %[1 1 1];
myEditTextColor = [1 1 1];
mySliderColor = [0.8 0.9 0.9];
myPushButtonColor = [0.26 0.37 0.41];

DATA = createData();
GUI = createInterface();

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
        DATA.Integration = 'ECG';
        DATA.integration_index = 1;
        
        DATA.temp_rec_name4wfdb = 'temp_ecg_wfdb';
    end

%% Open the window
    function GUI = createInterface()
        SmallFontSize = DATA.SmallFontSize;
        BigFontSize = DATA.BigFontSize;
        GUI = struct();
        GUI.Window = figure( ...
            'Name', 'PhysioZoo_PeakDetection', ...
            'NumberTitle', 'off', ...   
            'HandleVisibility', 'off', ...
            'Toolbar', 'none', ...
            'MenuBar', 'none', ...
            'Position', [20, 50, DATA.window_size(1), DATA.window_size(2)], ...
            'Tag', 'fPhysioZooPD');
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
        

        uitoolbar_handle = uitoolbar('Parent', GUI.Window);
        C = uitoolfactory(uitoolbar_handle, 'Exploration.ZoomIn');
%         C.Separator = 'on';
        C = uitoolfactory(uitoolbar_handle, 'Exploration.ZoomOut');
        C = uitoolfactory(uitoolbar_handle, 'Exploration.Pan');
        C = uitoolfactory(uitoolbar_handle, 'Exploration.DataCursor');
        %         C = uitoolfactory(H,'Standard.EditPlot');

        
        
        % + File menu
        GUI.FileMenu = uimenu( GUI.Window, 'Label', 'File' );
        uimenu( GUI.FileMenu, 'Label', 'Open record file', 'Callback', @OpenFile_Callback, 'Accelerator', 'O');
        GUI.OpenDataQuality = uimenu( GUI.FileMenu, 'Label', 'Open data quality', 'Callback', @OpenDataQuality_Callback, 'Accelerator', 'Q');
        GUI.SavePeaks = uimenu( GUI.FileMenu, 'Label', 'Save Peaks', 'Callback', @SavePeaks_Callback, 'Accelerator', 'P');
        GUI.SaveDataQuality = uimenu( GUI.FileMenu, 'Label', 'Save data quality', 'Callback', @SaveDataQuality_Callback, 'Accelerator', 'D');
        GUI.LoadConfigurationFile = uimenu( GUI.FileMenu, 'Label', 'Load configuration file', 'Callback', @LoadConfigurationFile_Callback, 'Accelerator', 'L');
        GUI.SaveConfigurationFile = uimenu( GUI.FileMenu, 'Label', 'Save configuration file', 'Callback', @SaveConfigurationFile_Callback, 'Accelerator', 'C');
        
        uimenu( GUI.FileMenu, 'Label', 'Exit', 'Callback', @Exit_Callback, 'Separator', 'on', 'Accelerator', 'E');
        
        % + Help menu
        helpMenu = uimenu( GUI.Window, 'Label', 'Help' );
        uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @onHelp );
        uimenu( helpMenu, 'Label', 'PhysioZoo Home', 'Callback', @onPhysioZooHome );
        
        % Create the layout (Arrange the main interface)
        mainLayout = uix.VBoxFlex('Parent', GUI.Window, 'Spacing', 3);
        
        % + Create the panels
        Upper_Part_Box = uix.HBoxFlex('Parent', mainLayout, 'Spacing', 5); % Upper Part
        Low_Part_BoxPanel = uix.BoxPanel( 'Parent', mainLayout, 'Title', '  ', 'Padding', 5 ); %Low Part
        
        upper_part = 0.5;
        low_part = 1 - upper_part;
        set(mainLayout, 'Heights', [(-1)*upper_part, (-1)*low_part]  );
        
        % + Upper Panel - Left and Right Parts
        temp_panel_left = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', 5);        
        temp_panel_right = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', 5); % , 'BorderType', 'none'
        temp_panel_buttons = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', 5); % , 'BorderType', 'none'        
        
        if DATA.SmallScreen
            left_part = 0.4;             
        else
            left_part = 0.26;            
        end
        right_part = 0.9;
        buttons_part = 0.07;
        Left_Part_widths_in_pixels = 0.3 * DATA.window_size(1);
                
        
        set(Upper_Part_Box, 'Widths', [-1*left_part -1*right_part -1*buttons_part]);
        
        RightLeft_TabPanel = uix.TabPanel('Parent', temp_panel_left, 'Padding', 0);
        two_axes_box = uix.VBox('Parent', temp_panel_right, 'Spacing', 3);
        CommandsButtons_Box = uix.VButtonBox('Parent', temp_panel_buttons, 'Spacing', 3, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        
        RecordTab = uix.Panel( 'Parent', RightLeft_TabPanel, 'Padding', 5);
        ConfigParamTab = uix.Panel( 'Parent', RightLeft_TabPanel, 'Padding', 5);
        DisplayTab = uix.Panel( 'Parent', RightLeft_TabPanel, 'Padding', 5);
        
        RightLeft_TabPanel.TabTitles = {'Record', 'Config Params', 'Display'};
        RightLeft_TabPanel.TabWidth = 100;
        RightLeft_TabPanel.FontSize = BigFontSize;
        
        GUI.ECGDataAxes = axes('Parent', uicontainer('Parent', two_axes_box), 'Tag', 'MainAxes');
        GUI.RRDataAxes = axes('Parent', uicontainer('Parent', two_axes_box));
        
        set(two_axes_box, 'Heights', [-1, 100]);
        
        GUI.RR_or_HR_plot_button = uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', @RR_or_HR_plot_button_Callback, 'FontSize', BigFontSize, 'String', 'Plot HR');
        GUI.Reset_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', CommandsButtons_Box, 'Callback', @Reset_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Reset');
        set(CommandsButtons_Box, 'ButtonSize', [70, 25], 'Spacing', 5 );
        
        tabs_widths = Left_Part_widths_in_pixels;
        tabs_heights = 370;
        
        RecordSclPanel = uix.ScrollingPanel( 'Parent', RecordTab);
        RecordBox = uix.VBox( 'Parent', RecordSclPanel, 'Spacing', 5);
        set(RecordSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        ConfigSclPanel = uix.ScrollingPanel( 'Parent', ConfigParamTab);
        GUI.ConfigBox = uix.VBox( 'Parent', ConfigSclPanel, 'Spacing', 5);
        set(ConfigSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        DisplaySclPanel = uix.ScrollingPanel( 'Parent', DisplayTab);
        DisplayBox = uix.VBox( 'Parent', DisplaySclPanel, 'Spacing', 5);
        set(DisplaySclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
        
        %-------------------------------------------------------
        % Record Tab
        
        field_size = [130, -1, 1]; % 170
        
        [GUI, ~] = createGUITextLine(GUI, 'GUIRecord', 'RecordFileName_text', 'Record file name:', RecordBox, field_size);
        [GUI, ~] = createGUITextLine(GUI, 'GUIRecord', 'PeaksFileName_text', 'Peaks file name:', RecordBox, field_size);
        [GUI, ~] = createGUITextLine(GUI, 'GUIRecord', 'DataQualityFileName_text', 'Data quality file name:', RecordBox, field_size);
        [GUI, ~] = createGUITextLine(GUI, 'GUIRecord', 'TimeSeriesLength_text', 'Time series length:', RecordBox, field_size);
        
        field_size = [130, 170, -1]; % 170 190
        
        [GUI, ~] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'Mammal_popupmenu', 'Mammal', RecordBox, field_size, @Mammal_popupmenu_Callback, DATA.GUI_mammals);
        [GUI, ~] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'Integration_popupmenu', 'Integration Level', RecordBox, field_size, @Integration_popupmenu_Callback, DATA.GUI_Integration);
        
        TempBox = uix.HBox( 'Parent', RecordBox, 'Spacing', 5);
        GUI.AutoCalc_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', TempBox, 'Callback', @AutoCalc_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'Auto Compute', 'Value', 1);
        GUI.AutoCompute_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', TempBox, 'Callback', @AutoCompute_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'Compute', 'Enable', 'inactive');
        uix.Empty( 'Parent', TempBox );
        set(TempBox, 'Widths', field_size );
        
        uix.Empty( 'Parent', RecordBox);
        set(RecordBox, 'Heights', [-7 -7 -7 -7 -7 -7 -7 -25] );
        
        %-------------------------------------------------------
        % Config Params Tab
        
        field_size = [80, 150, 10 -1];
        
        uix.Empty( 'Parent', GUI.ConfigBox );
        
        [GUI, ~] = createGUISingleEditLine(GUI, 'GUIConfig', 'HR', 'HR', 'BMP', GUI.ConfigBox, field_size, @config_edit_Callback, 'config_edit', 'HR');
        [GUI, ~] = createGUISingleEditLine(GUI, 'GUIConfig', 'QS', 'QS', 'sec', GUI.ConfigBox, field_size, @config_edit_Callback, 'config_edit', 'QS');
        [GUI, ~] = createGUISingleEditLine(GUI, 'GUIConfig', 'QT', 'QT', 'sec', GUI.ConfigBox, field_size, @config_edit_Callback, 'config_edit', 'QT');
        [GUI, ~] = createGUISingleEditLine(GUI, 'GUIConfig', 'QRSa', 'QRSa', 'microVolts', GUI.ConfigBox, field_size, @config_edit_Callback, 'config_edit', 'QRSa');
        [GUI, ~] = createGUISingleEditLine(GUI, 'GUIConfig', 'QRSamin', 'QRSamin', 'microVolts', GUI.ConfigBox, field_size, @config_edit_Callback, 'config_edit', 'QRSamin');
        [GUI, ~] = createGUISingleEditLine(GUI, 'GUIConfig', 'RRmin', 'RRmin', 'sec', GUI.ConfigBox, field_size, @config_edit_Callback, 'config_edit', 'RRmin');
        [GUI, ~] = createGUISingleEditLine(GUI, 'GUIConfig', 'RRmax', 'RRmax', 'sec', GUI.ConfigBox, field_size, @config_edit_Callback, 'config_edit', 'RRmax');
        
%         uix.Empty( 'Parent', GUI.ConfigBox );
%         
%         TempBox = uix.HBox('Parent', GUI.ConfigBox, 'Spacing', 5);
%         uix.Empty( 'Parent', TempBox );
%         uicontrol( 'Style', 'PushButton', 'Parent', TempBox, 'Callback', @CalcWithNewValues_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Calc with new values');
%         uix.Empty( 'Parent', TempBox );
%         set(TempBox, 'Widths', [80 150 -1]);
        
        uix.Empty('Parent', GUI.ConfigBox );
        set(GUI.ConfigBox, 'Heights', [-7 -7  -7 -7 -7 -7 -7 -7 -35] );
        %-------------------------------------------------------
        % Display Tab
        field_size = [110, 140, 10, -1];
        
        uix.Empty( 'Parent', DisplayBox );
        
        [GUI, ~] = createGUISingleEditLine(GUI, 'GUIDisplay', 'FirstSecond', 'Window start:', 'h:min:sec', DisplayBox, field_size, @FirstSecond_Callback, '', '');
        [GUI, ~] = createGUISingleEditLine(GUI, 'GUIDisplay', 'WindowSize', 'Window length:', 'h:min:sec', DisplayBox, field_size, @WindowSize_Callback, '', '');
        
        field_size = [110, 64, 4, 63, 10];
        [GUI, YLimitBox] = createGUIDoubleEditLine(GUI, 'GUIDisplay', {'MinYLimit_Edit'; 'MaxYLimit_Edit'}, 'Y Limit:', '', DisplayBox, field_size, {@MinMaxYLimit_Edit_Callback; @MinMaxYLimit_Edit_Callback}, '', '');
        
        GUI.AutoScaleY_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', YLimitBox, 'Callback', @AutoScaleY_pushbutton_Callback, 'FontSize', 10, 'String', 'Auto Scale Y', 'Value', 1);
        set(YLimitBox, 'Widths', [field_size, 95]);
        
        uix.Empty( 'Parent', DisplayBox );
        set(DisplayBox, 'Heights', [-7 -7 -7 -7 -70] );
        
        %-------------------------------------------------------
        
        % Low Part
        Low_Part_Box = uix.VBox('Parent', Low_Part_BoxPanel, 'Spacing', 3);                                
        
        GUI.PeaksTable = uitable( 'Parent', Low_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{550 'auto'}, 'FontName', 'Calibri');  
        GUI.PeaksTable.ColumnName = {'Description'; 'Values'};
        GUI.PeaksTable.RowName = {'NB_PEAKS (n.u.)'; 'NB_PEAKS_ADD (n.u.)'; 'PR_PEAKS_ADD (%)'; 'NB_PEAKS_RM (n.u.)'; 'PR_PEAKS_RM (%)'; 'PR_BAD_SQ (%)'};
        GUI.PeaksTable.Data = {''};
        GUI.PeaksTable.Data(1, 1) = {'Number of peaks detected by the peak detection algorithm'};
        GUI.PeaksTable.Data(2, 1) = {'Number of peaks manually added by the user'}; 
        GUI.PeaksTable.Data(3, 1) = {'Percentage of peaks manually added by the user'};
        GUI.PeaksTable.Data(4, 1) = {'Number of peaks manually removed by the user'};
        GUI.PeaksTable.Data(5, 1) = {'Percentage of peaks manually removed by the user'};
        GUI.PeaksTable.Data(6, 1) = {['Percentage of the record annotated as bad quality (i.e. signal quality ' sprintf('\x2260') ' ''A'')']};
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
    end
%%
    function [GUI, TempBox] = createGUITextLine(GUI, gui_struct, field_name, string_field_name, box_container, field_size)
        
        TempBox = uix.HBox( 'Parent', box_container, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', string_field_name, 'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.(gui_struct).(field_name) = uicontrol( 'Style', 'text', 'Parent', TempBox, 'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
        uix.Empty( 'Parent', TempBox );
        
        set( TempBox, 'Widths', field_size  );
    end
%%
    function [GUI, TempBox] = createGUISingleEditLine(GUI, gui_struct, field_name, string_field_name, field_units, box_container, field_size, callback_function, tag, user_data)
        
        TempBox = uix.HBox( 'Parent', box_container, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', string_field_name, 'FontSize', DATA.BigFontSize, 'HorizontalAlignment', 'left');
        GUI.(gui_struct).(field_name) = uicontrol( 'Style', 'edit', 'Parent', TempBox, 'Callback', callback_function, 'FontSize', DATA.BigFontSize, 'Tag', tag, 'UserData', user_data);
        uix.Empty( 'Parent', TempBox );
        if ~isempty(strfind(field_units, 'micro')) % https://unicode-table.com/en/
            field_units = strrep(field_units, 'micro', '');
            field_units = [sprintf('\x3bc') field_units];
        end
        uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', field_units, 'FontSize', DATA.BigFontSize, 'HorizontalAlignment', 'left');
        set( TempBox, 'Widths', field_size  );
    end
%%
    function [GUI, TempBox] = createGUIDoubleEditLine(GUI, gui_struct, field_name, string_field_name, field_units, box_container, field_size, callback_function, tag, user_data)
        
        TempBox = uix.HBox( 'Parent', box_container, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', string_field_name, 'FontSize', DATA.BigFontSize, 'HorizontalAlignment', 'left');
        GUI.(gui_struct).(field_name{1}) = uicontrol( 'Style', 'edit', 'Parent', TempBox, 'Callback', callback_function{1}, 'FontSize', DATA.BigFontSize, 'Tag', tag, 'UserData', user_data);
        uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', '-', 'FontSize', DATA.BigFontSize);
        GUI.(gui_struct).(field_name{2}) = uicontrol( 'Style', 'edit', 'Parent', TempBox, 'Callback', callback_function{2}, 'FontSize', DATA.BigFontSize, 'Tag', tag, 'UserData', user_data);
        
        uix.Empty( 'Parent', TempBox );
        
        if ~isempty(field_units)
            uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', field_units, 'FontSize', DATA.BigFontSize, 'HorizontalAlignment', 'left');
        end
        
        set(TempBox, 'Widths', field_size);
    end
%%
    function [GUI, TempBox] = createGUIPopUpMenuLine(GUI, gui_struct, field_name, string_field_name, box_container, field_size, callback_function, popupmenu_sting)
        
        TempBox = uix.HBox( 'Parent', box_container, 'Spacing', 5);
        uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', string_field_name, 'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.(gui_struct).(field_name) = uicontrol( 'Style', 'PopUpMenu', 'Parent', TempBox, 'Callback', callback_function, 'FontSize', DATA.SmallFontSize, 'String', popupmenu_sting);
        uix.Empty('Parent', TempBox);
        
        set(TempBox, 'Widths', field_size);
    end
%%
    function Mammal_popupmenu_Callback(src, ~)
        
        DATA.customConfigFile = [];
        
        index_selected = get(src, 'Value');        
        
        if index_selected == length(DATA.mammals) % Custom mammal
            
            [Config_FileName, PathName] = uigetfile({'*.conf','Configuration files (*.conf)'}, 'Open Configuration File', []);
            if ~isequal(Config_FileName, 0)
                params_filename = fullfile(PathName, Config_FileName);
                DATA.customConfigFile = params_filename;
            else % Cancel by user
                src.Value = DATA.mammal_index;
                return;
            end
        else
            DATA.customConfigFile = ['gqrs.' DATA.mammals{index_selected} '.conf'];
        end
        
        DATA.mammal_index = index_selected;
        
        load_updateGUI_config_param();
        if get(GUI.AutoCalc_checkbox, 'Value')
            RunAndPlotPeakDetector();
%             RunAndPlotPeakDetector(index_selected, DATA.customConfigFile);
        end
    end
%%
    function Integration_popupmenu_Callback(src, ~)
        items = get(src, 'String');
        index_selected = get(src, 'Value');
        DATA.Integration = items{index_selected};
    end
%%
    function OpenFile_Callback(~, ~)
        
        persistent DIRS;
        persistent EXT;
        
        % Add third-party dependencies to path
        gui_basepath = fileparts(mfilename('fullpath'));
        basepath = fileparts(gui_basepath);
        
        if ~isfield(DIRS, 'dataDirectory')
            DIRS.dataDirectory = [basepath filesep 'Examples'];
        end
        if isempty(EXT)
            EXT = 'mat';
        end
        
        [ECG_FileName, PathName] = uigetfile( ...
            {'*.dat',  'WFDB Files (*.dat)'; ...
            '*.mat','MAT-files (*.mat)'; ...
            '*.txt','Text Files (*.txt)'}, ...
            'Open ECG File', [DIRS.dataDirectory filesep '*.' EXT]); %
        
        if ~isequal(ECG_FileName, 0)
            
            delete_temp_wfdb_files();
            
            set(GUI.GUIRecord.RecordFileName_text, 'String', '');
            set(GUI.GUIRecord.PeaksFileName_text, 'String', '');
            set(GUI.GUIRecord.DataQualityFileName_text, 'String', '');
            set(GUI.GUIRecord.TimeSeriesLength_text, 'String', '');
            
            DIRS.dataDirectory = PathName;
            
            [~, DATA.DataFileName, ExtensionFileName] = fileparts(ECG_FileName);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            DATA.rec_name = [PathName, DATA.DataFileName];
            if strcmpi(ExtensionFileName, 'dat')
                header_info = wfdb_header(DATA.rec_name);
                DATA.ecg_channel = get_signal_channel(DATA.rec_name, 'header_info', header_info);
                if (isempty(DATA.ecg_channel))
                    error('Failed to find an ECG channel in the record %s', DATA.rec_name);
                end
                % Read Signal
                [DATA.tm, DATA.sig, DATA.Fs] = rdsamp(DATA.rec_name, DATA.ecg_channel, 'header_info', header_info);
            elseif strcmpi(ExtensionFileName, 'mat')
                ECG = load(DATA.rec_name);
                ECG_field_names = fieldnames(ECG);
                if ~isempty(regexpi(ECG_field_names{1}, 'ecg')) % |data
                    ECG_data = ECG.(ECG_field_names{1});
                    if ~isempty(ECG_data)
                        DATA.tm = ECG_data(:, 1);
                        DATA.sig = ECG_data(:, 2);
                        DATA.Fs = 1/median(diff(DATA.tm));
                        
                        [t_max, h, m, s ,ms] = signal_duration(length(DATA.tm), DATA.Fs);
                        header_info = struct('duration', struct('h', h, 'm', m, 's', s, 'ms', ms), 'total_seconds', t_max);
                        
                        DATA.ecg_channel = 1;
                        DATA.rec_name = DATA.temp_rec_name4wfdb;
                        
                        mat2wfdb(DATA.sig, DATA.rec_name, DATA.Fs, [], ' ' ,{} ,[]);
                        if exist([DATA.rec_name '.dat'], 'file') && exist([DATA.rec_name '.hea'], 'file')
                            [DATA.tm, DATA.sig, DATA.Fs] = rdsamp(DATA.rec_name, DATA.ecg_channel);
                        end
                    end
                else
                    errordlg('Please, choose the file with the ECG data.', 'Input Error');
                    return;
                end
            elseif strcmpi(ExtensionFileName, 'txt')
            end
            set(GUI.GUIRecord.RecordFileName_text, 'String', ECG_FileName); 
            
            cla(GUI.ECGDataAxes); % RawData_axes
            cla(GUI.RRDataAxes); % RR_axes
            
            DATA.DATA.mammal_index = 1;
            set(GUI.GUIRecord.Mammal_popupmenu, 'Value', 1);
            
            DATA.RawDataHandle = line(DATA.tm, DATA.sig, 'Parent', GUI.ECGDataAxes);
            
            PathName = strrep(PathName, '\', '\\');
            PathName = strrep(PathName, '_', '\_');
            ECG_FileName_title = strrep(ECG_FileName, '_', '\_');
            
            TitleName = [PathName ECG_FileName_title] ;
            title(GUI.ECGDataAxes, TitleName, 'FontWeight', 'normal', 'FontSize', 11);
            
            min_sig = min(DATA.sig);
            max_sig = max(DATA.sig);
            delta = (max_sig - min_sig)*0.1;
            
            set(GUI.ECGDataAxes, 'XLim', [0 max(DATA.tm)]);
            set(GUI.ECGDataAxes, 'YLim', [min(min_sig, max_sig) - delta max(min_sig, max_sig) + delta]);
            
            xlabel(GUI.ECGDataAxes, 'Time (sec)');
            ylabel(GUI.ECGDataAxes, 'ECG (mV)');
            hold(GUI.ECGDataAxes, 'on');
            
            set(GUI.GUIRecord.TimeSeriesLength_text, 'String', [[num2str(header_info.duration.h) ':' num2str(header_info.duration.m) ':' ...
                num2str(header_info.duration.s) '.' num2str(header_info.duration.ms)] '    h:min:sec.msec']);
            
            GUI.LoadConfigurationFile.Enable = 'on';
            GUI.SaveConfigurationFile.Enable = 'on';
            GUI.SavePeaks.Enable = 'on';
            
%             RunAndPlotPeakDetector(get(GUI.GUIRecord.Mammal_popupmenu, 'Value'), []);
        end
    end
%%
    function load_updateGUI_config_param()
        DATA.config_map = parse_gqrs_config_file(DATA.customConfigFile);
        
        params_GUI_edit_values = findobj(GUI.ConfigBox, 'Style', 'edit');
        fields_names = get(params_GUI_edit_values, 'UserData');
        
        for i = 1 : length(params_GUI_edit_values)
            param_value = DATA.config_map(fields_names{i});
            set(params_GUI_edit_values(i), 'String', param_value);
        end
    end
%%
%     function RunAndPlotPeakDetector(mammal_index, customConfigFile)
    function RunAndPlotPeakDetector()
        
        if isfield(DATA, 'rec_name') && ~strcmp(DATA.rec_name, '')
            
            cla(GUI.RRDataAxes);
            if isfield(DATA, 'red_peaks_handle') && ishandle(DATA.red_peaks_handle) && isvalid(DATA.red_peaks_handle)
                delete(DATA.red_peaks_handle);
            end
            if isfield(DATA, 'customConfigFile') && ~strcmp(DATA.customConfigFile, '')
                %         if mammal_index == length(DATA.mammals)
                %             conf_path = customConfigFile;
                %         else
                %             conf_path = ['gqrs.' DATA.mammals{mammal_index} '.conf'];
                %         end
                
                load_updateGUI_config_param();
                
                [DATA.qrs, DATA.outliers, tm, sig, Fs] = rqrs(DATA.rec_name, 'gqconf', DATA.customConfigFile, 'ecg_channel', DATA.ecg_channel, 'plot', false);
                DATA.red_peaks_handle = line(DATA.tm(DATA.qrs), DATA.sig(DATA.qrs, 1), 'Parent', GUI.ECGDataAxes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'LineWidth', 2);
                
                rr_time = DATA.qrs(1:end-1)/DATA.Fs;
                rr_data = diff(DATA.qrs)/DATA.Fs;
                
                if ~isempty(rr_data)
                    DATA.RRInt_handle = line(rr_time, rr_data, 'Parent', GUI.RRDataAxes);
                    
                    min_sig = min(rr_data);
                    max_sig = max(rr_data);
                    delta = (max_sig - min_sig)*1;
                    
                    set(GUI.RRDataAxes, 'XLim', [0 max(DATA.tm)]);
                    set(GUI.RRDataAxes, 'YLim', [min(min_sig, max_sig) - delta max(min_sig, max_sig) + delta]);
                    
                    % xlabel('Time (sec)');
                    ylabel(GUI.RRDataAxes, 'RR (sec)');
                    linkaxes([GUI.ECGDataAxes, GUI.RRDataAxes], 'x');
%                     set(GUI.NumPeaksDetected_edit, 'String', num2str(length(DATA.qrs)));
                    
                    GUI.PeaksTable.Data(1, 2) = {length(DATA.qrs)};
                else
                    errordlg('The algorithm could not run. Please, check input parameters.', 'Input Error');
                end
            end
        end
    end
%%
    function LoadConfigurationFile_Callback(~, ~)
        
        [Config_FileName, PathName] = uigetfile({'*.conf','Conf files (*.conf)'}, 'Open Configuration File', []);
        if ~isequal(Config_FileName, 0)
            mammal_index = length(DATA.mammals);
%             params_filename = fullfile(PathName, Config_FileName);
            DATA.customConfigFile = fullfile(PathName, Config_FileName);
            load_updateGUI_config_param();
            if get(GUI.AutoCalc_checkbox, 'Value')
%                 RunAndPlotPeakDetector(mammal_index, params_filename);
                RunAndPlotPeakDetector();                
            end
            GUI.GUIRecord.Mammal_popupmenu.Value = mammal_index;
            DATA.mammal_index = mammal_index;
        end
    end
%%
    function SaveConfigurationFile_Callback(~, ~)
        
        [filename, results_folder_name, FilterIndex] = uiputfile({'*.','Conf Files (*.conf)'},'Choose Config File Name', ['gqrs.custom.conf']);
        
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
        if ~strcmp(field_value, '')
            if isfield(DATA, 'config_map') && ~isempty(DATA.config_map)
                DATA.config_map(get(src, 'UserData')) = get(src, 'String');                
                DATA.customConfigFile = 'gqrs.temp_custom.conf';
                temp_custom_conf_fileID = saveCustomParameters(DATA.customConfigFile);
                if temp_custom_conf_fileID == -1
                    errordlg('Problems with creation of custom config file.', 'Input Error');
                    return;
                end
                if get(GUI.AutoCalc_checkbox, 'Value')
                    RunAndPlotPeakDetector();
                end
            end
        end
    end
%%
    function CalcWithNewValues_pushbutton_Callback(~, ~)
        
        Config_FileName = 'gqrs.temp_custom.conf';
        
        if isfield(DATA, 'config_map')
            temp_custom_conf_fileID = saveCustomParameters(Config_FileName);
            if temp_custom_conf_fileID ~= -1
                RunAndPlotPeakDetector(length(DATA.mammals), fullfile(pwd, Config_FileName));
                delete(Config_FileName);
            end
        end
    end
%%
    function delete_temp_wfdb_files()        
        if exist([pwd '\' DATA.temp_rec_name4wfdb '.hea'], 'file')
            delete([pwd '\' DATA.temp_rec_name4wfdb '.hea']);
        end
        if exist([pwd '\' DATA.temp_rec_name4wfdb '.dat'], 'file')
            delete([pwd '\' DATA.temp_rec_name4wfdb '.dat']);
        end        
    end
%%
    function SavePeaks_Callback(~, ~)       
        
        persistent DIRS;
        persistent EXT;
        
        % Add third-party dependencies to path
        gui_basepath = fileparts(mfilename('fullpath'));
        basepath = fileparts(gui_basepath);
        
        if ~isfield(DIRS, 'analyzedDataDirectory') 
            DIRS.analyzedDataDirectory = [basepath filesep 'Results'];
        end
        if isempty(EXT)
            EXT = 'mat';
        end
                
        original_file_name = DATA.DataFileName;
        file_name = [original_file_name, '_peaks'];
        
        [filename, results_folder_name, ~] = uiputfile({'*.*', 'All files';...
            '*.txt','Text Files (*.txt)';...
            '*.mat','MAT-files (*.mat)';...
            '*.qrs',  'WFDB Files (*.qrs)'},...
            'Choose Analyzed Data File Name',...
            [DIRS.analyzedDataDirectory, filesep, file_name, '.', EXT]);
        if ~isequal(results_folder_name, 0)
            DIRS.analyzedDataDirectory = results_folder_name;
            [~, DATA.PeaksFileName, ExtensionFileName] = fileparts(filename);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            
            Data = DATA.qrs;
            Fs = DATA.Fs;
            Integration = DATA.Integration;
            Mammal = DATA.mammals{DATA.mammal_index};
            
            full_file_name = [results_folder_name, filename];
            
            if strcmpi(ExtensionFileName, 'mat')
                save(full_file_name, 'Data', 'Fs', 'Integration', 'Mammal');
            elseif strcmpi(ExtensionFileName, 'txt')
                header_fileID = fopen(full_file_name, 'w');
                fprintf(header_fileID, 'Mammal: %s\r\n', Mammal);
                fprintf(header_fileID, 'Fs: %d\r\n', Fs);
                fprintf(header_fileID, 'Integration: %s\r\n\r\n', Integration);
                dlmwrite(full_file_name, Data, 'delimiter', '\t', 'precision', '%d\t\n', 'newline', 'pc', '-append');
                fclose(header_fileID);
            elseif strcmpi(ExtensionFileName, 'qrs')
                [~, filename_noExt, ~] = fileparts(filename);
                saved_path = pwd;
                cd(results_folder_name);
                try
                    wfdb_path = 'D:\Temp\wfdb-app-toolbox-0-9-10\mcode';
                    addpath(wfdb_path);
                    mat2wfdb(Data, filename_noExt, Fs, [], ' ', {}, [], {strcat(Integration, '-', Mammal)});
                    wrann(filename_noExt, 'qrs', int64(Data));
                    rmpath(wfdb_path);
                    delete([filename_noExt '.dat']);
                catch e
                    disp(e);
                end
                cd(saved_path);
            end
        end
    end
%%
    function AutoCompute_pushbutton_Callback( ~, ~ )
        %         RunAndPlotPeakDetector(get(GUI.GUIRecord.Mammal_popupmenu, 'Value'), []);        
        RunAndPlotPeakDetector();
    end
%%
    function AutoCalc_checkbox_Callback( src, ~ )
        if get(src, 'Value') == 1
            GUI.AutoCompute_pushbutton.Enable = 'inactive';
        else
            GUI.AutoCompute_pushbutton.Enable = 'on';
        end
    end
%%
    function RR_or_HR_plot_button_Callback(~, ~)
    end
%%
    function Reset_pushbutton_Callback(~, ~)
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