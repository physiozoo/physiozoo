%%
function clearParametersBox(VBoxHandle)
param_boxes_handles = allchild(VBoxHandle);
if ~isempty(param_boxes_handles)
    delete(param_boxes_handles);
end