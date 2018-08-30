%%
    function set_rectangles_YData(DATA, GUI)
        if isfield(GUI, 'red_rect')
            if ishandle(GUI.red_rect)
                set(GUI.red_rect, 'YData', [DATA.YLimLowAxes.MinYLimit DATA.YLimLowAxes.MinYLimit DATA.YLimLowAxes.MaxYLimit DATA.YLimLowAxes.MaxYLimit DATA.YLimLowAxes.MinYLimit]);
            end
        end
        if isfield(GUI, 'blue_line')
            if ishandle(GUI.blue_line)
                set(GUI.blue_line, 'YData', [DATA.YLimLowAxes.MinYLimit DATA.YLimLowAxes.MinYLimit DATA.YLimLowAxes.MaxYLimit DATA.YLimLowAxes.MaxYLimit]);
            end
        end
    end