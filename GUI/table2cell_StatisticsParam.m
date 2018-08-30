%%
    function [stat_data_cell, stat_row_names_cell, stat_descriptions_cell] = table2cell_StatisticsParam(stat_table)
        
        variables_num = length(stat_table.Properties.VariableNames);
        stat_data_cell = cell(variables_num, 1);
        stat_row_names_cell = cell(variables_num, 1);
        stat_descriptions_cell = cell(variables_num, 1);
        
        table_properties = stat_table.Properties;
        for i = 1 : variables_num
            var_name = table_properties.VariableNames{i};
            if length(stat_table.(var_name)) == 1
                stat_data_cell{i, 1} = sprintf('%.2f', stat_table.(var_name));
            else
                stat_data_cell{i, 1} = sprintf('%.2f\x00B1%.2f', stat_table.(var_name)(1), stat_table.(var_name)(2));
            end
            stat_row_names_cell{i, 1} = [var_name ' (' table_properties.VariableUnits{i} ')'];
            stat_descriptions_cell{i, 1} = table_properties.VariableDescriptions{i};
        end
    end