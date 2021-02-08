%%
function clear_nonlinear_statistics_results(GUI)
try
    cla(GUI.NonLinearAxes1);
    grid(GUI.NonLinearAxes1, 'off');
    legend(GUI.NonLinearAxes1, 'off');
    GUI.NonLinearAxes1.Visible = 'off';
    
    cla(GUI.NonLinearAxes2);
    grid(GUI.NonLinearAxes2, 'off');
    legend(GUI.NonLinearAxes2, 'off');
    GUI.NonLinearAxes2.Visible = 'off';
    
    cla(GUI.NonLinearAxes3);
    grid(GUI.NonLinearAxes3, 'off');
    legend(GUI.NonLinearAxes3, 'off');
    GUI.NonLinearAxes3.Visible = 'off';
catch e
%     disp(e.message);
end
try
    GUI.NonLinearAxes1.XLabel.Interpreter = 'none';
    GUI.NonLinearAxes1.YLabel.Interpreter = 'none';
    GUI.NonLinearAxes1.TickLabelInterpreter.Interpreter = 'none';
    GUI.NonLinearAxes1.Legend.Interpreter = 'none';
catch
end
try
    GUI.NonLinearAxes2.XLabel.Interpreter = 'none';
    GUI.NonLinearAxes2.YLabel.Interpreter = 'none';
    GUI.NonLinearAxes2.TickLabelInterpreter.Interpreter = 'none';
    GUI.NonLinearAxes2.Legend.Interpreter = 'none';
catch
end
try
    GUI.NonLinearAxes3.XLabel.Interpreter = 'none';
    GUI.NonLinearAxes3.YLabel.Interpreter = 'none';
    GUI.NonLinearAxes3.TickLabelInterpreter.Interpreter = 'none';
    GUI.NonLinearAxes3.Legend.Interpreter = 'none';
catch
end