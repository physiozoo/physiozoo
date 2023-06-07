function UniqueMap = loadDataFile(FileName)
persistent P
persistent Ext
curDir = pwd;
cmd = FGV_CMD;
UniqueMap = containers.Map;
UniqueMap('MSG') = 'msg_7';
UniqueMap('IsHeader') = false;
%% ----- GET Filename if w/o input --------
if ~nargin
    [f,p] = uigetfile({'*.*', 'All files';...
        '*.mat','MAT-files (*.mat)'; ...
        '*.dat',  'WFDB Files (*.dat)'; ...
        '*.qrs; *.atr; *.rdt',  'WFDB Files (*.qrs; *.atr; *.rdt)';...
        '*.txt','Text Files (*.txt)'}, ...
        'Open Data-Quality-Annotations File',[P,'*',Ext]);
    if p
        P = p;
    else
        return
    end
    FileName = [P,f];
end
UniqueMap('MSG') = 'msg_5';
keySet = [];
valueSet=keySet;
%% ------ Check File extantion and load file --------
[file_path,name,ext] = fileparts(FileName);
waitbar_handle = waitbar(1/2, sprintf('Loading "%s" file',replace(name, '_', '\_')), 'Name', 'Working on it...');

%% ------------- Put Logo --------------------
warning('off');
javaFrame = get(waitbar_handle, 'JavaFrame');
javaFrame.setFigureIcon(javax.swing.ImageIcon([fileparts(fileparts(mfilename('fullpath'))) filesep 'Logo' filesep 'logoRed.png']));
warning('on');

Ext = ext;
UniqueMap('Name') = name;
UniqueMap('File_path') = file_path;
UniqueMap('Ext') = ext;
switch ext(2:end)
    case 'mat'
        header = load(FileName);
        if ~isfield(header,'Data')
            close(waitbar_handle);
            delete(waitbar_handle)
            return
        end
        data.data = header.Data;
        header = rmfield(header,'Data');
        if ~isempty(fieldnames(header))
            UniqueMap('IsHeader') = true;
        end
    case {'txt', 'csv', 'yml'}
        data = ImportDataFile(FileName);
        if ~isfield(data,'data')
            close(waitbar_handle);
            delete(waitbar_handle)
            
            return
        end
        if isfield(data,'textdata')
            tempPath = [tempdir 'tempYAML.yml'];
            WriteHeaderYAML(data,tempPath)                                                                                                              % Write header to text file with *.yml
            %             tempPath2 = [pwd filesep 'tempYAML.yml'];
            try
                header = ReadYaml(tempPath);                                                                                                            % Read from temporary file YAML format
            catch
                UniqueMap('MSG') = 'msg_4';
                close(waitbar_handle);
                delete(waitbar_handle)
                
                return
            end
            %            save('tempFile.mat','tempPath','tempPath2','header','data')
            
            UniqueMap('IsHeader') = true;
        end
        
    case {'dat', 'rdt'}  % WFDB ECG files
        FileName = [file_path,filesep,name];                                                                                                                       % build filename w/o ext, for WFDB
        try
            header_info = mhrv.wfdb.wfdb_header(FileName);                                                                                   % parse WFDB header file
        catch
            UniqueMap('MSG') = 'msg_9';
            close(waitbar_handle);
            delete(waitbar_handle)
            return
        end
        
        try
            if ~isfield(header_info.channel_info{1}, 'units')
                [UniqueMap,header,data] = Read_WFDB_DataFile(header_info,UniqueMap,waitbar_handle,FileName,ext);
            elseif ~strcmp(header_info.channel_info{1}.units, '%')
                [UniqueMap,header,data] = Read_WFDB_DataFile(header_info,UniqueMap,waitbar_handle,FileName,ext);
            elseif strcmp(header_info.channel_info{1}.units, '%')
                [UniqueMap,header,data] = Read_WFDB_SpO2File(header_info,UniqueMap,waitbar_handle,FileName,ext);
            end
        catch
            if isvalid(waitbar_handle)
                close(waitbar_handle);
                return;
            end
        end
        
    case {'qrs','atr'}  % WFDB annotation files
        FileName = [file_path,filesep,name];                                                                                                                       % build filename w/o ext, for WFDB
        try
            header_info = mhrv.wfdb.wfdb_header(FileName);                                                                                   % parse WFDB header file
        catch
            UniqueMap('MSG') = 'msg_9';
            close(waitbar_handle);
            delete(waitbar_handle)
            return
        end
        [UniqueMap, header,data] = Read_WFDB_AnnotationFile(header_info,UniqueMap,waitbar_handle,FileName,ext);
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
try
    keySet{end+1} = 'rawData';
    valueSet{end+1} = data.data;
    UniqueMap = [UniqueMap;containers.Map(keySet,valueSet)];
catch
    UniqueMap('MSG') = 'msg_11';
    close(waitbar_handle);
    delete(waitbar_handle)
    return
end

UniqueMap('MSG') = 'msg_6';
FGV_DATA(cmd.SET,UniqueMap);
cd(curDir)
close(waitbar_handle);
delete(waitbar_handle)
hDialog = Configure_Dialog;
%% ------ Wait OK btn press  -----------------------
if ishandle(hDialog)
    handles = guihandles(hDialog);
    waitfor(handles.btnOK,'value',1)
end
UniqueMap = FGV_DATA(cmd.GET);
end
