%%
function [DATA, GUI, DIRS, mammal, mammal_index, integration, isM1] = Load_Data_from_SingleFile(DATA, GUI, DIRS, QRS_FileName, PathName, waitbar_handle)
if QRS_FileName
    [files_num, ~] = size(QRS_FileName);
    if files_num == 1
        
        [~, DataFileName, ExtensionFileName] = fileparts(QRS_FileName);
        
        ExtensionFileName = ExtensionFileName(2:end);
        
        DIRS.dataDirectory = PathName;
        DIRS.Ext_open = ExtensionFileName;
        
        integration = '';
        mammal = '';
        mammal_index = '';
               
        if strcmpi(ExtensionFileName, 'txt') || strcmpi(ExtensionFileName, 'mat') || strcmpi(ExtensionFileName, 'qrs') || strcmpi(ExtensionFileName, 'atr')            
            
            Config = ReadYaml('Loader Config.yml');
            
            DataFileMap = loadDataFile([PathName QRS_FileName]);
            MSG = DataFileMap('MSG');
            if strcmp(Config.alarm.(MSG), 'OK')
                data = DataFileMap('DATA');
                if ~strcmp(data.Data.Type, 'electrography')

                    DATA = clearData(DATA);
                    GUI = clear_statistics_plots(GUI);
                    [DATA, GUI] = clearStatTables(DATA, GUI);
                    GUI = clean_gui(GUI);

                    DATA.DataFileName = DataFileName;
                    
                    mammal = data.General.mammal;
                    [mammal, mammal_index] = set_mammal(DATA, mammal);
                    integration = data.General.integration_level;
                    DATA.SamplingFrequency = data.Time.Fs;
                    QRS_data = data.Data.Data;
                    time_data = data.Time.Data;
                    isM1 = 0;
                else
                    if isvalid(waitbar_handle)
                        close(waitbar_handle);
                    end
                    choice = questdlg('This recording contains raw electrophysiological data. It will be opened in the peak detection module.', ...
                                        'Select module', 'OK', 'Cancel', 'OK');
                    
                    switch choice
                        case 'OK'
                            %throw(MException('LoadFile:text', 'Please, choose another file type.'));
                            fileNameFromM2.FileName = QRS_FileName;
                            fileNameFromM2.PathName = PathName;
                            PhysioZooGUI_PeakDetection(fileNameFromM2);
                            isM1 = 1;
                            return;
                        case 'Cancel'
                            isM1 = 1;
                            return;
                    end
                end
            else
                throw(MException('LoadFile:text', Config.alarm.(MSG)));
            end
            
        else
            close(waitbar_handle);
            throw(MException('LoadFile:text', 'Please, choose another file type.'));
        end
        
        DATA = set_qrs_data(DATA, QRS_data, time_data);
        
%         if isempty(DATA.SamplingFrequency)
%             prompt = {'Please, enter Sampling Frequency:'};
%             dlg_title = 'Input';
%             num_lines = 1;
%             defaultans = {''};
%             answer = inputdlg(prompt, dlg_title, num_lines, defaultans);
%             
%             if ~isempty(answer)
%                 DATA.SamplingFrequency = str2double(answer{1});
%                 if ~isnan(DATA.SamplingFrequency)
%                     DATA = set_qrs_data(DATA, QRS_data, time_data);
%                 else
%                     close(waitbar_handle);
%                     throw(MException('LoadFile:SamplingFrequency', 'Please, enter valid SamplingFrequency!'));
%                 end
%             else
%                 close(waitbar_handle);
%                 throw(MException('LoadFile:SamplingFrequency', 'Please, enter SamplingFrequency!'));
%             end
%         else
%             DATA = set_qrs_data(DATA, QRS_data, time_data);
%         end
    end
end
end




 %                 if strcmpi(ExtensionFileName, 'mat')
        %                     QRS = load([PathName QRS_FileName]);
        %                     QRS_field_names = fieldnames(QRS);
        %                     QRS_data = [];
        %                     for i = 1 :  length(QRS_field_names)
        %                         curr_field = QRS.(QRS_field_names{i});
        %                         if ~isempty(regexpi(QRS_field_names{i}, 'qrs|data'))
        %                             QRS_data = curr_field;
        %                         elseif strcmpi(QRS_field_names{i}, 'mammal')  % ~isempty(regexpi(QRS_field_names{i}, 'mammal'))
        %                             mammal = curr_field;
        %                             [mammal, mammal_index] = set_mammal(mammal);
        %                         elseif strcmpi(QRS_field_names{i}, 'Fs')   %~isempty(regexpi(QRS_field_names{i}, 'Fs'))
        %                             DATA.SamplingFrequency = curr_field;
        %                         elseif strcmpi(QRS_field_names{i}, 'Integration')  %~isempty(regexpi(QRS_field_names{i}, 'Integration'))
        %                             %                             DATA.Integration = curr_field;
        %                             integration = curr_field;
        %                         end
        %                     end
        %                     time_data = 0;
        %                 if strcmpi(ExtensionFileName, 'qrs') % || strcmpi(ExtensionFileName, 'atr') atr - for quality; qrs - for annotations (peaks)
        %
        %                         [ ~, Fs, ~ ] = get_signal_channel( [PathName DATA.DataFileName] );
        %                         DATA.SamplingFrequency = Fs;
        %                         [mammal, integration] = get_description_from_wfdb_header([PathName DATA.DataFileName]);
        %                         [mammal, mammal_index] = set_mammal(mammal);
        %                         %                         if ~isempty(integration)
        %                         %                             DATA.Integration = integration;
        %                         %                         end
        %                     try
        %                         QRS_data = rdann([PathName DATA.DataFileName], ExtensionFileName); % atr qrs
        %                     catch
        %                         close(waitbar_handle);
        %                         throw(MException('LoadFile:text', 'Cann''t read file.'));
        %                     end
        %                     time_data = 0;
        
        
%                     file_name = [PathName DATA.DataFileName '.txt'];
            %                     fileID = fopen(file_name, 'r');
            %                     if fileID ~= -1
            %                         %                         mammal = fscanf(fileID, '%*s %s', 1);
            %                         Mammal = fscanf(fileID, '%s', 1);
            %                         if ~isempty(regexpi(Mammal, 'mammal'))
            %                             mammal = fscanf(fileID, '%s', 1);
            %                             [mammal, mammal_index] = set_mammal(mammal);
            %                             DATA.SamplingFrequency = fscanf(fileID, '%*s %d', 1);
            %                             %                         DATA.Integration = fscanf(fileID, '%*s %s', 1);
            %                             integration = fscanf(fileID, '%*s %s', 1);
            %                             if strcmpi(integration, 'AP') || strcmpi(integration, 'Action') % strcmpi(DATA.Integration, 'AP') || strcmpi(DATA.Integration, 'Action')
            %                                 %                             DATA.Integration = 'Action Potential';
            %                                 integration = 'Action Potential';
            %                             end
            %                             QRS_data = dlmread(file_name,' ', 4, 0);
            %                         else
            %                             QRS_data = dlmread(file_name,' ', 0, 0);
            %                         end
            %                         fclose(fileID);
            %                     end        