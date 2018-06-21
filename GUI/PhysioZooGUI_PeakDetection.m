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
        
        DATA.Spacing = 3;
        DATA.Padding = 3;
        
        DATA.PlotHR = 0;
        
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
        uimenu( GUI.FileMenu, 'Label', 'Open record file', 'Callback', @OpenFile_Callback, 'Accelerator', 'O');
        GUI.OpenDataQuality = uimenu( GUI.FileMenu, 'Label', 'Open data quality', 'Callback', @OpenDataQuality_Callback, 'Accelerator', 'Q');
        GUI.LoadPeaks = uimenu( GUI.FileMenu, 'Label', 'Load Peaks', 'Callback', @LoadPeaks_Callback, 'Accelerator', 'W');
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
        
        if DATA.SmallScreen
            left_part = 0.4;             
        else
            left_part = 0.26;            
        end
        right_part = 0.9;
        buttons_part = 0.07;
        Left_Part_widths_in_pixels = 0.3 * DATA.window_size(1);
                        
        set(Upper_Part_Box, 'Widths', [-1*left_part -1*right_part -1*buttons_part]);
        
        RightLeft_TabPanel = uix.TabPanel('Parent', temp_panel_left, 'Padding', DATA.Padding);
        two_axes_box = uix.VBox('Parent', temp_panel_right, 'Spacing', DATA.Spacing);
        CommandsButtons_Box = uix.VButtonBox('Parent', temp_panel_buttons, 'Spacing', DATA.Spacing, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        
        RecordTab = uix.Panel( 'Parent', RightLeft_TabPanel, 'Padding', DATA.Padding);
        ConfigParamTab = uix.Panel( 'Parent', RightLeft_TabPanel, 'Padding', DATA.Padding);
        DisplayTab = uix.Panel( 'Parent', RightLeft_TabPanel, 'Padding', DATA.Padding);
        
        RightLeft_TabPanel.TabTitles = {'Record', 'Config Params', 'Display'};
        RightLeft_TabPanel.TabWidth = 100;
        RightLeft_TabPanel.FontSize = BigFontSize;
        
        GUI.ECGDataAxes = axes('Parent', uicontainer('Parent', two_axes_box), 'Tag', 'GUI.ECGDataAxes');
        GUI.RRDataAxes = axes('Parent', uicontainer('Parent', two_axes_box), 'Tag', 'GUI.RRDataAxes');
        
        set(two_axes_box, 'Heights', [-1, 100]);
        
        GUI.RR_or_HR_plot_button = uicontrol( 'Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', @RR_or_HR_plot_button_Callback, 'FontSize', BigFontSize, 'String', 'Plot HR');
        GUI.Reset_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', CommandsButtons_Box, 'Callback', @Reset_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Reset');
        set(CommandsButtons_Box, 'ButtonSize', [70, 25], 'Spacing', DATA.Spacing);
        
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
        [GUI, textBox{3}, text_handles{3}] = createGUITextLine(GUI, 'GUIRecord', 'DataQualityFileName_text', 'Data quality file name:', RecordBox);
        [GUI, textBox{4}, text_handles{4}] = createGUITextLine(GUI, 'GUIRecord', 'TimeSeriesLength_text', 'Time series length:', RecordBox);                
        
        [GUI, textBox{5}, text_handles{5}] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'Mammal_popupmenu', 'Mammal', RecordBox, @Mammal_popupmenu_Callback, DATA.GUI_mammals);
        [GUI, textBox{6}, text_handles{6}] = createGUIPopUpMenuLine(GUI, 'GUIRecord', 'Integration_popupmenu', 'Integration Level', RecordBox, @Integration_popupmenu_Callback, DATA.GUI_Integration);
        
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
                
        for i = 5 : 6
            set(textBox{i}, 'Widths', field_size);
        end
        
        TempBox = uix.HBox( 'Parent', RecordBox, 'Spacing', DATA.Spacing);
        GUI.AutoCalc_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', TempBox, 'Callback', @AutoCalc_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'Auto Compute', 'Value', 1);
        GUI.AutoCompute_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', TempBox, 'Callback', @AutoCompute_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'Compute', 'Enable', 'inactive');
        uix.Empty( 'Parent', TempBox );
        set(TempBox, 'Widths', field_size );
        
        uix.Empty( 'Parent', RecordBox);
        set(RecordBox, 'Heights', [-7 -7 -7 -7 -7 -7 -7 -25] );
        
        %-------------------------------------------------------
        % Config Params Tab
        
