%%
function pd_data = comp_fft(signal)

signal(isnan(signal)) = 0;

N = length(signal);
Hs = hamming(N ,'symmetric');
fft_two_sided = fft(Hs'.*signal);
fft_two_sided = abs(fft_two_sided/N);

fft_one_sided = fft_two_sided(1:fix(N/2+1));
fft_one_sided(2:end-1) = 2*fft_one_sided(2:end-1);

freq=(0:(N/2))/N;

pd_data.x = freq;
pd_data.y = fft_one_sided;