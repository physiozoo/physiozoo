%%
function config_struct = update_config_struct(config_map, config_struct)
config_keys = keys(config_map);
for i = 1 : length(config_keys)
    curr_field = config_keys{i};
    if isstruct(config_struct.(curr_field))
        config_struct.(curr_field).value = config_map(curr_field);
    else
        config_struct.(curr_field) = config_map(curr_field);
    end
end