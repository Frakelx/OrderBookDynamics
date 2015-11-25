clc;clear;

sourcePath = '.\Index Future Tick Data\TruncatedData';

timeScale = 60;  % second, you can adjust it

timeSteps = seconds(timeScale);

files = dir([sourcePath,'\*.mat']);

Orders.outflow = zeros(length(files)*14400/timeScale,1);
Orders.inflow = Orders.outflow;
Orders.volume = Orders.outflow;
counter = 1;
timeFlag = [datetime(2001,01,01,9,30,00),datetime(2001,01,01,11,30,00); ...
                datetime(2001,01,01,13,00,00),datetime(2001,01,01,15,00,00)];
            
for fIndex = 1:length(files)
    load([sourcePath,'\',files(fIndex).name]);
    
    for i = 1:2
        timeGrid = timeFlag(i,1):timeSteps:timeFlag(i,2);
        for tIndex = 1:length(timeGrid)-1
            index = find(data.FullTime>=timeGrid(tIndex) & data.FullTime<timeGrid(tIndex+1));
            if(isempty(index))
                continue;
            end
            
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
title(' 30 s ');