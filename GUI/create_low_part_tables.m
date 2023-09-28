%%
function GUI = create_low_part_tables(GUI, Low_TabPanel, integration_level, Padding, Spacing, SmallFontSize, BigFontSize)

if strcmp(integration_level, '')
    PeaksTab = uix.Panel('Parent', Low_TabPanel, 'Padding', Padding);
    
    Low_Part_Box = uix.VBox('Parent', PeaksTab, 'Spacing', Spacing);    
    GUI.PeaksTable = uitable('Parent', Low_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{550 'auto'}, 'FontName', 'Calibri');
    GUI.PeaksTable.ColumnName = {'Description'; 'Values'};
    GUI.PeaksTable.RowName = {'NB PEAKS (n.u.)'; 'NB PEAKS ADD (n.u.)'; 'NB PEAKS RM (n.u.)'; 'PR BAD SQ (%)'};
    GUI.PeaksTable.Data = {''};
    GUI.PeaksTable.Data(1, 1) = {'Total number of peaks'};    % Number of peaks detected by the peak detection algorithm
    GUI.PeaksTable.Data(2, 1) = {'Number of peaks manually added by the user'}; % Number of peaks manually added by the user
    GUI.PeaksTable.Data(3, 1) = {'Number of peaks manually removed by the user'}; % Number of peaks manually removed by the user
    GUI.PeaksTable.Data(4, 1) = {['Percentage of the record annotated as bad quality (i.e. signal quality ' sprintf('\x2260') ' ''A'')']};
    GUI.PeaksTable.Data(:, 2) = {0};
    
    
    GUI.StatPanel1Tab = uix.Panel('Parent', Low_TabPanel, 'Padding', Padding);
    GUI.StatPanel2Tab = uix.Panel('Parent', Low_TabPanel, 'Padding', Padding);
    GUI.StatPanel3Tab = uix.Panel('Parent', Low_TabPanel, 'Padding', Padding);
%     GUI.StatPanel4Tab = uix.Panel('Parent', Low_TabPanel, 'Padding', Padding);
    
    Low_TabPanel.TabTitles = {'Peaks', 'Stat1', 'Stat2', 'Stat3'};
    Low_TabPanel.TabWidth = 150;
    Low_TabPanel.FontSize = BigFontSize;
    
elseif strcmp(integration_level, 'ECG')
    
%     PeaksTab = uix.Panel('Parent', Low_TabPanel, 'Padding', Padding);
%     RhythmsTab = uix.Panel('Parent', Low_TabPanel, 'Padding', Padding);
%     DurationTab = uix.Panel('Parent', Low_TabPanel, 'Padding', Padding);
%     AmplitudeTab = uix.Panel('Parent', Low_TabPanel, 'Padding', Padding);
    
    
%     Low_TabPanel.TabWidth = 100;
%     Low_TabPanel.FontSize = BigFontSize;
    
%     Low_Part_Box = uix.VBox('Parent', PeaksTab, 'Spacing', Spacing);
    
