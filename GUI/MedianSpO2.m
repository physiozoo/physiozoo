%%
% Apply a median filter to smooth the SpO2 signal.
% 
% Parameters:
% 	Signal: The SpO2 time series.
% 	FilterLength: The length of the filter.
% Returns: 
% 	The processed signal.

function signal = MedianSpO2(data)

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
    
    func_args = zip_args({'FilterLength'}, 9); % the length must be odd number
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    command = ['"' executable_file '" file ' signal_file ' MedianSpO2 ' func_args];    
    %     command = ['"' executable_file '" vector ' jsonencode(data) ' MedianSpO2 ' func_args];
    
    tic
    signal = exec_pzpy(command);
    toc
end