%         field_size = [80, 150, 10 -1];
        
        uix.Empty( 'Parent', GUI.ConfigBox );
        
        [GUI, textBox{1}, text_handles{1}] = createGUISingleEditLine(GUI, 'GUIConfig', 'HR', 'HR', 'BMP', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'HR');
        [GUI, textBox{2}, text_handles{2}] = createGUISingleEditLine(GUI, 'GUIConfig', 'QS', 'QS', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'QS');
        [GUI, textBox{3}, text_handles{3}] = createGUISingleEditLine(GUI, 'GUIConfig', 'QT', 'QT', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'QT');
        [GUI, textBox{4}, text_handles{4}] = createGUISingleEditLine(GUI, 'GUIConfig', 'QRSa', 'QRSa', 'microVolts', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'QRSa');
        [GUI, textBox{5}, text_handles{5}] = createGUISingleEditLine(GUI, 'GUIConfig', 'QRSamin', 'QRSamin', 'microVolts', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'QRSamin');
        [GUI, textBox{6}, text_handles{6}] = createGUISingleEditLine(GUI, 'GUIConfig', 'RRmin', 'RRmin', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'RRmin');
        [GUI, textBox{7}, text_handles{7}] = createGUISingleEditLine(GUI, 'GUIConfig', 'RRmax', 'RRmax', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'RRmax');
        
        uix.Empty('Parent', GUI.ConfigBox );
        
        GUI.AutoPeakWin_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', GUI.ConfigBox, 'FontSize', SmallFontSize, 'String', 'Auto', 'Value', 1);
        [GUI, textBox{8}, text_handles{8}] = createGUISingleEditLine(GUI, 'GUIConfig', 'PeaksWindow', 'Peaks window', 'ms', GUI.ConfigBox, @Peaks_Window_edit_Callback, '', '');
        
%         uix.Empty('Parent', GUI.ConfigBox );
%         
%         tempBox = uix.HBox('Parent', GUI.ConfigBox, 'Spacing', DATA.Spacing);
%         uix.Empty('Parent', tempBox );
%         GUI.AutoCompute_pushbutton = uicontrol( 'Style', 'PushButton', 'Parent', tempBox, 'Callback', @Del_win_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'Del Win');
%         uix.Empty('Parent', tempBox );  
%         uix.Empty('Parent', tempBox ); 
        
        uix.Empty('Parent', GUI.ConfigBox );
        set(GUI.ConfigBox, 'Heights', [-7 -7  -7 -7 -7 -7 -7 -7 -10 -7 -7 -35] );
        %-------------------------------------------------------
        % Display Tab
%         field_size = [110, 140, 10, -1];
        
        uix.Empty( 'Parent', DisplayBox );
        
        [GUI, textBox{9}, text_handles{9}] = createGUISingleEditLine(GUI, 'GUIDisplay', 'FirstSecond', 'Window start:', 'h:min:sec', DisplayBox, @FirstSecond_Callback, '', '');
        [GUI, textBox{10}, text_handles{10}] = createGUISingleEditLine(GUI, 'GUIDisplay', 'WindowSize', 'Window length:', 'h:min:sec', DisplayBox, @WindowSize_Callback, '', '');                        
        
%         field_size = [110, 64, 4, 63, 10];
        [GUI, YLimitBox, text_handles{11}] = createGUIDoubleEditLine(GUI, 'GUIDisplay', {'MinYLimit_Edit'; 'MaxYLimit_Edit'}, 'Y Limit:', '', DisplayBox, {@MinMaxYLimit_Edit_Callback; @MinMaxYLimit_Edit_Callback}, '', '');
        
        max_extent_control = calc_max_control_x_extend(text_handles);
        
        field_size = [max_extent_control, 150, 10 -1];        
        for i = 1 : length(text_handles) - 1
            set(textBox{i}, 'Widths', field_size);
        end
                
