function WriteHeaderYAML(data)
fid = fopen('tempYAML.yml','w');
for i = 1 : length(data.textdata)
    fprintf(fid,strip(cell2mat(data.textdata(i)),'right'));
    fprintf(fid,'\r\n');
end
fclose(fid);