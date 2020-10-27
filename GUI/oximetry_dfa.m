function [ n, fn, plot_data ] = oximetry_dfa(sig)
%Detrended fluctuation analysis, DFA [1]_. Calculates the DFA of a signal and it's
%scaling exponents :math:`\alpha_1` and :math:`\alpha_2`.
%
%:param t: time (or x values of signal)
%:param sig: signal data (or y values of signal)
%:param varargin: Pass in name-value pairs to configure advanced options:
%   
%   - n_min: Minimal DFA block-size (default 4)
%   - n_max: Maximal DFA block-size (default 64)
%   - n_incr: Increment value for n (default 2). Can also be less than 1, in
%     which case we interpret it as the ratio of a geometric series on box sizes
%     (n). This should produce box size values identical to the PhysioNet DFA
%     implmentation.
%
%:returns:
%
%   - n: block sizes (x-axis of DFA)
%   - fn: DFA value for each block size n
%
%.. [1] Peng, C.-K., Hausdorff, J. M. and Goldberger, A. L. (2000) ‘Fractal mechanisms
%   in neuronal control: human heartbeat and gait dynamics in health and disease,
%   Self-organized biological dynamics and nonlinear control.’ Cambridge:
%   Cambridge University Press.
%

n_min = 4;
n_max = 128;
n_incr = 1;

% Calculate zero-based interval time axis
sig = sig(:);
t = [0; cumsum(sig(1:end-1))];

%% Initializations

% Integrate the signal without mean
nni_int = cumsum(sig - mean(sig, 'omitnan'));

N = length(nni_int);

% Create n-axis (box-sizes)
% If n_incr is less than 1 we interpret it as the ratio of a geometric
% series on box sizes. This should produce box sizes identical to the
% PhysioNet DFA implmentation.
if n_incr < 1
    M = log2(n_max/n_min) * (1/n_incr);
    n = unique(floor(n_min.*(2^n_incr).^(0:M)+0.5));
else
    n = n_min:n_incr:n_max;
end

fn = ones(n_max, 1) * NaN;

%% DFA
for nn = n
    % Calculate the number of windows we need for the current n
    num_win = floor(N/nn);

    % Break the signal into num_win windows of n samples each
    sig_windows = reshape(nni_int(1:nn*num_win), nn, num_win);
    t_windows  = reshape(t(1:nn*num_win), nn, num_win);
    sig_regressed = zeros(size(sig_windows));

    % Perform linear regression in each window
    for ii = 1:num_win
        y = sig_windows(:, ii);
        x = [ones(nn, 1), t_windows(:, ii)];
        b = x\y;
        yn = x * b;
        sig_regressed(:, ii) = yn;
    end

    % Calculate F(n), the value of the DFA for the current n
    fn(nn) = sqrt ( 1/N * sum((sig_windows(:) - sig_regressed(:)).^2, 'omitnan') );
end

% Find the indices of all the DFA values we calculated
fn = fn(n);
n  = n';

% If fn is zero somewhere (might happen in the small scales if there's not
% enough data points there) set it to some small constant to prevent
% log(0)=-Inf.
fn(fn<1e-9) = 1e-9;

%% Plot
plot_data.name = 'DFA';
plot_data.n = n;
plot_data.fn = fn;

