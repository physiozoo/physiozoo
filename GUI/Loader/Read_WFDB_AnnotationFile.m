function [UniqueMap, header,data] = Read_WFDB_AnnotationFile(header_info,UniqueMap,waitbar_handle,FileName,ext)
Channel.type = 'peak';
Channel.name = 'data';
Channel.enable = 'yes';
Channel.unit = 'index';
try
    comment = header_info.comments{1};
    comment = strsplit(comment,':');
    header.Integration_level = comment{3};
    comment = strsplit(comment{2},',');
    header.Mammal = comment{1};
catch
    
end

%% -----------  Read data from WFDB file ------------------------
sig = double(mhrv.wfdb.rdann(FileName, ext(2:end)));
data.data = sig(3:end)-1;          

%% --------------------Build Channels Information for Loader ---------------------------------------------

header.Channels = {Channel};
UniqueMap('IsHeader') = true;
header.Fs = header_info.Fs;