%%

function pebm_intervals_stat = biomarkers_intervals(signal_file, Fs, fud_file, measures_cb_array)

pebm_intervals_stat = table;

exe_file_path = fileparts(fileparts(mfilename('fullpath')));
executable_file = [exe_file_path filesep 'pebm' filesep 'pebm_compiled.exe'];

result_measures = [];

if exist(executable_file, 'file') % ~all(isnan(signal)) &&
    
    func_args = zip_args({'fs'}, {Fs});
    
    %     signal_file = [tempdir 'temp.dat'];
    %     dlmwrite(signal_file, signal, '\n');
    %
    %     fud_file = [tempdir 'fud_temp.mat'];
    %     save(fud_file, 'fud_points');
    
    if measures_cb_array
        command = ['"' executable_file '" ' '"' signal_file '"'  ' "' fud_file  '"' ' biomarkers_intervals ' func_args];
        result_measures = exec_pzpy(command);
    else
        result_measures.Pwave_int = ' ';
        result_measures.PR_int = ' ';
        result_measures.PR_seg = ' ';
        result_measures.PR2_int = ' ';
        result_measures.QRS_int = ' ';
        
        result_measures.QT_int = ' ';
        result_measures.Twave_int = ' ';
        result_measures.TP_seg = ' ';
        result_measures.RR_int = ' ';
        result_measures.QTc_b = ' ';
        
        result_measures.QTcFri = ' ';
        result_measures.QTcF = ' ';
        result_measures.QTcH = ' ';
        result_measures.R_depolarization = ' ';
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
    result_measures.R_depolarization = NaN;
end

pebm_intervals_stat.Properties.Description = 'Fiducials Biomarkers Interval duration and segments';

pebm_intervals_stat.Properties.UserData = 6;

pebm_intervals_stat.Pwave_int = result_measures.Pwave_int;
pebm_intervals_stat.Properties.VariableUnits{'Pwave_int'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'Pwave_int'} = 'Time interval between P-peak and P-offset';

pebm_intervals_stat.PR_int = result_measures.PR_int;
pebm_intervals_stat.Properties.VariableUnits{'PR_int'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'PR_int'} = 'Time interval between P-onset and Q-onset';

pebm_intervals_stat.PR_seg = result_measures.PR_seg;
pebm_intervals_stat.Properties.VariableUnits{'PR_seg'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'PR_seg'} = 'Time interval between P-offset and Q-onset ';

pebm_intervals_stat.PR2_int = result_measures.PR_int2;
pebm_intervals_stat.Properties.VariableUnits{'PR2_int'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'PR2_int'} = 'Time interval between P-peak and R-peak'; %  as defined by Mao et al1.

pebm_intervals_stat.QRS_int = result_measures.QRS_int;
pebm_intervals_stat.Properties.VariableUnits{'QRS_int'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'QRS_int'} = 'Time interval between Q-onset and S-offset ';


pebm_intervals_stat.QT_int = result_measures.QT_int;
pebm_intervals_stat.Properties.VariableUnits{'QT_int'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'QT_int'} = 'Time interval between Q-onset and T-offset';

pebm_intervals_stat.Twave_int = result_measures.Twave_int;
pebm_intervals_stat.Properties.VariableUnits{'Twave_int'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'Twave_int'} = 'Time interval between T-onset and T-offset';

pebm_intervals_stat.TP_seg = result_measures.TP_seg;
pebm_intervals_stat.Properties.VariableUnits{'TP_seg'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'TP_seg'} = 'Time interval between T-offset and P-onset';

pebm_intervals_stat.RR_int = result_measures.RR_int;
pebm_intervals_stat.Properties.VariableUnits{'RR_int'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'RR_int'} = 'Time interval between consecutive R peaks ';

pebm_intervals_stat.QTcB = result_measures.QTc_b;
pebm_intervals_stat.Properties.VariableUnits{'QTcB'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'QTcB'} = 'Corrected QT interval (QTc) by Bazett';


pebm_intervals_stat.QTcFri = result_measures.QTc_frid;
pebm_intervals_stat.Properties.VariableUnits{'QTcFri'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'QTcFri'} = 'QTc by  Fridericia';

pebm_intervals_stat.QTcF = result_measures.QTc_fra;
pebm_intervals_stat.Properties.VariableUnits{'QTcF'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'QTcF'} = 'QTc by Framingham';

pebm_intervals_stat.QTcH = result_measures.QTc_hod;
pebm_intervals_stat.Properties.VariableUnits{'QTcH'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'QTcH'} = 'QTc by Hodges';

pebm_intervals_stat.R_depol = result_measures.R_depolarization;
pebm_intervals_stat.Properties.VariableUnits{'R_depol'} = 'ms';
pebm_intervals_stat.Properties.VariableDescriptions{'R_depol'} = 'Time interval between Q-onset and R-peak';
