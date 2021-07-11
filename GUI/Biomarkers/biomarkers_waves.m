%%

function pebm_waves_stat = biomarkers_waves(signal, Fs, fud_points, measures_cb_array)

pebm_waves_stat= table;

exe_file_path = fileparts(fileparts(mfilename('fullpath')));
executable_file = [exe_file_path filesep 'pebm' filesep 'pebm_compiled.exe'];

result_measures = [];

if ~all(isnan(signal)) && exist(executable_file, 'file')
       
%     func_args = zip_args({'fs', 'fiducials'}, {Fs, fud_points});
    func_args = zip_args({'fs'}, {Fs});
    
    signal_file = [tempdir 'temp.dat'];
    dlmwrite(signal_file, signal, '\n');
    
    fud_file = [tempdir 'fud_temp.mat'];
    save(fud_file, 'fud_points');
    
    if measures_cb_array        
        command = ['"' executable_file '" ' '"' signal_file '"'  ' "' fud_file  '"' ' biomarkers_waves ' func_args];
        result_measures = exec_pzpy(command);
    else
        result_measures.Pwave_amp = ' ';
        result_measures.Twave_amp = ' ';
        result_measures.Rwave_amp = ' ';
        result_measures.Parea = ' ';
        result_measures.Tarea = ' ';
        
        result_measures.QRSarea = ' ';
        result_measures.STamp = ' ';
        result_measures.J_point = ' ';                
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
    result_measures.J_point = NaN;     
end

pebm_waves_stat.Properties.Description = 'Fiducials Biomarkers Wave characteristics';

pebm_waves_stat.Properties.UserData = 6;

pebm_waves_stat.Pwave_amp = result_measures.Pwave_amp;
pebm_waves_stat.Properties.VariableUnits{'Pwave_amp'} = sprintf('10\x207B\x2074v'); %'1e-4v';
pebm_waves_stat.Properties.VariableDescriptions{'Pwave_amp'} = 'Amplitude difference between P peak and P off';

pebm_waves_stat.Twave_amp = result_measures.Twave_amp;
pebm_waves_stat.Properties.VariableUnits{'Twave_amp'} = sprintf('10\x207B\x2074v');
pebm_waves_stat.Properties.VariableDescriptions{'Twave_amp'} = 'Amplitude difference between T peak on and T off';

pebm_waves_stat.Rwave_amp = result_measures.Rwave_amp;
pebm_waves_stat.Properties.VariableUnits{'Rwave_amp'} = sprintf('10\x207B\x2074v');
pebm_waves_stat.Properties.VariableDescriptions{'Rwave_amp'} = 'R peak amplitude.';

pebm_waves_stat.Parea = result_measures.Parea;
pebm_waves_stat.Properties.VariableUnits{'Parea'} = sprintf('10\x207B\x2074v*ms'); %'1e-4v*ms'; 
pebm_waves_stat.Properties.VariableDescriptions{'Parea'} = 'P wave interval area defined as integral from the P on to the P off';

pebm_waves_stat.Tarea = result_measures.Tarea;
pebm_waves_stat.Properties.VariableUnits{'Tarea'} = sprintf('10\x207B\x2074v*ms'); 
pebm_waves_stat.Properties.VariableDescriptions{'Tarea'} = 'T wave interval area  defined as integral from the T on to the T off';


pebm_waves_stat.QRSarea = result_measures.QRSarea;
pebm_waves_stat.Properties.VariableUnits{'QRSarea'} = sprintf('10\x207B\x2074v*ms');
pebm_waves_stat.Properties.VariableDescriptions{'QRSarea'} = 'QRS interval area defined as integral from the QRS on to the QRS off';

pebm_waves_stat.STamp = result_measures.STamp;
pebm_waves_stat.Properties.VariableUnits{'STamp'} = sprintf('10\x207B\x2074v');
pebm_waves_stat.Properties.VariableDescriptions{'STamp'} = 'Amplitude difference between QRS off and T on';

pebm_waves_stat.Jpoint = result_measures.Jpoint;
pebm_waves_stat.Properties.VariableUnits{'Jpoint'} = sprintf('10\x207B\x2074v'); 
pebm_waves_stat.Properties.VariableDescriptions{'Jpoint'} = 'Amplitude in 40ms after QRS off'; %  as defined by Hollander et al6

