%%
% Calculate Hypoxic Burden SpO2 Features.
%
% Parameters:
% 	Signal: The SpO2 time series.
% 	Desaturations: Pandas Dataframe containing 2 columns, begin and end. Begin is the list of indices of beginning of each desaturation event, end is the indices of the end of those events. Typically, the dataframe returned by the API ODIMeasures can be entered here.
% 	CT_Threshold: Percentage of the time spent below the “CT_Threshold” % oxygen saturation level. Typically use CT90. Default value is 90.
% 	CA_Baseline: Baseline to compute the CA feature. (mean of the signal)
%
% Returns:
% Pandas Dataframe containing the following features:
% 	CA: Integral SpO2 below the baseline normalized by the total recording time
% 	CT: Percentage of the time spent below the threshold
% 	CDL: Cumulative duration of desaturations normalized by the total recording time
% 	CAmax: Cumulative area of desaturations using max value as baseline.
% 	CA100: Cumulative area of desaturations using 100% as baseline.

function SpO2_HBM = HypoxicBurdenMeasures(data, ODI_begin, ODI_end)

t0 = tic;
SpO2_HBM = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
    
    %   CT_Threshold = 90
    %   CA_Baseline
    %     func_args = zip_args({'end', 'begin', 'CT_Threshold'}, {ODI_end, ODI_begin, 90});
    func_args = zip_args({'end', 'begin'}, {ODI_end, ODI_begin});
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    command = ['"' executable_file '" file ' signal_file ' HypoxicBurdenMeasures ' func_args];
    %     command = ['"' executable_file '" vector ' jsonencode(data) ' HypoxicBurdenMeasures ' func_args];
    
    %     tic
    result_measures = exec_pzpy(command);
    %     toc
    
    if ~isempty(result_measures)
        SpO2_HBM.Properties.Description = 'Measures of the hypoxic burden';
        
        SpO2_HBM.CA = result_measures.CA;
        SpO2_HBM.Properties.VariableUnits{'CA'} = '%*sec';
        SpO2_HBM.Properties.VariableDescriptions{'CA'} = 'Integral SpO2 below the mean of the signal SpO2 level normalized by the total recording time';
        
        SpO2_HBM.CT = result_measures.CT;
        SpO2_HBM.Properties.VariableUnits{'CT'} = '%';
        SpO2_HBM.Properties.VariableDescriptions{'CT'} = 'Percentage of the time spent below the 90% oxygen saturation level';
        
        SpO2_HBM.CDL = result_measures.CDL;
        SpO2_HBM.Properties.VariableUnits{'CDL'} = 'sec';
        SpO2_HBM.Properties.VariableDescriptions{'CDL'} = 'Cumulative duration of desaturations normalized by the total recording time';
        
        SpO2_HBM.CAmax = result_measures.CAmax;
        SpO2_HBM.Properties.VariableUnits{'CAmax'} = '%*sec';
        SpO2_HBM.Properties.VariableDescriptions{'CAmax'} = 'Cumulative area of desaturations under max value as baseline and normalized by the total recording time';
        
        SpO2_HBM.CA100 = result_measures.CA100;
        SpO2_HBM.Properties.VariableUnits{'CA100'} = '%*sec';
        SpO2_HBM.Properties.VariableDescriptions{'CA100'} = 'Cumulative area of desaturations under the 100% SpO2 level as baseline and normalized by the total recording time';
    else
        throw(MException('HypoxicBurdenMeasures:text', 'Can''t calculate hypoxic burden measures.'));
    end
    %     disp(['HypoxicBurdenMeasures elapsed time: ', num2str(toc(t0))]);
end