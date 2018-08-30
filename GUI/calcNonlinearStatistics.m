%%
    function [DATA, GUI] = calcNonlinearStatistics(DATA, GUI, waitbar_handle)
        
        batch_window_start_time = DATA.AnalysisParams.segment_startTime;
        batch_window_length = DATA.AnalysisParams.activeWin_length;
        batch_overlap = DATA.AnalysisParams.segment_overlap/100;
        batch_win_num = DATA.AnalysisParams.winNum;
        
        hrv_nonlin_metrics_tables = cell(batch_win_num, 1);
        
        for i = 1 : batch_win_num
            
            t0 = cputime;
            
            try
                nni_window = DATA.nni(DATA.tnn >= batch_window_start_time & DATA.tnn <= batch_window_start_time + batch_window_length);
                
                waitbar(3 / 3, waitbar_handle, ['Calculating nolinear measures for window ' num2str(i)]);
                fprintf('[win % d: %.3f] >> mhrv: Calculating nonlinear metrics...\n', i, cputime-t0);
                [hrv_nl, pd_nl] = hrv_nonlinear(nni_window);
                
                DATA.NonLinStat.PlotData{i} = pd_nl;
                
                [nonlinData, nonlinRowsNames, nonlinDescriptions] = table2cell_StatisticsParam(hrv_nl);
                nonlinRowsNames_NO_GreekLetters = nonlinRowsNames;
                
                nonlinRowsNames = cellfun(@(x) strrep(x, 'alpha1', sprintf('\x3b1\x2081')), nonlinRowsNames, 'UniformOutput', false);
                nonlinRowsNames = cellfun(@(x) strrep(x, 'alpha2', sprintf('\x3b1\x2082')), nonlinRowsNames, 'UniformOutput', false);
                nonlinRowsNames = cellfun(@(x) strrep(x, 'SD1', sprintf('SD\x2081')), nonlinRowsNames, 'UniformOutput', false);
                nonlinRowsNames = cellfun(@(x) strrep(x, 'SD2', sprintf('SD\x2082')), nonlinRowsNames, 'UniformOutput', false);
                
                if ~DATA.GroupsCalc
                    if i == DATA.active_window
                        GUI.NonLinearTableRowName = nonlinRowsNames;
                        GUI.NonLinearTableData = [nonlinDescriptions nonlinData];
                        GUI.NonLinearTable.Data = [nonlinRowsNames nonlinData];
                        
                        plot_nonlinear_statistics_results(DATA, GUI, i);
                    end
                end
            catch e
                close(waitbar_handle);
                errordlg(['hrv_nonlinear: ' e.message], 'Input Error');
                rethrow(e);
            end
            
            curr_win_table = hrv_nl;
            curr_win_table.Properties.RowNames{1} = sprintf('W%d', i);
            
            hrv_nonlin_metrics_tables{i} = curr_win_table;
            
            if i == 1
                DATA.NonLinStat.RowsNames = nonlinRowsNames;
                DATA.NonLinStat.RowsNames_NO_GreekLetters = nonlinRowsNames_NO_GreekLetters;
                DATA.NonLinStat.Data = [nonlinDescriptions nonlinData];
            else
                DATA.NonLinStat.Data = [DATA.NonLinStat.Data nonlinData];
            end
            
            batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
        end
        if ~DATA.GroupsCalc
            GUI = updateMainStatisticsTable(DATA.timeStatPartRowNumber + DATA.frequencyStatPartRowNumber, DATA.NonLinStat.RowsNames, DATA.NonLinStat.Data, GUI);
        end
        % Create full table
        DATA.NonLinStat.hrv_nonlin_metrics = vertcat(hrv_nonlin_metrics_tables{:});
        DATA.NonLinStat.hrv_nonlin_metrics.Properties.Description = sprintf('HRV non linear metrics for %s', DATA.DataFileName);
    end