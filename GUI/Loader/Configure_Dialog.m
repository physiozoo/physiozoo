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

% Last Modified by GUIDE v2.5 03-Jul-2018 13:53:30

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


%% -------------- Init Fs control ---------------------------------------
try
    eboxColor = 'w';
    eboxString = UniqueMap('Fs');
    enable = 'off';
catch
    eboxColor = [ 1.0000    0.8667    0.8667];
    eboxString = 1;
    enable = 'on';
end
set(handles.ebFs,'backgroundcolor',eboxColor,'string',eboxString,'enable',enable)
%% ----------- Init All popupmenu controls----------------

hCh = findobj(handles.figure1,'style','popupmenu');
set(hCh,'backgroundcolor',[ 1.0000    0.8667    0.8667],'value',1,'enable','on')

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
if isKey(UniqueMap,'Channels')
    rawChannels = UniqueMap('Channels');
else
    rawChannels = zeros(1,Data_Size);
end
if length(rawChannels) ~= Data_Size
     UniqueMap('MSG') = 'Channel Info problem';
    FGV_DATA(cmd.SET,UniqueMap);
     btnOK_Callback(hObject, eventdata, handles)
%     figure1_CloseRequestFcn(hObject, eventdata, handles)
    return
end

Channels.General.File_Type = 'ECG';
%% ---------------Get Channels Information -------------
Channels.Time.Enable = 0;
Channels.Time.No = 0;
Channels.Time.Scale_factor= 1;
Channels.Time.Fs = eboxString;
Channels.Time.Unit = 'second';
Channels.Time.Type = 'time';
Channels.Data.Enable = 0;
Channels.Data.No =  Data_Size;
Channels.Data.Scale_factor = 1;
Channels.Data.Data = data(:,Channels.Data.No);
Channels.Data.Unit = 'volt';
Channels.Data.Type = 'data';
for i = 1 : Data_Size
    Channels.Data.Names{i} = sprintf('Ch%02d',i);
end
strTimeChannels = (0:Data_Size);
set(handles.pmTime_Channel,'string',strTimeChannels)
if UniqueMap('IsHeader')
    for iCh = 1 : length(rawChannels)
        try
            localChannel = cell2mat(rawChannels(iCh));
            type = lower(localChannel.type);
            Channels.Data.Names{iCh} =localChannel.name;
            switch type
                case 'time'
                    type = 'Time';
                otherwise
                    type = 'Data';
            end
            if localChannel.enable
                Channels = Update_Channel_Info(Channels,iCh,localChannel,data,type);
            end
        catch
        end
    end
    if ~Channels.Time.No
        Channels.Time.Data = (1:length(data))*(1/Channels.Time.Fs)';
    end

    %% ------------------- Set Params Control ---------------------------------
    set(handles.pmTime_Channel,'value',Channels.Time.No+1,'backgroundcolor','w','enable',cell2mat(ENABLE(Channels.Time.Enable+1)))
    hFileParams =  findobj(handles.uipFile,'style','popupmenu');
    for iParameter = 1 : length(hFileParams)
        hObj = hFileParams((iParameter));
        pName = get(hObj,'tag');
        try
            strParamValue = strtrim(lower(UniqueMap(pName(3:end))));
        catch
            continue
        end
        Set_Popupmenu(hObj, strParamValue, 'off')
        Channels.General.(pName(3:end)) = strParamValue;
    end
    
    %% Set pm
    
    
    DataChannel_ChangeString(handles.pmData_Unit,Channels.General.File_Type)
    Set_Popupmenu(handles.pmTime_Unit, Channels.Time.Unit, cell2mat(ENABLE(Channels.Time.Enable+1)))
    Set_Popupmenu(handles.pmData_Unit, Channels.Data.Unit, cell2mat(ENABLE(Channels.Data.Enable+1)))
    Channels = UpdateDataChannel(Channels,handles);
    PlotData(Channels,handles.axData)
end

    set(handles.pmChannels_Name,'string',Channels.Data.Names','value',Channels.Data.No,'backgroundcolor','w','enable','on')



% UIWAIT makes Configure_Dialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);

setappdata(handles.figure1,'Channels',Channels)
assignin('base','handles',handles)
assignin('base','data',data)
assignin('base','Channels',Channels)

switch CheckStatus(handles.ebFs, eventdata, handles);
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

