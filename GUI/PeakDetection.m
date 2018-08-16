function peaks = PeakDetection(x,ff,varargin)
%
% peaks = PeakDetection(x,f,flag),
% R-peak detector based on max search
%
% inputs:
% x: vector of input data
% f: approximate ECG beat-rate in Hertz, normalized by the sampling frequency
% flag: search for positive (flag=1) or negative (flag=0) peaks. By default
% the maximum absolute value of the signal, determines the peak sign.
%
% output:
% peaks: vector of R-peak impulse train
%
% Notes:
% - The R-peaks are found from a peak search in windows of length N; where
% N corresponds to the R-peak period calculated from the given f. R-peaks
% with periods smaller than N/2 or greater than N are not detected.
% - The signal baseline wander is recommended to be removed before the
% R-peak detection
%
%
% Open Source ECG Toolbox, version 1.0, November 2006
% Released under the GNU General Public License
% Copyright (C) 2006  Reza Sameni
% Sharif University of Technology, Tehran, Iran -- GIPSA-Lab, INPG, Grenoble, France
% reza.sameni@gmail.com

% Modified 03_02_2013: Joachim Behar, IPMG Oxford.
% Modified 04_29_2013: Xiaopeng Zhao, UTK

% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version.
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.

N = length(x);
peaks = zeros(1,N);

% determine whether the wave is upward or downward
if(nargin==3)
    flag = varargin{1};
else
    flag = abs(max(x))>abs(min(x));
end

% determine the minimal interval between two beats
% for adults, we use th = 0.5
% for fetus, we use th = 0.3
if(nargin==4)
    th = varargin{2};
else
    th = .5;
end
rng = floor(th/ff);

if(flag)
    for j = 1:N,
        %         index = max(j-rng,1):min(j+rng,N);
        if(j>rng && j<N-rng)
            index = j-rng:j+rng;
        elseif(j>rng)
            index = j-rng:N;
        else %j<rng
            index = 1:j+rng;
        end
        
        if(max(x(index))==x(j))
            peaks(j) = 1;
        end
    end
else
    for j = 1:N,
        %         index = max(j-rng,1):min(j+rng,N);
        if(j>rng && j<N-rng)
            index = j-rng:j+rng;
        elseif(j>rng)
            index = N-2*rng:N;
        else
            index = 1:2*rng;
        end
        
        if(min(x(index))==x(j))
            peaks(j) = 1;
        end
    end
end


% % --- XZ: I suspect the following is not effective since the above
% % algorithms will not identify points which are placed too close to each
% % other.
% % remove fake peaks
% I = find(peaks);
% d = diff(I);
% % z = find(d<rng);
% peaks(I(d<rng))=0;

% peaks = find(peaks);


% ---- XZ: remove fake peaks
% remove points whose energies are too low
e_th=0.25*median(x(peaks==1));
peaks=find(x>e_th & peaks==1);

end


