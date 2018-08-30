function GUI = clear_nonlinear_statistics_results(GUI)
grid(GUI.NonLinearAxes1, 'off');
grid(GUI.NonLinearAxes2, 'off');
grid(GUI.NonLinearAxes3, 'off');

legend(GUI.NonLinearAxes1, 'off');
legend(GUI.NonLinearAxes2, 'off');
legend(GUI.NonLinearAxes3, 'off');

cla(GUI.NonLinearAxes1);
cla(GUI.NonLinearAxes2);
cla(GUI.NonLinearAxes3);
end