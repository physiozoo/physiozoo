%%
function qrs = calc_r_peaks_from_ch(DATA, signal, peak_detector)

lcf = DATA.config_map('lcf');
hcf = DATA.config_map('hcf');
thr = DATA.config_map('thr');
rp  = DATA.config_map('rp');
ws  = DATA.config_map('ws');

temp_rec_name4wfdb = 'temp_ecg_wfdb_fid';

bpecg = mhrv.ecg.bpfilt(signal, DATA.Fs, lcf, hcf, [], 0);

if strcmp(peak_detector, 'jqrs')
    qrs_pos = mhrv.ecg.jqrs(bpecg, DATA.Fs, thr, rp, 0);
    qrs = qrs_pos';
elseif strcmp(peak_detector, 'wjqrs')
    qrs_pos = mhrv.ecg.wjqrs(bpecg, DATA.Fs, thr, rp, ws);
    qrs = qrs_pos';
elseif strcmp(peak_detector, 'rqrs')
    wfdb_record_name = [tempdir temp_rec_name4wfdb];
    mat2wfdb(signal, wfdb_record_name, DATA.Fs, [], ' ' ,{} ,[]);
    if ~exist([wfdb_record_name '.dat'], 'file') && ~exist([wfdb_record_name '.hea'], 'file')  
        throw(MException('calc_r_peaks_from_ch:text', 'Wfdb file cannot be created.'));
    end
    try
        [qrs, tm, sig, Fs] = mhrv.wfdb.rqrs(wfdb_record_name, 'gqconf', DATA.customConfigFile, 'ecg_channel', 1, 'plot', false);
    catch e
        throw(MException('calc_r_peaks_from_ch:text', 'Problems with peaks calculation..'));
    end
end

if ~isempty(qrs)
    qrs = double(unique(qrs));
end
if exist([tempdir temp_rec_name4wfdb '.hea'], 'file')
    delete([tempdir temp_rec_name4wfdb '.hea']);
end