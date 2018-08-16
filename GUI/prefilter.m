function bpfecg = prefilter(ecg,fs,lcf,hcf)
debug = 0;
% this function is made for prefiltering and ECG time series before it is
% passed through an alternative peak detector. Of important note: the upper
% cut off (hcf) and lower cutoff (lcf) of the bandpass filter that is
% applied, highly depends on the mammal that is being considered. This is
% particularly true for the hcf which will be higher for a mouse ECG file
% versus a human ECG for example.

% == prefiltering
LOW_CUT_FREQ = lcf;
HIGH_CUT_FREQ = hcf;
[b_lp,a_lp] = butter(5,HIGH_CUT_FREQ/(fs/2),'high');
[b_bas,a_bas] = butter(2,LOW_CUT_FREQ/(fs/2),'high');
ecg = ecg-mean(ecg);
bpfecg = ecg'-filtfilt(b_lp,a_lp,double(ecg'));
bpfecg = filtfilt(b_bas,a_bas,double(bpfecg));

if debug
    plot(ecg);
    hold on, plot(bpfecg,'r');
end

end