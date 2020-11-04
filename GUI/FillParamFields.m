%%
function [GUI, param_keys_length, max_extent_control, handles_boxes] = FillParamFields(VBoxHandle, param_map, GUI, DATA, myUpBackgroundColor)

SmallFontSize = DATA.SmallFontSize;

param_keys = keys(param_map);
param_keys_length = length(param_keys);

text_fields_handles_cell = cell(1, param_keys_length);
handles_boxes = cell(4, param_keys_length);
for i = 1 : param_keys_length
    
    HBox = uix.HBox( 'Parent', VBoxHandle, 'Spacing', DATA.Spacing, 'BackgroundColor', myUpBackgroundColor);
    handles_boxes{1, i} = HBox;
    
    field_name = param_keys{i};
    
    current_field = param_map(field_name);
    current_field_value = current_field.value;
    handles_boxes{2, i} = current_field_value;
    
    symbol_field_name = current_field.name;
    
    symbol_field_name = strrep(symbol_field_name, 'Alpha1', sprintf('\x3b1\x2081')); % https://unicode-table.com/en/
    symbol_field_name = strrep(symbol_field_name, 'Alpha2', sprintf('\x3b1\x2082'));
    symbol_field_name = strrep(symbol_field_name, 'Beta', sprintf('\x3b2'));
    
    text_fields_handles_cell{i} = uicontrol( 'Style', 'text', 'Parent', HBox, 'String', symbol_field_name, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'TooltipString', current_field.description);
    
    if length(current_field_value) < 2
        current_value = num2str(current_field_value);
        param_control = uicontrol( 'Style', 'edit', 'Parent', HBox, 'FontSize', SmallFontSize, 'TooltipString', current_field.description);
        if strcmp(symbol_field_name, 'Spectral window length')
            GUI.SpectralWindowLengthHandle = param_control;
            set(param_control, 'String', calcDuration(current_field_value*60, 0), 'UserData', current_field_value*60);
        else
            set(param_control, 'String', current_value, 'UserData', current_value);
        end
            
        param_control.Tag = symbol_field_name;
        
        GUI.ConfigParamHandlesMap(field_name) = param_control;
        
    else
        field_name_min = [field_name '.min'];
        current_value = num2str(current_field_value(1));
        param_control1 = uicontrol( 'Style', 'edit', 'Parent', HBox, 'FontSize', SmallFontSize, 'TooltipString', current_field.description, 'Tag', field_name_min);
        
        set(param_control1, 'String', current_value, 'UserData', current_value);
        uicontrol( 'Style', 'text', 'Parent', HBox, 'String', '-', 'FontSize', SmallFontSize, 'TooltipString', current_field.description);
        field_name_max = [field_name '.max'];
        current_value = num2str(current_field_value(2));
        param_control2 = uicontrol( 'Style', 'edit', 'Parent', HBox, 'FontSize', SmallFontSize, 'TooltipString', current_field.description, 'Tag', field_name_max);
        
        set(param_control2, 'String', current_value, 'UserData', current_value);
                
        GUI.ConfigParamHandlesMap(field_name_min) = param_control1;
        GUI.ConfigParamHandlesMap(field_name_max) = param_control2;                
    end
    
    if strcmp(symbol_field_name, 'Spectral window length')
        uicontrol( 'Style', 'text', 'Parent', HBox, 'String', 'h:min:sec', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'TooltipString', current_field.description);
    else
        uicontrol( 'Style', 'text', 'Parent', HBox, 'String', current_field.units, 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'TooltipString', current_field.description);
    end
    
    if strcmp(symbol_field_name, 'LF Band')
%         uicontrol('Style', 'PushButton', 'Parent', HBox, 'Callback', @EstimateLFBand_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'E',...
%             'TooltipString', 'Click here to estimate the frequency bands based on the mammalian typical heart rate');
        handles_boxes{3, i} = true; % estimateBands
    else
        handles_boxes{3, i} = false;
    end
    if strcmp(symbol_field_name, 'PNN Threshold')
%         uicontrol('Style', 'PushButton', 'Parent', HBox, 'Callback', @EstimatePNNThreshold_pushbutton_Callback, 'FontSize', SmallFontSize, 'String', 'E',...
%             'TooltipString', 'Click here to estimate the pNNxx threshold based on the mammalian breathing rate');
        handles_boxes{4, i} = true; % estimatepNNxx
    else
        handles_boxes{4, i} = false;
    end
end

max_extent_control = calc_max_control_x_extend(text_fields_handles_cell);