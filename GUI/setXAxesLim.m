%%
    function setXAxesLim(DATA, GUI)
        ha = GUI.RRDataAxes;
        
        set(ha, 'XLim', [DATA.firstSecond2Show DATA.firstSecond2Show + DATA.MyWindowSize]);
        setAxesXTicks(ha);
        
        blue_line_handle = get(GUI.all_data_handle);
        all_x = blue_line_handle.XData;
        
        window_size_in_data_points = size(find(all_x > DATA.firstSecond2Show & all_x < DATA.firstSecond2Show + DATA.MyWindowSize));
        
        if window_size_in_data_points < 350
            set(GUI.raw_data_handle, 'Marker', 'o', 'MarkerSize', 4, 'MarkerEdgeColor', [180 74 255]/255, 'MarkerFaceColor', [1, 1, 1]);
        else
            set(GUI.raw_data_handle, 'Marker', 'none');
        end
    end