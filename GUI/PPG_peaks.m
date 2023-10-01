%%
function [fiducials_table, fiducials_path] = PPG_peaks(ppg_file_name, config_file_name)

%% Path of executable file
fiducials_table = '';
fiducials_path = '';
% exe_file_path = fileparts(mfilename('fullpath'));
% executable_file = [exe_file_path filesep 'PPG' filesep 'pyPPG.exe'];

try
    % if exist(executable_file, 'file') && exist(config_file_name, 'file')
    try
        config_struct = ReadYaml(config_file_name);
        Fs = load(ppg_file_name, 'Fs');
    catch e
        rethrow(e);
    end
    
    executable_file = download_ppg_exe_file();
    
%     if ~exist(executable_file, 'file')
%         ME = MException('PPG_peaks:noSuchFile', 'Please, download PPG executable from https://physiozoo.com/!');
%         throw(ME);
%     end
    
    %% Input parameters
    in.data_path = ppg_file_name;
    in.savedata = 1;
    in.savingfolder = [tempdir, 'PPG_temp_dir'];
    in.savingformat = 'mat';
    in.savefig = 0;
    in.show_fig = 0;
    in.print_flag = 0;
    in.fs = Fs.Fs;
    in.filtering = config_struct.ppg_filt_enable.value;
    in.fL = config_struct.lcf_ppg.value + 0.0000001; %0.5000001;
    in.fH = config_struct.hcf_ppg.value; %12;
    in.order = config_struct.order.value; %4;
    in.check_ppg_len = 1;
    
    in.data_path = strrep(in.data_path, '\', '/');
    in.savingfolder = strrep(in.savingfolder ,'\', '/');
    executable_file = strrep(executable_file ,'\', '/');
    %% EXTRACT FIDUCIALS
    in.process_type = 'fiducials';
    
    func_args = zip_args(fieldnames(in), struct2cell(in));
    command = ['"' executable_file '" "' ,'{\"function\":\"ppg_example\",\"args\":',func_args,'}'];
    % try
    tic
    [status, result, error] = jsystem(command);
    toc
    %     if status ~= 0
    %         disp(['PPG_peaks error: ', error, '\n', result]);
    %         rethrow(error);
    if status == 0
        fiducials_file_names = jsondecode(result);
        if ~isempty(fiducials_file_names) && isfield(fiducials_file_names, 'fiducials_mat')
            fiducials_path = fiducials_file_names.fiducials_mat;
            if exist(fiducials_path, 'file')
                a = load(fiducials_path);
                if isfield(a, 'PPG_fiducials')
                    fiducials_table = struct2table(a.PPG_fiducials);
                end
            end
        end
    else
        disp(['PPG_peaks error: ', error, '\n', result]);
        ME = MException('PPG_peaks:jsystem', error);
        throw(ME);
    end
    
    %     if isempty(fiducials_table) || isempty(fiducials_path)
    %         rethrow('The fiducials points was''t calculated.');
    %     end
    % else
    % catch e
    %     if ~exist(executable_file, 'file')
    %         ME = MException('PPG_peaks:noSuchFile', 'Please, download PPG executable from https://physiozoo.com/!');
    %         rethrow(ME);
    %     else
    %         rethrow([e ': ' error]);
    %     end
    %     h_e = errordlg('Please, download PPG executable for https://physiozoo.com/!', 'Input Error'); setLogo(h_e, 'PPG');
    %     h_e = errordlg('The PPG exe or config file does''t exist!', 'Input Error'); setLogo(h_e, 'PPG');
    %     rethrow('The PPG exe or config file does''t exist!');
    % end
catch e
    rethrow(e);
end