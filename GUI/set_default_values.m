%%
    function DATA = set_default_values(DATA)
        if ~isempty(DATA.rri)
            DATA.default_frequency_method_index = 1;
            
            DATA.prev_point = 0;
            DATA.prev_point_segment = 0;
            DATA.prev_point_blue_line = 0;
            DATA.doCalc = false;
            
            %             trr = DATA.trr;
            DATA.maxSignalLength = DATA.trr(end);
            DATA.RRIntPage_Length = DATA.maxSignalLength;
            
            DATA.Filt_MyDefaultWindowSize = mhrv_get_default('hrv_freq.window_minutes', 'value') * 60; % min to sec
            
            DATA.PlotHR = 0;
            DATA.firstSecond2Show = 0;
            % Show only 6*hrv_freq.window_minutes portion of the raw data
            DATA.MyWindowSize = min(3 * DATA.Filt_MyDefaultWindowSize, DATA.maxSignalLength); % 6
            
            DATA.filter_level_index = DATA.default_filter_level_index;
            
            DATA.WinAverage = 0;
            
            DATA.freq_yscale = 'linear';
        end
    end