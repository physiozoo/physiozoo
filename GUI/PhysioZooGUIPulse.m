function PhysioZooGUIPulse(fileNameFromM2, DataFileMapFromM2)


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
        GUI.red_peaks_handle_Filt = [];
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
        
        DATA.Integration = '';
        DATA.integration_index = 1;
        
        DATA.peakDetector = '';
        DATA.peakDetector_index = 1;
        
        DATA.config_map = containers.Map;
        DATA.config_struct = struct;
        DATA.customConfigFile = '';
        DATA.wfdb_record_name = '';
        
        DATA.PlotHR = 1;
        
        DATA.maxRRTime = 0;
        
        DATA.prev_point_ecg = 0;
        DATA.prev_point = 0;
        
        DATA.RRIntPage_Length = 0;
        
        DATA.quality_win_num = 0;
        DATA.rhythms_win_num = 0;
        
        DATA.rr_data_filtered = [];
        DATA.rr_time_filtered = [];
        
        DATA.Rhythms_Map = containers.Map('KeyType', 'double', 'ValueType', 'any');
        
        DATA.amp_counter = [];
    end
%%
    function clean_gui_low_part()
        
        if isfield(GUI, 'RRInt_Axes') && isvalid(GUI.RRInt_Axes)
            cla(GUI.RRInt_Axes); % RR_axes
        end
        
        if isfield(GUI, 'PinkLineHandle_AllDataAxes')
            delete(GUI.PinkLineHandle_AllDataAxes);
            GUI = rmfield(GUI, 'PinkLineHandle_AllDataAxes');
        end
        
        if isfield(GUI, 'RhythmsHandle_AllDataAxes')
            delete(GUI.RhythmsHandle_AllDataAxes);
            GUI = rmfield(GUI, 'RhythmsHandle_AllDataAxes');
        end
        set(GUI.GUIRecord.PeaksFileName_text, 'String', '');
        
        set(GUI.GUIDisplay.RRIntPage_Length, 'String', '');
        set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'String', '');
        set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'String', '');
        
        set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'UserData', []);
        set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'UserData', []);
        
        GUI.SavePeaks.Enable = 'off';
        GUI.AutoScaleYLowAxes_checkbox.Value = 1;
        
        DATA.peaks_added = 0;
        DATA.peaks_deleted = 0;
        DATA.peaks_total = 0;
        DATA.peaks_file_name = '';
        DATA.qrs = [];
        DATA.qrs_saved = [];
        GUI.PeaksTable.Data(:, 2) = {0};
    end
%%
    function clean_gui(clear_sm_files_names)
        
        pan(GUI.Window, 'off');
        zoom(GUI.Window, 'off');
        
        delete(GUI.graphs_panel_up_central.Children);
        
        if isfield(GUI, 'ECG_Axes') && isvalid(GUI.ECG_Axes)
            
            cla(GUI.ECG_Axes); % RawData_axes
            legend(GUI.ECG_Axes, 'off');
            title(GUI.ECG_Axes, '');
        end
        
        if isfield(GUI, 'quality_win')
            delete(GUI.quality_win);
            GUI = rmfield(GUI, 'quality_win');
        end
        
        if isfield(GUI, 'rhythms_win')
            delete(GUI.rhythms_win);
            GUI = rmfield(GUI, 'rhythms_win');
        end
        
        GUI.RhythmsListbox.String = '';
        GUI.RhythmsListbox.UserData = [];
        GUI.GUIDisplay.MinRhythmsRange_Edit.String = '';
        GUI.GUIDisplay.MaxRhythmsRange_Edit.String = '';
        GUI.GUIDisplay.MinRhythmsRange_Edit.UserData = [];
        GUI.GUIDisplay.MaxRhythmsRange_Edit.UserData = [];
        
        set(GUI.GUIRecord.RecordFileName_text, 'String', '');
        
        set(GUI.GUIRecord.DataQualityFileName_text, 'String', '');
        set(GUI.GUIRecord.RhythmsFileName_text, 'String', '');
        set(GUI.GUIRecord.Config_text, 'String', '');
        set(GUI.GUIRecord.TimeSeriesLength_text, 'String', '');
        
        set(GUI.GUIDisplay.FirstSecond, 'String', '');
        set(GUI.GUIDisplay.WindowSize, 'String', '');
        
        set(GUI.GUIDisplay.MinYLimit_Edit, 'String', '');
        set(GUI.GUIDisplay.MaxYLimit_Edit, 'String', '');
        
        set(GUI.GUIDisplay.MinYLimit_Edit, 'UserData', '');
        set(GUI.GUIDisplay.MaxYLimit_Edit, 'UserData', '');
        
        GUI.AutoPeakWin_checkbox.Value = 1;
        
        GUI.GUIRecord.Annotation_popupmenu.Value = 1;
        
        GUI.Adjustment_Text.String = 'Peak adjustmen';
        GUI.GUIRecord.PeakAdjustment_popupmenu.Value = 1;
        GUI.GUIRecord.PeakAdjustment_popupmenu.String = DATA.Adjustment_type;
        GUI.GUIRecord.PeakAdjustment_popupmenu.Callback = @PeakAdjustment_popupmenu_Callback;
        
        set(GUI.GUIRecord.Mammal_popupmenu, 'String', '');
        set(GUI.GUIRecord.PeakDetector_popupmenu, 'Value', 1);
        
        GUI.LoadConfigurationFile.Enable = 'off';
        GUI.SaveConfigurationFile.Enable = 'off';
        
        GUI.SaveRhythms.Enable = 'off';
        GUI.OpenRhythms.Enable = 'off';
        
        GUI.SaveFiducials.Enable = 'off';
        GUI.SaveFiducialsStat.Enable = 'off';
        
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
        setptr(GUI.Window, 'arrow');
        DATA.hObject = 'overall';
        
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
        
        GridX_checkbox_Callback();
        
        GUI.FilteredSignal_checkbox.Value = 0;
        GUI.GUIDisplay.FilterLevel_popupmenu.Value = 1;
        GUI.FilterLevelBox.Visible = 'off';
        GUI.CutoffFrBox.Visible = 'off';
        
        set_default_filter_level_user_data();
        
        reset_rhythm_button();
        GUI.RhythmsHBox.Visible = 'off';
        Rhythms_ToggleButton_Reset();
        
        if isfield(GUI, 'RawChannelsData_handle')
            GUI = rmfield(GUI, 'RawChannelsData_handle');
        end
        if ~clear_sm_files_names
            GUI.GUIDir.DirName_text.String = '';
            GUI.GUIDir.FileList.String = '';
        end
        
        GUI.ChannelsTable.UserData = [];
        GUI.offset_array = [];
        try
            delete(GUI.FilteredData_handle);
            GUI = rmfield(GUI, 'FilteredData_handle');
        catch
        end
        try
            GUI.ChannelsTable.Data(:, 2) = false;
            GUI.ChannelsTable.Data(:, 3) = false;
            GUI.ChannelsTable.Data(:, 4) = false;
        catch
            GUI.ChannelsTable.Data(:, 2) = {false};
            GUI.ChannelsTable.Data(:, 3) = {false};
            GUI.ChannelsTable.Data(:, 4) = {false};
        end
        
        GUI.GUIDir.FileName2Split.String = '';
        GUI.GUIDir.Split_Sec.String = DATA.Small_File_Length_Sec;
        GUI.GUIDir.Split_Sec.UserData = DATA.Small_File_Length_Sec;
        
        clear_fiducials_handles();
        clear_fiducials_filt_handles();
        reset_fiducials_checkboxs();
        
        if isfield(GUI, 'RRInt_detrended_handle')
            delete(GUI.RRInt_detrended_handle);
            GUI = rmfield(GUI, 'RRInt_detrended_handle');
        end
        if isfield(GUI, 'RRInt_filtered_handle')
            delete(GUI.RRInt_filtered_handle);
            GUI = rmfield(GUI, 'RRInt_filtered_handle');
        end
        GUI.GridX_checkbox.Value = 1;
        GUI.GridY_checkbox.Value = 1;
        
        GUI.TrendHR_checkbox.Value = 1;
        GUI.FilterHR_checkbox.Value = 0;
        GUI.GridYHR_checkbox.Value = 1;
        
        GUI.DurationTable.Data = {};
        GUI.DurationTable.RowName = {};
        GUI.DurationTable.ColumnName = {'Description'; 'Mean'; 'Median'; 'Min'; 'Max'; 'IQR'; 'STD'};
        
        GUI.AmplitudeTable.Data = {};
        GUI.AmplitudeTable.RowName = {};
        GUI.AmplitudeTable.ColumnName = {'Description'; 'Mean'; 'Median'; 'Min'; 'Max'; 'IQR'; 'STD'};
        
        GUI.PQRST_position = {};
        GUI.RawSignal_checkbox.Value = 1;
        
        if isfield(GUI, 'pebm_waves_table')
            GUI = rmfield(GUI, 'pebm_waves_table');
        end
        if isfield(GUI, 'pebm_intervals_table')
            GUI = rmfield(GUI, 'pebm_intervals_table');
        end
        GUI.pebm_intervals_stat = {};
        GUI.pebm_waves_stat = {};
        
        GUI.pebm_intervalsData = {};
        GUI.pebm_wavesData = {};
        
        %         GUI.pebm_waves_table = {};
        %         GUI.pebm_intervals_table = {};
        
        GUI.BandpassFilter_checkbox.Value = 1;
        GUI.GUIConfig.NotchFilter_popupmenu.Value = 1;
        
        GUI.PPGFilter_checkbox.Value = 1;
        GUI.GUIConfig.Order.String = '';
        GUI.GUIConfig.Order.UserData = '';
        GUI.GUIConfig.PPG_Filt_Low_Edit.String = '';
        GUI.GUIConfig.PPG_Filt_Low_Edit.UserData = '';
        GUI.GUIConfig.PPG_Filt_Hight_Edit.String = '';
        GUI.GUIConfig.PPG_Filt_Hight_Edit.UserData = '';
        
        GUI.RawData_lines_handle = gobjects;
        GUI.ch_name_handles = gobjects;
    end
%%
    function DATA = createData()
        
        DATA.screensize = get( 0, 'Screensize' );
        
        %                 DEBUGGING MODE - Small Screen
        %         DATA.screensize = [0 0 1250 800];
        
        DATA.window_size = [DATA.screensize(3)*0.99 DATA.screensize(4)*0.85];
        
        if DATA.screensize(3) < 1530 %1080 % 1920
            DATA.BigFontSize = 9;
            DATA.SmallFontSize = 9;
            DATA.SmallScreen = 1;
        else
            DATA.BigFontSize = 10;
            DATA.SmallFontSize = 10;
            DATA.SmallScreen = 0;
        end
        
        DATA.mammals = {'human', 'dog', 'rabbit', 'mouse', 'default'};
        %         DATA.mammals = {'', 'human', 'dog', 'rabbit', 'mouse', 'custom'};
        %         DATA.GUI_mammals = {'Please, choose mammal'; 'Human'; 'Dog'; 'Rabbit'; 'Mouse'; 'Custom'};
        %         DATA.mammal_index = 1;
        
        DATA.Integration_From_Files = {'electrocardiogram'; 'electrogram'; 'photoplethysmogram'}; % ; 'action potential'
        DATA.GUI_Integration = {'ECG'; 'Electrogram'; 'PPG'}; % ; 'Action Potential'
        DATA.integration_level = {'ecg'; 'electrogram'; 'ppg'}; % ; 'ap'
        
        DATA.GUI_PeakDetector = {'rqrs'; 'jqrs'; 'wjqrs'; 'egmbeat'; 'PPGdet'}; % 'EGM peaks'
        DATA.peakDetector_index = 1;
        
        DATA.GUI_Annotation = {'Peak'; 'Signal quality'; 'Rhythms'};
        DATA.GUI_Class = {'A'; 'B'; 'C'};
        DATA.Adjustment_type = {'Default'; 'Local max'; 'Local min'};
        DATA.Rhythms_Type = {'AB'; 'AFIB'; 'AFL'; 'SVTA';...
            'B'; 'T'; 'IVR'; 'VFL'; 'VT';...
            'SBR'; 'BII'; 'NOD';...
            'P'; 'PREX';...
            'J'; 'PAT'; 'AT'; 'SVT'; 'AIVRS'; 'IVRS'; 'AIVR'}; % 'N'
        
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
            'Paroxysmal Atrial Tachycardia'; ...
            ''; ...
            'Supraventricular Tachycardia'; ...
            ''; ...
            ''; ...
            'Accelerated Idioventricular Rhythm'};
        
        DATA.temp_rec_name4wfdb = 'temp_ecg_wfdb';
        
        DATA.Spacing = 3;
        DATA.Padding = 3;
        
        DATA.firstZoom = 60; % sec
        DATA.zoom_rect_limits = [0 DATA.firstZoom];
        
        DATA.Ch_Colors = {[75 75 75]/255; ...
            [200 0 0]/255; ...
            [0 200 0]/255};
        
        DATA.Small_File_Length_Sec = 3600; % 3600
        
        DATA.amp_counter = [];
        DATA.amp_ch_factor = 1.05;
        
        DATA.Module = 'M1';
    end
