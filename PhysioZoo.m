function [] = PhysioZoo()
% PhyzioZoo: Starts the physiozoo application.

%% Set up paths
basepath = fileparts(mfilename('fullpath'));
rhrv_path = [basepath filesep 'rhrv'];
gui_A_path = [basepath filesep 'GUI'];
gui_PZ_path = [basepath filesep 'Test'];
config_path = [basepath filesep 'Config'];
wfdb_path = [basepath filesep 'wfdb'];

%% Initialize rhrv toolbox

rhrv_init_script = [rhrv_path filesep 'rhrv_init'];
run(rhrv_init_script);

%% Start PhysioZoo GUI
% addpath('D:\Temp\wfdb-app-toolbox-0-9-10\mcode');
addpath(gui_A_path);
addpath(gui_PZ_path);
addpath(config_path);
addpath(wfdb_path);


PhysioZooGUI();

end