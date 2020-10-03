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

function SpO2_CM = ComplexityMeasures(data)

t0 = tic;
SpO2_CM = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
    CTM_Threshold = mhrv.defaults.mhrv_get_default('ComplexityMeasures.CTM_Threshold', 'value');
    DFA_Window = mhrv.defaults.mhrv_get_default('ComplexityMeasures.DFA_Window', 'value');
    M_Sampen = mhrv.defaults.mhrv_get_default('ComplexityMeasures.M_Sampen', 'value');
    R_Sampen = mhrv.defaults.mhrv_get_default('ComplexityMeasures.R_Sampen', 'value');
    
    func_args = zip_args({'CTM_Threshold', 'DFA_Window', 'M_Sampen', 'R_Sampen'}, {CTM_Threshold, DFA_Window, M_Sampen, R_Sampen});
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    command = ['"' executable_file '" file ' signal_file ' ComplexityMeasures ' func_args];
    %     command = ['"' executable_file '" vector ' jsonencode(data) ' ComplexityMeasures ' func_args];
    
    tic
    result_measures = exec_pzpy(command);
    toc
        
    if ~isempty(result_measures)
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
        SpO2_CM.Properties.VariableDescriptions{'SampEn'} = 'Sample Entropy.';
        
        SpO2_CM.ApEn = result_measures.ApEn;
        SpO2_CM.Properties.VariableUnits{'ApEn'} = 'nu';
        SpO2_CM.Properties.VariableDescriptions{'ApEn'} = 'Approximate Entropy';
    else
        throw(MException('ComplexityMeasures:text', 'Can''t calculate complexity measures.'));
    end
    %     disp(['ComplexityMeasures elapsed time: ', num2str(toc(t0))]);
end