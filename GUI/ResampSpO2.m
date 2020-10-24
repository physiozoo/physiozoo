%%
% Resample the SpO2 signal to 1Hz
% Parameters:
% 	Signal: The SpO2 time series.
% 	Original_fs: The original frequency.
% Returns:
% 	The resampled signal.

function signal = ResampSpO2(data, Original_fs, waitbar_handle)

t0 = tic;
t2 = tic;
exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
    
%     Original_fs = mhrv.defaults.mhrv_get_default('filtSpO2.ResampSpO2.Original_fs', 'value');
    func_args = zip_args({'OriginalFreq'}, {Original_fs});
    
    waitbar(1 / 2, waitbar_handle, 'Writing data to the file', 'Name', 'SpO2');
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    disp(['ResampSpO2: write2file elapsed time: ', num2str(toc(t0))]);
    
    t1 = tic;
    waitbar(2 / 2, waitbar_handle, 'Resampling Signal', 'Name', 'SpO2');
    command = ['"' executable_file '" ' signal_file ' resamp_spo2 ' func_args];
    %     command = ['"' executable_file '" vector ' jsonencode(data) ' ResampSpO2 ' func_args];
        
    signal = exec_pzpy(command);
    if isvalid(waitbar_handle); close(waitbar_handle); end
    disp(['ResampSpO2: resampling elapsed time: ', num2str(toc(t1))]);  
    
    disp(['ResampSpO2: total elapsed time: ', num2str(toc(t2))]);  
    
    if isempty(signal)
        throw(MException('ResampSpO2:text', 'Can''t resample SpO2 signal'));
    end    
end