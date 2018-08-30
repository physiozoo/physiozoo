%%
    function GUI = EnablePageUpDown(DATA, GUI)
        xdata = get(GUI.red_rect, 'XData');
        
        if ~isempty(xdata)
            if xdata(2) == DATA.maxSignalLength
                GUI.PageUpButton.Enable = 'off';
            else
                GUI.PageUpButton.Enable = 'on';
            end
            if xdata(1) == 0
                GUI.PageDownButton.Enable = 'off';
            else
                GUI.PageDownButton.Enable = 'on';
            end
        end
    end