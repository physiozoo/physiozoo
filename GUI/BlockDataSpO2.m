%%
% Apply a block data filter to the SpO2 signal.
% 
% Parameters:
% 	Signal: The SpO2 time series.
% 	Treshold: treshold parameter for block data filter. Default value is 50.
% Returns: 
% 	preprocessed signal.

function signal = BlockDataSpO2(data, waitbar_handle)

t0 = tic;
exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
    
    waitbar(1 / 2, waitbar_handle, 'Writing data to the file', 'Name', 'SpO2 - Block');
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    Treshold = mhrv.defaults.mhrv_get_default('filtSpO2.BlockSpO2.Treshold', 'value');
    func_args = zip_args({'treshold'}, {Treshold}); 
    
    waitbar(2 / 2, waitbar_handle, 'Block Data', 'Name', 'SpO2 - Block Data');
        
    command = ['"' executable_file '" ' signal_file ' block_data ' func_args];        
    
    signal = exec_pzpy(command);
    if isvalid(waitbar_handle); close(waitbar_handle); end
    disp(['BlockData elapsed time: ', num2str(toc(t0))]);   
end