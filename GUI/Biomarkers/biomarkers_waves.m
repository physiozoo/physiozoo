%%

function pebm_waves_stat = biomarkers_waves(signal_file, Fs, fud_file, measures_cb_array)

pebm_waves_stat= table;

exe_file_path = fileparts(fileparts(mfilename('fullpath')));
executable_file = [exe_file_path filesep 'pebm' filesep 'pebm_compiled.exe'];

result_measures = [];

if exist(executable_file, 'file')
    
    func_args = zip_args({'fs'}, {Fs});
    
    %     signal_file = [tempdir 'temp.dat'];
    %     dlmwrite(signal_file, signal, '\n');
    %
    %     fud_file = [tempdir 'fud_temp.mat'];
    %     save(fud_file, 'fud_points');
    
    if measures_cb_array
        command = ['"' executable_file '" ' '"' signal_file '"'  ' "' fud_file  '"' ' biomarkers_waves ' func_args];
        result_measures = exec_pzpy(command);
    else
        result_measures.Pwave = ' ';
        result_measures.Twave = ' ';
        result_measures.Rwave = ' ';
        result_measures.Pwave_area = ' ';
        result_measures.Twave_area = ' ';
        
        result_measures.QRS_area = ' ';
        result_measures.ST_seg = ' ';
        result_measures.Jpoint = ' ';
    end
end

if isempty(result_measures)
    result_measures.Pwave_amp = NaN;
    result_measures.Twave_amp = NaN;
    result_measures.Rwave_amp = NaN;
    result_measures.Parea = NaN;
    result_measures.Tarea = NaN;
    
    result_measures.QRSarea = NaN;
    result_measures.STamp = NaN;
    result_measures.Jpoint = NaN;
end

pebm_waves_stat.Properties.Description = 'Fiducials Biomarkers Wave characteristics';

pebm_waves_stat.Properties.UserData = 6;

pebm_waves_stat.Pwave = result_measures.Pwave_amp;
pebm_waves_stat.Properties.VariableUnits{'Pwave'} = 'mV'; %'1e-4v';
pebm_waves_stat.Properties.VariableDescriptions{'Pwave'} = 'Amplitude difference between P peak and P off';

pebm_waves_stat.Twave = result_measures.Twave_amp;
pebm_waves_stat.Properties.VariableUnits{'Twave'} = 'mV'; %sprintf('10\x207B\x2074v');
pebm_waves_stat.Properties.VariableDescriptions{'Twave'} = 'Amplitude difference between T peak on and T off';

pebm_waves_stat.Rwave = result_measures.Rwave_amp;
pebm_waves_stat.Properties.VariableUnits{'Rwave'} = 'mV';
pebm_waves_stat.Properties.VariableDescriptions{'Rwave'} = 'R peak amplitude';

pebm_waves_stat.Pwave_area = result_measures.Parea;
pebm_waves_stat.Properties.VariableUnits{'Pwave_area'} = 'mV*ms'; %'1e-4v*ms';
pebm_waves_stat.Properties.VariableDescriptions{'Pwave_area'} = 'P wave interval area  defined as integral  between P-onset and P-offset';

pebm_waves_stat.Twave_area = result_measures.Tarea;
pebm_waves_stat.Properties.VariableUnits{'Twave_area'} = 'mV*ms';
pebm_waves_stat.Properties.VariableDescriptions{'Twave_area'} = 'T wave interval area   defined as integral between T-onset and T-offset';


pebm_waves_stat.QRS_area = result_measures.QRSarea;
pebm_waves_stat.Properties.VariableUnits{'QRS_area'} = 'mV*ms';
pebm_waves_stat.Properties.VariableDescriptions{'QRS_area'} = 'QRS interval area  defined as integral between Q-onset and S-offset';

pebm_waves_stat.ST_seg = result_measures.STamp;
pebm_waves_stat.Properties.VariableUnits{'ST_seg'} = 'mV';
pebm_waves_stat.Properties.VariableDescriptions{'ST_seg'} = 'Amplitude difference between S-offset and T-onset';

pebm_waves_stat.Jpoint = result_measures.Jpoint;
pebm_waves_stat.Properties.VariableUnits{'Jpoint'} = 'mV';
pebm_waves_stat.Properties.VariableDescriptions{'Jpoint'} = 'Amplitude 40ms after S-offset'; %  as defined by Hollander et al6

