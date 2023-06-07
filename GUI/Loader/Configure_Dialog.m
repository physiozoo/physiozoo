function varargout = Configure_Dialog(varargin)
% CONFIGURE_DIALOG MATLAB code for Configure_Dialog.fig
%      CONFIGURE_DIALOG, by itself, creates a new CONFIGURE_DIALOG or raises the existing
%      singleton*.
%
%      H = CONFIGURE_DIALOG returns the handle to a new CONFIGURE_DIALOG or the handle to
%      the existing singleton*.
%
%      CONFIGURE_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGURE_DIALOG.M with the given input arguments.
%
%      CONFIGURE_DIALOG('Property','Value',...) creates a new CONFIGURE_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Configure_Dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Configure_Dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Configure_Dialog

% Last Modified by GUIDE v2.5 03-Jun-2023 14:29:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Configure_Dialog_OpeningFcn, ...
    'gui_OutputFcn',  @Configure_Dialog_OutputFcn, ...
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


% --- Executes just before Configure_Dialog is made visible.
function Configure_Dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Configure_Dialog (see VARARGIN)

% Choose default command line output for Configure_Dialog
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
cmd = FGV_CMD;
UniqueMap = FGV_DATA(cmd.GET);
ENABLE = [{'on'};{'off'}];
FIRST_ITEM = [{'select'};{'auto'}];
Config = ReadYaml('Loader Config.yml');
BGColor = [[ 1.0000    0.8667    0.8667];[1 1 1]];
setappdata(handles.figure1,'Config',Config)
Names = fieldnames(Config);

for i = 1 : length(Names)-2
    localName = cell2mat(Names(i));
    if i > 1
        strItems = Config.(localName)';
    else
%         strItems =  fieldnames(Config.(localName));
        strItems =  replace(fieldnames(Config.(localName)),'_',' ');
    end
    set(handles.(['pm_',localName]),'string',strItems,'value',1)
end

%% ------------- Put Logo --------------------
warning('off');
javaFrame = get(handles.figure1, 'JavaFrame');
javaFrame.setFigureIcon(javax.swing.ImageIcon([fileparts(fileparts(mfilename('fullpath'))) filesep 'Logo' filesep 'logoRed.png']));
warning('on');


%% ------------- Put the figure on screen centre --------------------
figUnits = handles.figure1.Units;
handles.figure1.Units = 'pixels';
screen = get(0,'ScreenSize');
figPos = handles.figure1.Position;
handles.figure1.Position(1) = int32((screen(3)-figPos(3))/2);
handles.figure1.Position(2) = int32((screen(4)-figPos(4))/2);
handles.figure1.Units = figUnits;
movegui(handles.figure1, 'northwest');
%% ---------------------------------------------------------------

% handles.btnSaveAs.Visible = 'off';
set(handles.txtFileName,'string',['File name:  ',UniqueMap('Name')])
set(handles.txtAlarm,'string','')
hCh = findobj(handles.figure1,'style','popupmenu');
set(hCh,'backgroundcolor',BGColor(1,:),'value',1,'enable','on')

%% ------------------- Set Params Control ---------------------------------
hFileParams =  findobj(handles.uipGeneral,'style','popupmenu');

for iParameter = 1 : length(hFileParams)
    hObj = hFileParams((iParameter));
    pName = get(hObj,'tag');
    try
        strParamValue = replace(strtrim(lower(UniqueMap(pName(4:end)))),' ','_');
    catch
        continue
    end
    Set_Popupmenu(hObj, strParamValue, 'off')
    Channels.General.(pName(4:end)) = strParamValue;
end

%     Item = Get_Popupmenu_Item_Text(handles.pm_file_type)
%     set(handles.pm_data_type,'string',['select';strItems],'value',1)


%% -------------- Init Fs control ---------------------------------------
try
    eboxColor = 'w';
    eboxString = UniqueMap('fs');
    Fs = eboxString;
    enable = 'off';
catch
    eboxColor = [ 1.0000    0.8667    0.8667];
    eboxString = ' '; %NaN
    Fs = NaN;
    enable = 'on';
end
set(handles.ebFs,'backgroundcolor',eboxColor,'string',eboxString,'enable',enable)
%% ----------- Init All popupmenu controls----------------


