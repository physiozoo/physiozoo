function bpfecg = prefilter2(ecg,fs,lcf,hcf,debug)
% this function is made for prefiltering and ecg time series before it is
% passed through a peak detector. Of important note: the upper
% cut off (hcf) and lower cutoff (lcf) of the bandpass filter that is
% applied, highly depends on the mammal that is being considered. This is
% particularly true for the hcf which will be higher for a mouse ECG file
% versus a Human ecg. This is because the QRS is `sharper' for a mouse ecg
% than for a Human one.
%
% input
%   ecg: electrocardiogram (mV)
%   fs: sampling frequency (Hz)
%   lcf: low cut-off frequency (Hz)
%   hcf: high cut-off frequency (Hz)
%   debug: plot output filtered signal (boolean)
%
% output
%   bpfecg: band pass filtered ecg signal
%
% Note: Notch filters not included in this code.
%
% Joachim A. Behar, Technion-IIT, Israel, 2018

% == check NaN
ecg(isnan(ecg))=-32768;

% == prefiltering
LOW_CUT_FREQ = lcf;
HIGH_CUT_FREQ = hcf;
[b_bas,a_bas] = butter(2,LOW_CUT_FREQ/(fs/2),'high');
[b_lp,a_lp] = butter(5,HIGH_CUT_FREQ/(fs/2),'high');
bpfecg = ecg'-filtfilt(b_lp,a_lp,double(ecg'));
bpfecg = filtfilt(b_bas,a_bas,double(bpfecg'));

if debug
    plot(ecg);
    hold on, plot(bpfecg,'r');
end

end