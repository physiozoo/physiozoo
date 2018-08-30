%%
    function YLimAxes = setYAxesLim(DATA, axes_handle, AutoScaleY_checkbox, min_val_gui_handle, max_val_gui_handle, YLimAxes, AutoYLimitAxes)
        
        if get(AutoScaleY_checkbox, 'Value') == 1
            YLimAxes.RRMinYLimit = AutoYLimitAxes.RRMinYLimit;
            YLimAxes.RRMaxYLimit = AutoYLimitAxes.RRMaxYLimit;
            YLimAxes.HRMinYLimit = AutoYLimitAxes.HRMinYLimit;
            YLimAxes.HRMaxYLimit = AutoYLimitAxes.HRMaxYLimit;
        end
        
        if ~DATA.PlotHR %== 0
            MinYLimit = min(YLimAxes.RRMinYLimit, YLimAxes.RRMaxYLimit);
            MaxYLimit = max(YLimAxes.RRMinYLimit, YLimAxes.RRMaxYLimit);
        else
            MinYLimit = min(YLimAxes.HRMinYLimit, YLimAxes.HRMaxYLimit);
            MaxYLimit = max(YLimAxes.HRMinYLimit, YLimAxes.HRMaxYLimit);
        end
        
        set(min_val_gui_handle, 'String', num2str(MinYLimit));
        set(max_val_gui_handle, 'String', num2str(MaxYLimit));
        
        YLimAxes.MaxYLimit = MaxYLimit;
        YLimAxes.MinYLimit = MinYLimit;
        
        try
            set(axes_handle, 'YLim', [MinYLimit MaxYLimit]);
        catch
        end
    end