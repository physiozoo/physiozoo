%%
% Calculate Complexity PSD Features.
% 
% V2
% Parameters:
% - Signal: The SpO2 time series.
% 
% Returns:
% PSDResults class containing the following fields:
% - PSD_total: The area enclosed in the FFT signal.
% - PSD_band: The area enclosed in the FFT signal, within the band 0.014−0.033 𝐻𝑧.
% - PSD_ratio: Ratio of area enclosed in the FFT signal within the band 0.014−0.033 𝐻𝑧, with respect to the total area.
% - PSD_peak: Peak amplitude of the FFT signal within the band 0.014−0.033 𝐻𝑧.

function SpO2_PSD = PSDMeasures(data)

t0 = tic;
SpO2_PSD = table;

exe_file_path = fileparts(mfilename('fullpath'));
executable_file = [exe_file_path filesep 'SpO2' filesep 'pzpy.exe'];

if ~exist(executable_file, 'file')
    error('Could not find the "pzpy.exe"');
else
        
%     func_args = zip_args({'CTM_Threshold', 'DFA_Window', 'M_Sampen', 'R_Sampen'}, {0.4, 20, 1, 1});
    func_args = zip_args([], []);
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, data, '\n');
    
    command = ['"' executable_file '" file ' signal_file ' PSDMeasures ' func_args];
    %     command = ['"' executable_file '" vector ' jsonencode(data) ' ComplexityMeasures ' func_args];
    
    tic
    result_measures = exec_pzpy(command);
    toc
        
    if ~isempty(result_measures)
        SpO2_PSD.Properties.Description = 'PSD measures';
        
        SpO2_PSD.PSD_total = result_measures.PSD_total; % ApEn
        SpO2_PSD.Properties.VariableUnits{'PSD_total'} = '%';
        SpO2_PSD.Properties.VariableDescriptions{'PSD_total'} = 'The area enclosed in the FFT signal.';
        
        SpO2_PSD.PSD_band = result_measures.PSD_band;
        SpO2_PSD.Properties.VariableUnits{'PSD_band'} = '%';
        SpO2_PSD.Properties.VariableDescriptions{'PSD_band'} = 'The area enclosed in the FFT signal, within the band 0.014−0.033 𝐻𝑧';
        
        SpO2_PSD.PSD_ratio = result_measures.PSD_ratio;
        SpO2_PSD.Properties.VariableUnits{'PSD_ratio'} = 'nu';
        SpO2_PSD.Properties.VariableDescriptions{'PSD_ratio'} = 'Ratio of area enclosed in the FFT signal within the band 0.014−0.033 𝐻𝑧, with respect to the total area.';     
        
        SpO2_PSD.PSD_peak = result_measures.PSD_peak;
        SpO2_PSD.Properties.VariableUnits{'PSD_peak'} = '%';
        SpO2_PSD.Properties.VariableDescriptions{'PSD_peak'} = 'Peak amplitude of the FFT signal within the band 0.014−0.033 𝐻.';                
    else
        throw(MException('PSDMeasures:text', 'Can''t calculate PSD measures.'));
    end
    %     disp(['PSDMeasures elapsed time: ', num2str(toc(t0))]);
end