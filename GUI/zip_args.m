function args = zip_args(keys, values)

if ~isempty(keys) && length(keys) == length(values)
    args = jsonencode(containers.Map(keys,values));
    args = insertBefore(args, '"', "\");
else
    args = '';
end