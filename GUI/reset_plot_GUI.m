%%
    function [DATA, GUI] = reset_plot_GUI(DATA, GUI)
        
        if ~isempty(DATA.rri)
            
            set(GUI.AutoScaleYUpperAxes_checkbox, 'Value', 1);
            set(GUI.AutoScaleYLowAxes_checkbox, 'Value', 1);
            
            set(GUI.ShowLegend_checkbox, 'Value', 1);
            set(GUI.AutoCalc_checkbox, 'Value', 1);
            GUI.AutoCompute_pushbutton.Enable = 'off';
            GUI.WinAverage_checkbox.Value = 0;
            
            GUI.DefaultMethod_popupmenu.Value = DATA.default_frequency_method_index;
            
            if DATA.MyWindowSize == DATA.maxSignalLength
                enable_slider = 'off';
                set(GUI.FirstSecond, 'Enable', 'off');
            else
                enable_slider = 'on';
                set(GUI.FirstSecond, 'Enable', 'on');
            end
            
            GUI.FilteringLevel_popupmenu.Enable = 'on';
            
            GUI.FilteringLevel_popupmenu.String = DATA.FilterLevel;
            set(GUI.FilteringLevel_popupmenu, 'Value', DATA.default_filter_level_index);
            
            setSliderProperties(GUI.RawDataSlider, DATA.maxSignalLength, DATA.MyWindowSize, 0.1);
            GUI.RawDataSlider.Enable = enable_slider;
            
            try
                set(GUI.freq_yscale_Button, 'String', 'Log');
                set(GUI.freq_yscale_Button, 'Value', 1);
                
                set(GUI.segment_startTime, 'String', calcDuration(DATA.DEFAULT_AnalysisParams.segment_startTime, 0));
                set(GUI.segment_endTime, 'String', calcDuration(DATA.DEFAULT_AnalysisParams.segment_endTime, 0));
                set(GUI.activeWindow_length, 'String', calcDuration(DATA.DEFAULT_AnalysisParams.activeWin_length, 0));
                set(GUI.segment_overlap, 'String', num2str(DATA.DEFAULT_AnalysisParams.segment_overlap));
                set(GUI.segment_winNum, 'String', num2str(DATA.DEFAULT_AnalysisParams.winNum));
                set(GUI.active_winNum, 'String', '1');
                
                if isfield(DATA, 'legend_handle') && ishandle(DATA.legend_handle) && isvalid(DATA.legend_handle)
                    delete(DATA.legend_handle);
                end
                
                cla(GUI.RRDataAxes);
                cla(GUI.AllDataAxes);
                
                [DATA, GUI] = plotAllData(DATA, GUI);
                [DATA, GUI] = plotRawData(DATA, GUI);
                setXAxesLim(DATA, GUI);
                
                DATA.YLimUpperAxes = setYAxesLim(DATA, GUI.RRDataAxes, GUI.AutoScaleYUpperAxes_checkbox, GUI.MinYLimitUpperAxes_Edit, GUI.MaxYLimitUpperAxes_Edit, DATA.YLimUpperAxes, DATA.AutoYLimitUpperAxes);
                DATA.YLimLowAxes = setYAxesLim(DATA, GUI.AllDataAxes, GUI.AutoScaleYLowAxes_checkbox, GUI.MinYLimitLowAxes_Edit, GUI.MaxYLimitLowAxes_Edit, DATA.YLimLowAxes, DATA.AutoYLimitLowAxes);
                
                set_rectangles_YData(DATA, GUI);
                
                plotFilteredData(DATA, GUI);
                [DATA, GUI] = plotDataQuality(DATA, GUI);
                [DATA, GUI] = plotMultipleWindows(DATA, GUI);
                
                setSliderProperties(GUI.Filt_RawDataSlider, DATA.Filt_MaxSignalLength, DATA.AnalysisParams.activeWin_length, DATA.AnalysisParams.activeWin_length/DATA.Filt_MaxSignalLength);
                
                set(GUI.Filt_RawDataSlider, 'Enable', 'on');
                set(GUI.Active_Window_Length, 'String', calcDuration(DATA.AnalysisParams.activeWin_length, 0));
                
                set(GUI.MinYLimitUpperAxes_Edit, 'String', num2str(DATA.AutoYLimitUpperAxes.RRMinYLimit));
                set(GUI.MaxYLimitUpperAxes_Edit, 'String', num2str(DATA.AutoYLimitUpperAxes.RRMaxYLimit));
                
                set(GUI.MinYLimitLowAxes_Edit, 'String', num2str(DATA.AutoYLimitLowAxes.RRMinYLimit));
                set(GUI.MaxYLimitLowAxes_Edit, 'String', num2str(DATA.AutoYLimitLowAxes.RRMaxYLimit));
                
                set(GUI.WindowSize, 'String', calcDuration(DATA.MyWindowSize, 0));
                set(GUI.RecordLength_text, 'String', [calcDuration(DATA.maxSignalLength, 1) '    h:min:sec.msec']);
                set(GUI.RR_or_HR_plot_button, 'Enable', 'on', 'Value', 0, 'String', 'Plot HR');
                set(GUI.FirstSecond, 'String', calcDuration(DATA.firstSecond2Show, 0)); % , 'Enable', 'off'
                set(GUI.RRIntPage_Length, 'String', calcDuration(DATA.RRIntPage_Length, 0));
                
                XData_active_window = get(GUI.rect_handle(1), 'XData');
                set(GUI.Active_Window_Start, 'String', calcDuration(XData_active_window(1), 0));
                
                if(DATA.AnalysisParams.activeWin_length >= DATA.Filt_MaxSignalLength)
                    set(GUI.Filt_RawDataSlider, 'Enable', 'off');
                else
                    set(GUI.Active_Window_Start, 'Enable', 'on');
                    set(GUI.Filt_RawDataSlider, 'Enable', 'on');
                end
                GUI.StatisticsTable.ColumnName = {'Description'; 'Values'};
                
                set(GUI.Active_Window_Length, 'Enable', 'on');
                if isfield(GUI, 'SpectralWindowLengthHandle') && isvalid(GUI.SpectralWindowLengthHandle)
                    GUI.SpectralWindowLengthHandle.Enable = 'off';
                end
            catch e
                errordlg(['Reset Plot: ' e.message], 'Input Error');
            end
        end
    end % reset GUI