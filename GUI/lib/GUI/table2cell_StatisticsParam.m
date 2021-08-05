%%
    function [stat_data_cell, stat_row_names_cell, stat_descriptions_cell] = table2cell_StatisticsParam(stat_table)
            
        val_num = stat_table.Properties.UserData;
        if isempty(val_num)
            val_num = 1;
        end
    
        variables_num = length(stat_table.Properties.VariableNames);
        stat_data_cell = cell(variables_num, val_num);
        stat_row_names_cell = cell(variables_num, 1);
        stat_descriptions_cell = cell(variables_num, 1);
                
        table_properties = stat_table.Properties;
        for i = 1 : variables_num
            var_name = table_properties.VariableNames{i};
            
            if isstruct(stat_table.(var_name))                                                                
                st = struct2cell(stat_table.(var_name));
                if strcmp(table_properties.VariableUnits{i}, 'ms')
                    st = cellfun(@(x) round(x), st, 'UniformOutput', false);
                else
                    st = cellfun(@(x) sprintf('%.3f', x), st, 'UniformOutput', false);
                end
                stat_data_cell(i, :) = st';
            else
                if length(stat_table.(var_name)) == 1
                    if strcmp(stat_table.(var_name), ' ')
                        stat_data_cell{i, 1} = ' ';
                    else
                        stat_data_cell{i, 1} = sprintf('%.2f', stat_table.(var_name));
                    end
                else
                    stat_data_cell{i, 1} = sprintf('%.2f\x00B1%.2f', stat_table.(var_name)(1), stat_table.(var_name)(2));
                end
            end
            stat_row_names_cell{i, 1} = [var_name ' (' table_properties.VariableUnits{i} ')'];
            stat_descriptions_cell{i, 1} = table_properties.VariableDescriptions{i};
        end
    end