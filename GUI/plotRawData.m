%%
    function [DATA, GUI] = plotRawData(DATA, GUI)
        ha = GUI.RRDataAxes;
        
        signal_time = DATA.trr;
        signal_data = DATA.rri;
        
        if (DATA.PlotHR == 0)
            data =  signal_data;
            yString = 'RR (sec)';
        else
            data =  60 ./ signal_data;
            yString = 'HR (BPM)';
        end
        
        GUI.raw_data_handle = plot(ha, signal_time, data, 'b-', 'LineWidth', 2, 'DisplayName', 'Time series');
        hold(ha, 'on');
        
        GUI.filtered_handle = line(ones(1, length(DATA.tnn))*NaN, ones(1, length(DATA.nni))*NaN, 'LineWidth', 1, 'Color', 'g', 'LineStyle', '-', 'DisplayName', 'Selected filtered time series', 'Parent', ha);
        
        xlabel(ha, 'Time (h:min:sec)');
        ylabel(ha, yString);
        
        DATA.legend_handle = legend(ha, 'show', 'Location', 'southeast', 'Orientation', 'horizontal');
        if sum(ismember(properties(DATA.legend_handle), 'AutoUpdate'))
            DATA.legend_handle.AutoUpdate = 'off';
            DATA.legend_handle.Box = 'off';
        end
        
        set(ha, 'XLim', [DATA.firstSecond2Show, DATA.firstSecond2Show + DATA.MyWindowSize]);
        
        setAllowAxesZoom(DATA.zoom_handle, GUI.RRDataAxes, false);
    end