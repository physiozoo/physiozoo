function [mammal, intg] = get_description_from_wfdb_header(rec_name)
fheader = fopen([rec_name, '.hea']);
fgetl(fheader);
line = fgetl(fheader);
record_line = strsplit(line, ' ');
str = strsplit(record_line{end}, '-');
if length(str) >= 2
    intg = str{1};
    mammal = str{2};
else % not our description
    intg = '';
    mammal = '';
end
fclose(fheader);
