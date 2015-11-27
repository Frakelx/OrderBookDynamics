clc;clear;

sourcePath = '.\Index Future Tick Data\TruncatedData';

scale = [1, 5, 15, 30, 60, 300, 900, 1800, 3600];
beta = zeros(length(scale),1);
rsquare = zeros(length(scale),1);
for iscale = 1:length(scale)
    timeScale = scale(iscale);  % second, you can adjust it

    timeSteps = seconds(timeScale);

    files = dir([sourcePath,'\201501*.mat']);

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
    stats = regstats(Orders.inflow, Orders.outflow, 'linear', {'beta','rsquare'});
    beta(iscale) = stats.beta(2,1);
    rsquare(iscale) = stats.rsquare;
    subplot(3,3,iscale);
    scatter(Orders.inflow, Orders.outflow);hold on;
    xlabel('Order inflow');
    ylabel('Order outflow');
    if(iscale == 1) 
        title('1s');
    elseif(iscale == 2) 
        title('5s');
    elseif(iscale == 3) 
        title('15s');
    elseif(iscale == 4)
        title('30min');
    elseif(iscale == 5)
        title('1min');
    elseif(iscale == 6)
        title('5min');
    elseif(iscale == 7)
        title('15min');
    elseif(iscale == 8)
        title('30min');
    else
        title('60min');
    end
end

IO = Orders.inflow./Orders.outflow;
IV = Orders.inflow./Orders.volume;
VO = Orders.volume./Orders.outflow;
