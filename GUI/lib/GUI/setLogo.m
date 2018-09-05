%%
function setLogo(figure_handle)
warning('off');
javaFrame = get(figure_handle, 'JavaFrame');
javaFrame.setFigureIcon(javax.swing.ImageIcon([fileparts(fileparts(fileparts(mfilename('fullpath')))) filesep 'Logo' filesep 'logoRed.png']));
warning('on');
end