%% --------------Get data -------------------------------------
try
    data = UniqueMap('rawData');
    Data_Size = size(data,2);
    set(handles.figure1,'userdata',data)
catch
    btnOK_Callback(hObject, eventdata, handles)
    return
end

%% --------------Get Channels  -------------------------------------
if isKey(UniqueMap,'channels')
    rawChannels = UniqueMap('channels');
else
    rawChannels = zeros(1,Data_Size);
end
if length(rawChannels) ~= Data_Size
    UniqueMap('MSG') = 'msg_8';
    FGV_DATA(cmd.SET,UniqueMap);
    btnOK_Callback(hObject, eventdata, handles)
    return
end

%% ---------------Get Channels Information -------------
Channels.Time.Enable = 0;
Channels.Time.No = 0;
Channels.Time.Scale_factor= 1;
Channels.Time.Fs = Fs;
Channels.Time.Unit = 'second';
Channels.Time.Type = 'time';
Channels.Time.Name = 'time';
Channels.Data.Enable = 0;
Channels.Data.No =  Data_Size;
Channels.Data.Scale_factor = 1;
Channels.Data.Data = [];%  Changed 080720 data(:,Channels.Data.No);
Channels.Data.Unit = 'select';
Channels.Data.Type = 'select';
Channels.Data.Name = 'data';
Channels.Data.EnabledChNames = {};
for i = 1 : Data_Size
    Channels.Data.Names{i} = sprintf('Ch%02d',i);
end
Channels.Data.Names = Channels.Data.Names';
status_enable =2;
if UniqueMap('IsHeader')
    for iCh = 1 : length(rawChannels)
        try
            localChannel = cell2mat(rawChannels(iCh));
            type = lower(localChannel.type);
            Channels.Data.Names{iCh} = localChannel.name;
            switch type
                case 'time'
                    type = 'Time';
                otherwise
                    type = 'Data';
            end
            if localChannel.enable         
                Channels.Data.EnabledChNames{end+1} = localChannel.name;
                Channels = Update_Channel_Info(Channels,iCh,localChannel,data,type,Config);
            end            
        catch
        end
    end
    status_enable = 1;
end
if ~Channels.Time.No
    if sum((diff(data(:,1)))>0) < (length(data)-1)
        Channels.Time.Data = ((1:length(data))*(1/Channels.Time.Fs))';
     else
        status_enable = 1;
        if data(1,1) > 10000000000
            data(:,1) = data(:,1)/1000;
        end
        Channels.Time.Data = data(:,1);
        Channels = Update_Fs(Channels,handles,cell2mat(ENABLE(status_enable)),'msg_1');
    end
    if size(data,2) <= 1
        status_enable = 2;
    end
else
    status_enable = 2;
    Channels = Update_Fs(Channels,handles,cell2mat(ENABLE(status_enable)),'msg_1');
end
set(handles.pm_time_channel,'string',[FIRST_ITEM(status_enable);Channels.Data.Names])
set(handles.pm_time_channel,'value',Channels.Time.No+1,'backgroundcolor',BGColor(status_enable,:),'enable',cell2mat(ENABLE(status_enable)))


%% Set pm
set(handles.pm_data_unit,'string',['select';Config.data_type.(Channels.Data.Type)'])
Set_Popupmenu(handles.pm_time_unit, Channels.Time.Unit, cell2mat(ENABLE(status_enable)))
Set_Popupmenu(handles.pm_data_unit, Channels.Data.Unit, cell2mat(ENABLE(Channels.Data.Enable+1)))
Set_Popupmenu(handles.pm_data_type, Channels.Data.Type, cell2mat(ENABLE(Channels.Data.Enable+1)))
[Channels,err] = UpdateDataChannel(Channels,handles);
AlarmStatus(err,handles,'msg_2');
Channels = UpdateTimeChannel(Channels,handles);


set(handles.pm_channels_name,'string',[{'select'};Channels.Data.Names(~ismember(Channels.Data.Names,Channels.Time.Name))],...
                             'value',Channels.Data.No-Channels.Time.No+1,...
                             'backgroundcolor','w','enable',cell2mat(ENABLE(Channels.Data.Enable+1)))
                         
if IsPlotData(hObject, [], handles)
    PlotData(Channels,handles.axData)
else
    cla(handles.axData)
end


% UIWAIT makes Configure_Dialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);

setappdata(handles.figure1,'Channels',Channels)
switch CheckStatus(handles.ebFs, eventdata, handles)
    case 'on'
        btnOK_Callback(handles.btnOK, 0, handles);
        return
    otherwise
end
% --- Outputs from this function are returned to the command line.
function varargout = Configure_Dialog_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
try
varargout{1} = handles.output;
catch
    varargout{1} = [];
end

% --- Executes on selection change in pm_integration_level.
function pm_integration_level_Callback(hObject, eventdata, handles)
% hObject    handle to pm_integration_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_integration_level contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_integration_level
Channels = getappdata(handles.figure1,'Channels');
Channels.General.integration_level = Get_Popupmenu_Item_Text(hObject);
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)

