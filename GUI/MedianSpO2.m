%%
% Apply a median filter to smooth the SpO2 signal.
% 
% Parameters:
% 	Signal: The SpO2 time series.
% 	FilterLength: The length of the filter. Default value is 9.
% Returns: 
% 	The processed signal.

function signal = MedianSpO2(data, waitbar_handle)

t0 = tic;
exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
    
    waitbar(1 / 2, waitbar_handle, 'Writing data to the file', 'Name', 'SpO2 - Median');
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    FilterLength = mhrv.defaults.mhrv_get_default('filtSpO2.MedianSpO2.FilterLength', 'value');
    func_args = zip_args({'FilterLength'}, {FilterLength}); % the length must be odd number
    
    waitbar(2 / 2, waitbar_handle, 'Median', 'Name', 'SpO2 - Median');
        
    command = ['"' executable_file '" ' signal_file ' median_spo2 ' func_args];        
    
    signal = exec_pzpy(command);
    if isvalid(waitbar_handle); close(waitbar_handle); end
    disp(['SetRange elapsed time: ', num2str(toc(t0))]);   
end