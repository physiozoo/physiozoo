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
[~,name,ext] = fileparts(FileName);
Ext = ext;
UniqueMap('Name') = name;
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
            WriteHeaderYAML(data)                                                                                                              % Write header to text file with *.yml
            header = ReadYaml('tempYAML.yml');                                                                                 % Read from temporary file YAML format
            UniqueMap('IsHeader') = 1;
        end
    case {'dat','qrs'}  % WFDB files
        FileName = [P,name];                                                                                                                       % build filename w/o ext, for WFDB
        header_info = wfdb_header(FileName);                                                                                   % parse WFDB header file 
       [ChannelNo,Fs,~] = get_signal_channel(FileName, 'header_info', header_info);   % get signal info from header, number of channels , frequency, number of samples
                if (isempty(ChannelNo))                                                                                                            % return if have no signals
                   return
                end
                Description = strsplit(header_info.channel_info{1}.description,'-');                     % get mammal and integration level from description
                header.Mammal = Description{2};
                header.Integration_level = Description{1};
                %% -----------  Read data from WFDB file ------------------------
                if strcmp(ext(2:end),'dat')
                    [tm, sig, Fs] = rdsamp(FileName, ChannelNo, 'header_info', header_info);
                    data.data = [tm,sig];
                    type = 'electrography';
                    unit = 'millivolt';
                else
                    sig = rdann(FileName, ext(2:end));
                    tm = [];
                    data.data = sig;
                    type = 'peak';
                    unit = 'index';
                end
                %% --------------------Build Channels Information for Loader ---------------------------------------------
                tCh = 0;
                if ~isempty(tm)
                    tCh = 1;
                    header.Channels{tCh}.type = 'time';
                    header.Channels{tCh}.unit = 'sec';
                    header.Channels{tCh}.enable = 'yes';
                    header.Channels{tCh}.name = 'time';
                end
                for iCh = 1+tCh : length(header_info.channel_info)+tCh
                    localChannel = header_info.channel_info{iCh-tCh};
                    header.Channels{iCh}.type = type;
                    if ~isempty(localChannel.units)
                        unit = localChannel.units;
                    end
                    header.Channels{iCh}.unit = unit;
                    header.Channels{iCh}.enable = 'yes';
                    header.Channels{iCh}.name = 'data';
                end
                UniqueMap('IsHeader') = 1;
                header.Fs = Fs;
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
