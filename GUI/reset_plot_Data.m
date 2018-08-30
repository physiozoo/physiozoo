%%
    function [DATA, GUI] = reset_plot_Data(DATA, GUI)
        
        if ~isempty(DATA.rri)
            
            DATA = set_default_values(DATA);
            
            try
                % Only for calc min and max bounderies for plotting
                DATA = FiltSignal(DATA, 'filter_quotient', false, 'filter_ma', true, 'filter_range', false);
                
                DATA.filter_ma_nni = DATA.nni;
                DATA.filter_ma_tnn = DATA.tnn;
                
                DATA = setAutoYAxisLimUpperAxes(DATA, DATA.firstSecond2Show, DATA.MyWindowSize);
                
                if DATA.filter_index ~= 1 % Moving average
                    DATA = FiltSignal(DATA);
                end
                
                DATA.Filt_MaxSignalLength = DATA.tnn(end);
                
                DATA = set_default_analysis_params(DATA);
                
                DATA = setAutoYAxisLimLowAxes(DATA, [0 DATA.Filt_MaxSignalLength]);
                
                DATA.YLimUpperAxes.RRMinYLimit = DATA.AutoYLimitUpperAxes.RRMinYLimit;
                DATA.YLimUpperAxes.RRMaxYLimit = DATA.AutoYLimitUpperAxes.RRMaxYLimit;
                DATA.YLimUpperAxes.HRMinYLimit = DATA.AutoYLimitUpperAxes.HRMinYLimit;
                DATA.YLimUpperAxes.HRMaxYLimit = DATA.AutoYLimitUpperAxes.HRMaxYLimit;
                
                DATA.YLimUpperAxes.MaxYLimit = 0;
                DATA.YLimUpperAxes.MinYLimit = 0;
                
                DATA.YLimLowAxes.RRMinYLimit = DATA.AutoYLimitLowAxes.RRMinYLimit;
                DATA.YLimLowAxes.RRMaxYLimit = DATA.AutoYLimitLowAxes.RRMaxYLimit;
                DATA.YLimLowAxes.HRMinYLimit = DATA.AutoYLimitLowAxes.HRMinYLimit;
                DATA.YLimLowAxes.HRMaxYLimit = DATA.AutoYLimitLowAxes.HRMaxYLimit;
                DATA.YLimLowAxes.MaxYLimit = DATA.AutoYLimitLowAxes.MaxYLimit;
                DATA.YLimLowAxes.MinYLimit = DATA.AutoYLimitLowAxes.MinYLimit;
                
                GUI = clear_statistics_plots(GUI);
                [DATA, GUI] = clearStatTables(DATA, GUI);
                
                [DATA, GUI] = calcStatistics(DATA, GUI);
            catch e
                errordlg(['Reset Plot: ' e.message], 'Input Error');
            end
        end
    end % reset Data