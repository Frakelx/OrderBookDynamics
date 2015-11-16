sourcePath = '.\Index Future Tick Data\DataBase';
targetPath = '.\Index Future Tick Data\MatData';

if(~exist(targetPath,'dir'))
    mkdir(targetPath);
end

load ContractList

dataServer = IFDBServer('IFDB');
for i = 1:length(contractList)
    strings = regexp(contractList{i},'\.','split');
    if(~exist([targetPath,'\',strings{1},'.mat'],'file'))
        data = dataServer.retrieveData(contractList{i});
        data.midQuote = 0.5.*(data.aPrice1+data.bPrice1);
        data.vwap = data.turnover./data.volume;
        save([targetPath,'\',strings{1},'.mat'],'data');
    end
end

dataServer.clearObj();