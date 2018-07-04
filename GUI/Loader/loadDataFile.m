function UniqueMap = loadDataFile(FileName)
if ~nargin
    FileName = 'test.yml';
    FileName =  'testYML.yml';
    FileName =  'testDog.yml';
    %
end
cmd = FGV_CMD;
data = ImportDataFile(FileName);
UniqueMap = containers.Map;
UniqueMap('MSG') = 'No data';
UniqueMap('IsHeader') = 0;
if isempty(data.data)
    return
end
keySet = [];
valueSet=keySet;
if ~isempty(data.textdata)
    WriteHeaderYAML(data)
    header = ReadYaml('tempYAML.yml');
    KeysName = fieldnames(header);
    for iKey = 1 : length(KeysName)
        keySet{iKey} = cell2mat(KeysName(iKey));
        valueSet{iKey} = header.(cell2mat(keySet(iKey)));
    end
    UniqueMap('IsHeader') = 1;
end
keySet{end+1} = 'rawData';
valueSet{end+1} = data.data;
UniqueMap = [UniqueMap;containers.Map(keySet,valueSet)];
UniqueMap('MSG') = 'OK';
FGV_DATA(cmd.SET,UniqueMap);
hDialog = Configure_Dialog;
if ishandle(hDialog)
    handles = guihandles(hDialog);
    waitfor(handles.btnOK,'value',1)
end
UniqueMap = FGV_DATA(cmd.GET);
end
