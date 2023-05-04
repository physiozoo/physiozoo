%%
function result = exec_pzpy(command)

[res, out, error] = jsystem(command);

if res ~= 0
%     error('pzpy error: %s\n%s', error, out);

    disp(['pzpy error: ', error, '\n', out]);
%     h_e = errordlg(['pzpy error: ', error, '\n', out], 'Input Error'); setLogo(h_e, 'M2');
    result = [];
else    
        out = strrep(out, 'null', 'NaN');
        out = strrep(out, 'nan', 'NaN');
        out = strrep(out, '''', '"');
        result = jsondecode(out);    
end