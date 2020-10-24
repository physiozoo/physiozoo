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

function SpO2_HBM = HypoxicBurdenMeasures(data, ODI_begin, ODI_end)

% t0 = tic;
SpO2_HBM = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

result_measures = [];

% if ~exist(executable_file, 'file')
%     error('Could not find the "pzpy.exe"');
% else
if ~all(isnan(data)) && exist(executable_file, 'file')
    
    CT_Threshold = mhrv.defaults.mhrv_get_default('HypoxicBurdenMeasures.CT_Threshold', 'value');
    CA_Baseline = mhrv.defaults.mhrv_get_default('HypoxicBurdenMeasures.CA_Baseline', 'value');
    
    func_args = zip_args({'end', 'begin', 'CT_Threshold', 'CA_Baseline'}, {ODI_end, ODI_begin, CT_Threshold, CA_Baseline});
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    command = ['"' executable_file '" ' signal_file ' hypoxic_burden ' func_args];
    %     command = ['"' executable_file '" vector ' jsonencode(data) ' HypoxicBurdenMeasures ' func_args];
    
%     tic
    result_measures = exec_pzpy(command);
%     toc
end

if isempty(result_measures)
    result_measures.CA = NaN;
    result_measures.CT = NaN;
    result_measures.POD = NaN;
    result_measures.AODmax = NaN;
    result_measures.AOD100 = NaN;
end

%     if ~isempty(result_measures) && isstruct(result_measures)
SpO2_HBM.Properties.Description = 'Measures of the hypoxic burden';

SpO2_HBM.CAxx = result_measures.CA;
SpO2_HBM.Properties.VariableUnits{'CAxx'} = '%*sec';
SpO2_HBM.Properties.VariableDescriptions{'CAxx'} = 'Integral of SpO2 below the xx SpO2 level normalized by the total recording time';

SpO2_HBM.CTxx = result_measures.CT;
SpO2_HBM.Properties.VariableUnits{'CTxx'} = '%';
SpO2_HBM.Properties.VariableDescriptions{'CTxx'} = 'Cumulative time below the xx% oxygen saturation level'; %'Percentage of the time spent below the 90% oxygen saturation level';

SpO2_HBM.PODxx = result_measures.POD; % CDL % POD
SpO2_HBM.Properties.VariableUnits{'PODxx'} = 'sec'; % CDL % POD
SpO2_HBM.Properties.VariableDescriptions{'PODxx'} = 'Time of oxygen desaturation event, normalized by the total recording time'; % CDL % POD

SpO2_HBM.AODmax = result_measures.AODmax; % CAmax
SpO2_HBM.Properties.VariableUnits{'AODmax'} = '%*sec'; % CAmax
SpO2_HBM.Properties.VariableDescriptions{'AODmax'} = 'The area under the oxygen desaturation event curve, using the maximum SpO2 value as baseline and normalized by the total recording time'; % CAmax  and normalized by the total recording time

SpO2_HBM.AOD100 = result_measures.AOD100;% CA100
SpO2_HBM.Properties.VariableUnits{'AOD100'} = '%*sec'; % CA100
SpO2_HBM.Properties.VariableDescriptions{'AOD100'} = 'Cumulative area of desaturations under the 100% SpO2 level as baseline and normalized by the total recording time'; % CA100 Cumulative area of desaturations under the 100% SpO2 level as baseline
%     else
%         throw(MException('HypoxicBurdenMeasures:text', 'Can''t calculate hypoxic burden measures.'));
%     end
%         disp(['HypoxicBurdenMeasures elapsed time: ', num2str(toc(t0))]);
% end