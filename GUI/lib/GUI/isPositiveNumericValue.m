%%
function isnumeric = isPositiveNumericValue(str)

new_val = str2double(str);

if isnan(new_val) || new_val <= 0    
    isnumeric = 0;
else
    isnumeric = 1;
end
