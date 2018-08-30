%%
    function [DATA, GUI] = calcStatistics(DATA, GUI)
        if isfield(DATA, 'AnalysisParams')
            GUI.StatisticsTable.ColumnName = {'Description'};
            
            if DATA.AnalysisParams.winNum == 1
                GUI.StatisticsTable.ColumnName = cat(1, GUI.StatisticsTable.ColumnName, 'Values');
            else
                for i = 1 : DATA.AnalysisParams.winNum
                    GUI.StatisticsTable.ColumnName = cat(1, GUI.StatisticsTable.ColumnName, ['W' num2str(i)]);
                end
            end
            
            waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            
            try
                [DATA, GUI] = calcTimeStatistics(DATA, GUI, waitbar_handle);
            catch
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            end
            try
                [DATA, GUI] = calcFrequencyStatistics(DATA, GUI, waitbar_handle);
            catch
                waitbar_handle = waitbar(0, 'Calculating', 'Name', 'Working on it...');
            end
            try
                [DATA, GUI] = calcNonlinearStatistics(DATA, GUI, waitbar_handle);
            catch
            end
            if ishandle(waitbar_handle)
                close(waitbar_handle);
            end
        end
    end