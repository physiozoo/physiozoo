%%
    function plotFilteredData(DATA, GUI)
        if isfield(DATA.AnalysisParams, 'segment_startTime')
            Filt_time_data = DATA.tnn;
            Filt_data = DATA.nni;
            
            filt_win_indexes = find(Filt_time_data >= DATA.AnalysisParams.segment_startTime & Filt_time_data <= DATA.AnalysisParams.segment_effectiveEndTime);
            
            if ~isempty(filt_win_indexes)
                
                filt_signal_time = Filt_time_data(filt_win_indexes(1) : filt_win_indexes(end));
                filt_signal_data = Filt_data(filt_win_indexes(1) : filt_win_indexes(end));
                
                if (DATA.PlotHR == 0)
                    filt_data =  filt_signal_data;
                else
                    filt_data =  60 ./ filt_signal_data;
                end
                filt_data_time = ones(1, length(DATA.tnn))*NaN;
                filt_data_vector = ones(1, length(DATA.nni))*NaN;
                
                filt_data_time(filt_win_indexes) = filt_signal_time;
                filt_data_vector(filt_win_indexes) = filt_data;
                
                set(GUI.filtered_handle, 'XData', filt_data_time, 'YData', filt_data_vector);
            end
        end
    end