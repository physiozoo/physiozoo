%%
% Calculate Hypoxic Burden SpO2 Features.
% V1
% Parameters:
% 	Signal: The SpO2 time series.
% 	Desaturations: Pandas Dataframe containing 2 columns, begin and end. Begin is the list of indices of beginning of each desaturation event, end is the indices of the end of those events. Typically, the dataframe returned by the API ODIMeasures can be entered here.
% 	CT_Threshold: Percentage of the time spent below the �CT_Threshold� % oxygen saturation level. Typically use CT90. Default value is 90.
% 	CA_Baseline: Baseline to compute the CA feature. (mean of the signal)
%
% Returns:
% Pandas Dataframe containing the following features:
% 	CA: Integral SpO2 below the baseline normalized by the total recording time
% 	CT: Percentage of the time spent below the threshold
% 	CDL: Cumulative duration of desaturations normalized by the total recording time
% 	CAmax: Cumulative area of desaturations using max value as baseline.
% 	CA100: Cumulative area of desaturations using 100% as baseline.
% V2
% Parameters:
% - signal: The SpO2 time series.
% - begin: list of indices of beginning of each desaturation event. Typically, the list returned by the API odi_measure can be entered here.
% - end is the indices of the end of those events. Typically, the list returned by the API odi_measure can be entered here.
% - CT_Threshold: Percentage of the time spent below the �ct_threshold� % oxygen saturation level. Typically use CT90. Default value is 90.
% - CA_Baseline: Baseline to compute the CA feature. Default value is mean of the signal.
% Returns:
% HypoxicBurdenMeasuresResults containing the following fields:
% - CA: Integral SpO2 below the baseline normalized by the total recording time
% - CT: Percentage of the time spent below the threshold
% - CDL: Cumulative duration of desaturations normalized by the total recording time
% - AODmax: Cumulative area of desaturations using max value as baseline.
% - AOD100: Cumulative area of desaturations using 100% as baseline.

function SpO2_HBM = HypoxicBurdenMeasures(data, ODI_begin, ODI_end, measures_cb_array)

SpO2_HBM = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

result_measures = [];

CT_Threshold = mhrv.defaults.mhrv_get_default('HypoxicBurdenMeasures.CT_Threshold', 'value');
CA_Baseline = mhrv.defaults.mhrv_get_default('HypoxicBurdenMeasures.CA_Baseline', 'value');
ODI_Threshold = mhrv.defaults.mhrv_get_default('ODIMeasures.ODI_Threshold', 'value');

if ~all(isnan(data)) && exist(executable_file, 'file')
    
    func_args = zip_args({'end', 'begin', 'CT_Threshold', 'CA_Baseline'}, {ODI_end, ODI_begin, CT_Threshold, CA_Baseline});
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    if measures_cb_array
        command = ['"' executable_file '" ' '"' signal_file '"' ' hypoxic_burden ' func_args];
        result_measures = exec_pzpy(command);
    else
        result_measures.CA = ' ';
        result_measures.CT = ' ';
        result_measures.POD = ' ';
        result_measures.AODmax = ' ';
        result_measures.AOD100 = ' ';
    end
end

if isempty(result_measures)
    result_measures.CA = NaN;
    result_measures.CT = NaN;
    result_measures.POD = NaN;
    result_measures.AODmax = NaN;
    result_measures.AOD100 = NaN;
end

SpO2_HBM.Properties.Description = 'Measures of the hypoxic burden';

SpO2_HBM.CAxx = result_measures.CA;
SpO2_HBM.Properties.VariableUnits{'CAxx'} = '%*sec';
SpO2_HBM.Properties.VariableDescriptions{'CAxx'} = ['Integral of SpO2 below the ' num2str(floor(CA_Baseline)) ' SpO2 level normalized by the total recording time'];
SpO2_HBM.Properties.VariableNames{'CAxx'} = ['CA' num2str(floor(CA_Baseline))]; % change name to e.g. CA85

SpO2_HBM.CTxx = result_measures.CT;
SpO2_HBM.Properties.VariableUnits{'CTxx'} = '%';
SpO2_HBM.Properties.VariableDescriptions{'CTxx'} = ['Cumulative time below the ' num2str(floor(CT_Threshold)) '% oxygen saturation level']; %'Percentage of the time spent below the 90% oxygen saturation level';
SpO2_HBM.Properties.VariableNames{'CTxx'} = ['CT' num2str(floor(CT_Threshold))]; % change name to e.g. CT90

SpO2_HBM.PODxx = result_measures.POD; % CDL % POD
SpO2_HBM.Properties.VariableUnits{'PODxx'} = 'sec'; % CDL % POD
SpO2_HBM.Properties.VariableDescriptions{'PODxx'} = 'Time of oxygen desaturation event, normalized by the total recording time'; % CDL % POD
SpO2_HBM.Properties.VariableNames{'PODxx'} = ['POD' num2str(floor(ODI_Threshold))]; % change name to e.g. POD3

SpO2_HBM.AODmax = result_measures.AODmax; % CAmax
SpO2_HBM.Properties.VariableUnits{'AODmax'} = '%*sec'; % CAmax
SpO2_HBM.Properties.VariableDescriptions{'AODmax'} = 'The area under the oxygen desaturation event curve, using the maximum SpO2 value as baseline and normalized by the total recording time'; % CAmax  and normalized by the total recording time

SpO2_HBM.AOD100 = result_measures.AOD100;% CA100
SpO2_HBM.Properties.VariableUnits{'AOD100'} = '%*sec'; % CA100
SpO2_HBM.Properties.VariableDescriptions{'AOD100'} = 'Cumulative area of desaturations under the 100% SpO2 level as baseline and normalized by the total recording time'; % CA100 Cumulative area of desaturations under the 100% SpO2 level as baseline
