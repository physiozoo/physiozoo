function config_map = parse_gqrs_config_file(file_name)

config_map = containers.Map;

f_h = fopen(file_name);

if f_h ~= -1
    while ~feof(f_h)
        tline = fgetl(f_h);
        if ~isempty(tline) && ~strcmp(tline(1), '#')
            parameters_cell = strsplit(tline);
            if ~isempty(parameters_cell{1})
                config_map(parameters_cell{1}) = parameters_cell{2};
            end
        end
    end
    
    % keySet = keys(config_map)
    % valueSet = values(config_map)
    fclose(f_h);
end
end