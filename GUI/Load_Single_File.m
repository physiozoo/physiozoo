%%
function [DATA, GUI, DIRS] = Load_Single_File(DATA, GUI, DIRS, myColors, QRS_FileName, PathName)
        if QRS_FileName
            [files_num, ~] = size(QRS_FileName);
            if files_num == 1
%                 DATA = clearData(DATA);
%                 GUI = clear_statistics_plots(GUI);
%                 [DATA, GUI] = clearStatTables(DATA, GUI);
%                 GUI = clean_gui(GUI);
                try
                    waitbar_handle = waitbar(1/2, 'Loading data', 'Name', 'Working on it...');
                    [DATA, GUI, DIRS, mammal, mammal_index, integration, whichModule] = Load_Data_from_SingleFile(DATA, GUI, DIRS, QRS_FileName, PathName, waitbar_handle);
                    if whichModule == 1
                        if isvalid(waitbar_handle)
                            close(waitbar_handle);
                        end
                        return;
                    end
                catch e
                    if isvalid(waitbar_handle)
                        close(waitbar_handle);
                    end
                    errordlg(['Load Single File error: ' e.message], 'Input Error');
                    clean_gui();
                    cla(GUI.RRDataAxes);
                    cla(GUI.AllDataAxes);
                    return;
                end                                
                
                if isempty(integration) || strcmp(integration, 'electrocardiogram')
                    integration = 'ECG';
                end                                
                
                if isempty(mammal) || isempty(DATA.mammal) || (~strcmp(mammal, DATA.mammal) || ~strcmp(integration, DATA.Integration))
                    if isempty(mammal_index) || ~mammal_index
                        mammal_index = 1;
                        mammal = 'human (task force)';
                    end
                    DATA.mammal = mammal;
                    DATA.mammal_index = mammal_index;
                    GUI.Mammal_popupmenu.Value = DATA.mammal_index;
                    
                    DATA.Integration = integration;
                    DATA.integration_index = find(strcmpi(DATA.GUI_Integration, DATA.Integration));
                    GUI.Integration_popupmenu.Value = DATA.integration_index;
                    
%                     Set_MammalIntegration_After_Load();
                    
                    try
                        mhrv_load_defaults(DATA.mammals{DATA.mammal_index});
                    catch e
                        errordlg(['mhrv_load_defaults: ' e.message], 'Input Error');
                        if isvalid(waitbar_handle)
                            close(waitbar_handle);
                        end
                        return;
                    end
                    waitbar(2 / 2, waitbar_handle, 'Create Config Parameters Windows');
                    [DATA, GUI] = createConfigParametersInterface(DATA, GUI, myColors);
                    close(waitbar_handle);                                        
                else
                    close(waitbar_handle);
                end
                                
                [DATA, GUI] = reset_plot_Data(DATA, GUI);
                [DATA, GUI] = reset_plot_GUI(DATA, GUI);
                GUI = EnablePageUpDown(DATA, GUI);
                
                if isfield(GUI, 'RRDataAxes')
                    PathName = strrep(PathName, '\', '\\');
                    PathName = strrep(PathName, '_', '\_');
                    QRS_FileName_title = strrep(QRS_FileName, '_', '\_');
                    
                    TitleName = [PathName QRS_FileName_title] ;
                    title(GUI.RRDataAxes, TitleName, 'FontWeight', 'normal', 'FontSize', DATA.SmallFontSize);
                    
                    set(GUI.RecordName_text, 'String', QRS_FileName);
                end
                set(GUI.DataQualityMenu, 'Enable', 'on');
                set(GUI.SaveMeasures, 'Enable', 'on');
                set(GUI.SaveFiguresAsMenu, 'Enable', 'on');
                set(GUI.SaveParamFileMenu, 'Enable', 'on');
                set(GUI.LoadConfigFile, 'Enable', 'on');
            end
        end
        
%         setappdata(GUI.Window, 'DATA',DATA);
%         setappdata(GUI.Window, 'GUI',GUI);
%         setappdata(GUI.Window, 'DIRS',DIRS);
        
        
    end