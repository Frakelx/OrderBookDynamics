classdef IFDBServer
    properties
        db
    end
    properties
        curs
    end
    methods
        function obj = IFDBServer(DBName)
            obj.db = database(DBName,'','');
        end
        function data = retrieveData(obj,varargin)
            if nargin == 3
                filename = [varargin{1},'_',varargin{2},'.csv'];
            else
                filename = varargin{1};
            end
            sqlCommand = ['select 时间,成交量,成交额,卖5价,卖4价,卖3价,卖2价,卖1价,买1价,买2价,买3价,买4价,买5价,卖5量,卖4量,卖3量,卖2量,卖1量,买1量,买2量,买3量,买4量,买5量 from ',filename];
            obj.curs = exec(obj.db, sqlCommand);
            obj.curs = fetch(obj.curs);
            rawData = obj.curs.Data;
            
            if nargin == 3
                data.name = varargin{2};
                data.date = varargin{1};
            else
                str = regexp(varargin{1},'[\._]','split');
                data.name = str{2};
                data.date = str{1};
            end
            data.time = cell2mat(rawData(2:end,1));
            data.volume = cell2mat(rawData(2:end,2));
            data.turnover = cell2mat(rawData(2:end,3));
            data.aPrice5 = cell2mat(rawData(2:end,4));
            data.aPrice4 = cell2mat(rawData(2:end,5));
            data.aPrice3 = cell2mat(rawData(2:end,6));
            data.aPrice2 = cell2mat(rawData(2:end,7));
            data.aPrice1 = cell2mat(rawData(2:end,8));
            data.bPrice1 = cell2mat(rawData(2:end,9));
            data.bPrice2 = cell2mat(rawData(2:end,10));
            data.bPrice3 = cell2mat(rawData(2:end,11));
            data.bPrice4 = cell2mat(rawData(2:end,12));
            data.bPrice5 = cell2mat(rawData(2:end,13));
            
            data.aSize5 = cell2mat(rawData(2:end,14));
            data.aSize4 = cell2mat(rawData(2:end,15));
            data.aSize3 = cell2mat(rawData(2:end,16));
            data.aSize2 = cell2mat(rawData(2:end,17));
            data.aSize1 = cell2mat(rawData(2:end,18));
            data.bSize1 = cell2mat(rawData(2:end,19));
            data.bSize2 = cell2mat(rawData(2:end,20));
            data.bSize3 = cell2mat(rawData(2:end,21));
            data.bSize4 = cell2mat(rawData(2:end,22));
            data.bSize5 = cell2mat(rawData(2:end,23));
        end
        
        function obj = set.curs(obj,curs)
            obj.curs = curs;
        end
        function obj = clearObj(obj)
            close(obj.curs)
            close(obj.db)
        end
    end
end