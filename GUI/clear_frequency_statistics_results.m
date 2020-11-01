%%
function clear_frequency_statistics_results(GUI)

grid(GUI.FrequencyAxes1, 'off');
grid(GUI.FrequencyAxes2, 'off');
legend(GUI.FrequencyAxes1, 'off');
legend(GUI.FrequencyAxes2, 'off');
cla(GUI.FrequencyAxes1);
cla(GUI.FrequencyAxes2);
GUI.FrequencyAxes1.Visible = 'off';
GUI.FrequencyAxes2.Visible = 'off';
xlim(GUI.FrequencyAxes1, 'auto');
