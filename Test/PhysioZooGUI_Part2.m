function varargout = PhysioZooGUI_Part2(varargin)
% PhysioZooGUI_Part2 MATLAB code for PhysioZooGUI_Part2.fig
%      PhysioZooGUI_Part2, by itself, creates a new PhysioZooGUI_Part2 or raises the existing
%      singleton*.
%
%      H = PhysioZooGUI_Part2 returns the handle to a new PhysioZooGUI_Part2 or the handle to
%      the existing singleton*.
%
%      PhysioZooGUI_Part2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PhysioZooGUI_Part2.M with the given input arguments.
%
%      PhysioZooGUI_Part2('Property','Value',...) creates a new PhysioZooGUI_Part2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PhysioZooGUI_Part2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PhysioZooGUI_Part2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to helpmenu PhysioZooGUI_Part2

% Last Modified by GUIDE v2.5 26-Feb-2018 17:02:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PhysioZooGUI_Part2_OpeningFcn, ...
    'gui_OutputFcn',  @PhysioZooGUI_Part2_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%% --- Executes just before PhysioZooGUI_Part2 is made visible.
function PhysioZooGUI_Part2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PhysioZooGUI_Part2 (see VARARGIN)

% Choose default command line output for PhysioZooGUI_Part2

handles.output = hObject;
handles.DATA.mainWindow = hObject;

handles.DATA.zoom_handle = zoom(hObject);
%DATA.zoom_handle.Motion = 'vertical';
handles.DATA.zoom_handle.Enable = 'on';

%myUpBackgroundColor = [0.863 0.941 0.906]; % Green
myUpBackgroundColor = [219 237 240]/255; % Blue
myEditTextColor = [1 1 1];

handles.DATA.mammals = {'human', 'rabbit', 'mouse', 'dog', 'custom'};
handles.DATA.mammal_index = 1;


handles.DATA.GUI_Integration = {'ECG'; 'Electrogram'; 'Action Potential'};
handles.DATA.Integration = 'ECG';
handles.DATA.integration_index = 1;


%handles.DATA.temp_rec_name4wfdb = [fileparts(mfilename('fullpath')) filesep 'Temp' filesep 'temp_ecg_wfdb'];
% gui_basepath = fileparts(mfilename('fullpath'));
% [basepath guipath] = fileparts(gui_basepath);
% handles.DATA.temp_rec_name4wfdb = [guipath filesep 'Temp' filesep 'temp_ecg_wfdb'];
handles.DATA.temp_rec_name4wfdb = 'temp_ecg_wfdb';

handles.main_tab_group  = uix.TabPanel('Parent', handles.Main_uipanel, 'Units', 'Normalized', 'Position', [0 0 1 1], 'Padding', 5);
handles.Record_Tab = uix.Panel( 'Parent', handles.main_tab_group, 'Padding', 5); 
handles.ConfigParam_Tab = uix.Panel( 'Parent', handles.main_tab_group, 'Padding', 5); % , 'BorderType', 'none'

handles.main_tab_group.TabTitles = {'Record', 'Config Params'};
handles.main_tab_group.TabWidth = 120;
handles.main_tab_group.FontSize = 12;

set(handles.RecordParams_uipanel, 'Parent', handles.Record_Tab, 'Units', 'Normalized', 'Position', [0 0 1 1]);
set(handles.ConfigurationParameters_uipanel, 'Parent', handles.ConfigParam_Tab, 'Units', 'Normalized', 'Position', [0 0 1 1]);

set(findobj(handles.RecordParams_uipanel,'Style', 'edit'), 'BackgroundColor', myEditTextColor, 'Units', 'Normalized');
set(findobj(handles.RecordParams_uipanel,'Style', 'text'), 'BackgroundColor', myUpBackgroundColor, 'Units', 'Normalized');
set(findobj(handles.RecordParams_uipanel,'Style', 'radiobutton'), 'BackgroundColor', myUpBackgroundColor, 'Units', 'Normalized');
set(handles.uibuttongroup1, 'BackgroundColor', myUpBackgroundColor, 'Units', 'Normalized');
set(findobj(handles.ConfigurationParameters_uipanel,'Style', 'edit'), 'BackgroundColor', myEditTextColor, 'Units', 'Normalized');
set(findobj(handles.ConfigurationParameters_uipanel,'Style', 'text'), 'BackgroundColor', myUpBackgroundColor, 'Units', 'Normalized');