%         set( tempBox, 'Widths',  field_size); 
        
        field_size = [max_extent_control, 72, 2, 70, 10];
        set(YLimitBox, 'Widths', field_size);
        
        GUI.AutoScaleY_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', YLimitBox, 'Callback', @AutoScaleY_pushbutton_Callback, 'FontSize', 10, 'String', 'Auto Scale Y', 'Value', 1);
        set(YLimitBox, 'Widths', [field_size, 95]);
        
        uix.Empty( 'Parent', DisplayBox );
        set(DisplayBox, 'Heights', [-7 -7 -7 -7 -70] );
        
        %-------------------------------------------------------
        
        % Low Part
        Low_Part_Box = uix.VBox('Parent', Low_Part_BoxPanel, 'Spacing', DATA.Spacing);                                
        
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
    function Mammal_popupmenu_Callback(src, ~)
        
        index_selected = get(src, 'Value');
        if index_selected ~= 1
            
            DATA.customConfigFile = [];
            
            if index_selected == length(DATA.mammals) % Custom mammal
                
                [Config_FileName, PathName] = uigetfile({'*.conf','Configuration files (*.conf)'}, 'Open Configuration File', []);
                if ~isequal(Config_FileName, 0)
                    params_filename = fullfile(PathName, Config_FileName);
                    DATA.customConfigFile = params_filename;
                    mammal = 'custom';
                else % Cancel by user
                    src.Value = DATA.mammal_index;
                    return;
                end
            else
                mammal = DATA.mammals{index_selected};
                DATA.customConfigFile = ['gqrs.' mammal '.conf'];
            end
            
            DATA.mammal_index = index_selected;
            DATA.zoom_rect_limits = [0 DATA.firstZoom];
            
            load_updateGUI_config_param();
            if get(GUI.AutoCalc_checkbox, 'Value')
                RunAndPlotPeakDetector();                
            end            
            if strcmp(mammal, 'dog')
                DATA.peak_search_win = 90;
            elseif strcmp(mammal, 'rabbit')
                DATA.peak_search_win = 40;
            elseif strcmp(mammal, 'mouse')
                DATA.peak_search_win = 17;
            elseif strcmp(mammal, 'human')
                DATA.peak_search_win = 150;
            else
                DATA.peak_search_win = 100;
            end
            set(GUI.GUIConfig.PeaksWindow, 'String', DATA.peak_search_win);
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
                        header_info = set_data(ECG_data);
                    end                    
                else
                    errordlg('Please, choose the file with the ECG data.', 'Input Error');
                    return;
                end
            elseif strcmpi(ExtensionFileName, 'txt')
                                
                txt_data = dlmread([DATA.rec_name '.' EXT], '\t');
                
                if ~isempty(txt_data)
                    header_info = set_data(txt_data);
                end                                
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
            
            right_limit2plot = min(DATA.firstZoom, max(DATA.tm));            
            
            setECGYLim(0, right_limit2plot);
            
%             sig = DATA.sig(DATA.tm >= 0 & DATA.tm <= right_limit2plot);
%                         
%             min_sig = min(sig);
%             max_sig = max(sig);
%             delta = (max_sig - min_sig)*0.1;
            
            set(GUI.ECGDataAxes, 'XLim', [0 right_limit2plot]); 
%             set(GUI.ECGDataAxes, 'YLim', [min(min_sig, max_sig) - delta max(min_sig, max_sig) + delta]);
            
            xlabel(GUI.ECGDataAxes, 'Time (sec)');
            ylabel(GUI.ECGDataAxes, 'ECG (mV)');
            hold(GUI.ECGDataAxes, 'on');
            
            set(GUI.GUIRecord.TimeSeriesLength_text, 'String', [[num2str(header_info.duration.h) ':' num2str(header_info.duration.m) ':' ...
                num2str(header_info.duration.s) '.' num2str(header_info.duration.ms)] '    h:min:sec.msec']);
            
            GUI.LoadConfigurationFile.Enable = 'on';
            GUI.SaveConfigurationFile.Enable = 'on';
            GUI.SavePeaks.Enable = 'on';  
            GUI.LoadPeaks.Enable = 'on';
            
            
            DATA.zoom_rect_limits = [0 DATA.firstZoom];
        end
    end
