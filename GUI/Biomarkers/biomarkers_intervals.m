%%

function pebm_intervals_stat = biomarkers_intervals(signal, Fs, fud_points, measures_cb_array)

pebm_intervals_stat = table;

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
        command = ['"' executable_file '" ' '"' signal_file '"'  ' "' fud_file  '"' ' biomarkers_intervals ' func_args];
        result_measures = exec_pzpy(command);
    else
        result_measures.Pwave_int = ' ';
        result_measures.PR_int = ' ';
        result_measures.PR_seg = ' ';
        result_measures.PR_int2 = ' ';
        result_measures.QRS_int = ' ';
        
        result_measures.QT_int = ' ';
        result_measures.Twave_int = ' ';
        result_measures.TP_seg = ' ';
        result_measures.RR_int = ' ';
        result_measures.QTc_b = ' ';
        
        result_measures.QTc_frid = ' ';
        result_measures.QTc_fra = ' ';
        result_measures.QTc_hod = ' ';
        
    end
end

if isempty(result_measures)
    result_measures.Pwave_int = NaN;
    result_measures.PR_int = NaN;
    result_measures.PR_seg = NaN;
    result_measures.PR_int2 = NaN;
    result_measures.QRS_int = NaN;
    
    result_measures.QT_int = NaN;
    result_measures.Twave_int = NaN;
    result_measures.TP_seg = NaN;
    result_measures.RR_int = NaN;
    result_measures.QTc_b = NaN;
    
    result_measures.QTc_frid = NaN;
    result_measures.QTc_fra = NaN;
    result_measures.QTc_hod = NaN;   
end

pebm_intervals_stat.Properties.Description = 'Fiducials Biomarkers Interval duration and segments';

pebm_intervals_stat.Properties.UserData = 6;

pebm_intervals_stat.Pwave_int = result_measures.Pwave_int;
pebm_intervals_stat.Properties.VariableUnits{'Pwave_int'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'Pwave_int'} = 'Time interval between P on and P off';

pebm_intervals_stat.PR_int = result_measures.PR_int;
pebm_intervals_stat.Properties.VariableUnits{'PR_int'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'PR_int'} = 'Time interval between the P on to the QRS on';

pebm_intervals_stat.PR_seg = result_measures.PR_seg;
pebm_intervals_stat.Properties.VariableUnits{'PR_seg'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'PR_seg'} = 'Time interval between the P off to the QRS on';

pebm_intervals_stat.PR_int2 = result_measures.PR_int2;
pebm_intervals_stat.Properties.VariableUnits{'PR_int2'} = 'ms'; 
pebm_intervals_stat.Properties.VariableDescriptions{'PR_int2'} = 'Time interval between P peak and R peak'; %  as defined by Mao et al1.

pebm_intervals_stat.QRS_int = result_measures.QRS_int;
pebm_intervals_stat.Properties.VariableUnits{'QRS_int'} = 'ms'; 
pebm_intervals_stat.Properties.VariableDescriptions{'QRS_int'} = 'Time interval between the QRS on to the QRS off';


pebm_intervals_stat.QT_int = result_measures.QT_int;
pebm_intervals_stat.Properties.VariableUnits{'QT_int'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'QT_int'} = 'Time interval between the QRS on to the T off';

pebm_intervals_stat.Twave_int = result_measures.Twave_int;
pebm_intervals_stat.Properties.VariableUnits{'Twave_int'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'Twave_int'} = 'Time interval between T on and T off';

pebm_intervals_stat.TP_seg = result_measures.TP_seg;
pebm_intervals_stat.Properties.VariableUnits{'TP_seg'} = 'ms'; 
pebm_intervals_stat.Properties.VariableDescriptions{'TP_seg'} = 'Time interval between T off and P on';

pebm_intervals_stat.RR_int = result_measures.RR_int;
pebm_intervals_stat.Properties.VariableUnits{'RR_int'} = 'ms'; 
pebm_intervals_stat.Properties.VariableDescriptions{'RR_int'} = 'Time interval between sequential R peaks.';

pebm_intervals_stat.QTc_b = result_measures.QTc_b;
pebm_intervals_stat.Properties.VariableUnits{'QTc_b'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'QTc_b'} = 'Corrected QT interval (QTc) using Bazett’s formula';


pebm_intervals_stat.QTc_frid = result_measures.QTc_frid;
pebm_intervals_stat.Properties.VariableUnits{'QTc_frid'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'QTc_frid'} = 'QTc using the Fridericia formula';

pebm_intervals_stat.QTc_fra = result_measures.QTc_fra;
pebm_intervals_stat.Properties.VariableUnits{'QTc_fra'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'QTc_fra'} = 'QTc using the Framingham formula';

pebm_intervals_stat.QTc_hod = result_measures.QTc_hod;
pebm_intervals_stat.Properties.VariableUnits{'QTc_hod'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'QTc_hod'} = 'QTc using the Hodges formula';
