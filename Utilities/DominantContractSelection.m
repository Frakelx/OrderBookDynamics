path = 'D:\HKUST\Orderbook Dynamics\sandbox\Index Future Tick Data\DataBase';

load('DateList.mat');
dataServer = IFDBServer('IFDB');
dateList = num2str(dateList);
contractList = cell(length(dateList),1);

for day = 1:length(dateList)
    files = dir([path,'\',dateList(day,:),'_*.csv']);
    cumVol = zeros(length(files),1);
    for i = 1:length(files)
        data = dataServer.retrieveData(files(i).name);
        cumVol(i) = sum(data.volume);
    end
    [value, pos] = max(cumVol);
    contractList{day,1} = files(pos).name;
end
dataServer.clearObj();
save('contractList.mat',contractList);