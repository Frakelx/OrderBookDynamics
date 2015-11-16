clc;clear;
targetPath = '.\Index Future Tick Data\TruncatedData';

files = dir([targetPath,'\*.mat']);

invalidDataList = [];

for i = 1:length(files)
    load([targetPath,'\',files(i).name]);
    if any(any(data.askPrice == 0) ==1) || any(any(data.bidPrice == 0) == 1)
        invalidDataList = [invalidDataList; files(i).name];
    end
end

save('./InvalidDataList.mat','invalidDataList');