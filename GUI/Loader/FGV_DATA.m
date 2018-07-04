function prevDATA = FGV_DATA(CMD,newDATA)
persistent pDATA
switch CMD
    case 'get'
        prevDATA = pDATA;
    case 'set'
        pDATA = newDATA;
    case 'init'
        pDATA = [];
    otherwise
end
