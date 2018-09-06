
function [] = PhysioZoo()
% PhyzioZoo: Starts the physiozoo application.


%% Set up paths
basepath = fileparts(mfilename('fullpath'));
% mhrv_path = [basepath filesep 'mhrv'];
% gui_path = [basepath filesep 'GUI'];
% lib_path = [gui_path filesep 'lib'];
% % gui_PZ_path = [basepath filesep 'Test'];
% config_path = [basepath filesep 'Config'];
% % wfdb_path = [basepath filesep 'wfdb'];
% % wfdb_path = 'D:\Temp\wfdb-app-toolbox-0-9-10\mcode';
% myWFDB = [lib_path filesep filesep 'lib' 'myWFDB'];
% myLoader = [gui_path filesep 'Loader'];

%% Initialize mhrv toolbox

mhrv_init_script = [basepath filesep 'mhrv' filesep 'mhrv_init'];
run(mhrv_init_script);

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

PhysioZooGUI_HRVAnalysis();

end
