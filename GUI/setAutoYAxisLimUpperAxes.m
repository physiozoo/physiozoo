%%
    function DATA = setAutoYAxisLimUpperAxes(DATA, firstSecond2Show, WindowSize)
        
        signal_data = DATA.rri(DATA.trr >= firstSecond2Show & DATA.trr <= firstSecond2Show + WindowSize);
        filt_signal_data = DATA.nni(DATA.tnn >= firstSecond2Show & DATA.tnn <= firstSecond2Show + WindowSize);
        
        if ~isempty(signal_data) && ~isempty(filt_signal_data)
            
            if length(signal_data) == length(filt_signal_data)
                DATA.AutoYLimitUpperAxes.RRMinYLimit = min(min(signal_data), max(signal_data));
                DATA.AutoYLimitUpperAxes.RRMaxYLimit = max(min(signal_data), max(signal_data));
                
                max_rri_60 = max(60 ./ signal_data);
                min_rri_60 = min(60 ./ signal_data);
                DATA.AutoYLimitUpperAxes.HRMinYLimit = min(min_rri_60, max_rri_60);
                DATA.AutoYLimitUpperAxes.HRMaxYLimit = max(min_rri_60, max_rri_60);
            else
                max_nni = max(filt_signal_data);
                min_nni = min(filt_signal_data);
                delta = (max_nni - min_nni)*1;
                
                DATA.AutoYLimitUpperAxes.RRMinYLimit = min(min_nni, max_nni) - delta;
                DATA.AutoYLimitUpperAxes.RRMaxYLimit = max(min_nni, max_nni) + delta;
                
                max_nni_60 = max(60 ./ filt_signal_data);
                min_nni_60 = min(60 ./ filt_signal_data);
                delta_60 = (max_nni_60 - min_nni_60)*1;
                
                DATA.AutoYLimitUpperAxes.HRMinYLimit = min(min_nni_60, max_nni_60) - delta_60;
                DATA.AutoYLimitUpperAxes.HRMaxYLimit = max(min_nni_60, max_nni_60) + delta_60;
            end
            
            if ~DATA.PlotHR % == 0
                MinYLimit = DATA.AutoYLimitUpperAxes.RRMinYLimit;
                MaxYLimit = DATA.AutoYLimitUpperAxes.RRMaxYLimit;
            else
                MinYLimit = DATA.AutoYLimitUpperAxes.HRMinYLimit;
                MaxYLimit = DATA.AutoYLimitUpperAxes.HRMaxYLimit;
            end
            DATA.AutoYLimitUpperAxes.MaxYLimit = MaxYLimit;
            DATA.AutoYLimitUpperAxes.MinYLimit = MinYLimit;
        end
    end