% --- Executes during object creation, after setting all properties.
function pm_integration_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_integration_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pm_data_unit.
function pm_data_unit_Callback(hObject, eventdata, handles)
% hObject    handle to pm_data_unit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_data_unit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_data_unit

Channels = getappdata(handles.figure1,'Channels');
Channels.Data.Unit = Get_Popupmenu_Item_Text(hObject);
Channels.Data.Scale_factor =  ScaleFactor('data',Channels.Data.Unit);
if IsPlotData(hObject, [], handles)
    [Channels,err] = UpdateDataChannel(Channels,handles);
    AlarmStatus(err,handles,'msg_2');
    Channels = UpdateTimeChannel(Channels,handles);
    PlotData(Channels,handles.axData)
else
    cla(handles.axData)
end
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)



% --- Executes during object creation, after setting all properties.
function pm_data_unit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_data_unit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pm_mammal.
function pm_mammal_Callback(hObject, eventdata, handles)
% hObject    handle to pm_mammal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_mammal contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_mammal
Channels = getappdata(handles.figure1,'Channels');
Channels.General.mammal = Get_Popupmenu_Item_Text(hObject);
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)

% --- Executes during object creation, after setting all properties.
function pm_mammal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_mammal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ebFs_Callback(hObject, eventdata, handles)
% hObject    handle to ebFs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ebFs as text
%        str2double(get(hObject,'String')) returns contents of ebFs as a double
data = get(handles.figure1,'userdata');
Fs = str2double(get(hObject,'string'));
if isnan(Fs) || Fs > 10000
    Fs = NaN;
    set(hObject,'string',' ')
end
Channels = getappdata(handles.figure1,'Channels');
Channels.Time.Fs = Fs;
Channels = SetTimeChannel(handles.pm_time_channel,Channels,data);
if IsPlotData(hObject, [], handles)
    [Channels,err] = UpdateDataChannel(Channels,handles);
    AlarmStatus(err,handles,'msg_2');
    Channels = UpdateTimeChannel(Channels,handles);
    
    PlotData(Channels,handles.axData)
else
    cla(handles.axData)
end
switch Channels.Data.Type
    case 'electrography'
        Update_Fs(Channels,handles,get(hObject,'enable'),'msg_1')
        if false
            if Channels.Time.Fs ~= 1/(mean(diff(Channels.Time.Data))*Channels.Time.Scale_factor)
                err = true;
            else
                err = false;
            end
            AlarmStatus(err,handles,'msg_1');
        end
    otherwise
end
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)





