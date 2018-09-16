%%
function setLogo(figure_handle, Module)
warning('off');
javaFrame = get(figure_handle, 'JavaFrame');
if strcmp(Module, 'M2')
    file_name = 'logoRed.png';
elseif strcmp(Module, 'M1')
    file_name = 'logoBlue.png';
end
javaFrame.setFigureIcon(javax.swing.ImageIcon([fileparts(fileparts(fileparts(mfilename('fullpath')))) filesep 'Logo' filesep file_name]));
warning('on');
end