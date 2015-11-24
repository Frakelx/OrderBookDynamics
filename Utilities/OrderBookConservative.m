clc;clear;

sourcePath = '.\Index Future Tick Data\TruncatedData';

timeScale = 1;  % minute, you can adjust it

timeScale = timeScale*100000;
timeFlag = ...
    [93000050, 100000050, 110000050, 130000050, 140000050; ...
    96000050, 106000050, 113000050, 136000050, 146000050];

files = dir([sourcePath,'\*.mat']);

Orders.outflow = zeros(length(files)*240/(timeScale/100000),1);
Orders.inflow = Orders.outflow;
Orders.volume = Orders.outflow;
counter = 1;

for fIndex = 1:length(files)
    load([sourcePath,'\',files(fIndex).name]);
    
    for i = 1:5
        timeGrid = timeFlag(1,i):timeScale:timeFlag(2,i);
        for tIndex = 1:length(timeGrid)-1
            index = find(data.time>=timeGrid(tIndex) & data.time<timeGrid(tIndex+1));
            if(isempty(index))
                continue;
            end
            %Orders.inflow(counter) = sum(sum(data.LSO(index,:)))+sum(sum(data.LBO(index,:)));
            %Orders.outflow(counter) = sum(sum(data.BCancel(index,:)))+sum(sum(data.SCancel(index,:))) ...
            %+sum(data.MSO(index)+data.MBO(index));
            %Orders.volume(counter) = sum(data.volume(index));
            Orders.inflow(counter) = sum(data.orderInflow(index));
            Orders.outflow(counter) = sum(data.orderOutflow(index));
            Orders.volume(counter) = sum(data.volume(index));
            
            counter = counter+1;
        end
    end
end

IO = Orders.inflow./Orders.outflow;
IV = Orders.inflow./Orders.volume;
VO = Orders.volume./Orders.outflow;
figure;
scatter(Orders.inflow, Orders.outflow);hold on;
xlabel('Order inflow');
ylabel('Order outflow');
title(' 1 minute ');