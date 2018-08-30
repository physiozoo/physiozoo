%%
    function [DATA, GUI] = calcTimeStatistics(DATA, GUI, waitbar_handle)
        if isfield(DATA, 'AnalysisParams')
            batch_window_start_time = DATA.AnalysisParams.segment_startTime;
            batch_window_length = DATA.AnalysisParams.activeWin_length;
            batch_overlap = DATA.AnalysisParams.segment_overlap/100;
            batch_win_num = DATA.AnalysisParams.winNum;
            
            hrv_time_metrics_tables = cell(batch_win_num, 1);
            
            for i = 1 : batch_win_num
                t0 = cputime;
                
                try
                    nni_window = DATA.nni(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
                    
                    waitbar(1 / 3, waitbar_handle, ['Calculating time measures for window ' num2str(i)]);
                    % Time Domain metrics
                    fprintf('[win % d: %.3f] >> mhrv: Calculating time-domain metrics...\n', i, cputime-t0);
                    [hrv_td, pd_time] = hrv_time(nni_window);
                    % Heart rate fragmentation metrics
                    fprintf('[win % d: %.3f] >> mhrv: Calculating fragmentation metrics...\n', i, cputime-t0);
                    hrv_frag = hrv_fragmentation(nni_window);
                    
                    DATA.TimeStat.PlotData{i} = pd_time;
                    
                    [timeData, timeRowsNames, timeDescriptions] = table2cell_StatisticsParam(hrv_td);
                    [fragData, fragRowsNames, fragDescriptions] = table2cell_StatisticsParam(hrv_frag);
                    
                    if ~DATA.GroupsCalc
                        if i == DATA.active_window
                            
                            GUI.TimeParametersTableRowName = timeRowsNames;
                            GUI.TimeParametersTableData = [timeDescriptions timeData];
                            GUI.TimeParametersTable.Data = [timeRowsNames timeData];
                            
                            GUI.FragParametersTableRowName = fragRowsNames;
                            GUI.FragParametersTableData = [fragDescriptions fragData];
                            GUI.FragParametersTable.Data = [fragRowsNames fragData];
                            
                            GUI = updateTimeStatistics(GUI);
                            plot_time_statistics_results(DATA, GUI, i);
                        end
                    end
                catch e
                    DATA.timeStatPartRowNumber = 0;
                    close(waitbar_handle);
                    errordlg(['hrv_time: ' e.message], 'Input Error');
                    rethrow(e);
                end
                
                curr_win_table = horzcat(hrv_td, hrv_frag);
                curr_win_table.Properties.RowNames{1} = sprintf('W%d', i);
                
                hrv_time_metrics_tables{i} = curr_win_table;
                
                if i == 1
                    DATA.TimeStat.RowsNames = [timeRowsNames; fragRowsNames];
                    DATA.TimeStat.Data = [[timeDescriptions; fragDescriptions] [timeData; fragData]];
                else
                    DATA.TimeStat.Data = [DATA.TimeStat.Data [timeData; fragData]];
                end
                batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
            end
            if ~DATA.GroupsCalc
                GUI = updateMainStatisticsTable(0, DATA.TimeStat.RowsNames, DATA.TimeStat.Data, GUI);
                [rn, ~] = size(DATA.TimeStat.RowsNames);
                DATA.timeStatPartRowNumber = rn;
            end
            % Create full table
            DATA.TimeStat.hrv_time_metrics = vertcat(hrv_time_metrics_tables{:});
            DATA.TimeStat.hrv_time_metrics.Properties.Description = sprintf('HRV time metrics for %s', DATA.DataFileName);
        end
    end