%%
function setWidthsConfigParams(max_extent_control, handles_boxes)
handles_boxes_size = size(handles_boxes);
fields_size = [max_extent_control + 2, 125, -1];
for j = 1 : handles_boxes_size(2)
    if  handles_boxes{4, j} % estimatepNNxx
        set(handles_boxes{1, j}, 'Widths', [max_extent_control + 2, 125, 30, 20]);
    elseif handles_boxes{3, j}
        set(handles_boxes{1, j}, 'Widths', [max_extent_control + 2, 58, 5, 56, 20, 20]);
    elseif length(handles_boxes{2, j}) < 2
        set(handles_boxes{1, j}, 'Widths', fields_size);
    else
        set(handles_boxes{1, j}, 'Widths', [max_extent_control + 2, 58, 5, 56, -1]);
    end
end