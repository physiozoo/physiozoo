%%
function [pebm_intervals_stat_total, pebm_intervals_table_total] = biomarkers_intervals(signal_file, Fs, fud_file, measures_cb_array)

% pebm_intervals_stat = table;
% pebm_intervals_table_1 = table;

exe_file_path = fileparts(fileparts(mfilename('fullpath')));
executable_file = [exe_file_path filesep 'pebm' filesep 'pebm_compiled.exe'];

% result_measures = [];
total_result_measures = [];

if exist(executable_file, 'file') % ~all(isnan(signal)) &&
    
    func_args = zip_args({'fs'}, {Fs});
    
    %     signal_file = [tempdir 'temp.dat'];
    %     dlmwrite(signal_file, signal, '\n');
    %
    %     fud_file = [tempdir 'fud_temp.mat'];
    %     save(fud_file, 'fud_points');
    
    if measures_cb_array
        command = ['"' executable_file '" ' '"' signal_file '"'  ' "' fud_file  '"' ' biomarkers_intervals ' func_args];
        total_result_measures = exec_pzpy(command);
    else
        total_result_measures.Pwave_int = ' ';
        total_result_measures.PR_int = ' ';
        total_result_measures.PR_seg = ' ';
        total_result_measures.PR2_int = ' ';
        total_result_measures.QRS_int = ' ';
        
        total_result_measures.QT_int = ' ';
        total_result_measures.Twave_int = ' ';
        total_result_measures.TP_seg = ' ';
        total_result_measures.RR_int = ' ';
        total_result_measures.QTc_b = ' ';
        
        total_result_measures.QTcFri = ' ';
        total_result_measures.QTcF = ' ';
        total_result_measures.QTcH = ' ';
        total_result_measures.R_depolarization = ' ';
    end
end

for i = 1 : length(fieldnames(total_result_measures))
    
    pebm_intervals_stat = table;
    pebm_intervals_table_1 = table;
%     result_measures = [];
    
    result_measures = total_result_measures.(['ch_', num2str(i)]);
    
    if isempty(result_measures)
        
        str_NaN.mean = NaN;
        str_NaN.median = NaN;
        str_NaN.min = NaN;
        str_NaN.max = NaN;
        str_NaN.iqr = NaN;
        str_NaN.std = NaN;
        
        result_measures.Pwave_int = str_NaN;
        result_measures.PR_int = str_NaN;
        result_measures.PR_seg = str_NaN;
        result_measures.PR_int2 = str_NaN;
        result_measures.QRS_int = str_NaN;
        
        result_measures.QT_int = str_NaN;
        result_measures.Twave_int = str_NaN;
        result_measures.TP_seg = str_NaN;
        result_measures.RR_int = str_NaN;
        result_measures.QTc_b = str_NaN;
        
        result_measures.QTc_frid = str_NaN;
        result_measures.QTc_fra = str_NaN;
        result_measures.QTc_hod = str_NaN;
        result_measures.R_depolarization = str_NaN;
    end
    
    pebm_intervals_stat.Properties.Description = 'Fiducials Biomarkers Interval duration and segments';
    
    pebm_intervals_stat.Properties.UserData = 6;
    
    pebm_intervals_stat.Pwave_int = result_measures.Pwave_int;
    pebm_intervals_stat.Properties.VariableUnits{'Pwave_int'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'Pwave_int'} = 'Time interval between P-peak and P-offset';
    
    Pwave_int_table = struct2table(result_measures.Pwave_int);
    
    pebm_intervals_stat.PR_int = result_measures.PR_int;
    pebm_intervals_stat.Properties.VariableUnits{'PR_int'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'PR_int'} = 'Time interval between P-onset and Q-onset';
    
    PR_int_table = struct2table(result_measures.PR_int);
    
    pebm_intervals_stat.PR_seg = result_measures.PR_seg;
    pebm_intervals_stat.Properties.VariableUnits{'PR_seg'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'PR_seg'} = 'Time interval between P-offset and Q-onset';
    
    PR_seg_table = struct2table(result_measures.PR_seg);
    
    pebm_intervals_stat.PR2_int = result_measures.PR_int2;
    pebm_intervals_stat.Properties.VariableUnits{'PR2_int'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'PR2_int'} = 'Time interval between P-peak and R-peak'; %  as defined by Mao et al1.
    
    PR2_int_table = struct2table(result_measures.PR_int2);
    
    pebm_intervals_stat.QRS_int = result_measures.QRS_int;
    pebm_intervals_stat.Properties.VariableUnits{'QRS_int'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'QRS_int'} = 'Time interval between Q-onset and S-offset';
    
    QRS_int_table = struct2table(result_measures.QRS_int);
    
    
    
    pebm_intervals_stat.QT_int = result_measures.QT_int;
    pebm_intervals_stat.Properties.VariableUnits{'QT_int'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'QT_int'} = 'Time interval between Q-onset and T-offset';
    
    QT_int_table = struct2table(result_measures.QT_int);
    
    pebm_intervals_stat.Twave_int = result_measures.Twave_int;
    pebm_intervals_stat.Properties.VariableUnits{'Twave_int'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'Twave_int'} = 'Time interval between T-onset and T-offset';
    
    Twave_int_table = struct2table(result_measures.Twave_int);
    
    pebm_intervals_stat.TP_seg = result_measures.TP_seg;
    pebm_intervals_stat.Properties.VariableUnits{'TP_seg'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'TP_seg'} = 'Time interval between T-offset and P-onset';
    
    TP_seg_table = struct2table(result_measures.TP_seg);
    
    pebm_intervals_stat.RR_int = result_measures.RR_int;
    pebm_intervals_stat.Properties.VariableUnits{'RR_int'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'RR_int'} = 'Time interval between consecutive R peaks';
    
    RR_int_table = struct2table(result_measures.RR_int);
    
    pebm_intervals_stat.QTcB = result_measures.QTc_b;
    pebm_intervals_stat.Properties.VariableUnits{'QTcB'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'QTcB'} = 'Corrected QT interval (QTc) by Bazett';
    
    QTcB_table = struct2table(result_measures.QTc_b);
    
    
    pebm_intervals_stat.QTcFri = result_measures.QTc_frid;
    pebm_intervals_stat.Properties.VariableUnits{'QTcFri'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'QTcFri'} = 'QTc by  Fridericia';
    
    QTcFri_table = struct2table(result_measures.QTc_frid);
    
    pebm_intervals_stat.QTcF = result_measures.QTc_fra;
    pebm_intervals_stat.Properties.VariableUnits{'QTcF'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'QTcF'} = 'QTc by Framingham';
    
    QTcF_table = struct2table(result_measures.QTc_fra);
    
    pebm_intervals_stat.QTcH = result_measures.QTc_hod;
    pebm_intervals_stat.Properties.VariableUnits{'QTcH'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'QTcH'} = 'QTc by Hodges';
    
    QTcH_table = struct2table(result_measures.QTc_hod);
    
