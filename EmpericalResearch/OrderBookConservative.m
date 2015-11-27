clc;clear;

sourcePath = '.\Index Future Tick Data\TruncatedData';

scale = [1];
beta = zeros(length(scale),1);
rsquare = zeros(length(scale),1);
for iscale = 1:length(scale)
    
    timeScale = scale(iscale);  % second, you can adjust it
    
    timeSteps = seconds(timeScale);
    
    files = dir([sourcePath,'\201501*.mat']);
    
    Orders.outflow = zeros(length(files)*14400/timeScale,1);
    Orders.inflow = Orders.outflow;
    
    counter = 1;
    timeFlag = [datetime(0,0,0,9,30,0.0,'Format','HH:mm:ss:SSS'),datetime(0,0,0,11,30,0.0,'Format','HH:mm:ss:SSS'); ...
        datetime(0,0,0,13,0,0.0,'Format','HH:mm:ss:SSS'),datetime(0,0,0,15,0,0.0,'Format','HH:mm:ss:SSS')];
    timeGrid = [];
    for i = 1:2
        timeGrid = [timeGrid,timeFlag(i,1):timeSteps:timeFlag(i,2)];
    end
    
    tic;
    display(sprintf('***Orderbook Conservation Analysis: time scale %d seconds***', timeScale))
    for fIndex = 1:length(files)
        load([sourcePath,'\',files(fIndex).name]);
        
        
        for tIndex = 1:length(timeGrid)-1
            if(timeGrid(tIndex) == datetime(0,0,0,11,30,0.0,'Format','HH:mm:ss:SSS'))
                continue
            end
            
            index = find(data.time>=timeGrid(tIndex) & data.time<timeGrid(tIndex+1));
            if(isempty(index))
                continue;
            end
            
            Orders.inflow(counter) = sum(data.orderInflow(index));
            Orders.outflow(counter) = sum(data.orderOutflow(index));
            
            counter = counter+1;
        end
        
        display(sprintf('%.2f%% has been finished!',fIndex*100/length(files)));
        toc
    end
    
    stats = regstats(Orders.inflow, Orders.outflow, 'linear', {'beta','rsquare'});
    beta(iscale) = stats.beta(2,1);
    rsquare(iscale) = stats.rsquare;
    subplot(3,3,iscale);
    scatter(Orders.inflow, Orders.outflow);hold on;
    xlabel('Order inflow');
    ylabel('Order outflow');
    
    if(timeScale<=60)
        title([num2str(timeScale),' seconds']);
    else
        title([num2str(timeScale/60),' minutes']);
    end
    set(gca,'XLim',[0.8*min(Orders.inflow) 1.1*max(Orders.inflow)])
    set(gca,'YLim',[0.8*min(Orders.outflow) 1.1*max(Orders.outflow)])
    toc
end
