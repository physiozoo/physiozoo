function [ hrv_fd, pxx, f_axis, plot_data ] = hrv_freq( nni, varargin )
%HRV_FREQ NN interval spectrum and frequency-domain HRV metrics
%   This function estimates the PSD (power spectral density) of a given nn-interval sequence, and
%   calculates the power in various frequency bands.
%   Inputs:
%       - nni: RR/NN intervals, in seconds.
%       - varargin: Pass in name-value pairs to configure advanced options:
%           - methods: A cell array of strings containing names of methods to use to estimate the
%             spectrum. Supported methods are:
%               - 'lomb': Lomb-scargle periodogram.
%               - 'ar': Yule-Walker autoregressive model. Data will be resampled. No windowing will
%                       be performed for this method.
%               - 'welch': Welch's method (overlapping windows).
%               - 'fft': Simple fft-based periodogram, no overlap (also known as Bartlett's method).
%             In all cases, a Hamming window will be used on the samples. Data will not be resampled
%             for all methods except 'lomb', to 10*hf_band(2) (ten times the maximal frequency).
%             Default value is {'lomb', 'ar', 'welch'}.
%           - power_method: The method to use for calculating the power in each band. Can be any one
%             of the methods given in 'methods'. This also determines the spectrum that will be
%             returned from this function (pxx).
%             Default: First value in 'methods'.
%           - band_factor: A factor that will be applied to the frequency bands. Useful for shifting
%             them linearly to adapt to non-human data. Default: 1.0 (no shift).
%           - vlf_band: 2-element vector of frequencies in Hz defining the VLF band.
%             Default: [0.003, 0.04].
%           - lf_band: 2-element vector of frequencies in Hz defining the LF band.
%             Default: [0.04, 0.15].
%           - hf_band: 2-element vector of frequencies in Hz defining the HF band.
%             Default: [0.15, 0.4].
%           - window_minutes: Split intervals into windows of this length, calcualte the spectrum in
%             each window, and average them. A Hamming window will be also be applied to each window
%             after breaking the intervals into windows. Set to [] if you want to disable windowing.
%             Default: 5 minutes.
%           - detrend_order: Order of polynomial to fit to the data for detrending.
%             Default: 1 (i.e. linear detrending).
%           - ar_order: Order of the autoregressive model to use if 'ar' method is specific.
%             Default: 24.
%           - welch_overlap: Percentage of overlap between windows when using Welch's method.
%             Default: 50 percent.
%           - plot: true/false whether to generate plots. Defaults to true if no output arguments
%             were specified.
%   Outputs:
%       - hrv_fd: Table containing the following HRV metrics:
%           - TOT_PWR: Total power in all three bands combined.
%           - VLF_PWR: Power in the VLF band.
%           - LF_PWR: Power in the LF band.
%           - HF_PWR: Power in the HF band.
%           - VLF_to_TOT: Ratio between VLF power and total power.
%           - LF_to_TOT: Ratio between LF power and total power.
%           - HF_to_TOT: Ratio between HF power and total power.
%           - LF_to_HF: Ratio between LF and HF power.
%           - LF_PEAK: Frequency of highest peak in the LF band.
%           - HF_PEAK: Frequency of highest peak in the HF band.
%       - pxx: Power spectrum. It's type is determined by the 'power_method' parameter.
%       - f_axis: Frequencies, in Hz, at which pxx was calculated.

%% Input
SUPPORTED_METHODS = {'lomb', 'ar', 'welch', 'fft'};

% Defaults
DEFAULT_METHODS = rhrv_default('hrv_freq.methods', {'lomb', 'ar', 'welch'});
DEFAULT_BAND_FACTOR = rhrv_default('hrv_freq.band_factor', 1.0);
DEFAULT_VLF_BAND = rhrv_default('hrv_freq.vlf_band', [0.003, 0.04]);
DEFAULT_LF_BAND  = rhrv_default('hrv_freq.lf_band', [0.04,  0.15]);
DEFAULT_HF_BAND  = rhrv_default('hrv_freq.hf_band', [0.15,  0.4]);
DEFAULT_WINDOW_MINUTES = rhrv_default('hrv_freq.window_minutes', 5);
DEFAULT_AR_ORDER = rhrv_default('hrv_freq.ar_order', 24);
DEFAULT_WELCH_OVERLAP = rhrv_default('hrv_freq.welch_overlap', 50); % percent
DEFAULT_DETREND_ORDER = rhrv_default('hrv_freq.detrend_order', 1);

% Define input
p = inputParser;
p.addRequired('nni', @(x) isnumeric(x) && ~isscalar(x));
p.addParameter('methods', DEFAULT_METHODS, @(x) iscellstr(x) && ~isempty(x));
p.addParameter('power_method', [], @ischar);
p.addParameter('band_factor', DEFAULT_BAND_FACTOR, @(x) isnumeric(x)&&isscalar(x)&&x>0);
p.addParameter('vlf_band', DEFAULT_VLF_BAND, @(x) isnumeric(2)&&length(x)==2&&x(2)>x(1));
p.addParameter('lf_band', DEFAULT_LF_BAND, @(x) isnumeric(2)&&length(x)==2&&x(2)>x(1));
p.addParameter('hf_band', DEFAULT_HF_BAND, @(x) isnumeric(2)&&length(x)==2&&x(2)>x(1));
p.addParameter('window_minutes', DEFAULT_WINDOW_MINUTES, @(x) isnumeric(x));
p.addParameter('detrend_order', DEFAULT_DETREND_ORDER, @(x) isnumeric(x)&&isscalar(x));
p.addParameter('ar_order', DEFAULT_AR_ORDER, @(x) isnumeric(x)&&isscalar(x));
p.addParameter('welch_overlap', DEFAULT_WELCH_OVERLAP, @(x) isnumeric(x)&&isscalar(x)&&x>=0&&x<100);
p.addParameter('plot', nargout == 0, @islogical);

% Get input
p.parse(nni, varargin{:});
methods = p.Results.methods;
power_method = p.Results.power_method;
band_factor = p.Results.band_factor;
vlf_band = p.Results.vlf_band .* band_factor;
lf_band = p.Results.lf_band   .* band_factor;
hf_band = p.Results.hf_band   .* band_factor;
window_minutes = p.Results.window_minutes;
detrend_order = p.Results.detrend_order;
ar_order = p.Results.ar_order;
welch_overlap = p.Results.welch_overlap;
should_plot = p.Results.plot;

% Validate methods
methods_validity = cellfun(@(method) any(strcmp(SUPPORTED_METHODS, method)), methods);
if (~all(methods_validity))
    invalid_methods = methods(~methods_validity);
    error('Invalid methods given: %s.', strjoin(invalid_methods, ', '));
end

% Validate power method
if (isempty(power_method))
    % Use the first provided method if power_method not provided
    power_method = methods{1};
elseif (~any(strcmp(SUPPORTED_METHODS, power_method)))
    error('Invalid power_method given: %s.', power_method);
elseif (~any(strcmp(methods, power_method)))
    error('No matching method provided for power_method %s', power_method);
end

%% Preprocess

% Calculate zero-based interval time axis
nni = nni(:);
tnn = [0; cumsum(nni(1:end-1))];

% Detrend and zero mean
nni = nni - mean(nni);
[poly, ~, poly_mu] = polyfit(tnn, nni, detrend_order);
nni_trend = polyval(poly, tnn, [], poly_mu);
nni = nni - nni_trend;

%% Initializations

% Set window_minutes to maximal value if requested
if (isempty(window_minutes))
    window_minutes = max(1, floor((tnn(end)-tnn(1)) / 60));
end

t_win = 60 * window_minutes; % Window length in seconds
t_max = tnn(end);
f_min = vlf_band(1);
f_max = hf_band(2);
num_windows = floor(t_max / t_win);

% In case there's not enough data for one window, use entire signal length
if (num_windows < 1)
    num_windows = 1;
    t_win = floor(tnn(end)-tnn(1));
end

% Uniform sampling freq: Take 10x more than f_max
fs_uni = 10 * f_max; %Hz

% Uniform time axis
tnn_uni = tnn(1) : 1/fs_uni : tnn(end);
n_win_uni = floor(t_win / (1/fs_uni));
num_windows_uni = floor(length(tnn_uni) / n_win_uni);

% Build a frequency axis. The best frequency resolution we can get is 1/t_win.
f_res  = 1 / t_win; % equivalent to fs_uni / n_win_uni 
f_axis = (0 : f_res : f_max)';

% Check Nyquist criterion: We need atleast 2*f_max*t_win samples in each window to resolve f_max.
if (n_win_uni <= 2*f_max*t_win)
    warning('Nyquist criterion not met for given window length and frequency bands');
end

% Initialize outputs
pxx_lomb  = []; calc_lomb  = false;
pxx_ar    = []; calc_ar    = false;
pxx_welch = []; calc_welch = false;
pxx_fft   = []; calc_fft   = false;

if (any(strcmp(methods, 'lomb')))
    pxx_lomb = zeros(length(f_axis), 1);
    calc_lomb = true;
end
if (any(strcmp(methods, 'ar')))
    pxx_ar = zeros(length(f_axis), 1);
    calc_ar = true;
end
if (any(strcmp(methods, 'welch')))
    pxx_welch = zeros(length(f_axis), 1);
    calc_welch = true;
end
if (any(strcmp(methods, 'fft')))
    pxx_fft = zeros(length(f_axis), 1);
    calc_fft = true;
end

% Interlopate nn-intervals if needed
if (calc_ar || calc_fft || calc_welch)
    nni_uni = interp1(tnn, nni, tnn_uni, 'spline')';
end

%% Lomb method
if (calc_lomb)
    for curr_win = 1:num_windows
        curr_win_idx = (tnn >= t_win * (curr_win-1)) & (tnn < t_win * curr_win);

        nni_win = nni(curr_win_idx);
        tnn_win = tnn(curr_win_idx);
        
        n_win = length(nni_win);
        window_func = hamming(n_win);
        nni_win = nni_win .* window_func;
        
        % Check Nyquist criterion
        min_samples_nyquist = ceil(2*f_max*t_win);
        if (n_win < min_samples_nyquist)
            warning('Nyquist criterion not met in window %d (%d of %d samples)', curr_win, n_win, min_samples_nyquist);
        end
        
        [pxx_lomb_win, ~] = plomb(nni_win, tnn_win, f_axis);
        pxx_lomb = pxx_lomb + pxx_lomb_win;
    end
    % Average
    pxx_lomb = pxx_lomb ./ num_windows;
end

%% AR Method
if (calc_ar)
    for curr_win = 1:num_windows_uni
        curr_win_idx = ((curr_win - 1) * n_win_uni + 1) : (curr_win * n_win_uni);
        nni_win = nni_uni(curr_win_idx);

        % AR periodogram
        [pxx_ar_win, ~] = pyulear(nni_win, ar_order, f_axis, fs_uni);
        pxx_ar = pxx_ar + pxx_ar_win;
    end
    % Average
    pxx_ar = pxx_ar ./ num_windows_uni;
end

%% Welch Method
if (calc_welch)
    window = hamming(n_win_uni);
    welch_overlap_samples = floor(n_win_uni * welch_overlap / 100);
    [pxx_welch, ~] = pwelch(nni_uni, window, welch_overlap_samples, f_axis, fs_uni);
end

%% FFT method
if (calc_fft)
    window_func = hamming(n_win_uni);    
    for curr_win = 1:num_windows_uni
        curr_win_idx = ((curr_win - 1) * n_win_uni + 1) : (curr_win * n_win_uni);
        nni_win = nni_uni(curr_win_idx);
        
        % FFT periodogram
        [pxx_fft_win, ~] = periodogram(nni_win, window_func, f_axis, fs_uni);
        pxx_fft = pxx_fft + pxx_fft_win;
    end
    % Average
    pxx_fft = pxx_fft ./ num_windows_uni;
end

%% Metrics
hrv_fd = table;
hrv_fd.Properties.Description = 'Frequency Domain HRV Metrics';

% Get the PSD for the requested power_method
pxx = eval(['pxx_' power_method]);

% Calculate power in bands
total_band = [f_min, f_axis(end)];

hrv_fd.TOT_PWR = bandpower(pxx, f_axis, total_band,'psd') * 1e6;
hrv_fd.Properties.VariableUnits{'TOT_PWR'} = 'ms^2';
hrv_fd.Properties.VariableDescriptions{'TOT_PWR'} = 'Total power (all bands)';

hrv_fd.VLF_PWR = bandpower(pxx, f_axis, vlf_band,'psd') * 1e6;
hrv_fd.Properties.VariableUnits{'VLF_PWR'} = 'ms^2';
hrv_fd.Properties.VariableDescriptions{'VLF_PWR'} = 'Power in VLF band';

hrv_fd.LF_PWR  = bandpower(pxx, f_axis, lf_band, 'psd') * 1e6;
hrv_fd.Properties.VariableUnits{'LF_PWR'} = 'ms^2';
hrv_fd.Properties.VariableDescriptions{'LF_PWR'} = 'Power in LF band';

hrv_fd.HF_PWR  = bandpower(pxx, f_axis, [hf_band(1) f_axis(end)], 'psd') * 1e6;
hrv_fd.Properties.VariableUnits{'HF_PWR'} = 'ms^2';
hrv_fd.Properties.VariableDescriptions{'HF_PWR'} = 'Power in HF band';

% Calculate ratio of power in each band
hrv_fd.VLF_to_TOT = hrv_fd.VLF_PWR / hrv_fd.TOT_PWR;
hrv_fd.Properties.VariableUnits{'VLF_to_TOT'} = '1';
hrv_fd.Properties.VariableDescriptions{'VLF_to_TOT'} = 'VLF to total power ratio';

hrv_fd.LF_to_TOT  = hrv_fd.LF_PWR  / hrv_fd.TOT_PWR;
hrv_fd.Properties.VariableUnits{'LF_to_TOT'} = '1';
hrv_fd.Properties.VariableDescriptions{'LF_to_TOT'} = 'LF to total power ratio';

hrv_fd.HF_to_TOT  = hrv_fd.HF_PWR  / hrv_fd.TOT_PWR;
hrv_fd.Properties.VariableUnits{'HF_to_TOT'} = '1';
hrv_fd.Properties.VariableDescriptions{'HF_to_TOT'} = 'HF to total power ratio';

% Calculate LF/HF ratio
hrv_fd.LF_to_HF  = hrv_fd.LF_PWR  / hrv_fd.HF_PWR;
hrv_fd.Properties.VariableUnits{'LF_to_HF'} = '1';
hrv_fd.Properties.VariableDescriptions{'LF_to_HF'} = 'LF to HF power ratio';

% Find peaks in the spectrum
lf_band_idx = f_axis >= lf_band(1) & f_axis <= lf_band(2);
hf_band_idx = f_axis >= hf_band(1) & f_axis <= hf_band(2);
[~, f_peaks_lf] = findpeaks(pxx(lf_band_idx), f_axis(lf_band_idx), 'SortStr','descend');
[~, f_peaks_hf] = findpeaks(pxx(hf_band_idx), f_axis(hf_band_idx), 'SortStr','descend');

hrv_fd.LF_PEAK = NaN;
hrv_fd.HF_PEAK = NaN;
if ~isempty(f_peaks_lf)
    hrv_fd.LF_PEAK = f_peaks_lf(1);
end
if ~isempty(f_peaks_hf)
    hrv_fd.HF_PEAK = f_peaks_hf(1);
end
hrv_fd.Properties.VariableUnits{'LF_PEAK'} = 'Hz';
hrv_fd.Properties.VariableDescriptions{'LF_PEAK'} = 'LF peak frequency';
hrv_fd.Properties.VariableUnits{'HF_PEAK'} = 'Hz';
hrv_fd.Properties.VariableDescriptions{'HF_PEAK'} = 'HF peak frequency';

%% Plot
plot_data.name = 'Intervals Spectrum';
plot_data.f_axis = f_axis;
plot_data.pxx_lomb = pxx_lomb;
plot_data.pxx_ar = pxx_ar;
plot_data.pxx_welch = pxx_welch;
plot_data.pxx_fft = pxx_fft;
plot_data.vlf_band = vlf_band;
plot_data.lf_band = lf_band;
plot_data.hf_band = hf_band;
plot_data.f_max = f_max;
plot_data.t_win = t_win;
plot_data.welch_overlap = welch_overlap;
plot_data.ar_order = ar_order;
plot_data.num_windows = num_windows;
plot_data.lf_peak = hrv_fd.LF_PEAK;
plot_data.hf_peak = hrv_fd.HF_PEAK;

if (should_plot)
    figure('Name', plot_data.name);
    plot_hrv_freq_spectrum(gca, plot_data);
end
end
