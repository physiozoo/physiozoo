function qrs = run_qrsdet_by_seg(ecg,fs,thres,rp,ws)
% this function is used to run the qrs detector for each window (non-overlapping)
% this is usefull in the case of big artefacts which could bias the P&T threshold evaluation 
% or if the amplitude of the ecg is changing substantially over long recordings 
% (and so where adaptation of the energy threshold is useful).
%
% inputs
%   ecg: ecg signal (mV)
%   fs: sampling frequency (Hz)
%   ws: window size (sec)
%   thres: threshold to be used in the P&T algorithm(nu)
% 
% output
%   qrs:        qrs location in nb samples (ms)
%
% Joachim A. Behar, Technion-IIT, Israel, 2018


%= general
segsizeSamp = round(ws*fs); % convert window into nb of samples
NbSeg = floor(length(ecg)/segsizeSamp); % nb of segments
qrs = cell(NbSeg,1);

if NbSeg == 0
    NbSeg=1;
end
    
%= First subsegment
% first subsegment - look forward 1s
dTplus=round(fs);
dTminus=0;
start=1;
stop=segsizeSamp;

%= if no more data, don't look ahead
if NbSeg==1
    dTplus=0;
    stop=length(ecg);
end

% sign of peaks is determined by the sign on the
% first window and then is forced for the following windows.
qrs_temp=ptqrs(ecg(start-dTminus:stop+dTplus),fs,thres,rp,0);
qrs{1} = qrs_temp(:);

start = start+segsizeSamp;
stop = stop+segsizeSamp;

% for each segment perform qrs detection
for ch=2:NbSeg-1

    % take +/-1sec around selected subsegment exept for the borders. This
    % is in case there is a qrs in between segments -> allows to locate
    % them well.
    dTplus  = round(fs);
    dTminus = round(fs);

    qrs_temp=ptqrs(ecg(start-dTminus:stop+dTplus),fs,thres,rp,0);

    NewQRS = (start-1)-dTminus+qrs_temp;
    NewQRS(NewQRS>stop) = [];
    NewQRS(NewQRS<start) = [];

    if ~isempty(NewQRS) && ~isempty(qrs{ch-1})
        % this is needed to avoid multiple detection at the transition point
        NewQRS(NewQRS<qrs{ch-1}(end)) = [];
        if ~isempty(NewQRS) && (NewQRS(1)-qrs{ch-1}(end))<rp*fs
            % between two windows
            NewQRS(1) = [];
        end

    end
    qrs{ch} = NewQRS(:);

    start = start+segsizeSamp;
    stop = stop+segsizeSamp;
end

%JOs 24/02/15 check there is more than one segment otherwise
%PROBLEM...
if NbSeg>1
    % last subsegment
    ch = NbSeg;
    stop  = length(ecg);
    dTplus  = 0;
    dTminus = round(fs);
    qrs_temp=ptqrs(ecg(start-dTminus:stop+dTplus),fs,thres,rp,0);

    NewQRS = (start-1)-dTminus+qrs_temp;
    NewQRS(NewQRS>stop) = [];
    NewQRS(NewQRS<start) = [];

    if ~isempty(NewQRS) && ~isempty(qrs{ch-1})
        % this is needed to avoid multiple detection at the transition point
        NewQRS(NewQRS<qrs{ch-1}(end)) = [];
        if ~isempty(NewQRS) && (NewQRS(1)-qrs{ch-1}(end))<rp*fs
            % between two windows
            NewQRS(1) = [];
        end

    end
    qrs{ch} = NewQRS(:);
end

%= convert to double
qrs = vertcat(qrs{:});
qrs = qrs';

end