%%
    function header_info = set_data(ecg_data)
        
        DATA.tm = ecg_data(:, 1);
        DATA.sig = ecg_data(:, 2);
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
%%
    function setECGYLim(minLimit, maxLimit)
        sig = DATA.sig(DATA.tm >= minLimit & DATA.tm <= maxLimit);
        
        min_sig = min(sig);
        max_sig = max(sig);
        delta = (max_sig - min_sig)*0.1;
                
        set(GUI.ECGDataAxes, 'YLim', [min(min_sig, max_sig) - delta max(min_sig, max_sig) + delta]);
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
        if isfield(DATA, 'rec_name') && ~strcmp(DATA.rec_name, '')
            
            cla(GUI.RRDataAxes);
            if isfield(DATA, 'red_peaks_handle') && ishandle(DATA.red_peaks_handle) && isvalid(DATA.red_peaks_handle)
                delete(DATA.red_peaks_handle);
            end
            if isfield(DATA, 'customConfigFile') && ~strcmp(DATA.customConfigFile, '')
                
                load_updateGUI_config_param();
                
                [DATA.qrs, tm, sig, Fs] = rqrs(DATA.rec_name, 'gqconf', DATA.customConfigFile, 'ecg_channel', DATA.ecg_channel, 'plot', false);
                DATA.red_peaks_handle = line(DATA.tm(DATA.qrs), DATA.sig(DATA.qrs, 1), 'Parent', GUI.ECGDataAxes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'LineWidth', 2);
                uistack(DATA.red_peaks_handle, 'bottom');
                
                if ~isempty(DATA.qrs)
                    plot_rr_data();
                    plot_red_rectangle(DATA.zoom_rect_limits);
                    GUI.PeaksTable.Data(1, 2) = {length(DATA.qrs)};
                else
                    errordlg('The algorithm could not run. Please, check input parameters.', 'Input Error');
                end
            end
            set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
            set(GUI.Window, 'WindowButtonUpFcn', @my_WindowButtonUpFcn);
            set(GUI.Window, 'WindowButtonDownFcn', @my_WindowButtonDownFcn);
        end
    end
%%
    function plot_red_rectangle(xlim)        
        ylim = get(GUI.RRDataAxes, 'YLim');
        x_box = [min(xlim) max(xlim) max(xlim) min(xlim) min(xlim)];
        y_box = [ylim(1) ylim(1) ylim(2) ylim(2) ylim(1)];
        GUI.red_rect = line(x_box, y_box, 'Color', 'r', 'Linewidth', 2, 'Parent', GUI.RRDataAxes, 'Tag', 'red_zoom_rect');
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
                DATA.RRInt_handle = line(rr_time, rr_data, 'Parent', GUI.RRDataAxes);
                
                min_sig = min(rr_data);
                max_sig = max(rr_data);
                delta = (max_sig - min_sig)*0.1;
                   
                DATA.maxRRTime = max(rr_time);
                DATA.eps = DATA.maxRRTime * 0.01; %0.01
                
                set(GUI.RRDataAxes, 'YLim', [min(min_sig, max_sig) - delta max(min_sig, max_sig) + delta]);
                                
                ylabel(GUI.RRDataAxes, yString);
                if length(qrs) == length(DATA.qrs)
                    set(GUI.RRDataAxes, 'XLim', [0 max(DATA.tm)]);
%                 else
%                     set(GUI.RRDataAxes, 'XLim', get(GUI.ECGDataAxes, 'XLim'));
                end
            end
        end
    end
