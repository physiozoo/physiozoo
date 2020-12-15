function peaks=EGM_peaks(signal,params,toplot)
% peaks=EGM_peaks(signal,params)
% 
% PhysioZoo's default beat detector for sinoatrial node electrographic recordings.
% last eddited by Ori Shemla on December 15th, 2020
% If you use it - please use the following refference:
%   Shemla et al 2020 (Frontiers in physiology)
%
%
% inputs-
%   signal: numeric vector, raw electrogram record
%   params: 1x1 struct with the following fields:
%               - Fs (obligatory): numeric scalar, the measurement frequency (Hz).
%               - ref_per (obligatory): numeric scalar, the typical
%               refractory period (msec) of the mammal type.
%               - bi (obligatory): numeric scalar, the typical beating interval (msec) of the
%               mammal type.
%               - prom_thrresh1: numeric scalar. The relative peak prominence threshold [%] for the initial beat detection. In the range of [0-100]. default - 20.           
%               - prom_thrresh2: numeric scalar. The relative peak prominence threshold [%] for the beat classification. In the range of [0-inf]. default - 80.           
%
% outputs- 
%   peaks: numeric vector of real positive integers, the peaks location
%   indices in the electrogram signal.
% 
% 
% example: 
% temp=load('egm_filename.mat','Data');
% signal=temp.Data;
% params.Fs=10000;
% params.ref_per=30;
% params.bi=250;
% peaks=EGM_peaks(signal,params)
% 


if nargin==2
    toplot=0;
elseif nargin<2
    error('not enough input arguments')
end
if nargout~=1
    error('too much or not at all output arguments')
end

if ~isfield(params,'Fs') || ~isfield(params,'ref_per') || ~isfield(params,'bi') || isempty(params.Fs) || isempty(params.ref_per) || isempty(params.bi) || ~isfinite(params.Fs) || ~isfinite(params.ref_per) || ~isfinite(params.bi)
    error('Invalid refractory period and BI values. Enter their values as fields in ''params''');
elseif params.bi<3 || params.ref_per<1
    warning('The refractory_period and BI values are extrimely low. make sure their units are millisecond.')
end
if ~isfield(params,'plot_title')
    params.plot_title='';
