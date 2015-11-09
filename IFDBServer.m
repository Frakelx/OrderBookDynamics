classdef IFDBServer
    properties
        db
    end
    properties
        curs
    end
    methods
        function obj = IFDBServer(DBName)
            setdbprefs('datareturnformat','numeric');
            setdbprefs('FetchInBatches','yes')
            setdbprefs('FetchBatchSize','10000')
            obj.db = database.ODBCConnection(DBName,'','');
        end
        function data = retrieveData(obj,varargin)
            if nargin == 3
                filename = [varargin{1},'_',varargin{2},'.csv'];
            else
                filename = varargin{1};
            end
            colName = '时间,成交量,成交额,卖5价,卖4价,卖3价,卖2价,卖1价,买1价,买2价,买3价,买4价,买5价,卖5量,卖4量,卖3量,卖2量,卖1量,买1量,买2量,买3量,买4量,买5量';
            
            sqlCommand = ['select ',colName,' from ',filename];
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
            data.time = rawData(2:end,1);
            data.volume = rawData(2:end,2);
            data.turnover = rawData(2:end,3);
            data.aPrice5 = rawData(2:end,4);
            data.aPrice4 = rawData(2:end,5);
            data.aPrice3 = rawData(2:end,6);
            data.aPrice2 = rawData(2:end,7);
            data.aPrice1 = rawData(2:end,8);
            data.bPrice1 = rawData(2:end,9);
            data.bPrice2 = rawData(2:end,10);
            data.bPrice3 = rawData(2:end,11);
            data.bPrice4 = rawData(2:end,12);
            data.bPrice5 = rawData(2:end,13);
            
            data.aSize5 = rawData(2:end,14);
            data.aSize4 = rawData(2:end,15);
            data.aSize3 = rawData(2:end,16);
            data.aSize2 = rawData(2:end,17);
            data.aSize1 = rawData(2:end,18);
            data.bSize1 = rawData(2:end,19);
            data.bSize2 = rawData(2:end,20);
            data.bSize3 = rawData(2:end,21);
            data.bSize4 = rawData(2:end,22);
            data.bSize5 = rawData(2:end,23);
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