% --- Executes on selection change in pmIntegration_Level.
function pmIntegration_Level_Callback(hObject, eventdata, handles)
% hObject    handle to pmIntegration_Level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmIntegration_Level contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmIntegration_Level
Channels = getappdata(handles.figure1,'Channels');
Channels.General.Integration_Level = Get_Popupmenu_Item_Text(hObject);
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)

% --- Executes during object creation, after setting all properties.
function pmIntegration_Level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmIntegration_Level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pmData_Unit.
function pmData_Unit_Callback(hObject, eventdata, handles)
% hObject    handle to pmData_Unit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmData_Unit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmData_Unit

data = get(handles.figure1,'userdata');
Channels = getappdata(handles.figure1,'Channels');
Channels.Data.Unit = Get_Popupmenu_Item_Text(hObject);
Channels.Data.Scale_factor =  ScaleFactor('data',Channels.Data.Unit);
Channels = UpdateDataChannel(Channels,handles);
PlotData(Channels,handles.axData)
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)



% --- Executes during object creation, after setting all properties.
function pmData_Unit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmData_Unit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pmMammal.
function pmMammal_Callback(hObject, eventdata, handles)
% hObject    handle to pmMammal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmMammal contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmMammal
Channels = getappdata(handles.figure1,'Channels');
Channels.General.Mammal = Get_Popupmenu_Item_Text(hObject);
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)

% --- Executes during object creation, after setting all properties.
function pmMammal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmMammal (see GCBO)
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
    set(hObject,'string',Fs)
end
Channels = getappdata(handles.figure1,'Channels');
Channels.Time.Fs = Fs;
Channels = SetTimeChannel(handles.pmTime_Channel,Channels,data);
PlotData(Channels,handles.axData)
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


% --- Executes on selection change in pmFile_Type.
function pmFile_Type_Callback(hObject, eventdata, handles)
% hObject    handle to pmFile_Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmFile_Type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmFile_Type
Channels = getappdata(handles.figure1,'Channels');
Channels.General.File_Type = Get_Popupmenu_Item_Text(hObject);
DataChannel_ChangeString(handles.pmData_Unit,Channels.General.File_Type)
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)


% --- Executes during object creation, after setting all properties.
function pmFile_Type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmFile_Type (see GCBO)
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
if 0
    if Channels.Data.Enable
        Channels = UpdateDataChannel(Channels,handles);
    end
    if Channels.Time.Enable
        Channels.Time.Data = Channels.Time.Data*Channels.Time.Scale_factor;
    end
end
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
UniqueMap('MSG') = 'Canceled';
FGV_DATA(cmd.SET,UniqueMap);

my_closereq(handles.figure1)


% Check if disable
function Status = CheckStatus(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hCh = [findobj(handles.uipFile,'style','popupmenu');handles.pmData_Unit;handles.pmTime_Unit];
Status = 'off';
if prod([cell2mat(get(hCh,'value'))-1;str2double(get(handles.ebFs,'str'))>1])
    Status = 'on';
end
set(handles.btnOK,'enable',Status)
switch hObject
    case handles.ebFs
        status = str2double(get(handles.ebFs,'str'))==1;
     case {handles.pmTime_Channel,handles.pmChannels_Name}
         status = 0;
    otherwise
        status = ~(get(hObject,'value')-1);
end

if status
    set(hObject,'backgroundcolor',[ 1.0000    0.8667    0.8667])
else
    set(hObject,'backgroundcolor','white')
end


% --- Executes on selection change in pmChannels_Name.
function pmChannels_Name_Callback(hObject, eventdata, handles)
% hObject    handle to pmChannels_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmChannels_Name contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmChannels_Name
Channels = getappdata(handles.figure1,'Channels');
Channels.Data.No = get(hObject,'value');
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)


% --- Executes during object creation, after setting all properties.
function pmChannels_Name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmChannels_Name (see GCBO)
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





% --- Executes on selection change in pmTime_Channel.
function pmTime_Channel_Callback(hObject, eventdata, handles)
% hObject    handle to pmTime_Channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmTime_Channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmTime_Channel
Channels = getappdata(handles.figure1,'Channels');
data = get(handles.figure1,'userdata');
Channels.Time.No = Get_Popupmenu_Item_Text(hObject);
Channels = SetTimeChannel(handles.pmTime_Channel,Channels,data);
PlotData(Channels,handles.axData)
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)


