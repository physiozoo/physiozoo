%%
    function DATA = set_default_analysis_params(DATA)
        DATA.DEFAULT_AnalysisParams.segment_startTime = 0;
        DATA.DEFAULT_AnalysisParams.activeWin_startTime = 0;
        DATA.DEFAULT_AnalysisParams.segment_endTime = DATA.Filt_MyDefaultWindowSize; % DATA.Filt_MaxSignalLength
        DATA.DEFAULT_AnalysisParams.segment_effectiveEndTime = DATA.DEFAULT_AnalysisParams.segment_endTime;
        DATA.DEFAULT_AnalysisParams.activeWin_length = min(DATA.Filt_MaxSignalLength, DATA.Filt_MyDefaultWindowSize);
        DATA.DEFAULT_AnalysisParams.segment_overlap = 0;
        DATA.DEFAULT_AnalysisParams.winNum = 1;
        DATA.active_window = 1;
        
        DATA.AnalysisParams = DATA.DEFAULT_AnalysisParams;
    end