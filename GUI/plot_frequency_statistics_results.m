%%
    function plot_frequency_statistics_results(DATA, GUI, active_window)
        
        GUI = clear_frequency_statistics_results(GUI);
        
        plot_data = DATA.FrStat.PlotData{active_window};
        
        if ~isempty(plot_data)
            plot_hrv_freq_spectrum(GUI.FrequencyAxes1, plot_data, 'detailed_legend', false, 'yscale', DATA.freq_yscale);
            plot_hrv_freq_beta(GUI.FrequencyAxes2, plot_data);
        end
        box(GUI.FrequencyAxes1, 'off' );
        box(GUI.FrequencyAxes2, 'off' );
        setAllowAxesZoom(DATA.zoom_handle, GUI.FrequencyAxes2, false);
    end