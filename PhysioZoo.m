function [] = PhysioZoo()
% PhyzioZoo: Starts the physiozoo application.


%% Set up paths
basepath = fileparts(mfilename('fullpath'));
rhrv_path = [basepath filesep 'rhrv'];
gui_A_path = [basepath filesep 'GUI'];
lib_path = [gui_A_path filesep 'lib'];
% gui_PZ_path = [basepath filesep 'Test'];
config_path = [basepath filesep 'Config'];
% wfdb_path = [basepath filesep 'wfdb'];
% wfdb_path = 'D:\Temp\wfdb-app-toolbox-0-9-10\mcode';
myWFDB = [lib_path filesep 'myWFDB'];
myLoader = [gui_A_path filesep 'Loader'];


%check for updates
url = ['https://github.com/shemla/physiozoo.github.io/blob/master/version.txt'];%%%%url to version file
new_version1=webread(url);
k=findstr(new_version,'##version:');
new_version=new_version1(k:k+16);
current_version=load(strrep(basepath,'PhysioZoo','version.txt'));

if ~strcmp(current_version,new_version)
	meassage_updates={'Good news!','There''s a new version of the PhysioZoo program, now available online for download.','We at the PhysioZoo community work constantly on new updates, features, and maintainance of the existing features of the program.','In order to enjoy the full extension of the tools we provide with PhysioZoo, we suggest you always to work with the latest release of the program.'};  ;
	answer = questdlg(meassage_updates,'New Update','Go to website','Not now','Go to website');
	if strcmp(answer,'Go to website')
		web('http://physiozoo.com/');
	end
end

%% Initialize rhrv toolbox

rhrv_init_script = [rhrv_path filesep 'rhrv_init'];
run(rhrv_init_script);

%% Start PhysioZoo GUI
% addpath('D:\Temp\wfdb-app-toolbox-0-9-10\mcode');
addpath(gui_A_path);
% addpath(gui_PZ_path);
addpath(config_path);
% addpath(wfdb_path);
addpath(myLoader);
addpath(lib_path);
addpath(myWFDB);

PhysioZooGUI();

end