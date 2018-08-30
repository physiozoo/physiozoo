%%
    function [DATA, GUI] = plotAllData(DATA, GUI)
        ha = GUI.AllDataAxes;
        if ~DATA.PlotHR  % == 0
            data =  DATA.rri;
        else
            data =  60 ./ DATA.rri;
        end
        
        GUI.all_data_handle = line(DATA.trr, data, 'Color', 'b', 'LineWidth', 1.5, 'Parent', ha, 'DisplayName', 'Hole time series'); % , 'Tag', 'DoNotIgnore', 'ButtonDownFcn', {@my_clickOnAllData, 'aa'}
        
        set(ha, 'XLim', [0 DATA.RRIntPage_Length]);
        
        % PLot red rectangle
        ylim = get(ha, 'YLim');
        x_box = [0 DATA.MyWindowSize DATA.MyWindowSize 0 0];
        y_box = [ylim(1) ylim(1) ylim(2) ylim(2) ylim(1)];
        
        if isfield(GUI, 'red_rect')
            delete(GUI.red_rect);
            GUI = rmfield(GUI, 'red_rect');
        end
        
        if isfield(GUI, 'blue_line')
            delete(GUI.blue_line);
            GUI = rmfield(GUI, 'blue_line');
        end
        
        x_segment_start = DATA.AnalysisParams.segment_startTime;
        x_segment_stop = DATA.AnalysisParams.segment_effectiveEndTime;
        y_segment_start = ylim(1);
        y_segment_stop = ylim(2);
        
        v = [x_segment_start y_segment_start; x_segment_stop y_segment_start; x_segment_stop y_segment_stop; x_segment_start y_segment_stop];
        f = [1 2 3 4];
        
        GUI.blue_line = patch('Faces', f, 'Vertices', v, 'FaceColor', DATA.rectangle_color, 'EdgeColor', DATA.rectangle_color, 'LineWidth', 2, 'FaceAlpha', 0.3, 'EdgeAlpha', 0.9, 'Parent', ha); % , 'Marker', '^', 'MarkerSize', 7, 'MarkerFaceColor', DATA.rectangle_color, 'Linewidth', 2
        
        setAxesXTicks(ha);
        
        GUI.red_rect = line(x_box, y_box, 'Color', 'r', 'Linewidth', 3, 'Parent', ha);
        
        setAllowAxesZoom(DATA.zoom_handle, GUI.AllDataAxes, false);
    end