%     GUI.PeaksTable = uitable('Parent', Low_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{550 'auto'}, 'FontName', 'Calibri');
%     GUI.PeaksTable.ColumnName = {'Description'; 'Values'};
%     GUI.PeaksTable.RowName = {'NB PEAKS (n.u.)'; 'NB PEAKS ADD (n.u.)'; 'NB PEAKS RM (n.u.)'; 'PR BAD SQ (%)'};
%     GUI.PeaksTable.Data = {''};
%     GUI.PeaksTable.Data(1, 1) = {'Total number of peaks'};    % Number of peaks detected by the peak detection algorithm
%     GUI.PeaksTable.Data(2, 1) = {'Number of peaks manually added by the user'}; % Number of peaks manually added by the user
%     GUI.PeaksTable.Data(3, 1) = {'Number of peaks manually removed by the user'}; % Number of peaks manually removed by the user
%     GUI.PeaksTable.Data(4, 1) = {['Percentage of the record annotated as bad quality (i.e. signal quality ' sprintf('\x2260') ' ''A'')']};
%     GUI.PeaksTable.Data(:, 2) = {0};
    
    %--------------------------------------------------------------------------
    
    Rhythms_Part_Box = uix.VBox('Parent', GUI.StatPanel1Tab, 'Spacing', Spacing);
    GUI.RhythmsTable = uitable('Parent', Rhythms_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{250 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto'}, 'FontName', 'Calibri');
    GUI.RhythmsTable.ColumnName = {'Description'; 'Min (sec)'; 'Max (sec)'; 'Median (sec)'; 'Q1 (sec)'; 'Q3 (sec)'; 'Burden (%)'; 'Nb events'};
    GUI.RhythmsTable.Data = {};
    GUI.RhythmsTable.RowName = {};
    
    %--------------------------------------------------------------------------
    
    Amplitude_Part_Box = uix.VBox('Parent', GUI.StatPanel2Tab, 'Spacing', Spacing);
    GUI.AmplitudeTable = uitable('Parent', Amplitude_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{450 'auto' 'auto' 'auto' 'auto' 'auto' 'auto'}, 'FontName', 'Calibri');
    GUI.AmplitudeTable.ColumnName = {'Description'; 'Mean'; 'Median'; 'Min'; 'Max'; 'IQR'; 'STD'};
    GUI.AmplitudeTable.Data = {};
    GUI.AmplitudeTable.RowName = {};
    
    %--------------------------------------------------------------------------
    
    Duration_Part_Box = uix.VBox('Parent', GUI.StatPanel3Tab, 'Spacing', Spacing);
    GUI.DurationTable = uitable('Parent', Duration_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{350 'auto' 'auto' 'auto' 'auto' 'auto' 'auto'}, 'FontName', 'Calibri');
    GUI.DurationTable.ColumnName = {'Description'; 'Mean'; 'Median'; 'Min'; 'Max'; 'IQR'; 'STD'};
    GUI.DurationTable.Data = {};
    GUI.DurationTable.RowName = {};
    
    try
        delete(GUI.StatPanel4Tab)
    catch
    end
    
    
    Low_TabPanel.TabTitles = {'Peaks', 'Rhythms', 'Duration', 'Amplitude'};
        
elseif strcmp(integration_level, 'PPG')
    
    ColumnName = {'Description'; 'Mean'; 'Median'; 'STD'; 'Percentile 25'; 'Percentile 75'; 'IQR'; 'Skew'; 'Kurtosis'; 'Mad'};
    
    if length(GUI.Low_TabPanel.Children) == 4
        GUI.StatPanel4Tab = uix.Panel('Parent', Low_TabPanel, 'Padding', Padding);
    end
    
    PPGSig_Part_Box = uix.VBox('Parent', GUI.StatPanel1Tab, 'Spacing', Spacing);
    GUI.PPG_Signal_Table = uitable('Parent', PPGSig_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{350 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto'}, 'FontName', 'Calibri');
    GUI.PPG_Signal_Table.ColumnName = ColumnName; %{'Description'; 'Mean'; 'Median'; 'STD'; 'Percentile 25'; 'Percentile 75'; 'IQR'; 'Skew'; 'Kurtosis'; 'Mad'};
    GUI.PPG_Signal_Table.Data = {};
    GUI.PPG_Signal_Table.RowName = {};
    
    PPGDerivs_Part_Box = uix.VBox('Parent', GUI.StatPanel2Tab, 'Spacing', Spacing);
    GUI.PPG_Derivatives_Table = uitable('Parent', PPGDerivs_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{350 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto'}, 'FontName', 'Calibri');
    GUI.PPG_Derivatives_Table.ColumnName = ColumnName; %{'Description'; 'Mean'; 'Median'; 'STD'; 'Percentile 25'; 'Percentile 75'; 'IQR'; 'Skew'; 'Kurtosis'; 'Mad'};
    GUI.PPG_Derivatives_Table.Data = {};
    GUI.PPG_Derivatives_Table.RowName = {};
    
    SigRatios_Part_Box = uix.VBox('Parent', GUI.StatPanel3Tab, 'Spacing', Spacing);
    GUI.Signal_Ratios_Table = uitable('Parent', SigRatios_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{350 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto'}, 'FontName', 'Calibri');
    GUI.Signal_Ratios_Table.ColumnName = ColumnName; %{'Description'; 'Mean'; 'Median'; 'STD'; 'Percentile 25'; 'Percentile 75'; 'IQR'; 'Skew'; 'Kurtosis'; 'Mad'};
    GUI.Signal_Ratios_Table.Data = {};
    GUI.Signal_Ratios_Table.RowName = {};
    
    DerivsRatios_Part_Box = uix.VBox('Parent', GUI.StatPanel4Tab, 'Spacing', Spacing);
    GUI.Derivatives_Ratios_Table = uitable('Parent', DerivsRatios_Part_Box, 'FontSize', SmallFontSize, 'ColumnWidth',{350 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto'}, 'FontName', 'Calibri');
    GUI.Derivatives_Ratios_Table.ColumnName = ColumnName; %{'Description'; 'Mean'; 'Median'; 'STD'; 'Percentile 25'; 'Percentile 75'; 'IQR'; 'Skew'; 'Kurtosis'; 'Mad'};
    GUI.Derivatives_Ratios_Table.Data = {};
    GUI.Derivatives_Ratios_Table.RowName = {};
    
    Low_TabPanel.TabTitles = {'Peaks', 'PPG Signal', 'PPG Derivatives', 'Signal Ratios', 'Derivatives Ratios'};
    
else
    h_e = errordlg(['create_low_part_tables error - wrong integration level: ' e.message], 'Input Error');
    setLogo(h_e, 'M1');
    return;
end