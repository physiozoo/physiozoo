%%
    function [DATA, GUI] = calcFrequencyStatistics(DATA, GUI, waitbar_handle)
        
        if isfield(DATA, 'AnalysisParams')
            batch_window_start_time = DATA.AnalysisParams.segment_startTime;
            batch_window_length = DATA.AnalysisParams.activeWin_length;
            batch_overlap = DATA.AnalysisParams.segment_overlap/100;
            batch_win_num = DATA.AnalysisParams.winNum;
            
            hrv_fr_metrics_tables = cell(batch_win_num, 1);
            
            for i = 1 : batch_win_num
                
                t0 = cputime;
                
                try
                    nni_window = DATA.nni(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
                    
                    waitbar(2 / 3, waitbar_handle, ['Calculating frequency measures for window ' num2str(i)]);
                    % Freq domain metrics
                    fprintf('[win % d: %.3f] >> mhrv: Calculating frequency-domain metrics...\n', i, cputime-t0);
                    
                    if DATA.WinAverage
                        window_minutes = mhrv_get_default('hrv_freq.window_minutes');
                        [ hrv_fd, ~, ~, pd_freq ] = hrv_freq(nni_window, 'methods', {'welch','ar'}, 'power_methods', {'welch','ar'}, 'window_minutes', window_minutes.value);
                    else
                        [ hrv_fd, ~, ~, pd_freq ] = hrv_freq(nni_window, 'methods', {'welch','ar'}, 'power_methods', {'welch','ar'}, 'window_minutes', []);
                    end
                    
                    DATA.FrStat.PlotData{i} = pd_freq;
                    
                    %hrv_fd_lomb = hrv_fd(:, find(cellfun(@(x) ~isempty(regexpi(x, '_lomb')), hrv_fd.Properties.VariableNames)));
                    hrv_fd_ar = hrv_fd(:, find(cellfun(@(x) ~isempty(regexpi(x, '_ar')), hrv_fd.Properties.VariableNames)));
                    hrv_fd_welch = hrv_fd(:, find(cellfun(@(x) ~isempty(regexpi(x, 'welch')), hrv_fd.Properties.VariableNames)));
                    
                    %[fd_lombData, fd_LombRowsNames, fd_lombDescriptions] = table2cell_StatisticsParam(hrv_fd_lomb);
                    [fd_arData, fd_ArRowsNames, fd_ArDescriptions] = table2cell_StatisticsParam(hrv_fd_ar);
                    [fd_welchData, fd_WelchRowsNames, fd_WelchDescriptions] = table2cell_StatisticsParam(hrv_fd_welch);
                    fd_ArRowsNames_NO_GreekLetters = fd_ArRowsNames;
                    fd_WelchRowsNames_NO_GreekLetters = fd_WelchRowsNames;
                    
                    fd_ArRowsNames = fix_fr_prop_var_names(fd_ArRowsNames);
                    fd_WelchRowsNames = fix_fr_prop_var_names(fd_WelchRowsNames);
                    
                    if ~DATA.GroupsCalc
                        if i == DATA.active_window
                            GUI.FrequencyParametersTableRowName = strrep(fd_WelchRowsNames, 'WELCH', '');
                            GUI.FrequencyParametersTable.Data = [GUI.FrequencyParametersTableRowName fd_welchData fd_arData];
                            plot_frequency_statistics_results(DATA, GUI, i);
                        end
                    end
                catch e
                    DATA.frequencyStatPartRowNumber = 0;
                    close(waitbar_handle);
                    errordlg(['hrv_freq: ' e.message], 'Input Error');
                    rethrow(e);
                end
                
                curr_win_table = horzcat(hrv_fd_ar, hrv_fd_welch);
                curr_win_table.Properties.RowNames{1} = sprintf('W%d', i);
                
                hrv_fr_metrics_tables{i} = curr_win_table;
                
                if i == 1
                    DATA.FrStat.ArWindowsData.RowsNames = fd_ArRowsNames;
                    DATA.FrStat.WelchWindowsData.RowsNames = fd_WelchRowsNames;
                    
                    DATA.FrStat.ArWindowsData.RowsNames_NO_GreekLetters = fd_ArRowsNames_NO_GreekLetters;
                    DATA.FrStat.WelchWindowsData.RowsNames_NO_GreekLetters = fd_WelchRowsNames_NO_GreekLetters;
                    
                    DATA.FrStat.ArWindowsData.Data = [fd_ArDescriptions fd_arData];
                    DATA.FrStat.WelchWindowsData.Data = [fd_WelchDescriptions fd_welchData];
                else
                    DATA.FrStat.ArWindowsData.Data = [DATA.FrStat.ArWindowsData.Data fd_arData];
                    DATA.FrStat.WelchWindowsData.Data = [DATA.FrStat.WelchWindowsData.Data fd_welchData];
                end
                
                batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
            end
            if ~DATA.GroupsCalc
                [StatRowsNames, StatData] = setFrequencyMethodData(DATA);
                GUI = updateMainStatisticsTable(DATA.timeStatPartRowNumber, StatRowsNames, StatData, GUI);
                [rn, ~] = size(StatRowsNames);
                DATA.frequencyStatPartRowNumber = rn;
            end
            % Create full table
            DATA.FrStat.hrv_fr_metrics = vertcat(hrv_fr_metrics_tables{:});
            DATA.FrStat.hrv_fr_metrics.Properties.Description = sprintf('HRV frequency metrics for %s', DATA.DataFileName);
        end
    end