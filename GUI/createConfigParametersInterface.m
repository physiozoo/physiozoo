%%
    function [DATA, GUI] = createConfigParametersInterface(DATA, GUI, myColors)
        
        gui_param = ReadYaml('gui_params.yml');
        gui_param_names = fieldnames(gui_param);
        param_struct = gui_param.(gui_param_names{1});
        param_name = fieldnames(param_struct);
        not_in_use_params_fr = param_struct.(param_name{1});
        not_in_use_params_mse = param_struct.(param_name{2});
        
        SmallFontSize = DATA.SmallFontSize;
        
        GUI.ConfigParamHandlesMap = containers.Map;
        
        defaults_map = mhrv_get_all_defaults();
        param_keys = keys(defaults_map);
        
        filtrr_keys = param_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'filtrr')), param_keys)));
        filt_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.range')), filtrr_keys)));
        ma_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.moving_average')), filtrr_keys)));
        quotient_range_keys = filtrr_keys(find(cellfun(@(x) ~isempty(regexpi(x, '\.quotient')), filtrr_keys)));
        
        filt_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), filt_range_keys))) = [];
        ma_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), ma_range_keys))) = [];
        quotient_range_keys(find(cellfun(@(x) ~isempty(regexpi(x, 'enable')), quotient_range_keys))) = [];
        
        DATA.filter_quotient = mhrv_get_default('filtrr.quotient.enable', 'value');
        DATA.filter_ma = mhrv_get_default('filtrr.moving_average.enable', 'value');
        DATA.filter_range = mhrv_get_default('filtrr.range.enable', 'value');
        
        DATA.default_filters_thresholds.moving_average.win_threshold = mhrv_get_default('filtrr.moving_average.win_threshold', 'value');
        DATA.default_filters_thresholds.moving_average.win_length = mhrv_get_default('filtrr.moving_average.win_length', 'value');
        DATA.default_filters_thresholds.quotient.rr_max_change = mhrv_get_default('filtrr.quotient.rr_max_change', 'value');
        DATA.default_filters_thresholds.range.rr_max = mhrv_get_default('filtrr.range.rr_max', 'value');
        DATA.default_filters_thresholds.range.rr_min = mhrv_get_default('filtrr.range.rr_min', 'value');        
        
        DATA.custom_filters_thresholds = DATA.default_filters_thresholds;
