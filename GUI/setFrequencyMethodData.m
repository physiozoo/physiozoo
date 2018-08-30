%%
    function [StatRowsNames, StatData] = setFrequencyMethodData(DATA)
        StatRowsNames = [];
        StatData = [];
        if ~isempty(DATA.FrStat)
            if DATA.default_frequency_method_index == 2 % AR
                if isfield(DATA.FrStat, 'ArWindowsData')
                    StatRowsNames = DATA.FrStat.ArWindowsData.RowsNames;
                    StatData = DATA.FrStat.ArWindowsData.Data;
                end
            elseif DATA.default_frequency_method_index == 1 % Welch
                if isfield(DATA.FrStat, 'WelchWindowsData')
                    StatRowsNames = DATA.FrStat.WelchWindowsData.RowsNames;
                    StatData = DATA.FrStat.WelchWindowsData.Data;
                end
            end
        end
    end