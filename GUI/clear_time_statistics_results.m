%%
function clear_time_statistics_results(GUI)

grid(GUI.TimeAxes1, 'off');
legend(GUI.TimeAxes1, 'off')
cla(GUI.TimeAxes1);
GUI.TimeAxes1.Visible = 'off';

try
    GUI.TimeAxes1.XLabel.Interpreter = 'none';
    GUI.TimeAxes1.YLabel.Interpreter = 'none';
    GUI.TimeAxes1.TickLabelInterpreter.Interpreter = 'none';
    GUI.TimeAxes1.Legend.Interpreter = 'none';
catch
end

