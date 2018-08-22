function [] = PhysioZoo()
% PhyzioZoo: Starts the physiozoo application.


%% Set up paths
basepath = fileparts(mfilename('fullpath'));
% rhrv_path = [basepath filesep 'rhrv'];
% gui_path = [basepath filesep 'GUI'];
% lib_path = [gui_path filesep 'lib'];
% % gui_PZ_path = [basepath filesep 'Test'];
% config_path = [basepath filesep 'Config'];
% % wfdb_path = [basepath filesep 'wfdb'];
% % wfdb_path = 'D:\Temp\wfdb-app-toolbox-0-9-10\mcode';
% myWFDB = [lib_path filesep filesep 'lib' 'myWFDB'];
% myLoader = [gui_path filesep 'Loader'];


%check for updates
url = ['https://github.com/shemla/physiozoo.github.io/blob/master/version.txt'];%%%%url to version file
new_version1 = webread(url);
k = findstr(new_version1, '##version:');
new_version = new_version1(k : k + 16);

filename = [basepath filesep 'version.txt'];
fid = fopen(filename, 'rt');
tmp = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
current_version = tmp{1};

if ~strcmp(current_version, new_version)
	meassage_updates = {'Good news!', 'There''s a new version of the PhysioZoo program, now available online for download.','We at the PhysioZoo community work constantly on new updates, features, and maintainance of the existing features of the program.','In order to enjoy the full extension of the tools we provide with PhysioZoo, we suggest you always to work with the latest release of the program.'};
	answer = questdlg(meassage_updates, 'New Update', 'Go to website', 'Not now', 'Go to website');
	if strcmp(answer, 'Go to website')	
        web('http://physiozoo.com/');
        return
	end
end

%% Initialize rhrv toolbox

rhrv_init_script = [basepath filesep 'rhrv' filesep 'rhrv_init'];
run(rhrv_init_script);

%% Start PhysioZoo GUI
% addpath('D:\Temp\wfdb-app-toolbox-0-9-10\mcode');
addpath([basepath filesep 'Config']);
addpath([basepath filesep 'GUI']);
addpath([basepath filesep 'GUI' filesep 'Loader']);
addpath(genpath([basepath filesep 'GUI' filesep 'lib']));
% addpath([basepath filesep 'GUI' filesep 'lib' filesep 'gui-layout-toolbox-2.3.1']);
% % addpath(gui_PZ_path);
% addpath([basepath filesep 'Config']);
% % addpath(wfdb_path);
% addpath([gui_path filesep 'Loader']);
% addpath(lib_path);
% addpath(myWFDB);

PhysioZooGUI();

end