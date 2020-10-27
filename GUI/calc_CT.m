%%
function biomarker = calc_CT(signal, x)

signal(isnan(signal)) = [];

biomarker = 0;
for index = 1 : length(signal)
    if signal(index) < x
        biomarker = biomarker + 1;
    end
end 

biomarker = 100 * biomarker / length(signal);