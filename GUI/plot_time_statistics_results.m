%%
    function plot_time_statistics_results(DATA, GUI, active_window)
        
        GUI = clear_time_statistics_results(GUI);
        plot_data = DATA.TimeStat.PlotData{active_window};
        
        if ~isempty(plot_data)
            plot_hrv_time_hist(GUI.TimeAxes1, plot_data, 'clear', true);
        end
        box(GUI.TimeAxes1, 'off' );
        setAllowAxesZoom(DATA.zoom_handle, GUI.TimeAxes1, false);
    end