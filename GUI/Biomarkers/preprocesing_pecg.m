%%
function result = preprocesing_pecg(signal_file, Fs, pwl_freq, preproc_file_name, call_func)

result = [];
preproc_data = [];

% call_func = [1 1]; % BandPath filter + Notch filter
% call_func = [1 0]; % BandPath filter
% call_func = [0 1]; % Notch filter

exe_file_path = fileparts(fileparts(mfilename('fullpath')));
executable_file = [exe_file_path filesep 'prepr_pecg' filesep 'complided_preprocessing.exe'];

if exist(executable_file, 'file')
    func_args = zip_args({'fs', 'pwl_freq', 'call_func'}, {Fs, pwl_freq, call_func});
    command = ['"' executable_file '" ' '"' signal_file '"' ' "' preproc_file_name '" ' func_args];
    
    [res, out, error] = jsystem(command);
    if res ~= 0
        disp(['pzpy error: ', error, '\n', out]);
    elseif exist(preproc_file_name, 'file')
        data = load(preproc_file_name);        
        if ~isempty(data)
            fieldnames_data = fieldnames(data);
            for i = 1 : length(fieldnames(data))                
                preproc_data(:, end+1) = data.(fieldnames_data{i})';
            end
            result = preproc_data;
        end
    end
end