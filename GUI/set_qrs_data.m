%%
function DATA = set_qrs_data(DATA, QRS_data, time_data)
if time_data == 0
    if ~isempty(QRS_data) && sum(QRS_data > 0)
        % Convert indices to double so we can do calculations on them
        QRS_data = double(QRS_data);
        DATA.rri = diff(QRS_data)/DATA.SamplingFrequency;
        DATA.trr = QRS_data(1:end-1)/DATA.SamplingFrequency; % moving first peak at zero ms
    else
        close(waitbar_handle);
        throw(MException('LoadFile:Data', 'Could not Load the file. Please, choose the file with the QRS data and positive values'));
    end
else
    DATA.rri = double(QRS_data);
    DATA.trr = time_data;
end
end