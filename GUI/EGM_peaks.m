function peaks=EGM_peaks(signal,params,toplot)
% peaks=EGM_peaks(signal,params)
%
% PhysioZoo's default peak detector for electrograms.
% inputs-
%   signal: Nx1 numeric vector, raw electrogram record
%   params: 1x1 struct with the followin  g fields:
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
%                   params.BI=205;
% outputs-
%   peaks: numeric vector of real positive integers, the peaks location
%   indices in the electrogram signal.
%
% last update:September 2019
% by Ori Shemla
%
%




%parameters declaration and input verification
%set values in the 'params' struct
%resampling parameters
params.BI_resolution=150;
%notch filter parameters
params.notch_low=2;
params.notch_high=2;
params.notch_freq_low=40;
params.notch_freq_high=100;%500
params.notch_freq_resolution=10*abs(params.notch_freq_high-params.notch_freq_low);
params.notch_width=0.5;
params.notch_quotient=1;
params.notch_limit_multiplier=3;%1.7;
params.peaks_height_factor=1;

if nargin==2
    toplot=0;
elseif nargin<2
    error('not enough input arguments')
end
if nargout~=1
    error('too much or not at all output arguments')
end

if ~isfield(params,'refractory_period') || ~isfield(params,'BI') || isempty(params.refractory_period) || isempty(params.BI) || ~isfinite(params.refractory_period) || ~isfinite(params.BI)
    error('Invalid refractory_period and BI values. Enter their values as fields in ''params''');
elseif params.BI<3 || params.refractory_period<1
    warning('The refractory_period and BI values are extrimely low. make sure their units are millisecond.')
end
if ~isfield(params,'plot_title')
    params.plot_title='';
