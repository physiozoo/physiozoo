function filtered_sig=notch_egm_subfunction(sig,Fs,electricity_freq)
    
    if ~isempty(electricity_freq) && electricity_freq
        q=100; %quality factor of the filter

        w0=electricity_freq/(Fs/2);
        bw=w0/q;
        bw=1/(Fs/2);%bandwidth of 1 Hz
        [b,a]=iirnotch(w0,bw);

        filtered_sig=filtfilt(b,a,sig);
    else
        filtered_sig=sig;
    end