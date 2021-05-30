%%
% Calculate overall SpO2 features.
% V1
% Parameters:
% 	Signal: The SpO2 time series.
% 	ZC_Baseline: Baseline for calculating number of zero-crossing points. Typically use mean of the signal. Default value is mean of the signal.
% 	Percentile: Percentile to perform. For example, for percentile 1, the argument should be 0.01. Default value is 0.01
% 	M_Threshold: Percentage of the signal M_Threshold % below median oxygen saturation. Typically use M_1, M_2 or M_5. Default value is 2.
% 	DI_Window: Window to calculate DelTa Index. Default values is 12.
%
% Returns:
% Pandas Dataframe containing the following features:
% 	AV: Average of the signal.
% 	MED: Median of the signal.
% 	Min: Minimum value of the signal.
% 	SD: Std of the signal.
% 	RG: SpO2 range (difference between the max and min value).
% 	P: percentile.
% 	M: Percentage of the signal x% below median oxygen saturation.
% 	ZC: Number of zero-crossing points.
% 	DI: Delta Index.
% V2
% Parameters:
% - Signal: The SpO2 time series.
% - ZC_Baseline: Baseline for calculating number of zero-crossing points. Typically use mean of the signal. Default value is mean of the signal.
% - percentile: Percentile to perform. For example, for percentile 1, the argument should be 1. Default value is 1
% - M_Threshold: Percentage of the signal m_threshold % below median oxygen saturation. Typically use 1, 2 or 5. Default value is 2.
% - DI_Window: Window to calculate Delta Index. Default values is 12.
% Returns:
% OverallGeneralMeasuresResult class containing the following fields:
% - AV: Average of the signal.
% - MED: Median of the signal.
% - Min: Minimum value of the signal.
% - SD: Std of the signal.
% - RG: SpO2 range (difference between the max and min value).
% - P: percentile.
% - M: Percentage of the signal x% below median oxygen saturation.
% - ZC: Number of zero-crossing points.
% - DI: Delta Index.



function SpO2_OGM = OverallGeneralMeasures(data, measures_cb_array)

SpO2_OGM = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

result_measures = [];

ZC_Baseline = mhrv.defaults.mhrv_get_default('OveralGeneralMeasures.ZC_Baseline', 'value');
Percentile = mhrv.defaults.mhrv_get_default('OveralGeneralMeasures.Percentile', 'value');
M_Threshold = mhrv.defaults.mhrv_get_default('OveralGeneralMeasures.M_Threshold', 'value');
DI_Window = mhrv.defaults.mhrv_get_default('OveralGeneralMeasures.DI_Window', 'value');

if ~all(isnan(data)) && exist(executable_file, 'file')
    
    
    func_args = zip_args({'ZC_Baseline', 'percentile', 'M_Threshold', 'DI_Window'}, [ZC_Baseline, Percentile, M_Threshold, DI_Window]);
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    if measures_cb_array
        command = ['"' executable_file '" ' '"' signal_file '"' ' overall_general ' func_args];
        result_measures = exec_pzpy(command);
    else
        result_measures.AV = ' ';
        result_measures.MED = ' ';
        result_measures.Min = ' ';
        result_measures.SD = ' ';
        result_measures.RG = ' ';
        
        result_measures.P = ' ';
        result_measures.M = ' ';
        result_measures.ZC = ' ';
        result_measures.DI = ' ';
    end
end

if isempty(result_measures)
    result_measures.AV = NaN;
    result_measures.MED = NaN;
    result_measures.Min = NaN;
    result_measures.SD = NaN;
    result_measures.RG = NaN;
    
    result_measures.P = NaN;
    result_measures.M = NaN;
    result_measures.ZC = NaN;
    result_measures.DI = NaN;
end

SpO2_OGM.Properties.Description = 'Overall general measures';

SpO2_OGM.AV = result_measures.AV;
SpO2_OGM.Properties.VariableUnits{'AV'} = '%';
SpO2_OGM.Properties.VariableDescriptions{'AV'} = 'SpO2 mean'; % 'Average of the signal';

SpO2_OGM.MED = result_measures.MED;
SpO2_OGM.Properties.VariableUnits{'MED'} = '%';
SpO2_OGM.Properties.VariableDescriptions{'MED'} = 'SpO2 median'; % 'Median of the signal';

SpO2_OGM.Min = result_measures.Min;
SpO2_OGM.Properties.VariableUnits{'Min'} = '%';
SpO2_OGM.Properties.VariableDescriptions{'Min'} = 'SpO2 min'; % 'Minimum value of the signal';

SpO2_OGM.SD = result_measures.SD;
SpO2_OGM.Properties.VariableUnits{'SD'} = '%';
SpO2_OGM.Properties.VariableDescriptions{'SD'} = 'SpO2 standard deviation'; % 'Std of the signal'; %

SpO2_OGM.RG = result_measures.RG;
SpO2_OGM.Properties.VariableUnits{'RG'} = '%';
SpO2_OGM.Properties.VariableDescriptions{'RG'} = 'SpO2 range'; %'SpO2 range' (difference between the max and min value);


SpO2_OGM.Pxx = result_measures.P;
SpO2_OGM.Properties.VariableUnits{'Pxx'} = '%';
SpO2_OGM.Properties.VariableDescriptions{'Pxx'} = [num2str(floor(Percentile)) 'th percentile SpO2 value']; % xxth percentile SpO2 value, by default xx=1; 'Percentile'; %'0.01th percentile SpO2 value';
SpO2_OGM.Properties.VariableNames{'Pxx'} = ['P' num2str(floor(Percentile))]; % change name to e.g. P1

SpO2_OGM.Mx = result_measures.M;
SpO2_OGM.Properties.VariableUnits{'Mx'} = '%';
SpO2_OGM.Properties.VariableDescriptions{'Mx'} = ['Percentage of the signal ' num2str(floor(M_Threshold)) '% below median oxygen saturation']; %'Percentage of the signal 2% below median oxygen saturation';
SpO2_OGM.Properties.VariableNames{'Mx'} = ['M' num2str(floor(M_Threshold))]; % change name to e.g. M2

SpO2_OGM.ZCxx = result_measures.ZC;
SpO2_OGM.Properties.VariableUnits{'ZCxx'} = 'nu';
SpO2_OGM.Properties.VariableDescriptions{'ZCxx'} = ['Number of zero-crossing points at the ' num2str(floor(ZC_Baseline)) '% SpO2 level']; % by default xx=AV'; %'Number of zero-crossing points, using mean of the signal as baseline';
SpO2_OGM.Properties.VariableNames{'ZCxx'} = ['ZC' num2str(floor(ZC_Baseline))]; % change name to e.g. ZC85

SpO2_OGM.DIx = result_measures.DI;
SpO2_OGM.Properties.VariableUnits{'DIx'} = 'nu';
SpO2_OGM.Properties.VariableDescriptions{'DIx'} = 'Delta Index'; %'Delta index';
SpO2_OGM.Properties.VariableNames{'DIx'} = ['DI' num2str(floor(DI_Window))]; % change name to e.g. DI12
