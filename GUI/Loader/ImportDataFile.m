function data = ImportDataFile(FileName)
fid = fopen(FileName);
flag = [];
i = 1;
data.textdata = [];
data.data = [];
while isempty(flag)
    currentPos = ftell(fid);
    strLine = fgetl(fid);
    if strLine < 0
        break
    end
    chNo = length(sscanf(strLine,'%f'));
    if chNo
        fseek(fid,currentPos,'bof');
        data.textdata = data.textdata';
        a = fscanf(fid,'%f');
        data.data = reshape(a,chNo,length(a)/chNo)';
        flag = 1;
    else
        data.textdata{i} = strLine;
        i = i + 1;
    end
end
fclose(fid);