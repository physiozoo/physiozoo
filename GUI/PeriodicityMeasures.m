%%
% Calculate PeriodicityMeasures SpO2 Features.
%
% Parameters:
% 	Signal: The SpO2 time series.
%	d_PRSA: Fragment duration of PRSA. Default value is 10.
% 	
% Returns:
% Pandas Dataframe containing the following features:
% 	PRSAc:  PRSA capacity.
% 	PRSAad: PRSA amplitude difference.
% 	PRSAos: PRSA overall slope.
%   PRSAsb: PRSA slope before the anchor point.
% 	PRSAsa: PRSA slope after the anchor point.
% 	AC:     Autocorrelation.

function SpO2_PM = PeriodicityMeasures(data)

t0 = tic;
SpO2_PM = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
        
    func_args = zip_args({'d_PRSA'}, 10);
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    command = ['"' executable_file '" file ' signal_file ' PeriodicityMeasures ' func_args];
    %     command = ['"' executable_file '" vector ' jsonencode(data) ' ComplexityMeasures ' func_args];
    
    tic
    result_measures = exec_pzpy(command);
    toc        
    
    if ~isempty(result_measures)
        SpO2_PM.Properties.Description = 'Periodicity measures';
        
        SpO2_PM.PRSAc = result_measures.PRSAc; 
        SpO2_PM.Properties.VariableUnits{'PRSAc'} = 'nu';
        SpO2_PM.Properties.VariableDescriptions{'PRSAc'} = 'PRSA capacity';
        
        SpO2_PM.PRSAad = result_measures.PRSAad;
        SpO2_PM.Properties.VariableUnits{'PRSAad'} = 'nu';
        SpO2_PM.Properties.VariableDescriptions{'PRSAad'} = 'PRSA amplitude difference';
        
        SpO2_PM.PRSAos = result_measures.PRSAos;
        SpO2_PM.Properties.VariableUnits{'PRSAos'} = 'nu';
        SpO2_PM.Properties.VariableDescriptions{'PRSAos'} = 'PRSA overall slope';
        
        SpO2_PM.PRSAsb = result_measures.PRSAsb;
        SpO2_PM.Properties.VariableUnits{'PRSAsb'} = 'nu';
        SpO2_PM.Properties.VariableDescriptions{'PRSAsb'} = 'PRSA slope before the anchor point';
        
        SpO2_PM.PRSAsa = result_measures.PRSAsa;
        SpO2_PM.Properties.VariableUnits{'PRSAsa'} = 'nu';
        SpO2_PM.Properties.VariableDescriptions{'PRSAsa'} = 'PRSA slope after the anchor point';
        
        SpO2_PM.AC = result_measures.AC;
        SpO2_PM.Properties.VariableUnits{'AC'} = 'nu';
        SpO2_PM.Properties.VariableDescriptions{'AC'} = 'Autocorrelation';
    else
        throw(MException('PeriodicityMeasures:text', 'Can''t calculate periodicity measures.'));
    end
    %     disp(['ComplexityMeasures elapsed time: ', num2str(toc(t0))]);
end