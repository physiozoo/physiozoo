function [DATA, GUI] = clearStatTables(DATA, GUI)
        GUI.TimeParametersTable.Data = []; %cell(1);
        GUI.TimeParametersTableData = [];
        GUI.TimeParametersTable.RowName = [];
        
        GUI.FragParametersTableData = [];
        GUI.FragParametersTable.RowName=[];
        GUI.FragParametersTable.Data = [];
        
        GUI.FrequencyParametersTable.Data = [];
        GUI.FrequencyParametersTableData = [];
        GUI.FrequencyParametersTable.RowName = [];
        GUI.FrequencyParametersTableMethodRowName = [];
        
        GUI.NonLinearTable.Data = [];
        GUI.NonLinearTableData = [];
        GUI.NonLinearTable.RowName = [];
        
        GUI.StatisticsTable.RowName = {''};
        GUI.StatisticsTable.Data = {''};
        GUI.StatisticsTable.ColumnName = {'Description'; 'Values'};
        
        DATA.TimeStat = [];
        DATA.FrStat = [];
        DATA.NonLinStat = [];
        
%         DATA.TimeStat.hrv_time_metrics = [];
%         DATA.FrStat.hrv_fr_metrics = [];
%         DATA.NonLinStat.hrv_nonlin_metrics = [];
        
        DATA.timeStatPartRowNumber = 0;
        DATA.frequencyStatPartRowNumber = 0;
    end