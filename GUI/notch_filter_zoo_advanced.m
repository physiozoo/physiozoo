function [filtered_data,filter_freq]=notch_filter_zoo_advanced(Data,params,varargin)
% [filtered_data,filter_freq]=notch_filter_zoo_advanced(Data,Fs,params,toplot)
% 
% This function scan the PSD of the Data and look for unnatural
% frequencies, such as elctricity power grid noiseat 50/60 Hz.
% The range and resolution or scanned frequencies are detailed in 'params', among other parameters.  
% The scan is based on the first 2 minutes of the Data.
% 
% inputs-
%   Data:(obligatory) Nx1 numeric vector, raw signal recording.[V/mV/uV/A.U.]
%   params:(obligatory) structure of parameters
%       list of required fields:
%           -Fs: numeric scalar, the measurement frequency.[Hz]
%           -notch_low: numeric scalar, the ratio of low frequencies fit in
%           the limit line.[1]
%           -notch_high: numeric scalar, the ratio of high frequencies fit in
%           the limit line.[1]
%           -notch_width: numeric scalar,the maximal width of an unnatural frequency peak to filter out.[Hz]  
%           -notch_freq_low: numeric scalar, the lowest frequency to scan
%           from.[Hz]
%           -notch_freq_high: numeric scalar, the highest frequency to scan
%           from.[Hz]
%           -notch_df: numeric scalar, the resolution of frequencies to scan
%           from.[Hz]
%   toplot: binaric scalar, indicate whether or not to produce a figure of
%   the results of the filtering process. value is 1/0(default)
% 
% outputs-
%   filtered_data: Nx1 numeric vector, filtered signal recording.[V/mV/uV/A.U.]
%   filter_freq: 1xM numeric vector, contain the values of the unnatural
%   frequencies which had been filtered out. M is the number of filtered out frequencies, M<=6.[Hz]
% 
% example of usage:
%    load('young_06_part2.mat','Data','Fs');%load 'Data and 'Fs' from some EGM recording
%    params.notch_low=3;
%    params.notch_high=2;
%    params.notch_freq_low=40;
%    params.notch_freq_high=500;
%    params.notch_freq_resolution=(10*abs(params.notch_freq_high-params.notch_freq_low);
%    params.notch_width=0.5;
%    params.Fs=Fs;
%    
%    toplot=1;% 1- figure 0-no figure
%    [filtered_data,filter_freq]=notch_filter_zoo_advanced(Data,params,toplot);
%    filter_freq
% gives:
% a figure with M=3 peaks of filtered out unnatural frequencies.
% filter_freq =
%   120.0000  240.0000  407.9000
% 'filtered_data' is in the same size of Data.
% 

method=2;%limit line fit method
%input check
narginchk(2,3);
if nargin==2
    toplot=0;
else
    toplot=varargin{1};
end
%PSD calculation and normalization 
Fs=params.Fs;
df=abs(min(params.notch_freq_high,Fs/2)-params.notch_freq_low)/params.notch_freq_resolution;
f_axis=params.notch_freq_low:df:min(params.notch_freq_high,Fs/2);
finish=min(length(Data),round(2*60*Fs));
pxx=pwelch(Data(1:finish),[],[],f_axis,Fs);
norm_pxx=pxx;
MeanSquareRoot=sqrt(mean(norm_pxx.^2));
% norm_pxx=norm_pxx/std(norm_pxx);
norm_pxx=norm_pxx/MeanSquareRoot;
norm_pxx=norm_pxx/sum(norm_pxx);

if method==1
    %calculate and draw a line of the limit for the peaks
    %fit a model of pxx=a*(1./f)+b*f+c
    fittype1=fittype({'1/x','x','1'});
    STD_func=fit(f_axis',norm_pxx',fittype1);
    STD_axis1=STD_func.a./f_axis+STD_func.b*f_axis+STD_func.c;
    %adjust the model
    STD_axis1=STD_axis1-min(STD_axis1);
    STD_axis1=STD_axis1+(mean(norm_pxx)-min(norm_pxx));

    %fit a model of pxx=exp(b)*exp(a*f) for the range of low frequencies only
    fittype2=fittype({'x','1'});
    f_axis1=f_axis(f_axis<f_axis(1)+50);
    norm_pxx1=norm_pxx(f_axis<f_axis(1)+50);
    STD_func2=fit(f_axis1(norm_pxx1>mean(norm_pxx1))',log(norm_pxx1(norm_pxx1>mean(norm_pxx1))'),fittype2);
    STD_axis2=exp(STD_func2.a.*f_axis+STD_func2.b);
    %adjust the model
    STD_axis2=STD_axis2-min(STD_axis2);
    STD_axis2=STD_axis2+(mean(norm_pxx)-min(norm_pxx));

    %sum the limit lines
    limit_line=params.notch_high*STD_axis1+params.notch_low*STD_axis2;
