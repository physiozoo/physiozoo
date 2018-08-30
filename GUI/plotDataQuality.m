%%
    function [DATA, GUI] = plotDataQuality(DATA, GUI)
        if ~isempty(DATA.QualityAnnotations_Data)
            if ~isempty(DATA.rri)
                ha = GUI.RRDataAxes;
                MaxYLimit = DATA.YLimUpperAxes.MaxYLimit;
                time_data = DATA.trr;
                data = DATA.rri;
                
                qd_size = size(DATA.QualityAnnotations_Data);
                intervals_num = qd_size(1);
                
                if (DATA.PlotHR == 1)
                    data = 60 ./ data;
                end
                
                if ~isfield(GUI, 'GreenLineHandle') || ~isvalid(GUI.GreenLineHandle)
                    GUI.GreenLineHandle = line([DATA.firstSecond2Show DATA.firstSecond2Show + DATA.MyWindowSize], [MaxYLimit MaxYLimit], 'Color', DATA.MyGreen, 'LineWidth', 3, 'Parent', ha);
                else
                    GUI.GreenLineHandle.XData = [DATA.firstSecond2Show DATA.firstSecond2Show + DATA.MyWindowSize];
                    GUI.GreenLineHandle.YData = [MaxYLimit MaxYLimit];
                end
                uistack(GUI.GreenLineHandle, 'down')
                %---------------------------------
                
                if ~(DATA.QualityAnnotations_Data(1, 1) + DATA.QualityAnnotations_Data(1,2))==0
                    
                    if ~isfield(GUI, 'RedLineHandle') || ~isvalid(GUI.RedLineHandle(1))
%                         GUI.RedLineHandle = line((DATA.QualityAnnotations_Data-time_data(1))', [MaxYLimit MaxYLimit]', 'Color', 'red', 'LineWidth', 3, 'Parent', ha);
                        GUI.RedLineHandle = line((DATA.QualityAnnotations_Data)', [MaxYLimit MaxYLimit]', 'Color', 'red', 'LineWidth', 3, 'Parent', ha);
                        uistack(GUI.RedLineHandle, 'top');
                    else
                        for i = 1 : intervals_num
                            GUI.RedLineHandle(i).XData = (DATA.QualityAnnotations_Data(i, :))';
                            GUI.RedLineHandle(i).YData = [MaxYLimit MaxYLimit]';
                        end
                    end
                    
                    for i = 1 : intervals_num
                        a1=find(time_data >= DATA.QualityAnnotations_Data(i,1));
                        a2=find(time_data <= DATA.QualityAnnotations_Data(i,2));
                        
                        if isempty(a2); a2 = 1; end % case where the bad quality starts before the first annotated peak
                        if isempty(a1); a1 = length(time_data); end
                        if length(a1)<2
                            low_quality_indexes = [a2(end) : a1(1)];
                        elseif a2(end) == 1
                            low_quality_indexes = [1 : a1(1)];
                        elseif a2(end) < a1(1)
                            low_quality_indexes = [a2(end)-1 : a1(1)];
                        else
                            low_quality_indexes = [a1(1)-1 : a2(end)+1];
                        end
                        
                        if ~isempty(low_quality_indexes)
                            GUI.PinkLineHandle(i) = line(time_data(low_quality_indexes), data(low_quality_indexes), 'LineStyle', '-', 'Color', [255 157 189]/255, 'LineWidth', 2.5, 'Parent', ha);
                            if isvalid(DATA.legend_handle) && length(DATA.legend_handle.String) < 3 %
                                legend([GUI.raw_data_handle, GUI.filtered_handle GUI.PinkLineHandle(1)], [DATA.legend_handle.String 'Bad quality']);
                            end
                        end
                    end
                end
            end
        end
        setAllowAxesZoom(DATA.zoom_handle, GUI.RRDataAxes, false);
    end