%%
% Calculate Desaturations events-related features.
% V1
% Parameters:
% 	Signal: The SpO2 time series.
% 	Desaturations: Pandas Dataframe containing 2 columns, begin and end. Begin is the list of indices of beginning of each desaturation event, end is the indices of the end of those events. Typically, the dataframe returned by the API ODIMeasures can be entered here.
%
% Returns:
% Pandas Dataframe containing the following features:
% 	DL_u: Mean of desaturation length
% 	DL_sd: Standard deviation of desaturation length
% 	DSA100_u: Mean of desaturation area using 100% as baseline.
% 	DSA100_sd: Standard deviation of desaturation area using 100% as baseline
% 	DSAmax_u: Mean of desaturation area using max value as baseline.
% 	DSAmax_sd: Standard deviation of desaturation area using max value as baseline
% 	DD100_u: Mean of depth desaturation from 100%.
% 	DD100_sd: Standard deviation of depth desaturation from 100%.
% 	DDmax_u: Mean of depth desaturation from max value.
% 	DDmax_sd: Standard deviation of depth desaturation from max value.
% 	DS_u: Mean of the desaturation slope.
% 	DS_sd: Standard deviation of the desaturation slope.
% V2
% Parameters:
% - signal: The SpO2 time series.
% - begin: list of indices of beginning of each desaturation event. Typically, the list returned by the API odi_measure can be entered here.
% - end is the indices of the end of those events. Typically, the list returned by the API odi_measure can be entered here.
% Returns:
% ODIMeasureResult class containing the following fields:
% - DL_u: Mean of desaturation length
% - DL_sd: Standard deviation of desaturation length
% - DSA100_u: Mean of desaturation area using 100% as baseline.
% - DSA100_sd: Standard deviation of desaturation area using 100% as baseline
% - DSAmax_u: Mean of desaturation area using max value as baseline.
% - DSAmax_sd: Standard deviation of desaturation area using max value as baseline
% - DD100_u: Mean of depth desaturation from 100%.
% - DD100_sd: Standard deviation of depth desaturation from 100%.
% - DDmax_u: Mean of depth desaturation from max value.
% - DDmax_sd: Standard deviation of depth desaturation from max value.
% - DS_u: Mean of the desaturation slope.
% - DS_sd: Standard deviation of the desaturation slope.
% - TD_u: Mean of time between two consecutive desaturation events.
% - TD_sd: Standard deviation of time between 2 consecutive desaturation events.

function SpO2_DSM = DesaturationsMeasures(data, ODI_begin, ODI_end)