else
    %estimate the limit line according to local maxima of ~5 Hz segments of
    %the normalized PSD
    %step 1: find local maxima per segment
    num_of_segments=round((f_axis(end)-f_axis(1))/max(10,50*df));
    segment_length=floor(length(f_axis)/num_of_segments);
    local_max=zeros(1,num_of_segments);
    local_freq=local_max;
    
    for k=1:num_of_segments
        begin=(k-1)*segment_length+1;
        finish=k*segment_length;
        [local_max(k),temp_idx]=max(norm_pxx(begin:finish));
        local_freq(k)=f_axis(temp_idx+begin-1);
    end
    %step 2: quotient filtering of the local maxima series.
    diff_max=diff(diff(local_max));
    idx=[0 diff_max 0]<-params.notch_quotient*local_max;
    local_max(idx)=[];
    local_freq(idx)=[];
    %step 3: fit a curve for the local maxima series
    limit_line=zeros(size(f_axis));
    for k=1:length(local_max)-1
        linear_fit=polyfit(local_freq(k:k+1),local_max(k:k+1),1);
        idx2 = (f_axis>=local_freq(k) & f_axis<local_freq(k+1)) | (k==1 & f_axis<local_freq(1));
        limit_line(idx2)=linear_fit(1)*f_axis(idx2)+linear_fit(2);
        
    end
    limit_line=max(limit_line , prctile(norm_pxx(f_axis>=70),90)+std(norm_pxx(f_axis>=70)));
    limit_line=params.notch_limit_multiplier*limit_line;
% %     %fit a curve for the local maxima series
% %     polynom_low=polyfit(local_freq(local_freq<=130),params.notch_low*local_max(local_freq<=130),4);
% %     polynom_high=polyfit(local_freq(local_freq>70),params.notch_high*local_max(local_freq>70),2);
% %     
% %     limit_line_low=zeros(size(f_axis));
% %     limit_line_high=zeros(size(f_axis));
% %     
% %     for k=1:length(polynom_low)
% %         limit_line_low=limit_line_low+polynom_low(k)*f_axis.^(length(polynom_low)-k);        
% %     end
% %     for k=1:length(polynom_high)
% %         limit_line_high=limit_line_high+polynom_high(k)*f_axis.^(length(polynom_high)-k);
% %     end
% %     limit_line=[limit_line_low(f_axis<=80) , max(limit_line_low(f_axis>80 & f_axis<=120),limit_line_high(f_axis>80 & f_axis<=120)) , limit_line_high(f_axis>120)];
% %     %adjust the fit
% %     limit_line=max(limit_line , min(norm_pxx)+prctile(norm_pxx(f_axis>=70),95)+std(norm_pxx(f_axis>=70)));
end
%find peaks (and charachteristics) of high intensity frequencies in the PSD vector
[~,locs,w,p]=findpeaks(norm_pxx,'WidthReference','halfheight');
%filter the unnatural frequencies to filter. (up to 6 frequencies)
idx=find(p>=limit_line(locs) & w>0 & w*df<params.notch_width & f_axis(locs)>=f_axis(1)+5 & f_axis(locs)<=f_axis(end)-5);
[~,I]=sort(p(idx)./limit_line(locs(idx)),'descend');
idx2=idx(I(1:min(4,length(I))));
locs=locs(idx2);
filter_freq=f_axis(locs);

%filter the data with a notch filter around each one of the unnatural
%frequencies
filtered_data=Data;
for num=1:length(locs)
    filtered_data=notch_egm_subfunction(filtered_data,Fs,filter_freq(num));
end

%figure results of the filtering process
filter_freq=sort(filter_freq);
if toplot
    time=(0:(length(Data)-1))/Fs;
    figure(7)
    subplot(2,1,1)
    if length(filter_freq)>=2
        plot(time,Data,time,filtered_data,'LineWidth',1)
        legend('raw','filtered')
        title_str='notch filtered data at ';
        for num=1:length(filter_freq)-1
            title_str=[title_str, num2str(filter_freq(num)) ', '];
        end
        title_str=[title_str(1:end-2),' and ' num2str(filter_freq(end)) ' Hz'];
    elseif length(filter_freq)==1
        plot(time,Data,time,filtered_data,'LineWidth',1)
        legend('raw','filtered')
        title_str=['notch filtered data at ' num2str(filter_freq(1)) ' Hz'];
    else
        plot(time,Data,'LineWidth',1)
        title_str='unfiltered data';
    end
    xlabel('Time(sec)')
    title(title_str)
    subplot(2,1,2)
    plot(f_axis,norm_pxx,local_freq,local_max,'m',f_axis,limit_line,'k','LineWidth',1.5)
    hold on
    plot(f_axis(locs),norm_pxx(locs),'+r')
    hold off
    title('normalized PSD')
    xlabel('Freq(Hz)')
end