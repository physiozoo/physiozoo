%%
function signalDuration = calcDuration(varargin)

show_hours = 1;
need_ms = 0;

signal_length = double(varargin{1});

try
    if length(varargin) > 1
        need_ms = varargin{2};
        show_hours = varargin{3};
    end
catch
end


% if length(varargin) == 2
%     need_ms = varargin{2};
% else
%     need_ms = 1;
% end


what_2_show = show_hours * 2 + need_ms;

% Duration of signal
% duration_h  = mod(floor(signal_length / 3600), 60);
duration_h  = floor(signal_length / 3600);
duration_m  = mod(floor(signal_length / 60), 60);
duration_s  = mod(floor(signal_length), 60);
duration_ms = floor(mod(signal_length, 1)*1000);

switch what_2_show
    case 0
        signalDuration = sprintf('%02d:%02d', duration_m, duration_s);
    case 1
        signalDuration = sprintf('%02d:%02d.%03d', duration_m, duration_s, duration_ms);
    case 2
        signalDuration = sprintf('%02d:%02d:%02d', duration_h, duration_m, duration_s);
    case 3
        signalDuration = sprintf('%02d:%02d:%02d.%03d', duration_h, duration_m, duration_s, duration_ms);
end

