%
    function SavePeaks_Callback(~, ~)       
        
        persistent DIRS;
        persistent EXT;
        
        % Add third-party dependencies to path
        gui_basepath = fileparts(mfilename('fullpath'));
        basepath = fileparts(gui_basepath);
        
        if ~isdir([basepath filesep 'Results'])
            warning('off');
            mkdir(basepath, 'Results');
            warning('on');
        end
                
        if ~isfield(DIRS, 'analyzedDataDirectory') 
            DIRS.analyzedDataDirectory = [basepath filesep 'Results'];
        end
        if isempty(EXT)
            EXT = 'mat';
        end
                
        original_file_name = DATA.DataFileName;
        file_name = [original_file_name, '_peaks'];
        
        [filename, results_folder_name, ~] = uiputfile({'*.*', 'All files';...
            '*.txt','Text Files (*.txt)';...
            '*.mat','MAT-files (*.mat)';...
            '*.qrs',  'WFDB Files (*.qrs)'},...
            'Choose Analyzed Data File Name',...
            [DIRS.analyzedDataDirectory, filesep, file_name, '.', EXT]);
        if ~isequal(results_folder_name, 0)
            DIRS.analyzedDataDirectory = results_folder_name;
            [~, ~, ExtensionFileName] = fileparts(filename);
            ExtensionFileName = ExtensionFileName(2:end);
            EXT = ExtensionFileName;
            
            Data = DATA.qrs;
            Fs = DATA.Fs;
            Integration_level = DATA.Integration;
            Mammal = DATA.mammals{DATA.mammal_index};
%             File_type = 'beating rate';
            
            Channels{1}.name = 'interval';
            Channels{1}.enable = 'yes';
            Channels{1}.type = 'peak';
            Channels{1}.unit = 'index';
            
            full_file_name = [results_folder_name, filename];
            
            if strcmpi(ExtensionFileName, 'mat')
                save(full_file_name, 'Data', 'Fs', 'Integration_level', 'Mammal', 'Channels');
            elseif strcmpi(ExtensionFileName, 'txt')
                header_fileID = fopen(full_file_name, 'wt');
                
                fprintf(header_fileID, '---\n');
                
%                 fprintf(header_fileID, 'File_type:         %s\n', File_type);
                fprintf(header_fileID, 'Mammal:            %s\n', Mammal);
                fprintf(header_fileID, 'Fs:                %d\n', Fs);
                fprintf(header_fileID, 'Integration_level: %s\n\n', Integration_level);
                                               
                fprintf(header_fileID, 'Channels:\n\n');
                fprintf(header_fileID, '    - type:   %s\n', Channels{1}.type);
                fprintf(header_fileID, '      name:   %s\n', Channels{1}.name);
                fprintf(header_fileID, '      unit:   %s\n', Channels{1}.unit);
                fprintf(header_fileID, '      enable: %s\n\n', Channels{1}.enable);
                
				fprintf(header_fileID, '---\n');
				
%                 fprintf(header_fileID, 'Mammal: %s\r\n', Mammal);
%                 fprintf(header_fileID, 'Fs: %d\r\n', Fs);
%                 fprintf(header_fileID, 'Integration_level: %s\r\n\r\n', Integration_level);


%                 dlmwrite(file_name_txt, ecg, 'delimiter', '\t', 'newline', 'pc', 'precision', '%.9f', 'roffset', roffset, '-append');
                  % '%d\t\n'

                dlmwrite(full_file_name, Data, 'delimiter', '\t', 'precision', '%d', 'newline', 'pc', '-append', 'roffset', 1);
                
                fclose(header_fileID);
            elseif strcmpi(ExtensionFileName, 'qrs')
                [~, filename_noExt, ~] = fileparts(filename);
                saved_path = pwd;
                cd(results_folder_name);
                try
%                     wfdb_path = 'D:\Temp\wfdb-app-toolbox-0-9-10\mcode';
%                     addpath(wfdb_path);
%                     mat2wfdb(Data, filename_noExt, Fs, [], ' ', {}, [], {strcat(Integration_level, '-', Mammal)});
%                     wrann(filename_noExt, 'qrs', int64(Data));
%                     rmpath(wfdb_path);
%                     delete([filename_noExt '.dat']);

                    wrann([results_folder_name filename_noExt], 'qrs', int64(Data), 'fs', 500);


                catch e
                    disp(e);
                end
                cd(saved_path);
            end
        end
    end