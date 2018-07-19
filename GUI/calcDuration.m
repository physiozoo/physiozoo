function signalDuration = calcDuration(varargin)

signal_length = double(varargin{1});
if length(varargin) == 2
    need_ms = varargin{2};
else
    need_ms = 1;
end
% Duration of signal
duration_h  = mod(floor(signal_length / 3600), 60);
duration_m  = mod(floor(signal_length / 60), 60);
duration_s  = mod(floor(signal_length), 60);
duration_ms = floor(mod(signal_length, 1)*1000);
if need_ms
    signalDuration = sprintf('%02d:%02d:%02d.%03d', duration_h, duration_m, duration_s, duration_ms);
else
    signalDuration = sprintf('%02d:%02d:%02d', duration_h, duration_m, duration_s);
end