set(findobj(handles.PZ_GUI_Part_1_figure,'Type', 'uicontainer'), 'BackgroundColor', myUpBackgroundColor, 'Units', 'Normalized');
set(findobj(handles.PZ_GUI_Part_1_figure,'Type', 'uipanel'), 'BackgroundColor', myUpBackgroundColor, 'Units', 'Normalized');

set(findobj(handles.Results_uipanel,'Style', 'edit'), 'BackgroundColor', myEditTextColor, 'Units', 'Normalized');
set(findobj(handles.Results_uipanel,'Style', 'text'), 'BackgroundColor', myUpBackgroundColor, 'Units', 'Normalized');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PhysioZooGUI_Part2 wait for user response (see UIRESUME)
% uiwait(handles.PZ_GUI_Part_1_figure);


%% --- Outputs from this function are returned to the command line.
function varargout = PhysioZooGUI_Part2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% --- Executes on selection change in Mammal_popupmenu.
function Mammal_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Mammal_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Mammal_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Mammal_popupmenu
DATA = handles.DATA;
DATA.customConfigFile = [];

index_selected = get(hObject, 'Value');

if index_selected == 5
    
    [Config_FileName, PathName] = uigetfile({'*.conf','Configuration files (*.conf)'}, 'Open Configuration File', []);
    if ~isequal(Config_FileName, 0)
        params_filename = fullfile(PathName, Config_FileName);
        DATA.customConfigFile = params_filename;
    else % Cancel by user
        hObject.Value = DATA.mammal_index;
        return;
    end
end
DATA.mammal_index = index_selected;
handles.DATA = DATA;

handles = RunAndPlotPeakDetector(handles, index_selected, DATA.customConfigFile);
guidata(hObject, handles);

%% --- Executes during object creation, after setting all properties.
function Mammal_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mammal_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --------------------------------------------------------------------
function OpenFileMainMenu_Callback(hObject, eventdata, handles)
% hObject    handle to OpenFileMainMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);


%% --------------------------------------------------------------------
function PeaksMainMenu_Callback(hObject, eventdata, handles)
% hObject    handle to PeaksMainMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% --------------------------------------------------------------------
function RunPeakDetector_Callback(hObject, eventdata, handles)
% hObject    handle to RunPeakDetector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);

%% --------------------------------------------------------------------
function LoadPeaksFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadPeaksFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);

%% --------------------------------------------------------------------
function SavePeaks2File_Callback(hObject, eventdata, handles)
% hObject    handle to SavePeaks2File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);

%% --------------------------------------------------------------------
function OpenFile_Callback(hObject, eventdata, handles)
% hObject    handle to OpenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

persistent DIRS;
persistent EXT;

% Add third-party dependencies to path
gui_basepath = fileparts(mfilename('fullpath'));
basepath = fileparts(gui_basepath);

if ~isfield(DIRS, 'dataDirectory') %isempty(DIRS.dataDirectory)
    DIRS.dataDirectory = [basepath filesep 'Examples'];
end
if isempty(EXT)
    EXT = 'mat';
end

DATA = handles.DATA;

[ECG_FileName, PathName] = uigetfile( ...
    {'*.dat',  'WFDB Files (*.dat)'; ...
    '*.mat','MAT-files (*.mat)'; ...
    '*.txt','Text Files (*.txt)'}, ...
    'Open ECG File', [DIRS.dataDirectory filesep '*.' EXT]); % 

