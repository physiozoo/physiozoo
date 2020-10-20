%%
% Calculate ODI (average number of desaturation events per hour).
%
% Parameters:
% 	Signal: The SpO2 time series.
% 	ODI_Threshold: Threshold to compute Oxygen Desaturation Index. Default values is 3.
% V1
% Returns:
% Pandas Dataframe containing the ODI. It is the average number of desaturation events per hour. A desaturation is defined as SpO2 drops by x% below the baseline.
% Pandas Dataframe containing:
% 	Begin: List of indices of beginning of each desaturation event.
% 	End: List of indices of end of each desaturation event.
% V2
% Returns:
% ODIMeasureResult class containing the following fields:
% - ODI. It is the average number of desaturation events per hour. A desaturation is defined as SpO2 drops by x% below the baseline.
% - begin: List of indices of beginning of each desaturation event.
% - end: List of indices of end of each desaturation event.

function [SpO2_ODI, ODI_begin, ODI_end] = ODIMeasure(data)

t0 = tic;
SpO2_ODI = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
    ODI_Threshold = mhrv.defaults.mhrv_get_default('ODIMeasures.ODI_Threshold', 'value');

    func_args = zip_args({'ODI_Threshold'}, {ODI_Threshold});
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    command = ['"' executable_file '" ' signal_file ' odi ' func_args];
    %     command = ['"' executable_file '" vector ' jsonencode(data) ' ODIMeasure ' func_args];
    
    %     tic
    result_measures = exec_pzpy(command);
    %     toc
    
    if ~isempty(result_measures)
        SpO2_ODI.Properties.Description = 'Desaturations measures - ODI';
        
        SpO2_ODI.ODIxx = result_measures.ODI;
        SpO2_ODI.Properties.VariableUnits{'ODIxx'} = 'Event/h';
        SpO2_ODI.Properties.VariableDescriptions{'ODIxx'} = 'The oxygen desaturation index';
        
        ODI_begin = result_measures.begin;
        ODI_end = result_measures.end;
    else
        throw(MException('ODIMeasure:text', 'Can''t calculate ODI measures.'));
    end
    disp(['ODIMeasure elapsed time: ', num2str(toc(t0))]);
end