function data = ImportDataFile(FileName)
fid = fopen(FileName);
i = 1;
while ~feof(fid)
    currentPos = ftell(fid);
    strLine = fgetl(fid);
    if strLine < 0;  break;  end                        % Break while loop if EOF
    if strfind(strLine,'---'); continue;end     % Check  and continue if "---" string detected
    chNo = length(sscanf(strLine,'%f',12));
    if chNo
        m = regexp(strLine, '[,\t;]', 'match');
        if ~isempty(m)
            lCh = length(m);
            strF = ['%f',cell2mat(m(1))];
        else
            lCh = 1;
            strF = '';
        end
        strFormat = [repmat(strF,1,lCh),'%f'];
        chNo = length(sscanf(strLine,strFormat));
        fseek(fid,currentPos,'bof');                  % Remove the file pointer to previous position @ strart data block
        data.data = fscanf(fid,strFormat,[chNo,Inf])';
    else
        data.textdata{i,1} = strLine;
        i = i + 1;
    end
end
fclose(fid);