function DATA = clearData(DATA)
        % All signal (Intervals)
        DATA.trr = [];
        DATA.rri = [];
        
        % All Filtered Signal (Intervals)
        DATA.tnn = [];
        DATA.nni = [];
        
        DATA.firstSecond2Show = 0;
        DATA.MyWindowSize = [];
        DATA.maxSignalLength = [];
        DATA.RRIntPage_Length = [];
        
        DATA.YLimUpperAxes.MaxYLimit = 0;
        DATA.YLimUpperAxes.HRMinYLimit = 0;
        DATA.YLimUpperAxes.HRMaxYLimit = [];
        DATA.YLimUpperAxes.RRMinYLimit = 0;
        DATA.YLimUpperAxes.RRMaxYLimit = [];
        
        DATA.YLimLowAxes.MaxYLimit = 0;
        DATA.YLimLowAxes.HRMinYLimit = 0;
        DATA.YLimLowAxes.HRMaxYLimit = [];
        DATA.YLimLowAxes.RRMinYLimit = 0;
        DATA.YLimLowAxes.RRMaxYLimit = [];
        
        DATA.Filt_MyDefaultWindowSize = 300; % sec
        DATA.Filt_MaxSignalLength = [];
        
        DATA.SamplingFrequency = [];
        
        DATA.QualityAnnotations_Data = [];
        
        DATA.FL_win_indexes = [];
        DATA.filt_FL_win_indexes = [];
        DATA.DataFileName = '';
        
        DATA.TimeStat.PlotData = [];
        DATA.FrStat.PlotData = [];
        DATA.NonLinStat.PlotData = [];
        
        DATA.timeData = [];
        DATA.timeRowsNames = [];
        DATA.timeDescriptions = [];
        
        DATA.fd_arData = [];
        DATA.fd_ArRowsNames = [];
        
        DATA.fd_welchData = [];
        DATA.fd_WelchRowsNames = [];
        
        DATA.nonlinData = [];
        DATA.nonlinRowsNames = [];
        DATA.nonlinDescriptions = [];
        
%         GUI.TimeParametersTableRowName = [];
%         GUI.FrequencyParametersTableMethodRowName = [];
%         GUI.NonLinearTableRowName = [];
        
        DATA.flag = '';
        
        DATA.freq_yscale = 'linear';
        
        DATA.active_window = 1;
        DATA.AutoYLimitUpperAxes = [];
        DATA.AutoYLimitLowAxes = [];
        
        DATA.Group.Path.AllDirs = [];  %Eugene 04.05.18
        DATA.Group.Path.AllExts = [];
        
        DATA.GroupsCalc = 0;
        
        DATA.custom_filters_thresholds = [];
        
        DATA.Action = 'move';
%         DATA.custom_config_params = containers.Map;
    end