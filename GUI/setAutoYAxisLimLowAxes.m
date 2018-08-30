%%
    function DATA = setAutoYAxisLimLowAxes(DATA, axes_xlim)
        filt_signal_data = DATA.filter_ma_nni(DATA.filter_ma_tnn >= min(axes_xlim) & DATA.filter_ma_tnn <= max(axes_xlim));
        if ~isempty(filt_signal_data)
            max_nni = max(filt_signal_data);
            min_nni = min(filt_signal_data);
            delta = (max_nni - min_nni) * 0.1;
            
            max_nni_60 = max(60 ./ filt_signal_data);
            min_nni_60 = min(60 ./ filt_signal_data);
            delta_60 = (max_nni_60 - min_nni_60) * 0.1;
            
            DATA.AutoYLimitLowAxes.RRMinYLimit = min(min_nni, max_nni) - delta;
            DATA.AutoYLimitLowAxes.RRMaxYLimit = max(min_nni, max_nni) + delta;
            
            DATA.AutoYLimitLowAxes.HRMinYLimit = min(min_nni_60, max_nni_60) - delta_60;
            DATA.AutoYLimitLowAxes.HRMaxYLimit = max(min_nni_60, max_nni_60) + delta_60;
            
            if ~DATA.PlotHR %== 0
                DATA.AutoYLimitLowAxes.MinYLimit = DATA.AutoYLimitLowAxes.RRMinYLimit;
                DATA.AutoYLimitLowAxes.MaxYLimit = DATA.AutoYLimitLowAxes.RRMaxYLimit;
            else
                DATA.AutoYLimitLowAxes.MinYLimit = DATA.AutoYLimitLowAxes.HRMinYLimit;
                DATA.AutoYLimitLowAxes.MaxYLimit = DATA.AutoYLimitLowAxes.HRMaxYLimit;
            end
        end
    end