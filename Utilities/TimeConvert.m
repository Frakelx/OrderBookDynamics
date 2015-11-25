clc;clear;

sourcePath = '.\Index Future Tick Data\TruncatedData';

files = dir([sourcePath,'\*.mat']);

for fIndex = 1:length(files)
    load([sourcePath,'\',files(fIndex).name]);
    ms = mod(data.time,1000);
    s = mod(data.time-ms, 10^5)/1000;
    minute = mod(data.time-ms-s*1000,10^7)/10^5;
    h = (data.time-ms-s*1000-minute*10^5)/10^7;
    %d = str2double(data.date(7:8));
    %Month = str2double(data.date(5:6));
    %y = str2double(data.date(1:4));
    data.FullTime = datetime(2001,01,01,h,minute,s+ms./1000,'Format','yyyy-MM-dd HH:mm:ss:SSS');
    
    save([sourcePath, '\', files(fIndex).name], 'data');
end