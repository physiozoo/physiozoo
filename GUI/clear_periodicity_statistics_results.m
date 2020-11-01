%%
function clear_periodicity_statistics_results(GUI)

grid(GUI.FifthAxes1, 'off');
grid(GUI.FifthAxes2, 'off');
legend(GUI.FifthAxes1, 'off');
legend(GUI.FifthAxes2, 'off');
cla(GUI.FifthAxes1);
cla(GUI.FifthAxes2);
GUI.FifthAxes1.Visible = 'off';
GUI.FifthAxes2.Visible = 'off';
