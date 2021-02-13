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

try
    GUI.FrequencyAxes1.XLabel.Interpreter = 'none';
    GUI.FrequencyAxes1.YLabel.Interpreter = 'none';
    GUI.FrequencyAxes1.TickLabelInterpreter.Interpreter = 'none';
    GUI.FrequencyAxes1.Legend.Interpreter = 'none';
catch
end
try
    GUI.FrequencyAxes2.XLabel.Interpreter = 'none';
    GUI.FrequencyAxes2.YLabel.Interpreter = 'none';
    GUI.FrequencyAxes2.TickLabelInterpreter.Interpreter = 'none';
    GUI.FrequencyAxes2.Legend.Interpreter = 'none';
catch
end