end
params.refractory_period=params.refractory_period*0.95;%msec
if ~isvector(signal) || numel(signal)<=1
    error('''signal'' must be a vector')
elseif any(size(signal)>size(signal,1))
    signal=reshape(signal,[length(signal),1]);
end


%debug mode and figure mode control
toplot_process=toplot;%if toplot_process=1 the program figure a peak detection process figure of 5 steps.
toplot=0;%if toplot=1 the program is in debug mode


%%%%%%%%%%
%3 elements window median filter
signal_med=[median(signal(1:2)) ; median([signal(1:end-2) , signal(2:end-1) , signal(3:end)], 2) ; median(signal(end-1:end))];
if toplot
    t=(0:(length(signal)-1))/params.Fs;
    figure(6)
    plot(t,signal,t,signal_med)
    legend('raw data','median-filtered data')
end


%resampling if possible
Fs_old=params.Fs;
[signal_resampled,params]=resample_EGM_peaks(signal_med,params);
Fs_new=params.Fs;
%filter out unnatural frequencies with multifrequencies notch filter.
signal_filtered=notch_filter_zoo_advanced(signal_resampled,params,toplot);
if toplot_process
    signal_temp=signal((params.Fs*params.ratio)*60:(params.Fs*params.ratio)*60.5);
    time_temp=0:1/(params.Fs*params.ratio):0.5;
    signal_filtered_temp=signal_filtered(params.Fs*60:params.Fs*60.5);
    time_f_temp=0:1/params.Fs:0.5;
    
    figure(100)
    subplot(511)
    plot(time_temp*1000,signal_temp,time_f_temp*1000,signal_filtered_temp,'LineWidth',1.2)
    box off
    Leg1=legend('Raw EGM','Filtered EGM','Location','northeastoutside');
    Leg1.EdgeColor=[1 1 1];%white line color of the legend box
    title('Filtered vs raw EGM [mV]','FontSize',12)
    xlab=xlabel('Time [msec]');
    xlab.Position=[diff(xlim)/10*10.75 -0.195 0]; %adjust the x-axis label to the right side of the axis
    ylabel('[mV]')
    
end

%upside peak detection
%run peak detection algorithm by segments of 30 seconds
[peaks1,params]=peak_detection_per_segment(signal_filtered,params,toplot || toplot_process);
%return to peaks indices of the raw signal (before resampling)
peaks1=round(peaks1*params.ratio);
params.Fs=Fs_old;
r=params.ratio;
params.ratio=1;
%look for the closest local maxima at the raw signal near every peak index
peaks1=local_max_EGM_peaks(signal,peaks1,params);

%downside peak detection
params.Fs=Fs_new;
params.ratio=r;
%run peak detection algorithm by segments of 30 seconds
params=rmfield(params,'template');
[peaks2,params]=peak_detection_per_segment(-signal_filtered,params,toplot);
%return to peaks indices of the raw signal (before resampling)
peaks2=round(peaks2*params.ratio);
params.Fs=Fs_old;
r=params.ratio;
params.ratio=1;
%look for the closest local maxima at the raw signal near every peak index
peaks2=local_max_EGM_peaks(-signal,peaks2,params);


%choose direction of peaks (upwards/downwards)
if mean(signal(peaks1))>=mean(-signal(peaks2))
    peaks=peaks1;
else
    peaks=peaks2;
end
if toplot_process
    begindex=round(14626*r*18+1);
    endex=round(14626*r*19);
    
    figure(100)
    subplot(515)
    time=(0:(length(signal)-1))/(params.Fs);
    plot(time(begindex:endex)-time(begindex),signal(begindex:endex),time(peaks)-time(begindex),signal(peaks),'+r','LineWidth',1.2)
    box off
    title('Final peaks detection','FontSize',12)
    xlab=xlabel('Time [sec]');
    xlab.Position=[diff(xlim)/10*10.75 -0.195 0];%[diff(xlim)/10*10.75 -0.195 0]; %adjust the x-axis label to the right side of the axis
    ylabel('[mV]')
    Leg5=legend('Raw EGM','Peaks','Location','northeastoutside');
    Leg5.EdgeColor=[1 1 1];%white line color of the legend box
    set(gcf,'Position',[1019,203,877,791]);
    
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function [Data_out,params]=resample_EGM_peaks(Data_in,params)

new_Fs=round(params.BI_resolution*1000/params.refractory_period);
if new_Fs<params.Fs
    params.ratio=params.Fs/new_Fs;
    Data_out=resample(Data_in,new_Fs,params.Fs);
    params.Fs=new_Fs;
    params.refractory_period=params.refractory_period;
    params.BI=params.BI;
    
else
    params.ratio=1;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function peaks_out=local_max_EGM_peaks(signal,peaks_in,params)

L0=length(signal);
peaks_out=peaks_in;
% [~,locs,w]=findpeaks(params.template);
% [~,idx]=min(abs(params.template_peak-locs));
% w0=w(idx);

MinPeakDistance=params.refractory_period*params.Fs/1000;
window_max=max(15,round(0.1*MinPeakDistance));

for k=1:length(peaks_in)
    begin=max(1,peaks_in(k)-window_max);
    finish=min(L0,peaks_in(k)+window_max);
    temp=signal(begin:finish);
    [~,l]=max(temp);
    %     l=l+begin-1;
    %     [~,c]=min(abs(l-peaks_in(k))); %activate in the case of multiple close-by local maxima points
    peaks_out(k)=l+begin-1;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [peaks,params]=peak_detection_per_segment(signal,params,toplot)
params.A=[];
L=length(signal);
num_of_segments=max(1,round(L/(params.Fs*10)));
length_of_segment=floor(L/num_of_segments);
MinPeakDistance=params.refractory_period*params.Fs/1000;
for k=1:num_of_segments
    begin=(k-1)*length_of_segment+1;
    finish=k*length_of_segment;
    [temp{k,1},params.template,params.template_peak]=one_sized_peak_detection(signal(begin:finish),params,toplot);
    temp{k,1}=temp{k,1}+begin-1;
    
end
peaks=cell2mat(temp);
if isempty(peaks)
    peaks=[1;L];
end
k=2;
while k<length(peaks)
    if peaks(k)-peaks(k-1)<=MinPeakDistance
        peaks(k)=[];
    else
        k=k+1;
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [peaks,template,template_peak]=one_sized_peak_detection(signal,params,toplot)
toplot_process=toplot;
toplot=0;

%%initial peakdetection
MinPeakDistance=params.refractory_period*params.Fs/1000;
L=length(signal);
time=(0:(L-1))/params.Fs;
MinPeakProm=max( (max(signal)-min(signal))/20 , std(signal(signal<=prctile(signal,(1-2*params.refractory_period/params.BI)*100) & signal>=prctile(signal,(2*params.refractory_period/params.BI)*100))));
%[A(:,1),A(:,2),A(:,3),A(:,4)]=findpeaks2(signal,params,'MinPeakDistance',max(3,0.05*MinPeakDistance),'MinPeakWidth',3,'MaxPeakWidth',MinPeakDistance,'MinPeakProminence',MinPeakProm);
[A(:,1),A(:,2),A(:,3),A(:,4)]=findpeaks(signal,'MinPeakDistance',max(3,MinPeakDistance),'MinPeakWidth',3,'MaxPeakWidth',MinPeakDistance,'MinPeakProminence',MinPeakProm);

if isempty(A) || size(A,1)<=2
    if isfield(params,'template') && isfield(params,'template_peak') && ~isempty(params.template) && ~isempty(params.template_peak)
        template=params.template;
        template_peak=params.template_peak;
    else
        template=[];
        template_peak=[];
        peaks=[];
        return
    end
else
    
    init_A=A;
    
    
    mid_process_A=A;
    
    %%peak classification
    %high_prob_idx=1:size(A,1);
    % minProm=mean(A(:,4))-2*std(A(:,4));
    % maxProm=mean(A(:,4))+2*std(A(:,4));
    minProm=prctile(A(:,4),10);
    maxProm=prctile(A(:,4),90);
    minWidth=prctile(A(:,3),10);
    maxWidth=prctile(A(:,3),90);
    
    
    high_prob_idx=A(:,4)>=minProm & A(:,4)<=maxProm & A(:,3)>=minWidth & A(:,3)<=maxWidth;
    
    
    
    if toplot_process
        figure(100)
        subplot(512);
        plot(time,signal,time(mid_process_A(high_prob_idx,2)),signal(mid_process_A(high_prob_idx,2)),'bo','LineWidth',1.2)
        box off
        hold on
        plot(time(mid_process_A(~high_prob_idx,2)),signal(mid_process_A(~high_prob_idx,2)),'kx','LineWidth',1.2)
        hold off
        title('Initial peak detection and classification','FontSize',12)
        Leg2=legend('Filtered EGM','Chosen peaks','Discarded peaks','Location','northeastoutside');
        Leg2.EdgeColor=[1 1 1];%white line color of the legend box
        xlab=xlabel('Time [sec]');
        xlab.Position=[diff(xlim)/10*10.75 -0.195 0]; %adjust the x-axis label to the right side of the axis
        ylabel('[mV]')
        
    end
    %%%%
    
    %%template declaration
    y2=zeros(L,1);
    y2(A(high_prob_idx,2))=1;
    
    maxlag=round(MinPeakDistance);
    if isfield(params,'template') && ~isempty(params.template)
        template=1/3*xcorr(signal,y2,maxlag)/sum(y2)+2/3*params.template;
    else
        template=xcorr(signal,y2,maxlag)/sum(y2);
    end
    %%%%
    %%find the first prominent peak of the template
    %[~,locs,w,prom]=findpeaks2(template,params,'MinPeakDistance',max(5,0.1*MinPeakDistance),'MinPeakWidth',5,'MaxPeakWidth',MinPeakDistance,'MinPeakProminence',MinPeakProm);
    [~,locs,w,prom]=findpeaks(template,'MinPeakDistance',max(5,0.1*MinPeakDistance),'MinPeakWidth',5,'MaxPeakWidth',MinPeakDistance,'MinPeakProminence',MinPeakProm);
    % if isempty(locs)
    %     template=[];
    %     template_peak=[];
    %     peaks=[];
    %
    %     return;
    % end
    
    
    [maxHeight,I_maxHeight]=max(prom);
    idx=find(prom>maxHeight/5);
    
    locs=locs(idx);
    w=w(idx);
    medW=median(w);
    if length(locs)<3
        medW=inf;
    end
    idx=find(w<=medW);
    if ~isempty(idx)
        template_peak=locs(idx(1));
        template_peak_width=ceil(w(idx(1)));
    else
        template_peak=locs(I_maxHeight);
        template_peak_width=ceil(w(I_maxHeight));
    end
    
    
    
    %%%%
    %%compare to previous templates if available
    if isfield(params,'template') && ~isempty(params.template)
        [R_template,lags_template]=xcorr(params.template,template);
        [~,delay_idx]=max(R_template);
        delay=lags_template(delay_idx);
        template_peak_temp=min(length(template),max(1,params.template_peak-delay));
        
        if toplot
            figure(2);
            
            ax_template(1)=subplot(3,1,1);
            
            plot(ax_template(1),lags_template,R_template,lags_template(delay_idx),R_template(delay_idx),'+r')
            title('xcorr of templates')
            
            ax_template(2)=subplot(3,1,2);
            plot(ax_template(2),template)
            hold on
            plot(ax_template(2),template_peak,template(template_peak),'+r')
            plot(ax_template(2),template_peak_temp,template(template_peak_temp),'+k')
            legend('new template','new peak','old peak')
            title('new template')
            hold off
            
            ax_template(3)=subplot(3,1,3);
            plot(ax_template(3),params.template)
            hold on
            
            plot(ax_template(3),params.template_peak,params.template(params.template_peak),'+k')
            title('old template')
            hold off
        end
        
        
        if (template_peak_temp>template_peak+10 | template_peak_temp<template_peak-10) & ~ismembertol(template_peak_temp,locs,5)
            template_peak=template_peak_temp;
        elseif ismembertol(template_peak_temp,locs,5)
            [~,template_peak_idx]=min(abs(template_peak_temp-locs));
            template_peak=locs(template_peak_idx);
        end
        
        
    end
    
    
    if toplot_process
        figure(100)
        subplot(513)
        t_template=(0:(length(template)-1))*1000/params.Fs;
        plot(t_template,template,'LineWidth',1.2)
        box off
        hold on
        plot(t_template(template_peak),template(template_peak),'+r','LineWidth',1.2)
        Leg3=legend('Template','Desired peak','Location','northeastoutside');
        Leg3.EdgeColor=[1 1 1];%white line color of the legend box
        title('Calculated template','FontSize',12)
        hold off
        xlim([-max(t_template) max(t_template)*2])
        xlab=xlabel('Time [msec]');
        xlab.Position=[diff(xlim)/10*10.75 -0.195 0]; %adjust the x-axis label to the right side of the axis
        ylabel('[mV]')
        
    end
end
%%%%
%%cross correlation calculation and simple peak detection with a
%%threshold
[R3,lags]=xcorr(signal,template);
lags=lags+template_peak;
R3=R3(lags>=0 & lags<L);
% R3(R3<0)=0;
%note power of 3
R3=R3.^3;
lags=lags(lags>=0 & lags<L)/params.Fs;
prc90=prctile(R3(R3>=0),90);
prc10=prctile(R3,10);
R3_alternative=R3(R3>=prc10 & R3<=prc90);
minH=max(std(R3_alternative),max(R3)/10);
%[h,peaks]=findpeaks2(R3,params,'MinPeakProminence',minH,'MinPeakDistance',MinPeakDistance,'MinPeakHeight',minH);
try
    [h,peaks]=findpeaks(R3,'MinPeakProminence',minH,'MinPeakDistance',MinPeakDistance,'MinPeakHeight',minH);
    
    %check if the segment borders are parts of a peak
    if min(peaks)>MinPeakDistance && R3(1)>mean(R3(peaks))/3
        h=[R3(1);h];
        peaks=[1;peaks];
    end
    if max(peaks)<length(R3)-MinPeakDistance && R3(end)>mean(R3(peaks))/3
        h=[h;R3(end)];
        peaks=[peaks;length(R3)];
    end
catch
    h=[];
    peaks=[];
    return
end


if toplot
    R3_alternative=R3;
    R3_alternative(R3>minH)=NaN;
    figure(3);
    ax2(1)=subplot(2,1,1);
    plot(lags,R3,lags,R3_alternative,lags(peaks),h,'+r')
    ax2(2)=subplot(2,1,2);
    plot(time,signal,time(peaks),signal(peaks),'+r')
    linkaxes(ax2,'x');
end
if toplot_process
    R3_alternative=R3;
    R3_alternative(R3>minH)=NaN;
    figure(100);
    subplot(514);
    plot(lags,R3,lags,R3_alternative,lags(peaks),h,'+r','LineWidth',1.2)
    box off
    Leg4=legend('Above threshold','Below threshold','Local maxima','Location','northeastoutside');
    Leg4.EdgeColor=[1 1 1];%white line color of the legend box
    title('Correlation between template and EGM','FontSize',12)
    xlab=xlabel('Time [sec]');
    xlab.Position=[diff(xlim)/10*10.75 -0.195 0]; %adjust the x-axis label to the right side of the axis
    ylabel('[mV^2]')
    
end

%%%%
if toplot
    figure(4)
    
    ax(1)=subplot(3,1,1);
    plot(time,signal,time(init_A(:,2)),signal(init_A(:,2)),'+r')
    title('Naive peak detection')
    
    ax(2)=subplot(3,1,2);
    plot(time,signal,time(mid_process_A(high_prob_idx,2)),signal(mid_process_A(high_prob_idx,2)),'bo')
    hold on
    plot(time(mid_process_A(~high_prob_idx,2)),signal(mid_process_A(~high_prob_idx,2)),'kx')
    hold off
    title('First peak filtering')
    
    
    ax(3)=subplot(3,1,3);
    plot(time,signal,time(peaks),signal(peaks),'+r')
    title('Aproximated peak detection by template recognition')
    linkaxes(ax,'x');
end

end
