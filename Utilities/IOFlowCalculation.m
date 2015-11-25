clc;clear;

sourcePath = '.\Index Future Tick Data\TruncatedData';
files = dir([sourcePath,'\*.mat']);

invalidList = [];
for fIndex = 1:length(files)
    load([sourcePath,'\',files(fIndex).name])
    
    data.orderInflow = sum(data.LSO,2)+sum(data.LBO,2);
    data.orderOutflow = sum(data.BCancel,2)+sum(data.SCancel,2)+data.MSO+data.MBO;
    
    save([sourcePath, '\', files(fIndex).name], 'data');
end