%         DATA.custom_config_params = defaults_map;
        
        if DATA.filter_ma && DATA.filter_range
            DATA.filter_index = 4;
        elseif ~DATA.filter_quotient && ~DATA.filter_ma && ~DATA.filter_range
            DATA.filter_index = 5;
        elseif DATA.filter_ma
            DATA.filter_index = 1;
        elseif DATA.filter_range
            DATA.filter_index = 2;
        elseif DATA.filter_quotient
            DATA.filter_index = 3;
        end
        GUI.Filtering_popupmenu.Value = DATA.filter_index;
        
        hrv_time_keys = param_keys((cellfun(@(x) ~isempty(regexpi(x, 'hrv_time')), param_keys))); % find
        hrv_freq_keys = param_keys((cellfun(@(x) ~isempty(regexpi(x, 'hrv_freq')), param_keys)));% find
        dfa_keys = param_keys((cellfun(@(x) ~isempty(regexpi(x, 'dfa')), param_keys))); % find
        mse_keys = param_keys((cellfun(@(x) ~isempty(regexpi(x, 'mse')), param_keys))); % find
        
        for i = 1 : length(not_in_use_params_fr)
            hrv_freq_keys((cellfun(@(x) ~isempty(regexpi(x, not_in_use_params_fr{i})), hrv_freq_keys))) = []; % find
        end
        for i = 1 : length(not_in_use_params_mse)
            mse_keys((cellfun(@(x) ~isempty(regexpi(x, not_in_use_params_mse{i})), mse_keys))) = [];
        end
        
        mse_keys((cellfun(@(x) ~isempty(regexpi(x, 'normalize_std')), mse_keys))) = [];
        
        max_extent_control = [];
        % Filtering Parameters
        clearParametersBox(GUI.FilteringParamBox);
        uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Range', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        [DATA, GUI, filt_range_keys_length, max_extent_control(1), handles_boxes_1] = FillParamFields(DATA, GUI, myColors, GUI.FilteringParamBox, containers.Map(filt_range_keys, values(defaults_map, filt_range_keys)));
        uix.Empty( 'Parent', GUI.FilteringParamBox );
        
        uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Moving average', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        [DATA, GUI, filt_ma_keys_length, max_extent_control(2), handles_boxes_2] = FillParamFields(DATA, GUI, myColors, GUI.FilteringParamBox, containers.Map(ma_range_keys, values(defaults_map, ma_range_keys)));
        uix.Empty( 'Parent', GUI.FilteringParamBox );
        
        uicontrol( 'Style', 'text', 'Parent', GUI.FilteringParamBox, 'String', 'Quotient', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        [DATA, GUI, filt_quotient_keys_length, max_extent_control(3), handles_boxes_3] = FillParamFields(DATA, GUI, myColors, GUI.FilteringParamBox, containers.Map(quotient_range_keys, values(defaults_map, quotient_range_keys)));
        uix.Empty( 'Parent', GUI.FilteringParamBox );
        
        max_extent = max(max_extent_control);
        
        setWidthsConfigParams(max_extent, handles_boxes_1);
        setWidthsConfigParams(max_extent, handles_boxes_2);
        setWidthsConfigParams(max_extent, handles_boxes_3);
        
        rs = 19; %-22;
        ts = 19; % -18
        es = 2;
        set( GUI.FilteringParamBox, 'Height', [ts, rs * ones(1, filt_range_keys_length), es, ts,  rs * ones(1, filt_ma_keys_length), es, ts,  rs * ones(1, filt_quotient_keys_length), -20]  );
        
        % Time Parameters
        clearParametersBox(GUI.TimeParamBox);
        uix.Empty( 'Parent', GUI.TimeParamBox );
        [DATA, GUI, time_keys_length, max_extent_control, handles_boxes] = FillParamFields(DATA, GUI, myColors, GUI.TimeParamBox, containers.Map(hrv_time_keys, values(defaults_map, hrv_time_keys)));
        uix.Empty( 'Parent', GUI.TimeParamBox );
        
        setWidthsConfigParams(max_extent_control, handles_boxes);
        
        rs = 19; %-10;
        ts = 19;
        set( GUI.TimeParamBox, 'Height', [ts, rs * ones(1, time_keys_length), -167]  );
        
        %-----------------------------------
        
        % Frequency Parameters
        clearParametersBox(GUI.FrequencyParamBox);
        uix.Empty( 'Parent', GUI.FrequencyParamBox );
        [DATA, GUI, freq_param_length, max_extent_control, handles_boxes] = FillParamFields(DATA, GUI, myColors, GUI.FrequencyParamBox, containers.Map(hrv_freq_keys, values(defaults_map, hrv_freq_keys)));
        uix.Empty( 'Parent', GUI.FrequencyParamBox );
        
        setWidthsConfigParams(max_extent_control, handles_boxes);
        
        GUI.WinAverage_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', GUI.FrequencyParamBox, 'Callback', @WinAverage_checkbox_Callback, 'FontSize', DATA.BigFontSize, ...
                                             'String', 'Use window average', 'Value', 0, 'Tooltip', 'Divide the signal into segments of size Spectral window length in order to compute the power spectrum and average across them');
        
        uix.Empty( 'Parent', GUI.FrequencyParamBox );
        rs = 19;
        set( GUI.FrequencyParamBox, 'Height', [-10, rs * ones(1, freq_param_length), -1, -10, -55]  );
        
        %-----------------------------------
        
        % NonLinear Parameters - DFA
        clearParametersBox(GUI.NonLinearParamBox);
        uicontrol( 'Style', 'text', 'Parent', GUI.NonLinearParamBox, 'String', 'Detrended Fluctuation Analysis (DFA)', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        [DATA, GUI, dfa_param_length, max_extent_control(1), handles_boxes_1] = FillParamFields(DATA, GUI, myColors, GUI.NonLinearParamBox, containers.Map(dfa_keys, values(defaults_map, dfa_keys)));
        
        % NonLinear Parameters - MSE
        uix.Empty( 'Parent', GUI.NonLinearParamBox );
        uicontrol( 'Style', 'text', 'Parent', GUI.NonLinearParamBox, 'String', 'Multi Scale Entropy (MSE)', 'FontSize', SmallFontSize, 'HorizontalAlignment', 'left', 'FontWeight', 'Bold');
        [DATA, GUI, mse_param_length, max_extent_control(2), handles_boxes_2] = FillParamFields(DATA, GUI, myColors, GUI.NonLinearParamBox, containers.Map(mse_keys, values(defaults_map, mse_keys)));
        
        uix.Empty( 'Parent', GUI.NonLinearParamBox );
        
        GUI.Normalize_STD_checkbox = uicontrol( 'Style', 'Checkbox', 'Parent', GUI.NonLinearParamBox, 'Callback', @Normalize_STD_checkbox_Callback, 'FontSize', DATA.BigFontSize, ...
            'String', defaults_map('mse.normalize_std').name, 'Value', defaults_map('mse.normalize_std').value, 'TooltipString', defaults_map('mse.normalize_std').description, 'Callback', @Normalize_STD_checkbox_Callback);
        
        uix.Empty( 'Parent', GUI.NonLinearParamBox );
        
        max_extent = max(max_extent_control);
        
        setWidthsConfigParams(max_extent, handles_boxes_1);
        setWidthsConfigParams(max_extent, handles_boxes_2);
        
        rs = 19; %-22;
        ts = 19; % -18
        es = 2; % -15
        
        set( GUI.NonLinearParamBox, 'Heights', [ts, rs * ones(1, dfa_param_length), es, ts,  rs * ones(1, mse_param_length), es, rs, -25] );
        
        set(findobj(GUI.FilteringParamBox,'Style', 'edit'), 'BackgroundColor', myColors.myEditTextColor);
        set(findobj(GUI.FilteringParamBox,'Style', 'text'), 'BackgroundColor', myColors.myUpBackgroundColor);
        
        set(findobj(GUI.TimeParamBox,'Style', 'edit'), 'BackgroundColor', myColors.myEditTextColor);
        set(findobj(GUI.TimeParamBox,'Style', 'text'), 'BackgroundColor', myColors.myUpBackgroundColor);
        set(findobj(GUI.TimeParamBox,'Style', 'PushButton'), 'BackgroundColor', myColors.myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
        
        set(findobj(GUI.FrequencyParamBox,'Style', 'edit'), 'BackgroundColor', myColors.myEditTextColor);
        set(findobj(GUI.FrequencyParamBox,'Style', 'text'), 'BackgroundColor', myColors.myUpBackgroundColor);
        set(findobj(GUI.FrequencyParamBox,'Style', 'PushButton'), 'BackgroundColor', myColors.myPushButtonColor, 'ForegroundColor', [1 1 1], 'FontWeight', 'bold');
        set(findobj(GUI.FrequencyParamBox,'Style', 'Checkbox'), 'BackgroundColor', myColors.myUpBackgroundColor);
        
        set(findobj(GUI.NonLinearParamBox,'Style', 'edit'), 'BackgroundColor', myColors.myEditTextColor);
        set(findobj(GUI.NonLinearParamBox,'Style', 'text'), 'BackgroundColor', myColors.myUpBackgroundColor);
        set(findobj(GUI.NonLinearParamBox,'Style', 'Checkbox'), 'BackgroundColor', myColors.myUpBackgroundColor);
    end