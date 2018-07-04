classdef FGV
    properties (Constant)
        INIT = 'init'
        GET = 'get'
        SET = 'set'
    end
    properties ( Access = protected)
        data = [];
    end
    methods
        function obj = FGV(newDATA)
             obj.data = newDATA;
        end
        function SET_DATA(obj,newDATA)
            obj.data = newDATA;
        end
        function prevDATA = GET_DATA(obj)
            prevDATA = obj.data;
        end
        function prevDATA = DATA(obj,CMD,newDATA)
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
        end
    end
end
