%%
    function [DATA, GUI] = plotMultipleWindows(DATA, GUI)
        if isfield(DATA.AnalysisParams, 'winNum')
            batch_win_num = DATA.AnalysisParams.winNum;
            
            if batch_win_num > 0
                if isfield(GUI, 'rect_handle')
                    for i = 1 : length(GUI.rect_handle)
                        delete(GUI.rect_handle(i));
                    end
                end
                
                batch_window_start_time = DATA.AnalysisParams.segment_startTime;
                batch_window_length = DATA.AnalysisParams.activeWin_length;
                batch_overlap = DATA.AnalysisParams.segment_overlap/100;
                
                GUI.rect_handle = gobjects(batch_win_num, 1);
                f = [1 2 3 4];
                
                for i = 1 : batch_win_num
                    
                    v = [batch_window_start_time DATA.YLimUpperAxes.MinYLimit; batch_window_start_time + batch_window_length DATA.YLimUpperAxes.MinYLimit; batch_window_start_time + batch_window_length DATA.YLimUpperAxes.MaxYLimit; batch_window_start_time DATA.YLimUpperAxes.MaxYLimit];
                    
                    GUI.rect_handle(i) = patch('Faces' ,f, 'Vertices', v, 'FaceColor', DATA.rectangle_color, 'EdgeColor', DATA.rectangle_color, 'LineWidth', 0.5, 'FaceAlpha', 0.15, ...
                        'Parent', GUI.RRDataAxes, 'UserData', i);
                    
                    %                  GUI.rect_handle(i) = fill([batch_window_start_time batch_window_start_time batch_window_start_time + batch_window_length batch_window_start_time + batch_window_length], ...
                    %                     [DATA.MinYLimit DATA.MaxYLimit DATA.MaxYLimit DATA.MinYLimit], DATA.rectangle_color, 'LineWidth', 0.5, 'FaceAlpha', 0.15, 'Parent', GUI.RRDataAxes, ...
                    %                       'UserData', i); % 'ButtonDownFcn', @WindowButtonDownFcn_rect_handle, 'Tag', 'DoNotIgnore',
                    
                    if i == DATA.active_window
                        set(GUI.rect_handle(i), 'LineWidth', 2.5); % , 'FaceAlpha', 0.15
                        GUI.prev_act = GUI.rect_handle(i);
                    end
                    
                    batch_window_start_time = batch_window_start_time + (1-batch_overlap) * batch_window_length;
                end
                if isfield(GUI, 'RedLineHandle')
                    if isvalid(GUI.RedLineHandle)
                        uistack(GUI.RedLineHandle, 'top');
                    end
                end
            end
        end
    end