if ~isequal(ECG_FileName, 0)
        
    delete_temp_wfdb_files(handles);
    
    set(handles.FileName_text, 'String', '');
    set(handles.PeaksFileName_text, 'String', '');
    set(handles.DataQualityFileName_text, 'String', '');
    set(handles.RecordLength_text, 'String', '');
        
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
        if ~isempty(regexpi(ECG_field_names{1}, 'ecg|data'))
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
        end
    elseif strcmpi(ExtensionFileName, 'txt')
    end
    set(handles.FileName_text, 'String', ECG_FileName); % fullfile(PathName, ECG_FileName)
    
    cla(handles.RawData_axes);
    cla(handles.RR_axes);
    
    handles.DATA.mammal_index = 1;
    set(handles.Mammal_popupmenu, 'Value', 1);
    
    DATA.RawDataHandle = line(DATA.tm, DATA.sig, 'Parent', handles.RawData_axes);    
    
    PathName = strrep(PathName, '\', '\\');
    PathName = strrep(PathName, '_', '\_');
    ECG_FileName_title = strrep(ECG_FileName, '_', '\_');
    
    TitleName = [PathName ECG_FileName_title] ;
    title(handles.RawData_axes, TitleName, 'FontWeight', 'normal', 'FontSize', 11);
    
    min_sig = min(DATA.sig);
    max_sig = max(DATA.sig);
    delta = (max_sig - min_sig)*0.1;
    
    set(handles.RawData_axes, 'XLim', [0 max(DATA.tm)]);
    set(handles.RawData_axes, 'YLim', [min(min_sig, max_sig) - delta max(min_sig, max_sig) + delta]);
    
    xlabel(handles.RawData_axes, 'Time (sec)');
    ylabel(handles.RawData_axes, 'ECG (mV)');
    hold(handles.RawData_axes, 'on');
    
    handles.DATA = DATA;
    set(handles.RecordLength_text, 'String', [[num2str(header_info.duration.h) ':' num2str(header_info.duration.m) ':' ...
        num2str(header_info.duration.s) '.' num2str(header_info.duration.ms)] '    h:min:sec.msec']);
    
    handles.LoadConfigurationFile.Enable = 'on';
    handles.SaveConfigurationFile.Enable = 'on';
    handles.SavePeaks.Enable = 'on';
    
    handles = RunAndPlotPeakDetector(handles, get(handles.Mammal_popupmenu, 'Value'), []);

end
guidata(hObject, handles);
%%
function delete_temp_wfdb_files(handles)
if isfield(handles, 'DATA')
    if exist([handles.DATA.temp_rec_name4wfdb '.hea'], 'file')
        delete([handles.DATA.temp_rec_name4wfdb '.hea']);
    end
    if exist([handles.DATA.temp_rec_name4wfdb '.dat'], 'file')
        delete([handles.DATA.temp_rec_name4wfdb '.dat']);
    end
end
%% --------------------------------------------------------------------
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete_temp_wfdb_files(handles);
delete( handles.DATA.mainWindow );

%% --------------------------------------------------------------------
function HelpMainMenu_Callback(hObject, eventdata, handles)
% hObject    handle to HelpMainMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% --------------------------------------------------------------------
function HelpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to HelpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% --------------------------------------------------------------------
function AboutMenu_Callback(hObject, eventdata, handles)
% hObject    handle to AboutMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% --- Executes on selection change in IntegrationLevel_popupmenu.
function IntegrationLevel_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to IntegrationLevel_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns IntegrationLevel_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from IntegrationLevel_popupmenu

items = get(hObject, 'String');
index_selected = get(hObject, 'Value');
handles.DATA.Integration = items{index_selected}; 

guidata(hObject, handles);

%% --- Executes during object creation, after setting all properties.
function IntegrationLevel_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IntegrationLevel_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
guidata(hObject, handles);

%% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%% --- Executes on button press in RunPeakDetection_pushbutton.
% function RunPeakDetection_pushbutton_Callback(hObject, eventdata, handles)
% % hObject    handle to RunPeakDetection_pushbutton (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% handles = RunAndPlotPeakDetector(handles, get(handles.Mammal_popupmenu, 'Value'), []);
% 
% guidata(hObject, handles);

%%
function handles = RunAndPlotPeakDetector(handles, mammal_index, customConfigFile)

DATA = handles.DATA;

cla(handles.RR_axes);
if isfield(DATA, 'red_peaks_handle') && ishandle(DATA.red_peaks_handle) && isvalid(DATA.red_peaks_handle)
    delete(DATA.red_peaks_handle);
end

if mammal_index == 5
    conf_path = customConfigFile;
else
    conf_path = ['gqrs.' DATA.mammals{mammal_index} '.conf'];
end
DATA.config_map = parse_gqrs_config_file(conf_path);

params_GUI_edit_values = findobj('Parent', handles.ConfigurationParameters_uipanel, 'Style', 'edit');
fields_names = get(params_GUI_edit_values, 'UserData');

for i = 1 : length(params_GUI_edit_values)
    param_value = DATA.config_map(fields_names{i});
    set(params_GUI_edit_values(i), 'String', param_value);
end

[DATA.qrs, DATA.outliers, tm, sig, Fs] = rqrs(DATA.rec_name, 'gqconf', conf_path, 'ecg_channel', DATA.ecg_channel, 'plot', false);
DATA.red_peaks_handle = line(DATA.tm(DATA.qrs), DATA.sig(DATA.qrs, 1), 'Parent', handles.RawData_axes, 'Color', 'r', 'LineStyle', 'none', 'Marker', 'x', 'LineWidth', 2);

rr_time = DATA.qrs(1:end-1)/DATA.Fs;
rr_data = diff(DATA.qrs)/DATA.Fs;

if ~isempty(rr_data)
    DATA.RRInt_handle = line(rr_time, rr_data, 'Parent', handles.RR_axes);
    
    min_sig = min(rr_data);
    max_sig = max(rr_data);
    delta = (max_sig - min_sig)*1;
    
    set(handles.RR_axes, 'XLim', [0 max(DATA.tm)]);
    set(handles.RR_axes, 'YLim', [min(min_sig, max_sig) - delta max(min_sig, max_sig) + delta]);
    
    % xlabel('Time (sec)');
    ylabel('RR (sec)');    
    linkaxes([handles.RawData_axes, handles.RR_axes], 'x');    
    set(handles.NumPeaksDetected_edit, 'String', num2str(length(DATA.qrs)));
else
    errordlg('The algorithm could not run. Please, check input parameters.', 'Input Error');
end
handles.DATA = DATA;

%% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


%% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


%% --------------------------------------------------------------------
function LoadConfigurationFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadConfigurationFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[Config_FileName, PathName] = uigetfile({'*.conf','Conf files (*.conf)'}, 'Open Configuration File', []);
if ~isequal(Config_FileName, 0)
    params_filename = fullfile(PathName, Config_FileName);        
    handles = RunAndPlotPeakDetector(handles, 5, params_filename);    
    handles.Mammal_popupmenu.Value = 5;
    handles.DATA.mammal_index = 5;
end

guidata(hObject, handles);

%% --- Executes on selection change in SignalQuality_popupmenu.
function SignalQuality_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to SignalQuality_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SignalQuality_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SignalQuality_popupmenu


%% --- Executes during object creation, after setting all properties.
function SignalQuality_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SignalQuality_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on selection change in SignalQuality_listbox.
function SignalQuality_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to SignalQuality_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SignalQuality_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SignalQuality_listbox


%% --- Executes during object creation, after setting all properties.
function SignalQuality_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SignalQuality_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --------------------------------------------------------------------
function LoadQualityFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadQualityFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% --------------------------------------------------------------------
function SaveQualityAnnotations_Callback(hObject, eventdata, handles)
% hObject    handle to SaveQualityAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% --------------------------------------------------------------------
function SaveConfigurationFile_Callback(hObject, eventdata, handles)
% hObject    handle to SaveConfigurationFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, results_folder_name, FilterIndex] = uiputfile({'*.','Conf Files (*.conf)'},'Choose Config File Name', ['gqrs.custom.conf']);

if ~isequal(results_folder_name, 0)                       
    full_file_name_conf = fullfile(results_folder_name, filename);        
    button = 'Yes';
    if exist(full_file_name_conf, 'file')
        button = questdlg([full_file_name_conf ' already exist. Do you want to overwrite it?'], 'Overwrite existing file?', 'Yes', 'No', 'No');
    end
    if strcmp(button, 'Yes')
        saveCustomParameters(handles, full_file_name_conf);
    end
end


%% --- Executes during object creation, after setting all properties.
function config_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function QS_edit_config_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double


%% --- Executes during object creation, after setting all properties.
function QS_edit_config_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function QT_edit_config_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double

%%
% --- Executes during object creation, after setting all properties.
function QT_edit_config_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function QRSa_edit_config_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double

%%
% --- Executes during object creation, after setting all properties.
function QRSa_edit_config_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function QRSamin_edit_config_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double


%% --- Executes during object creation, after setting all properties.
function QRSamin_edit_config_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function RRmin_edit_config_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double

%%
% --- Executes during object creation, after setting all properties.
function RRmin_edit_config_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function RRmax_edit_config_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double


%% --- Executes during object creation, after setting all properties.
function RRmax_edit_config_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
function config_edit_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double
DATA = handles.DATA;

DATA.config_map(get(hObject, 'UserData')) = get(hObject, 'String');

handles.DATA = DATA;
guidata(hObject, handles);


%% --- Executes on button press in CalcWithNewValues_pushbutton.
function CalcWithNewValues_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CalcWithNewValues_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DATA = handles.DATA;
Config_FileName = 'gqrs.temp_custom.conf';

if isfield(DATA, 'config_map')   
    temp_custom_conf_fileID = saveCustomParameters(handles, Config_FileName);
    if temp_custom_conf_fileID ~= -1
        handles = RunAndPlotPeakDetector(handles, 5, fullfile(pwd, Config_FileName));    
        delete(Config_FileName);
    end
end
guidata(hObject, handles);

%%
function temp_custom_conf_fileID = saveCustomParameters(handles, FullFileName)

DATA = handles.DATA;
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
% --------------------------------------------------------------------
function SaveDataQuality_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDataQuality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenDataQuality_Callback(hObject, eventdata, handles)
% hObject    handle to OpenDataQuality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function PZ_GUI_Part_1_figure_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to PZ_GUI_Part_1_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete_temp_wfdb_files(handles);


% --- Executes on button press in DeleteSignalQuality_radiobutton.
function DeleteSignalQuality_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteSignalQuality_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DeleteSignalQuality_radiobutton


% --- Executes when Results_uipanel is resized.
function Results_uipanel_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to Results_uipanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function NumPeaksDetected_edit_Callback(hObject, eventdata, handles)
% hObject    handle to NumPeaksDetected_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumPeaksDetected_edit as text
%        str2double(get(hObject,'String')) returns contents of NumPeaksDetected_edit as a double


% --- Executes during object creation, after setting all properties.
function NumPeaksDetected_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumPeaksDetected_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumPeaksCorrected_edit_Callback(hObject, eventdata, handles)
% hObject    handle to NumPeaksCorrected_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumPeaksCorrected_edit as text
%        str2double(get(hObject,'String')) returns contents of NumPeaksCorrected_edit as a double


% --- Executes during object creation, after setting all properties.
function NumPeaksCorrected_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumPeaksCorrected_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PercantageBadQuality_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PercantageBadQuality_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PercantageBadQuality_edit as text
%        str2double(get(hObject,'String')) returns contents of PercantageBadQuality_edit as a double


% --- Executes during object creation, after setting all properties.
function PercantageBadQuality_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PercantageBadQuality_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6


% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HR_edit_config_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double


% --- Executes during object creation, after setting all properties.
function HR_edit_config_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function QS_edit_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double


% --- Executes during object creation, after setting all properties.
function QS_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function QT_edit_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double


% --- Executes during object creation, after setting all properties.
function QT_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function QRSa_edit_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double


% --- Executes during object creation, after setting all properties.
function QRSa_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function QRSamin_edit_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double


% --- Executes during object creation, after setting all properties.
function QRSamin_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RRmin_edit_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double


% --- Executes during object creation, after setting all properties.
function RRmin_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RRmax_edit_Callback(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of config_edit as text
%        str2double(get(hObject,'String')) returns contents of config_edit as a double


% --- Executes during object creation, after setting all properties.
function RRmax_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to config_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CalcWithNewValues_pushbutton.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to CalcWithNewValues_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SavePeaks_Callback(hObject, eventdata, handles)
% hObject    handle to SavePeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

persistent DIRS;
persistent EXT;

% Add third-party dependencies to path
gui_basepath = fileparts(mfilename('fullpath'));
basepath = fileparts(gui_basepath);

if ~isfield(DIRS, 'analyzedDataDirectory') %isempty(DIRS.dataDirectory)
    DIRS.analyzedDataDirectory = [basepath filesep 'Results'];
end
if isempty(EXT)
    EXT = 'mat';
end

DATA = handles.DATA;
original_file_name = DATA.DataFileName;
file_name = [original_file_name, '_peaks'];

[filename, results_folder_name, ~] = uiputfile({'*.*', 'All files';...
                                                          '*.txt','Text Files (*.txt)';...
                                                          '*.mat','MAT-files (*.mat)'},...
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
    Mammal = DATA.mammals{handles.DATA.mammal_index};

    if strcmpi(ExtensionFileName, 'mat')
       save([results_folder_name, filename], 'Data', 'Fs', 'Integration', 'Mammal'); 
    end
end





handles.DATA = DATA;
