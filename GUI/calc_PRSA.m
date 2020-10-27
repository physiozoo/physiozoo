%%
function PRSA_window = calc_PRSA(signal, d)

signal = signal';
windows = [];
for index = max(d+1, 2) : length(signal) - d
    if signal(index) < signal(index-1)
        windows = [windows; signal(index-d:index+d)];
    end
end

PRSA_window = sum(windows, 1, 'omitnan') / size(windows, 1);