%%

function [pebm_waves_stat_total, pebm_waves_table_total] = biomarkers_waves(signal_file, Fs, fud_file, measures_cb_array)

% pebm_waves_stat = table;
% pebm_waves_table_1 = table;

exe_file_path = fileparts(fileparts(mfilename('fullpath')));
executable_file = [exe_file_path filesep 'pebm' filesep 'pebm_compiled.exe'];

% result_measures = [];
total_result_measures = [];

if exist(executable_file, 'file')
    
    func_args = zip_args({'fs'}, {Fs});
    
    %     signal_file = [tempdir 'temp.dat'];
    %     dlmwrite(signal_file, signal, '\n');
    %
    %     fud_file = [tempdir 'fud_temp.mat'];
    %     save(fud_file, 'fud_points');
    
    if measures_cb_array
        command = ['"' executable_file '" ' '"' signal_file '"'  ' "' fud_file  '"' ' biomarkers_waves ' func_args];
        total_result_measures = exec_pzpy(command);
    else
        total_result_measures.Pwave = ' ';
        total_result_measures.Twave = ' ';
        total_result_measures.Rwave = ' ';
        total_result_measures.Pwave_area = ' ';
        total_result_measures.Twave_area = ' ';
        
        total_result_measures.QRS_area = ' ';
        total_result_measures.ST_seg = ' ';
        total_result_measures.Jpoint = ' ';
    end
end

for i = 1 : length(fieldnames(total_result_measures))
    
    pebm_waves_stat = table;
    pebm_waves_table_1 = table;
    
    result_measures = total_result_measures.(['ch_', num2str(i)]);
    
    if isempty(result_measures)
        
        str_NaN.mean = NaN;
        str_NaN.median = NaN;
        str_NaN.min = NaN;
        str_NaN.max = NaN;
        str_NaN.iqr = NaN;
        str_NaN.std = NaN;
        
        result_measures.Pwave = str_NaN;
        result_measures.Twave = str_NaN;
        result_measures.Rwave = str_NaN;
        result_measures.Parea = str_NaN;
        result_measures.Tarea = str_NaN;
        
        result_measures.QRSarea = str_NaN;
        result_measures.STamp = str_NaN;
        result_measures.Jpoint = str_NaN;
    end
    
    pebm_waves_stat.Properties.Description = 'Fiducials Biomarkers Wave characteristics';
    
    pebm_waves_stat.Properties.UserData = 6;
    
    pebm_waves_stat.Pwave = result_measures.Pwave;
    pebm_waves_stat.Properties.VariableUnits{'Pwave'} = 'mV'; %'1e-4v';
    pebm_waves_stat.Properties.VariableDescriptions{'Pwave'} = 'Amplitude difference between P peak and P off';
    
    Pwave_table = struct2table(result_measures.Pwave);
    
    pebm_waves_stat.Twave = result_measures.Twave;
    pebm_waves_stat.Properties.VariableUnits{'Twave'} = 'mV'; %sprintf('10\x207B\x2074v');
    pebm_waves_stat.Properties.VariableDescriptions{'Twave'} = 'Amplitude difference between T peak on and T off';
    
    Twave_table = struct2table(result_measures.Twave);
    
    pebm_waves_stat.Rwave = result_measures.Rwave;
    pebm_waves_stat.Properties.VariableUnits{'Rwave'} = 'mV';
    pebm_waves_stat.Properties.VariableDescriptions{'Rwave'} = 'R peak amplitude';
    
    Rwave_table = struct2table(result_measures.Rwave);
    
    pebm_waves_stat.Pwave_area = result_measures.Parea;
    pebm_waves_stat.Properties.VariableUnits{'Pwave_area'} = 'mV*ms'; %'1e-4v*ms';
    pebm_waves_stat.Properties.VariableDescriptions{'Pwave_area'} = 'P wave interval area defined as integral between P-onset and P-offset';
    
    Pwave_area_table = struct2table(result_measures.Parea);
    
    pebm_waves_stat.Twave_area = result_measures.Tarea;
    pebm_waves_stat.Properties.VariableUnits{'Twave_area'} = 'mV*ms';
    pebm_waves_stat.Properties.VariableDescriptions{'Twave_area'} = 'T wave interval area defined as integral between T-onset and T-offset';
    
    Twave_area_table = struct2table(result_measures.Tarea);
    
    pebm_waves_stat.QRS_area = result_measures.QRSarea;
    pebm_waves_stat.Properties.VariableUnits{'QRS_area'} = 'mV*ms';
    pebm_waves_stat.Properties.VariableDescriptions{'QRS_area'} = 'QRS interval area defined as integral between Q-onset and S-offset';
    
    QRSarea_table = struct2table(result_measures.QRSarea);
    
    pebm_waves_stat.ST_seg = result_measures.STamp;
    pebm_waves_stat.Properties.VariableUnits{'ST_seg'} = 'mV';
    pebm_waves_stat.Properties.VariableDescriptions{'ST_seg'} = 'Amplitude difference between S-offset and T-onset';
    
    ST_seg_table = struct2table(result_measures.STamp);
    
    pebm_waves_stat.Jpoint = result_measures.Jpoint;
    pebm_waves_stat.Properties.VariableUnits{'Jpoint'} = 'mV';
    pebm_waves_stat.Properties.VariableDescriptions{'Jpoint'} = 'Amplitude 40ms after S-offset'; %  as defined by Hollander et al6
    
    Jpoint_table = struct2table(result_measures.Jpoint);
    
    table_descriptions = {'Amplitude difference between P peak and P off', 'Amplitude difference between T peak on and T off', ...
        'R peak amplitude', 'P wave interval area  defined as integral  between P-onset and P-offset'...
        'T wave interval area   defined as integral between T-onset and T-offset', 'QRS interval area defined as integral between Q-onset and S-offset',...
        'Amplitude difference between S-offset and T-onset', 'Amplitude 40ms after S-offset'};
    pebm_waves_table_1.Descriptions = table_descriptions';
    
    pebm_waves_table_2 = [Pwave_table; Twave_table; Rwave_table; Pwave_area_table; Twave_area_table; QRSarea_table; ST_seg_table; Jpoint_table];
    
    T = cell2table(arrayfun(@(x) sprintf('%.3f', x), pebm_waves_table_2.Variables, 'UniformOutput', false));
    
    T.Properties.VariableNames = pebm_waves_table_2.Properties.VariableNames;
    
    pebm_waves_table = [pebm_waves_table_1, T];
    
    pebm_waves_table.Properties.RowNames = {'Pwave (mV)', 'Twave (mV)', 'Rwave (mV)', 'Pwave_area (mV*ms)', 'Twave_area (mV*ms)', 'QRSarea (mV*ms)', 'ST_seg (mV)', 'Jpoint (mV)'};
    
    pebm_waves_table.Properties.DimensionNames = {'Fiducials Points', 'Data'};
    
    
    pebm_waves_stat_total{1, i} = pebm_waves_stat;
    pebm_waves_table_total{1, i} = pebm_waves_table;
    
end