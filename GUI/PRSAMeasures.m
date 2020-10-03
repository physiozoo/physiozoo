%%
% Calculate PRSA SpO2 Features.
% V2
% Parameters:
% - Signal: The SpO2 time series.
% - PRSA_Window: Fragment duration of PRSA.
% - K_AC: Number of values to shift when computing autocorrelation.
% Returns:
% PRSAResults class containing the following fields:
% - PRSAc: PRSA capacity.
% - PRSAad: PRSA amplitude difference.
% - PRSAos: PRSA overall slope.
% - PRSAsb: PRSA slope before the anchor point.
% - PRSAsa: PRSA slope after the anchor point.
% - AC: Autocorrelation.

% function SpO2_PRSA = PRSAMeasures(data, K_AC)
function SpO2_PRSA = PRSAMeasures(data)

t0 = tic;
SpO2_PRSA = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
        
%     func_args = zip_args({'PRSA_Window', 'K_AC'}, {9, K_AC});
    func_args = zip_args({'PRSA_Window'}, {9});
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    command = ['"' executable_file '" file ' signal_file ' PRSAMeasures ' func_args];
    %     command = ['"' executable_file '" vector ' jsonencode(data) ' PRSAMeasures ' func_args];
    
    tic
    result_measures = exec_pzpy(command);
    toc
        
    if ~isempty(result_measures)
        SpO2_PRSA.Properties.Description = 'PRSA measures';
        
        SpO2_PRSA.PRSAc = result_measures.PRSAc; 
        SpO2_PRSA.Properties.VariableUnits{'PRSAc'} = '%';
        SpO2_PRSA.Properties.VariableDescriptions{'PRSAc'} = 'PRSA capacity';
        
        SpO2_PRSA.PRSAad = result_measures.PRSAad;
        SpO2_PRSA.Properties.VariableUnits{'PRSAad'} = '%';
        SpO2_PRSA.Properties.VariableDescriptions{'PRSAad'} = 'PRSA amplitude difference';
        
        SpO2_PRSA.PRSAos = result_measures.PRSAos;
        SpO2_PRSA.Properties.VariableUnits{'PRSAos'} = '%/sec';
        SpO2_PRSA.Properties.VariableDescriptions{'PRSAos'} = 'PRSA overall slope';
        
        SpO2_PRSA.PRSAsb = result_measures.PRSAsb;
        SpO2_PRSA.Properties.VariableUnits{'PRSAsb'} = '%/sec';
        SpO2_PRSA.Properties.VariableDescriptions{'PRSAsb'} = 'PRSA slope before the anchor point';
        
        SpO2_PRSA.PRSAsa = result_measures.PRSAsa;
        SpO2_PRSA.Properties.VariableUnits{'PRSAsa'} = '%/sec';
        SpO2_PRSA.Properties.VariableDescriptions{'PRSAsa'} = 'PRSA slope after the anchor point';
        
        SpO2_PRSA.AC = result_measures.AC;
        SpO2_PRSA.Properties.VariableUnits{'AC'} = '%**2';
        SpO2_PRSA.Properties.VariableDescriptions{'AC'} = 'Autocorrelation';
    else
        throw(MException('PRSAMeasures:text', 'Can''t calculate PRSA Measures.'));
    end
    %     disp(['PRSAMeasures elapsed time: ', num2str(toc(t0))]);
end