%% Open the window
    function GUI = createInterface()
        SmallFontSize = DATA.SmallFontSize;
        BigFontSize = DATA.BigFontSize;
        GUI = struct();
        GUI.Window = figure( ...
            'Name', 'PhysioZoo_Pulse', ...
            'NumberTitle', 'off', ...
            'HandleVisibility', 'callback', ...
            'Toolbar', 'none', ...
            'MenuBar', 'none', ...
            'Position', [20, 50, DATA.window_size(1), DATA.window_size(2)], ...
            'Tag', 'fPhysioZooPD');
        
        set(GUI.Window, 'CloseRequestFcn', {@Exit_Callback});
        
        setLogo(GUI.Window, DATA.Module);
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
        
        try
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
            
            GUI.OpenRhythms = uimenu( GUI.FileMenu, 'Label', 'Open rhythm file', 'Callback', @OpenRhythms_Callback, 'Accelerator', 'R', 'Separator', 'on');
            GUI.SaveRhythms = uimenu( GUI.FileMenu, 'Label', 'Save rhythm file', 'Callback', @SaveRhythms_Callback, 'Accelerator', 'T');
            
            GUI.SaveFiducials = uimenu(GUI.FileMenu, 'Label', 'Save fiducial points', 'Callback', @SaveFiducialsPoints_Callback, 'Separator', 'on', 'Accelerator', 'F');
            GUI.SaveFiducialsStat = uimenu(GUI.FileMenu, 'Label', 'Save fiducial biomarkers', 'Callback', @SaveFiducialsStat_Callback, 'Accelerator', 'M');
            
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
            
            upper_part = 0.75; % 0.8 0.55
            low_part = 1 - upper_part;
            set(mainLayout, 'Heights', [(-1)*upper_part, (-1)*low_part]);
            
            % + Upper Panel - Left and Right Parts
            temp_panel_left = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding);
            GUI.graphs_panel_up_central = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding); % , 'BorderType', 'none'
            temp_panel_buttons = uix.Panel( 'Parent', Upper_Part_Box, 'Padding', DATA.Padding); % , 'BorderType', 'none'
            
            temp_vbox_buttons = uix.VBox( 'Parent', temp_panel_buttons, 'Spacing', DATA.Spacing);
            
            if DATA.SmallScreen
                left_part = 0.48; % 0.4
                set(Upper_Part_Box, 'Widths', [-29 -55 -13]);
                Left_Part_widths_in_pixels = 0.3 * DATA.window_size(1); % 0.3
            else
                left_part = 0.285;  % 0.285  %0.265
                set(Upper_Part_Box, 'Widths', [-27 -55 -10.5]); % [-29.5 -65 -10.5]
                Left_Part_widths_in_pixels = 0.3 * DATA.window_size(1); % 0.3
            end
            right_part = 0.99; % 0.9
            buttons_part = 0.08; % 0.08
            %         Left_Part_widths_in_pixels = 0.3 * DATA.window_size(1); % 0.3
            
            %         set(Upper_Part_Box, 'Widths', [-1*left_part -1*right_part -1*buttons_part]);
            %         set(Upper_Part_Box, 'Widths', [-25.5 -64 -10.5]);
            
            GUI.RightLeft_TabPanel = uix.TabPanel('Parent', temp_panel_left, 'Padding', DATA.Padding);
            %             two_axes_box = uix.VBox('Parent', GUI.graphs_panel_up_central, 'Spacing', DATA.Spacing);
            CommandsButtons_Box = uix.VButtonBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top'); %
            
            GUI.ChannelsTable = uitable('Parent', temp_vbox_buttons, 'FontSize', SmallFontSize, 'FontName', 'Calibri', 'Tag', 'ChannelsTable',...
                'ColumnName', {'Ch.', 'Disp.', 'D.Filt.', 'D.Fiducials'}, 'ColumnEditable', [false true true true], 'RowStriping', 'on', ...
                'CellEditCallback', @ChannelsTableEditCallback, 'CellSelectionCallback', @ChannelsTableSelectionCallback);
            GUI.ChannelsTable.RowName = {};
            GUI.ChannelsTable.ColumnWidth = {30, 35, 40, 58};
            %--------------------------------------
            amp_box = uix.VBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'Padding', DATA.Padding);
            
            AmpPlusMinusHButtons_Box = uix.HButtonBox('Parent', amp_box, 'Spacing', DATA.Spacing);
            GUI.ChAmpDecreaseButton = uicontrol('Style', 'PushButton', 'Parent', AmpPlusMinusHButtons_Box, 'Callback', @amp_plus_minus_pushbutton_Callback,...
                'FontSize', BigFontSize, 'String', sprintf('\x25BE'), 'Tooltip', 'Decrease channel amplitude', 'UserData', 'minus'); % sprintf('\x25A0') 25B2
            
            GUI.ChAmpSourceButton = uicontrol('Style', 'PushButton', 'Parent', AmpPlusMinusHButtons_Box, 'Callback', @amp_plus_minus_pushbutton_Callback,...
                'FontSize', BigFontSize, 'String', sprintf('\x003D'), 'Tooltip', 'Source channel amplitude', 'UserData', 'source'); % sprintf('\x25A0') 25B2
            
            GUI.ChAmpIncreaseButton = uicontrol('Style', 'PushButton', 'Parent', AmpPlusMinusHButtons_Box, 'Callback', @amp_plus_minus_pushbutton_Callback,...
                'FontSize', BigFontSize, 'String', sprintf('\x25B4'), 'Tooltip', 'Increase channel amplitude', 'UserData', 'plus'); % sprintf('\x25A0') 25B2
            
            %-----------------------------------------
            FiducialsStartTimeBox = uix.HBox('Parent', amp_box, 'Spacing',DATA.Spacing);
            aa{1} = uicontrol('Style', 'text', 'Parent', FiducialsStartTimeBox, 'String', 'W. S.', 'FontSize', SmallFontSize-0.5, 'HorizontalAlignment', 'left');
            GUI.Fiducials_winStart = uicontrol('Style', 'edit', 'Parent', FiducialsStartTimeBox, 'FontSize', SmallFontSize-0.5, 'Callback', @Fiducials_winStartLength_Edit_Callback, 'Tag', 'Fiducials_startTime');
            uicontrol('Style', 'text', 'Parent', FiducialsStartTimeBox, 'String', 'h:min:sec', 'FontSize', SmallFontSize-1, 'HorizontalAlignment', 'left');
            
            FiducialWindowLengthBox = uix.HBox( 'Parent', amp_box, 'Spacing', DATA.Spacing);
            aa{2} = uicontrol( 'Style', 'text', 'Parent', FiducialWindowLengthBox, 'String', 'W. L.', 'FontSize', SmallFontSize-0.5, 'HorizontalAlignment', 'left');
            GUI.Fiducials_winLength = uicontrol( 'Style', 'edit', 'Parent', FiducialWindowLengthBox, 'FontSize', SmallFontSize-0.5, 'Callback', @Fiducials_winStartLength_Edit_Callback, 'Tag', 'Fiducials_winLength');
            uicontrol( 'Style', 'text', 'Parent', FiducialWindowLengthBox, 'String', 'h:min:sec', 'FontSize', SmallFontSize-1, 'HorizontalAlignment', 'left');
            
            max_extent_control = calc_max_control_x_extend(aa);
            
            field_size = [max_extent_control, -4.5, -4];
            
            set(FiducialsStartTimeBox, 'Widths', field_size);
            set(FiducialWindowLengthBox, 'Widths', field_size);
            
            set(amp_box, 'Heights', [-3 -1 -1]);
            %-----------------------------------------
            
            peaks_box = uix.VBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'Padding', DATA.Padding);
            GUI.P_checkbox = uicontrol('Style', 'Checkbox', 'Parent', peaks_box, 'Callback', @PQRST_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'P-Peaks', 'Value', 0, 'Tag', 'PPeaksCb');
            GUI.Q_checkbox = uicontrol('Style', 'Checkbox', 'Parent', peaks_box, 'Callback', @PQRST_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'Q-Peaks (QRS on)', 'Value', 0, 'Tag', 'QPeaksCb');
            GUI.R_checkbox = uicontrol('Style', 'Checkbox', 'Parent', peaks_box, 'Callback', @PQRST_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'R-Peaks', 'Value', 1, 'Tag', 'RPeaksCb');
            GUI.S_checkbox = uicontrol('Style', 'Checkbox', 'Parent', peaks_box, 'Callback', @PQRST_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'S-Peaks (QRS off)', 'Value', 0, 'Tag', 'SPeaksCb');
            GUI.T_checkbox = uicontrol('Style', 'Checkbox', 'Parent', peaks_box, 'Callback', @PQRST_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'T-Peaks', 'Value', 0, 'Tag', 'TPeaksCb');
            
            GUI.P_checkbox.ForegroundColor = [0.9290, 0.6940, 0.1250];
            GUI.Q_checkbox.ForegroundColor = [0.4940, 0.1840, 0.5560];
            GUI.R_checkbox.ForegroundColor = [1 0 0];
            GUI.S_checkbox.ForegroundColor = [0.8500, 0.3250, 0.0980];
            GUI.T_checkbox.ForegroundColor = [0.6350, 0.0780, 0.1840];
            
            % ------------------------
            
            play_box = uix.VButtonBox('Parent', temp_vbox_buttons, 'Spacing', DATA.Spacing, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Padding', DATA.Padding); %
            
            GUI.CalcPeaksButton_handle = uicontrol('Style', 'PushButton', 'Parent', play_box, 'String', 'Find Fiducials', 'FontSize', DATA.SmallFontSize,...
                'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Enable', 'inactive', 'Tag', 'CalcPQRSTPeaks', 'Callback', @CalcPQRSTPeaks);
            %on' | 'off' | 'inactive'
            
            %             set(fp_box, 'ButtonSize', [110, 25], 'Spacing', DATA.Spacing);
            
            
            
            %         set(temp_vbox_buttons, 'Heights', [-100, -35]);
            
            RecordTab = uix.Panel('Parent', GUI.RightLeft_TabPanel, 'Padding', DATA.Padding);
            DirectoryTab = uix.Panel('Parent', GUI.RightLeft_TabPanel, 'Padding', DATA.Padding);
            ConfigParamTab = uix.Panel('Parent', GUI.RightLeft_TabPanel, 'Padding', DATA.Padding);
            DisplayTab = uix.Panel('Parent', GUI.RightLeft_TabPanel, 'Padding', DATA.Padding);
            
            GUI.RightLeft_TabPanel.TabTitles = {'Record', 'Folder', 'Configuration', 'Display'};
            GUI.RightLeft_TabPanel.FontSize = BigFontSize;
            
            if DATA.SmallScreen
                GUI.RightLeft_TabPanel.TabWidth = 80; % 100
            else
                GUI.RightLeft_TabPanel.TabWidth = 90; % 100
            end
            
            %--------------------------------------------------------------------
            
            two_axes_box = uix.VBox('Parent', GUI.graphs_panel_up_central, 'Spacing', DATA.Spacing);
            
            GUI.ECG_Axes = axes('Parent', uicontainer('Parent', two_axes_box), 'Tag', 'GUI.ECG_Axes');
            GUI.RRInt_Axes = axes('Parent', uicontainer('Parent', two_axes_box), 'Tag', 'GUI.RRInt_Axes');
            
            set(two_axes_box, 'Heights', [-7, -3]);
            
            %--------------------------------------------------------------------
            
            %             [GUI.ECG_Axes, GUI.RRInt_Axes] = create_graphs_panel(GUI.graphs_panel_up_central, DATA.Spacing);
            
            %--------------------------------------------------------------------
            
            GUI.AutoCompute_pushbutton = uicontrol('Style', 'PushButton', 'Parent', CommandsButtons_Box, 'Callback', @AutoCompute_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'Compute', 'Enable', 'off');
            GUI.AutoCalc_checkbox = uicontrol('Style', 'Checkbox', 'Parent', CommandsButtons_Box, 'Callback', @AutoCalc_checkbox_Callback, 'FontSize', SmallFontSize-1, 'String', 'Auto Compute', 'Value', 1);
            
            GUI.RR_or_HR_plot_button = uicontrol('Style', 'ToggleButton', 'Parent', CommandsButtons_Box, 'Callback', @RR_or_HR_plot_button_Callback, 'FontSize', BigFontSize, 'String', 'Plot RR', 'Value', 1);
            GUI.Reset_pushbutton = uicontrol('Style', 'PushButton', 'Parent', CommandsButtons_Box, 'Callback', @Reset_pushbutton_Callback, 'FontSize', BigFontSize, 'String', 'Reset');
            set(CommandsButtons_Box, 'ButtonSize', [110, 25], 'Spacing', DATA.Spacing); % [70, 25]
            
            %             GUI.Rhythms_handle = uicontrol('Style', 'PushButton', 'Parent', play_box, 'String', 'Rhythms', 'FontSize', DATA.SmallFontSize,...
            %                 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Enable', 'inactive');
            GUI.Rhythms_handle = uicontrol('Style', 'PushButton', 'Parent', play_box, 'String', 'ArNet2', 'FontSize', DATA.SmallFontSize,...
                'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Enable', 'inactive', 'Callback', @ArNet2_pushbutton_Callback);
            
            MovieStartStioHButtons_Box = uix.HButtonBox('Parent', play_box, 'Spacing', DATA.Spacing); % , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom'
            GUI.PlayStopReverseMovieButton = uicontrol('Style', 'ToggleButton', 'Parent', MovieStartStioHButtons_Box, 'Callback', @play_stop_reverse_movie_pushbutton_Callback,...
                'FontSize', BigFontSize, 'String', sprintf('\x25C4'), 'Enable', 'inactive', 'Tooltip', 'Start/Stop scrolling (reverse)'); % sprintf('\x25A0') 25B2
            GUI.PlayStopForwMovieButton = uicontrol('Style', 'ToggleButton', 'Parent', MovieStartStioHButtons_Box, 'Callback', @play_stop_movie_pushbutton_Callback,...
                'FontSize', BigFontSize, 'String', sprintf('\x25BA'), 'Enable', 'inactive', 'Tooltip', 'Start/Stop scrolling (forward)'); % sprintf('\x25A0') 25B2
            
            % Black Right-Pointing Pointer
            %         Black Left-Pointing Pointer
            
            PageUpDownButtons_Box = uix.HButtonBox('Parent', play_box, 'Spacing', DATA.Spacing); % , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom'
            GUI.PageDownButton = uicontrol('Style', 'PushButton', 'Parent', PageUpDownButtons_Box, 'Callback', {@page_down_pushbutton_Callback, ''}, 'FontSize', BigFontSize, 'String', sprintf('\x25C0'), 'Enable', 'off');  % 2190'
            GUI.PageUpButton = uicontrol('Style', 'PushButton', 'Parent', PageUpDownButtons_Box, 'Callback', {@page_up_pushbutton_Callback, ''}, 'FontSize', BigFontSize, 'String', sprintf('\x25B6'), 'Enable', 'off');  % 2192
            set(PageUpDownButtons_Box, 'ButtonSize', [70, 25], 'Spacing', DATA.Spacing);
            set(MovieStartStioHButtons_Box, 'ButtonSize', [70, 25], 'Spacing', DATA.Spacing);
            set(play_box, 'ButtonSize', [110, 25], 'Spacing', DATA.Spacing); % [70, 25]
            
            GUI.CommandsButtons_Box = CommandsButtons_Box;
            GUI.PageUpDownButtons_Box = PageUpDownButtons_Box;
            
            tabs_widths = Left_Part_widths_in_pixels;
            tabs_heights = 600; % 525
            
            RecordSclPanel = uix.ScrollingPanel( 'Parent', RecordTab);
            RecordBox = uix.VBox( 'Parent', RecordSclPanel, 'Spacing', DATA.Spacing);
            set(RecordSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
            
            DirSclPanel = uix.ScrollingPanel( 'Parent', DirectoryTab);
            DirBox = uix.VBox( 'Parent', DirSclPanel, 'Spacing', DATA.Spacing);
            set(DirSclPanel, 'Widths', tabs_widths, 'Heights', tabs_heights );
            
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
            % Folder Tab
            
            [GUI, textBox{1}, text_handles{1}] = createGUITextLine(GUI, 'GUIDir', 'DirName_text', 'Folder name:', DirBox, 'text', 1, @OpenDir_Callback);
            GUI.GUIDir.DirName_text_pushbutton_handle.Enable = 'on';
            
            textBox{2} = uix.HBox('Parent', DirBox, 'Spacing', DATA.Spacing);
            text_handles{2} = uicontrol('Style', 'text', 'Parent', textBox{2}, 'String', 'File list:', ...
                'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.GUIDir.FileList = uicontrol('Style', 'listbox', 'Parent', textBox{2}, 'FontSize', ...
                DATA.SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.GUIDir.FileList.Callback = @FileList_listbox_callback;
            uix.Empty('Parent', textBox{2});
            
            uix.Empty('Parent', DirBox);
            
            textBox{3} = uix.HBox('Parent', DirBox, 'Spacing', DATA.Spacing);
            text_handles{3} = uicontrol('Style', 'text', 'Parent', textBox{3}, 'String', 'Split file ', ...
                'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.GUIDir.FileName2Split = uicontrol('Style', 'text', 'Parent', textBox{3}, 'FontSize', DATA.SmallFontSize, 'String', '', 'HorizontalAlignment', 'left');
            uicontrol('Style', 'text', 'Parent', textBox{3}, 'String', 'to', ...
                'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
            
            textBox{4} = uix.HBox('Parent', DirBox, 'Spacing', DATA.Spacing);
            text_handles{4} = uicontrol('Style', 'text', 'Parent', textBox{4}, 'String', 'Sections of ', ...
                'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.GUIDir.Split_Sec = uicontrol('Style', 'edit', 'Parent', textBox{4}, 'Callback', @Split_Sec_Callback, ...
                'FontSize', DATA.SmallFontSize, 'Tag', 'Split_sec', 'UserData', DATA.Small_File_Length_Sec, 'String', DATA.Small_File_Length_Sec);
            uicontrol('Style', 'text', 'Parent', textBox{4}, 'String', 'sec', ...
                'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
            
            textBox{5} = uix.HBox('Parent', DirBox, 'Spacing', DATA.Spacing);
            uix.Empty('Parent', textBox{5});
            uicontrol('Style', 'PushButton', 'Parent', textBox{5}, 'Callback', @SplitFile_Button_Callback, ...
                'FontSize', DATA.SmallFontSize, 'String', 'Split');
            uix.Empty('Parent', textBox{5});
            
            uix.Empty('Parent', DirBox);
            
            
            max_extent_control = calc_max_control_x_extend(text_handles);
            
            if DATA.SmallScreen
                field_size = [max_extent_control, 200, 25];
            else
                field_size = [max_extent_control, 270, 25];
            end
            for i =  1 : 5
                set(textBox{i}, 'Widths', field_size);
            end
            
            %         if DATA.SmallScreen
            %             hf = -0.45;
            %             set(DirBox, 'Heights', [hf * ones(1, 2), -4] );
            %         else
            %             hf = -1;
            %             set(DirBox, 'Heights', [-0.9, -7, -0.7, -0.7, -0.7, -0.7, -7]);
            set(DirBox, 'Heights', [-1, -7, -1, -1, -1, -1 -8]);
            %         end
            
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
            
            GUI.Adjust_textBox = textBox{11};
            GUI.Adjustment_Text = text_handles{11};
            GUI.Adjustment_Text.Visible = 'on';
            
            max_extent_control = calc_max_control_x_extend(text_handles);
            
            field_size = [max_extent_control, -1, 1];
            for i = 6 : 6
                set(textBox{i}, 'Widths', field_size);
            end
            
            if DATA.SmallScreen
                field_size1 = [max_extent_control, -0.47, -0.5]; % -0.56, -0.2 -0.55
            else
                field_size1 = [max_extent_control, -0.4, -0.55]; % + 5 % -0.45, -0.5
            end
            
            for i = 7 : 11 % 13
                set(textBox{i}, 'Widths', field_size1);
            end
            
            popupmenu_position = get(GUI.GUIRecord.Mammal_popupmenu, 'Position');
            
            if DATA.SmallScreen
                field_size = [max_extent_control, popupmenu_position(3) + 50, 25];
            else
                field_size = [max_extent_control, popupmenu_position(3) + 94, 25];
            end
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
            if DATA.SmallScreen
                set(Rhythms_grid, 'Widths', 34*ones(1, 3), 'Heights', -1*ones(1, length(DATA.Rhythms_Type)/3)); % 34
            else
                set(Rhythms_grid, 'Widths', 39*ones(1, 3), 'Heights', -1*ones(1, length(DATA.Rhythms_Type)/3)); % 60
            end
            
            set(GUI.RhythmsHBox, 'Widths', field_size1);
            
            if DATA.SmallScreen
                hf = -0.12; % -0.1
                %             uix.Empty( 'Parent', RecordBox);
                set(RecordBox, 'Heights', [hf * ones(1, 11), -1]);
            else
                hf = -0.12; % -0.155
                set(RecordBox, 'Heights', [hf * ones(1, 11), -0.9]);
            end
            
            load_config_name_button_position = get(GUI.GUIRecord.Config_text_pushbutton_handle, 'Position');
            updated_position = [load_config_name_button_position(1) load_config_name_button_position(2) + 10 load_config_name_button_position(3) load_config_name_button_position(4) - 10];
            set(GUI.GUIRecord.RecordFileName_text_pushbutton_handle, 'Position', updated_position, 'Enable', 'on');
            set(GUI.GUIRecord.PeaksFileName_text_pushbutton_handle, 'Position', updated_position);
            set(GUI.GUIRecord.Config_text_pushbutton_handle, 'Position', updated_position);
            set(GUI.GUIRecord.DataQualityFileName_text_pushbutton_handle, 'Position', updated_position);
            set(GUI.GUIRecord.RhythmsFileName_text_pushbutton_handle, 'Position', updated_position);
            
            GUI.Adjust_textBox_position = get(GUI.Adjust_textBox, 'Position');
            %         GUI.Class_textBox_position = get(GUI.Class_textBox, 'Position');
            %         GUI.Rhythms_textBox_position = get(GUI.Rhythms_textBox, 'Position');
            %         GUI.RhythmsHBox_position = get(GUI.RhythmsHBox, 'Position');
            
            
            %         set(GUI.RhythmsHBox, 'Position', GUI.Class_textBox_position);
            %         get(GUI.RhythmsHBox, 'Position')
            %-------------------------------------------------------
            % Config Params Tab
            
            %         field_size = [80, 150, 10 -1];
            
            uicontrol( 'Style', 'text', 'Parent', GUI.ConfigBox, 'String', 'rqrs', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
            
            %         uix.Empty( 'Parent', GUI.ConfigBox );
            
            [GUI, textBox{1}, text_handles{1}] = createGUISingleEditLine(GUI, 'GUIConfig', 'HR', 'HR', 'BPM', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'HR', BigFontSize-0.5);
            [GUI, textBox{2}, text_handles{2}] = createGUISingleEditLine(GUI, 'GUIConfig', 'QS', 'QS', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'QS', BigFontSize-0.5);
            [GUI, textBox{3}, text_handles{3}] = createGUISingleEditLine(GUI, 'GUIConfig', 'QT', 'QT', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'QT', BigFontSize-0.5);
            [GUI, textBox{4}, text_handles{4}] = createGUISingleEditLine(GUI, 'GUIConfig', 'QRSa', 'QRSa', 'microVolts', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'QRSa', BigFontSize-0.5);
            [GUI, textBox{5}, text_handles{5}] = createGUISingleEditLine(GUI, 'GUIConfig', 'QRSamin', 'QRSamin', 'microVolts', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'QRSamin', BigFontSize-0.5);
            [GUI, textBox{6}, text_handles{6}] = createGUISingleEditLine(GUI, 'GUIConfig', 'RRmin', 'RRmin', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'RRmin', BigFontSize-0.5);
            [GUI, textBox{7}, text_handles{7}] = createGUISingleEditLine(GUI, 'GUIConfig', 'RRmax', 'RRmax', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'RRmax', BigFontSize-0.5);
            
            %             uix.Empty('Parent', GUI.ConfigBox );
            
            uicontrol( 'Style', 'text', 'Parent', GUI.ConfigBox, 'String', 'jqrs/wjqrs', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
            [GUI, textBox{8}, text_handles{8}] = createGUISingleEditLine(GUI, 'GUIConfig', 'lcf', 'Lower cutoff frequency', 'Hz', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'lcf', BigFontSize-0.5);
            [GUI, textBox{9}, text_handles{9}] = createGUISingleEditLine(GUI, 'GUIConfig', 'hcf', 'Upper cutoff frequency', 'Hz', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'hcf', BigFontSize-0.5);
            [GUI, textBox{10}, text_handles{10}] = createGUISingleEditLine(GUI, 'GUIConfig', 'thr', 'Threshold', 'n.u.', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'thr', BigFontSize-0.5);
            [GUI, textBox{11}, text_handles{11}] = createGUISingleEditLine(GUI, 'GUIConfig', 'rp', 'Refractory period', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'rp', BigFontSize-0.5);
            [GUI, textBox{12}, text_handles{12}] = createGUISingleEditLine(GUI, 'GUIConfig', 'ws', 'Window size', 'sec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'ws', BigFontSize-0.5);
            
            %             uix.Empty('Parent', GUI.ConfigBox );
            
            % ORI's algorithm for EGM peaks
            uicontrol( 'Style', 'text', 'Parent', GUI.ConfigBox, 'String', 'egmbeat', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
            [GUI, textBox{13}, text_handles{13}] = createGUISingleEditLine(GUI, 'GUIConfig', 'ref_per', 'Refractory period', 'msec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'ref_per', BigFontSize-0.5);
            [GUI, textBox{14}, text_handles{14}] = createGUISingleEditLine(GUI, 'GUIConfig', 'bi', 'Average BI', 'msec', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'bi', BigFontSize-0.5);
            
            [GUI, textBox{15}, text_handles{15}] = createGUISingleEditLine(GUI, 'GUIConfig', 'init_prom_thresh', 'Initial prominence threshold', '%', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'init_prom_thresh', BigFontSize-0.5);
            [GUI, textBox{16}, text_handles{16}] = createGUISingleEditLine(GUI, 'GUIConfig', 'classify_prom_thresh', 'Clasifying prominence threshold', '%', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'classify_prom_thresh', BigFontSize-0.5);
            
            %             [GUI, textBox{15}, text_handles{15}] = createGUISingleEditLine(GUI, 'GUIConfig', 'prom_thresh1', 'Prominence threshold 1', '%', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'prom_thresh1');
            %             [GUI, textBox{16}, text_handles{16}] = createGUISingleEditLine(GUI, 'GUIConfig', 'prom_thresh2', 'Prominence threshold 2', '%', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'prom_thresh2');
            
            %             uix.Empty('Parent', GUI.ConfigBox );
            
            GUI.AutoPeakWin_checkbox = uicontrol('Style', 'Checkbox', 'Parent', GUI.ConfigBox, 'FontSize', BigFontSize, 'String', 'Auto', 'Value', 1);
            [GUI, textBox{17}, text_handles{17}] = createGUISingleEditLine(GUI, 'GUIConfig', 'PeaksWindow', 'Peaks window', 'ms', GUI.ConfigBox, @Peaks_Window_edit_Callback, '', 'peaks_window', BigFontSize-0.5);
            
            uicontrol( 'Style', 'text', 'Parent', GUI.ConfigBox, 'String', 'Fiducials ECG filtering parameters', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
            GUI.BandpassFilter_checkbox = uicontrol('Style', 'Checkbox', 'Parent', GUI.ConfigBox, 'FontSize', BigFontSize-0.5, 'String', 'Bandpass filter', 'Value', 1);
            
            [GUI, textBox{18}, text_handles{18}] = createGUIPopUpMenuLine(GUI, 'GUIConfig', 'NotchFilter_popupmenu', 'Notch filter', GUI.ConfigBox, @NotchFilter_popupmenu_Callback, {'None'; '50'; '60'});
            text_handles{18}.FontSize = BigFontSize-0.5;
            GUI.GUIConfig.NotchFilter_popupmenu.FontSize = BigFontSize-0.5;
            uicontrol( 'Style', 'text', 'Parent', textBox{18}, 'String', 'Hz', 'FontSize', BigFontSize-0.5, 'HorizontalAlignment', 'left');
            
            
            uicontrol( 'Style', 'text', 'Parent', GUI.ConfigBox, 'String', 'Fiducials PPG filtering parameters', 'FontSize', BigFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
            GUI.PPGFilter_checkbox = uicontrol('Style', 'Checkbox', 'Parent', GUI.ConfigBox, 'FontSize', BigFontSize-0.5, 'String', 'Apply filter', 'Value', 1, 'UserData', 'ppg_filt_enable', 'Callback', @apply_filter_ppg_checkbox_Callback);
            [GUI, PPGLimitBox_L, text_handles_ppg_L] =     createGUISingleEditLine(GUI, 'GUIConfig', 'lcf_ppg', 'Lower cutoff frequency', 'Hz', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'lcf_ppg', BigFontSize-0.5);
            [GUI, PPGLimitBox_H, text_handles_ppg_H] =     createGUISingleEditLine(GUI, 'GUIConfig', 'hcf_ppg', 'Upper cutoff frequency', 'Hz', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'hcf_ppg', BigFontSize-0.5);
            [GUI, PPGOrder,      text_handles_ppg_order] = createGUISingleEditLine(GUI, 'GUIConfig', 'order', 'Order', 'n.u.', GUI.ConfigBox, @config_edit_Callback, 'config_edit', 'order', BigFontSize-0.5);
            
            uix.Empty('Parent', GUI.ConfigBox );
            
            if DATA.SmallScreen
                set(GUI.ConfigBox, 'Heights', [-10 -10 * ones(1, 7)  -10 -10 * ones(1, 5)  -10 -10 * ones(1, 4)  -10 -10 -10 -10 -15 -10 -10 -10 -10 -10 -40]);
            else
                set(GUI.ConfigBox, 'Heights', [-10 -10 * ones(1, 7)  -10 -10 * ones(1, 5)  -10 -10 * ones(1, 4)  -10 -10 -10 -10 -15 -10 -10 -10 -10 -10 -20]);
            end
            
            uix.Empty('Parent', DisplayBox);
            
            [GUI, textBox{19}, text_handles{19}] = createGUISingleEditLine(GUI, 'GUIDisplay', 'FirstSecond', 'Window start:', 'h:min:sec', DisplayBox, @FirstSecond_Callback, '', 0, BigFontSize);
            [GUI, textBox{20}, text_handles{20}] = createGUISingleEditLine(GUI, 'GUIDisplay', 'WindowSize', 'Window length:', 'h:min:sec', DisplayBox, @WindowSize_Callback, '', 0, BigFontSize);
            
            [GUI, YLimitBox, text_handles{21}] = createGUIDoubleEditLine(GUI, 'GUIDisplay', {'MinYLimit_Edit'; 'MaxYLimit_Edit'}, 'Y Limit:', '', DisplayBox, {@MinMaxYLimit_Edit_Callback; @MinMaxYLimit_Edit_Callback}, {'', ''}, []);
            
            uix.Empty('Parent', DisplayBox);
            
            [GUI, textBox{22}, text_handles{22}] = createGUISingleEditLine(GUI, 'GUIDisplay', 'RRIntPage_Length', 'Display duration:', 'h:min:sec', DisplayBox, @RRIntPage_Length_Callback, '', '', BigFontSize);
            [GUI, YLimitBox2, text_handles{23}] = createGUIDoubleEditLine(GUI, 'GUIDisplay', {'MinYLimitLowAxes_Edit'; 'MaxYLimitLowAxes_Edit'}, 'Y Limit:', '', DisplayBox, {@MinMaxYLimitLowAxes_Edit_Callback; @MinMaxYLimitLowAxes_Edit_Callback}, {'', ''}, []);
            
            uix.Empty('Parent', DisplayBox);
            
            [GUI, textBox{24}, text_handles{24}] = createGUISingleEditLine(GUI, 'GUIDisplay', 'Movie_Delay', 'Movie Speed:', 'n.u.', DisplayBox, @Movie_Delay_Callback, '', 2, BigFontSize);
            GUI.GUIDisplay.Movie_Delay.String = 2;
            
            uix.Empty('Parent', DisplayBox);
            
            
            %--------------------------------------------------------------
            tempBox = uix.HBox('Parent', DisplayBox, 'Spacing', DATA.Spacing);
            
            GUI.GridX_checkbox = uicontrol('Style', 'Checkbox', 'Parent', tempBox, 'Callback', @GridX_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'Grid X', 'Value', 1);
            GUI.GridY_checkbox = uicontrol('Style', 'Checkbox', 'Parent', tempBox, 'Callback', @GridY_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'Grid Y', 'Value', 1);
            uix.Empty('Parent', tempBox);
            uix.Empty('Parent', tempBox);
            %-----------------------------
            tempBox1 = uix.HBox('Parent', DisplayBox, 'Spacing', DATA.Spacing);
            GUI.TrendHR_checkbox = uicontrol('Style', 'Checkbox', 'Parent', tempBox1, 'Callback', @TrendHR_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'Trend HR', 'Value', 1);
            GUI.FilterHR_checkbox = uicontrol('Style', 'Checkbox', 'Parent', tempBox1, 'Callback', @FilterHR_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'Filter HR', 'Value', 0);
            
            GUI.GridYHR_checkbox = uicontrol('Style', 'Checkbox', 'Parent', tempBox1, 'Callback', @GridYHR_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'Grid Y HR', 'Value', 1);
            uix.Empty('Parent', tempBox1);
            %--------------------------------------------------------------
            uix.Empty('Parent', DisplayBox);
            
            ChannelsBox = uix.HBox('Parent', DisplayBox, 'Spacing', DATA.Spacing);
            
            GUI.FilteredSignal_checkbox = uicontrol('Style', 'Checkbox', 'Parent', ChannelsBox, 'Callback', @ShowFilteredSignal_checkbox_Callback, 'FontSize', SmallFontSize, 'String', 'Show filtered signal', 'Value', 0);
            GUI.RawSignal_checkbox =      uicontrol('Style', 'Checkbox', 'Parent', ChannelsBox, 'Callback', @ShowRawSignal_checkbox_Callback,      'FontSize', SmallFontSize, 'String', 'Show raw signal', 'Value', 1);
            
            [GUI, textBox{25}, text_handles{25}] = createGUIPopUpMenuLine(GUI, 'GUIDisplay', 'FilterLevel_popupmenu', 'Filter level', DisplayBox,...
                @FilterLevel_popupmenu_Callback, {'Weak'; 'Moderate'; 'Strong'});
            
            [GUI, CutoffFr, text_handles{26}] = createGUIDoubleEditLine(GUI, 'GUIDisplay', {'LowCutoffFr_Edit'; 'HightCutoffFr_Edit'}, 'Cutoff Frequency:', 'Hz', DisplayBox, {@LowHightCutoffFr_Edit; @LowHightCutoffFr_Edit}, {'', ''}, []);
            set_default_filter_level_user_data();
            
            uix.Empty('Parent', DisplayBox);
            
            % ---------------------------------------------------
            [GUI, GUI.RhythmsRangeHBox, text_handles{27}] = createGUIDoubleEditLine(GUI, 'GUIDisplay', {'MinRhythmsRange_Edit'; 'MaxRhythmsRange_Edit'}, 'Rhythms range:', 'h:min:sec', DisplayBox, {@MinMaxRhythmsRange_Edit_Callback; @MinMaxRhythmsRange_Edit_Callback}, {'Min'; 'Max'}, []);
            
            GUI.DispRhythmsHBox = uix.HBox('Parent', DisplayBox, 'Spacing', DATA.Spacing);
            text_handles{28} = uicontrol('Style', 'text', 'Parent', GUI.DispRhythmsHBox, 'String', 'Rhythms', 'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
            GUI.RhythmsListbox = uicontrol('Style', 'ListBox', 'Parent', GUI.DispRhythmsHBox, 'Callback', @Rhythms_listbox_Callback, 'FontSize', DATA.SmallFontSize, 'Tag', 'RhythmsList');
            
            uix.Empty('Parent', DisplayBox);
            
            GUI.FilterLevelBox = textBox{25};
            GUI.CutoffFrBox = CutoffFr;
            
            GUI.FilterLevelBox.Visible = 'off';
            GUI.CutoffFrBox.Visible = 'off';
            
            set(GUI.GUIDisplay.FirstSecond, 'Enable', 'on');
            set(GUI.GUIDisplay.WindowSize, 'Enable', 'on');
            set(GUI.GUIDisplay.MinYLimit_Edit, 'Enable', 'inactive');
            set(GUI.GUIDisplay.MaxYLimit_Edit, 'Enable', 'inactive');
            set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'Enable', 'inactive');
            set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'Enable', 'inactive');
            
            max_extent_control = calc_max_control_x_extend(text_handles(19:end));
            
            if DATA.SmallScreen
                field_size = [max_extent_control, 120, 1 -1]; % max_extent_control, 150, 10 -1
            else
                field_size = [max_extent_control, 140, 1 -1]; % max_extent_control, 150, 10 -1
            end
            
            for i = 1 : length(text_handles) - 4
                set(textBox{i}, 'Widths', field_size);
            end
            
            set(PPGLimitBox_L, 'Widths', field_size);
            set(PPGLimitBox_H, 'Widths', field_size);
            set(PPGOrder, 'Widths', field_size);
            
            
            set(textBox{24}, 'Widths', field_size);
            set(tempBox, 'Widths', [-1 -1 -1 -1]);
            set(tempBox1, 'Widths', [-1 -1 -1 -1]);
            
            if DATA.SmallScreen
                field_size = [max_extent_control, 120, -1];
            else
                field_size = [max_extent_control, 140, -1];
            end
            set(textBox{25}, 'Widths', field_size);
            
            if DATA.SmallScreen
                field_size = [max_extent_control, 56, 5, 53, 1];
            else
                field_size = [max_extent_control, 66, 5, 63, 1];
            end
            set(YLimitBox, 'Widths', field_size);
            set(YLimitBox2, 'Widths', field_size);
            
            GUI.AutoScaleY_checkbox = uicontrol('Style', 'Checkbox', 'Parent', YLimitBox, 'Callback', @AutoScaleY_pushbutton_Callback, 'FontSize', DATA.BigFontSize, 'String', 'Auto Scale Y', 'Value', 1, 'Enable', 'on');
            set(YLimitBox, 'Widths', [field_size, 150]);
            
            GUI.AutoScaleYLowAxes_checkbox = uicontrol('Style', 'Checkbox', 'Parent', YLimitBox2, 'Callback', @AutoScaleYLowAxes_pushbutton_Callback, 'FontSize', DATA.BigFontSize, 'String', 'Auto Scale Y', 'Value', 1, 'Enable', 'on');
            set(YLimitBox2, 'Widths', [field_size, 150]);
            
            if DATA.SmallScreen
                field_size = [max_extent_control, 56, 5, 53, 1, -1];
            else
                field_size = [max_extent_control, 66, 5, 63, 1, -1];
            end
            set(CutoffFr, 'Widths', field_size);
            set(GUI.RhythmsRangeHBox, 'Widths', field_size);
            %             set(PPGLimitBox, 'Widths', field_size);
            
            
            if DATA.SmallScreen
                set(GUI.DispRhythmsHBox, 'Widths', [max_extent_control 120]);
            else
                set(GUI.DispRhythmsHBox, 'Widths', [max_extent_control 140]);
            end
            
            if DATA.SmallScreen
                set(DisplayBox, 'Heights', [-2 -6 -6 -6 -2 -6 -6 -2 -6  -4 -6   -6   -2   -6  -7 -6 -2 -6 -30 -30]);
            else
                set(DisplayBox, 'Heights', [-2 -6 -6 -6 -2 -6 -6 -2 -6  -3 -6   -6   -2   -6  -7 -6 -6 -6 -40 -1]);
            end
            
            %-------------------------------------------------------
            
            % Low Part
            
            GUI.Low_TabPanel = uix.TabPanel('Parent', Low_Part_BoxPanel, 'Padding', DATA.Padding);
            
            GUI = create_low_part_tables(GUI, GUI.Low_TabPanel, '', DATA.Padding, DATA.Spacing, DATA.SmallFontSize, DATA.BigFontSize);
            
            %             PeaksTab = uix.Panel('Parent', Low_TabPanel, 'Padding', DATA.Padding);
            %             RhythmsTab = uix.Panel('Parent', Low_TabPanel, 'Padding', DATA.Padding);
            %             DurationTab = uix.Panel('Parent', Low_TabPanel, 'Padding', DATA.Padding);
            %             AmplitudeTab = uix.Panel('Parent', Low_TabPanel, 'Padding', DATA.Padding);
            %
            %             Low_TabPanel.TabTitles = {'Peaks', 'Rhythms', 'Duration', 'Amplitude'};
            %             Low_TabPanel.TabWidth = 100;
            %             Low_TabPanel.FontSize = BigFontSize;
            %
            %             Low_Part_Box = uix.VBox('Parent', PeaksTab, 'Spacing', DATA.Spacing);
            %
            %             GUI.PeaksTable = uitable('Parent', Low_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{550 'auto'}, 'FontName', 'Calibri');
            %             GUI.PeaksTable.ColumnName = {'Description'; 'Values'};
            %             GUI.PeaksTable.RowName = {'NB PEAKS (n.u.)'; 'NB PEAKS ADD (n.u.)'; 'NB PEAKS RM (n.u.)'; 'PR BAD SQ (%)'};
            %             GUI.PeaksTable.Data = {''};
            %             GUI.PeaksTable.Data(1, 1) = {'Total number of peaks'};    % Number of peaks detected by the peak detection algorithm
            %             GUI.PeaksTable.Data(2, 1) = {'Number of peaks manually added by the user'}; % Number of peaks manually added by the user
            %             GUI.PeaksTable.Data(3, 1) = {'Number of peaks manually removed by the user'}; % Number of peaks manually removed by the user
            %             GUI.PeaksTable.Data(4, 1) = {['Percentage of the record annotated as bad quality (i.e. signal quality ' sprintf('\x2260') ' ''A'')']};
            %             GUI.PeaksTable.Data(:, 2) = {0};
            %
            %             %--------------------------------------------------------------------------
            %
            %             Rhythms_Part_Box = uix.VBox('Parent', RhythmsTab, 'Spacing', DATA.Spacing);
            %             GUI.RhythmsTable = uitable('Parent', Rhythms_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{250 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto'}, 'FontName', 'Calibri');
            %             GUI.RhythmsTable.ColumnName = {'Description'; 'Min (sec)'; 'Max (sec)'; 'Median (sec)'; 'Q1 (sec)'; 'Q3 (sec)'; 'Burden (%)'; 'Nb events'};
            %             GUI.RhythmsTable.Data = {};
            %             GUI.RhythmsTable.RowName = {};
            %
            %             %--------------------------------------------------------------------------
            %
            %             Amplitude_Part_Box = uix.VBox('Parent', AmplitudeTab, 'Spacing', DATA.Spacing);
            %             GUI.AmplitudeTable = uitable('Parent', Amplitude_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{450 'auto' 'auto' 'auto' 'auto' 'auto' 'auto'}, 'FontName', 'Calibri');
            %             %             GUI.AmplitudeTable.ColumnName = {'Description'; 'Min (sec)'; 'Max (sec)'; 'Mean (sec)'; 'Median (sec)'; 'STD (sec)'; 'IQR (sec)'};
            %             GUI.AmplitudeTable.ColumnName = {'Description'; 'Mean'; 'Median'; 'Min'; 'Max'; 'IQR'; 'STD'};
            %             GUI.AmplitudeTable.Data = {};
            %             GUI.AmplitudeTable.RowName = {};
            %
            %             %--------------------------------------------------------------------------
            %
            %             Duration_Part_Box = uix.VBox('Parent', DurationTab, 'Spacing', DATA.Spacing);
            %             GUI.DurationTable = uitable('Parent', Duration_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{350 'auto' 'auto' 'auto' 'auto' 'auto' 'auto'}, 'FontName', 'Calibri');
            %             GUI.DurationTable.ColumnName = {'Description'; 'Mean'; 'Median'; 'Min'; 'Max'; 'IQR'; 'STD'};
            %             GUI.DurationTable.Data = {};
            %             GUI.DurationTable.RowName = {};
            
            %--------------------------------------------------------------------------
            
            set(findobj(Upper_Part_Box,'Style', 'edit'), 'BackgroundColor', myEditTextColor);
            set(findobj(Upper_Part_Box,'Style', 'text'), 'BackgroundColor', myUpBackgroundColor);
            set(findobj(Upper_Part_Box,'Style', 'slider'), 'BackgroundColor', mySliderColor);
            set(findobj(Upper_Part_Box,'Style', 'checkbox'), 'BackgroundColor', myUpBackgroundColor);
            set(findobj(Upper_Part_Box,'Style', 'ToggleButton'), 'BackgroundColor', myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
            set(findobj(Upper_Part_Box,'Style', 'PushButton'), 'BackgroundColor', myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
            set(findobj(Upper_Part_Box,'Type', 'uicontainer'), 'BackgroundColor', myUpBackgroundColor);
            set(findobj(Upper_Part_Box,'Type', 'uipanel'), 'BackgroundColor', myUpBackgroundColor);
            
            if ismac()
                set(findobj(Upper_Part_Box,'Style', 'ToggleButton'), 'ForegroundColor', [0 0 0]);
            end
            
            
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
            
            GUI.SaveFiducials.Enable = 'off';
            GUI.SaveFiducialsStat.Enable = 'off';
            
            GUI.LoadConfigurationFile.Enable = 'off';
            GUI.SaveConfigurationFile.Enable = 'off';
            GUI.SavePeaks.Enable = 'off';
            GUI.SaveFiguresFile.Enable = 'off';
            %GUI.LoadPeaks.Enable = 'off';
            
            GUI.PlayStopForwMovieButton.ForegroundColor = [0 1 0];
            GUI.PlayStopReverseMovieButton.ForegroundColor = [0 1 0];
            GUI.PageDownButton.ForegroundColor = [0 0 1];
            GUI.PageUpButton.ForegroundColor = [0 0 1];
        catch e
            disp(e);
        end
    end
%%
    function [GUI, TempBox, uicontrol_handle] = createGUITextLine(GUI, gui_struct, field_name, string_field_name, box_container, style, isOpenButton, callback_openButton)
        
        TempBox = uix.HBox( 'Parent', box_container, 'Spacing', DATA.Spacing);
        uicontrol_handle = uicontrol('Style', 'text', 'Parent', TempBox, 'String', string_field_name, 'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
        GUI.(gui_struct).(field_name) = uicontrol('Style', style, 'Parent', TempBox, 'FontSize', DATA.SmallFontSize, 'HorizontalAlignment', 'left');
        
        if isOpenButton
            button_field_name = [field_name '_pushbutton_handle'];
            GUI.(gui_struct).(button_field_name) = uicontrol('Style', 'PushButton', 'Parent', TempBox, 'Callback', callback_openButton, 'FontSize', DATA.SmallFontSize, 'String', '...', 'Enable', 'off');
        else
            uix.Empty( 'Parent', TempBox );
        end
        %         set( TempBox, 'Widths', field_size  );
    end
%%
    function [GUI, TempBox, uicontrol_handle] = createGUISingleEditLine(GUI, gui_struct, field_name, string_field_name, field_units, box_container, callback_function, tag, user_data, FontSize)
        
        TempBox = uix.HBox( 'Parent', box_container, 'Spacing', DATA.Spacing);
        uicontrol_handle = uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', string_field_name, 'FontSize', FontSize, 'HorizontalAlignment', 'left');
        GUI.(gui_struct).(field_name) = uicontrol( 'Style', 'edit', 'Parent', TempBox, 'Callback', callback_function, 'FontSize', FontSize, 'Tag', tag, 'UserData', user_data);
        uix.Empty( 'Parent', TempBox );
        if ~isempty(strfind(field_units, 'micro')) % https://unicode-table.com/en/
            field_units = strrep(field_units, 'micro', '');
            field_units = [sprintf('\x3bc') field_units];
        end
        uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', field_units, 'FontSize', FontSize, 'HorizontalAlignment', 'left');
        %         set( TempBox, 'Widths', field_size  );
    end
%%
    function [GUI, TempBox, uicontrol_handle] = createGUIDoubleEditLine(GUI, gui_struct, field_name, string_field_name, field_units, box_container, callback_function, tag, user_data)
        
        TempBox = uix.HBox( 'Parent', box_container, 'Spacing', DATA.Spacing);
        uicontrol_handle = uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', string_field_name, 'FontSize', DATA.BigFontSize, 'HorizontalAlignment', 'left');
        GUI.(gui_struct).(field_name{1}) = uicontrol( 'Style', 'edit', 'Parent', TempBox, 'Callback', callback_function{1}, 'FontSize', DATA.BigFontSize, 'Tag', tag{1}, 'UserData', user_data);
        uicontrol( 'Style', 'text', 'Parent', TempBox, 'String', '-', 'FontSize', DATA.BigFontSize);
        GUI.(gui_struct).(field_name{2}) = uicontrol( 'Style', 'edit', 'Parent', TempBox, 'Callback', callback_function{2}, 'FontSize', DATA.BigFontSize, 'Tag', tag{2}, 'UserData', user_data);
        
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
            setLogo(h_e, DATA.Module);
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
                setLogo(h_e, DATA.Module);
                uiwait(h_e);
            end
            
            GUI.GUIRecord.Mammal_popupmenu.String = mammal;
            
            %             DATA.Integration = integration;
            DATA.integration_index = find(strcmpi(DATA.GUI_Integration, integration));
            set(GUI.GUIRecord.Integration_popupmenu, 'Value', DATA.integration_index);
            
            DATA.peakDetector = DATA.config_map('peak_detector');
            DATA.peakDetector_index = find(strcmpi(DATA.GUI_PeakDetector, DATA.peakDetector));
            
            if strcmp(integration, 'Electrogram')
                set(GUI.GUIRecord.PeakDetector_popupmenu, 'String', DATA.GUI_PeakDetector, 'Value', DATA.peakDetector_index);
                GUI.GUIRecord.PeakDetector_popupmenu.Enable = 'inactive';
            elseif strcmp(integration, 'ECG')
                set(GUI.GUIRecord.PeakDetector_popupmenu, 'String', DATA.GUI_PeakDetector(1:end-1, :), 'Value', DATA.peakDetector_index);
                GUI.GUIRecord.PeakDetector_popupmenu.Enable = 'on';
            elseif strcmp(integration, 'PPG')
                set(GUI.GUIRecord.PeakDetector_popupmenu, 'String', DATA.GUI_PeakDetector, 'Value', DATA.peakDetector_index);
                GUI.GUIRecord.PeakDetector_popupmenu.Enable = 'off';
            end
            
            
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
            if isvalid(waitbar_handle)
                close(waitbar_handle);
            end
            rethrow(e);
        end
        
        DATA.zoom_rect_limits = [0 min(DATA.firstZoom, max(DATA.tm))];
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
            
            if index_selected == 2 % Electrogram
                GUI.GUIRecord.PeakDetector_popupmenu.String = DATA.GUI_PeakDetector;
                GUI.GUIRecord.PeakDetector_popupmenu.Value = 4;
                GUI.GUIRecord.PeakDetector_popupmenu.Enable = 'inactive';
            elseif index_selected == 1
                GUI.GUIRecord.PeakDetector_popupmenu.Value = 1;
                GUI.GUIRecord.PeakDetector_popupmenu.String = DATA.GUI_PeakDetector(1:end-1, :);
                GUI.GUIRecord.PeakDetector_popupmenu.Enable = 'on';
            elseif index_selected == 3
                GUI.GUIRecord.PeakDetector_popupmenu.String = DATA.GUI_PeakDetector;
                GUI.GUIRecord.PeakDetector_popupmenu.Value = 5;
                GUI.GUIRecord.PeakDetector_popupmenu.Enable = 'off';
            end
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
                    [~, ch_num] = size(DATA.sig);
                    if ch_num == 12
                        parent_axes = GUI.ECG_Axes_Array(1);
                        ch_marker_size = 4;
                    else
                        parent_axes = GUI.ECG_Axes;
                        ch_marker_size = 5;
                    end
                    create_fiducials_filt_handles(1, ch_marker_size, parent_axes);
                    set_fid_visible(1);
                    if ch_num == 12
                        set12LEDYLim();
                    end
                    if isfield(GUI, 'red_rect_handle') && isvalid(GUI.red_rect_handle)
                        xdata = get(GUI.red_rect_handle, 'XData');
                        setECGYLim(xdata(1), xdata(2));
                    end
                catch e
                    h_e = errordlg(['PeakDetector error: ' e.message], 'Input Error'); setLogo(h_e, DATA.Module);
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
                '*.dat; *.qrs; *.atr; *.rdt',  'WFDB Files (*.dat; *.qrs; *.atr; *.rdt)'}, ...
                'Open Data File', [DIRS.dataDirectory filesep '*.' EXT]); %
        elseif nargin >= 4 % from Module 2
            ECG_FileName = fileNameFromM2.FileName;
            PathName = fileNameFromM2.PathName;
            DataFileMap = DataFileMapFromM2;
        elseif nargin == 3 % small files
            ECG_FileName = fileNameFromM2.FileName;
            PathName = fileNameFromM2.PathName;
        end
        
        if isequal(ECG_FileName, 0)
            return;
        else
            
            DIRS.dataDirectory = PathName;
            
            [~, DataFileName, ExtensionFileName] = fileparts(ECG_FileName);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            
            if strcmpi(ExtensionFileName, 'mat') || strcmpi(ExtensionFileName, 'txt') || strcmpi(ExtensionFileName, 'dat') || strcmpi(ExtensionFileName, 'qrs') || strcmpi(ExtensionFileName, 'atr') || strcmpi(ExtensionFileName, 'rdt')
                
                Config = ReadYaml('Loader Config.yml');
                if nargin <= 3
                    try
                        waitbar_handle = waitbar(1/2, 'Loading data', 'Name', 'Working on it...');
                        setLogo(waitbar_handle, DATA.Module);
                        
                        DataFileMap = loadDataFile([PathName DataFileName '.' EXT]);
                        
                        close(waitbar_handle);
                    catch e
                        if isvalid(waitbar_handle)
                            close(waitbar_handle);
                        end
                        h_e = errordlg(['onOpenFile error: ' e.message], 'Input Error');
                        setLogo(h_e, DATA.Module);
                        return;
                    end
                end
                MSG = DataFileMap('MSG');
                if strcmp(Config.alarm.(MSG), 'OK')
                    data = DataFileMap('DATA');
                    
                    if strcmp(data.Data.Type, 'electrography') || strcmp(data.Data.Type, 'photoplethysmography')
                        
                        clearData();
                        if nargin == 3
                            clear_sm_files_names = true;
                        else
                            clear_sm_files_names = false;
                        end
                        clean_gui_low_part();
                        clean_gui(clear_sm_files_names);
                        clean_config_param_fields();
                        delete_temp_wfdb_files();
                        
                        DATA.DataFileName = DataFileName;
                        DATA.rec_name = [PathName, DATA.DataFileName];
                        
                        GUI.GUIDir.FileName2Split.String = DATA.DataFileName;
                        
                        mammal = data.General.mammal;
                        if strcmpi(mammal, 'custom')
                            DATA.Mammal = 'default';
                        else
                            DATA.Mammal = mammal;
                        end
                        
                        integration = data.General.integration_level;
                        DATA.integration_index = find(strcmpi(DATA.Integration_From_Files, integration));
                        DATA.Integration = DATA.GUI_Integration{DATA.integration_index};
                        
                        DATA.Fs = double(data.Time.Fs);
                        DATA.sig = data.Data.Data;
                        time_data = data.Time.Data;
                        DATA.tm = time_data - time_data(1);
                        
                        DATA.ecg_channel = 1;
                        
                        if (strcmpi(EXT, 'txt') || strcmpi(EXT, 'mat')) && ~strcmp(DATA.Integration, 'PPG')
                            
                            DATA.wfdb_record_name = [tempdir DATA.temp_rec_name4wfdb];
                            mat2wfdb(DATA.sig(:, 1), DATA.wfdb_record_name, DATA.Fs, [], ' ' ,{} ,[]);
                            
                            if ~exist([DATA.wfdb_record_name '.dat'], 'file') && ~exist([DATA.wfdb_record_name '.hea'], 'file')   % && ~exist(fullfile(tempdir, [DATA.temp_rec_name4wfdb '.hea']), 'file')
                                throw(MException('set_data:text', 'Wfdb file cannot be created.'));
                            end
                        elseif (strcmpi(EXT, 'txt') || strcmpi(EXT, 'mat')) && strcmp(DATA.Integration, 'PPG')
                            Fs = DATA.Fs;
                            Data = DATA.sig;
                            DATA.wfdb_record_name = [tempdir DATA.temp_rec_name4wfdb '.mat'];
                            save(DATA.wfdb_record_name, 'Data', 'Fs');
                            clear Fs;
                            clear Data;
                            if ~exist(DATA.wfdb_record_name, 'file')
                                throw(MException('set_data:text', 'Mat file for PPG cannot be created.'));
                            end
                        else
                            DATA.wfdb_record_name = DATA.rec_name;
                        end
                        DATA.ExtensionFileName = ExtensionFileName;
                        isM2 = 0;
                    else
                        
                        choice = questdlg('This recording contains peak annotations or an RR intervals time series. Do you want to open it in the pulse module or the HRV analysis module?', ...
                            'Select module', 'Pulse module', 'HRV analysis module', 'Cancel', 'Pulse module');
                        
                        switch choice
                            case 'HRV analysis module'
                                
                                fileNameFromM1.FileName = ECG_FileName;
                                fileNameFromM1.PathName = PathName;
                                if isvalid(waitbar_handle)
                                    close(waitbar_handle);
                                end
                                PhysioZooGUI(fileNameFromM1, DataFileMap);
                                isM2 = 1;
                                return;
                            case 'Pulse module'
                                if isfield(DATA, 'Mammal') && ~isempty(DATA.Mammal)
                                    isM2 = 0;
                                    try
                                        load_peaks(ECG_FileName, PathName, DataFileMap);
                                        if isvalid(waitbar_handle)
                                            close(waitbar_handle);
                                        end
                                        
                                        GUI.Rhythms_handle.Enable = 'inactive';
                                        return;
                                    catch e
                                        clean_gui_low_part();
                                        if isvalid(waitbar_handle)
                                            close(waitbar_handle);
                                        end
                                        h_e = errordlg(['load_peaks error: ' e.message], 'Input Error');
                                        setLogo(h_e, DATA.Module);
                                        if nargin < 3
                                            return;
                                        else
                                            throw(MException('OpenFile:LoadPeaks', 'Load Peaks failed'));
                                        end
                                    end
                                else
                                    isM2 = 0;
                                    clean_gui_low_part();
                                    h_e = errordlg('Please, load ECG file first.', 'Input Error');
                                    setLogo(h_e, DATA.Module);
                                    if isvalid(waitbar_handle)
                                        close(waitbar_handle);
                                    end
                                    if nargin < 3
                                        return;
                                    else
                                        throw(MException('OpenFile:NoECGFile', 'Please, load ECG file first'));
                                    end
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
                    setLogo(h_e, DATA.Module);
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
                        setLogo(h_e, DATA.Module);
                        return;
                    end
                end
                
                set(GUI.GUIRecord.RecordFileName_text, 'String', ECG_FileName);
                
                %--------------------------------------------------------------------
                
                [~, ch_no] = size(DATA.sig);
                real_ch_no = length(data.Data.EnabledChNames);
                if real_ch_no > ch_no
                    names_array = {data.Data.EnabledChNames{2:end}};
                else
                    names_array = data.Data.EnabledChNames;
                end
                
                try
                    a = DataFileMap('channels');
                catch
                    if ~isempty(data.Data.Data)
                        names_array = {'data'};
                    end
                end
                
                if isempty(names_array)
                    clean_gui_low_part();
                    clean_gui(true);
                    delete_temp_wfdb_files();
                    if isvalid(waitbar_handle)
                        close(waitbar_handle);
                    end
                    GUI.ChannelsTable.Data = {};
                    GUI.CalcPeaksButton_handle.Enable = 'inactive';
                    h_e = errordlg('No data was loaded', 'Input Error'); setLogo(h_e, DATA.Module);
                    return;
                end
                
                table_data = cell(ch_no, 4);
                table_data(1, 1) = {names_array{1}};
                table_data(1, 2) = {true};
                table_data(1, 4) = {true};
                table_data(1, 3) = {false};
                
                for i = 2 : ch_no
                    table_data(i, 1) = {names_array{i}};
                    table_data(i, 2) = {false};
                    table_data(i, 4) = {false};
                    table_data(i, 3) = {false};
                end
                
                clear('DataFileMap');
                
                GUI.ChannelsTable.Data = table_data;
                
                GUI.offset_array = zeros(1, ch_no);
                GUI.offset_array(1) = 0;
                
                if ch_no ~= 12
                    
                    %                     if ~strcmp(DATA.Integration, 'PPG')
                    [GUI.ECG_Axes, GUI.RRInt_Axes] = create_graphs_panel(GUI.graphs_panel_up_central, DATA.Spacing, myUpBackgroundColor);
                    GUI.RawData_handle = line(DATA.tm, DATA.sig(:, 1), 'Parent', GUI.ECG_Axes, 'Tag', 'RawData_1', 'Color', DATA.Ch_Colors{1});
                    offset = min(GUI.RawData_handle.YData)*1.05;
                    GUI.RawChannelsData_handle(1) = GUI.RawData_handle;
                    
                    for i = 2 : ch_no
                        GUI.offset_array(i) = offset;
                        GUI.RawChannelsData_handle(i) = line(DATA.tm, DATA.sig(:, i) + offset, 'Parent', GUI.ECG_Axes,...
                            'Tag', ['RawData_' num2str(i)], 'Color', DATA.Ch_Colors{mod(i-1, 3)+1});
                        offset = min(GUI.RawChannelsData_handle(i).YData)*1.05; % +offset
                        GUI.RawChannelsData_handle(i).Visible = 'off';
                    end
                    
                    PathName = strrep(PathName, '\', '\\');
                    PathName = strrep(PathName, '_', '\_');
                    ECG_FileName_title = strrep(ECG_FileName, '_', '\_');
                    
                    TitleName = [PathName ECG_FileName_title];
                    title(GUI.ECG_Axes, TitleName, 'FontWeight', 'normal', 'FontSize', 11, 'FontName', 'Times New Roman');
                    
                    % -----------------------------------------------------
                    DATA.firstZoom = min(60, max(DATA.tm)); % sec
                    DATA.zoom_rect_limits = [0 DATA.firstZoom];
                    % -----------------------------------------------------
                    
                    right_limit2plot = min(DATA.firstZoom, max(DATA.tm));
                    setECGXLim(0, right_limit2plot);
                    setECGYLim(0, right_limit2plot);
                    
                    set(GUI.GUIDisplay.FirstSecond, 'Enable', 'on');
                    set(GUI.GUIDisplay.WindowSize, 'Enable', 'on');
                    set(GUI.GUIDisplay.MinYLimit_Edit, 'Enable', 'on');
                    set(GUI.GUIDisplay.MaxYLimit_Edit, 'Enable', 'on');
                    set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'Enable', 'on');
                    set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'Enable', 'on');
                    GUI.AutoScaleYLowAxes_checkbox.Enable = 'on';
                    GUI.AutoScaleY_checkbox.Enable = 'on';
                    set(GUI.GUIDisplay.RRIntPage_Length, 'Enable', 'on');
                    set(GUI.GUIDisplay.Movie_Delay, 'Enable', 'on');
                    GUI.TrendHR_checkbox.Enable = 'on';
                    GUI.FilterHR_checkbox.Enable = 'on';
                    GUI.GridYHR_checkbox.Enable = 'on';
                    GUI.RR_or_HR_plot_button.Enable = 'on';
                    GUI.PlayStopReverseMovieButton.Enable = 'on';
                    GUI.PlayStopForwMovieButton.Enable = 'on';
                    GUI.PageDownButton.Enable = 'on';
                    GUI.PageUpButton.Enable = 'on';
                    GUI.Fiducials_winStart.Enable = 'on';
                    GUI.Fiducials_winLength.Enable = 'on';
                    
                    GUI.ChAmpDecreaseButton.Enable = 'on';
                    GUI.ChAmpIncreaseButton.Enable = 'on';
                    GUI.ChAmpSourceButton.Enable = 'on';
                    
                    GUI.GUIRecord.Annotation_popupmenu.Enable = 'on';
                    GUI.GUIRecord.PeakAdjustment_popupmenu.Enable = 'on';
                    
                    if strcmp(DATA.Integration, 'PPG')
                        y_label_text = 'PPG (mV)';
                        GUI.GUIRecord.Annotation_popupmenu.Enable = 'off';
                        GUI.GUIRecord.PeakAdjustment_popupmenu.Enable = 'off';
                        GUI.TrendHR_checkbox.Enable = 'off';
                        GUI.FilterHR_checkbox.Enable = 'off';
                        GUI.FilteredSignal_checkbox.Enable = 'off';
                        GUI.DispRhythmsHBox.Visible = 'off';
                        GUI.RhythmsRangeHBox.Visible = 'off';
                        GUI.P_checkbox.Visible = 'off';
                        GUI.Q_checkbox.String = 'ON';
                        GUI.R_checkbox.String = 'SP';
                        GUI.S_checkbox.String = 'DN';
                        GUI.T_checkbox.String = 'DP';
                        
                        GUI.P_checkbox.ForegroundColor = 'w';
                        GUI.Q_checkbox.ForegroundColor = 'b';
                        GUI.R_checkbox.ForegroundColor = 'r';
                        GUI.S_checkbox.ForegroundColor = 'g';
                        GUI.T_checkbox.ForegroundColor = 'm';
                        DATA.Module = 'PPG';
                        setLogo(GUI.Window, DATA.Module);
                        
                        GUI.fiducials_path = '';
                        GUI.GUIConfig.NotchFilter_popupmenu.Enable = 'off';
                        GUI.BandpassFilter_checkbox.Enable = 'off';
                        
                        %                         GUI.GUIRecord.PeaksFileName_text.Enable = 'off';
                        %                         GUI.GUIRecord.DataQualityFileName_text.Enable = 'off';
                        %                         GUI.GUIRecord.RhythmsFileName_text.Enable = 'off';
                        
                        GUI = create_low_part_tables(GUI, GUI.Low_TabPanel, 'PPG', DATA.Padding, DATA.Spacing, DATA.SmallFontSize, DATA.BigFontSize);
                        
                        %                         try
                        %                             download_ppg_exe_file();
                        %                         catch e
                        %                             h_e = errordlg(['OpenFile error: ' e.message], 'Input Error'); setLogo(h_e, DATA.Module);
                        %                             return;
                        %                         end
                        
                        
                    else
                        y_label_text = 'ECG (mV)';
                        GUI.GUIRecord.Annotation_popupmenu.Enable = 'on';
                        GUI.GUIRecord.PeakAdjustment_popupmenu.Enable = 'on';
                        GUI.TrendHR_checkbox.Enable = 'on';
                        GUI.FilterHR_checkbox.Enable = 'on';
                        GUI.FilteredSignal_checkbox.Enable = 'on';
                        GUI.DispRhythmsHBox.Visible = 'on';
                        GUI.RhythmsRangeHBox.Visible = 'on';
                        GUI.P_checkbox.Visible = 'on';
                        GUI.Q_checkbox.String = 'Q-Peaks (QRS on)';
                        GUI.R_checkbox.String = 'R-Peaks';
                        GUI.S_checkbox.String = 'S-Peaks (QRS off)';
                        GUI.T_checkbox.String = 'T-Peaks';
                        
                        GUI.P_checkbox.ForegroundColor = [0.9290, 0.6940, 0.1250];
                        GUI.Q_checkbox.ForegroundColor = [0.4940, 0.1840, 0.5560];
                        GUI.R_checkbox.ForegroundColor = [1 0 0];
                        GUI.S_checkbox.ForegroundColor = [0.8500, 0.3250, 0.0980];
                        GUI.T_checkbox.ForegroundColor = [0.6350, 0.0780, 0.1840];
                        DATA.Module = 'M1';
                        setLogo(GUI.Window, DATA.Module);
                        
                        GUI.fiducials_path = '';
                        GUI.GUIConfig.NotchFilter_popupmenu.Enable = 'on';
                        GUI.BandpassFilter_checkbox.Enable = 'on';
                        
                        %                         GUI.GUIRecord.PeaksFileName_text.Enable = 'on';
                        %                         GUI.GUIRecord.DataQualityFileName_text.Enable = 'on';
                        %                         GUI.GUIRecord.RhythmsFileName_text.Enable = 'on';
                        
                        GUI = create_low_part_tables(GUI, GUI.Low_TabPanel, 'ECG', DATA.Padding, DATA.Spacing, DATA.SmallFontSize, DATA.BigFontSize);
                    end
                    
                    try
                        xlabel(GUI.ECG_Axes, 'Time (h:min:sec)', 'FontName', 'Times New Roman');
                        ylabel(GUI.ECG_Axes, y_label_text, 'FontName', 'Times New Roman');
                        hold(GUI.ECG_Axes, 'on');
                        GUI.hT = text(0, 0, 'Test', 'Parent', GUI.ECG_Axes, 'FontName', 'Times New Roman');
                    catch
                        %                         xlabel(GUI.PPG_Axes, 'Time (h:min:sec)', 'FontName', 'Times New Roman');
                        %                         ylabel(GUI.PPG_Axes, 'PPG (mV)', 'FontName', 'Times New Roman');
                        %                         hold(GUI.PPG_Axes, 'on');
                        %                         GUI.hT = text(0, 0, 'Test', 'Parent', GUI.PPG_Axes, 'FontName', 'Times New Roman');
                        %                         GUI.RR_or_HR_plot_button.Enable = 'off';
                        %                         GUI.ChAmpDecreaseButton.Enable = 'off';
                        %                         GUI.ChAmpIncreaseButton.Enable = 'off';
                        %                         GUI.ChAmpSourceButton.Enable = 'off';
                        %                         GUI.GUIRecord.Annotation_popupmenu.Enable = 'off';
                        %                         GUI.GUIRecord.PeakAdjustment_popupmenu.Enable = 'off';
                        %                         GUI.PlayStopReverseMovieButton.Enable = 'off';
                        %                         GUI.PlayStopForwMovieButton.Enable = 'off';
                        %                         GUI.PageDownButton.Enable = 'off';
                        %                         GUI.PageUpButton.Enable = 'off';
                    end
                    
                    GUI.Rhythms_handle.Enable = 'inactive';
                    %                     GUI.Rhythms_handle.Enable = 'on';
                    
                    
                else
                    GUI.ECG_Axes_Array = create_grid_panel(GUI.graphs_panel_up_central, DATA.Spacing, DATA.Padding, myUpBackgroundColor, ch_no);
                    [GUI.RawChannelsData_handle, GUI.ch_name_handles] = plot_ch_data(GUI.ECG_Axes_Array, DATA.tm, DATA.sig, names_array, GUI.GridX_checkbox, GUI.GridY_checkbox);
                    
                    GUI.ECG_Axes = GUI.ECG_Axes_Array(1);
                    GUI.RawData_handle = GUI.RawChannelsData_handle(1);
                    
                    GUI.ChannelsTable.Data(:, 2) = {true};
                    
                    set(GUI.GUIDisplay.FirstSecond, 'Enable', 'off', 'String', '');
                    set(GUI.GUIDisplay.WindowSize, 'Enable', 'off', 'String', '');
                    set(GUI.GUIDisplay.MinYLimit_Edit, 'Enable', 'off', 'String', '');
                    set(GUI.GUIDisplay.MaxYLimit_Edit, 'Enable', 'off', 'String', '');
                    set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'Enable', 'off', 'String', '');
                    set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'Enable', 'off', 'String', '');
                    GUI.AutoScaleYLowAxes_checkbox.Enable = 'off';
                    GUI.AutoScaleY_checkbox.Enable = 'off';
                    set(GUI.GUIDisplay.RRIntPage_Length, 'Enable', 'off', 'String', '');
                    set(GUI.GUIDisplay.Movie_Delay, 'Enable', 'off', 'String', '');
                    GUI.TrendHR_checkbox.Enable = 'off';
                    GUI.FilterHR_checkbox.Enable = 'off';
                    GUI.GridYHR_checkbox.Enable = 'off';
                    GUI.RR_or_HR_plot_button.Enable = 'off';
                    GUI.PlayStopReverseMovieButton.Enable = 'off';
                    GUI.PlayStopForwMovieButton.Enable = 'off';
                    GUI.PageDownButton.Enable = 'off';
                    GUI.PageUpButton.Enable = 'off';
                    GUI.Fiducials_winStart.Enable = 'off';
                    GUI.Fiducials_winLength.Enable = 'off';
                    
                    GUI.ChAmpDecreaseButton.Enable = 'off';
                    GUI.ChAmpIncreaseButton.Enable = 'off';
                    GUI.ChAmpSourceButton.Enable = 'off';
                    
                    GUI.GUIRecord.Annotation_popupmenu.Enable = 'off';
                    GUI.GUIRecord.PeakAdjustment_popupmenu.Enable = 'off';
                    DATA.Module = 'M1';
                    setLogo(GUI.Window, DATA.Module);
                    
                    GUI = create_low_part_tables(GUI, GUI.Low_TabPanel, 'ECG', DATA.Padding, DATA.Spacing, DATA.SmallFontSize, DATA.BigFontSize);
                end
                
                %---------------------------------------------------------------------------------------------------
                
                DATA.amp_counter = zeros(1, length(GUI.RawChannelsData_handle));
                
                set(GUI.GUIRecord.TimeSeriesLength_text, 'String', [calcDuration(DATA.tm(end), 1) '    h:min:sec.msec']);
                
                if GUI.AutoCalc_checkbox.Value
                    try
                        RunAndPlotPeakDetector();
                    catch e
                        h_e = errordlg(['OpenFile error: ' e.message], 'Input Error');
                        setLogo(h_e, DATA.Module);
                    end
                end
                
                GUI.LoadConfigurationFile.Enable = 'on';
                GUI.SaveConfigurationFile.Enable = 'on';
                GUI.SavePeaks.Enable = 'on';
                GUI.SaveFiguresFile.Enable = 'on';
                
                if ~strcmp(DATA.Integration, 'PPG')
                    GUI.GUIRecord.PeaksFileName_text_pushbutton_handle.Enable = 'on';
                    GUI.GUIRecord.DataQualityFileName_text_pushbutton_handle.Enable = 'on';
                    GUI.GUIRecord.RhythmsFileName_text_pushbutton_handle.Enable = 'on';
                    GUI.SaveDataQuality.Enable = 'on';
                    GUI.OpenDataQuality.Enable = 'on';
                    GUI.SaveRhythms.Enable = 'on';
                    GUI.OpenRhythms.Enable = 'on';
                else
                    GUI.GUIRecord.PeaksFileName_text_pushbutton_handle.Enable = 'off';
                    GUI.GUIRecord.DataQualityFileName_text_pushbutton_handle.Enable = 'off';
                    GUI.GUIRecord.RhythmsFileName_text_pushbutton_handle.Enable = 'off';
                    GUI.SaveDataQuality.Enable = 'off';
                    GUI.OpenDataQuality.Enable = 'off';
                    GUI.SaveRhythms.Enable = 'off';
                    GUI.OpenRhythms.Enable = 'off';
                end
                
                GUI.GUIRecord.Config_text_pushbutton_handle.Enable = 'on';
                
                GUI.Fiducials_winStart.String = calcDuration(0, 0);
                GUI.Fiducials_winLength.String = calcDuration(min(300, max(DATA.tm)), 0);
                
                GUI.Fiducials_winStart.UserData = 0;
                GUI.Fiducials_winLength.UserData = min(300, max(DATA.tm)); % sec
                
                DATA.zoom_rect_limits = [0 DATA.firstZoom];
                set_default_filter_level_user_data();
                
                GUI.GUIDir.Split_Sec.String = min(max(DATA.tm), DATA.Small_File_Length_Sec);
                GUI.GUIDir.Split_Sec.UserData = GUI.GUIDir.Split_Sec.String;
                
                % Split huge file to small files
                if nargin ~= 3
                    if max(DATA.tm)*0.9 > str2double(GUI.GUIDir.Split_Sec.String) %DATA.Small_File_Length_Sec %3600
                        answer = questdlg('This is a very long file. Would you like to split it to a smaller files?', ...
                            'Huge file', ...
                            'Split', 'No', 'Split');
                        if strcmp(answer, 'Split')
                            SplitFile_Button_Callback();
                        end
                    end
                end
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
            h_e = errordlg('Please, enter correct values!', 'Input Error'); setLogo(h_e, DATA.Module);
        end
        GridX_checkbox_Callback;
        GridY_checkbox_Callback;
    end
%%
    function setECGXLim(minLimit, maxLimit)
        [~, ch_num] = size(DATA.sig);
        
        if ch_num ~= 12
            if isfield(GUI, 'ECG_Axes') && isvalid(GUI.ECG_Axes)
                set(GUI.ECG_Axes, 'XLim', [minLimit maxLimit]);
                setXECGGrid(GUI.ECG_Axes, GUI.GridX_checkbox);
                %             elseif isfield(GUI, 'PPG_Axes') && isvalid(GUI.PPG_Axes)
                %                 set(GUI.PPG_Axes, 'XLim', [minLimit maxLimit]);
                %                 setXECGGrid(GUI.PPG_Axes, GUI.GridX_checkbox);
            end
        end
    end
%%
    function [min_value, max_value] = CheckHandle_CalcMin(line_handle, minLimit, maxLimit)
        if ishandle(line_handle) && isvalid(line_handle)...
                && strcmp(line_handle.Visible,'on')
            y_data = line_handle.YData(DATA.tm >= minLimit & DATA.tm <= maxLimit);
            min_value = min(y_data);
            max_value = max(y_data);
        else
            min_value = NaN;
            max_value = NaN;
        end
    end
%%
    function setECGYLim(minLimit, maxLimit)
        [~, ch_num] = size(DATA.sig);
        
        if ch_num ~= 12
            try
                if ~isfield(GUI, 'RawChannelsData_handle')
                    
                    sig = DATA.sig(DATA.tm >= minLimit & DATA.tm <= maxLimit, 1);
                    
                    min_sig = min(sig);
                    max_sig = max(sig);
                else
                    [min_sig, max_sig] = CheckHandle_CalcMin(GUI.RawChannelsData_handle(1), minLimit, maxLimit);
                    
                    ch_data_no = length(GUI.RawChannelsData_handle);
                    
                    for i = 2 : ch_data_no
                        if strcmp(GUI.RawChannelsData_handle(i).Visible, 'on')
                            [min_value, max_value] = CheckHandle_CalcMin(GUI.RawChannelsData_handle(i), minLimit, maxLimit);
                            min_sig = min(min_sig, min_value);
                            max_sig = max(max_sig, max_value);
                        end
                    end
                end
            catch e
                disp(e.message);
            end
            
            if isfield(GUI, 'FilteredData_handle')
                for i = 1 : ch_data_no
                    if ishandle(GUI.FilteredData_handle(i)) && isvalid(GUI.FilteredData_handle(i))
                        [min_value, max_value] = CheckHandle_CalcMin(GUI.FilteredData_handle(i), minLimit, maxLimit);
                        
                        if ~isempty(min_value)
                            min_sig = min(min_sig, min_value);
                            max_sig = max(max_sig, max_value);
                        end
                    end
                end
            end
            
            if ~isnan(min_sig) && ~isnan(max_sig)
                
                delta = (max_sig - min_sig)*0.1;
                
                min_y_lim = min(min_sig, max_sig) - delta;
                max_y_lim = max(min_sig, max_sig) + delta;
                
                try
                    if isfield(GUI, 'ECG_Axes') && isvalid(GUI.ECG_Axes)
                        set(GUI.ECG_Axes, 'YLim', [min_y_lim max_y_lim]);
                        %                     elseif isfield(GUI, 'PPG_Axes') && isvalid(GUI.PPG_Axes)
                        %                         set(GUI.PPG_Axes, 'YLim', [min_y_lim max_y_lim]);
                    end
                catch e
                    disp(e.message);
                end
                GUI.GUIDisplay.MinYLimit_Edit.UserData = GUI.GUIDisplay.MinYLimit_Edit.String;
                GUI.GUIDisplay.MaxYLimit_Edit.UserData = GUI.GUIDisplay.MaxYLimit_Edit.String;
                set(GUI.GUIDisplay.MinYLimit_Edit, 'String', min_y_lim);
                set(GUI.GUIDisplay.MaxYLimit_Edit, 'String', max_y_lim);
                if isfield(GUI, 'ECG_Axes') && isvalid(GUI.ECG_Axes)
                    setYECGGrid(GUI.ECG_Axes, GUI.GridY_checkbox);
                end
            end
        end
    end
%%
    function setRRIntYLim()
        if GUI.AutoScaleYLowAxes_checkbox.Value
            [low_y_lim, hight_y_lim] = calc_auto_y_low_axes_lim();
            set(GUI.RRInt_Axes, 'YLim', [low_y_lim hight_y_lim]);
            
            set_min_max_low_axes_y_lim_string(low_y_lim, hight_y_lim);
        end
        set_rectangles_YData();
        setYHRGrid(GUI.RRInt_Axes, GUI.GridYHR_checkbox);
    end
%%
    function [low_y_lim, hight_y_lim] = calc_auto_y_low_axes_lim()
        xlim = get(GUI.RRInt_Axes, 'XLim');
        if GUI.FilterHR_checkbox.Value == 0
            current_y_data = GUI.RRInt_handle.YData(GUI.RRInt_handle.XData >= xlim(1) & GUI.RRInt_handle.XData <= xlim(2));
            low_y_lim = min(current_y_data);
            hight_y_lim = max(current_y_data);
        else
            if isfield(DATA, 'rr_data_filtered') && ~isempty(DATA.rr_data_filtered)
                
                current_y_data = DATA.rr_data_filtered(DATA.rr_time_filtered >= xlim(1) & DATA.rr_time_filtered <= xlim(2));
                
                low_y_lim = min(current_y_data);
                hight_y_lim = max(current_y_data);
            end
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
            h_e = errordlg('Please, enter correct values!', 'Input Error'); setLogo(h_e, DATA.Module);
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
                        set(params_GUI_edit_values(i), 'String', param_value, 'Tooltip', tooltip, 'Enable', 'on');
                    catch
                        set(params_GUI_edit_values(i), 'Enable', 'off');
                    end
                end
            end
            
            % Check that the upper frequency of the filter is below Fs/2
            if DATA.Fs/2 <= str2double(get(GUI.GUIConfig.hcf, 'String'))
                set(GUI.GUIConfig.hcf, 'String', floor(DATA.Fs/2) - 2);
                DATA.config_map(get(GUI.GUIConfig.hcf, 'UserData')) = str2double(get(GUI.GUIConfig.hcf, 'String'));
            end
            
            params_GUI_checkbox_values = findobj(GUI.ConfigBox, 'Style', 'Checkbox');
            fields_name = get(params_GUI_checkbox_values, 'UserData');
            for i = 1 : length(params_GUI_checkbox_values)
                if ~isempty(fields_name{i})
                    try
                        param_value = DATA.config_map(fields_name{i});
                        tooltip = DATA.config_struct.(fields_name{i}).description;
                        set(params_GUI_checkbox_values(i), 'Value', param_value, 'Tooltip', tooltip, 'Enable', 'on');
                    catch
                        %                         set(params_GUI_checkbox_values(i), 'Enable', 'off');
                    end
                end
            end
            
            if ~strcmp(DATA.Integration, 'PPG')
                DATA.customConfigFile = [tempdir 'gqrs.temp_custom.conf'];
                temp_custom_conf_fileID = saveCustomParameters(DATA.customConfigFile);
                if temp_custom_conf_fileID == -1
                    h_e = errordlg('Problems with creation of custom config file.', 'Input Error');
                    setLogo(h_e, DATA.Module);
                    return;
                end
            else
                DATA.customConfigFile = [tempdir 'temp_custom_ppg.yml'];
                DATA.config_struct = update_config_struct(DATA.config_map, DATA.config_struct);
                result_WriteYaml = WriteYaml(DATA.customConfigFile, DATA.config_struct);
                if result_WriteYaml ~= 0
                    h_e = errordlg('Problems with creation of custom config file.', 'Input Error');
                    setLogo(h_e, DATA.Module);
                    return;
                end
            end
        else
            throw(MException('LoadConfig:text', 'Config file does''t exist.'));
        end
    end
%%
    function clean_rhythms()
        GUI.RhythmsListbox.String = '';
        GUI.RhythmsListbox.UserData = [];
        GUI.GUIDisplay.MinRhythmsRange_Edit.String = '';
        GUI.GUIDisplay.MaxRhythmsRange_Edit.String = '';
        GUI.GUIDisplay.MinRhythmsRange_Edit.UserData = [];
        GUI.GUIDisplay.MaxRhythmsRange_Edit.UserData = [];
        
        DATA.Rhythms_Map = containers.Map('KeyType', 'double', 'ValueType', 'any');
        
        if isfield(GUI, 'rhythms_win')
            delete(GUI.rhythms_win);
            GUI = rmfield(GUI, 'rhythms_win');
            %             DATA.rhythms_win_num = 0;
        end
        DATA.rhythms_win_num = 0;
        
        if isfield(GUI, 'RhythmsHandle_AllDataAxes')
            delete(GUI.RhythmsHandle_AllDataAxes);
            GUI = rmfield(GUI, 'RhythmsHandle_AllDataAxes');
        end
        
        GUI.RhythmsTable.Data = {};
        GUI.RhythmsTable.RowName = {};
        
        reset_rhythm_button();
        %         Rhythms_ToggleButton_Reset();
        %         GUI.RhythmsHBox.Visible = 'off';
        
        GUI.RhythmsTable.Data = {};
        GUI.RhythmsTable.RowName = {};
        DATA.Rhythms_file_name = '';
        set(GUI.GUIRecord.RhythmsFileName_text, 'String', '');
    end
%%
    function RunAndPlotPeakDetector()
        if isfield(DATA, 'wfdb_record_name') && ~strcmp(DATA.wfdb_record_name, '')
            
            [~, ch_no] = size(DATA.sig);
            
            clean_rhythms();
            
            if isfield(GUI, 'ECG_Axes') && isvalid(GUI.ECG_Axes)
                legend(GUI.ECG_Axes, 'off');
            end
            %             if isfield(GUI, 'PPG_Axes') && isvalid(GUI.PPG_Axes)
            %                 legend(GUI.PPG_Axes, 'off');
            %             end
            if isfield(GUI, 'RRInt_Axes') && isvalid(GUI.RRInt_Axes)
                cla(GUI.RRInt_Axes);
            end
            
            if isfield(GUI, 'red_peaks_handle') && ishandle(GUI.red_peaks_handle) && isvalid(GUI.red_peaks_handle)
                delete(GUI.red_peaks_handle);
            end
            
            GUI.PQRST_position = {};
            
            if isfield(GUI, 'pebm_waves_table')
                GUI = rmfield(GUI, 'pebm_waves_table');
            end
            if isfield(GUI, 'pebm_intervals_table')
                GUI = rmfield(GUI, 'pebm_intervals_table');
            end
            GUI.pebm_intervals_stat = cell(1, ch_no);
            GUI.pebm_waves_stat = cell(1, ch_no);
            
            GUI.pebm_intervalsData = cell(1, ch_no);
            GUI.pebm_wavesData = cell(1, ch_no);
            
            GUI.ChannelsTable.Data(:, 4) = {false};
            GUI.ChannelsTable.Data(1, 4) = {true};
            
            clear_fiducials_handles();
            clear_fiducials_filt_handles();
            reset_fiducials_checkboxs();
            
            try
                if isfield(DATA, 'customConfigFile') && ~strcmp(DATA.customConfigFile, '')
                    
                    peak_detector = GUI.GUIRecord.PeakDetector_popupmenu.String{GUI.GUIRecord.PeakDetector_popupmenu.Value};
                    
                    waitbar_handle = waitbar(1/2, 'Compute peaks...', 'Name', 'Computing'); setLogo(waitbar_handle, DATA.Module);
                    
                    if ~strcmpi(peak_detector, 'rqrs') && ~strcmpi(peak_detector, 'egmbeat') && ~strcmpi(peak_detector, 'PPGdet')
                        
                        lcf = DATA.config_map('lcf');
                        hcf = DATA.config_map('hcf');
                        thr = DATA.config_map('thr');
                        rp  = DATA.config_map('rp');
                        ws  = DATA.config_map('ws');
                        
                        bpecg = mhrv.ecg.bpfilt(DATA.sig(:, 1), DATA.Fs, lcf, hcf, [], 0);  % bpecg = prefilter2(ecg,fs,lcf,hcf,0);
                    end
                    
                    if strcmp(peak_detector, 'jqrs')
                        qrs_pos = mhrv.ecg.jqrs(bpecg, DATA.Fs, thr, rp, 0); % qrs_pos = ptqrs(bpecg,fs,thr,rp,0);
                        DATA.qrs = qrs_pos';
                    elseif strcmp(peak_detector, 'wjqrs')
                        qrs_pos = mhrv.ecg.wjqrs(bpecg, DATA.Fs, thr, rp, ws);
                        DATA.qrs = qrs_pos';
                    elseif strcmp(peak_detector, 'egmbeat')
                        params_struct = struct();
                        
                        params_struct.Fs = DATA.Fs;
                        try
                            params_struct.ref_per = DATA.config_map('ref_per');
                            params_struct.bi = DATA.config_map('bi');
                            params_struct.init_prom_thresh = DATA.config_map('init_prom_thresh');
                            params_struct.classify_prom_thresh = DATA.config_map('classify_prom_thresh');
                            
                            qrs_pos = EGM_peaks(DATA.sig(:, 1), params_struct, 0);
                            DATA.qrs = qrs_pos;
                        catch
                            h_e = errordlg('The parameters for the EGM algorithms were not defined.', 'Input Error');
                            setLogo(h_e, DATA.Module);
                        end
                    elseif strcmpi(peak_detector, 'PPGdet')
                        try
                            [GUI.PQRST_position, GUI.fiducials_path] = PPG_peaks(DATA.wfdb_record_name, DATA.customConfigFile);
                            DATA.qrs = GUI.PQRST_position.sp + 1;
                        catch e
                            if isvalid(waitbar_handle)
                                close(waitbar_handle);
                            end
                            h_e = errordlg(['The PPG fiducials points were not found. ', e.message], 'Input Error'); setLogo(h_e, DATA.Module);
                            return;
                        end
                    else
                        if (exist(fullfile([DATA.wfdb_record_name '.dat']), 'file') || exist(fullfile([DATA.wfdb_record_name '.rdt']), 'file')) && exist(fullfile([DATA.wfdb_record_name '.hea']), 'file')
                            
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
                        DATA.qrs = unique(DATA.qrs);
                        DATA.qrs_saved = DATA.qrs;
                        DATA.qrs = double(DATA.qrs);
                        
                        if ch_no == 12
                            parent_axes = GUI.ECG_Axes_Array(1);
                            vis_ax = 'on';
                            coeff = 1;
                        else
                            parent_axes = GUI.ECG_Axes;
                            vis_ax = 'on';
                            % ---------------------------
                            if DATA.amp_counter(1) > 0
                                coeff = 1/(DATA.amp_ch_factor ^ DATA.amp_counter(1));
                            else
                                coeff = DATA.amp_ch_factor ^ abs(DATA.amp_counter(1));
                            end
                            % ---------------------------
                            plot_rr_data();
                            if ~strcmp(DATA.Integration, 'PPG')
                                TrendHR_checkbox_Callback(GUI.TrendHR_checkbox);
                            end
                            plot_red_rectangle(DATA.zoom_rect_limits);
                        end
                        
                        GUI.red_peaks_handle = line(DATA.tm(DATA.qrs), DATA.sig(DATA.qrs, 1), 'Parent', parent_axes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'MarkerSize', 5, 'LineWidth', 1, 'Tag', 'Peaks');
                        GUI.red_peaks_handle.Visible = vis_ax;
                        uistack(GUI.red_peaks_handle, 'top');  % bottom
                        
                        GUI.red_peaks_handle.YData = GUI.red_peaks_handle.YData / coeff;
                        
                        GUI.PeaksTable.Data(:, 2) = {0};
                        DATA.peaks_added = 0;
                        DATA.peaks_deleted = 0;
                        DATA.peaks_total = length(DATA.qrs);
                        GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
                        
                        set(GUI.GUIDisplay.FirstSecond, 'String', calcDuration(min(DATA.zoom_rect_limits), 0));
                        
                        WindowSize_value = max(DATA.zoom_rect_limits) - min(DATA.zoom_rect_limits);
                        GUI.GUIDisplay.WindowSize.String = calcDuration(WindowSize_value, 0);
                        GUI.GUIDisplay.WindowSize.UserData = WindowSize_value;
                        if ch_no ~= 12
                            set(GUI.GUIDisplay.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
                            set(GUI.RRInt_Axes, 'XLim', [0 DATA.maxRRTime]);
                            setAxesXTicks(GUI.RRInt_Axes);
                            setRRIntYLim();
                            EnablePageUpDown();
                        end
                    else
                        GUI.PeaksTable.Data(:, 2) = {0};
                        DATA.peaks_added = 0;
                        DATA.peaks_deleted = 0;
                        DATA.peaks_total = length(DATA.qrs);
                        GUI.PeaksTable.Data(1, 2) = {DATA.peaks_total};
                        h_e = errordlg('The algorithm could not run. Please, check input parameters.', 'Input Error');
                        setLogo(h_e, DATA.Module);
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
            if ch_no ~= 12 && ~isempty(DATA.qrs)
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
            if ~isempty(DATA.qrs) && ~all(isnan(DATA.qrs))
                if strcmp(DATA.Mammal, 'human')
                    GUI.CalcPeaksButton_handle.Enable = 'on';
                else
                    GUI.CalcPeaksButton_handle.Enable = 'inactive';
                end
            else
                GUI.CalcPeaksButton_handle.Enable = 'inactive';
            end
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
    function [rr_time, rr_data, yString] = calc_rr()
        
        qrs = double(DATA.qrs(~isnan(DATA.qrs)));
        
        rr_time = qrs(1:end-1)/DATA.Fs;
        rr_data = diff(qrs)/DATA.Fs;
        
        if isempty(rr_data)
            throw(MException('plot_rr_data:text', 'Not enough datapoints!'));
        else
            if DATA.PlotHR == 1
                rr_data = 60 ./ rr_data;
                yString = 'HR (BPM)';
            else
                yString = 'RR (sec)';
            end
        end
    end
%%
    function plot_rr_data()
        if isfield(DATA, 'qrs')
            
            DATA.maxRRTime = max(DATA.tm);
            
            if ~strcmp(DATA.Integration, 'PPG')
                try
                    [rr_time, rr_data, yString] = calc_rr();
                    GUI.RRInt_handle = line(rr_time, rr_data, 'Parent', GUI.RRInt_Axes, 'LineWidth', 0.5, 'Tag', 'RRInt'); % 'Marker', '*', 'MarkerSize', 2,
                    DATA.RRIntPage_Length = max(rr_time);
                catch e
                    rethrow(e);
                end
            else
                GUI.RRInt_handle = line(DATA.tm, DATA.sig(:, 1), 'Parent', GUI.RRInt_Axes, 'LineWidth', 0.5, 'Tag', 'RRInt');
                yString = '';
                DATA.RRIntPage_Length = DATA.maxRRTime;
            end
            
            ylabel(GUI.RRInt_Axes, yString, 'FontName', 'Times New Roman');
            
            if ~strcmp(DATA.Integration, 'PPG')
                if length(rr_data) == 1
                    DATA.rr_data_filtered = rr_data;
                    DATA.rr_time_filtered = rr_time;
                else
                    try
                        f_n = [DATA.Mammal '_' DATA.integration_level{DATA.integration_index}];
                        mhrv.defaults.mhrv_load_defaults(f_n);
                        %                     win_samples = mhrv.defaults.mhrv_get_default('filtrr.moving_average.win_length', 'value');
                        %                     win_samples = mhrv.defaults.mhrv_get_default('filtrr.moving_average.win_length', 'value');
                        
                        rr_min = mhrv.defaults.mhrv_get_default('filtrr.range.rr_min', 'value');
                        rr_max = mhrv.defaults.mhrv_get_default('filtrr.range.rr_max', 'value');
                        
                        if DATA.PlotHR == 1
                            rr_min_t = 60 ./ rr_min;
                            rr_max_t = 60 ./ rr_max;
                            rr_min = min(rr_min_t, rr_max_t);
                            rr_max = max(rr_min_t, rr_max_t);
                        end
                    catch e
                        h_e = errordlg(['File "' f_n '.yml" does''t exists.'], 'Input Error'); setLogo(h_e, DATA.Module);
                        rethrow(e);
                    end
                    try
                        [rr_data_filtered, rr_time_filtered, ~] = mhrv.rri.filtrr(rr_data, rr_time, 'filter_quotient', false, 'filter_ma', false, 'filter_range', true, 'rr_min', rr_min, 'rr_max', rr_max);
                        
                        if isempty(rr_data_filtered)
                            throw(MException('mhrv_rri_filtrr:text', 'Not enough datapoints!'));
                        elseif length(rr_data) * 0.1 > length(rr_data_filtered)
                            throw(MException('mhrv_rri_filtrr:text', 'Not enough datapoints!'));
                        else
                            DATA.rr_data_filtered = rr_data_filtered;
                            DATA.rr_time_filtered = rr_time_filtered;
                        end
                    catch e
                        DATA.rr_data_filtered = rr_data;
                        DATA.rr_time_filtered = rr_time;
                        h_e = warndlg(['filtrr error: ', e.message], 'Warning');
                        setLogo(h_e, DATA.Module);
                    end
                end
            else
                DATA.rr_data_filtered = [];
                DATA.rr_time_filtered = [];
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
            
            try
                set_new_mammal(DATA.customConfigFile);
            catch
                h_e = errordlg('LoadConfigurationFile_Callback error: Please, choose right config file format!', 'Input Error');
                setLogo(h_e, DATA.Module);
                return;
            end
            
            if get(GUI.AutoCalc_checkbox, 'Value')
                try
                    RunAndPlotPeakDetector();
                    if DATA.Adjust % no default
                        PeakAdjustment(DATA.qrs_saved);
                    end
                catch e
                    h_e = errordlg(['LoadConfigurationFile error: ' e.message], 'Input Error');
                    setLogo(h_e, DATA.Module);
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
            
            %             config_keys = keys(DATA.config_map);
            %             for i = 1 : length(config_keys)
            %                 curr_field = config_keys{i};
            %                 if isstruct(DATA.config_struct.(curr_field))
            %                     DATA.config_struct.(curr_field).value = DATA.config_map(curr_field);
            %                 else
            %                     DATA.config_struct.(curr_field) = DATA.config_map(curr_field);
            %                 end
            %             end
            DATA.config_struct = update_config_struct(DATA.config_map, DATA.config_struct);
            if strcmp(button, 'Yes')
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
                h_e = errordlg('Please, enter numeric value.', 'Input Error'); setLogo(h_e, DATA.Module);
                set(src, 'String', DATA.config_map(get(src, 'UserData')));
                return;
            elseif strcmp(get(src, 'UserData'), 'rp') && ~(numeric_field_value >= 0)
                h_e = errordlg('The refractory period must be greater or equal to 0.', 'Input Error');
                setLogo(h_e, DATA.Module);
                set(src, 'String', DATA.config_map(get(src, 'UserData')));
                return;
            elseif strcmp(get(src, 'UserData'), 'hcf_ppg') && (numeric_field_value < 0 || numeric_field_value > 20)
                h_e = errordlg('The Upper cutoff frequency must be greater or equal to 0 and less then 20.', 'Input Error');
                setLogo(h_e, DATA.Module);
                set(src, 'String', DATA.config_map(get(src, 'UserData')));
                return;
            elseif strcmp(get(src, 'UserData'), 'lcf_ppg') && (numeric_field_value < 0 || numeric_field_value > 20)
                h_e = errordlg('The Low cutoff frequency must be greater or equal to 0 and less then 20.', 'Input Error');
                setLogo(h_e, DATA.Module);
                set(src, 'String', DATA.config_map(get(src, 'UserData')));
                return;
            elseif strcmp(get(src, 'UserData'), 'order') && ~(ismember(numeric_field_value, [0:1:4]))
                h_e = errordlg('The order must be only integer between 0 and 4.', 'Input Error');
                setLogo(h_e, DATA.Module);
                set(src, 'String', DATA.config_map(get(src, 'UserData')));
                return;
            elseif (numeric_field_value <= 0) && ~(strcmp(get(src, 'UserData'), 'rp') || strcmp(get(src, 'UserData'), 'hcf_ppg') || strcmp(get(src, 'UserData'), 'lcf_ppg'))
                h_e = errordlg('The value must be greater then 0.', 'Input Error');
                setLogo(h_e, DATA.Module);
                set(src, 'String', DATA.config_map(get(src, 'UserData')));
                return;
            end
            if strcmp(get(src, 'UserData'), 'hcf') && (numeric_field_value > DATA.Fs/2)
                h_e = errordlg('The upper cutoff frequency must be inferior to half of the sampling frequency.', 'Input Error');
                setLogo(h_e, DATA.Module);
                set(src, 'String', DATA.config_map(get(src, 'UserData')));
                return;
            end
            
            if strcmp(get(src, 'UserData'), 'bi')
                if (numeric_field_value < 0 || numeric_field_value > 20000)
                    h_e = errordlg('The beating interval must be in the range of 0 - 20000.', 'Input Error');
                    setLogo(h_e, DATA.Module);
                    set(src, 'String', DATA.config_map(get(src, 'UserData')));
                    return;
                end
                if numeric_field_value <= DATA.config_map('ref_per')
                    h_e = errordlg('The beating interval must be greater than refractory period.', 'Input Error');
                    setLogo(h_e, DATA.Module);
                    set(src, 'String', DATA.config_map(get(src, 'UserData')));
                    return;
                end
            end
            
            if strcmp(get(src, 'UserData'), 'ref_per')
                if (numeric_field_value < 0 || numeric_field_value > 20000)
                    h_e = errordlg('The refractory period must be in the range of 0 - 20000', 'Input Error');
                    setLogo(h_e, DATA.Module);
                    set(src, 'String', DATA.config_map(get(src, 'UserData')));
                    return;
                elseif numeric_field_value > DATA.config_map('bi')
                    h_e = errordlg('The beating interval must be greater than refractory period.', 'Input Error');
                    setLogo(h_e, DATA.Module);
                    set(src, 'String', DATA.config_map(get(src, 'UserData')));
                    return;
                end
            end
            
            if isfield(DATA, 'config_map') && ~isempty(DATA.config_map)
                DATA.config_map(get(src, 'UserData')) = numeric_field_value;
                
                if ~strcmp(DATA.Integration, 'PPG')
                    DATA.customConfigFile = [tempdir 'gqrs.temp_custom.conf'];
                    temp_custom_conf_fileID = saveCustomParameters(DATA.customConfigFile);
                    if temp_custom_conf_fileID == -1
                        h_e = errordlg('Problems with creation of custom config file.', 'Input Error');
                        setLogo(h_e, DATA.Module);
                        return;
                    end
                else
                    DATA.customConfigFile = [tempdir 'temp_custom_ppg.yml'];
                    DATA.config_struct = update_config_struct(DATA.config_map, DATA.config_struct);
                    result_WriteYaml = WriteYaml(DATA.customConfigFile, DATA.config_struct);
                    if result_WriteYaml ~= 0
                        h_e = errordlg('Problems with creation of custom config file.', 'Input Error');
                        setLogo(h_e, DATA.Module);
                        return;
                    end
                end
                if get(GUI.AutoCalc_checkbox, 'Value')
                    try
                        RunAndPlotPeakDetector();
                        set(GUI.GUIRecord.PeakAdjustment_popupmenu, 'Value', 1);
                        [~, ch_num] = size(DATA.sig);
                        if ch_num == 12
                            parent_axes = GUI.ECG_Axes_Array(1);
                            ch_marker_size = 4;
                        else
                            parent_axes = GUI.ECG_Axes;
                            ch_marker_size = 5;
                        end
                        create_fiducials_filt_handles(1, ch_marker_size, parent_axes);
                        set_fid_visible(1);
                        if ch_num == 12
                            set12LEDYLim();
                        end
                        if isfield(GUI, 'red_rect_handle') && isvalid(GUI.red_rect_handle)
                            xdata = get(GUI.red_rect_handle, 'XData');
                            setECGYLim(xdata(1), xdata(2));
                        end
                    catch e
                        h_e = errordlg(['config_edit_Callback error: ' e.message], 'Input Error');
                        setLogo(h_e, DATA.Module);
                        return;
                    end
                end
            end
        end
    end
%%
    function apply_filter_ppg_checkbox_Callback(src, ~)
        if isfield(DATA, 'config_map')
            field_value = get(src, 'Value');
            if isfield(DATA, 'config_map') && ~isempty(DATA.config_map)
                DATA.config_map(get(src, 'UserData')) = field_value;
                if strcmp(DATA.Integration, 'PPG')
                    DATA.customConfigFile = [tempdir 'temp_custom_ppg.yml'];
                    DATA.config_struct = update_config_struct(DATA.config_map, DATA.config_struct);
                    result_WriteYaml = WriteYaml(DATA.customConfigFile, DATA.config_struct);
                    if result_WriteYaml ~= 0
                        h_e = errordlg('Problems with creation of custom config file.', 'Input Error'); setLogo(h_e, DATA.Module);
                        return;
                    end
                    if get(GUI.AutoCalc_checkbox, 'Value')
                        try
                            clear_fiducials_handles();
                            clear_fiducials_filt_handles();
                            reset_fiducials_checkboxs();
                            RunAndPlotPeakDetector();
                            if isfield(GUI, 'red_rect_handle') && isvalid(GUI.red_rect_handle)
                                xdata = get(GUI.red_rect_handle, 'XData');
                                setECGYLim(xdata(1), xdata(2));
                            end
                        catch e
                            h_e = errordlg(['apply_filter_ppg_checkbox_Callback error: ' e.message], 'Input Error'); setLogo(h_e, DATA.Module);
                            return;
                        end
                    end
                end
            end
        end
    end
%%
    function NotchFilter_popupmenu_Callback(~, ~)
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
                    setLogo(h_e, DATA.Module);
                    return;
                end
            else
                set(src, 'String', num2str(DATA.peak_search_win));
                h_e = errordlg('The window length for peak detection must be greater than 0 and less than 1 sec.', 'Input Error');
                setLogo(h_e, DATA.Module);
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
        if exist([tempdir DATA.temp_rec_name4wfdb '.mat'], 'file')
            delete([tempdir DATA.temp_rec_name4wfdb '.mat']);
        end
        if exist([tempdir 'tempYAML.yml'], 'file')
            delete([tempdir 'tempYAML.yml']);
        end
        try
            rmdir([tempdir 'PPG_temp_dir'], 's');
        catch
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
                                setLogo(h_e, DATA.Module);
                                uiwait(h_e);
                            end
                        else
                            h_e = errordlg(['on Load Peaks error: ' 'Please, choose another file type.'], 'Input Error');
                            setLogo(h_e, DATA.Module);
                            return;
                        end
                    elseif strcmp(Config.alarm.(MSG), 'Canceled')
                        return;
                    else
                        h_e = errordlg(['on Load Peaks error: ' Config.alarm.(MSG)], 'Input Error');
                        setLogo(h_e, DATA.Module);
                        return;
                    end
                catch e
                    h_e = errordlg(['onOpenFile error: ' e.message], 'Input Error');
                    setLogo(h_e, DATA.Module);
                    rethrow(e);
                    %                     return;
                end
            else
                h_e = errordlg(['on Load Peaks error: ' 'Please, choose another file type.'], 'Input Error');
                setLogo(h_e, DATA.Module);
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
                
                try
                    delete(GUI.FilteredData_handle);
                    GUI = rmfield(GUI, 'FilteredData_handle');
                catch
                end
                
                GUI.ChannelsTable.Data(:, 3) = {false};
                GUI.ChannelsTable.Data(:, 4) = {false};
                GUI.ChannelsTable.Data(1, 4) = {true};
                
                clear_fiducials_handles();
                clear_fiducials_filt_handles();
                reset_fiducials_checkboxs();
                
                DATA.qrs = double(DATA.qrs);
                GUI.red_peaks_handle = line(DATA.tm(DATA.qrs), DATA.sig(DATA.qrs, 1), 'Parent', GUI.ECG_Axes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'MarkerSize', 5, 'LineWidth', 1, 'Tag', 'Peaks');
                uistack(GUI.red_peaks_handle, 'top');
                
                %  ---------------------------
                if DATA.amp_counter(1) > 0
                    coeff = 1/(DATA.amp_ch_factor ^ DATA.amp_counter(1));
                else
                    coeff = DATA.amp_ch_factor ^ abs(DATA.amp_counter(1));
                end
                GUI.red_peaks_handle.YData = GUI.red_peaks_handle.YData / coeff;
                % ---------------------------
                
                if isfield(GUI, 'RRInt_handle') && ishandle(GUI.RRInt_handle) && isvalid(GUI.RRInt_handle)
                    delete(GUI.RRInt_handle);
                end
                try
                    %                     delete(GUI.red_rect_handle);
                    %                     delete(GUI.RRInt_handle);
                    
                    if isfield(GUI, 'red_rect_handle') && ishandle(GUI.red_rect_handle) && isvalid(GUI.red_rect_handle)
                        delete(GUI.red_rect_handle);
                    end
                    
                    plot_rr_data();
                    TrendHR_checkbox_Callback(GUI.TrendHR_checkbox);
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
                    
                    set(GUI.Window, 'WindowScrollWheelFcn', @my_WindowScrollWheelFcn);
                    set(GUI.Window, 'WindowKeyPressFcn', @my_WindowKeyPressFcn);
                    set(GUI.Window, 'WindowKeyReleaseFcn', @my_WindowKeyReleaseFcn);
                    
                    GUI.timer_object = timer;
                    GUI.timer_object.ExecutionMode = 'fixedRate';
                    GUI.timer_object.StopFcn = @EnablePageUpDown;
                catch e
                    disp(e.message);
                end
            else
                h_e = errordlg('The algorithm could not run. Please, check input parameters.', 'Input Error');
                setLogo(h_e, DATA.Module);
            end
            
            if ~isempty(DATA.qrs) && ~all(isnan(DATA.qrs))
                if strcmp(DATA.Mammal, 'human')
                    GUI.CalcPeaksButton_handle.Enable = 'on';
                else
                    GUI.CalcPeaksButton_handle.Enable = 'inactive';
                end
            else
                GUI.CalcPeaksButton_handle.Enable = 'inactive';
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
                setLogo(h_e, DATA.Module);
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
            h_e = errordlg(['AutoCompute pushbutton callback error: ' e.message], 'Input Error'); setLogo(h_e, DATA.Module);
            return;
        end
    end
%%
    function AutoCalc_checkbox_Callback(src, ~ )
        if src.Value
            GUI.AutoCompute_pushbutton.Enable = 'off';
        else
            GUI.AutoCompute_pushbutton.Enable = 'on';
        end
    end
%%
    function RR_or_HR_plot_button_Callback(~, ~)
        if ~strcmp(DATA.Integration, 'PPG')
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
                    FilterHR_checkbox_Callback(GUI.FilterHR_checkbox);
                    [low_y_lim, hight_y_lim] = calc_auto_y_low_axes_lim();
                    set(GUI.RRInt_Axes, 'YLim', [low_y_lim hight_y_lim]);
                    plot_red_rectangle(DATA.zoom_rect_limits);
                    
                    set_min_max_low_axes_y_lim_string(low_y_lim, hight_y_lim);
                    
                    set_rectangles_YData();
                catch e
                    disp(e.message);
                end
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
            
            ch_num = length(GUI.RawChannelsData_handle);
            
            GUI.RawData_handle.Visible = 'on';
            
            if ch_num ~= 12
                GUI.ChannelsTable.Data(:, 2) = {false};
            else
                GUI.ChannelsTable.Data(:, 2) = {true};
            end
            GUI.ChannelsTable.Data(1, 2) = {true};
            GUI.ChannelsTable.Data(:, 4) = {false};
            GUI.ChannelsTable.Data(1, 4) = {true};
            GUI.ChannelsTable.Data(:, 3) = {false};
            
            GUI.PQRST_position = {};
            
            GUI.RawSignal_checkbox.Value = 1;
            
            for i = 1 : ch_num
                GUI.RawChannelsData_handle(i).Visible = 'on';
                GUI.ChannelsTable.UserData = i;
                if ch_num ~= 12
                    amp_plus_minus_pushbutton_Callback(GUI.ChAmpSourceButton);
                    GUI.RawChannelsData_handle(i).Visible = 'off';
                end
            end
            GUI.ChannelsTable.UserData = [];
            GUI.RawChannelsData_handle(1).Visible = 'on';
            
            DATA.amp_counter = zeros(1, length(GUI.RawChannelsData_handle));
            
            if isfield(GUI, 'quality_win')
                delete(GUI.quality_win);
                
                GUI = rmfield(GUI, 'quality_win');
                
                DATA.quality_win_num = 0;
                DATA.peaks_total = 0;
                DATA.peaks_bad_quality = 0;
            end
            
            clear_fiducials_handles();
            clear_fiducials_filt_handles();
            reset_fiducials_checkboxs();
            
            if isfield(GUI, 'PinkLineHandle_AllDataAxes')
                delete(GUI.PinkLineHandle_AllDataAxes);
                GUI = rmfield(GUI, 'PinkLineHandle_AllDataAxes');
            end
            
            GUI.AutoCalc_checkbox.Value = 1;
            GUI.RR_or_HR_plot_button.String = 'Plot HR';
            DATA.PlotHR = 1;
            set(GUI.GUIRecord.PeaksFileName_text, 'String', '');
            set(GUI.GUIRecord.DataQualityFileName_text, 'String', '');
            set(GUI.GUIRecord.RhythmsFileName_text, 'String', '');
            
            GUI.GUIRecord.Annotation_popupmenu.Value = 1;
            
            GUI.Adjustment_Text.String = 'Peak adjustmen';
            GUI.GUIRecord.PeakAdjustment_popupmenu.Value = 1;
            GUI.GUIRecord.PeakAdjustment_popupmenu.String = DATA.Adjustment_type;
            GUI.GUIRecord.PeakAdjustment_popupmenu.Callback = @PeakAdjustment_popupmenu_Callback;
            
            if strcmp(DATA.Integration, 'PPG')
                GUI.GUIRecord.Annotation_popupmenu.Enable = 'off';
                GUI.GUIRecord.PeakAdjustment_popupmenu.Enable = 'off';
                GUI.TrendHR_checkbox.Enable = 'off';
                GUI.FilterHR_checkbox.Enable = 'off';
                GUI.FilteredSignal_checkbox.Enable = 'off';
                GUI.DispRhythmsHBox.Visible = 'off';
                GUI.RhythmsRangeHBox.Visible = 'off';
                
                GUI.Derivatives_Ratios_Table.Data = {};
                GUI.Signal_Ratios_Table.Data = {};
                GUI.PPG_Derivatives_Table.Data = {};
                GUI.PPG_Signal_Table.Data = {};
            else
                GUI.GUIRecord.Annotation_popupmenu.Enable = 'on';
                GUI.GUIRecord.PeakAdjustment_popupmenu.Enable = 'on';
                GUI.TrendHR_checkbox.Enable = 'on';
                GUI.FilterHR_checkbox.Enable = 'on';
                GUI.FilteredSignal_checkbox.Enable = 'on';
                GUI.DispRhythmsHBox.Visible = 'on';
                GUI.RhythmsRangeHBox.Visible = 'on';
            end
            
            DATA.Adjust = 0;
            
            GUI.GridX_checkbox.Value = 1;
            GUI.GridY_checkbox.Value = 1;
            
            GUI.TrendHR_checkbox.Value = 1;
            GUI.FilterHR_checkbox.Value = 0;
            GUI.GridYHR_checkbox.Value = 1;
            
            try
                delete(GUI.FilteredData_handle);
                GUI = rmfield(GUI, 'FilteredData_handle');
            catch
            end
            
            try
                set_new_mammal(DATA.init_config_file_name);
            catch
                h_e = errordlg('Reset_pushbutton_Callback error: Please, choose right config file format!', 'Input Error');
                setLogo(h_e, DATA.Module);
                return;
            end
            
            if ch_num ~= 12
                reset_movie_buttons();
            end
            GUI.GUIDisplay.Movie_Delay.String = 2;
            
            GUI.AutoScaleY_checkbox.Value = 1;
            GUI.AutoScaleYLowAxes_checkbox.Value = 1;
            
            set(GUI.GUIDisplay.MinYLimitLowAxes_Edit, 'UserData', []);
            set(GUI.GUIDisplay.MaxYLimitLowAxes_Edit, 'UserData', []);
            
            set(GUI.GUIDisplay.MinYLimit_Edit, 'UserData', '');
            set(GUI.GUIDisplay.MaxYLimit_Edit, 'UserData', '');
            
            clean_rhythms();
            
            Rhythms_ToggleButton_Reset();
            GUI.RhythmsHBox.Visible = 'off';
            
            GUI.FilteredSignal_checkbox.Value = 0;
            GUI.GUIDisplay.FilterLevel_popupmenu.Value = 1;
            
            GUI.FilterLevelBox.Visible = 'off';
            GUI.CutoffFrBox.Visible = 'off';
            set_default_filter_level_user_data();
            
            GUI.GUIDir.Split_Sec.String = DATA.Small_File_Length_Sec;
            GUI.GUIDir.Split_Sec.UserData = DATA.Small_File_Length_Sec;
            
            legend(GUI.ECG_Axes, 'off');
            
            GUI.Fiducials_winStart.String = calcDuration(0, 0);
            GUI.Fiducials_winLength.String = calcDuration(min(300, max(DATA.tm)), 0);
            
            GUI.Fiducials_winStart.UserData = 0;
            GUI.Fiducials_winLength.UserData = min(300, max(DATA.tm)); % 300 sec
            
            if isfield(GUI, 'pebm_waves_table')
                GUI = rmfield(GUI, 'pebm_waves_table');
            end
            if isfield(GUI, 'pebm_intervals_table')
                GUI = rmfield(GUI, 'pebm_intervals_table');
            end
            GUI.pebm_intervals_stat = cell(1, ch_num);
            GUI.pebm_waves_stat = cell(1, ch_num);
            
            GUI.pebm_intervalsData = cell(1, ch_num);
            GUI.pebm_wavesData = cell(1, ch_num);
            
            GUI.Rhythms_handle.Enable = 'inactive';
            
            GUI.BandpassFilter_checkbox.Value = 1;
            GUI.GUIConfig.NotchFilter_popupmenu.Value = 1;
            
            GUI.PPGFilter_checkbox.Value = 1;
            GUI.GUIConfig.Order.String = '';
            GUI.GUIConfig.Order.UserData = '';
            GUI.GUIConfig.PPG_Filt_Low_Edit.String = '';
            GUI.GUIConfig.PPG_Filt_Low_Edit.UserData = '';
            GUI.GUIConfig.PPG_Filt_Hight_Edit.String = '';
            GUI.GUIConfig.PPG_Filt_Hight_Edit.UserData = '';
            
            try
                RunAndPlotPeakDetector();
            catch e
                h_e = errordlg(['AutoCompute_pushbutton_Callback error: ' e.message], 'Input Error');
                setLogo(h_e, DATA.Module);
                return;
            end
            if ch_num == 12
                set12LEDYLim();
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
                        
                        r_start = GUI.RhythmsListbox.UserData(GUI.RhythmsListbox.Value);
                        if r_start == rhythms_starts{i}
                            rhythms_struct.rhythm_handle.LineWidth = 3;
                        else
                            rhythms_struct.rhythm_handle.LineWidth = 1;
                        end
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
            
            %             reset_rhythm_linewidth_bottomaxes();
            
            if isfield(GUI, 'RhythmsHandle_AllDataAxes')  && any(isvalid(GUI.RhythmsHandle_AllDataAxes))
                prev_rhythms_win_num = length(GUI.RhythmsHandle_AllDataAxes);
            else
                prev_rhythms_win_num = 0;
            end
            
            qd_size = size(DATA_QualityAnnotations_Data);
            intervals_num = qd_size(1);
            
            ylim = get(GUI.RRInt_Axes, 'YLim');
            f = [1 2 3 4];
            
            for i = 1 : intervals_num
                
                reset_rhythm_linewidth_bottomaxes();
                
                [is_member, class_ind] = ismember(DATA_Class{i}, DATA.Rhythms_Type);
                if ~is_member
                    class_ind = 1;
                end
                %                 ylim = get(GUI.RRInt_Axes, 'YLim');
                %                 f = [1 2 3 4];
                
                rhythm_start = DATA_QualityAnnotations_Data(i,1);
                rhythm_end = DATA_QualityAnnotations_Data(i,2);
                
                v = [rhythm_start min(ylim); rhythm_end min(ylim); rhythm_end max(ylim); rhythm_start max(ylim)];
                
                patch_handle = patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.rhythms_color{class_ind}, 'EdgeColor', DATA.rhythms_color{class_ind}, ...
                    'LineWidth', 2, 'FaceAlpha', 0.4, 'EdgeAlpha', 0.85, 'UserData', class_ind, 'Parent', GUI.RRInt_Axes, 'Tag', 'RRIntRhythms');
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
        
        reset_rhythm_linewidth_topaxes();
        
        ylim = get(GUI.ECG_Axes, 'YLim');
        
        v = [min(rhythms_range) min(ylim); max(rhythms_range) min(ylim); max(rhythms_range) max(ylim); min(rhythms_range) max(ylim)];
        f = [1 2 3 4];
        
        patch_handle = patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.rhythms_color{rhythms_class}, 'EdgeColor', DATA.rhythms_color{rhythms_class}, ...
            'LineWidth', 3, 'FaceAlpha', 0.4, 'EdgeAlpha', 0.5, 'UserData', rhythms_class, 'Parent', GUI.ECG_Axes, 'Tag', 'DataRhythms', ...
            'Visible', 'on'); % 'FaceAlpha', 0.1
        %         GUI.rhythms_win(rhythms_win_num)
        uistack(patch_handle, 'bottom'); % GUI.rhythms_win(rhythms_win_num)
    end
%%
    function reset_rhythm_button()
        %         GUI.Rhythms_handle.String = 'Rhythms';
        %         GUI.Rhythms_handle.BackgroundColor = [52 204 255]/255;
        
        try
            GUI.hT.Visible = 'off';
        catch
        end
    end
%%
    function update_rhythm_button(r_m_num)
        rhythm_name = DATA.Rhythms_Type{r_m_num};
        %         GUI.Rhythms_handle.String = (rhythm_name);
        %         GUI.Rhythms_handle.BackgroundColor = DATA.rhythms_color{r_m_num};
        
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
                        
                        %                         classes = get(GUI.GUIRecord.Class_popupmenu, 'String');
                        %                         quality_class = GUI.GUIRecord.Class_popupmenu.Value;
                        
                        classes = get(GUI.GUIRecord.PeakAdjustment_popupmenu, 'String');
                        quality_class = GUI.GUIRecord.PeakAdjustment_popupmenu.Value;
                        
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
                        
                        %                         classes = get(GUI.GUIRecord.Rhythms_popupmenu, 'String');
                        %                         rhythms_class = GUI.GUIRecord.Rhythms_popupmenu.Value;
                        
                        classes = get(GUI.GUIRecord.PeakAdjustment_popupmenu, 'String');
                        rhythms_class = GUI.GUIRecord.PeakAdjustment_popupmenu.Value;
                        
                        rhythms_handle = plot_rhythms_rect(rhythms_range, 0, rhythms_class); % DATA.rhythms_win_num
                        
                        %                         rhythms_handle.LineWidth = 3;
                        
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
                        
                        Update_Rhythms_ListBox(rhythms_struct);
                        
                        %                         CurrentName = {[rhythms_struct.rhythm_type '_' num2str(min(rhythms_range))]};
                        %                         if isempty(GUI.RhythmsListbox.String)
                        %                             GUI.RhythmsListbox.String = CurrentName;
                        %                             GUI.RhythmsListbox.UserData = min(rhythms_range);
                        %                         else
                        %                             GUI.RhythmsListbox.String(end+1) = CurrentName;
                        %                             GUI.RhythmsListbox.UserData = [GUI.RhythmsListbox.UserData min(rhythms_range)];
                        %                             GUI.RhythmsListbox.Value = length(GUI.RhythmsListbox.String);
                        %                         end
                        %
                        %                         GUI.GUIDisplay.MinRhythmsRange_Edit.String = min(rhythms_range);
                        %                         GUI.GUIDisplay.MaxRhythmsRange_Edit.String = max(rhythms_range);
                        
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
        %         type
        %         if isfield(DATA, 'hObject')
        %             DATA.hObject
        %         else
        %             'NO'
        %         end
        switch type
            case 'init'
                reset_rhythm_button();
                annotation = get(GUI.GUIRecord.Annotation_popupmenu, 'Value');
                integration = DATA.Integration;
                
                if annotation == 1 && ((hittest(GUI.Window) == GUI.RawData_handle || get(hittest(GUI.Window), 'Parent') == GUI.RawData_handle)) && ~strcmp(integration, 'PPG') % ECG data
                    setptr(GUI.Window, 'datacursor');
                    DATA.hObject = 'add_del_peak';
                elseif annotation == 1 && (hittest(GUI.Window) == GUI.ECG_Axes) && ~strcmp(integration, 'PPG') %  || get(hittest(GUI.Window), 'Parent') == GUI.ECG_Axes % white space, draw del rect
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
        
        if isvalid(GUI.timer_object) && strcmp(GUI.timer_object.Running, 'on')
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
                                
                                CurrentName = [rhythms_struct.rhythm_type, '_', num2str(min(rhythms_range))];
                                iGroup = ismember(GUI.RhythmsListbox.String, CurrentName);
                                GUI.RhythmsListbox.Value = 1;
                                GUI.RhythmsListbox.String = GUI.RhythmsListbox.String(~iGroup);
                                GUI.RhythmsListbox.UserData = GUI.RhythmsListbox.UserData(~iGroup);
                                
                                if ~isempty(GUI.RhythmsListbox.String)
                                    
                                    reset_rhythm_linewidth_topaxes();
                                    reset_rhythm_linewidth_bottomaxes();
                                    
                                    r_h = DATA.Rhythms_Map(GUI.RhythmsListbox.UserData(1));
                                    r_h.low_axes_patch_handle.LineWidth = 2;
                                    r_h.rhythm_handle.LineWidth = 3;
                                    
                                    r_r = r_h.rhythm_range;
                                    
                                    GUI.GUIDisplay.MinRhythmsRange_Edit.String = calcDuration(r_r(1), 0, 1);
                                    GUI.GUIDisplay.MaxRhythmsRange_Edit.String = calcDuration(r_r(2), 0, 1);
                                    GUI.GUIDisplay.MinRhythmsRange_Edit.UserData = r_r(1);
                                    GUI.GUIDisplay.MaxRhythmsRange_Edit.UserData = r_r(2);
                                    
                                else
                                    GUI.GUIDisplay.MinRhythmsRange_Edit.String = '';
                                    GUI.GUIDisplay.MaxRhythmsRange_Edit.String = '';
                                    GUI.GUIDisplay.MinRhythmsRange_Edit.UserData = [];
                                    GUI.GUIDisplay.MaxRhythmsRange_Edit.UserData = [];
                                end
                                
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
            nearest_point_value = DATA.sig(nearest_point_ind, 1);
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
                    [new_peak, ind_new_peak] = min(DATA.sig(DATA.tm>=x_min & DATA.tm<=x_max, 1));
                else
                    [new_peak, ind_new_peak] = max(DATA.sig(DATA.tm>=x_min & DATA.tm<=x_max, 1));
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
                GUI.red_peaks_handle = line(temp_XData, temp_YData, 'Parent', GUI.ECG_Axes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'MarkerSize', 5, 'LineWidth', 1, 'Tag', 'Peaks');
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
            TrendHR_checkbox_Callback(GUI.TrendHR_checkbox);
            plot_red_rectangle(DATA.zoom_rect_limits);
            setRRIntYLim();
        catch
        end
        if ~isempty(DATA.qrs) && ~all(isnan(DATA.qrs))
            if strcmp(DATA.Mammal, 'human')
                GUI.CalcPeaksButton_handle.Enable = 'on';
            else
                GUI.CalcPeaksButton_handle.Enable = 'inactive';
            end
        else
            GUI.CalcPeaksButton_handle.Enable = 'inactive';
        end
        %---------------------------------------
        GUI.PQRST_position = {};
        [~, ch_num] = size(DATA.sig);
        if isfield(GUI, 'pebm_waves_table')
            GUI = rmfield(GUI, 'pebm_waves_table');
        end
        if isfield(GUI, 'pebm_intervals_table')
            GUI = rmfield(GUI, 'pebm_intervals_table');
        end
        GUI.pebm_intervals_stat = cell(1, ch_num);
        GUI.pebm_waves_stat = cell(1, ch_num);
        
        GUI.pebm_intervalsData = cell(1, ch_num);
        GUI.pebm_wavesData = cell(1, ch_num);
        
        GUI.ChannelsTable.Data(:, 4) = {false};
        GUI.ChannelsTable.Data(1, 4) = {true};
        
        %         if ~strcmp(DATA.Integration, 'PPG')
        clear_fiducials_handles();
        clear_fiducials_filt_handles();
        reset_fiducials_checkboxs();
        %         end
        
        if ch_num == 12
            parent_axes = GUI.ECG_Axes_Array(1);
            ch_marker_size = 4;
        else
            parent_axes = GUI.ECG_Axes;
            ch_marker_size = 5;
        end
        create_fiducials_filt_handles(1, ch_marker_size, parent_axes);
        set_fid_visible(1);
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
                    TrendHR_checkbox_Callback(GUI.TrendHR_checkbox);
                    plot_red_rectangle(DATA.zoom_rect_limits);
                    setRRIntYLim();
                catch
                end
            else
                disp('Not in range!');
            end
            if ~isempty(DATA.qrs) && ~all(isnan(DATA.qrs))
                if strcmp(DATA.Mammal, 'human')
                    GUI.CalcPeaksButton_handle.Enable = 'on';
                else
                    GUI.CalcPeaksButton_handle.Enable = 'inactive';
                end
            else
                GUI.CalcPeaksButton_handle.Enable = 'inactive';
            end
            
            %---------------------------------------
            GUI.PQRST_position = {};
            [~, ch_num] = size(DATA.sig);
            if isfield(GUI, 'pebm_waves_table')
                GUI = rmfield(GUI, 'pebm_waves_table');
            end
            if isfield(GUI, 'pebm_intervals_table')
                GUI = rmfield(GUI, 'pebm_intervals_table');
            end
            GUI.pebm_intervals_stat = cell(1, ch_num);
            GUI.pebm_waves_stat = cell(1, ch_num);
            
            GUI.pebm_intervalsData = cell(1, ch_num);
            GUI.pebm_wavesData = cell(1, ch_num);
            
            GUI.ChannelsTable.Data(:, 4) = {false};
            GUI.ChannelsTable.Data(1, 4) = {true};
            
            clear_fiducials_handles();
            clear_fiducials_filt_handles();
            reset_fiducials_checkboxs();
            
            if ch_num == 12
                parent_axes = GUI.ECG_Axes_Array(1);
                ch_marker_size = 4;
            else
                parent_axes = GUI.ECG_Axes;
                ch_marker_size = 5;
            end
            create_fiducials_filt_handles(1, ch_marker_size, parent_axes);
            set_fid_visible(1);
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
                    setLogo(h_e, DATA.Module);
                end
                return;
            elseif RRIntPage_Length < red_rect_length
                set(GUI.GUIDisplay.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, display_msec));
                if isInputNumeric ~= 2
                    h_e = errordlg('The window size must be greater than zoom window length!', 'Input Error');
                    setLogo(h_e, DATA.Module);
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
            
            GUI.Adjustment_Text.String = 'Peak adjustmen';
            GUI.GUIRecord.PeakAdjustment_popupmenu.String = DATA.Adjustment_type;
            GUI.GUIRecord.PeakAdjustment_popupmenu.Value = 1;
            GUI.GUIRecord.PeakAdjustment_popupmenu.Callback = @PeakAdjustment_popupmenu_Callback;
            
            %             GUI.GUIRecord.Class_popupmenu.Visible = 'off';
            %             GUI.Class_Text.Visible = 'off';
            %
            %             GUI.GUIRecord.Rhythms_popupmenu.Visible = 'off';
            %             GUI.Rhythms_Text.Visible = 'off';
            %
            %             GUI.GUIRecord.PeakAdjustment_popupmenu.Visible = 'on';
            %             GUI.Adjustment_Text.Visible = 'on';
            %
            %             set(GUI.Adjust_textBox, 'Position', GUI.Adjust_textBox_position);
            % %             set(GUI.Class_textBox, 'Position', GUI.Class_textBox_position);
            % %             set(GUI.Rhythms_textBox, 'Position', GUI.Rhythms_textBox_position);
            %
            %             set(GUI.RhythmsHBox, 'Position', GUI.RhythmsHBox_position);
            GUI.RhythmsHBox.Visible = 'off';
        elseif index_selected == 2
            
            
            GUI.Adjustment_Text.String = 'Class';
            GUI.GUIRecord.PeakAdjustment_popupmenu.String = DATA.GUI_Class;
            GUI.GUIRecord.PeakAdjustment_popupmenu.Value = 1;
            GUI.GUIRecord.PeakAdjustment_popupmenu.Callback = @Class_popupmenu_Callback;
            
            %             GUI.GUIRecord.Class_popupmenu.Visible = 'on';
            %             GUI.Class_Text.Visible = 'on';
            %
            %             GUI.GUIRecord.Rhythms_popupmenu.Visible = 'off';
            %             GUI.Rhythms_Text.Visible = 'off';
            %
            %             GUI.GUIRecord.PeakAdjustment_popupmenu.Visible = 'off';
            %             GUI.Adjustment_Text.Visible = 'off';
            %
            % %             set(GUI.Adjust_textBox, 'Position', GUI.Class_textBox_position);
            %             set(GUI.Class_textBox, 'Position', GUI.Adjust_textBox_position);
            % %             set(GUI.Rhythms_textBox, 'Position', GUI.Rhythms_textBox_position);
            %
            % %             set(GUI.RhythmsHBox, 'Position', GUI.RhythmsHBox_position);
            GUI.RhythmsHBox.Visible = 'off';
        else
            
            
            GUI.Adjustment_Text.String = 'Rhythms';
            GUI.GUIRecord.PeakAdjustment_popupmenu.String = DATA.Rhythms_Type;
            GUI.GUIRecord.PeakAdjustment_popupmenu.Value = 1;
            GUI.GUIRecord.PeakAdjustment_popupmenu.Callback = @Rhythms_popupmenu_Callback;
            
            %             GUI.GUIRecord.Class_popupmenu.Visible = 'off';
            %             GUI.Class_Text.Visible = 'off';
            %
            %             GUI.GUIRecord.PeakAdjustment_popupmenu.Visible = 'off';
            %             GUI.Adjustment_Text.Visible = 'off';
            %
            % %             set(GUI.Adjust_textBox, 'Position', GUI.Rhythms_textBox_position);
            % %             set(GUI.Class_textBox, 'Position', GUI.Class_textBox_position);
            %             set(GUI.Rhythms_textBox, 'Position', GUI.Adjust_textBox_position);
            %
            %             GUI.GUIRecord.Rhythms_popupmenu.Visible = 'on';
            %             GUI.Rhythms_Text.Visible = 'on';
            GUI.RhythmsHBox.Visible = 'on';
            %
            %             set(GUI.RhythmsHBox, 'Position', [GUI.Class_textBox_position(1) GUI.Class_textBox_position(1) GUI.RhythmsHBox_position(3) GUI.RhythmsHBox_position(4)]);
            %
            Rhythms_ToggleButton_Reset();
            %             GUI.rhythms_legend(GUI.GUIRecord.Rhythms_popupmenu.Value).Value = 1;
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
            [~, ch_num] = size(DATA.sig);
            if ch_num == 12
                parent_axes = GUI.ECG_Axes_Array(1);
                ch_marker_size = 4;
            else
                parent_axes = GUI.ECG_Axes;
                ch_marker_size = 5;
            end
            create_fiducials_filt_handles(1, ch_marker_size, parent_axes);
            set_fid_visible(1);
            if isfield(GUI, 'red_rect_handle') && isvalid(GUI.red_rect_handle)
                xdata = get(GUI.red_rect_handle, 'XData');
                setECGYLim(xdata(1), xdata(2));
            end
        end
    end
%%
    function PeakAdjustment(QRS)
        if DATA.Adjust
            try
                waitbar_handle = waitbar(1/2, 'Compute peaks...', 'Name', 'Computing');
                setLogo(waitbar_handle, DATA.Module);
                
                %                 DATA.qrs = mhrv.ecg.qrs_adjust(DATA.sig, DATA.qrs, DATA.Fs, DATA.Adjust, DATA.peak_search_win/1000, false);
                DATA.qrs = mhrv.ecg.qrs_adjust(DATA.sig(:, 1), double(QRS), DATA.Fs, DATA.Adjust, DATA.peak_search_win/1000, false);
                
                if isvalid(waitbar_handle)
                    close(waitbar_handle);
                end
            catch e
                if isvalid(waitbar_handle)
                    close(waitbar_handle);
                end
                h_e = errordlg(['mhrv.ecg.qrs_adjust error: ' e.message], 'Input Error');
                setLogo(h_e, DATA.Module);
                return;
            end
        else % default
            DATA.qrs = DATA.qrs_saved;
        end
        if ~isempty(DATA.qrs)
            if isfield(GUI, 'red_peaks_handle') && ishandle(GUI.red_peaks_handle) && isvalid(GUI.red_peaks_handle)
                delete(GUI.red_peaks_handle);
            end
            
            GUI.ChannelsTable.Data(:, 4) = {false};
            GUI.ChannelsTable.Data(1, 4) = {true};
            
            clear_fiducials_handles();
            clear_fiducials_filt_handles();
            reset_fiducials_checkboxs();
            
            legend(GUI.ECG_Axes, 'off');
            
            DATA.qrs = double(DATA.qrs);
            GUI.red_peaks_handle = line(DATA.tm(DATA.qrs), DATA.sig(DATA.qrs, 1), 'Parent', GUI.ECG_Axes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'MarkerSize', 5, 'LineWidth', 1, 'Tag', 'Peaks');
            uistack(GUI.red_peaks_handle, 'top');
            
            %  ---------------------------
            if DATA.amp_counter(1) > 0
                coeff = 1/(DATA.amp_ch_factor ^ DATA.amp_counter(1));
            else
                coeff = DATA.amp_ch_factor ^ abs(DATA.amp_counter(1));
            end
            GUI.red_peaks_handle.YData = GUI.red_peaks_handle.YData / coeff;
            % ---------------------------
            
            delete(GUI.red_rect_handle);
            delete(GUI.RRInt_handle);
            
            plot_rr_data();
            TrendHR_checkbox_Callback(GUI.TrendHR_checkbox);
            plot_red_rectangle(DATA.zoom_rect_limits);
            setRRIntYLim();
            
            if ~isempty(DATA.qrs) && ~all(isnan(DATA.qrs))
                if strcmp(DATA.Mammal, 'human')
                    GUI.CalcPeaksButton_handle.Enable = 'on';
                else
                    GUI.CalcPeaksButton_handle.Enable = 'inactive';
                end
            else
                GUI.CalcPeaksButton_handle.Enable = 'inactive';
            end
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
        
        if ~isempty(GUI.GUIDir.DirName_text.String)
            [~, b] = fileparts(GUI.GUIDir.DirName_text.String);
            res_parh = [res_parh filesep b];
            
        end
        
        if ~isfolder(res_parh) % isdir
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
            [~, filename_no_ext, ExtensionFileName] = fileparts(filename);
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
                h_e = errordlg('Please, choose only *.mat or *.txt file.', 'Input Error'); % , *.atr or *.qrs
                setLogo(h_e, DATA.Module);
                return;
            end
            set(GUI.GUIRecord.RhythmsFileName_text, 'String', filename);
            DATA.Rhythms_file_name = [results_folder_name, filename_no_ext];
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
        
        if ~isfolder(res_parh) % isdir
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
                setLogo(h_e, DATA.Module);
                return;
            end
        end
    end
%%
    function SaveFiducialsPoints_Callback(~, ~)
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
        
        if ~isfolder(res_parh) % isdir
            warning('off');
            mkdir(res_parh);
            warning('on');
        end
        
        if ~isfield(DIRS, 'analyzedDataDirectory')
            DIRS.analyzedDataDirectory = res_parh;
        end
        if isempty(EXT)
            EXT = 'xlsx';
        end
        
        original_file_name = DATA.DataFileName;
        file_name = [original_file_name, '_Fiducial_Points'];
        
        [filename, results_folder_name, ~] = uiputfile({'*.*', 'All files';...
            '*.xlsx','Excel Files (*.xlsx)';...
            '*.mat','MAT-files (*.mat)'},...
            'Choose Fiducials Points File Name',...
            [DIRS.analyzedDataDirectory, filesep, file_name, '.', EXT]);
        
        if ~isequal(results_folder_name, 0)
            DIRS.analyzedDataDirectory = results_folder_name;
            [~, ~, ExtensionFileName] = fileparts(filename);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            
            full_file_name = [results_folder_name, filename];
            
            if isfield(GUI, 'PQRST_position')
                
                fid_points = GUI.PQRST_position;
                
                RecordName = GUI.GUIRecord.RecordFileName_text.String;
                Mammal = GUI.GUIRecord.Mammal_popupmenu.String;
                IntegrationLevel = GUI.GUIRecord.Integration_popupmenu.String{GUI.GUIRecord.Integration_popupmenu.Value};
                PeakDetector = GUI.GUIRecord.PeakDetector_popupmenu.String{GUI.GUIRecord.PeakDetector_popupmenu.Value};
                PeakAdjustment = GUI.GUIRecord.PeakAdjustment_popupmenu.String{GUI.GUIRecord.PeakAdjustment_popupmenu.Value};
                
                WindowStart = GUI.Fiducials_winStart.String;
                WindowLength = GUI.Fiducials_winLength.String;
                
                if strcmpi(ExtensionFileName, 'mat')
                    save(full_file_name, 'fid_points', 'RecordName', 'Mammal', 'IntegrationLevel', 'PeakDetector', 'PeakAdjustment', 'WindowStart', 'WindowLength');
                    %                 elseif strcmpi(ExtensionFileName, 'txt')
                    %                     header_fileID = fopen(full_file_name, 'wt');
                    %                     fclose(header_fileID);
                elseif strcmpi(ExtensionFileName, 'xlsx')
                    warning('off');
                    
                    MetaDataCell = {'RecordName: ', RecordName; 'Mammal: ', Mammal; 'IntegrationLevel: ', IntegrationLevel; 'PeakDetector: ', PeakDetector; ...
                        'PeakAdjustment: ', PeakAdjustment; 'WindowStart: ', WindowStart; 'WindowLength: ', WindowLength};
                    
                    writecell(MetaDataCell, full_file_name, 'Sheet', 'MetaData');
                    
                    fid_points = GUI.PQRST_position;
                    
                    if ~strcmp(IntegrationLevel, 'PPG')
                        for i = 1 : length(fid_points)
                            if ~isempty(fid_points{i})
                                writecell([fieldnames(fid_points{i}), struct2cell(fid_points{i})], full_file_name, 'Sheet', [GUI.ChannelsTable.Data{i, 1}]);
                            end
                        end
                    else
                        if ~isempty(fid_points)
                            writetable(fid_points, full_file_name, 'Sheet', [GUI.ChannelsTable.Data{1, 1}]);
                        end
                    end
                    warning('on');
                end
            end
        end
    end
%%
    function SaveFiducialsStat_Callback(~, ~)
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
        
        if ~isfolder(res_parh) % isdir
            warning('off');
            mkdir(res_parh);
            warning('on');
        end
        
        if ~isfield(DIRS, 'analyzedDataDirectory')
            DIRS.analyzedDataDirectory = res_parh;
        end
        if isempty(EXT)
            EXT = 'xlsx';
        end
        
        original_file_name = DATA.DataFileName;
        file_name = [original_file_name, '_Fiducial_Biomarkers'];
        
        [filename, results_folder_name, ~] = uiputfile({'*.*', 'All files';...
            '*.xlsx','Excel Files (*.xlsx)';...
            '*.mat','MAT-files (*.mat)'},...
            'Choose Fiducials Points File Name',...
            [DIRS.analyzedDataDirectory, filesep, file_name, '.', EXT]);
        
        if ~isequal(results_folder_name, 0)
            DIRS.analyzedDataDirectory = results_folder_name;
            [~, ~, ExtensionFileName] = fileparts(filename);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            
            full_file_name = [results_folder_name, filename];
            
            fid_intervals = GUI.pebm_intervals_stat;
            fid_waves = GUI.pebm_waves_stat;
            
            RecordName = GUI.GUIRecord.RecordFileName_text.String;
            Mammal = GUI.GUIRecord.Mammal_popupmenu.String;
            IntegrationLevel = GUI.GUIRecord.Integration_popupmenu.String{GUI.GUIRecord.Integration_popupmenu.Value};
            PeakDetector = GUI.GUIRecord.PeakDetector_popupmenu.String{GUI.GUIRecord.PeakDetector_popupmenu.Value};
            PeakAdjustment = GUI.GUIRecord.PeakAdjustment_popupmenu.String{GUI.GUIRecord.PeakAdjustment_popupmenu.Value};
            
            WindowStart = GUI.Fiducials_winStart.String;
            WindowLength = GUI.Fiducials_winLength.String;
            
            if strcmp(IntegrationLevel, 'PPG')
                PPG_Signal_BM = cell2table([GUI.PPG_Signal_Table.RowName GUI.PPG_Signal_Table.Data], 'VariableNames', {'Names', 'Description', 'Mean', 'Median', 'STD', 'Percentile 25', 'Percentile 75', 'IQR', 'Skew', 'Kurtosis', 'Mad'});
                PPG_Derivatives_BM = cell2table([GUI.PPG_Derivatives_Table.RowName GUI.PPG_Derivatives_Table.Data], 'VariableNames', {'Names', 'Description', 'Mean', 'Median', 'STD', 'Percentile 25', 'Percentile 75', 'IQR', 'Skew', 'Kurtosis', 'Mad'});
                Signal_Ratios_BM = cell2table([GUI.Signal_Ratios_Table.RowName GUI.Signal_Ratios_Table.Data], 'VariableNames', {'Names', 'Description', 'Mean', 'Median', 'STD', 'Percentile 25', 'Percentile 75', 'IQR', 'Skew', 'Kurtosis', 'Mad'});
                Derivatives_Ratios_BM = cell2table([GUI.Derivatives_Ratios_Table.RowName GUI.Derivatives_Ratios_Table.Data], 'VariableNames', {'Names', 'Description', 'Mean', 'Median', 'STD', 'Percentile 25', 'Percentile 75', 'IQR', 'Skew', 'Kurtosis', 'Mad'});
            end
            
            if strcmpi(ExtensionFileName, 'mat')
                if ~strcmp(IntegrationLevel, 'PPG')
                    save(full_file_name, 'fid_intervals', 'fid_waves', 'RecordName', 'Mammal', 'IntegrationLevel', 'PeakDetector', 'PeakAdjustment', 'WindowStart', 'WindowLength');
                else
                    save(full_file_name, 'PPG_Signal_BM', 'PPG_Derivatives_BM', 'Signal_Ratios_BM', 'Derivatives_Ratios_BM', 'RecordName', 'Mammal', 'IntegrationLevel', 'PeakDetector', 'PeakAdjustment', 'WindowStart', 'WindowLength');
                end
                %             elseif strcmpi(ExtensionFileName, 'txt')
                %                 header_fileID = fopen(full_file_name, 'wt');
                %                 fclose(header_fileID);
            elseif strcmpi(ExtensionFileName, 'xlsx')
                warning('off');
                
                MetaDataCell = {'RecordName: ', RecordName; 'Mammal: ', Mammal; 'IntegrationLevel: ', IntegrationLevel; 'PeakDetector: ', PeakDetector; ...
                    'PeakAdjustment: ', PeakAdjustment; 'WindowStart: ', WindowStart; 'WindowLength: ', WindowLength};
                
                writecell(MetaDataCell, full_file_name, 'Sheet', 'MetaData');
                
                if ~strcmp(IntegrationLevel, 'PPG')
                    if isfield(GUI, 'pebm_waves_table')
                        pebm_waves_table = GUI.pebm_waves_table;
                        for i = 1 : length(pebm_waves_table)
                            if ~isempty(pebm_waves_table{1, i})
                                writetable(pebm_waves_table{1, i}, full_file_name, 'WriteRowNames', true, 'Sheet', ['Amp. ', GUI.ChannelsTable.Data{i, 1}]);
                            end
                        end
                    end
                    if isfield(GUI, 'pebm_intervals_table')
                        pebm_intervals_table = GUI.pebm_intervals_table;
                        for i = 1 : length(pebm_intervals_table)
                            if ~isempty(pebm_intervals_table{1, i})
                                writetable(pebm_intervals_table{1, i}, full_file_name, 'WriteRowNames', true, 'Sheet', ['Dur. ', GUI.ChannelsTable.Data{i, 1}]);
                            end
                        end
                    end
                else
                    writetable(PPG_Signal_BM, full_file_name, 'Sheet', 'PPG Signal BM');
                    writetable(PPG_Derivatives_BM, full_file_name, 'Sheet', 'PPG Derivatives BM');
                    writetable(Signal_Ratios_BM, full_file_name, 'Sheet', 'Signal Ratios BM');
                    writetable(Derivatives_Ratios_BM, full_file_name, 'Sheet', 'Derivatives Ratios BM');
                end
                warning('on');
            end
        end
        %                     pebm_wintervals_table = table;
        %                     pebm_wintervals_table.Variables = GUI.DurationTable.Data;
        %                     pebm_wintervals_table.Properties.VariableNames = GUI.DurationTable.ColumnName;
        %                     pebm_wintervals_table.Properties.RowNames = GUI.DurationTable.RowName;
        %                     pebm_wintervals_table.Properties.DimensionNames = {'Fiducials Points', 'Data'};
    end
%%
    function [ExtensionFileName, PathName, was_return] = LoadRhythmsFile(Rhythms_FileName, PathName)
        
        [~, RhythmsFileName, ExtensionFileName] = fileparts(Rhythms_FileName);
        ExtensionFileName = ExtensionFileName(2:end);
        %         EXT = ExtensionFileName;
        %         DIRS.analyzedDataDirectory = PathName;
        was_return = 0;
        if isfield(DATA, 'Rhythms_file_name') && ~isempty(DATA.Rhythms_file_name)
            if strcmp(DATA.Rhythms_file_name, [PathName, RhythmsFileName])
                choice = questdlg(['The file "' RhythmsFileName '" already loaded. Do you want to open the same rhythm file?'], ...
                    'Same Rhythm file', 'Open', 'Cancel', 'Cancel');
                
                switch choice
                    case 'Open'
                    case 'Cancel'
                        was_return = 1;
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
                setLogo(h_e, DATA.Module);
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
                tline3 = fgetl(fileID);
                tline4 = fgetl(fileID);
                tline5 = fgetl(fileID);
                tline6 = fgetl(fileID);
                tline7 = fgetl(fileID);
                %                     tline3 = fgetl(fileID);
                type_line = strsplit(tline2, ': ');
                type_line2= strsplit(tline7, '\t');
                %                     source_line = strsplit(tline3, ': ');
                
                if strcmp(tline1, '---') && strcmp(type_line{1}, 'type') && strcmp(type_line{2}, 'rhythms annotation') && ...
                        strcmp(tline5, '---') && strcmp(type_line2{1}, 'Beginning') && strcmp(type_line2{2}, 'End') && strcmp(type_line2{3}, 'Class')
                    
                    if ~isempty(rhythms_data{1}) && ~isempty(rhythms_data{2}) && ~isempty(rhythms_data{3})
                        DATA_RhythmsAnnotations_Data = [cell2mat(rhythms_data(1)) cell2mat(rhythms_data(2))];
                        class = rhythms_data(3);
                        DATA_RhythmsClass = class{1};
                    else
                        DATA_RhythmsAnnotations_Data = [0 0];
                        DATA_RhythmsClass = {'AB'};
                        %                         h_e = errordlg('Please, choose the Rhythms Annotations File.', 'Input Error');
                        %                         setLogo(h_e, DATA.Module);
                        %                         return;
                    end
                else
                    h_e = errordlg('Please, choose the right format for Rhythms Annotations File.', 'Input Error');
                    setLogo(h_e, DATA.Module);
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
            setLogo(h_e, DATA.Module);
            return;
        end
        
        set(GUI.GUIRecord.RhythmsFileName_text, 'String', Rhythms_FileName);
        
        GUI.GUIRecord.Annotation_popupmenu.Value = 3;
        Annotation_popupmenu_Callback();
        
        if isfield(DATA, 'rhythms_win_num') && DATA.rhythms_win_num
            rhythms_keys = DATA.Rhythms_Map.keys;
            keys_num = length(rhythms_keys);
            rhythms_keys_str = cellfun(@num2str, rhythms_keys, 'UniformOutput', false);
            temp_rhythms_map = containers.Map(rhythms_keys_str, zeros(1, keys_num));
        else
            DATA.Rhythms_Map = containers.Map('KeyType', 'double', 'ValueType', 'any');
            GUI.RhythmsListbox.String = '';
            GUI.RhythmsListbox.UserData = [];
            GUI.GUIDisplay.MinRhythmsRange_Edit.String = '';
            GUI.GUIDisplay.MaxRhythmsRange_Edit.String = '';
            GUI.GUIDisplay.MinRhythmsRange_Edit.UserData = [];
            GUI.GUIDisplay.MaxRhythmsRange_Edit.UserData = [];
            
            temp_rhythms_map = containers.Map;
        end
        
        waitbar_handle = waitbar(0, 'Loading', 'Name', 'Working on it...'); setLogo(waitbar_handle, DATA.Module);
        
        rhythms_annotations_num = length(DATA_RhythmsClass);
        
        Rhythms_Data = [];
        RhythmsClass = {};
        
        for i = 1 : rhythms_annotations_num
            [is_member, class_ind] = ismember(DATA_RhythmsClass{i}, DATA.Rhythms_Type);
            if ~is_member
                class_ind = 1;
            end
            if DATA_RhythmsAnnotations_Data(i, 1) ~= DATA_RhythmsAnnotations_Data(i, 2)
                %                 if ~isKey(DATA.Rhythms_Map, DATA_RhythmsAnnotations_Data(i, 1))
                if ~isKey(temp_rhythms_map, num2str(DATA_RhythmsAnnotations_Data(i, 1)))
                    waitbar(i / rhythms_annotations_num, waitbar_handle, ['Ploting rhythms for ' num2str(i) ' annotation']); setLogo(waitbar_handle, DATA.Module);
                    
                    rhythms_struct.rhythm_type = DATA_RhythmsClass{i};
                    rhythms_struct.rhythm_range = DATA_RhythmsAnnotations_Data(i, :);
                    rhythms_struct.rhythm_class_ind = class_ind;
                    rhythms_struct.rhythm_plotted = false;
                    
                    DATA.Rhythms_Map(DATA_RhythmsAnnotations_Data(i, 1)) = rhythms_struct;
                    DATA.rhythms_win_num = DATA.rhythms_win_num + 1;
                    
                    Rhythms_Data = [Rhythms_Data; DATA_RhythmsAnnotations_Data(i, :)];
                    RhythmsClass = [RhythmsClass; DATA_RhythmsClass{i}];
                    
                    Update_Rhythms_ListBox(rhythms_struct);
                end
            end
        end
        redraw_rhythms_rect();
        if isvalid(waitbar_handle)
            close(waitbar_handle);
        end
        plot_rhythms_line(Rhythms_Data, RhythmsClass);
        Update_Rhytms_Stat_Table();
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
            
            %             [~, RhythmsFileName, ExtensionFileName] = fileparts(Rhythms_FileName);
            %             ExtensionFileName = ExtensionFileName(2:end);
            %             EXT = ExtensionFileName;
            %             DIRS.analyzedDataDirectory = PathName;
            
            [ExtensionFileName, PathName, was_return] = LoadRhythmsFile(Rhythms_FileName, PathName);
            if ~was_return
                EXT = ExtensionFileName;
                DIRS.analyzedDataDirectory = PathName;
            end
            %-----------------------------------------------------
            
            %             if isfield(DATA, 'Rhythms_file_name') && ~isempty(DATA.Rhythms_file_name)
            %                 if strcmp(DATA.Rhythms_file_name, [PathName, RhythmsFileName])
            %                     choice = questdlg(['The file "' RhythmsFileName '" already loaded. Do you want to open the same rhythm file?'], ...
            %                         'Same Rhythm file', 'Open', 'Cancel', 'Cancel');
            %
            %                     switch choice
            %                         case 'Open'
            %                         case 'Cancel'
            %                             return;
            %                     end
            %                 end
            %             end
            %
            %             DATA.Rhythms_file_name = [PathName, RhythmsFileName];
            %
            %             if strcmpi(ExtensionFileName, 'mat')
            %
            %                 RhythmsAnnotations = load([PathName Rhythms_FileName]);
            %                 RhythmsAnnotations_field_names = fieldnames(RhythmsAnnotations);
            %
            %                 RhythmsAnnotations_Data = [];
            %                 type = [];
            %
            %                 for i = 1 : length(RhythmsAnnotations_field_names)
            %                     if ~isempty(regexpi(RhythmsAnnotations_field_names{i}, 'rhythms'))
            %                         RhythmsAnnotations_Data = RhythmsAnnotations.(RhythmsAnnotations_field_names{i});
            %                     elseif ~isempty(regexpi(RhythmsAnnotations_field_names{i}, 'class'))
            %                         RhythmsClass = RhythmsAnnotations.(RhythmsAnnotations_field_names{i});
            %                     elseif ~isempty(regexpi(RhythmsAnnotations_field_names{i}, 'type'))
            %                         type = RhythmsAnnotations.(RhythmsAnnotations_field_names{i});
            %                     end
            %                 end
            %                 if ~isempty(RhythmsAnnotations_Data) && strcmpi(type, 'rhythms annotation')
            %                     DATA_RhythmsAnnotations_Data = RhythmsAnnotations_Data;
            %                 else
            %                     h_e = errordlg('Please, choose the Rhythms Annotations File.', 'Input Error');
            %                     setLogo(h_e, DATA.Module);
            %                     return;
            %                 end
            %                 if ~isempty(RhythmsClass)
            %                     DATA_RhythmsClass = RhythmsClass;
            %                 end
            %             elseif strcmpi(ExtensionFileName, 'txt')
            %
            %                 file_name = [PathName Rhythms_FileName];
            %                 fileID = fopen(file_name);
            %                 if fileID ~= -1
            %
            %                     rhythms_data = textscan(fileID, '%f %f %s', 'Delimiter', '\t', 'HeaderLines', 7);
            %
            %                     frewind(fileID);
            %
            %                     tline1 = fgetl(fileID);
            %                     tline2 = fgetl(fileID);
            %                     %                     tline3 = fgetl(fileID);
            %                     type_line = strsplit(tline2, ': ');
            %                     %                     source_line = strsplit(tline3, ': ');
            %
            %                     if strcmp(tline1, '---') && strcmp(type_line{1}, 'type') && strcmp(type_line{2}, 'rhythms annotation')
            %                         %                         if strcmp(source_line{1}, 'source file') && strcmp(source_line{2}, 'rhythms annotation')
            %                         %                         end
            %                         if ~isempty(rhythms_data{1}) && ~isempty(rhythms_data{2}) && ~isempty(rhythms_data{3})
            %                             DATA_RhythmsAnnotations_Data = [cell2mat(rhythms_data(1)) cell2mat(rhythms_data(2))];
            %                             class = rhythms_data(3);
            %                             DATA_RhythmsClass = class{1};
            %                         else
            %                             h_e = errordlg('Please, choose the Rhythms Annotations File.', 'Input Error');
            %                             setLogo(h_e, DATA.Module);
            %                             return;
            %                         end
            %                     else
            %                         h_e = errordlg('Please, choose the right format for Rhythms Annotations File.', 'Input Error');
            %                         setLogo(h_e, DATA.Module);
            %                         return;
            %                     end
            %                     fclose(fileID);
            %                 else
            %                     return;
            %                 end
            %                 %             elseif strcmpi(ExtensionFileName, 'atr') || strcmpi(ExtensionFileName, 'qrs')
            %                 %                 [rhythms_data, class] = mhrv.wfdb.rdann([PathName RhythmsFileName], ExtensionFileName);
            %                 %                 rhythms_data = double(rhythms_data)/DATA.Fs;
            %                 %                 DATA_RhythmsAnnotations_Data = [rhythms_data(1:2:end), rhythms_data(2:2:end)];
            %                 %                 DATA_RhythmsClass = class(1:2:end);
            %             else
            %                 h_e = errordlg('Please, choose only *.mat, *.txt, *.qrs or *.atr file.', 'Input Error');
            %                 setLogo(h_e, DATA.Module);
            %                 return;
            %             end
            %
            %             set(GUI.GUIRecord.RhythmsFileName_text, 'String', Rhythms_FileName);
            %
            %             GUI.GUIRecord.Annotation_popupmenu.Value = 3;
            %             Annotation_popupmenu_Callback();
            %
            %             if isfield(DATA, 'rhythms_win_num') && DATA.rhythms_win_num
            %                 rhythms_win_num = DATA.rhythms_win_num + 1;
            %             else
            %                 rhythms_win_num = 1;
            %                 DATA.Rhythms_Map = containers.Map('KeyType', 'double', 'ValueType', 'any');
            %                 GUI.RhythmsListbox.String = '';
            %                 GUI.RhythmsListbox.UserData = [];
            %                 GUI.GUIDisplay.MinRhythmsRange_Edit.String = '';
            %                 GUI.GUIDisplay.MaxRhythmsRange_Edit.String = '';
            %                 GUI.GUIDisplay.MinRhythmsRange_Edit.UserData = [];
            %                 GUI.GUIDisplay.MaxRhythmsRange_Edit.UserData = [];
            %             end
            %
            %             waitbar_handle = waitbar(0, 'Loadind', 'Name', 'Working on it...'); setLogo(waitbar_handle, DATA.Module);
            %
            %             rhythms_annotations_num = length(DATA_RhythmsClass);
            %
            %             Rhythms_Data = [];
            %             RhythmsClass = {};
            %
            %             for i = 1 : rhythms_annotations_num
            %                 [is_member, class_ind] = ismember(DATA_RhythmsClass{i}, DATA.Rhythms_Type);
            %                 if ~is_member
            %                     class_ind = 1;
            %                 end
            %                 if DATA_RhythmsAnnotations_Data(i, 1) ~= DATA_RhythmsAnnotations_Data(i, 2)
            %
            %                     if ~isKey(DATA.Rhythms_Map, DATA_RhythmsAnnotations_Data(i, 1))
            %                         waitbar(i / rhythms_annotations_num, waitbar_handle, ['Ploting rhythms for ' num2str(i) ' annotation']); setLogo(waitbar_handle, DATA.Module);
            %
            %                         rhythms_struct.rhythm_type = DATA_RhythmsClass{i};
            %                         rhythms_struct.rhythm_range = DATA_RhythmsAnnotations_Data(i, :);
            %                         rhythms_struct.rhythm_class_ind = class_ind;
            %                         rhythms_struct.rhythm_plotted = false;
            %
            %                         DATA.Rhythms_Map(DATA_RhythmsAnnotations_Data(i, 1)) = rhythms_struct;
            %
            %                         %                     plot_rhythms_rect(DATA_RhythmsAnnotations_Data(i, :), rhythms_win_num, class_ind);
            %                         DATA.rhythms_win_num = DATA.rhythms_win_num + 1;
            %                         %                     rhythms_win_num = rhythms_win_num + 1;
            %                         %                     Update_Rhytms_Stat_Table(DATA_RhythmsAnnotations_Data(i, :));
            %
            %                         Rhythms_Data = [Rhythms_Data; DATA_RhythmsAnnotations_Data(i, :)];
            %                         RhythmsClass = [RhythmsClass; DATA_RhythmsClass{i}];
            %
            %                         Update_Rhythms_ListBox(rhythms_struct);
            %                     end
            %                 end
            %             end
            %             redraw_rhythms_rect();
            %             if isvalid(waitbar_handle)
            %                 close(waitbar_handle);
            %             end
            %             %             plot_rhythms_line(DATA_RhythmsAnnotations_Data, DATA_RhythmsClass);
            %             plot_rhythms_line(Rhythms_Data, RhythmsClass);
            %             Update_Rhytms_Stat_Table();
        end
        %-----------------------------------------------------
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
                    setLogo(h_e, DATA.Module);
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
                            setLogo(h_e, DATA.Module);
                            return;
                        end
                    else
                        h_e = errordlg('Please, choose the right format for Signal Quality Annotations File.', 'Input Error');
                        setLogo(h_e, DATA.Module);
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
                setLogo(h_e, DATA.Module);
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
            
            waitbar_handle = waitbar(0, 'Loading', 'Name', 'Working on it...'); setLogo(waitbar_handle, DATA.Module);
            
            quality_annotations_num = length(DATA_Class);
            
            for i = 1 : quality_annotations_num
                [is_member, class_ind] = ismember(DATA_Class{i}, DATA.GUI_Class);
                if ~is_member
                    class_ind = 3;
                end
                if DATA_QualityAnnotations_Data(i, 1) ~= DATA_QualityAnnotations_Data(i, 2)
                    
                    waitbar(i / quality_annotations_num, waitbar_handle, ['Ploting signal quality for ' num2str(i) ' annotation']); setLogo(waitbar_handle, DATA.Module);
                    
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
        
        setLogo(GUI.SaveFiguresWindow, DATA.Module);
        
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
                xlabel(new_axes, 'Time (h:min:sec)', 'FontName', 'Times New Roman');
                new_axes.YLabel.FontName = 'Times New Roman';
                new_axes.FontName = 'Times New Roman';
                
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
                            mhrv.util.fig_print( af, file_name, 'output_format', ext, 'font_size', 10, 'width', 20, 'font', 'Times New Roman', 'font_weight', 'normal');
                        end
                    end
                    close(af);
                catch e
                    disp(e);
                end
            end
        else
            h_e = errordlg('Please enter valid path to save figures', 'Input Error');
            setLogo(h_e, DATA.Module);
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
                        h_e = errordlg('The first second value must be grater than 0 and less than signal length!', 'Input Error'); setLogo(h_e, DATA.Module);
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
                        h_e = errordlg('The window size must be greater than 0 sec and less than signal length!', 'Input Error'); setLogo(h_e, DATA.Module);
                        return;
                    elseif MyWindowSize > DATA.RRIntPage_Length
                        set(GUI.GUIDisplay.WindowSize, 'String', calcDuration(GUI.GUIDisplay.WindowSize.UserData, 0));
                        h_e = errordlg('The zoom window length must be smaller than display duration length!', 'Input Error'); setLogo(h_e, DATA.Module);
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
        if isfield(DATA, 'sig')
            [~, ch_num] = size(DATA.sig);
            
            if ch_num == 12
                for i = 1 : ch_num
                    GUI.ECG_Axes_Array(i).XGrid = GUI.GridX_checkbox.Value;
                    GUI.ECG_Axes_Array(i).XMinorGrid = GUI.GridX_checkbox.Value;
                end
            elseif isfield(GUI, 'ECG_Axes') && isvalid(GUI.ECG_Axes)
                setXECGGrid(GUI.ECG_Axes, GUI.GridX_checkbox);
            end
        end
    end
%%
    function GridY_checkbox_Callback(~, ~)
        if isfield(DATA, 'sig')
            [~, ch_num] = size(DATA.sig);
            
            if ch_num == 12
                for i = 1 : ch_num
                    GUI.ECG_Axes_Array(i).YGrid = GUI.GridY_checkbox.Value;
                    GUI.ECG_Axes_Array(i).YMinorGrid = GUI.GridY_checkbox.Value;
                end
            elseif isfield(GUI, 'ECG_Axes') && isvalid(GUI.ECG_Axes)
                setYECGGrid(GUI.ECG_Axes, GUI.GridY_checkbox);
            end
        end
    end
%%
    function GridYHR_checkbox_Callback(~, ~)
        setYHRGrid(GUI.RRInt_Axes, GUI.GridYHR_checkbox);
    end
%%
    function TrendHR_checkbox_Callback(src, ~)
        if isfield(DATA, 'Integration') && ~strcmp(DATA.Integration, 'PPG')
            if src.Value
                try
                    if isfield(GUI, 'RRInt_detrended_handle')
                        delete(GUI.RRInt_detrended_handle);
                        GUI = rmfield(GUI, 'RRInt_detrended_handle');
                    end
                    f_n = [DATA.Mammal '_' DATA.integration_level{DATA.integration_index}];
                    mhrv.defaults.mhrv_load_defaults(f_n);
                    lambda = mhrv.defaults.mhrv_get_default('filtrr.detrending.lambda');
                    
                    if GUI.FilterHR_checkbox.Value
                        signal2detrend = DATA.rr_data_filtered;
                        rr_time = DATA.rr_time_filtered;
                    else
                        try
                            [rr_time, rr_data, ~] = calc_rr();
                        catch e
                            h_e = errordlg(['TrendHR_checkbox_Callback, calc_rr error:' e.message], 'Detrending error'); setLogo(h_e, DATA.Module);
                        end
                        signal2detrend = rr_data;
                    end
                    
                    waitbar_handle = waitbar(0, 'Detrending', 'Name', 'Working on it...'); setLogo(waitbar_handle, DATA.Module);
                    
                    tic
                    nni_detrended_trans = split_detrend(signal2detrend, lambda.value, DATA.Fs, waitbar_handle);
                    toc
                    if isvalid(waitbar_handle)
                        close(waitbar_handle);
                    end
                    nni_detrended = signal2detrend - nni_detrended_trans;
                    %                 nni_detrended_trans = nni_detrended_trans + mean(nni);
                    hold(GUI.RRInt_Axes, 'on');
                    GUI.RRInt_detrended_handle = line(rr_time, nni_detrended, 'Color', 'r', 'Parent', GUI.RRInt_Axes);
                catch e
                    if isvalid(waitbar_handle)
                        close(waitbar_handle);
                    end
                    h_e = errordlg(['TrendHR_checkbox_Callback error: ' e.message], 'Detrending error'); setLogo(h_e, DATA.Module);
                    GUI.TrendHR_checkbox.Value = 0;
                end
            else
                try
                    if isfield(GUI, 'RRInt_detrended_handle')
                        delete(GUI.RRInt_detrended_handle);
                        GUI = rmfield(GUI, 'RRInt_detrended_handle');
                    end
                catch e
                    disp(e.message);
                end
            end
        end
    end
%%
    function FilterHR_checkbox_Callback(src, ~)
        if isfield(DATA, 'Integration') && ~strcmp(DATA.Integration, 'PPG')
            try
                if isfield(GUI, 'RRInt_filtered_handle')
                    delete(GUI.RRInt_filtered_handle);
                    GUI = rmfield(GUI, 'RRInt_filtered_handle');
                end
            catch e
                disp(e.message);
            end
            if src.Value
                GUI.RRInt_handle.Visible = 'off';
                GUI.RRInt_filtered_handle = line(DATA.rr_time_filtered, DATA.rr_data_filtered, 'Color', 'b');
            else
                GUI.RRInt_handle.Visible = 'on';
            end
            TrendHR_checkbox_Callback(GUI.TrendHR_checkbox);
            setRRIntYLim();
        end
    end
%%
    function LowHightCutoffFr_Edit(src, ~)
        lcf = GUI.GUIDisplay.LowCutoffFr_Edit.String;
        hcf = GUI.GUIDisplay.HightCutoffFr_Edit.String;
        
        if isPositiveNumericValue(lcf) && isPositiveNumericValue(hcf) && str2double(lcf) < str2double(hcf) && str2double(hcf) < DATA.Fs/2
            try
                clear_fiducials_filt_handles();
                calc_plot_flitered_data();
                [~, ch_num] = size(DATA.sig);
                for i = 1 : ch_num
                    set_fid_visible(i);
                end
                if ch_num == 12
                    set12LEDYLim();
                end
                src.UserData(GUI.GUIDisplay.FilterLevel_popupmenu.Value) = str2double(src.String);
            catch e
            end
        else
            if str2double(hcf) >= DATA.Fs/2
                error_str = 'The upper cutoff frequency must be inferior to half of the sampling frequency.';
            else
                error_str = 'Please, enter correct values!';
            end
            h_e = errordlg(error_str, 'Input Error'); setLogo(h_e, DATA.Module);
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
        try
            clear_fiducials_filt_handles();
            calc_plot_flitered_data();
            [~, ch_num] = size(DATA.sig);
            for i = 1 : ch_num
                set_fid_visible(i);
            end
            if ch_num == 12
                set12LEDYLim();
            end
        catch e
            disp(e.message);
        end
    end
%%
%     function ShowChISignal_checkbox_Callback(src, ~)
%         line_handle = GUI.RawChannelsData_handle(src.UserData);
%         if isvalid(line_handle)
%             if src.Value
%                 line_handle.Visible = 'on';
%                 uistack(line_handle, 'top');
%             else
%                 line_handle.Visible = 'off';
%             end
%
%             xdata = get(GUI.red_rect_handle, 'XData');
%             setECGYLim(xdata(1), xdata(2));
%
%             redraw_quality_rect();
%             redraw_rhythms_rect();
%         end
%     end
%%
    function ShowRawSignal_checkbox_Callback(src, ~)
        if isfield(DATA, 'sig')
            [~, ch_num] = size(DATA.sig);
            if isfield(GUI, 'RawChannelsData_handle')
                if src.Value
                    set(GUI.RawChannelsData_handle, 'Visible', 'on');
                    for i = 1 : ch_num
                        if GUI.ChannelsTable.Data{i, 2}
                            GUI.RawChannelsData_handle(i).Visible = 'on';
                        else
                            GUI.RawChannelsData_handle(i).Visible = 'off';
                        end
                        set_fid_visible(i);
                    end
                else
                    set(GUI.RawChannelsData_handle, 'Visible', 'off');
                    for i = 1 : ch_num
                        set_fid_visible(i);
                    end
                end
                if isfield(GUI, 'red_rect_handle') && isvalid(GUI.red_rect_handle)
                    xdata = get(GUI.red_rect_handle, 'XData');
                    setECGYLim(xdata(1), xdata(2));
                end
                if ch_num == 12
                    set12LEDYLim();
                end
            end
        end
    end
%%
    function ShowFilteredSignal_checkbox_Callback(src, ~)
        if isfield(DATA, 'Integration') && ~strcmp(DATA.Integration, 'PPG')
            if isfield(GUI, 'RawData_handle')
                [~, ch_num] = size(DATA.sig);
                if src.Value
                    if isfield(GUI, 'FilteredData_handle') && any(ishandle(GUI.FilteredData_handle)) && any(isvalid(GUI.FilteredData_handle))
                        for i = 1 : ch_num
                            if GUI.ChannelsTable.Data{i, 3}
                                GUI.FilteredData_handle(i).Visible = 'on';
                            else
                                GUI.FilteredData_handle(i).Visible = 'off';
                            end
                            set_fid_visible(i);
                        end
                    else
                        if isfield(DATA, 'sig')
                            try
                                for i = 1 : ch_num
                                    if GUI.ChannelsTable.Data{i, 2}
                                        GUI.ChannelsTable.Data(i, 3) = {true};
                                    end
                                end
                                calc_plot_flitered_data();
                                for i = 1 : ch_num
                                    set_fid_visible(i);
                                end
                            catch e
                                src.Value = 0;
                            end
                        end
                    end
                    GUI.FilterLevelBox.Visible = 'on';
                    GUI.CutoffFrBox.Visible = 'on';
                else
                    if isfield(GUI, 'FilteredData_handle') && any(ishandle(GUI.FilteredData_handle)) && any(isvalid(GUI.FilteredData_handle))
                        set(GUI.FilteredData_handle, 'Visible', 'off');
                    end
                    GUI.FilterLevelBox.Visible = 'off';
                    GUI.CutoffFrBox.Visible = 'off';
                    for i = 1 : ch_num
                        set_fid_visible(i);
                    end
                end
                if isfield(GUI, 'red_rect_handle') && isvalid(GUI.red_rect_handle)
                    xdata = get(GUI.red_rect_handle, 'XData');
                    setECGYLim(xdata(1), xdata(2));
                end
                if ch_num == 12
                    set12LEDYLim();
                end
            end
        end
    end
%%
    function set12LEDYLim()
        
        names_array = GUI.ChannelsTable.Data(:, 1);
        
        for j = 1 : length(GUI.ECG_Axes_Array)
            parent_axes = GUI.ECG_Axes_Array(j);
            
            lines_obj = findobj(parent_axes.Children, 'Type', 'Line', 'Visible', 'on');
            if ~isempty(lines_obj)
                [min_YLim, max_YLim] = bounds(lines_obj(1).YData);
                for i = 2 : length(lines_obj)
                    [min_yData, max_yData] = bounds(lines_obj(i).YData);
                    min_YLim = min(min_YLim, min_yData);
                    max_YLim = max(max_YLim, max_yData);
                end
                parent_axes.YLim = [min_YLim*1.1 max_YLim*1.1];
                
                x_lim = parent_axes.XLim;
                y_lim = parent_axes.YLim;
                
                delete(GUI.ch_name_handles(j));
                GUI.ch_name_handles(j) = text(parent_axes, x_lim(1) + 0.1, y_lim(2) - 0.2, names_array{j}, 'FontSize', 11, 'FontName', 'Times New Roman');
            end
        end
    end
%%
    function calc_plot_flitered_data()
        try
            delete(GUI.FilteredData_handle);
            GUI = rmfield(GUI, 'FilteredData_handle');
        catch
        end
        try
            delete(GUI.red_peaks_handle_Filt);
            GUI = rmfield(GUI, 'red_peaks_handle_Filt');
        catch
        end
        
        lcf = str2double(GUI.GUIDisplay.LowCutoffFr_Edit.String);
        hcf = str2double(GUI.GUIDisplay.HightCutoffFr_Edit.String);
        try
            [~, ch_num] = size(DATA.sig);
            
            if ch_num ~= 12
                ch_marker_size = 5;
            else
                ch_marker_size = 4;
            end
            
            parent_axes = GUI.ECG_Axes;
            
            for i = 1 : ch_num
                if ch_num == 12
                    parent_axes = GUI.ECG_Axes_Array(i);
                end
                bpecg = mhrv.ecg.bpfilt(DATA.sig(:, i), DATA.Fs, lcf, hcf, [], 0);
                GUI.FilteredData_handle(i) = line(DATA.tm, bpecg, 'Parent', parent_axes, 'Tag', 'FilteredData', 'Color', 'b');
                
                if GUI.ChannelsTable.Data{i, 3}
                    GUI.FilteredData_handle(i).Visible = 'on';
                else
                    GUI.FilteredData_handle(i).Visible = 'off';
                end
                
                % ---------------------------------------------------------------
                
                if DATA.amp_counter(i) > 0
                    coeff = 1/(DATA.amp_ch_factor ^ DATA.amp_counter(i));
                else
                    coeff = DATA.amp_ch_factor ^ abs(DATA.amp_counter(i));
                end
                
                GUI.FilteredData_handle(i).YData = GUI.FilteredData_handle(i).YData + GUI.offset_array(i);
                GUI.FilteredData_handle(i).YData = ((GUI.FilteredData_handle(i).YData - GUI.offset_array(i)) / coeff) + GUI.offset_array(i);
                
                create_fiducials_filt_handles(i, ch_marker_size, parent_axes);
                
                % ---------------------------
            end
            if isfield(GUI, 'red_rect_handle') && isvalid(GUI.red_rect_handle)
                xdata = get(GUI.red_rect_handle, 'XData');
                setECGYLim(xdata(1), xdata(2));
            end
        catch e
            h_e = errordlg(['BP Filter error: ' e.message], 'Input Error'); setLogo(h_e, DATA.Module);
            rethrow(e);
        end
    end
%%
    function create_fiducials_filt_handles(ch_num, ch_marker_size, parent_axes)
        try
            filt_ch_data = GUI.FilteredData_handle(ch_num).YData;
            if ch_num == 1 && ~isfield(GUI, 'red_peaks_handle_Filt')
                GUI.red_peaks_handle_Filt(ch_num) = line(DATA.tm(DATA.qrs), filt_ch_data(DATA.qrs), 'Parent', parent_axes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'MarkerSize', ch_marker_size, 'LineWidth', 1, 'Tag', 'RedPeaksFilt');
                GUI.red_peaks_handle_Filt(ch_num).Visible = 'off';
                uistack(GUI.red_peaks_handle_Filt(ch_num), 'top');  % bottom
            end
            if isfield(GUI, 'PQRST_position') && ~isempty(GUI.PQRST_position)
                [P, Q, S, T, R] = return_PQST(GUI.PQRST_position{1, ch_num}, numel(DATA.tm(DATA.tm >= 0 & DATA.tm < GUI.Fiducials_winStart.UserData, :)));
                GUI.P_linehandle_filt(ch_num) = line(DATA.tm(P), filt_ch_data(P), 'Parent', parent_axes, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', ch_marker_size, 'MarkerFaceColor', [0.9290, 0.6940, 0.1250], 'MarkerEdgeColor', [0.9290, 0.6940, 0.1250], 'Visible', 'off', 'Tag', 'PFilt');
                GUI.Q_linehandle_filt(ch_num) = line(DATA.tm(Q), filt_ch_data(Q), 'Parent', parent_axes, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', ch_marker_size, 'MarkerFaceColor', [0.4940, 0.1840, 0.5560], 'MarkerEdgeColor', [0.4940, 0.1840, 0.5560], 'Visible', 'off', 'Tag', 'QFilt');
                GUI.S_linehandle_filt(ch_num) = line(DATA.tm(S), filt_ch_data(S), 'Parent', parent_axes, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', ch_marker_size, 'MarkerFaceColor', [0.8500, 0.3250, 0.0980], 'MarkerEdgeColor', [0.8500, 0.3250, 0.0980], 'Visible', 'off', 'Tag', 'SFilt');
                GUI.T_linehandle_filt(ch_num) = line(DATA.tm(T), filt_ch_data(T), 'Parent', parent_axes, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', ch_marker_size, 'MarkerFaceColor', [0.6350, 0.0780, 0.1840], 'MarkerEdgeColor', [0.6350, 0.0780, 0.1840], 'Visible', 'off', 'Tag', 'TFilt');
                
                if ch_num ~= 1
                    GUI.red_peaks_handle_Filt(ch_num) = line(DATA.tm(R), filt_ch_data(R), 'Parent', parent_axes, 'LineStyle', 'none', 'Marker', 'x', 'LineWidth', 1, 'MarkerSize', ch_marker_size, 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 0 0], 'Visible', 'off');
                end
            end
        catch
        end
    end
%%
    function Rhythms_ToggleButton_Callback(src, ~)
        for i = 1 : length(DATA.Rhythms_Type)
            GUI.rhythms_legend(i).Value = 0;
        end
        src.Value = 1;
        %         GUI.GUIRecord.Rhythms_popupmenu.Value = src.UserData;
        
        GUI.GUIRecord.PeakAdjustment_popupmenu.Value = src.UserData;
    end
%%
    function Rhythms_ToggleButton_Reset()
        for i = 1 : length(DATA.Rhythms_Type)
            GUI.rhythms_legend(i).Value = 0;
        end
    end
%%
    function OpenDir_Callback(~, ~)
        
        basepath = fileparts(fileparts(mfilename('fullpath')));
        
        files_folder = uigetdir([basepath filesep 'ExamplesTXT'], 'Choose folder with the ECG files');
        if files_folder == 0
            return;
        end
        
        GUI.GUIDir.DirName_text.String = files_folder;
        
        all_files_list = dir(files_folder);
        files_list_names = cell(1, length(all_files_list)-2);
        
        for i = 3 : length(all_files_list)
            files_list_names{1, i-2} = all_files_list(i).name;
        end
        GUI.GUIDir.FileList.Value = 1;
        GUI.GUIDir.FileList.String = files_list_names;
        clearData();
        clean_gui(true);
        clean_gui_low_part();
        %         set(GUI.Window, 'WindowButtonMotionFcn', {@my_WindowButtonMotionFcn, 'init'});
    end
%%
    function FileList_listbox_callback(src, ~)
        
        fullFileName_ecg.FileName = src.String{src.Value};
        fullFileName_ecg.PathName = [GUI.GUIDir.DirName_text.String filesep];
        
        peaks_file_name = strrep(fullFileName_ecg.FileName, '_ecg', '_Peaks');
        
        FileName = peaks_file_name;
        PathName = [GUI.GUIDir.DirName_text.String filesep];
        
        saved_val_AutoCalc_checkbox= GUI.AutoCalc_checkbox.Value;
        saved_val_AutoCompute_pushbutton = GUI.AutoCompute_pushbutton.Enable;
        try
            GUI.AutoCalc_checkbox.Value = 0;
            GUI.AutoCompute_pushbutton.Enable = 'on';
            OpenFile_Callback([], [], fullFileName_ecg);
            if exist([PathName, FileName], 'file')
                load_peaks(FileName, PathName, struct([]));
            else
                try
                    delete(GUI.FilteredData_handle);
                    GUI = rmfield(GUI, 'FilteredData_handle');
                catch
                end
                RunAndPlotPeakDetector();
            end
        catch e
            h_e = errordlg(['load_peaks: ', e.message], 'Input Error'); setLogo(h_e, DATA.Module);
            %             disp(e.message);
        end
        GUI.AutoCalc_checkbox.Value = saved_val_AutoCalc_checkbox;
        GUI.AutoCompute_pushbutton.Enable = saved_val_AutoCompute_pushbutton;
    end
%%
    function select_fid_handles(ch_num, if_visible, if_filt)
        try
            if ~if_filt
                if ch_num == 1
                    R_line_handle = GUI.red_peaks_handle;
                else
                    R_line_handle = GUI.qrs_ch(ch_num-1);
                end
            else
                R_line_handle = GUI.red_peaks_handle_Filt(ch_num);
            end
            if isvalid(R_line_handle)
                R_line_handle.Visible = GUI.R_checkbox.Value * if_visible;
            end
        catch
        end
        try
            if ~if_filt
                if isfield(GUI,'P_linehandle')
                    P_line_handle = GUI.P_linehandle(ch_num);
                end
                if isfield(GUI,'Q_linehandle')
                    Q_line_handle = GUI.Q_linehandle(ch_num);
                end
                if isfield(GUI,'S_linehandle')
                    S_line_handle = GUI.S_linehandle(ch_num);
                end
                if isfield(GUI,'T_linehandle')
                    T_line_handle = GUI.T_linehandle(ch_num);
                end
            else
                P_line_handle = GUI.P_linehandle_filt(ch_num);
                Q_line_handle = GUI.Q_linehandle_filt(ch_num);
                S_line_handle = GUI.S_linehandle_filt(ch_num);
                T_line_handle = GUI.T_linehandle_filt(ch_num);
            end
            
            if exist('P_line_handle', 'var') && isvalid(P_line_handle)
                P_line_handle.Visible = GUI.P_checkbox.Value * if_visible;
            end
            if exist('Q_line_handle', 'var') && isvalid(Q_line_handle)
                Q_line_handle.Visible = GUI.Q_checkbox.Value * if_visible;
            end
            
            if exist('S_line_handle', 'var') && isvalid(S_line_handle)
                S_line_handle.Visible = GUI.S_checkbox.Value * if_visible;
            end
            if exist('T_line_handle', 'var') && isvalid(T_line_handle)
                T_line_handle.Visible = GUI.T_checkbox.Value * if_visible;
            end
        catch
        end
    end
%%
    function ChannelsTableEditCallback(src, callbackdata)
        
        if callbackdata.Indices(1, 2) == 2 || callbackdata.Indices(1, 2) == 3 || callbackdata.Indices(1, 2) == 4
            ch_num = callbackdata.Indices(1, 1);
            
            if_sig_visible = src.Data{ch_num, 2} * GUI.RawSignal_checkbox.Value;
            %             if_fid_visible = src.Data{ch_num, 4};
            if_filt_visible = src.Data{ch_num, 3} * GUI.FilteredSignal_checkbox.Value;
            
            try
                filt_line_handle = GUI.FilteredData_handle(ch_num);
                if isvalid(filt_line_handle)
                    filt_line_handle.Visible = if_filt_visible;
                end
            catch
            end
            line_handle = GUI.RawChannelsData_handle(ch_num);
            if isvalid(line_handle)
                line_handle.Visible = if_sig_visible;
                set_fid_visible(ch_num);
                
                if isfield(GUI, 'red_rect_handle') && isvalid(GUI.red_rect_handle)
                    xdata = get(GUI.red_rect_handle, 'XData');
                    setECGYLim(xdata(1), xdata(2));
                    
                    redraw_quality_rect();
                    redraw_rhythms_rect();
                end
            end
            if length(GUI.RawChannelsData_handle) == 12
                set12LEDYLim();
            end
        end
        
        if callbackdata.Indices(1, 2) == 4
            
            ind = find(cellfun(@(x) x == 1, src.Data(:, 4)));
            ind_stat = find(cellfun(@(x) ~isempty(x), GUI.pebm_intervalsData));
            
            show_stat_ind = intersect(ind, ind_stat');
            
            if length(show_stat_ind) == 1 %length(ind) == 1 || length(ind_stat) == 1
                GUI.DurationTable.ColumnName = {'Description'; 'Mean'; 'Median'; 'Min'; 'Max'; 'IQR'; 'STD'};
                GUI.AmplitudeTable.ColumnName = {'Description'; 'Mean'; 'Median'; 'Min'; 'Max'; 'IQR'; 'STD'};
                if ~isempty(GUI.DurationTable.Data)
                    GUI.DurationTable.Data = [GUI.DurationTable.Data(:, 1) GUI.pebm_intervalsData{1, show_stat_ind}];
                end
                if ~isempty(GUI.AmplitudeTable.Data)
                    GUI.AmplitudeTable.Data = [GUI.AmplitudeTable.Data(:, 1) GUI.pebm_wavesData{1, show_stat_ind}];
                end
            elseif length(show_stat_ind) == 0
                if ~isempty(GUI.DurationTable.Data)
                    GUI.DurationTable.Data = GUI.DurationTable.Data(:, 1);
                end
                if ~isempty(GUI.AmplitudeTable.Data)
                    GUI.AmplitudeTable.Data = GUI.AmplitudeTable.Data(:, 1);
                end
            else
                if ~isempty(GUI.DurationTable.Data) && ~isempty(GUI.AmplitudeTable.Data)
                    [~, ch_number] = size(DATA.sig);
                    
                    ColumnName = cell(1, ch_number + 1);
                    ColumnName(1, 1) = {'Description'};
                    GUI.DurationTable.Data = GUI.DurationTable.Data(:, 1);
                    GUI.AmplitudeTable.Data = GUI.AmplitudeTable.Data(:, 1);
                    
                    for i = 1 : length(show_stat_ind)
                        if ~isempty(GUI.pebm_intervalsData{1, show_stat_ind(i)})
                            fid_int = GUI.pebm_intervalsData{1, show_stat_ind(i)};
                            GUI.DurationTable.Data = [GUI.DurationTable.Data fid_int(:, 2)];
                        end
                        if ~isempty(GUI.pebm_wavesData{1, show_stat_ind(i)})
                            fid_waves = GUI.pebm_wavesData{1, show_stat_ind(i)};
                            GUI.AmplitudeTable.Data = [GUI.AmplitudeTable.Data fid_waves(:, 2)];
                        end
                        ColumnName(1, i + 1) = {[GUI.ChannelsTable.Data{show_stat_ind(i), 1}, ' (med)']};
                    end
                    GUI.DurationTable.ColumnName = ColumnName;
                    GUI.AmplitudeTable.ColumnName = ColumnName;
                end
            end
        end
    end
%%
    function set_fid_visible(ch_num)
        try
            if_sig_visible = GUI.ChannelsTable.Data{ch_num, 2} * GUI.RawSignal_checkbox.Value;
            if_fid_visible = GUI.ChannelsTable.Data{ch_num, 4};
            if_filt_visible = GUI.ChannelsTable.Data{ch_num, 3} * GUI.FilteredSignal_checkbox.Value;
            
            if if_sig_visible && if_fid_visible
                select_fid_handles(ch_num, 1, 0);
                select_fid_handles(ch_num, 0, 1);
            elseif ~if_sig_visible && if_fid_visible && if_filt_visible
                select_fid_handles(ch_num, 0, 0);
                select_fid_handles(ch_num, 1, 1);
            else
                select_fid_handles(ch_num, 0, 0);
                select_fid_handles(ch_num, 0, 1);
            end
        catch
        end
    end
%%
    function ChannelsTableSelectionCallback(obj, callbackdata)
        %         handle.Data
        %         callbackdata.Indices
        
        if ~isempty(callbackdata.Indices) && callbackdata.Indices(1, 2) == 1
            obj.UserData = callbackdata.Indices(1, 1);
        end
    end
%%
    function amp_plus_minus_pushbutton_Callback(src, ~)
        
        GUI.AutoScaleY_checkbox.Value = 0;
        GUI.GUIDisplay.MinYLimit_Edit.Enable = 'on';
        GUI.GUIDisplay.MaxYLimit_Edit.Enable = 'on';
        
        if ~isempty(GUI.ChannelsTable.UserData)
            ch_num = GUI.ChannelsTable.UserData;
            line_handle = GUI.RawChannelsData_handle(ch_num);
            try
                filt_line_handle =  GUI.FilteredData_handle(ch_num);
            catch
            end
            if isvalid(line_handle) %&& GUI.ChannelsTable.Data{ch_num, 2}
                if strcmp(src.UserData, 'plus')
                    line_handle.YData = ((line_handle.YData - GUI.offset_array(ch_num)) * DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    DATA.amp_counter(ch_num) = DATA.amp_counter(ch_num) + 1;
                    
                    try
                        filt_line_handle.YData = ((filt_line_handle.YData - GUI.offset_array(ch_num)) * DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    catch
                    end
                    
                    if ch_num == 1
                        GUI.red_peaks_handle.YData = GUI.red_peaks_handle.YData * DATA.amp_ch_factor;
                    end
                    %                     try
                    if isfield(GUI, 'P_linehandle') && isvalid(GUI.P_linehandle(ch_num))
                        GUI.P_linehandle(ch_num).YData = ((GUI.P_linehandle(ch_num).YData - GUI.offset_array(ch_num)) * DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if isfield(GUI, 'Q_linehandle') && isvalid(GUI.Q_linehandle(ch_num))
                        GUI.Q_linehandle(ch_num).YData = ((GUI.Q_linehandle(ch_num).YData - GUI.offset_array(ch_num)) * DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if isfield(GUI, 'S_linehandle') && isvalid(GUI.S_linehandle(ch_num))
                        GUI.S_linehandle(ch_num).YData = ((GUI.S_linehandle(ch_num).YData - GUI.offset_array(ch_num)) * DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if isfield(GUI, 'T_linehandle') && isvalid(GUI.T_linehandle(ch_num))
                        GUI.T_linehandle(ch_num).YData = ((GUI.T_linehandle(ch_num).YData - GUI.offset_array(ch_num)) * DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if ch_num ~= 1 && (isfield(GUI, 'qrs_ch') && isvalid(GUI.qrs_ch(ch_num-1)))
                        GUI.qrs_ch(ch_num-1).YData =     ((GUI.qrs_ch(ch_num-1).YData     - GUI.offset_array(ch_num)) * DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    %                     catch e
                    %                         disp(e);
                    %                     end
                    %                     try
                    if isfield(GUI, 'P_linehandle_filt') && isvalid(GUI.P_linehandle_filt(ch_num))
                        GUI.P_linehandle_filt(ch_num).YData = ((GUI.P_linehandle_filt(ch_num).YData - GUI.offset_array(ch_num)) * DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if isfield(GUI, 'Q_linehandle_filt') && isvalid(GUI.Q_linehandle_filt(ch_num))
                        GUI.Q_linehandle_filt(ch_num).YData = ((GUI.Q_linehandle_filt(ch_num).YData - GUI.offset_array(ch_num)) * DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if isfield(GUI, 'S_linehandle_filt') && isvalid(GUI.S_linehandle_filt(ch_num))
                        GUI.S_linehandle_filt(ch_num).YData = ((GUI.S_linehandle_filt(ch_num).YData - GUI.offset_array(ch_num)) * DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if isfield(GUI, 'T_linehandle_filt') && isvalid(GUI.T_linehandle_filt(ch_num))
                        GUI.T_linehandle_filt(ch_num).YData = ((GUI.T_linehandle_filt(ch_num).YData - GUI.offset_array(ch_num)) * DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    %                     catch e
                    %                         disp(e);
                    %                     end
                    try
                        GUI.red_peaks_handle_Filt(ch_num).YData = ((GUI.red_peaks_handle_Filt(ch_num).YData - GUI.offset_array(ch_num)) * DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    catch
                    end
                elseif strcmp(src.UserData, 'minus')
                    line_handle.YData = ((line_handle.YData - GUI.offset_array(ch_num)) / DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    DATA.amp_counter(ch_num) = DATA.amp_counter(ch_num) - 1;
                    try
                        filt_line_handle.YData = ((filt_line_handle.YData - GUI.offset_array(ch_num)) / DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    catch
                    end
                    if ch_num == 1
                        GUI.red_peaks_handle.YData = GUI.red_peaks_handle.YData / DATA.amp_ch_factor;
                    end
                    %                     try
                    if isfield(GUI, 'P_linehandle') && isvalid(GUI.P_linehandle(ch_num))
                        GUI.P_linehandle(ch_num).YData = ((GUI.P_linehandle(ch_num).YData - GUI.offset_array(ch_num)) / DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if isfield(GUI, 'Q_linehandle') && isvalid(GUI.Q_linehandle(ch_num))
                        GUI.Q_linehandle(ch_num).YData = ((GUI.Q_linehandle(ch_num).YData - GUI.offset_array(ch_num)) / DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if isfield(GUI, 'S_linehandle') && isvalid(GUI.S_linehandle(ch_num))
                        GUI.S_linehandle(ch_num).YData = ((GUI.S_linehandle(ch_num).YData - GUI.offset_array(ch_num)) / DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if isfield(GUI, 'T_linehandle') && isvalid(GUI.T_linehandle(ch_num))
                        GUI.T_linehandle(ch_num).YData = ((GUI.T_linehandle(ch_num).YData - GUI.offset_array(ch_num)) / DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if ch_num ~= 1 && (isfield(GUI, 'qrs_ch') && isvalid(GUI.qrs_ch(ch_num-1)))
                        GUI.qrs_ch(ch_num-1).YData =     ((GUI.qrs_ch(ch_num-1).YData     - GUI.offset_array(ch_num)) / DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    %                     catch e
                    %                         disp(e);
                    %                     end
                    %                     try
                    if isfield(GUI, 'P_linehandle_filt') && isvalid(GUI.P_linehandle_filt(ch_num))
                        GUI.P_linehandle_filt(ch_num).YData = ((GUI.P_linehandle_filt(ch_num).YData - GUI.offset_array(ch_num)) / DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if isfield(GUI, 'Q_linehandle_filt') && isvalid(GUI.Q_linehandle_filt(ch_num))
                        GUI.Q_linehandle_filt(ch_num).YData = ((GUI.Q_linehandle_filt(ch_num).YData - GUI.offset_array(ch_num)) / DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if isfield(GUI, 'S_linehandle_filt') && isvalid(GUI.S_linehandle_filt(ch_num))
                        GUI.S_linehandle_filt(ch_num).YData = ((GUI.S_linehandle_filt(ch_num).YData - GUI.offset_array(ch_num)) / DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    if isfield(GUI, 'T_linehandle_filt') && isvalid(GUI.T_linehandle_filt(ch_num))
                        GUI.T_linehandle_filt(ch_num).YData = ((GUI.T_linehandle_filt(ch_num).YData - GUI.offset_array(ch_num)) / DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    end
                    %                     catch e
                    %                         disp(e);
                    %                     end
                    try
                        GUI.red_peaks_handle_Filt(ch_num).YData = ((GUI.red_peaks_handle_Filt(ch_num).YData - GUI.offset_array(ch_num)) / DATA.amp_ch_factor) + GUI.offset_array(ch_num);
                    catch
                    end
                elseif strcmp(src.UserData, 'source')
                    if DATA.amp_counter(ch_num) ~= 0
                        if DATA.amp_counter(ch_num) > 0
                            coeff = 1/(DATA.amp_ch_factor ^ DATA.amp_counter(ch_num));
                        else
                            coeff = DATA.amp_ch_factor ^ abs(DATA.amp_counter(ch_num));
                        end
                        line_handle.YData = ((line_handle.YData - GUI.offset_array(ch_num)) * coeff) + GUI.offset_array(ch_num);
                        try
                            filt_line_handle.YData = ((filt_line_handle.YData - GUI.offset_array(ch_num)) * coeff) + GUI.offset_array(ch_num);
                        catch
                        end
                        if ch_num == 1
                            GUI.red_peaks_handle.YData = GUI.red_peaks_handle.YData * coeff;
                        end
                        %                         try
                        if isfield(GUI, 'P_linehandle') && isvalid(GUI.P_linehandle(ch_num))
                            GUI.P_linehandle(ch_num).YData = ((GUI.P_linehandle(ch_num).YData - GUI.offset_array(ch_num)) * coeff) + GUI.offset_array(ch_num);
                        end
                        if isfield(GUI, 'Q_linehandle') && isvalid(GUI.Q_linehandle(ch_num))
                            GUI.Q_linehandle(ch_num).YData = ((GUI.Q_linehandle(ch_num).YData - GUI.offset_array(ch_num)) * coeff) + GUI.offset_array(ch_num);
                        end
                        if isfield(GUI, 'S_linehandle') && isvalid(GUI.S_linehandle(ch_num))
                            GUI.S_linehandle(ch_num).YData = ((GUI.S_linehandle(ch_num).YData - GUI.offset_array(ch_num)) * coeff) + GUI.offset_array(ch_num);
                        end
                        if isfield(GUI, 'T_linehandle') && isvalid(GUI.T_linehandle(ch_num))
                            GUI.T_linehandle(ch_num).YData = ((GUI.T_linehandle(ch_num).YData - GUI.offset_array(ch_num)) * coeff) + GUI.offset_array(ch_num);
                        end
                        if ch_num ~= 1 && (isfield(GUI, 'qrs_ch') && isvalid(GUI.qrs_ch(ch_num-1)))
                            GUI.qrs_ch(ch_num-1).YData =     ((GUI.qrs_ch(ch_num-1).YData     - GUI.offset_array(ch_num)) * coeff) + GUI.offset_array(ch_num);
                        end
                        %                         catch e
                        %                             disp(e);
                        %                         end
                        %                         try
                        if isfield(GUI, 'P_linehandle_filt') && isvalid(GUI.P_linehandle_filt(ch_num))
                            GUI.P_linehandle_filt(ch_num).YData = ((GUI.P_linehandle_filt(ch_num).YData - GUI.offset_array(ch_num)) * coeff) + GUI.offset_array(ch_num);
                        end
                        if isfield(GUI, 'Q_linehandle_filt') && isvalid(GUI.Q_linehandle_filt(ch_num))
                            GUI.Q_linehandle_filt(ch_num).YData = ((GUI.Q_linehandle_filt(ch_num).YData - GUI.offset_array(ch_num)) * coeff) + GUI.offset_array(ch_num);
                        end
                        if isfield(GUI, 'S_linehandle_filt') && isvalid(GUI.S_linehandle_filt(ch_num))
                            GUI.S_linehandle_filt(ch_num).YData = ((GUI.S_linehandle_filt(ch_num).YData - GUI.offset_array(ch_num)) * coeff) + GUI.offset_array(ch_num);
                        end
                        if isfield(GUI, 'T_linehandle_filt') && isvalid(GUI.T_linehandle_filt(ch_num))
                            GUI.T_linehandle_filt(ch_num).YData = ((GUI.T_linehandle_filt(ch_num).YData - GUI.offset_array(ch_num)) * coeff) + GUI.offset_array(ch_num);
                        end
                        %                         catch e
                        %                             disp(e);
                        %                         end
                        try
                            GUI.red_peaks_handle_Filt(ch_num).YData = ((GUI.red_peaks_handle_Filt(ch_num).YData - GUI.offset_array(ch_num)) * coeff) + GUI.offset_array(ch_num);
                        catch e
                            %                             disp(e);
                        end
                    end
                    DATA.amp_counter(ch_num) = 0;
                end
                redraw_quality_rect();
                redraw_rhythms_rect();
            end
        end
    end
%%
    function y_lim_plus_minus_pushbutton_Callback(src, ~)
        
        GUI.AutoScaleY_checkbox.Value = 0;
        GUI.GUIDisplay.MinYLimit_Edit.Enable = 'on';
        GUI.GUIDisplay.MaxYLimit_Edit.Enable = 'on';
        
        y_lim = get(GUI.ECG_Axes, 'YLim');
        
        if strcmp(src.UserData, 'source')
            GUI.AutoScaleY_checkbox.Value = 1;
            AutoScaleY_pushbutton_Callback(GUI.AutoScaleY_checkbox);
        elseif strcmp(src.UserData, 'plus')
            set(GUI.ECG_Axes, 'YLim', y_lim/1.1);
        elseif strcmp(src.UserData, 'minus')
            set(GUI.ECG_Axes, 'YLim', y_lim*1.1);
        end
        redraw_quality_rect();
        redraw_rhythms_rect();
    end
%%
    function SplitFile_Button_Callback(~, ~)
        if isfield(DATA, 'DataFileName') && ~isempty(DATA.DataFileName)
            
            Small_File_Length_Sec = str2double(GUI.GUIDir.Split_Sec.String);
            
            basepath = fileparts(mfilename('fullpath'));
            if isdeployed
                res_parh = [userpath filesep 'PhysioZoo' filesep 'Results'];
            else
                res_parh = [fileparts(basepath) filesep 'Results'];
            end
            
            small_files_folder = [res_parh, filesep, DATA.DataFileName];
            
            if ~isfolder(small_files_folder)
                warning('off');
                mkdir(small_files_folder);
                warning('on');
            end
            
            small_files_folder = uigetdir(small_files_folder, 'Choose folder for small files');
            if small_files_folder == 0
                return;
            end
            GUI.GUIDir.DirName_text.String = small_files_folder;
            
            Mammal = DATA.Mammal;
            Fs = DATA.Fs;
            Integration_level = DATA.Integration_From_Files{DATA.integration_index};
            
            %                         Channels{1}.name = 'Time';
            %                         Channels{1}.enable = 'yes';
            %                         Channels{1}.type = 'time';
            %                         Channels{1}.unit = 'sec';
            
            %                         for j = 2 : ch_no + 1
            [~, ch_no] = size(DATA.sig);
            for j = 1 : ch_no
                Channels{j}.name = ['Data_' num2str(j)];
                Channels{j}.enable = 'yes';
                Channels{j}.type = 'electrography';
                Channels{j}.unit = 'mV';
            end
            
            waitbar_handle = waitbar(0, 'Saving', 'Name', 'Working on it...'); setLogo(waitbar_handle, DATA.Module);
            
            %         sm_files_num = ceil(max(DATA.tm)/DATA.Small_File_Length_Sec);
            sm_files_num = ceil(max(DATA.tm)/Small_File_Length_Sec);
            
            file_list = cell(1, sm_files_num);
            
            minLimit = 0;
            maxLimit = Small_File_Length_Sec;
            
            for i = 1 : sm_files_num
                
                file_name = ['part_' num2str(i) '_ecg.mat'];
                full_file_name = [small_files_folder filesep file_name];
                
                file_list{1, i} = file_name;
                
                Data = DATA.sig(DATA.tm >= minLimit & DATA.tm < maxLimit, :);
                Time = DATA.tm(DATA.tm >= minLimit & DATA.tm < maxLimit, :);
                
                %                             Data = [Time, Data];
                
                waitbar(i / sm_files_num, waitbar_handle, ['Saving file number ' num2str(i)]); setLogo(waitbar_handle, DATA.Module);
                save(full_file_name, 'Data', 'Mammal', 'Fs', 'Integration_level', 'Channels');
                
                minLimit = maxLimit;
                maxLimit = min(maxLimit + Small_File_Length_Sec, max(DATA.tm));
            end
            
            if isvalid(waitbar_handle)
                close(waitbar_handle);
            end
            
            GUI.GUIDir.FileList.String = file_list;
            GUI.GUIDir.FileList.Value = 1;
            
            if ~isempty(DATA.qrs)
                Channels={};
                %                             Channels{1}.name = 'Time';
                %                             Channels{1}.enable = 'yes';
                %                             Channels{1}.type = 'time';
                %                             Channels{1}.unit = 'sec';
                
                Channels{1}.name = 'interval';
                Channels{1}.enable = 'yes';
                Channels{1}.type = 'peak';
                Channels{1}.unit = 'index';
                
                qrs = double(DATA.qrs(~isnan(DATA.qrs)));
                rr_time = qrs/DATA.Fs;
                
                minLimit_rr = 0;
                maxLimit_rr = min(Small_File_Length_Sec, max(rr_time));
                
                time_samples = 0;
                for i = 1 : sm_files_num
                    
                    full_file_name_peaks_ind = [small_files_folder filesep 'part_' num2str(i) '_Peaks.mat'];
                    
                    ecg_time = DATA.tm(DATA.tm >= minLimit_rr & DATA.tm < maxLimit_rr, :);
                    Data = DATA.qrs(rr_time >= minLimit_rr & rr_time <= maxLimit_rr, :);
                    
                    if i > 1
                        time_samples = time_samples + ecg_time_length;
                        Data = Data - time_samples;
                        if Data(1) == 0
                            Data(1) = 1;
                        end
                        ecg_time_length = numel(ecg_time);
                    else
                        ecg_time_length = numel(ecg_time);
                    end
                    
                    save(full_file_name_peaks_ind, 'Data', 'Mammal', 'Fs', 'Integration_level', 'Channels');
                    
                    minLimit_rr = maxLimit_rr;
                    maxLimit_rr = min(maxLimit_rr + Small_File_Length_Sec, max(rr_time));
                end
            end
            GUI.RightLeft_TabPanel.Selection = 2;
            GUI.GUIDir.FileList.Value = 1;
            FileList_listbox_callback(GUI.GUIDir.FileList);
        end
    end
%%
    function Split_Sec_Callback(src, ~)
        newVal = str2double(src.String);
        isnumeric = isPositiveNumericValue(src.String);
        if isnumeric && newVal > 0 && newVal <= max(DATA.tm)
            src.UserData = newVal;
        else
            src.String = src.UserData;
            h_e = errordlg('Please, check your input!', 'Input Error'); setLogo(h_e, DATA.Module);
        end
    end
%%
    function Update_Rhythms_ListBox(rhythms_struct)
        
        min_rhythms_range = min(rhythms_struct.rhythm_range);
        max_rhythms_range = max(rhythms_struct.rhythm_range);
        
        CurrentName = {[rhythms_struct.rhythm_type '_' num2str(min_rhythms_range)]};
        if isempty(GUI.RhythmsListbox.String)
            GUI.RhythmsListbox.String = CurrentName;
            GUI.RhythmsListbox.UserData = min_rhythms_range;
            GUI.RhythmsListbox.Value = 1;
        else
            GUI.RhythmsListbox.String(end+1) = CurrentName;
            GUI.RhythmsListbox.UserData = [GUI.RhythmsListbox.UserData min_rhythms_range];
            GUI.RhythmsListbox.Value = length(GUI.RhythmsListbox.String);
        end
        
        GUI.GUIDisplay.MinRhythmsRange_Edit.String = calcDuration(min_rhythms_range, 0, 1);
        GUI.GUIDisplay.MaxRhythmsRange_Edit.String = calcDuration(max_rhythms_range, 0, 1);
        GUI.GUIDisplay.MinRhythmsRange_Edit.UserData = min_rhythms_range;
        GUI.GUIDisplay.MaxRhythmsRange_Edit.UserData = max_rhythms_range;
    end
%%
    function reset_rhythm_linewidth_topaxes()
        if isfield(GUI, 'rhythms_win')
            for i = 1 : length(GUI.rhythms_win)
                GUI.rhythms_win(i).LineWidth = 1;
            end
        end
    end
%%
    function reset_rhythm_linewidth_bottomaxes()
        if isfield(GUI, 'RhythmsHandle_AllDataAxes')
            for i = 1 : length(GUI.RhythmsHandle_AllDataAxes)
                GUI.RhythmsHandle_AllDataAxes(i).LineWidth = 1;
            end
        end
    end
%%
    function Rhythms_listbox_Callback(src, ~)
        
        if isfield(DATA, 'Rhythms_Map') && ~isempty(DATA.Rhythms_Map)
            
            reset_rhythm_linewidth_topaxes();
            reset_rhythm_linewidth_bottomaxes();
            
            current_r = DATA.Rhythms_Map(src.UserData(src.Value));
            r_r = current_r.rhythm_range;
            
            GUI.GUIDisplay.MinRhythmsRange_Edit.String = calcDuration(r_r(1), 0, 1);
            GUI.GUIDisplay.MaxRhythmsRange_Edit.String = calcDuration(r_r(2), 0, 1);
            GUI.GUIDisplay.MinRhythmsRange_Edit.UserData = r_r(1);
            GUI.GUIDisplay.MaxRhythmsRange_Edit.UserData = r_r(2);
            
            current_r.low_axes_patch_handle.LineWidth = 2;
            
            if current_r.rhythm_plotted
                current_r.rhythm_handle.LineWidth = 3;
            end
            
            switch get(GUI.Window, 'selectiontype')
                %             case 'normal'
                case 'open'
                    x_lim = get(GUI.ECG_Axes, 'XLim');
                    delta = (max(x_lim) - min(x_lim))*0.1;
                    
                    xdata = get(GUI.red_rect_handle, 'XData');
                    xofs = r_r(1) - xdata(1, 1) - delta;
                    Window_Move('normal', xofs);
                otherwise
            end
        end
    end
%%
    function MinMaxRhythmsRange_Edit_Callback(src, ~)
        
        min_r_str = GUI.GUIDisplay.MinRhythmsRange_Edit.String;
        max_r_str = GUI.GUIDisplay.MaxRhythmsRange_Edit.String;
        
        if strcmp(src.Tag, 'Min')
            [min_r_d, isInputNumeric_min] = calcDurationInSeconds(GUI.GUIDisplay.MinRhythmsRange_Edit, min_r_str, GUI.GUIDisplay.MinRhythmsRange_Edit.UserData);
            isInputNumeric_max = 1;
            max_r_d = GUI.GUIDisplay.MaxRhythmsRange_Edit.UserData;
        elseif strcmp(src.Tag, 'Max')
            isInputNumeric_min = 1;
            min_r_d = GUI.GUIDisplay.MinRhythmsRange_Edit.UserData;
            [max_r_d, isInputNumeric_max] = calcDurationInSeconds(GUI.GUIDisplay.MaxRhythmsRange_Edit, max_r_str, GUI.GUIDisplay.MaxRhythmsRange_Edit.UserData);
        end
        
        if isfield(DATA, 'maxRRTime')
            if isInputNumeric_min && isInputNumeric_max
                
                min_r = min(min_r_d, max_r_d);
                max_r = max(min_r_d, max_r_d);
                
                if max_r > DATA.maxRRTime
                    max_r = DATA.maxRRTime;
                end
                
                r_s = DATA.Rhythms_Map(GUI.RhythmsListbox.UserData(GUI.RhythmsListbox.Value));
                
                rhythms_range = r_s.rhythm_range;
                
                CurrentName = [r_s.rhythm_type, '_', num2str(min(rhythms_range))];
                iGroup = ismember(GUI.RhythmsListbox.String, CurrentName);
                GUI.RhythmsListbox.Value = 1;
                GUI.RhythmsListbox.String = GUI.RhythmsListbox.String(~iGroup);
                GUI.RhythmsListbox.UserData = GUI.RhythmsListbox.UserData(~iGroup);
                
                DATA.Rhythms_Map.remove(min(rhythms_range));
                
                GUI.GUIDisplay.MinRhythmsRange_Edit.String = calcDuration(min_r, 0, 1);
                GUI.GUIDisplay.MaxRhythmsRange_Edit.String = calcDuration(max_r, 0, 1);
                
                GUI.GUIDisplay.MinRhythmsRange_Edit.UserData = min_r;
                GUI.GUIDisplay.MaxRhythmsRange_Edit.UserData = max_r;
                
                r_s.rhythm_range = [min_r max_r];
                
                rhythm_x_data = [min_r max_r max_r min_r];
                
                try
                    if r_s.rhythm_plotted
                        r_s.rhythm_handle.XData = rhythm_x_data;
                    end
                catch e
                    disp(e.message);
                end
                try
                    if isgraphics(r_s.low_axes_patch_handle)
                        r_s.low_axes_patch_handle.XData = rhythm_x_data;
                    end
                catch e
                    disp(e.message);
                end
                
                DATA.Rhythms_Map(min_r) = r_s;
                
                GUI.RhythmsListbox.String(end+1) = {[r_s.rhythm_type, '_', num2str(min_r)]};
                GUI.RhythmsListbox.UserData = [GUI.RhythmsListbox.UserData min_r];
                GUI.RhythmsListbox.Value = length(GUI.RhythmsListbox.String);
                
                redraw_rhythms_rect();
                Update_Rhytms_Stat_Table();
            end
        end
    end
%%
    function set_legend(parent_axes, leg_str, ch_num)
        try
            if ch_num ~= 12
                warning('off');
                lgn_subset = GUI.red_peaks_handle;
                if isfield(GUI, 'P_linehandle')
                    P_valid = findobj(GUI.P_linehandle, 'Type', 'line');  
                    lgn_subset = [lgn_subset P_valid(1)];
                end
                if isfield(GUI, 'Q_linehandle') || isfield(GUI, 'S_linehandle') || isfield(GUI, 'T_linehandle')
                    Q_valid = findobj(GUI.Q_linehandle, 'Type', 'line');
                    lgn_subset = [lgn_subset Q_valid(1)];
                end
                if isfield(GUI, 'S_linehandle') || isfield(GUI, 'T_linehandle')
                    S_valid = findobj(GUI.S_linehandle, 'Type', 'line');
                    lgn_subset = [lgn_subset S_valid(1)];
                end
                if isfield(GUI, 'T_linehandle')
                    T_valid = findobj(GUI.T_linehandle, 'Type', 'line');
                    lgn_subset = [lgn_subset T_valid(1)];
                end
                
%                 l_h = legend(parent_axes, [GUI.red_peaks_handle; P_valid(1);...
%                     Q_valid(1);...
%                     S_valid(1);...
%                     T_valid(1)],...
%                     leg_str, 'Location', 'best');
                l_h = legend(parent_axes, lgn_subset, leg_str, 'Location', 'best');
                warning('on');
                l_h.AutoUpdate = 'off';
            end
        catch e
            disp(e.message);
        end
    end
%%
    function CalcPQRSTPeaks(~, ~)
        
        if ~strcmp(DATA.Integration, 'PPG')
            [~, ch_num] = size(DATA.sig);
            
            clear_fiducials_handles();
            
            if ch_num == 12
%                 clear_fiducials_handles();
                clear_fiducials_filt_handles();
                reset_fiducials_checkboxs();
                GUI.ChannelsTable.Data(:, 4) = {true};
            end
            
            try
                winStart = GUI.Fiducials_winStart.UserData;
                winLength = GUI.Fiducials_winLength.UserData;
                
                if winLength > 0
                    
                    ecg_time_1 = DATA.tm(DATA.tm >= 0 & DATA.tm < winStart, :);
                    time_samples = numel(ecg_time_1);
                    
                    if ch_num == 12
                        GUI.PQRST_position = cell(1, ch_num);
                    elseif isfield(GUI, 'PQRST_position') && isempty(GUI.PQRST_position)
                        GUI.PQRST_position = cell(1, ch_num);                        
                    end
                    
                    parent_axes = GUI.ECG_Axes;
                    if ch_num ~= 12
                        ch_marker_size = 5;
                    else
                        ch_marker_size = 4;
                    end
                    
                    qrs = double(DATA.qrs(~isnan(DATA.qrs)));
                    rr_time = qrs/DATA.Fs;
                    time = DATA.tm;
                    
                    P = cell(1, ch_num);
                    Q = cell(1, ch_num);
                    S = cell(1, ch_num);
                    T = cell(1, ch_num);
                    % ----------------------------------
                    waitbar_handle = waitbar(0, 'Filtering data', 'Name', 'Working on it...'); setLogo(waitbar_handle, DATA.Module);
                    disp('Bandpath and notch filters:');
                    tic
                    bpecg_data = DATA.sig;
                    if GUI.BandpassFilter_checkbox.Value || GUI.GUIConfig.NotchFilter_popupmenu.Value ~= 1
                        
                        if_bpf = GUI.BandpassFilter_checkbox.Value;
                        if_notch = GUI.GUIConfig.NotchFilter_popupmenu.Value ~= 1;
                        
                        try
                            if GUI.GUIConfig.NotchFilter_popupmenu.Value ~= 1
                                notch_fr = str2num(GUI.GUIConfig.NotchFilter_popupmenu.String{GUI.GUIConfig.NotchFilter_popupmenu.Value});
                            else
                                notch_fr = [];
                            end
                            
                            temp_data_file = [tempdir 'temp_signal.mat'];
                            save(temp_data_file, 'bpecg_data');
                            
                            waitbar_handle = waitbar(1/2, waitbar_handle, 'Calculating bandpass filter', 'Name', 'Working on it...'); setLogo(waitbar_handle, DATA.Module);
                            bpecg_data = preprocesing_pecg(temp_data_file, DATA.Fs, notch_fr, [tempdir 'temp_preprocecg.mat'], [if_bpf if_notch]);
                            if isempty(bpecg_data)
                                h_e = errordlg('Filtering error in fiducials calc', 'Input Error'); setLogo(h_e, DATA.Module);
                                return;
                            end
                        catch e
                            disp(e.message);
                        end
                        delete([tempdir 'temp_signal.mat']);
                        if exist([tempdir 'temp_preprocecg.mat'], 'file')
                            delete([tempdir 'temp_preprocecg.mat']);
                        end
                    end
                    toc
                    if isvalid(waitbar_handle)
                        close(waitbar_handle);
                    end
                    % ----------------------------------
                    waitbar_handle = waitbar(0, 'Calculating pebm biomarkers', 'Name', 'Working on it...'); setLogo(waitbar_handle, DATA.Module);
                    for i = 1 : ch_num
                        if GUI.ChannelsTable.Data{i, 4}
                            
                            data = bpecg_data(:, i);
                            data = data(time >= winStart & time < winStart+winLength, :);
                            % ----------------------------------
                            if i == 1
                                qrs_2 = DATA.qrs(rr_time >= winStart & rr_time < winStart+winLength, :);
                                qrs_2 = qrs_2 - time_samples;
                                
                                if qrs_2(1) == 0
                                    qrs_2(1) = 1;
                                end
                            else
                                peak_detector = GUI.GUIRecord.PeakDetector_popupmenu.String{GUI.GUIRecord.PeakDetector_popupmenu.Value};
                                try
                                    ch_data = DATA.sig(:, i);
                                    qrs_2 = calc_r_peaks_from_ch(DATA, ch_data(time >= winStart & time < winStart+winLength, :), peak_detector);
                                catch e
                                    h_e = errordlg(['Fiducials points error: ' e.message], 'Input Error'); setLogo(h_e, DATA.Module);
                                    return;
                                end
                            end
                            % ----------------------------------
                            if ch_num == 12
                                parent_axes = GUI.ECG_Axes_Array(i);
                            end
                            % ----------------------------------
                            
                            %                       disp(['wavedet_3D: channel ', num2str(i)]);
                            waitbar_handle = waitbar(i/(1+ch_num*2), waitbar_handle, ['Calculating pebm biomarkers ch. ' num2str(i)], 'Name', 'Working on it...'); setLogo(waitbar_handle, DATA.Module);
                            %                         tic
                            heasig = struct("nsig", 1, "freq", DATA.Fs, "nsamp", length(data));
                            [GUI.PQRST_position{i}, ~, ~] = wavedet_3D(data, qrs_2, heasig, []); % Enter pre-filtered data according to user
                            %                         toc
                            [P{i}, Q{i}, S{i}, T{i}, ~] = return_PQST(GUI.PQRST_position{1, i}, time_samples);
                            
                            if ~isempty(P{i})
                                GUI.P_linehandle(i) = line(DATA.tm(P{i}), GUI.RawChannelsData_handle(i).YData(P{i}), 'Parent', parent_axes, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', ch_marker_size, 'MarkerFaceColor', [0.9290, 0.6940, 0.1250], 'MarkerEdgeColor', [0.9290, 0.6940, 0.1250], 'Tag', 'P');
                            end
                            if ~isempty(Q{i})
                                GUI.Q_linehandle(i) = line(DATA.tm(Q{i}), GUI.RawChannelsData_handle(i).YData(Q{i}), 'Parent', parent_axes, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', ch_marker_size, 'MarkerFaceColor', [0.4940, 0.1840, 0.5560], 'MarkerEdgeColor', [0.4940, 0.1840, 0.5560], 'Tag', 'Q');
                            end
                            if ~isempty(S{i})
                                GUI.S_linehandle(i) = line(DATA.tm(S{i}), GUI.RawChannelsData_handle(i).YData(S{i}), 'Parent', parent_axes, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', ch_marker_size, 'MarkerFaceColor', [0.8500, 0.3250, 0.0980], 'MarkerEdgeColor', [0.8500, 0.3250, 0.0980], 'Tag', 'S');
                            end
                            if ~isempty(T{i})
                                GUI.T_linehandle(i) = line(DATA.tm(T{i}), GUI.RawChannelsData_handle(i).YData(T{i}), 'Parent', parent_axes, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', ch_marker_size, 'MarkerFaceColor', [0.6350, 0.0780, 0.1840], 'MarkerEdgeColor', [0.6350, 0.0780, 0.1840], 'Tag', 'T');
                            end
                            
                            if ~all(isnan(P{i}))
                                GUI.P_checkbox.Value = 1;
                            else
                                GUI.P_checkbox.Value = 0;
                            end
                            if ~all(isnan(Q{i}))
                                GUI.Q_checkbox.Value = 1;
                            else
                                GUI.Q_checkbox.Value = 0;
                            end
                            if ~all(isnan(S{i}))
                                GUI.S_checkbox.Value = 1;
                            else
                                GUI.S_checkbox.Value = 0;
                            end
                            if ~all(isnan(T{i}))
                                GUI.T_checkbox.Value = 1;
                            else
                                GUI.T_checkbox.Value = 0;
                            end
                            
                            if i ~= 1
                                GUI.qrs_ch(i-1) = line(DATA.tm(qrs_2 + time_samples), GUI.RawChannelsData_handle(i).YData(qrs_2 + time_samples), 'Parent', parent_axes, 'LineStyle', 'none', 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'MarkerSize', ch_marker_size+1, 'LineWidth', 1, 'MarkerEdgeColor', [1, 0, 0], 'Visible', 'off');
                                GUI.R_checkbox.Value = 1;
                            end
                            
                            create_fiducials_filt_handles(i, ch_marker_size, parent_axes);
                            set_fid_visible(i);
                        end
                    end % for ch_num
                    if isvalid(waitbar_handle)
                        close(waitbar_handle);
                    end
                    %-------------------------------------------------------------------------------
                    if ~isempty(GUI.PQRST_position)
                        GUI.SaveFiducials.Enable = 'on';
                    end
                    
                    if ~all(isnan(cell2mat(P)))
                        GUI.P_checkbox.Value = 1;
                    else
                        GUI.P_checkbox.Value = 0;
                    end
                    if ~all(isnan(cell2mat(Q)))
                        GUI.Q_checkbox.Value = 1;
                    else
                        GUI.Q_checkbox.Value = 0;
                    end
                    if ~all(isnan(cell2mat(S)))
                        GUI.S_checkbox.Value = 1;
                    else
                        GUI.S_checkbox.Value = 0;
                    end
                    if ~all(isnan(cell2mat(T)))
                        GUI.T_checkbox.Value = 1;
                    else
                        GUI.T_checkbox.Value = 0;
                    end
                    
                    set_legend(parent_axes, {'R', 'P', 'Q', 'S', 'T'}, ch_num);
                    
%                     try
%                         if ch_num ~= 12
%                             warning('off');
%                             if isfield(GUI, 'P_linehandle') || isfield(GUI, 'Q_linehandle') || isfield(GUI, 'S_linehandle') || isfield(GUI, 'T_linehandle')
%                                 
%                                 P_valid = findobj(GUI.P_linehandle, 'Type', 'line');
%                                 Q_valid = findobj(GUI.Q_linehandle, 'Type', 'line');
%                                 S_valid = findobj(GUI.S_linehandle, 'Type', 'line');
%                                 T_valid = findobj(GUI.T_linehandle, 'Type', 'line');
%                                 
%                                 l_h = legend(parent_axes, [GUI.red_peaks_handle; P_valid(1);...
%                                     Q_valid(1);...
%                                     S_valid(1);...
%                                     T_valid(1)],...
%                                     {'R', 'P', 'Q', 'S', 'T'}, 'Location', 'best');
%                                 warning('on');
%                                 l_h.AutoUpdate = 'off';
%                             end
%                         end
%                     catch e
%                         disp(e.message);
%                     end
                    if ch_num == 12
                        set12LEDYLim();
                    end
                    %------------------------------------------
                    if ch_num == 12
                        GUI.pebm_intervals_stat = cell(1, ch_num);
                        GUI.pebm_waves_stat = cell(1, ch_num);
                        
                        GUI.pebm_intervalsData = cell(1, ch_num);
                        GUI.pebm_wavesData = cell(1, ch_num);
                        
                        GUI.pebm_waves_table = cell(1, ch_num);
                        GUI.pebm_intervals_table = cell(1, ch_num);
                    end
                    %------------------------------------------
                    
                    waitbar_handle = waitbar(0, 'Calculating pebm statistics', 'Name', 'Working on it...'); setLogo(waitbar_handle, DATA.Module);
                    
                    pqrst_pos_4saving = {};
                    signal_4saving = [];
                    ind2calc = zeros(1, ch_num);
                    j = 1;
                    
                    for i = 1 : ch_num
                        if ~isempty(GUI.PQRST_position{1, i}) && GUI.ChannelsTable.Data{i, 4} && isempty(GUI.pebm_intervals_stat{1, i})
                            pqrst_pos_4saving{1, end+1} = GUI.PQRST_position{1, i};
                            signal_4saving(:, end+1) = bpecg_data(:, i);
                            ind2calc(i) = j;
                            j = j + 1;
                        end
                    end
                    
                    tic
                    if ~isempty(signal_4saving)
                        try
                            disp('save temp files:');
                            
                            signal_file = [tempdir 'temp.mat'];
                            signal = signal_4saving;
                            save(signal_file, 'signal');
                            
                            fid_file = [tempdir 'fid_temp.mat'];
                            fud_points = pqrst_pos_4saving;
                            save(fid_file, 'fud_points');
                            
                        catch e
                            disp(e.message);
                        end
                        
                        clear pqrst_pos_4saving;
                        clear signal_4saving;
                        
                        disp('Intervals:');
                        [pebm_intervals_stat_curr, pebm_intervals_table_curr] = biomarkers_intervals(signal_file, DATA.Fs, fid_file, 1);
                        
                        disp('waves:');
                        [pebm_waves_stat_curr, pebm_waves_table_curr] = biomarkers_waves(signal_file, DATA.Fs, fid_file, 1);
                        
                        delete([tempdir 'temp.mat']);
                        delete([tempdir 'fid_temp.mat']);
                        toc
                        %------------------------------------------
                        GUI.SaveFiducialsStat.Enable = 'on';
                        
                        for i = 1 : ch_num
                            if ind2calc(i)
                                GUI.pebm_intervals_stat(1, i) = pebm_intervals_stat_curr(ind2calc(i));
                                GUI.pebm_intervals_table(1, i) = pebm_intervals_table_curr(ind2calc(i));
                                GUI.pebm_waves_stat(1, i) = pebm_waves_stat_curr(ind2calc(i));
                                GUI.pebm_waves_table(1, i) = pebm_waves_table_curr(ind2calc(i));
                                
                                [GUI.pebm_intervalsData{1, i}, pebm_intervalsRowsNames, pebm_intervalsDescriptions] = table2cell_StatisticsParam(GUI.pebm_intervals_stat{1, i});
                                [GUI.pebm_wavesData{1, i}, pebm_wavesRowsNames, pebm_wavesDescriptions] = table2cell_StatisticsParam(GUI.pebm_waves_stat{1, i});
                            end
                        end
                        
                        %------------------------------------------------------------------
                        try
                            GUI.DurationTable.RowName = pebm_intervalsRowsNames;
                            GUI.AmplitudeTable.RowName = pebm_wavesRowsNames;
                            
                            ind = find(cellfun(@(x) x == 1, GUI.ChannelsTable.Data(:, 4)));
                            ind_stat = find(cellfun(@(x) ~isempty(x), GUI.pebm_intervalsData));
                            show_stat_ind = intersect(ind, ind_stat');
                            
                            if length(find(cellfun(@(x) ~isempty(x), GUI.pebm_intervalsData))) == 1
                                GUI.DurationTable.ColumnName = {'Description'; 'Mean'; 'Median'; 'Min'; 'Max'; 'IQR'; 'STD'};
                                GUI.AmplitudeTable.ColumnName = {'Description'; 'Mean'; 'Median'; 'Min'; 'Max'; 'IQR'; 'STD'};
                                GUI.DurationTable.Data = [pebm_intervalsDescriptions GUI.pebm_intervalsData{1, show_stat_ind}];
                                GUI.AmplitudeTable.Data = [pebm_wavesDescriptions GUI.pebm_wavesData{1, show_stat_ind}];
                            else
                                GUI.DurationTable.Data = pebm_intervalsDescriptions;
                                GUI.AmplitudeTable.Data = pebm_wavesDescriptions;
                                
                                ColumnName = cell(1, ch_num + 1);
                                ColumnName(1, 1) = {'Description'};
                                for i = 1 : length(show_stat_ind)
                                    fid_int = GUI.pebm_intervalsData{1, show_stat_ind(i)};
                                    fid_waves = GUI.pebm_wavesData{1, show_stat_ind(i)};
                                    GUI.DurationTable.Data = [GUI.DurationTable.Data fid_int(:, 2)];
                                    GUI.AmplitudeTable.Data = [GUI.AmplitudeTable.Data fid_waves(:, 2)];
                                    ColumnName(1, i + 1) = {[GUI.ChannelsTable.Data{show_stat_ind(i), 1}, ' (med)']};
                                end
                                GUI.DurationTable.ColumnName = ColumnName;
                                GUI.AmplitudeTable.ColumnName = ColumnName;
                            end
                        catch
                        end
                        %------------------------------------------
                    end
                    if isvalid(waitbar_handle)
                        close(waitbar_handle);
                    end
                else
                    h_e = errordlg('The window length must be grather than 0!', 'Input Error'); setLogo(h_e, DATA.Module);
                end
            catch e
                disp(['CalcPQRSTPeaks:', e.message]);
                if isvalid(waitbar_handle)
                    close(waitbar_handle);
                end
            end
        else
            
            %             if isempty(GUI.PQRST_position)
            %                 waitbar_handle = waitbar(1/2, 'Compute peaks...', 'Name', 'Computing'); setLogo(waitbar_handle, DATA.Module);
            %                 [GUI.PQRST_position, GUI.fiducials_path] = PPG_peaks(DATA.wfdb_record_name, DATA.customConfigFile);
            %                 %                 DATA.qrs = GUI.PQRST_position.sp + 1;
            %                 if isvalid(waitbar_handle)
            %                     close(waitbar_handle);
            %                 end
            %             end
            
            
            GUI.SaveFiducials.Enable = 'off';
            GUI.SaveFiducialsStat.Enable = 'off';
            waitbar_handle = waitbar(0, 'Calculating PPG biomarkers', 'Name', 'Working on it...'); setLogo(waitbar_handle, DATA.Module);
            waitbar_handle = waitbar(1/2, waitbar_handle, 'Calculating PPG Biomarkers'); setLogo(waitbar_handle, DATA.Module);
            calc_disp_PPG_Stats();
            waitbar_handle = waitbar(2/2, waitbar_handle, 'Plot PPG Fiducials Points'); setLogo(waitbar_handle, DATA.Module);
            plotPPGFiducials4Win();
            if isvalid(waitbar_handle)
                close(waitbar_handle);
            end
        end
    end
%%
    function calc_disp_PPG_Stats()
        if isfield(GUI, 'PQRST_position') && ~isempty(GUI.PQRST_position)
            
            GUI.Derivatives_Ratios_Table.Data = {};
            GUI.Signal_Ratios_Table.Data = {};
            GUI.PPG_Derivatives_Table.Data = {};
            GUI.PPG_Signal_Table.Data = {};
            
            winStart = GUI.Fiducials_winStart.UserData;
            winLength = GUI.Fiducials_winLength.UserData;
            if winLength > 0
                start_sig = int16(winStart * DATA.Fs);
                
                try
                    biomarkers_path = PPG_biomarkers(DATA.wfdb_record_name, DATA.customConfigFile, GUI.fiducials_path, start_sig, winLength);
                catch e
                    h_e = errordlg(['The PPG biomarkers points were not found. ', e.message], 'Input Error'); setLogo(h_e, DATA.Module);
                    return;
                end
                if ~isempty(biomarkers_path)
                    
                    res_dir_struct_fields_names = fieldnames(biomarkers_path);
                    
                    saved_fn = {'ppg_sig'; 'sig_ratios'; 'ppg_derivs'; 'derivs_ratios'};
                    GUI_fn = {'PPG_Signal'; 'Signal_Ratios'; 'PPG_Derivatives'; 'Derivatives_Ratios'};
                    our_map = containers.Map(saved_fn, GUI_fn);
                    
                    TabName_str = '';
                    for i = 1 : length(res_dir_struct_fields_names)
                        ppg_bm_st = load(biomarkers_path.(res_dir_struct_fields_names{i}));
                        
                        TabName_str = cell2mat(fieldnames(ppg_bm_st));
                        
                        bm_table = struct2table(ppg_bm_st.(TabName_str));
                        bm_table_data = removevars(bm_table, 'index');
                        bm_table_data = removevars(bm_table_data, 'unit');
                        
                        RowName = cell(height(bm_table), 1);
                        for j = 1 : height(bm_table)
                            RowName{j} = [cell2mat(bm_table.index(j)) ' ' cell2mat(bm_table.unit(j))];
                        end
                        
                        TableName4GUI = our_map(TabName_str);
                        
                        GUI.([TableName4GUI '_Table']).RowName = RowName;
                        GUI.([TableName4GUI '_Table']).Data = table2cell(bm_table_data);
                    end
                    GUI.SaveFiducialsStat.Enable = 'on';
                else
                    h_e = errordlg('The PPG biomarkers were not calculated!', 'Input Error'); setLogo(h_e, 'PPG');
                end
            end
        end
    end
%%
    function plotPPGFiducials4Win()
        [~, ch_num] = size(DATA.sig);
        ch_marker_size = 5;
        parent_axes = GUI.ECG_Axes;
        if isfield(GUI, 'PQRST_position') && ~isempty(GUI.PQRST_position)
            
            winStart = GUI.Fiducials_winStart.UserData;
            winLength = GUI.Fiducials_winLength.UserData;
            
            if winLength > 0
                start_sig = winStart * DATA.Fs;
                end_sig = start_sig + winLength * DATA.Fs;
                
                select_row = find(GUI.PQRST_position.on >= start_sig & GUI.PQRST_position.off < end_sig);
                fiducials = GUI.PQRST_position(select_row, :);
                
                P = [];
                Q = fiducials.on + 1;
                S = fiducials.dn + 1;
                T = fiducials.dp + 1;
                
                clear_only_fiducials_handles();
                
                if ~isempty(P)
                    GUI.P_linehandle = line(DATA.tm(P), GUI.RawChannelsData_handle(1).YData(P), 'Parent', parent_axes, 'LineStyle', 'none', 'LineWidth', 1.5, 'Marker', 'o', 'MarkerSize', ch_marker_size, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'Tag', 'P');
                end
                if ~isempty(Q)
                    GUI.Q_linehandle = line(DATA.tm(Q), GUI.RawChannelsData_handle(1).YData(Q), 'Parent', parent_axes, 'LineStyle', 'none', 'LineWidth', 1.5, 'Marker', 's', 'MarkerSize', ch_marker_size, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'b', 'Tag', 'Q');
                end
                if ~isempty(S)
                    GUI.S_linehandle = line(DATA.tm(S), GUI.RawChannelsData_handle(1).YData(S), 'Parent', parent_axes, 'LineStyle', 'none', 'LineWidth', 1.5, 'Marker', 'd', 'MarkerSize', ch_marker_size, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'g', 'Tag', 'S');
                end
                if ~isempty(T)
                    GUI.T_linehandle = line(DATA.tm(T), GUI.RawChannelsData_handle(1).YData(T), 'Parent', parent_axes, 'LineStyle', 'none', 'LineWidth', 1.5, 'Marker', 'o', 'MarkerSize', ch_marker_size, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'm', 'Tag', 'T');
                end
                
                if ~all(isnan(P))
                    GUI.P_checkbox.Value = 1;
                else
                    GUI.P_checkbox.Value = 0;
                end
                if ~all(isnan(Q))
                    GUI.Q_checkbox.Value = 1;
                else
                    GUI.Q_checkbox.Value = 0;
                end
                if ~all(isnan(S))
                    GUI.S_checkbox.Value = 1;
                else
                    GUI.S_checkbox.Value = 0;
                end
                if ~all(isnan(T))
                    GUI.T_checkbox.Value = 1;
                else
                    GUI.T_checkbox.Value = 0;
                end
                GUI.SaveFiducials.Enable = 'on';
                
                set_legend(parent_axes, {'SP', 'ON', 'DN', 'DP'}, ch_num);
            end
        end
    end
%%
    function reset_fiducials_checkboxs()
        GUI.P_checkbox.Value = 0;
        GUI.Q_checkbox.Value = 0;
        GUI.R_checkbox.Value = 1;
        GUI.S_checkbox.Value = 0;
        GUI.T_checkbox.Value = 0;
    end
%%
    function clear_fiducials_handles()
%         if isfield(GUI, 'P_linehandle')% && any(isvalid(GUI.P_linehandle))
%             delete(GUI.P_linehandle);
%             GUI = rmfield(GUI, 'P_linehandle');
%         end
%         if isfield(GUI, 'Q_linehandle')% && any(isvalid(GUI.Q_linehandle))
%             delete(GUI.Q_linehandle);
%             GUI = rmfield(GUI, 'Q_linehandle');
%         end
%         if isfield(GUI, 'S_linehandle')% && any(isvalid(GUI.S_linehandle))
%             delete(GUI.S_linehandle);
%             GUI = rmfield(GUI, 'S_linehandle');
%         end
%         if isfield(GUI, 'T_linehandle')% && any(isvalid(GUI.T_linehandle))
%             delete(GUI.T_linehandle);
%             GUI = rmfield(GUI, 'T_linehandle');
%         end
%         %-----------------------------------------------
%         if isfield(GUI, 'qrs_ch')% && any(isvalid(GUI.qrs_ch))
%             delete(GUI.qrs_ch);
%             GUI = rmfield(GUI, 'qrs_ch');
%         end

        clear_only_fiducials_handles();
        
        if isfield(GUI, 'ECG_Axes') && isvalid(GUI.ECG_Axes)
            legend(GUI.ECG_Axes, 'off');
        end
        GUI.DurationTable.Data = {};
        GUI.AmplitudeTable.Data = {};
        try
            GUI.Derivatives_Ratios_Table.Data = {};
            GUI.Signal_Ratios_Table.Data = {};
            GUI.PPG_Derivatives_Table.Data = {};
            GUI.PPG_Signal_Table.Data = {};
        catch
        end
        GUI.SaveFiducials.Enable = 'off';
        GUI.SaveFiducialsStat.Enable = 'off';
    end
%%
    function clear_only_fiducials_handles()
        if isfield(GUI, 'P_linehandle')% && any(isvalid(GUI.P_linehandle))
            delete(GUI.P_linehandle);
            GUI = rmfield(GUI, 'P_linehandle');
        end
        if isfield(GUI, 'Q_linehandle')% && any(isvalid(GUI.Q_linehandle))
            delete(GUI.Q_linehandle);
            GUI = rmfield(GUI, 'Q_linehandle');
        end
        if isfield(GUI, 'S_linehandle')% && any(isvalid(GUI.S_linehandle))
            delete(GUI.S_linehandle);
            GUI = rmfield(GUI, 'S_linehandle');
        end
        if isfield(GUI, 'T_linehandle')% && any(isvalid(GUI.T_linehandle))
            delete(GUI.T_linehandle);
            GUI = rmfield(GUI, 'T_linehandle');
        end
        %-----------------------------------------------
        if isfield(GUI, 'qrs_ch')% && any(isvalid(GUI.qrs_ch))
            delete(GUI.qrs_ch);
            GUI = rmfield(GUI, 'qrs_ch');
        end                
    end
%%
    function clear_fiducials_filt_handles()
        if isfield(GUI, 'P_linehandle_filt') %&& any(isvalid(GUI.P_linehandle_filt))
            delete(GUI.P_linehandle_filt);
            GUI = rmfield(GUI, 'P_linehandle_filt');
        end
        if isfield(GUI, 'Q_linehandle_filt')% && any(isvalid(GUI.Q_linehandle_filt))
            delete(GUI.Q_linehandle_filt);
            GUI = rmfield(GUI, 'Q_linehandle_filt');
        end
        if isfield(GUI, 'S_linehandle_filt')% && any(isvalid(GUI.S_linehandle_filt))
            delete(GUI.S_linehandle_filt);
            GUI = rmfield(GUI, 'S_linehandle_filt');
        end
        if isfield(GUI, 'T_linehandle_filt')% && any(isvalid(GUI.T_linehandle_filt))
            delete(GUI.T_linehandle_filt);
            GUI = rmfield(GUI, 'T_linehandle_filt');
        end
        try
            delete(GUI.red_peaks_handle_Filt);
            GUI = rmfield(GUI, 'red_peaks_handle_Filt');
        catch
        end
    end
%%
    function PQRST_checkbox_Callback(src, ~)
        try
            line_vis = src.Value;
            
            handles_fid = gobjects(0);
            handles_fid_filt = gobjects(0);
            
            if GUI.RawSignal_checkbox.Value
                array_vis = cell2mat(GUI.ChannelsTable.Data(:, 4)) * line_vis .* cell2mat(GUI.ChannelsTable.Data(:, 2));
                if GUI.FilteredSignal_checkbox.Value
                    array_vis_filt = ~cell2mat(GUI.ChannelsTable.Data(:, 2)) * line_vis .* cell2mat(GUI.ChannelsTable.Data(:, 3)).* cell2mat(GUI.ChannelsTable.Data(:, 4));
                else
                    array_vis_filt = zeros(size(array_vis));
                end
            elseif GUI.FilteredSignal_checkbox.Value && ~GUI.RawSignal_checkbox.Value
                array_vis_filt = cell2mat(GUI.ChannelsTable.Data(:, 4)) * line_vis .* cell2mat(GUI.ChannelsTable.Data(:, 3));
                array_vis = zeros(size(array_vis_filt));
            elseif ~GUI.FilteredSignal_checkbox.Value && ~GUI.RawSignal_checkbox.Value
                array_vis = zeros(size(cell2mat(GUI.ChannelsTable.Data(:, 4))));
                array_vis_filt = zeros(size(array_vis));
            end
            
            if strcmp(src.Tag, 'PPeaksCb') && isfield(GUI, 'P_linehandle') && ~isempty(GUI.P_linehandle) && any(ishandle(GUI.P_linehandle)) && any(isvalid(GUI.P_linehandle))
                handles_fid = GUI.P_linehandle;
            elseif strcmp(src.Tag, 'QPeaksCb') && isfield(GUI, 'Q_linehandle') && ~isempty(GUI.Q_linehandle) && any(ishandle(GUI.Q_linehandle)) && any(isvalid(GUI.Q_linehandle))
                handles_fid = GUI.Q_linehandle;
            elseif strcmp(src.Tag, 'RPeaksCb')   && isfield(GUI, 'red_peaks_handle') && ~isempty(GUI.red_peaks_handle) && any(ishandle(GUI.red_peaks_handle)) && any(isvalid(GUI.red_peaks_handle))
                handles_fid = GUI.red_peaks_handle;
            elseif strcmp(src.Tag, 'SPeaksCb') && isfield(GUI, 'S_linehandle') && ~isempty(GUI.S_linehandle) && any(ishandle(GUI.S_linehandle)) && any(isvalid(GUI.S_linehandle))
                handles_fid = GUI.S_linehandle;
            elseif strcmp(src.Tag, 'TPeaksCb') && isfield(GUI, 'T_linehandle') && ~isempty(GUI.T_linehandle) && any(ishandle(GUI.T_linehandle)) && any(isvalid(GUI.T_linehandle))
                handles_fid = GUI.T_linehandle;
            end
            if strcmp(src.Tag, 'PPeaksCb') && isfield(GUI, 'P_linehandle_filt') && ~isempty(GUI.P_linehandle_filt) && any(ishandle(GUI.P_linehandle_filt)) && any(isvalid(GUI.P_linehandle_filt))
                handles_fid_filt = GUI.P_linehandle_filt;
            elseif strcmp(src.Tag, 'QPeaksCb') && isfield(GUI, 'Q_linehandle_filt') && ~isempty(GUI.Q_linehandle_filt) && any(ishandle(GUI.Q_linehandle_filt)) && any(isvalid(GUI.Q_linehandle_filt))
                handles_fid_filt = GUI.Q_linehandle_filt;
            elseif strcmp(src.Tag, 'RPeaksCb')   && isfield(GUI, 'red_peaks_handle_Filt') && ~isempty(GUI.red_peaks_handle_Filt) && any(ishandle(GUI.red_peaks_handle_Filt)) && any(isvalid(GUI.red_peaks_handle_Filt))
                handles_fid_filt = GUI.red_peaks_handle_Filt;
            elseif strcmp(src.Tag, 'SPeaksCb') && isfield(GUI, 'S_linehandle_filt') && ~isempty(GUI.S_linehandle_filt) && any(ishandle(GUI.S_linehandle_filt)) && any(isvalid(GUI.S_linehandle_filt))
                handles_fid_filt = GUI.S_linehandle_filt;
            elseif strcmp(src.Tag, 'TPeaksCb') && isfield(GUI, 'T_linehandle_filt') && ~isempty(GUI.T_linehandle_filt) && any(ishandle(GUI.T_linehandle_filt)) && any(isvalid(GUI.T_linehandle_filt))
                handles_fid_filt = GUI.T_linehandle_filt;
            end
            if strcmp(src.Tag, 'RPeaksCb') && isfield(GUI, 'qrs_ch') && ~isempty(GUI.qrs_ch) && any(ishandle(GUI.qrs_ch)) && any(isvalid(GUI.qrs_ch))
                handles_fid = [handles_fid GUI.qrs_ch];
            end
            
            for i = 1 : length(handles_fid)
                if ishandle(handles_fid(i))
                    handles_fid(i).Visible = array_vis(i);
                end
            end
            for i = 1 : length(handles_fid_filt)
                if ishandle(handles_fid_filt(i))
                    handles_fid_filt(i).Visible = array_vis_filt(i);
                end
            end
        catch
        end
    end
%%
    function Fiducials_winStartLength_Edit_Callback(src, ~)
        [param_value, isInputNumeric] = calcDurationInSeconds(src, src.String, src.UserData);
        
        if isInputNumeric
            [fid_winstart, isInputNumericS] = calcDurationInSeconds(GUI.Fiducials_winStart, GUI.Fiducials_winStart.String, GUI.Fiducials_winStart.UserData);
            [fid_winLength, isInputNumericL] = calcDurationInSeconds(GUI.Fiducials_winLength, GUI.Fiducials_winLength.String, GUI.Fiducials_winLength.UserData);
            
            if isInputNumericS && isInputNumericL
                if fid_winstart + fid_winLength <= max(DATA.tm)
                    src.UserData = param_value;
                elseif fid_winstart > max(DATA.tm)
                    GUI.Fiducials_winStart.String = calcDuration(max(DATA.tm), 0);
                    GUI.Fiducials_winLength.String = calcDuration(0, 0);
                    GUI.Fiducials_winStart.UserData = max(DATA.tm);
                    GUI.Fiducials_winLength.UserData = 0;
                else
                    GUI.Fiducials_winLength.String = calcDuration(max(DATA.tm)-fid_winstart, 0);
                    GUI.Fiducials_winLength.UserData = max(DATA.tm)-fid_winstart;
                    GUI.Fiducials_winStart.UserData = fid_winstart;
                    h_e = warndlg('Win length was adapted so that start time plus win lenght will be less than signal length!', 'Input error'); setLogo(h_e, DATA.Module);
                end
                
                if ~strcmp(DATA.Integration, 'PPG')
                    GUI.PQRST_position = {};
                end
                [~, ch_num] = size(DATA.sig);
                if isfield(GUI, 'pebm_waves_table')
                    GUI = rmfield(GUI, 'pebm_waves_table');
                end
                if isfield(GUI, 'pebm_intervals_table')
                    GUI = rmfield(GUI, 'pebm_intervals_table');
                end
                GUI.pebm_intervals_stat = cell(1, ch_num);
                GUI.pebm_waves_stat = cell(1, ch_num);
                
                GUI.pebm_intervalsData = cell(1, ch_num);
                GUI.pebm_wavesData = cell(1, ch_num);
                
                clear_fiducials_handles();
                clear_fiducials_filt_handles();
                reset_fiducials_checkboxs();
                GUI.ChannelsTable.Data(:, 4) = {false};
                GUI.ChannelsTable.Data(1, 4) = {true};
                
                if ch_num == 12
                    parent_axes = GUI.ECG_Axes_Array(1);
                    ch_marker_size = 4;
                else
                    parent_axes = GUI.ECG_Axes;
                    ch_marker_size = 5;
                end
                create_fiducials_filt_handles(1, ch_marker_size, parent_axes);
                set_fid_visible(1);
            end
        end
    end
%%
    function ArNet2_pushbutton_Callback(~, ~)
        
        %         command = ['"' executable_file '" ' '"' 'D:\Alexandra\OneDrive - Technion\Work\ARNet2 Shany\qrs.mat' '" ' '"' 'D:\Alexandra\OneDrive - Technion\Work\ARNet2 Shany\' '"' ];
        waitbar_handle = waitbar(0, 'Calculating ArNet2', 'Name', 'ArNet2'); setLogo(waitbar_handle, DATA.Module);
        try
            [rr_time, rr_data, ~] = calc_rr();
            
            if DATA.PlotHR == 1
                rr_data = 60./ rr_data;
            end
            
            disp('save temp files:');
            waitbar_handle = waitbar(1/2, waitbar_handle, 'Saving ArNet2 temp files'); setLogo(waitbar_handle, DATA.Module);
            tic
            peaks_file = [tempdir 'temp_4arnet2.mat'];
            save(peaks_file, 'rr_data', 'rr_time');
            toc
        catch e
            disp(e.message);
        end
        
        exe_file_path = fileparts(mfilename('fullpath'));
        executable_file = [exe_file_path filesep 'ArNet2' filesep 'ArNet2_for_physiozoo.exe'];
        
        tempdir_name = tempdir;
        
        if exist(executable_file, 'file')
            
            command = ['"' executable_file '" ' '"' peaks_file '" ' '"' tempdir_name(1:end-1) '"'];
            
            waitbar_handle = waitbar(2/2, waitbar_handle, 'Calc ArNet2 rhythms'); setLogo(waitbar_handle, DATA.Module);
            tic
            [res, out, error] = jsystem(command, 'noshell');
            toc
            if(res ~= 0)
                disp(['jsystem error: ', error, '\n', out]);
            else
                rhythms_file_name = [tempdir_name '\' 'rhythms.txt'];
            end
            
            delete(peaks_file);
            if ~exist(rhythms_file_name, 'file')
                h_e = errordlg('ArNet2_pushbutton_Callback error: The exe file was not executed', 'Input Error'); setLogo(h_e, DATA.Module);
            else
                LoadRhythmsFile('rhythms.txt', tempdir_name);
                try
                    delete(rhythms_file_name);
                catch
                end
                SaveRhythms_Callback();
                %                 set(GUI.GUIRecord.RhythmsFileName_text, 'String', Rhythms_FileName);
            end
        end
        if isvalid(waitbar_handle)
            close(waitbar_handle);
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
        try
            if isfield(GUI, 'timer_object')
                delete(GUI.timer_object);
            end
            %             delete(GUI.Window);
        catch
        end
        if exist('GUI', 'var') && isfield(GUI, 'Window') && isvalid(GUI.Window)
            delete(GUI.Window);
        end
    end % onExit
end