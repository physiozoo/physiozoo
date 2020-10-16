%%
function biomarker = calc_CA(signal, x)

biomarker = 0;
for index = 1 : length(signal)
    if signal(index) < x
        to_add = x - signal(index);
        biomarker = biomarker + to_add;
    end
end 

biomarker = biomarker / length(signal);