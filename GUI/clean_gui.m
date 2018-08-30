function GUI = clean_gui(GUI)

set(GUI.SaveMeasures, 'Enable', 'off');

set(GUI.DataQualityMenu,'Enable', 'off');
set(GUI.SaveFiguresAsMenu,'Enable', 'off');
set(GUI.SaveParamFileMenu,'Enable', 'off');
set(GUI.LoadConfigFile, 'Enable', 'off');

GUI.Filt_RawDataSlider.Enable = 'off';

set(GUI.MinYLimitUpperAxes_Edit, 'String', '');
set(GUI.MaxYLimitUpperAxes_Edit, 'String', '');
set(GUI.WindowSize, 'String', '');
set(GUI.FirstSecond, 'String', '');
set(GUI.Active_Window_Length, 'String', '');
set(GUI.Active_Window_Start, 'String', '');
set(GUI.RRIntPage_Length, 'String', '');
set(GUI.MinYLimitLowAxes_Edit, 'String', '');
set(GUI.MaxYLimitLowAxes_Edit, 'String', '');

title(GUI.RRDataAxes, '');

set(GUI.RecordName_text, 'String', '');
set(GUI.RecordLength_text, 'String', '');
set(GUI.DataQuality_text, 'String', '');

set(GUI.freq_yscale_Button, 'String', 'Log');
set(GUI.freq_yscale_Button, 'Value', 1);

GUI.PageDownButton.Enable = 'off';
GUI.PageUpButton.Enable = 'on';
end