end
params.ref_per=params.ref_per*0.95;%msec
if ~isvector(signal) || numel(signal)<=1
    error('''signal'' must be a vector')
elseif any(size(signal)>size(signal,1))
    signal=reshape(signal,[length(signal),1]);
end

%parameters declaration and input verification
%set values in the 'params' struct 
%resampling parameters
%params.BI_resolution=150;

%params.peaks_height_factor=1;
txt='';

%notch filter
signal_filtered=notch_filter_zoo_simple(signal,params);
if toplot
    begin=132.69;
    per=2.5;

    signal_temp=signal((params.Fs)*begin:(params.Fs)*(begin+per));
    time_temp=0:1/(params.Fs):per;
    signal_filtered_temp=signal_filtered(params.Fs*begin:params.Fs*(begin+per));
    time_f_temp=0:1/params.Fs:per;
    
    figure(100)
    subplot(311)
    plot(time_temp,signal_temp,'LineWidth',1,'Color',[0.8500 0.3250 0.0980])
    hold on
    plot(time_f_temp,signal_filtered_temp,'LineWidth',1,'Color',[0 0.4470 0.7410])
    box off
    hold off

    legend({'Raw signal','Filtered signal'},'Location','southeastoutside','EdgeColor',[1 1 1],'FontSize',12,'FontName','Times New Roman','FontWeight','bold');
    legend boxoff
    %title('Filtered vs raw EGM [mV]','FontSize',12)
    ylabel('Electrogram (mV)')

    ax_temp=gca;
    set(ax_temp,'FontSize',12,'FontName','Times New Roman','FontWeight','bold')  
    set(ax_temp.YLabel,'Units','normalized','FontSize',12)
    txt(1)=text(ax_temp,ax_temp.YLabel.Position(1),1.15,'A','Units','normalized','FontWeight','bold','FontSize',12,'HorizontalAlignment','right');

end
%upside or downside decision
side = peak_side(signal_filtered,params,0);
if side
    signal_filtered1=signal_filtered;
else
    signal_filtered1=-signal_filtered;  
end
%peak detection
peaks=peak_detection_per_segment(signal_filtered1,params,toplot,txt);



end

%%%%%%%%%%%%%%%%%%

function peaks=peak_detection_per_segment(signal,params,toplot,txt)
    if ~isfield(params,'min_promp_perc')
        params.prom_thresh1=20;
    else
        params.prom_thresh1=min(max(params.prom_thresh1,0),100);
    end
    if ~isfield(params,'min_promp_thresh')
        arams.prom_thresh2=80;
    else
        arams.prom_thresh2=max(arams.prom_thresh2,0);
    end

    L=length(signal);

    MinPeakDistance=params.ref_per*params.Fs/1000;

    num_of_segments=max(1,round(L/(params.Fs*20)));
    overlap=floor(MinPeakDistance);
    length_of_segment=floor((L-overlap)/num_of_segments);
    temp=cell(num_of_segments,4);

    for k=1:num_of_segments
        %segmentation
        begin=(k-1)*length_of_segment+1;
        finish=k*length_of_segment+overlap;%note overlap
        sig_temp=signal(begin:finish);
        %naive peak detection
        %[temp{k,1},temp_idx,temp{k,3},temp{k,4}]=findpeaks(sig_temp,'MinPeakDistance',MinPeakDistance,'MinPeakWidth',params.beta);
        p=params.prom_thresh1/2;
        MinPeakProm=(prctile(sig_temp,100-p)-prctile(sig_temp,p));
        [temp{k,1},temp_idx,temp{k,3},temp{k,4}]=findpeaks(sig_temp,'MinPeakWidth',5,'MaxPeakWidth',2*MinPeakDistance,'WidthReference','halfheight','MinPeakProminence',MinPeakProm,'MinPeakDistance',MinPeakDistance);
       
        temp{k,2}=temp_idx+begin-1;
    %     %beta filtering based on width
    %     idx_beta=temp{k,3}>params.beta;
    %     for k2=1:4
    %         temp{k,k2}=temp{k,k2}(idx_beta);
    %     end
    %     %params.alpha=0.95;
        %alpha filtering based on prominence
        idx_alpha=temp{k,4}>arams.prom_thresh2/100*median(temp{k,4});
        discarded_peaks=temp_idx(~idx_alpha);
        selected_peaks=temp_idx(idx_alpha);
        temp{k,2}=temp{k,2}(idx_alpha);
         if toplot
            [num2str(k) ': ' num2str(sum(~idx_alpha)) ' discarded']
            begin=13;
            per=2.5;
            time_vec=(0:(length(sig_temp)-1))/params.Fs;
            figure(100)
            subplot(312)
            plot(time_vec-begin,sig_temp,time_vec(selected_peaks)-begin,sig_temp(selected_peaks),'ob',time_vec(discarded_peaks)-begin,sig_temp(discarded_peaks),'xk','LineWidth',1)
            legend({'Filtered signal','Selected peaks','Discarded peaks'},'Location','southeastoutside','EdgeColor',[1 1 1],'FontSize',12,'FontName','Times New Roman','FontWeight','bold');
            xlim([0 per])
            legend boxoff
            box off
            ylabel('Electrogram (mV)')
            %xlabel('Time [sec]')
            ax_temp=gca;
            set(ax_temp,'FontSize',12,'FontName','Times New Roman','FontWeight','bold')  
            set(ax_temp.YLabel,'Units','normalized','FontSize',12)
            txt(2)=text(ax_temp,ax_temp.YLabel.Position(1),1.15,'B','Units','normalized','FontWeight','bold','FontSize',12,'HorizontalAlignment','right');

            subplot(313)
            plot(time_vec(selected_peaks(2:end))-begin,diff(selected_peaks)*1000/params.Fs,'LineWidth',1)
            ylabel('Beat interval (msec)')
            xlabel('Time (sec)')
            box off
            xlim([0 per])
            ax_temp=gca;
            set(ax_temp,'FontSize',12,'FontName','Times New Roman','FontWeight','bold')  
            set(ax_temp.YLabel,'Units','normalized','FontSize',12)
            set(ax_temp.XLabel,'Units','normalized','FontSize',12)
            txt(3)=text(ax_temp,ax_temp.YLabel.Position(1),1.15,'C','Units','normalized','FontWeight','bold','FontSize',12,'HorizontalAlignment','right');
            set(ax_temp.Parent,'Units','normalized','Position',[0.2 0 0.7 0.9])
            ax_all=ax_temp.Parent.Children;
            pos_min=inf;
            for a=1:length(ax_all)
                if strcmp(ax_all(a).Type,'axes')
                    pos{a}=get(ax_all(a),'Position');
                    pos_min=min([pos_min,pos{a}(end-1)]);
                end                
            end
            for a=1:length(ax_all)
                if strcmp(ax_all(a).Type,'axes')
                    pos{a}=[pos{a}(1:2) pos_min pos{a}(4)];
                    set(ax_all(a),'Position',pos{a});
                end                
            end
            set(txt(1),'Position',[txt(1).Parent.YLabel.Position(1) txt(1).Position(2:end)])
            set(txt(2),'Position',[txt(2).Parent.YLabel.Position(1) txt(2).Position(2:end)])
            set(txt(3),'Position',[txt(3).Parent.YLabel.Position(1) txt(3).Position(2:end)])
            
         end
    end
    % A=cell2mat(temp);
    % height=A(:,1);
    % peaks=A(:,2);
    % width=A(:,3);
    % prominence=A(:,4);
    peaks=cell2mat(temp(:,2));
    

end

function side = peak_side(Data,params,toplot)
params.notch_freq_low=1000/params.bi/2;
params.notch_freq_high=1000/params.ref_per*2;
params.notch_freq_resolution=10*abs(params.notch_freq_high-params.notch_freq_low);
upside_thresh=prctile(Data,40);
downside_thresh=prctile(Data,60);

up_idx=Data>upside_thresh;
down_idx=Data<downside_thresh;
Data_up=Data;
Data_up(~up_idx)=upside_thresh;
[norm_pxx_up,f_axis_up]=EGM_PSD(Data_up,params);

Data_down=-Data;
Data_down(~down_idx)=-downside_thresh;
[norm_pxx_down,f_axis_down]=EGM_PSD(Data_down,params);

mean_freq_up=sum(norm_pxx_up.*f_axis_up)/sum(norm_pxx_up);
mean_freq_down=sum(norm_pxx_down.*f_axis_down)/sum(norm_pxx_down);

side=mean_freq_up>mean_freq_down;

if toplot
    figure(100)
    subplot(412)
    semilogy(f_axis_up,norm_pxx_up,f_axis_down,norm_pxx_down)
    leg2=legend('Upside','Downside');
    Leg2.EdgeColor=[1 1 1];%white line color of the legend box

    ylabel('PSD [n.u.]')
    xlabel('Frequency [Hz]')
    box off
%     legend boxoff
end
end

function [filtered_data,filter_freq]=notch_filter_zoo_simple(Data,params)
% toplot=0;
%notch filter parameters
params.notch_low=2;
params.notch_high=2;
params.notch_freq_low=40;
params.notch_freq_high=100;%500
params.notch_freq_resolution=10*abs(params.notch_freq_high-params.notch_freq_low);
params.notch_width=0.5;
params.notch_quotient=1;
params.notch_limit_multiplier=3;%1.7;

%PSD calculation and normalization 
[norm_pxx,f_axis,~]=EGM_PSD(Data,params);
Fs=params.Fs;
threshold=5*prctile(norm_pxx,90);

%50,60 Hz location
[~,i50]=min(abs(f_axis-50));
[~,i60]=min(abs(f_axis-60));
if norm_pxx(i50)>threshold
    filter_freq=50;
    filtered_data=notch_egm_subfunction(Data,Fs,filter_freq);
elseif norm_pxx(i60)>threshold
    filter_freq=60;
    filtered_data=notch_egm_subfunction(Data,Fs,filter_freq);
else
    filter_freq=[];
    filtered_data=Data;
end
% if toplot
%     figure()
%     plot(f_axis,norm_pxx,[f_axis(1),f_axis(end)],[threshold,threshold]);
%     filter_freq
% end
end


function [norm_pxx,f_axis,df]=EGM_PSD(Data,params)
%calculate the PSD function od the Data
    Fs=params.Fs;
    df=abs(min(params.notch_freq_high,Fs/2)-params.notch_freq_low)/params.notch_freq_resolution;
    f_axis=params.notch_freq_low:df:min(params.notch_freq_high,Fs/2);
    finish=min(length(Data),round(2*60*Fs));
    pxx=pwelch(Data(1:finish),[],[],f_axis,Fs);
    norm_pxx=pxx;% no normalization
    MeanSquareRoot=sqrt(mean(norm_pxx.^2));
    % norm_pxx=norm_pxx/std(norm_pxx);
    norm_pxx=norm_pxx/MeanSquareRoot;
    norm_pxx=norm_pxx/sum(norm_pxx);
end

function filtered_sig=notch_egm_subfunction(sig,Fs,electricity_freq)
%filter the signal with an IIR Notch filter
    
    if ~isempty(electricity_freq) && electricity_freq
        %q=100; %quality factor of the filter

        w0=electricity_freq/(Fs/2);
        %bw=w0/q;
        bw=1/(Fs/2);%bandwidth of 1 Hz
        q=w0/bw; %quality factor of the filter
        [b,a]=iirnotch(w0,bw);

        filtered_sig=filtfilt(b,a,sig);
    else
        filtered_sig=sig;
    end
end

