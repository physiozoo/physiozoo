%%
function [DATA, GUI] = createConfigParametersInterface_Oximetry(DATA, GUI, myColors)
% disp('Test');

SmallFontSize = DATA.SmallFontSize;

GUI.ConfigParamHandlesMap = containers.Map;
defaults_map = mhrv.defaults.mhrv_get_all_defaults();
param_keys = keys(defaults_map);

filtrr_keys = param_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'filtSpO2')), param_keys)));
filt_median_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.MedianSpO2')), filtrr_keys)));
% filt_resamp_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.ResampSpO2')), filtrr_keys)));
filt_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.RangeSpO2')), filtrr_keys)));

filt_block_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.BlockSpO2')), filtrr_keys)));
filt_dfilter_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.DFilterSpO2')), filtrr_keys)));


filt_median_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), filt_median_keys))) = [];
% filt_resamp_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), filt_resamp_keys))) = [];
filt_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), filt_range_keys))) = [];

filt_block_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), filt_block_keys))) = [];
filt_dfilter_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), filt_dfilter_keys))) = [];


DATA.filter_spo2_median = mhrv.defaults.mhrv_get_default('filtSpO2.MedianSpO2.enable', 'value');
% DATA.filter_spO2_resamp = mhrv.defaults.mhrv_get_default('filtSpO2.ResampSpO2.enable', 'value');
DATA.filter_spo2_range = mhrv.defaults.mhrv_get_default('filtSpO2.RangeSpO2.enable', 'value');

DATA.filter_spo2_block = mhrv.defaults.mhrv_get_default('filtSpO2.BlockSpO2.enable', 'value');
DATA.filter_spo2_dfilter = mhrv.defaults.mhrv_get_default('filtSpO2.DFilterSpO2.enable', 'value');


DATA.default_filters_thresholds.MedianSpO2.FilterLength = mhrv.defaults.mhrv_get_default('filtSpO2.MedianSpO2.FilterLength', 'value');
% DATA.default_filters_thresholds.ResampSpO2.Original_fs = mhrv.defaults.mhrv_get_default('filtSpO2.ResampSpO2.Original_fs', 'value');
DATA.default_filters_thresholds.RangeSpO2.Range_max = mhrv.defaults.mhrv_get_default('filtSpO2.RangeSpO2.Range_max', 'value');
DATA.default_filters_thresholds.RangeSpO2.Range_min = mhrv.defaults.mhrv_get_default('filtSpO2.RangeSpO2.Range_min', 'value');

DATA.default_filters_thresholds.BlockSpO2.Treshold = mhrv.defaults.mhrv_get_default('filtSpO2.BlockSpO2.Treshold', 'value');
DATA.default_filters_thresholds.DFilterSpO2.Diff = mhrv.defaults.mhrv_get_default('filtSpO2.DFilterSpO2.Diff', 'value');


DATA.custom_filters_thresholds = DATA.default_filters_thresholds;

GUI.Detrending_checkbox.Value = DATA.filter_spo2_median;

% Set GUI filter list value
%-----------------------------
if DATA.filter_spo2_range
    DATA.filter_index = 1;
% elseif DATA.filter_spo2_median
%     DATA.filter_index = 2;    
elseif DATA.filter_spo2_block
    DATA.filter_index = 2; 
elseif DATA.filter_spo2_dfilter
    DATA.filter_index = 3;
elseif ~DATA.filter_spo2_range && ~DATA.filter_spo2_median && ~DATA.filter_spo2_block && ~DATA.filter_spo2_dfilter
    DATA.filter_index = 4;    
end
GUI.Filtering_popupmenu.Value = DATA.filter_index;
%-----------------------------

general_spo2_keys = param_keys((cellfun(@(x) ~isempty(regexpi(x, 'OveralGeneralMeasures')), param_keys)));
desaturations_spo2_keys = param_keys((cellfun(@(x) ~isempty(regexpi(x, 'ODIMeasures')), param_keys)));
hypoxicBurden_spo2_keys = param_keys((cellfun(@(x) ~isempty(regexpi(x, 'HypoxicBurdenMeasures')), param_keys)));
complexity_spo2_keys = param_keys((cellfun(@(x) ~isempty(regexpi(x, 'ComplexityMeasures')), param_keys)));
periodicity_spo2_keys = param_keys((cellfun(@(x) ~isempty(regexpi(x, 'PeriodicityMeasures')), param_keys)));


desaturations_spo2_keys((cellfun(@(x) ~isempty(regexpi(x, 'Relative')), desaturations_spo2_keys))) = [];


max_extent_control = [];
% Filtering Parameters
clearParametersBox(GUI.FilteringParamBox);

uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Range', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
[GUI, filt_range_keys_length, max_extent_control(1), handles_boxes_1] = FillParamFields(GUI.FilteringParamBox, containers.Map(filt_range_keys, values(defaults_map, filt_range_keys)), GUI, DATA, myColors.myUpBackgroundColor);
uix.Empty('Parent', GUI.FilteringParamBox);

uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Median', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
[GUI, filt_median_keys_length, max_extent_control(2), handles_boxes_2] = FillParamFields(GUI.FilteringParamBox, containers.Map(filt_median_keys, values(defaults_map, filt_median_keys)), GUI, DATA, myColors.myUpBackgroundColor);
uix.Empty( 'Parent', GUI.FilteringParamBox );

uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Block', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
[GUI, filt_block_keys_length, max_extent_control(3), handles_boxes_3] = FillParamFields(GUI.FilteringParamBox, containers.Map(filt_block_keys, values(defaults_map, filt_block_keys)), GUI, DATA, myColors.myUpBackgroundColor);
uix.Empty( 'Parent', GUI.FilteringParamBox );

uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'DFilter', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
[GUI, filt_dfilter_keys_length, max_extent_control(4), handles_boxes_4] = FillParamFields(GUI.FilteringParamBox, containers.Map(filt_dfilter_keys, values(defaults_map, filt_dfilter_keys)), GUI, DATA, myColors.myUpBackgroundColor);
uix.Empty( 'Parent', GUI.FilteringParamBox );

% uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Resampling', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
% [GUI, filt_resamp_keys_length, max_extent_control(5), handles_boxes_5] = FillParamFields(GUI.FilteringParamBox, containers.Map(filt_resamp_keys, values(defaults_map, filt_resamp_keys)), GUI, DATA, myColors.myUpBackgroundColor);
% uix.Empty( 'Parent', GUI.FilteringParamBox );

% GUI.Detrending_checkbox.Value = defaults_map('filtSpO2.ResampSpO2.enable').value;

max_extent = max(max_extent_control);

setWidthsConfigParams(max_extent, handles_boxes_1);
setWidthsConfigParams(max_extent, handles_boxes_2);
setWidthsConfigParams(max_extent, handles_boxes_3);
setWidthsConfigParams(max_extent, handles_boxes_4);
% setWidthsConfigParams(max_extent, handles_boxes_5);

rs = 19; %-22;
ts = 19; % -18
es = 2;
set(GUI.FilteringParamBox, 'Height', ...
    [ts, rs * ones(1, filt_range_keys_length), es,...
    ts, rs * ones(1, filt_median_keys_length), es,...
    ts, rs * ones(1, filt_block_keys_length), es,...
    ts, rs * ones(1, filt_dfilter_keys_length), es]);


% Time Parameters
clearParametersBox(GUI.TimeParamBox);
uix.Empty( 'Parent', GUI.TimeParamBox );
[GUI, general_keys_length, max_extent_control, handles_boxes] = FillParamFields(GUI.TimeParamBox, containers.Map(general_spo2_keys, values(defaults_map, general_spo2_keys)), GUI, DATA, myColors.myUpBackgroundColor);
uix.Empty( 'Parent', GUI.TimeParamBox );

setWidthsConfigParams(max_extent_control, handles_boxes);

rs = 19; %-10;
ts = 19;
set(GUI.TimeParamBox, 'Height', [ts, rs * ones(1, general_keys_length), -1]  );

%-----------------------------------

% Frequency Parameters
clearParametersBox(GUI.FrequencyParamBox);
uix.Empty( 'Parent', GUI.FrequencyParamBox );
[GUI, desaturations_param_length, max_extent_control, handles_boxes] = FillParamFields(GUI.FrequencyParamBox, containers.Map(desaturations_spo2_keys, values(defaults_map, desaturations_spo2_keys)), GUI, DATA, myColors.myUpBackgroundColor);
uix.Empty( 'Parent', GUI.FrequencyParamBox );

GUI.Relativecheckbox = uicontrol( 'Style', 'Checkbox', 'Parent', GUI.FrequencyParamBox, 'FontSize', DATA.BigFontSize, ...
    'String', defaults_map('ODIMeasures.Relative').name, 'Value', defaults_map('ODIMeasures.Relative').value, 'TooltipString', defaults_map('ODIMeasures.Relative').description);

uix.Empty( 'Parent', GUI.FrequencyParamBox );


setWidthsConfigParams(max_extent_control, handles_boxes);

rs = 19;
ts = 19;
set(GUI.FrequencyParamBox, 'Height', [ts, rs * ones(1, desaturations_param_length), ts, ts, -1]);

