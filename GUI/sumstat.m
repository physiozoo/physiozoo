function cell_res = sumstat(x, total_signal_length)
min_x = min(x);
max_x = max(x);
median_x = median(x);
Q1_x = prctile(x, 25);
Q3_x = prctile(x, 75);

burden = 100*sum(x)/total_signal_length;

events_number = length(x);

cell_res = {min_x, max_x, median_x, Q1_x, Q3_x, burden, events_number};
% length(x)