%%
% Remove abnormalities of SpO2 signal, i.e values greater than 100 or lower than 50.
% Parameters:
%	Signal: The SpO2 time series
% Returns:
%	The processed signal.

function signal = RemovalAbnormalities(data, waitbar_handle)

t0 = tic;
exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
    
    func_args = zip_args([], []);
    
    waitbar(1 / 2, waitbar_handle, 'Writing data to the file', 'Name', 'SpO2 - Remove Abnormalities');
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    waitbar(2 / 2, waitbar_handle, 'Remove Abnormalities', 'Name', 'SpO2 - Remove Abnormalities');
    command = ['"' executable_file '" ' signal_file ' set_range ' func_args];
    %  command = ['"' executable_file '" vector ' jsonencode(data) ' RemovalAbnormalities ' func_args];
    
    signal = exec_pzpy(command);
    if isvalid(waitbar_handle); close(waitbar_handle); end
    disp(['RemovalAbnormalities elapsed time: ', num2str(toc(t0))]);    
%     if isempty(signal)
%         throw(MException('RemovalAbnormalities:text', 'Can''t remove abnormalities'));
%     end
end