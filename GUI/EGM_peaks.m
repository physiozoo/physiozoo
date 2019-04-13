function peaks=EGM_peaks2(signal,params)
% peaks=EGM_peaks(signal,params)
% 
% PhysioZoo's default peak detector for electrograms.
% inputs-
%   signal: numeric vector, raw electrogram record
%   params: 1x1 struct with the following fields:
%               - Fs: numeric scalar, the measurement frequency (Hz).
%               - refractory_period: numeric scalar, the typical
%               refractoric period (msec) of the mammal type.
%               - alpha: numeric scalar, adjustable parameter (n.u.) for the
%               prominence of the peaks. higher alpha means more prominent
%               peaks selection. typically in the range of [0-2].
%               - BI: numeric scalar, the typical beating interval (msec) of the
%               mammal type.
%               
%               example:
%                   params.Fs=Fs;
%                   params.refractory_period=40;
%                   params.alpha=0.95;
%                   params.BI=205;
% outputs- 
%   peaks: numeric vector of real positive integers, the peaks location
%   indices in the electrogram signal.
% 
% last update:April 2019
% by Ori Shemla 
% 
% 
new_Fs=round(150*1000/params.refractory_period);
if new_Fs<params.Fs
    ratio=params.Fs/new_Fs;
    signal=resample(signal,new_Fs,params.Fs);
    params.Fs=new_Fs; 
else
    ratio=1;
end
beta=min(14,0.1*(params.refractory_period*params.Fs/1000));
params.beta=beta;
signal=notch_egm(signal,params.Fs);
%[~,peaks1_raw,w1,p1]=findpeaks(signal,'MinPeakDistance',params.refractory_period*params.Fs/1000,'MinPeakWidth',beta);
%[~,peaks2_raw,w2,p2]=findpeaks(-signal,'MinPeakDistance',params.refractory_period*params.Fs/1000,'MinPeakWidth',beta);
[~,peaks1,~,p1]=naive_peak_detection_per_segments(signal,params);
[~,peaks2,~,p2]=naive_peak_detection_per_segments(-signal,params);

% peaks1=peaks1_raw(w1>beta);
% peaks2=peaks2_raw(w2>beta);
% p1=p1(w1>beta);
% p2=p2(w2>beta);

%params.alpha=0.95;

peaks1=peaks1(p1>params.alpha*mean(p1));
peaks2=peaks2(p2>params.alpha*mean(p2));

if std(diff(peaks1))>std(diff(peaks2))
    peaks=peaks2;
else
    peaks=peaks1;
end

if ratio~=1
    peaks=round(peaks*ratio);
end

end

%%%%%%%%%%%%%%%%%%%
function [filtered_sig,filter_description] = notch_egm(sig,Fs)
%[filtered_sig,filter_description] = notch_egm(sig,Fs,toplot)
%

f_axis=40:0.01:70;
pxx=pwelch(sig,[],[],f_axis,Fs);
mean_power=sum(pxx)/length(pxx);


filtered_sig=sig;
filter_description='raw signal';
pxx_temp60=pxx((f_axis>=59 & f_axis<=61));
pxx_temp50=pxx((f_axis>=49 & f_axis<=51));

if sum(pxx_temp60)/length(pxx_temp60)>=mean_power*2
    %notch filter around 60 Hz
    [~,idx]=max(pxx_temp60);
    electricity_freq=f_axis(idx)+19;%Hz
    q=50; %quality factor of the filter

    w0=electricity_freq/(Fs/2);
    bw=w0/q;
    [b,a]=iirnotch(w0,bw);

    filtered_sig=filtfilt(b,a,sig);
    filter_description=[filter_description,'-60Hz'];
end
if sum(pxx_temp50)/length(pxx_temp50)>=mean_power*2
%notch filter around 50 Hz
    [~,idx]=max(pxx_temp50);
    electricity_freq=f_axis(idx)+9;%Hz
    q=50; %quality factor of the filter

    w0=electricity_freq/(Fs/2);
    bw=w0/q;
    [b,a]=iirnotch(w0,bw,6);

    filtered_sig=filtfilt(b,a,sig);
    filter_description=[filter_description,'-50Hz'];

end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [height,peaks_idx,width,prominence]=naive_peak_detection_per_segments(signal,params)

L=length(signal);
num_of_segments=max(1,round(L/(params.Fs*30)));
length_of_segment=floor(L/num_of_segments);

for k=1:num_of_segments
    begin=(k-1)*length_of_segment+1;
    finish=k*length_of_segment;
    [temp{k,1},temp_idx,temp{k,3},temp{k,4}]=findpeaks(signal(begin:finish),'MinPeakDistance',params.refractory_period*params.Fs/1000,'MinPeakWidth',params.beta);
    temp{k,2}=temp_idx+begin-1;
end
A=cell2mat(temp);
height=A(:,1);
peaks_idx=A(:,2);
width=A(:,3);
prominence=A(:,4);



end

