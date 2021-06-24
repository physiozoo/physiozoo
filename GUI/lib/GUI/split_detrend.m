%%
function detrended_signal_trans = split_detrend(signal2detrend, lambda, Fs, waitbar_handle)

part_length = 500;

detrended_signal_trans = [];

sl = length(signal2detrend);

sm_parts_num = ceil(sl / part_length);
minLimit = 1;
maxLimit = min(part_length, sl);

for i = 1 : sm_parts_num    
    
    waitbar(i / sm_parts_num, waitbar_handle, ['Detrending part ' num2str(i)]); setLogo(waitbar_handle, 'M1');
    
    detrended_part_signal = mhrv.rri.detrendrr(signal2detrend(minLimit : maxLimit), lambda, Fs);
    
    minLimit = maxLimit + 1;
    maxLimit = min(maxLimit + part_length, sl);
    
    detrended_signal_trans = [detrended_signal_trans; detrended_part_signal];  
end


