%%
% Calculate overall SpO2 features.
%
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

function SpO2_OGM = OveralGeneralMeasures(data)

t0 = tic;
SpO2_OGM = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
    
    
    %     ZC_Baseline = mean of the signal
    %     Percentile = 0.01
    %     M_Threshold = 2
    %     DI_Window = 12
    %     func_args = zip_args({'ZC_Baseline', 'percentile', 'M_Threshold', 'DI_Window'}, [1, 0.01, 2, 12]);
    %     func_args = zip_args({'ZC_Baseline', 'percentile', 'M_Threshold', 'DI_Window'}, [1, 0.02, 3, 10]);
    func_args = zip_args([], []);
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    command = ['"' executable_file '" ' signal_file ' OveralGeneralMeasures ' func_args];
    %command = ['"' executable_file '" vector ' jsonencode(data) ' OveralGeneralMeasures ' func_args];
    
    %     tic
    result_measures = exec_pzpy(command);
    %     toc    
    
    if ~isempty(result_measures)
        SpO2_OGM.Properties.Description = 'Overall general measures';
        
        SpO2_OGM.AV = result_measures.AV;
        SpO2_OGM.Properties.VariableUnits{'AV'} = '%';
        SpO2_OGM.Properties.VariableDescriptions{'AV'} = 'SpO2 mean';
        
        SpO2_OGM.MED = result_measures.MED;
        SpO2_OGM.Properties.VariableUnits{'MED'} = '%';
        SpO2_OGM.Properties.VariableDescriptions{'MED'} = 'SpO2 median';
        
        SpO2_OGM.Min = result_measures.Min;
        SpO2_OGM.Properties.VariableUnits{'Min'} = '%';
        SpO2_OGM.Properties.VariableDescriptions{'Min'} = 'SpO2 min';
        
        SpO2_OGM.SD = result_measures.SD;
        SpO2_OGM.Properties.VariableUnits{'SD'} = '%';
        SpO2_OGM.Properties.VariableDescriptions{'SD'} = 'SpO2 standard deviation';
        
        SpO2_OGM.RG = result_measures.RG;
        SpO2_OGM.Properties.VariableUnits{'RG'} = '%';
        SpO2_OGM.Properties.VariableDescriptions{'RG'} = 'SpO2 range';
        
        SpO2_OGM.P = result_measures.P;
        SpO2_OGM.Properties.VariableUnits{'P'} = '%';
        SpO2_OGM.Properties.VariableDescriptions{'P'} = '0.01th percentile SpO2 value';
        
        SpO2_OGM.M = result_measures.M;
        SpO2_OGM.Properties.VariableUnits{'M'} = '%';
        SpO2_OGM.Properties.VariableDescriptions{'M'} = 'Percentage of the signal 2% below median oxygen saturation';
        
        SpO2_OGM.ZC = result_measures.ZC;
        SpO2_OGM.Properties.VariableUnits{'ZC'} = 'nu';
        SpO2_OGM.Properties.VariableDescriptions{'ZC'} = 'Number of zero-crossing points, using mean of the signal as baseline';
        
        SpO2_OGM.DI = result_measures.DI;
        SpO2_OGM.Properties.VariableUnits{'DI'} = 'nu';
        SpO2_OGM.Properties.VariableDescriptions{'DI'} = 'Delta index';
    else
        throw(MException('OveralGeneralMeasures:text', 'Can''t calculate overal general measures.'));
    end
end
%     disp(['OveralGeneralMeasures elapsed time: ', num2str(toc(t0))]);
end