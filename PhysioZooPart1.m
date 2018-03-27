
% PhyzioZooPart1: Starts the physiozoo application.

%% Set up paths
basepath = fileparts(mfilename('fullpath'));
rhrv_path = [basepath filesep 'rhrv'];
%gui_path = [basepath filesep 'Module1'];
gui_path = [basepath filesep 'Test'];
config_path = [basepath filesep 'Config'];

%% Initialize rhrv toolbox

rhrv_init_script = [rhrv_path filesep 'rhrv_init'];
run(rhrv_init_script);

%% Start PhysioZoo GUI
addpath(gui_path);
addpath(config_path);

PhysioZooGUI_Part2();
