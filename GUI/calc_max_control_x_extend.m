%%
function max_extent_control = calc_max_control_x_extend(uitext_handle)
max_extent_control = 0;
for i = 1 : length(uitext_handle)
    extent_control = get(uitext_handle{i}, 'Extent');
    max_extent_control = max(max_extent_control, extent_control(3));
end
