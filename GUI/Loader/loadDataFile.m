function UniqueMap = loadDataFile(FileName)
persistent P
persistent Ext
curDir = pwd;
cmd = FGV_CMD;
UniqueMap = containers.Map;
UniqueMap('MSG') = 'Canceled by User';
UniqueMap('IsHeader') = 0;
%% ----- GET Filename if w/o input --------
if ~nargin
%     [f,p] = uigetfile([P,'/*.txt']);
    [f,p] = uigetfile({'*.*', 'All files';...
            '*.mat','MAT-files (*.mat)'; ...
            '*.dat',  'WFDB Files (*.dat)'; ... 
            '*.qrs',  'WFDB Files (*.qrs)'; ... 
            '*.txt','Text Files (*.txt)'}, ...
            'Open Data-Quality-Annotations File',[P,'*',Ext]);
    if p
        P = p;
    else
        return
    end
    FileName = [P,f];
end
UniqueMap('MSG') = 'No data';
keySet = [];
valueSet=keySet;
%% ------ Check File extantion and load file --------
[~,~,ext] = fileparts(FileName);
Ext = ext;
switch ext(2:end)
    case 'mat'
        header = load(FileName);
        if ~isfield(header,'Data')
            return
        end
        data.data = header.Data;
        header = rmfield(header,'Data');
        if ~isempty(fieldnames(header))
            UniqueMap('IsHeader') = 1;
        end
    case {'txt', 'csv','yml'}
        data = ImportDataFile(FileName);
        if ~isfield(data,'data')
            return
        end
        if isfield(data,'textdata')
            WriteHeaderYAML(data)
            header = ReadYaml('tempYAML.yml');
            UniqueMap('IsHeader') = 1;
        end
    case 'dat'
    case 'qrs'
        
    otherwise
end
%% ------ if exist header prepare the container -------
if   UniqueMap('IsHeader') 
    KeysName = fieldnames(header);
    for iKey = 1 : length(KeysName)
        keySet{iKey} = cell2mat(KeysName(iKey));
        valueSet{iKey} = header.(cell2mat(keySet(iKey)));
        keySet{iKey} = lower(keySet{iKey});
    end
end
%% ------ Add raw data to container and call to Configure Dialog GUI -----------------
keySet{end+1} = 'rawData';
valueSet{end+1} = data.data;
UniqueMap = [UniqueMap;containers.Map(keySet,valueSet)];

UniqueMap('MSG') = 'OK';
FGV_DATA(cmd.SET,UniqueMap);
cd(curDir)
hDialog = Configure_Dialog;
%% ------ Wait OK btn press -----------------------
if ishandle(hDialog)
    handles = guihandles(hDialog);
    waitfor(handles.btnOK,'value',1)
end
UniqueMap = FGV_DATA(cmd.GET);
end
