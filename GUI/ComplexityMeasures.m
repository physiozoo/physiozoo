%%
% Calculate Complexity SpO2 Features.
% V1
% Parameters:
% 	Signal: The SpO2 time series.
% 	CTM_Threshold: Radius of Central Tendency Measure. Default value is 0.25.
%
% Returns:
% Pandas Dataframe containing the following features:
% 	ApEN: Approximate Entropy.
% 	LZ: Lempel-Ziv complexity.
% 	CTM: Central Tendency Measure.
% V2
% Parameters:
% - Signal: The SpO2 time series.
% - CTM_Threshold: Radius of Central Tendency Measure. Default value is 0.25.
% - DFA_Window: Length of window to calculate DFA biomarker. Default value is 20.
% - M_Sampen: Embedding dimension to compute SampEn.
% - R_Sampen: Tolerance to compute SampEn.
% Returns:
% Pandas Dataframe containing the following features:
% - ApEn: Approximate Entropy.
% - LZ: Lempel-Ziv complexity.
% - CTM: Central Tendency Measure.
% - SampEn: Sample Entropy.
% - DFA: Detrended Fluctuation Analysis.

function SpO2_CM = ComplexityMeasures(data, measures_cb_array)

SpO2_CM = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

result_measures = [];

if ~all(isnan(data)) && exist(executable_file, 'file')
        
    CTM_Threshold = mhrv.defaults.mhrv_get_default('ComplexityMeasures.CTM_Threshold', 'value');
    DFA_Window = mhrv.defaults.mhrv_get_default('ComplexityMeasures.DFA_Window', 'value');
    M_Sampen = mhrv.defaults.mhrv_get_default('ComplexityMeasures.M_Sampen', 'value');
    R_Sampen = mhrv.defaults.mhrv_get_default('ComplexityMeasures.R_Sampen', 'value');
    M_ApEn = mhrv.defaults.mhrv_get_default('ComplexityMeasures.M_ApEn', 'value');
    R_ApEn = mhrv.defaults.mhrv_get_default('ComplexityMeasures.R_ApEn', 'value');
    
    func_args = zip_args({'CTM_Threshold', 'DFA_Window', 'M_Sampen', 'R_Sampen', 'M_ApEn', 'R_ApEn'}, {CTM_Threshold, DFA_Window, M_Sampen, R_Sampen, M_ApEn, R_ApEn});
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
        
    if sum(measures_cb_array) == length(measures_cb_array)
        command = ['"' executable_file '" ' '"' signal_file '"' ' complexity ' func_args];
        result_measures = exec_pzpy(command);
    else
        result_measures.DFA = ' ';
        result_measures.LZ = ' ';
        result_measures.CTM = ' ';
        result_measures.SampEn = ' ';
        result_measures.ApEn = ' ';
        
        if measures_cb_array(1)
            command = ['"' executable_file '" ' '"' signal_file '"' ' comp_dfa ' func_args];
            result_measures.DFA = exec_pzpy(command);        
        end
        if measures_cb_array(2)
            command = ['"' executable_file '" ' '"' signal_file '"' ' comp_lz ' func_args];
            result_measures.LZ = exec_pzpy(command);
        end
        if measures_cb_array(3)
            command = ['"' executable_file '" ' '"' signal_file '"' ' comp_ctm ' func_args];
            result_measures.CTM = exec_pzpy(command);
        end
        if measures_cb_array(4)
            command = ['"' executable_file '" ' '"' signal_file '"' ' comp_sampen ' func_args];
            result_measures.SampEn = exec_pzpy(command);
        end
        if measures_cb_array(5)
            command = ['"' executable_file '" ' '"' signal_file '"' ' comp_apen ' func_args];
            result_measures.ApEn = exec_pzpy(command);
        end
    end
            
%     command = ['"' executable_file '" ' signal_file ' complexity ' func_args];
%     result_measures = exec_pzpy(command);
end

if isempty(result_measures)
    result_measures.DFA = NaN;
    result_measures.LZ = NaN;
    result_measures.CTM = NaN;
    result_measures.SampEn = NaN;
    result_measures.ApEn = NaN;
end

SpO2_CM.Properties.Description = 'Complexity measures';

SpO2_CM.DFA = result_measures.DFA; % ApEn
SpO2_CM.Properties.VariableUnits{'DFA'} = '%';
SpO2_CM.Properties.VariableDescriptions{'DFA'} = 'Detrended Fluctuation Analysis';

SpO2_CM.LZ = result_measures.LZ;
SpO2_CM.Properties.VariableUnits{'LZ'} = 'nu';
SpO2_CM.Properties.VariableDescriptions{'LZ'} = 'Lempel-Ziv complexity';

SpO2_CM.CTMxx = result_measures.CTM;
SpO2_CM.Properties.VariableUnits{'CTMxx'} = 'nu';
SpO2_CM.Properties.VariableDescriptions{'CTMxx'} = 'Central Tendency Measure with radius 0.25';

SpO2_CM.SampEn = result_measures.SampEn;
SpO2_CM.Properties.VariableUnits{'SampEn'} = 'nu';
SpO2_CM.Properties.VariableDescriptions{'SampEn'} = 'Sample Entropy';

SpO2_CM.ApEn = result_measures.ApEn;
SpO2_CM.Properties.VariableUnits{'ApEn'} = 'nu';
SpO2_CM.Properties.VariableDescriptions{'ApEn'} = 'Approximate Entropy';
