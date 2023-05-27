%%
function save_spo2_figures_to_file(GUI, DATA, export_path_name, ext, fig_name, DATA_Fig)

axes_array = [GUI.TimeAxes1 GUI.FrequencyAxes1 GUI.FrequencyAxes2 GUI.NonLinearAxes1 GUI.FourthAxes1 GUI.FifthAxes1 GUI.FifthAxes2 GUI.RRDataAxes];

for i = 1 : length(axes_array)
    
    if DATA_Fig.export_figures(i)
        
        axes_handle = axes_array(i);
        
        fig_title = [fig_name DATA.FiguresNames{i}];
        
        try
            af = figure;
            set(af, 'Name', fig_title, 'NumberTitle', 'off');
            new_axes = copyobj(axes_handle, af);
            
%             fig_title = strrep(fig_title, '_', ' $\space $');
%             fig_title = strrep(fig_title, '_', ' $\_$ ');
            fig_title = strrep(fig_title, '_', '\_');
%             fig_title = strrep(fig_title, '2', '$_2$');
            fig_title = strrep(fig_title, '2', '_2');
            
%             title(new_axes, fig_title, 'Interpreter', 'Latex');
            title(new_axes, fig_title, 'FontWeight', 'normal');
            
            if ~isempty(new_axes.Children)
                file_name = [export_path_name DATA.FiguresNames{i}];
                
                if exist([file_name '.' ext], 'file')
                    button = questdlg([file_name '.' ext ' already exist. Do you want to overwrite it?'], 'Overwrite existing file?', 'Yes', 'No', 'No');
                    if strcmp(button, 'No')
                        close(af);
                        continue;
                    end
                end                
                if strcmpi(ext, 'fig')
                    savefig(af, file_name, 'compact');
                elseif ~strcmpi(ext, 'fig')
                    mhrv.util.fig_print( af, file_name, 'output_format', ext, 'font_size', 16, 'width', 20, 'font_weight', 'normal');
                end                
            end
            close(af);
        catch e
            disp(e.message);
        end
    end
end