% --- Executes during object creation, after setting all properties.
function ebFs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ebFs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pm_file_type.
function pm_file_type_Callback(hObject, eventdata, handles)
% hObject    handle to pm_file_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_file_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_file_type
ENABLE = [{'on'};{'off'}];
Channels = getappdata(handles.figure1,'Channels');
Config = getappdata(handles.figure1,'Config');
Channels.General.file_type = Get_Popupmenu_Item_Text(hObject);
set(handles.pm_data_unit,'string',Config.file_type.(Channels.General.file_type).unit')
set(handles.pm_data_type,'string',['select';Config.file_type.(Channels.General.file_type).type'],'value',1)
Set_Popupmenu(handles.pm_data_unit, Channels.Data.Unit, cell2mat(ENABLE(Channels.Data.Enable+1)))
Set_Popupmenu(handles.pm_data_type, Channels.Data.Type, cell2mat(ENABLE(Channels.Data.Enable+1)))

CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)


% --- Executes during object creation, after setting all properties.
function pm_file_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_file_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
% hObject    handle to btnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Channels = getappdata(handles.figure1,'Channels');
assignin('base','Channels',Channels)
cmd = FGV_CMD;
UniqueMap = FGV_DATA(cmd.GET);
UniqueMap('DATA') = Channels;
FGV_DATA(cmd.SET,UniqueMap);
try 
%     eventdata.Source
my_closereq(handles.figure1)
%     closereq
catch
  
end

% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cmd = FGV_CMD;
UniqueMap = FGV_DATA(cmd.GET);
UniqueMap('MSG') = 'msg_7';
FGV_DATA(cmd.SET,UniqueMap);

my_closereq(handles.figure1)


% Check if disable
function Status = CheckStatus(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hCh = [findobj(handles.uipGeneral,'style','popupmenu');handles.pm_data_unit;handles.pm_time_unit;handles.pm_channels_name];
Status = 'off';
if prod([cell2mat(get(hCh,'value'))-1;~isnan(str2double(get(handles.ebFs,'str')))])
    Status = 'on';
end
set(handles.btnOK,'enable',Status)
switch hObject
    case handles.ebFs
        status = isnan(str2double(get(handles.ebFs,'str')));
     case {handles.pm_time_channel}
         status =  (~(get(hObject,'value')-1) & strcmp(Get_Popupmenu_Item_Text(hObject),'select'));
     otherwise
        status = ~(get(hObject,'value')-1);
end

if status
    set(hObject,'backgroundcolor',[ 1.0000    0.8667    0.8667])  % red color
else
    set(hObject,'backgroundcolor','white')
end



% Check if disable
function Status = IsPlotData(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hCh = findobj(handles.figure1,'style','popupmenu');
hGeneral = findobj(handles.uipGeneral,'style','popupmenu');
hCh = hCh(~ismember(hCh,hGeneral));
hCh = hCh(~ismember(hCh,handles.pm_time_channel));
Status = false;
if prod([cell2mat(get(hCh,'value'))-1;~isnan(str2double(get(handles.ebFs,'str')))])
    Status = true;
end




% --- Executes on selection change in pm_channels_name.
function pm_channels_name_Callback(hObject, eventdata, handles)
% hObject    handle to pm_channels_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_channels_name contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_channels_name
Channels = getappdata(handles.figure1,'Channels');
Channels.Data.No = get(hObject,'value')-1+Channels.Time.No;
if IsPlotData(hObject, [], handles)
    [Channels,err] = UpdateDataChannel(Channels,handles);
    AlarmStatus(err,handles,'msg_2');
    Channels = UpdateTimeChannel(Channels,handles);
    PlotData(Channels,handles.axData)
    if err
         cla(handles.axData)
    end
else
    cla(handles.axData)
end
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)


% --- Executes during object creation, after setting all properties.
function pm_channels_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_channels_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSaveAs.
function btnSaveAs_Callback(hObject, eventdata, handles)
% hObject    handle to btnSaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CH = getappdata(handles.figure1,'Channels');
switch CH.Data.Type
    case {'interval','electrography'}
        file_type = '*.dat';
        file_name = 'WFDB files (*.dat)';
    case {'peak','beating_rate', 'oxygen_saturation'}
        file_type = '*.qrs; *.atr';
        file_name = 'WFDB Files (*.qrs; *.atr)';
    otherwise
end
cmd = FGV_CMD;
UniqueMap = FGV_DATA(cmd.GET);
ENABLE = [{'No'};{'Yes'}];
[filename, results_folder_name, ~] = uiputfile({'*.*', 'All files';...
    '*.txt','Text Files (*.txt)';...
    '*.mat','MAT-files (*.mat)';...
    file_type,file_name;},...
    'Choose Analyzed Data File Name',...
    [UniqueMap('File_path'), filesep, [UniqueMap('Name'),'_update'], '.', UniqueMap('Ext')]);
if ~filename
    return
end
[~, ~, ExtensionFileName] = fileparts(filename);
ExtensionFileName = ExtensionFileName(2:end);
Data = [CH.Time.Data,CH.Data.Data];
Fs = CH.Time.Fs;
Integration_level = CH.General.integration_level;
Mammal = CH.General.mammal;
Channels{1}.name = CH.Time.Name;
Channels{1}.type = CH.Time.Type;
Channels{1}.unit = CH.Time.Unit;
Channels{1}.enable = ENABLE{CH.Time.Enable+1};
Channels{2}.name = CH.Data.Name;
Channels{2}.type = CH.Data.Type;
Channels{2}.unit = CH.Data.Unit;
Channels{2}.enable = ENABLE{CH.Data.Enable+1};
switch ExtensionFileName
    case 'mat'
        save([results_folder_name,filename], 'Data', 'Fs', 'Integration_level', 'Mammal', 'Channels');
    case 'txt'
        header_fileID = fopen([results_folder_name,filename], 'wt');
        fprintf(header_fileID, '---\n');
        fprintf(header_fileID, 'Mammal:            %s\n', Mammal);
        fprintf(header_fileID, 'Fs:                %d\n', Fs);
        fprintf(header_fileID, 'Integration_level: %s\n\n', Integration_level);
        fprintf(header_fileID, 'Channels:\n\n');
        for i = 1 : length(Channels)
            fprintf(header_fileID, '    - type:   %s\n', Channels{i}.type);
            fprintf(header_fileID, '      name:   %s\n', Channels{i}.name);
            fprintf(header_fileID, '      unit:   %s\n', Channels{i}.unit);
            fprintf(header_fileID, '      enable: %s\n\n', Channels{i}.enable);
        end
        fprintf(header_fileID, '---\n');
        dlmwrite([results_folder_name,filename], Data, 'delimiter', '\t', 'precision', '%d', 'newline', 'pc', '-append', 'roffset', 1);
        fclose(header_fileID);
    case {'atr','qrs'}
        [~, filename_noExt, ~] = fileparts(filename);
        comments = {['Mammal:' Mammal ',Integration_level:' Integration_level]};
        
        if ~strcmp(CH.Data.Type, 'oxygen_saturation')
            wrann([results_folder_name filename_noExt], ExtensionFileName, int64(cumsum(Data(:,2))*Fs), 'fs', Fs, 'comments', comments); % , 'comments', {[DATA.Integration '-' DATA.Mammal]}
        else
            wrann([results_folder_name filename_noExt], ExtensionFileName, int64(Data(:,2)), 'fs', Fs, 'comments', comments); % , 'comments', {[DATA.Integration '-' DATA.Mammal]}
        end
        
    otherwise
end


% --- Executes on selection change in pm_time_channel.
function pm_time_channel_Callback(hObject, eventdata, handles)
% hObject    handle to pm_time_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_time_channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_time_channel
Channels = getappdata(handles.figure1,'Channels');
data = get(handles.figure1,'userdata');
% toRemove = Get_Popupmenu_Item_Text(hObject);
strNames = get(hObject,'string');
Channels.Time.No = get(hObject,'value')-1;
if Channels.Time.No
    strNames(Channels.Time.No+1)=[];
end
dataName = Get_Popupmenu_Item_Text(handles.pm_channels_name);
set(handles.pm_channels_name,'value',1,'string',strNames)
Set_Popupmenu(handles.pm_channels_name, lower(dataName), get(handles.pm_channels_name,'enable'))
Channels = SetTimeChannel(handles.pm_time_channel,Channels,data);
% Channels = Update_Fs(Channels,handles,'on');
if IsPlotData(hObject, [], handles)
    PlotData(Channels,handles.axData)
else
    cla(handles.axData)
end
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)


% --- Executes during object creation, after setting all properties.
function pm_time_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_time_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Get Scale Factor 
function scale_factor = ScaleFactor(type,unit)
switch type
    case 'time'
        switch lower(unit)
            case 'millisecond'
                scale_factor = 0.001;
            case 'second'
                scale_factor = 1;
            case 'index'
                scale_factor = 1;
            otherwise
                scale_factor = 1;
        end
    case {'data','peak','interval'}
        switch lower(unit)
            case 'millivolt'
                scale_factor = 1;
            case 'volt'
                scale_factor = 1000;
            case 'microvolt'
                scale_factor = 0.001;
            case 'millisecond'
                scale_factor = 0.001;
            case 'second'
                scale_factor = 1;
            case 'index'
                scale_factor = 0;
            case 'bpm'
                scale_factor = 1;
            otherwise
                scale_factor = 1;
        end
    case 'percent'
        scale_factor = 1;
    otherwise
        scale_factor = 1;
end



function pm_time_unit_Callback(hObject, eventdata, handles)
% hObject    handle to pm_file_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_file_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_file_type
Channels = getappdata(handles.figure1,'Channels');
Channels.Time.Unit = Get_Popupmenu_Item_Text(hObject);
Channels.Time.Scale_factor =  ScaleFactor('time',Channels.Time.Unit);
[Channels,err] = UpdateDataChannel(Channels,handles);
AlarmStatus(err,handles,'msg_2');
if IsPlotData(hObject, [], handles)
    Channels = UpdateTimeChannel(Channels,handles);
    Channels = Update_Fs(Channels,handles,get(handles.ebFs,'enable'),'msg_1');
    
    PlotData(Channels,handles.axData)
else
    cla(handles.axData)
end
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)

% --- Executes during object creation, after setting all properties.
function pm_time_unit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_file_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- 
function Set_Popupmenu(hObject, pName, status)
strNames = lower(get(hObject,'string'));  
[Lia,LocB] = ismember(pName,strNames);
    if Lia && LocB-1
        set(hObject,'value',LocB,'backgroundcolor','w','enable',status)
    else
        set(hObject,'value',1)
    end

    
    
     
    % --- 
function Item = Get_Popupmenu_Item_Text(hObject)

val = get(hObject,'value');
str = get(hObject,'string');
if iscell(str)
    Item = cell2mat(str(val));
else
    Item = str(val);
end




%% ------------------
function DataChannel_ChangeString(hObject,File_Type)
    set(hObject,'string',header.file_type.(Channels.General.file_type).unit')
    if 0
        timeUnits = [{'Select Units'};{'milisecond'};{'second'};{'minute'};{'datapoint'}];
        signalUnits = [{'Select Units'};{'microvolt'};{'millivolt'};{'volt'};{'datapoint'}];
        switch lower(File_Type)
            case 'beating_rate'
                str = timeUnits;
            case 'electrography'
                str = signalUnits;
            otherwise
                str = timeUnits;
        end
        set(hObject,'string',str)
    end

%% ------------------
function Channels = Update_Channel_Info(Channels,iCh,localChannel,data,type,Config)
Channels.(type).No = iCh;
Channels.(type).Unit = Update_Unit(Config,lower(localChannel.unit));
Channels.(type).Scale_factor =  ScaleFactor(lower(type),Channels.(type).Unit);
switch type
    case 'Data'
        Channels.(type).Data = [Channels.(type).Data,data(:,iCh)];
    otherwise
        Channels.(type).Data = data(:,iCh);
end

Channels.(type).Enable = 1;
Channels.(type).Type = replace(strtrim(lower(localChannel.type)),' ','_');
Channels.(type).Name = lower(localChannel.name);

 

%% ------------------
function strUnit = Update_Unit(Config,unit)
AllUnits = fieldnames(Config.units);
strUnit = '';
for i = 1 : length(AllUnits)
    unitName = cell2mat(AllUnits(i));
    if sum(strcmp(Config.units.(unitName),unit))
         strUnit = unitName;
         break
    end
end


%% ------------------------- Set Time Channel
function Channels = SetTimeChannel(hObject,Channels,data)
% TimeChannel = int32(str2double(Get_Popupmenu_Item_Text(hObject)));
    TimeChannel = get(hObject,'value')-1;
if TimeChannel
    Channels.Time.Data = data(:,TimeChannel)*Channels.Time.Scale_factor;
else
    Channels.Time.Data = (((1:length(data))*(1/(Channels.Time.Fs)))'*Channels.Time.Scale_factor)';
end






  %% -----------------  Plot Data ------------------
    function PlotData(Channels,hAx)
        try
            iWc = int32(length(Channels.Data.Data)/2);
            switch Channels.Data.Type
                case 'electrography'
                    title = 'Amplitude (millivolt)';
                    Span = ((Channels.Time.Data(iWc)-2.5) < Channels.Time.Data & Channels.Time.Data < (Channels.Time.Data(iWc)+2.5));
%                     Span = GetSpan(Channels,5);
                    
                case {'interval','peak'}
                    title = 'Amplitude [millisec]';
                    Span = ((Channels.Time.Data(iWc)-15) < Channels.Time.Data & Channels.Time.Data < (Channels.Time.Data(iWc)+15));
%                     Span = GetSpan(Channels,30);
                                      
                otherwise
                    title = 'Amplitude [sec]';
                    Span =int32(length(Channels.Data.Data)/1000);
                    if ~Span || Span < 10 || Span > iWc
                        Span = iWc;
                    end
                    
            end
%             dataWindow = iWc-Span+1:iWc+Span-1;
            firstPoint = find(Span == 1);
            hp = plot(hAx,Channels.Time.Data(Span)-Channels.Time.Data(firstPoint(1)),Channels.Data.Data(Span));
            set(hp,'linewidth',1.5,'color',[0.1412    0.2745    0.2902]);
            axis(hAx,'tight')
            zoom(hAx,'on')
            ylabel(hAx,title)
        catch
        end
       
        
%% ---------- Get Span Function ------------------
        function Span = GetSpan(Channels,window)
            Span = (window/2)*Channels.Time.Fs;
            if 0
                Y = fft(Channels.Data.Data-mean(Channels.Data.Data));
                Fs = Channels.Time.Fs;
                L = length(Channels.Data.Data);
                P2 = abs(Y/L);
                iC = floor(L/2);
                P1 = P2(1:iC+1);
                P1(2:end-1) = 2*P1(2:end-1);
                f = Fs*(0:(iC))/L;
                [~,k] = max(P1);
                if f(k) > 5
                    [~,k] = max(P1(1:k-1));
                end
                Span = 1/f(k)*5*Fs;
            end
            
    %% ------------------ Update Data Channels Function --------------
        function [Channels,err] = UpdateDataChannel(Channels,handles)
            data = get(handles.figure1,'userdata');
            err = false;
            if (~Channels.Data.No | Channels.Data.No > size(data,2))
                err = true;
                Channels.Data.Data = Channels.Data.Data*NaN;
                return
            end
            switch lower(Channels.Data.Type)
                case 'electrography'
                    if Channels.Data.Scale_factor
                        Fs = 1;
                        Scale_factor = Channels.Data.Scale_factor;
                    else
                        Fs = Channels.Time.Fs;
                        Scale_factor = 1;
                    end
%                   Channels.Data.Data = (data(:,Channels.Data.No)/Fs)*Scale_factor; Added Eugene 29.06.2020
                    Channels.Data.Data = (Channels.Data.Data/Fs)*Scale_factor;
                case {'data','interval'}
                    if Channels.Data.Scale_factor
                        Fs = 1;
                        Scale_factor = Channels.Data.Scale_factor;
                    else
                        Fs = Channels.Time.Fs;
                        Scale_factor = 1;
                    end
                      Channels.Data.Data = (data(:,Channels.Data.No)/Fs)*Scale_factor;
                case 'peak'
                    if Channels.Data.Scale_factor
                        Fs = 1;
                        Scale_factor = Channels.Data.Scale_factor;
                    else
                        Fs = Channels.Time.Fs;
                        Scale_factor = 1;
                    end
                    dData = diff((data(:,Channels.Data.No)));
                    Channels.Data.Data = (dData/Fs)*Scale_factor;
                case 'beating_rate'
                    Channels.Data.Data = 60./data(:,Channels.Data.No)*Channels.Data.Scale_factor;
                case 'oxygen_saturation'  
                case 'select'
                    Channels.Data.Data =data(:, Channels.Data.No);
                otherwise
            end
                 
    %% ------------------ Update Time Channel Function --------------
        function Channels = UpdateTimeChannel(Channels,handles)
            data = get(handles.figure1,'userdata');
                    
            switch lower(Channels.Data.Type)
                case 'electrography'
                    if sum((diff(data(:,1)))>0) < (length(data)-1)
                        Channels.Time.Data = ((1:length(data))*(1/Channels.Time.Fs))';
                    else
                        Channels.Time.Data = data(:,1)*Channels.Time.Scale_factor;
                    end
                case 'peak'
                    if Channels.Data.Scale_factor
                        Fs = 1;
                        %                         Scale_factor = Channels.Data.Scale_factor;
                        Scale_factor = Channels.Data.Scale_factor;
                    else
                        Fs = Channels.Time.Fs;
                        Scale_factor = 1;
                    end
                    Channels.Time.Data = (data((1:end-1),Channels.Data.No)/Fs)*Scale_factor';
                case 'interval'
                     if Channels.Data.Scale_factor
                        Fs = 1;
                        %                         Scale_factor = Channels.Data.Scale_factor;
                        Scale_factor = 1;
                    else
                        Fs = 1;
                        Scale_factor = 1;
                    end
                    Channels.Time.Data = ((cumsum(Channels.Data.Data)/Fs)*Scale_factor)';
                case 'beating_rate'
                    Fs = 1;
                    Scale_factor = 1;
                    Channels.Time.Data = ((cumsum(Channels.Data.Data)/Fs)*Scale_factor)';
                case 'oxygen_saturation'    
                otherwise
            end
                 

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject)



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject)


% --- Executes on selection change in pm_data_type.
function pm_data_type_Callback(hObject, eventdata, handles)
% hObject    handle to pm_data_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_data_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_data_type

ENABLE = [{'on'};{'off'}];
Channels = getappdata(handles.figure1,'Channels');
Config = getappdata(handles.figure1,'Config');  
% Channels.Data.Type = Get_Popupmenu_Item_Text(hObject);
Channels.Data.Type = replace(Get_Popupmenu_Item_Text(hObject),' ','_');
if ~(get(hObject,'value')-1)
    set(handles.pm_data_unit,'string','select','value',1,'enable','off')
else
    set(handles.pm_data_unit,'string',['select';Config.data_type.(Channels.Data.Type)'],'enable','on','value',1)
%     Set_Popupmenu(handles.pm_data_unit, Channels.Data.Unit, cell2mat(ENABLE(Channels.Data.Enable+1)))
end
CheckStatus(handles.pm_data_unit, eventdata, handles);

%% --- added from pm_data_unit_Callback ----
if false
    Channels.Data.Scale_factor = ScaleFactor('data',Channels.Data.Unit);
    if IsPlotData(hObject, [], handles)
        [Channels,err] = UpdateDataChannel(Channels,handles);
        AlarmStatus(err,handles,'msg_2');
        Channels = UpdateTimeChannel(Channels,handles);
        PlotData(Channels,handles.axData)
    else
        cla(handles.axData)
    end
    
end
%% -----
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)





% --- Executes during object creation, after setting all properties.
function pm_data_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_data_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% ------ Check and Update Fs function --------------
    function Channels = Update_Fs(Channels,handles,enable,alarm)
        if nargin < 4
            alarm = 'msg_1';
        end
        switch Channels.Data.Type
            case 'electrography'
                if Channels.Time.Fs ~= int32(1/(mean(diff(Channels.Time.Data))))%*Channels.Time.Scale_factor)
                    if 1/(mean(diff(Channels.Time.Data))) < 1
                        Channels.Time.Data = Channels.Time.Data / 1000;
                    end
                    Channels.Time.Fs = int32(1/(mean(diff(Channels.Time.Data))));%*Channels.Time.Scale_factor);
                    set(handles.ebFs,'string', num2str(Channels.Time.Fs),'enable',enable)
                    err = true;
                else
                    err = false;
                 end
                AlarmStatus(err,handles,alarm)
            otherwise
        end

        
        
        
 %% -------- Alarm Function -------------
        function AlarmStatus(err,handles,alarm)
            Config = getappdata(handles.figure1,'Config');
            if err
                set(handles.txtAlarm,'string',Config.alarm.(alarm))
            else
                set(handles.txtAlarm,'string','')
            end
            
 


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over btnOK.
function btnOK_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to btnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function btnOK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
