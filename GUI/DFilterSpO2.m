%%
% Apply Delta Filter to the SpO2 signal.
% 
% Parameters:
% 	Signal: The SpO2 time series.
% 	Diff – parameter of the delta filter. Default value is 4.
% Returns: 
% 	The preprocessed signal.

function signal = DFilterSpO2(data, waitbar_handle)

t0 = tic;
exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
    
    waitbar(1 / 2, waitbar_handle, 'Writing data to the file', 'Name', 'SpO2 - DFilter');
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    Diff = mhrv.defaults.mhrv_get_default('filtSpO2.DFilterSpO2.Diff', 'value');
    func_args = zip_args({'Diff'}, {Diff}); 
    
    waitbar(2 / 2, waitbar_handle, 'DFilter', 'Name', 'SpO2 - DFilter');
        
    command = ['"' executable_file '" ' signal_file ' dfilter ' func_args];        
    
    signal = exec_pzpy(command);
    if isvalid(waitbar_handle); close(waitbar_handle); end
    disp(['DFilter elapsed time: ', num2str(toc(t0))]);   
end