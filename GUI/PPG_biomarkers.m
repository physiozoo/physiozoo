%%
function biomarkers_path = PPG_biomarkers(ppg_file_name, config_file_name, fiducials_path, start_sig, win_len_in_sec)

%% Path of executable file
biomarkers_path = '';
% exe_file_path = fileparts(mfilename('fullpath'));
% executable_file = [exe_file_path filesep 'PPG' filesep 'pyPPG.exe'];

% if exist(executable_file, 'file') && exist(config_file_name, 'file') && exist(fiducials_path, 'file')
try
    try
        config_struct = ReadYaml(config_file_name);
        Fs = load(ppg_file_name, 'Fs');
    catch e
        rethrow(e);
    end
    
    executable_file = download_ppg_exe_file();
%     
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
    in.check_ppg_len = 0;
    
    in.start_sig = start_sig; %200;
    in.end_sig = in.start_sig + win_len_in_sec * in.fs;
    
    in.data_path = strrep(in.data_path, '\', '/');
    in.savingfolder = strrep(in.savingfolder ,'\', '/');
    executable_file = strrep(executable_file ,'\', '/');
    in.saved_fiducials = strrep(fiducials_path, '\', '/');
    
    %% EXTRACT BIOMARKERS
    in.process_type = 'biomarkers';
    
    func_args = zip_args(fieldnames(in), struct2cell(in));
    command = ['"' executable_file '" "' ,'{\"function\":\"ppg_example\",\"args\":',func_args,'}'];
    
    tic
    [status, result, error] = jsystem(command);
    toc
    
    if status == 0
        file_names = jsondecode(result);
        if ~isempty(file_names) && isfield(file_names, 'ppg_sig_defs_stats_mat')&& isfield(file_names, 'ppg_derivs_defs_stats_mat')&& isfield(file_names, 'sig_ratios_defs_stats_mat')&& isfield(file_names, 'derivs_ratios_defs_stats_mat')
            biomarkers_path.PPG_Signal = file_names.ppg_sig_defs_stats_mat;
            biomarkers_path.PPG_Derivatives = file_names.ppg_derivs_defs_stats_mat;
            biomarkers_path.Signal_Ratios = file_names.sig_ratios_defs_stats_mat;
            biomarkers_path.Derivatives_Ratios = file_names.derivs_ratios_defs_stats_mat;
        end
    else
        disp(['PPG_biomarkers error: ', error, '\n', result]);
        ME = MException('PPG_peaks:jsystem', error);
        throw(ME);
        %         disp(['PPG_biomarkers error: ', error, '\n', result]);
        %         rethrow(MException('PPG_biomarkers:jsystem', error));
    end
    %     if isempty(biomarkers_path)
    %         rethrow('The PPG biomarkers was''t calculated.');
    %     end
    % else
    %     h_e = errordlg('Please, download PPG executable for https://physiozoo.com/!', 'Input Error'); setLogo(h_e, 'PPG');
    %     h_e = errordlg('The PPG exe or config file does''t exist!', 'Input Error'); setLogo(h_e, 'PPG');
    % end
catch e
    rethrow(e);
end