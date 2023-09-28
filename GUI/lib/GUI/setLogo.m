%%
function setLogo(figure_handle, Module)
warning('off');
javaFrame = get(figure_handle, 'JavaFrame');
if strcmp(Module, 'M2')
    file_name = 'logoRed.png';
elseif strcmp(Module, 'M1')
%     file_name = 'logoBlue.png';
    file_name = 'logoOrange.png';
elseif strcmp(Module, 'M_OBM')
    file_name = 'logoBlue.png';    
elseif strcmp(Module, 'PPG')
    file_name = 'logoPPG.png';        
end
javaFrame.setFigureIcon(javax.swing.ImageIcon([fileparts(fileparts(fileparts(mfilename('fullpath')))) filesep 'Logo' filesep file_name]));
warning('on');
end