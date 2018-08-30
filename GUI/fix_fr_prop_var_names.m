%%
    function fr_prop_variables_names = fix_fr_prop_var_names(fr_prop_variables_names)
        fr_prop_variables_names = cellfun(@(x) strrep(x, 'BETA', sprintf('\x3b2')), fr_prop_variables_names, 'UniformOutput', false);
        fr_prop_variables_names = cellfun(@(x) strrep(x, '_', sprintf(' ')), fr_prop_variables_names, 'UniformOutput', false);
        fr_prop_variables_names = cellfun(@(x) strrep(x, ' TO ', sprintf('/')), fr_prop_variables_names, 'UniformOutput', false);
        fr_prop_variables_names = cellfun(@(x) strrep(x, ' POWER', sprintf('')), fr_prop_variables_names, 'UniformOutput', false);
        fr_prop_variables_names = cellfun(@(x) strrep(x, 'TOTAL', sprintf('TOTAL POWER')), fr_prop_variables_names, 'UniformOutput', false);
    end