%     pebm_intervals_stat.R_depol = result_measures.R_depolarization;
    pebm_intervals_stat.R_depol = result_measures.R_dep;
    pebm_intervals_stat.Properties.VariableUnits{'R_depol'} = 'ms';
    pebm_intervals_stat.Properties.VariableDescriptions{'R_depol'} = 'Time interval between Q-onset and R-peak';
    
%     R_depol_table = struct2table(result_measures.R_depolarization);
    R_depol_table = struct2table(result_measures.R_dep);
    
    
    
    table_descriptions = {'Time interval between P-peak and P-offset',...
        'Time interval between P-onset and Q-onset',...
        'Time interval between P-offset and Q-onset',...
        'Time interval between P-peak and R-peak',...
        'Time interval between Q-onset and S-offset',...
        'Time interval between Q-onset and T-offset',...
        'Time interval between T-onset and T-offset',...
        'Time interval between T-offset and P-onset',...
        'Time interval between consecutive R peaks',...
        'Corrected QT interval (QTc) by Bazett',...
        'QTc by  Fridericia',...
        'QTc by Framingham',...
        'QTc by Hodges',...
        'Time interval between Q-onset and R-peak'};
    
    pebm_intervals_table_1.Descriptions = table_descriptions';
    pebm_intervals_table_2 = [Pwave_int_table; PR_int_table; PR_seg_table; PR2_int_table; QRS_int_table;...
        QT_int_table; Twave_int_table; TP_seg_table; RR_int_table; QTcB_table;...
        QTcFri_table; QTcF_table; QTcH_table; R_depol_table];
    
    T = cell2table(arrayfun(@(x) round(x), pebm_intervals_table_2.Variables, 'UniformOutput', false));
    
    T.Properties.VariableNames = pebm_intervals_table_2.Properties.VariableNames;
    
    pebm_intervals_table = [pebm_intervals_table_1, T];
    
    pebm_intervals_table.Properties.RowNames = {'Pwave_int (ms)', 'PR_int (ms)', 'PR_seg (ms)', 'PR2_int (ms)', 'QRS_int (ms)',...
        'QT_int (ms)', 'Twave_int (ms)', 'TP_seg (ms)', 'RR_int (ms)', 'QTcB (ms)',...
        'QTcFri (ms)', 'QTcF (ms)', 'QTcH (ms)', 'R_depol (ms)'};
    
    pebm_intervals_table.Properties.DimensionNames = {'Fiducials Points', 'Data'};
    
    
    pebm_intervals_stat_total{1, i} = pebm_intervals_stat;
    pebm_intervals_table_total{1, i} = pebm_intervals_table;
    
    
end