%%
function clear_time_statistics_results(GUI)

grid(GUI.TimeAxes1, 'off');
legend(GUI.TimeAxes1, 'off')
cla(GUI.TimeAxes1);
GUI.TimeAxes1.Visible = 'off';
