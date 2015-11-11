clc;clear;

sourcePath = 'D:\HKUST\Orderbook Dynamics\sandbox\Index Future Tick Data\MatData';
targetPath = 'D:\HKUST\Orderbook Dynamics\sandbox\Index Future Tick Data\TruncatedData';
startTime = 93000000;
stopTime = 150000000;
if(~exist(targetPath,'dir'))
    mkdir(targetPath);
end

files = dir([sourcePath,'\*.mat']);

for i = 1:length(files)
    if(exist([targetPath,'\',files(i).name,'.mat'],'file'))
        continue;
    end
    
    load(files(i).name)
    effectiveData.name = data.name;
    effectiveData.date = data.date;
    
    index = find(data.time>=startTime & data.time <= stopTime);
    effectiveData.time = data.time(index);
    effectiveData.volume = data.volume(index);
    effectiveData.turnover = data.turnover(index);
    effectiveData.vwap = data.vwap(index)./300;
    effectiveData.midQuote = data.midQuote(index)./10000;
    effectiveData.askPrice = [data.aPrice1(index), data.aPrice2(index), ...
                              data.aPrice3(index), data.aPrice4(index), data.aPrice5(index)]./10000;
    effectiveData.askSize = [data.aSize1(index), data.aSize2(index), ...
                             data.aSize3(index),data.aSize4(index),data.aSize5(index)];
    effectiveData.bidPrice = [data.bPrice1(index), data.bPrice2(index), ...
                              data.bPrice3(index), data.bPrice4(index), data.bPrice5(index)]./10000;
    effectiveData.bidSize = [data.bSize1(index), data.bSize2(index), ...
                             data.bSize3(index),data.bSize4(index),data.bSize5(index)];
    data = effectiveData;
    
    save([targetPath, '\', files(i).name], 'data');
end