t0 = tic;
SpO2_DSM = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
    
    if length(ODI_end) == 1
        ODI_end = ones(1, 1)*ODI_end;
        ODI_begin = ones(1, 1)*ODI_begin;
    end
    
    func_args = zip_args({'end', 'begin'}, {ODI_end, ODI_begin});
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    command = ['"' executable_file '" file ' signal_file ' DesaturationsMeasures ' func_args];
    %     command = ['"' executable_file '" vector ' jsonencode(data) ' DesaturationsMeasures ' func_args];
    
    %     tic
    result_measures = exec_pzpy(command);
    %     toc
    
    if ~isempty(result_measures) && isstruct(result_measures)
        SpO2_DSM.Properties.Description = 'Desaturations measures';
        
        SpO2_DSM.DL_u = result_measures.DL_u;
        SpO2_DSM.Properties.VariableUnits{'DL_u'} = 'sec';
        SpO2_DSM.Properties.VariableDescriptions{'DL_u'} = 'Mean of desaturation length';
        
        SpO2_DSM.DL_sd = result_measures.DL_sd;
        SpO2_DSM.Properties.VariableUnits{'DL_sd'} = 'sec**2';
        SpO2_DSM.Properties.VariableDescriptions{'DL_sd'} = 'Standard deviation of desaturation length';
        
        SpO2_DSM.DA100_u = result_measures.DA100_u;
        SpO2_DSM.Properties.VariableUnits{'DA100_u'} = '%*sec'; %'%';
        SpO2_DSM.Properties.VariableDescriptions{'DA100_u'} = 'Mean of desaturation area under the 100% SpO2 level as baseline';
        
        SpO2_DSM.DA100_sd = result_measures.DA100_sd;
        SpO2_DSM.Properties.VariableUnits{'DA100_sd'} = '(%*sec)**2'; %'%';
        SpO2_DSM.Properties.VariableDescriptions{'DA100_sd'} = 'Standard deviation of desaturation area under the 100% SpO2 level as baseline';
        
        SpO2_DSM.DAmax_u = result_measures.DAmax_u;
        SpO2_DSM.Properties.VariableUnits{'DAmax_u'} = '%*sec';
        SpO2_DSM.Properties.VariableDescriptions{'DAmax_u'} = 'Mean of desaturation area';
        
        SpO2_DSM.DAmax_sd = result_measures.DAmax_sd;
        SpO2_DSM.Properties.VariableUnits{'DAmax_sd'} = '(%*sec)**2';
        SpO2_DSM.Properties.VariableDescriptions{'DAmax_sd'} = 'Standard deviation of desaturation area';
        
        SpO2_DSM.DD100_u = result_measures.DD100_u;
        SpO2_DSM.Properties.VariableUnits{'DD100_u'} = '%'; %'%*sec';
        SpO2_DSM.Properties.VariableDescriptions{'DD100_u'} = 'Mean of desaturations depth using 100% SpO2 level as baseline';
        
        SpO2_DSM.DD100_sd = result_measures.DD100_sd;
        SpO2_DSM.Properties.VariableUnits{'DD100_sd'} = '%**2'; %'(%*sec)**2';
        SpO2_DSM.Properties.VariableDescriptions{'DD100_sd'} = 'Standard deviation of desaturations depth using 100% SpO2 level as baseline';
        
        SpO2_DSM.DDmax_u = result_measures.DDmax_u;
        SpO2_DSM.Properties.VariableUnits{'DDmax_u'} = '%';
        SpO2_DSM.Properties.VariableDescriptions{'DDmax_u'} = 'Mean of desaturation depth';
        
        SpO2_DSM.DDmax_sd = result_measures.DDmax_sd;
        SpO2_DSM.Properties.VariableUnits{'DDmax_sd'} = '%**2';
        SpO2_DSM.Properties.VariableDescriptions{'DDmax_sd'} = 'Standard deviation of desaturations depth';
        
        SpO2_DSM.DS_u = result_measures.DS_u;
        SpO2_DSM.Properties.VariableUnits{'DS_u'} = '%/sec';
        SpO2_DSM.Properties.VariableDescriptions{'DS_u'} = 'Mean of the desaturation slope';
        
        SpO2_DSM.DS_sd = result_measures.DS_sd;
        SpO2_DSM.Properties.VariableUnits{'DS_sd'} = '(%/sec)**2';
        SpO2_DSM.Properties.VariableDescriptions{'DS_sd'} = 'Standard deviation of the desaturation slope';
        
        SpO2_DSM.TD_u = result_measures.TD_u;
        SpO2_DSM.Properties.VariableUnits{'TD_u'} = 'sec';
        SpO2_DSM.Properties.VariableDescriptions{'TD_u'} = 'Mean of time between two consecutive desaturation events';
        
        SpO2_DSM.TD_sd = result_measures.TD_sd;
        SpO2_DSM.Properties.VariableUnits{'TD_sd'} = 'sec**2';
        SpO2_DSM.Properties.VariableDescriptions{'TD_sd'} = 'Standard deviation of time between 2 consecutive desaturation events';
    else
        throw(MException('DesaturationsMeasures:text', 'Can''t calculate desaturations measures.'));
    end
    disp(['DesaturationsMeasures elapsed time: ', num2str(toc(t0))]);
end