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

function [SpO2_DSM, ODI_begin, ODI_end] = DesaturationsMeasures(data, measures_cb_array)

SpO2_DSM = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

result_measures = [];

ODI_Threshold = mhrv.defaults.mhrv_get_default('ODIMeasures.ODI_Threshold', 'value');
Hard_Threshold = mhrv.defaults.mhrv_get_default('ODIMeasures.Hard_Threshold', 'value');
Relative = mhrv.defaults.mhrv_get_default('ODIMeasures.Relative', 'value');
Desat_Max_Length = mhrv.defaults.mhrv_get_default('ODIMeasures.Desat_Max_Length', 'value');

if ~all(isnan(data)) && exist(executable_file, 'file')
    
    if Relative
        rel = false;
    else
        rel = true;
    end
    
    func_args = zip_args({'ODI_Threshold', 'hard_threshold', 'relative', 'desat_max_length'}, {ODI_Threshold, Hard_Threshold, rel, Desat_Max_Length});
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    if measures_cb_array
        command = ['"' executable_file '" ' '"' signal_file '"' ' desaturation ' func_args];
        result_measures = exec_pzpy(command);
    else
        result_measures.ODI = ' ';
        result_measures.DL_u = ' ';
        result_measures.DL_sd = ' ';
        result_measures.DA100_u = ' ';
        result_measures.DA100_sd = ' ';
        
        result_measures.DAmax_u = ' ';
        result_measures.DAmax_sd = ' ';
        result_measures.DD100_u = ' ';
        result_measures.DD100_sd = ' ';
        result_measures.DDmax_u = ' ';
        
        result_measures.DDmax_sd = ' ';
        result_measures.DS_u = ' ';
        result_measures.DS_sd = ' ';
        result_measures.TD_u = ' ';
        result_measures.TD_sd = ' ';
        
        result_measures.begin = [];
        result_measures.end = [];
    end
end

if isempty(result_measures)
    result_measures.ODI = NaN;
    result_measures.DL_u = NaN;
    result_measures.DL_sd = NaN;
    result_measures.DA100_u = NaN;
    result_measures.DA100_sd = NaN;
    
    result_measures.DAmax_u = NaN;
    result_measures.DAmax_sd = NaN;
    result_measures.DD100_u = NaN;
    result_measures.DD100_sd = NaN;
    result_measures.DDmax_u = NaN;
    
    result_measures.DDmax_sd = NaN;
    result_measures.DS_u = NaN;
    result_measures.DS_sd = NaN;
    result_measures.TD_u = NaN;
    result_measures.TD_sd = NaN;
    
    result_measures.begin = [];
    result_measures.end = [];
end

SpO2_DSM.Properties.Description = 'Desaturations measures';

SpO2_DSM.ODIxx = result_measures.ODI;
SpO2_DSM.Properties.VariableUnits{'ODIxx'} = 'Event/h';
SpO2_DSM.Properties.VariableDescriptions{'ODIxx'} = 'The oxygen desaturation index';
SpO2_DSM.Properties.VariableNames{'ODIxx'} = ['ODI' num2str(floor(ODI_Threshold))]; % change name to e.g. ODI5

ODI_begin = result_measures.begin;
ODI_end = result_measures.end;

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
