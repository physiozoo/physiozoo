%%
function [signalDurationInSec, isInputNumeric]  = calcDurationInSeconds(GUIFiled, NewFieldValue, OldFieldValue)
duration = sscanf(NewFieldValue, '%d:%d:%d.%d');

isInputNumeric = true;

if length(duration) == 1 && duration(1) > 0
    signalDuration = calcDuration(duration(1), 0);
    set(GUIFiled, 'String', signalDuration);
    signalDurationInSec = duration(1);
elseif length(duration) == 3 && duration(1) >= 0 && duration(2) >= 0 && duration(3) >= 0
    signalDurationInSec = duration(1)*3600 + duration(2)*60 + duration(3);
elseif length(duration) == 4 && duration(1) >= 0 && duration(2) >= 0 && duration(3) >= 0 && duration(4) >= 0
    signalDurationInSec = duration(1)*3600 + duration(2)*60 + duration(3)+ duration(4)/1000;
else
    set(GUIFiled, 'String', calcDuration(OldFieldValue, 0));
    h_w = warndlg('Please, check your input');
    setLogo(h_w, 'M2');
    isInputNumeric = false;
    signalDurationInSec = [];
end
