%%
function target_file_name = download_ppg_exe_file()

basepath = fileparts(mfilename('fullpath'));

ppg_path = [basepath filesep 'PPG' filesep];
ppgFile = [ppg_path 'pyPPG.exe'];
target_file_name = ppgFile;

file_address = 'https://github.com/physiozoo/physiozoo/raw/master/GUI/PPG/pyPPG.exe?download=';

waitbar_handle = waitbar(0, 'Loading', 'Name', 'Working on it...'); setLogo(waitbar_handle, 'PPG');

try
    waitbar(1/2, waitbar_handle, 'Downloading Executable'); setLogo(waitbar_handle, 'PPG');
    if ~exist(ppgFile, 'file')
        disp('Downloading PPG executable');
        target_file_name = websave(ppgFile, file_address);
    else
        fileInfo = dir(ppgFile);
        fileSize = fileInfo.bytes;
        if fileSize < 1000
            disp('Downloading PPG executable');
            target_file_name = websave(ppgFile, file_address);
        end
    end
    
    new_fileInfo = dir(target_file_name);
    newFileSize = new_fileInfo.bytes;
    if ~exist(target_file_name, 'file') || newFileSize < 100000000
        ME = MException(download_ppg_exe_file:downloadPPGexe, 'Downloading from the git failed. Please try again');
        throw(ME);
    end
    
    if isvalid(waitbar_handle)
        close(waitbar_handle);
    end
    
catch e
    rethrow(e);
end




% https://www.dropbox.com/scl/fi/pzh3fwoaxenqxug2yv3jp/pyPPG.exe?rlkey=vuibsgl940lygj1jon3acmei5&dl=0
% websave([ppg_path 'pyPPG.exe'], 'https://drive.google.com/file/d/1wD6On_tYxiImzCKrRP5U7kDpLkxNTgSm/view?usp=sharing');
% websave([ppg_path 'pyPPG.zip'], 'https://drive.google.com/file/d/1V_NlWjuw07rPMpIjWlbWMLXKVJj-0Uxn/view?usp=sharing');
% unzip([ppg_path 'pyPPG.zip'], ppg_path);