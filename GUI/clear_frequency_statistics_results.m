function GUI = clear_frequency_statistics_results(GUI)
grid(GUI.FrequencyAxes1, 'off');
grid(GUI.FrequencyAxes2, 'off');
legend(GUI.FrequencyAxes1, 'off');
legend(GUI.FrequencyAxes2, 'off');
cla(GUI.FrequencyAxes1);
cla(GUI.FrequencyAxes2);
end