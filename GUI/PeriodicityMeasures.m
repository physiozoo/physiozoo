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

function [SpO2_PM, pd_data] = PeriodicityMeasures(data)

% t0 = tic;
SpO2_PM = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

result_measures = [];
result_measures_2 = [];

if ~all(isnan(data)) && exist(executable_file, 'file')
    
    % if ~exist(executable_file, 'file')
    %     error('Could not find the "pzpy.exe"');
    % else
    PRSA_Window = mhrv.defaults.mhrv_get_default('PeriodicityMeasures.PRSA_Window', 'value');
    K_AC = mhrv.defaults.mhrv_get_default('PeriodicityMeasures.K_AC', 'value');
    
    func_args = zip_args({'PRSA_Window', 'K_AC'}, {PRSA_Window, K_AC});
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    command1 = ['"' executable_file '" ' signal_file ' prsa_periodicity ' func_args];
    
    tic
    result_measures = exec_pzpy(command1);
    toc
    
    command2 = ['"' executable_file '" ' signal_file ' psd_periodicity ' ];
    
%     tic
    result_measures_2 = exec_pzpy(command2);
%     toc
    
    pd_data.fft = comp_fft(data);
    pd_data.PRSA_window = calc_PRSA(data, 10);
else
    pd_data = [];
end

if isempty(result_measures)
    result_measures.PRSAc = NaN;
    result_measures.PRSAad = NaN;
    result_measures.PRSAos = NaN;
    result_measures.PRSAsb = NaN;
    result_measures.PRSAsa = NaN;
    result_measures.AC = NaN;
end

if isempty(result_measures_2)
    result_measures_2.PSD_total = NaN;
    result_measures_2.PSD_band = NaN;
    result_measures_2.PSD_ratio = NaN;
    result_measures_2.PSD_peak = NaN;
end

%     if ~isempty(result_measures)
SpO2_PM.Properties.Description = 'Periodicity measures';

SpO2_PM.PRSAc = result_measures.PRSAc;
SpO2_PM.Properties.VariableUnits{'PRSAc'} = '%';
SpO2_PM.Properties.VariableDescriptions{'PRSAc'} = 'PRSA capacity';

SpO2_PM.PRSAad = result_measures.PRSAad;
SpO2_PM.Properties.VariableUnits{'PRSAad'} = '%';
SpO2_PM.Properties.VariableDescriptions{'PRSAad'} = 'PRSA amplitude difference';

SpO2_PM.PRSAos = result_measures.PRSAos;
SpO2_PM.Properties.VariableUnits{'PRSAos'} = '%/sec';
SpO2_PM.Properties.VariableDescriptions{'PRSAos'} = 'PRSA overall slope';

SpO2_PM.PRSAsb = result_measures.PRSAsb;
SpO2_PM.Properties.VariableUnits{'PRSAsb'} = '%/sec';
SpO2_PM.Properties.VariableDescriptions{'PRSAsb'} = 'PRSA slope before the anchor point';

SpO2_PM.PRSAsa = result_measures.PRSAsa;
SpO2_PM.Properties.VariableUnits{'PRSAsa'} = '%/sec';
SpO2_PM.Properties.VariableDescriptions{'PRSAsa'} = 'PRSA slope after the anchor point';

SpO2_PM.AC = result_measures.AC;
SpO2_PM.Properties.VariableUnits{'AC'} = '%**2';
SpO2_PM.Properties.VariableDescriptions{'AC'} = 'Autocorrelation';
%     else
%         throw(MException('PeriodicityMeasures:text', 'Can''t calculate PRSA measures.'));
%     end
%     if ~isempty(result_measures)
SpO2_PM.PSD_total = result_measures_2.PSD_total;
SpO2_PM.Properties.VariableUnits{'PSD_total'} = '%';
SpO2_PM.Properties.VariableDescriptions{'PSD_total'} = 'The area enclosed in the FFT signal';

SpO2_PM.PSD_band = result_measures_2.PSD_band;
SpO2_PM.Properties.VariableUnits{'PSD_band'} = '%';
SpO2_PM.Properties.VariableDescriptions{'PSD_band'} = 'The area enclosed in the FFT signal, within the band 0.014−0.033 Hz';

SpO2_PM.PSD_ratio = result_measures_2.PSD_ratio;
SpO2_PM.Properties.VariableUnits{'PSD_ratio'} = 'nu';
SpO2_PM.Properties.VariableDescriptions{'PSD_ratio'} = 'Ratio of area enclosed in the FFT signal within the band 0.014−0.033 Hz, with respect to the total area';

SpO2_PM.PSD_peak = result_measures_2.PSD_peak;
SpO2_PM.Properties.VariableUnits{'PSD_peak'} = '%';
SpO2_PM.Properties.VariableDescriptions{'PSD_peak'} = 'Peak amplitude of the FFT signal within the band 0.014−0.033 Hz';
%     else
%         throw(MException('PeriodicityMeasures:text', 'Can''t calculate PSD measures.'));
%     end
%     disp(['PeriodicityMeasures elapsed time: ', num2str(toc(t0))]);




%     command = ['"' executable_file '" ' signal_file ' SpectralPlot '];
%     tic
%     result_measures = exec_pzpy(command);
%     toc
%     if ~isempty(result_measures)
%         pd_data.x = [0:0.01:0.05];
%         pd_data.y = [0:0.01:0.05]*10;
%     else
%         throw(MException('SpectralPlot:text', 'Can''t calculate Spectral Plot data.'));
%     end
% end