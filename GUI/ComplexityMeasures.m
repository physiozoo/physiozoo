%%
% Calculate Complexity SpO2 Features.
%
% Parameters:
% 	Signal: The SpO2 time series.
% 	CTM_Threshold: Radius of Central Tendency Measure. Default value is 0.25.
%
% Returns:
% Pandas Dataframe containing the following features:
% 	ApEN: Approximate Entropy.
% 	LZ: Lempel-Ziv complexity.
% 	CTM: Central Tendency Measure.

function SpO2_CM = ComplexityMeasures(data)

t0 = tic;
SpO2_CM = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
    
    %   CTM_Threshold = 0.25
    func_args = zip_args({'CTM_Threshold'}, 0.4);
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    command = ['"' executable_file '" file ' signal_file ' ComplexityMeasures ' func_args];
    %     command = ['"' executable_file '" vector ' jsonencode(data) ' ComplexityMeasures ' func_args];
    
    %     tic
    %     result_measures = exec_pzpy(command);
    %     toc
    
    result_measures.ApEn = NaN;
    result_measures.LZ = NaN;
    result_measures.CTM = NaN;
    
    if ~isempty(result_measures)
        SpO2_CM.Properties.Description = 'Complexity measures';
        
        SpO2_CM.ApEn = result_measures.ApEn;
        SpO2_CM.Properties.VariableUnits{'ApEn'} = 'nu';
        SpO2_CM.Properties.VariableDescriptions{'ApEn'} = 'Approximate entropy';
        
        SpO2_CM.LZ = result_measures.LZ;
        SpO2_CM.Properties.VariableUnits{'LZ'} = 'nu';
        SpO2_CM.Properties.VariableDescriptions{'LZ'} = 'Lempel-Ziv complexity';
        
        SpO2_CM.CTM = result_measures.CTM;
        SpO2_CM.Properties.VariableUnits{'CTM'} = 'nu';
        SpO2_CM.Properties.VariableDescriptions{'CTM'} = 'Central tendency measure with radius 0.25';
    else
        throw(MException('ComplexityMeasures:text', 'Can''t calculate complexity measures.'));
    end
    %     disp(['ComplexityMeasures elapsed time: ', num2str(toc(t0))]);
end