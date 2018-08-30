%%
    function plot_nonlinear_statistics_results(DATA, GUI, active_window)
        
        GUI = clear_nonlinear_statistics_results(GUI);
        
        plot_data = DATA.NonLinStat.PlotData{active_window};
        
        if ~isempty(plot_data)
            plot_dfa_fn(GUI.NonLinearAxes1, plot_data.dfa);
            plot_mse(GUI.NonLinearAxes3, plot_data.mse);
            plot_poincare_ellipse(GUI.NonLinearAxes2, plot_data.poincare);
        end
        box(GUI.NonLinearAxes1, 'off' );
        box(GUI.NonLinearAxes2, 'off' );
        box(GUI.NonLinearAxes3, 'off' );
        setAllowAxesZoom(DATA.zoom_handle, [GUI.NonLinearAxes1, GUI.NonLinearAxes2, GUI.NonLinearAxes3], false);
    end