%%
    function LoadConfigurationFile_Callback(~, ~)
        
        [Config_FileName, PathName] = uigetfile({'*.conf','Conf files (*.conf)'}, 'Open Configuration File', []);
        if ~isequal(Config_FileName, 0)
            mammal_index = length(DATA.mammals);
            DATA.customConfigFile = fullfile(PathName, Config_FileName);
            load_updateGUI_config_param();
            if get(GUI.AutoCalc_checkbox, 'Value')
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
        if exist([pwd '\' DATA.temp_rec_name4wfdb '.hea'], 'file')
            delete([pwd '\' DATA.temp_rec_name4wfdb '.hea']);
        end
        if exist([pwd '\' DATA.temp_rec_name4wfdb '.dat'], 'file')
            delete([pwd '\' DATA.temp_rec_name4wfdb '.dat']);
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
            DIRS.analyzedDataDirectory = [basepath filesep 'Examples'];
        end
        if isempty(EXT)
            EXT = 'mat';
        end
        [Peaks_FileName, PathName] = uigetfile( ...
            {'*.dat',  'WFDB Files (*.dat)'; ...
            '*.mat','MAT-files (*.mat)'; ...
            '*.txt','Text Files (*.txt)'}, ...
            'Open ECG File', [DIRS.analyzedDataDirectory filesep '*.' EXT]); %
        
        if ~isequal(Peaks_FileName, 0)
            %             DATA.qrs
            [~, DATA.PeaksFileName, ExtensionFileName] = fileparts(Peaks_FileName);
            ExtensionFileName = ExtensionFileName(2:end);
            
            DATA.peaks_file_name = [PathName, DATA.PeaksFileName];
            
            if strcmpi(ExtensionFileName, 'mat')
                QRS = load(DATA.peaks_file_name);
                DATA.qrs = QRS.Data;
                DATA.Fs = QRS.Fs;
                DATA.Mammal = QRS.Mammal;
                DATA.Integration = QRS.Integration;
                
                %                 QRS_field_names = fieldnames(QRS);
                %                 if ~isempty(regexpi(QRS_field_names{1}, 'data')) % |data
                %                     DATA.qrs = QRS.(QRS_field_names{1});
                %                 end
                if ~isempty(DATA.qrs)
                    if isfield(DATA, 'red_peaks_handle') && ishandle(DATA.red_peaks_handle) && isvalid(DATA.red_peaks_handle)
                        delete(DATA.red_peaks_handle);
                    end
                    DATA.red_peaks_handle = line(DATA.tm(DATA.qrs), DATA.sig(DATA.qrs, 1), 'Parent', GUI.ECGDataAxes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'LineWidth', 2);
                    uistack(DATA.red_peaks_handle, 'bottom');
                    
                    if isfield(DATA, 'RRInt_handle') && ishandle(DATA.RRInt_handle) && isvalid(DATA.RRInt_handle)
                        delete(DATA.RRInt_handle);
                    end                                                            
                    plot_rr_data();
                    
                    if isfield(GUI, 'red_rect') && ishandle(GUI.red_rect) && isvalid(GUI.red_rect)
                        delete(GUI.red_rect);
                    end                                                             
                    
                    plot_red_rectangle(DATA.zoom_rect_limits);
                    %                     GUI.PeaksTable.Data(1, 2) = {length(DATA.qrs)};
                else
                    errordlg('The algorithm could not run. Please, check input parameters.', 'Input Error');
                end
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
        
         if isfield(DATA, 'sig') && ~isempty(DATA.sig)
            cla(GUI.RRDataAxes); % RR_axes
            if(DATA.PlotHR == 1)
                set(GUI.RR_or_HR_plot_button, 'String', 'Plot HR');
                DATA.PlotHR = 0;                
            else
                set(GUI.RR_or_HR_plot_button, 'String', 'Plot RR');
                DATA.PlotHR = 1;                
            end
            plot_rr_data();
         end        
    end
%%
    function Reset_pushbutton_Callback(~, ~)
    end
%%
    function my_WindowButtonUpFcn (src, callbackdata, handles)
        set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
        refresh(GUI.Window);
        switch DATA.hObject
            case 'del_win_peaks'
                Del_win(get(GUI.del_rect, 'XData'));
                try
                    delete(GUI.del_rect);
                catch
                end
                set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
            otherwise
        end        
    end
%%
    function my_WindowButtonMotionFcn(src, callbackdata, type)        
        switch type
            case 'init'
                    if (hittest(GUI.Window) == DATA.RawDataHandle || get(hittest(GUI.Window), 'Parent') == DATA.RawDataHandle) % ECG data                        
                        setptr(GUI.Window, 'datacursor');
                        DATA.hObject = 'add_del_peak';
                    elseif (hittest(GUI.Window) == GUI.ECGDataAxes) %  || get(hittest(GUI.Window), 'Parent') == GUI.ECGDataAxes % white space, draw del rect
                        setptr(GUI.Window, 'ddrag');
                        DATA.hObject = 'del_win_peaks';
                    elseif hittest(GUI.Window) == GUI.red_rect  % || get(hittest(GUI.Window), 'Parent') == GUI.RRDataAxes  % GUI.red_rect
                        try
                            xdata = get(GUI.red_rect, 'XData');
                            point1 = get(GUI.RRDataAxes, 'CurrentPoint');
                            if point1(1, 1) >= 0 && point1(1, 1) <= max(get(GUI.RRDataAxes, 'XLim'))
                                if  point1(1,1) <= max(xdata) + DATA.eps && point1(1,1) >= max(xdata) - DATA.eps
                                    setptr(GUI.Window, 'lrdrag');
                                    DATA.hObject = 'right_resize';
                                elseif  point1(1,1) <= min(xdata) + DATA.eps && point1(1,1) >= min(xdata) - DATA.eps
                                    setptr(GUI.Window, 'lrdrag');
                                    DATA.hObject = 'left_resize';
                                else
                                    setptr(GUI.Window, 'arrow');
                                    DATA.hObject = 'overall';
                                end
                            end
                        catch
                        end
                    elseif hittest(GUI.Window) == GUI.RRDataAxes || get(hittest(GUI.Window), 'Parent') == GUI.RRDataAxes
                        xdata = get(GUI.red_rect, 'XData');
                        point1 = get(GUI.RRDataAxes, 'CurrentPoint');
                        if point1(1,1) < max(xdata) && point1(1,1) > min(xdata)
                            setptr(GUI.Window, 'hand');
                            DATA.hObject = 'zoom_rect_move';
                        else
                            setptr(GUI.Window, 'arrow');
                            DATA.hObject = 'overall';
                        end
                    else
                        setptr(GUI.Window, 'arrow');
                        DATA.hObject = 'overall';
                    end
            case 'window_move'
                Window_Resize('normal');
            case 'drag_del_rect'
                draw_rect_to_del_peaks();
            case 'right_resize_move'
                LR_Resize('right');
            case 'left_resize_move'
                LR_Resize('left');
            otherwise
        end
    end
%%
    function my_WindowButtonDownFcn(src, callbackdata, handles)
        prev_point = get(GUI.RRDataAxes, 'CurrentPoint');
        DATA.prev_point = prev_point;
        curr_point = get(GUI.ECGDataAxes, 'CurrentPoint');
        DATA.prev_point_ecg = curr_point;
        switch DATA.hObject
            case 'add_del_peak'
                Remove_Peak();
            case 'del_win_peaks'
                GUI.del_rect = line(curr_point(1, 1), curr_point(1, 2), 'Color', 'r', 'Linewidth', 1.5, 'LineStyle', ':', 'Parent', GUI.ECGDataAxes);
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
                        Window_Resize('open'); % double-click: show all data
                    otherwise
                end
            otherwise
        end
    end
%%
    function LR_Resize(type)
        xdata = get(GUI.red_rect, 'XData');
        xdata_saved = xdata;
        point1 = get(GUI.RRDataAxes, 'CurrentPoint');
        xofs = point1(1,1) - DATA.prev_point(1, 1);
        DATA.prev_point = point1(1, 1);
        
        RR_XLim = get(GUI.RRDataAxes,  'XLim');
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
        set(GUI.red_rect, 'XData', xdata);
        DATA.zoom_rect_limits = [xdata(1) xdata(2)];
    end
%%
    function Window_Resize(type)
        
        xdata = get(GUI.red_rect, 'XData');
        xdata_saved = xdata;
        point1 = get(GUI.RRDataAxes, 'CurrentPoint');        
        xofs = point1(1,1) - DATA.prev_point(1, 1);
        DATA.prev_point = point1(1, 1);
        
        RR_XLim = get(GUI.RRDataAxes,  'XLim');
        min_XLim = min(RR_XLim);
        max_XLim = max(RR_XLim);  
        
        switch type
            case 'normal'
                xdata = xdata + xofs;
            case 'open'
                xdata([1, 4, 5]) = 0;
                xdata([2, 3]) = DATA.maxRRTime;
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
        DATA.zoom_rect_limits = [xdata(1) xdata(2)];
    end
%%
    function draw_rect_to_del_peaks()
        point1 = get(GUI.ECGDataAxes, 'CurrentPoint');
        
        x_box = [DATA.prev_point_ecg(1, 1) DATA.prev_point_ecg(1, 1) point1(1, 1) point1(1, 1) DATA.prev_point_ecg(1, 1)];
        y_box = [DATA.prev_point_ecg(1, 2) point1(1, 2) point1(1, 2) DATA.prev_point_ecg(1, 2) DATA.prev_point_ecg(1, 2)];
        
        set(GUI.del_rect, 'XData', x_box, 'YData', y_box);
    end
%%
    function ChangePlot(xdata)                     
                      
%         linkaxes([GUI.ECGDataAxes, GUI.RRDataAxes], 'off');
        set(GUI.ECGDataAxes, 'XLim', [xdata(1) xdata(2)]); 
        setECGYLim(xdata(1), xdata(2));
%         linkaxes([GUI.ECGDataAxes, GUI.RRDataAxes], 'on');
                
%         DATA.firstSecond2Show = xdata(1);
%         DATA.MyWindowSize = xdata(2) - xdata(1);
%         
%         set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0));
%         set(GUI.WindowSize,'String', calcDuration(DATA.MyWindowSize, 0));
%         
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
        
        point1 = get(GUI.ECGDataAxes, 'CurrentPoint');
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
        
        red_peaks_x_data = DATA.red_peaks_handle.XData;
        
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
            temp_XData = [DATA.red_peaks_handle.XData, time_new_peak];
            temp_YData = [DATA.red_peaks_handle.YData, new_peak];
            
            [temp_XData, ind_sort] = sort(temp_XData);
            temp_YData = temp_YData(ind_sort);
            
            global_ind = find(DATA.tm == time_new_peak);
                        
            DATA.qrs = sort([DATA.qrs', global_ind])';            
            
            set(DATA.red_peaks_handle, 'XData', temp_XData, 'YData', temp_YData);
            
        else
            DATA.red_peaks_handle.XData(peak_ind) = [];
            DATA.red_peaks_handle.YData(peak_ind) = [];
            DATA.qrs(peak_ind) = [];
        end
        cla(GUI.RRDataAxes);
        plot_rr_data();
        plot_red_rectangle(DATA.zoom_rect_limits);
    end
%%
    function Del_win(range2del)        
        xlim = get(GUI.ECGDataAxes, 'XLim');
        
        if min(range2del) >= xlim(1) || max(range2del) <= xlim(2)
            red_peaks_x_data = DATA.red_peaks_handle.XData;
            peak_ind = find(red_peaks_x_data >= min(range2del) & red_peaks_x_data <= max(range2del));
            DATA.red_peaks_handle.XData(peak_ind) = [];
            DATA.red_peaks_handle.YData(peak_ind) = [];
            DATA.qrs(peak_ind) = [];
            cla(GUI.RRDataAxes);
            plot_rr_data();
            plot_red_rectangle(DATA.zoom_rect_limits);
        else
            disp('Not in range!');
        end        
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