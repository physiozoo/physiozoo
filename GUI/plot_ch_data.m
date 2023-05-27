%%
function [RawData_lines_handle, ch_name_handles] = plot_ch_data(ECG_Axes_Array, tm, ch_data, names_array, GridX_checkbox, GridY_checkbox)

[~, ch_num] = size(ch_data);

RawData_lines_handle = gobjects(1, ch_num);
ch_name_handles = gobjects(1, ch_num); 

for i = 1 : ch_num
    curr_ch = ch_data(:, i);

    RawData_lines_handle(i) = line(tm, curr_ch, 'Parent', ECG_Axes_Array(i), 'Color', 'k');
                
    min_sig = min(curr_ch);
    max_sig = max(curr_ch);
    
    delta = (max_sig - min_sig)*0.1;
    
    min_y_lim = min_sig - delta;
    max_y_lim = max_sig + delta;
    
%     try
%         set(ECG_Axes_Array(i), 'YLim', [min_y_lim max_y_lim]);
%     catch e
%         disp(e.message);
%     end
    
    x_lim = ECG_Axes_Array(i).XLim;
    y_lim = ECG_Axes_Array(i).YLim;
    
    ch_name_handles(i) = text(ECG_Axes_Array(i), x_lim(1) + 0.1, y_lim(2) - 0.2, names_array{i}, 'FontSize', 11, 'FontName', 'Times New Roman');
        
%     axis(ECG_Axes_Array(i), 'equal');
%     set(ECG_Axes_Array(i), 'DataAspectRatio', [1 1 1]);
%     set(ECG_Axes_Array(i), 'PlotBoxAspectRatio', [1 1 1]);
     
    
    
    %     setXECGGrid(ECG_Axes_Array(i), GridX_checkbox);
    %     setYECGGrid(ECG_Axes_Array(i), GridY_checkbox);
    
    
    ECG_Axes_Array(i).XGrid = 'on';
    ECG_Axes_Array(i).YGrid = 'on';
    ECG_Axes_Array(i).XMinorGrid = 'on';
    ECG_Axes_Array(i).YMinorGrid = 'on';
    ECG_Axes_Array(i).GridColor = [1 0 0];
    ECG_Axes_Array(i).MinorGridColor = [1 0 0];
    ECG_Axes_Array(i).MinorGridLineStyle = ':';
    ECG_Axes_Array(i).GridAlpha = 0.5;
    
    %     xlabel(ECG_Axes_Array(i), '');
    %     ylabel(ECG_Axes_Array(i), '');
end

linkaxes(ECG_Axes_Array, 'x');

% Horizontal unit:
% the unwinding speed of the graph paper of 25 mm/sec
% five large square represents one second.
% a large square represents 0.2 seconds.
% there are 5 small squares in a large square.
% a small square represents 0.04 seconds.

% Vertical unit:
% 10mm represents 1mv.
% 2 large square represents 1mv.
% 1 large square represents 0.5mv.
% There are 5 small tiles in a large square.
% a small square represents 0.1mv.