%-----------------------------------
h_n = size(handles_boxes, 2);
for i = 1 : h_n
    if strcmp(handles_boxes{1, i}.Children(2).Tag, 'ODI Threshold')
        GUI.ODI_Threshold = handles_boxes{1, i}.Children(2);
    elseif strcmp(handles_boxes{1, i}.Children(2).Tag, 'Hard Threshold')
        GUI.Hard_Threshold = handles_boxes{1, i}.Children(2);
    elseif strcmp(handles_boxes{1, i}.Children(2).Tag, 'Max Length')
        GUI.Desat_Max_Length = handles_boxes{1, i}.Children(2);
    end
end

GUI.Hard_Threshold.Enable = 'of';
GUI.ODI_Threshold.Enable = 'on';
GUI.Desat_Max_Length.Enable = 'on';
%-----------------------------------

% NonLinear Parameters
clearParametersBox(GUI.NonLinearParamBox);
uix.Empty('Parent', GUI.NonLinearParamBox );
[GUI, hypoxicBurden_param_length, max_extent_control, handles_boxes] = FillParamFields(GUI.NonLinearParamBox, containers.Map(hypoxicBurden_spo2_keys, values(defaults_map, hypoxicBurden_spo2_keys)), GUI, DATA, myColors.myUpBackgroundColor);
uix.Empty('Parent', GUI.NonLinearParamBox );

setWidthsConfigParams(max_extent_control, handles_boxes);
rs = 19;
ts = 19;
set(GUI.NonLinearParamBox, 'Height', [ts, rs * ones(1, hypoxicBurden_param_length), -1]);
%-----------------------------------

% Complexity Parameters
clearParametersBox(GUI.ComplexityParamBox);
uix.Empty('Parent', GUI.ComplexityParamBox );
[GUI, complexity_param_length, max_extent_control, handles_boxes] = FillParamFields(GUI.ComplexityParamBox, containers.Map(complexity_spo2_keys, values(defaults_map, complexity_spo2_keys)), GUI, DATA, myColors.myUpBackgroundColor);
uix.Empty('Parent', GUI.ComplexityParamBox );

setWidthsConfigParams(max_extent_control, handles_boxes);
rs = 19;
ts = 19;
set(GUI.ComplexityParamBox, 'Height', [ts, rs * ones(1, complexity_param_length), -1]);
%-----------------------------------

% Periodicity Parameters
clearParametersBox(GUI.PeriodicityParamBox);
uix.Empty('Parent', GUI.PeriodicityParamBox );
[GUI, periodicity_param_length, max_extent_control, handles_boxes] = FillParamFields(GUI.PeriodicityParamBox, containers.Map(periodicity_spo2_keys, values(defaults_map, periodicity_spo2_keys)), GUI, DATA, myColors.myUpBackgroundColor);
uix.Empty('Parent', GUI.PeriodicityParamBox );

setWidthsConfigParams(max_extent_control, handles_boxes);
rs = 19;
ts = 19;
set(GUI.PeriodicityParamBox, 'Height', [ts, rs * ones(1, periodicity_param_length), -1]);

%-----------------------------------
set(findobj(GUI.FilteringParamBox, 'Style', 'edit'), 'BackgroundColor', myColors.myEditTextColor);
set(findobj(GUI.FilteringParamBox, 'Style', 'text'), 'BackgroundColor', myColors.myUpBackgroundColor);

set(findobj(GUI.TimeParamBox, 'Style', 'edit'), 'BackgroundColor', myColors.myEditTextColor);
set(findobj(GUI.TimeParamBox, 'Style', 'text'), 'BackgroundColor', myColors.myUpBackgroundColor);

set(findobj(GUI.FrequencyParamBox, 'Style', 'edit'), 'BackgroundColor', myColors.myEditTextColor);
set(findobj(GUI.FrequencyParamBox, 'Style', 'text'), 'BackgroundColor', myColors.myUpBackgroundColor);
set(findobj(GUI.FrequencyParamBox, 'Style', 'Checkbox'), 'BackgroundColor', myColors.myUpBackgroundColor);

set(findobj(GUI.NonLinearParamBox, 'Style', 'edit'), 'BackgroundColor', myColors.myEditTextColor);
set(findobj(GUI.NonLinearParamBox, 'Style', 'text'), 'BackgroundColor', myColors.myUpBackgroundColor);

set(findobj(GUI.ComplexityParamBox, 'Style', 'edit'), 'BackgroundColor', myColors.myEditTextColor);
set(findobj(GUI.ComplexityParamBox, 'Style', 'text'), 'BackgroundColor', myColors.myUpBackgroundColor);

set(findobj(GUI.PeriodicityParamBox, 'Style', 'edit'), 'BackgroundColor', myColors.myEditTextColor);
set(findobj(GUI.PeriodicityParamBox, 'Style', 'text'), 'BackgroundColor', myColors.myUpBackgroundColor);

