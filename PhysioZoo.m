function [] = PhysioZoo()
% PhyzioZoo: Starts the physiozoo application.

%% Set up paths
basepath = fileparts(mfilename('fullpath'));

%% Initialize mhrv toolbox
lib_path = [basepath filesep 'mhrv'];
addpath(lib_path);

mhrv_init_script = [lib_path filesep 'mhrv_init'];
run(mhrv_init_script);

%% Start PhysioZoo GUI
addpath([basepath filesep 'Config']);
addpath([basepath filesep 'GUI']);
addpath([basepath filesep 'GUI' filesep 'Loader']);
addpath(genpath([basepath filesep 'GUI' filesep 'lib']));
addpath(genpath([basepath filesep 'GUI' filesep 'Biomarkers']));

PhysioZooGUI();

end