% --- Executes during object creation, after setting all properties.
function pmTime_Channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmTime_Channel (see GCBO)
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
            case 'milisecond'
                scale_factor = 0.001;
            case 'second'
                scale_factor = 1;
            case 'datapoint'
                scale_factor = 1;
            otherwise
                scale_factor = 1;
        end
    case {'data','rr'}
        switch lower(unit)
            case 'milivolt'
                scale_factor = 1;
            case 'volt'
                scale_factor = 1000;
            case 'datapoint'
                scale_factor = 0;
            case 'milisecond'
                scale_factor = 0.001;
            case 'second'
                scale_factor = 1;
            otherwise
                scale_factor = 1;
        end
    case {'annotation'}
        switch lower(unit)
            case 'milivolt'
                scale_factor = 1;
            case 'volt'
                scale_factor = 1000;
            case 'datapoint'
                scale_factor = 0;
            case 'milisecond'
                scale_factor = 0.001;
            case 'second'
                scale_factor = 1;
            otherwise
                scale_factor = 1;
        end    
    otherwise
        scale_factor = 1;
end



function pmTime_Unit_Callback(hObject, eventdata, handles)
% hObject    handle to pmFile_Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmFile_Type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmFile_Type
data = get(handles.figure1,'userdata');
Channels = getappdata(handles.figure1,'Channels');
Channels.Time.Unit = Get_Popupmenu_Item_Text(hObject);
Channels.Time.Scale_factor =  ScaleFactor('time',Channels.Time.Unit);
Channels = UpdateDataChannel(Channels,handles);
PlotData(Channels,handles.axData)
CheckStatus(hObject, eventdata, handles);
setappdata(handles.figure1,'Channels',Channels)

% --- Executes during object creation, after setting all properties.
function pmTime_Unit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmFile_Type (see GCBO)
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
    if Lia
        set(hObject,'value',LocB,'backgroundcolor','w','enable',status)
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
timeUnits = [{'Select Units'};{'milisecond'};{'second'};{'minute'};{'datapoint'}];
signalUnits = [{'Select Units'};{'microvolt'};{'millivolt'};{'volt'};{'datapoint'}];
switch lower(File_Type)
    case 'peak'
        str = timeUnits;
    case 'electrography'
        str = signalUnits;
    otherwise
        str = timeUnits;
end
set(hObject,'string',str)


%% ------------------
function Channels = Update_Channel_Info(Channels,iCh,localChannel,data,type)
Channels.(type).No = iCh;
Channels.(type).Unit = lower(localChannel.unit);
Channels.(type).Scale_factor =  ScaleFactor(lower(type),Channels.(type).Unit);
Channels.(type).Data = data(:,iCh);
Channels.(type).Enable = 1;
Channels.(type).Type =  lower(localChannel.type);


%% ------------------------- Set Time Channel
function Channels = SetTimeChannel(hObject,Channels,data)
TimeChannel = int32(str2double(Get_Popupmenu_Item_Text(hObject)));
%     TimeChannel = get(hObject,'value');
if TimeChannel
    Channels.Time.Data = data(:,TimeChannel*Channels.Time.Scale_factor);
else
    Channels.Time.Data = ((1:length(data))*(1/(Channels.Time.Fs)))'*Channels.Time.Scale_factor;
end






  %% -----------------  Plot Data ------------------
    function PlotData(Channels,hAx)
    try
        iWc = int32(length(Channels.Data.Data)/2);
        Span =int32(length(Channels.Data.Data)/1000);
        if ~Span || Span < 10
            Span = iWc;
        end
        dataWindow = iWc-Span+1:iWc+Span-1;
        plot(hAx,Channels.Time.Data(dataWindow),Channels.Data.Data(dataWindow))
        zoom(hAx,'on')
    catch
    end
    
    
    
    
    %% ------------------ Update Data Channels Function --------------
        function Channels = UpdateDataChannel(Channels,handles)
            data = get(handles.figure1,'userdata');
            switch lower(Channels.Data.Type)
                case {'data','rr'}
                    Channels.Data.Data = data(:,Channels.Data.No)*Channels.Data.Scale_factor;
                case 'annotation'
                    if Channels.Time.Scale_factor
                        Channels.Time.Fs = 1;
                    end
                    dData = diff(double(data(:,Channels.Data.No)));
                    dData(end+1) = dData(end);
                    Channels.Data.Data = dData/Channels.Time.Fs;
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
