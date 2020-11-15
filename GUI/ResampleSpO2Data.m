%%
function [rri_resampled, time_data] = ResampleSpO2Data(rri, Original_fs)
disp('Resamping');

% rri_resampled = [];

% if SamplingFrequency ~= SpO2NewSamplingFrequency
    
    wb = waitbar(0, 'SpO2: Resampling ... ', 'Name', 'SpO2'); setLogo(wb, 'M2');
    
    rri_resampled = ResampSpO2(rri, Original_fs, wb);
    
    if isvalid(wb); close(wb); end
    
    if isempty(rri_resampled)
        throw(MException('ResampleSpO2Data:Data', 'Could not Resample SpO2 data.'));
    end
%     Fs = SpO2NewSamplingFrequency;
% else
%     rri_resampled = rri;
%     Fs = SamplingFrequency;
% end

time_data = 0 : 1 : length(rri_resampled)-1;

% time_data = time_data - time_data(1);

% set_qrs_data(DATA.rri, time_data);