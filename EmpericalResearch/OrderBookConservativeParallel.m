clc;clear;

sourcePath = '.\Index Future Tick Data\TruncatedData';

scale = [1, 5, 15, 30, 60, 300, 900, 1800];
beta = zeros(length(scale),1);
rsquare = zeros(length(scale),1);
for iscale = 1:length(scale)
    
    timeScale = scale(iscale);  % second, you can adjust it
    
    timeSteps = seconds(timeScale);
    
    files = dir([sourcePath,'\201508*.mat']);
%     files2 = dir([sourcePath,'\201505*.mat']);
%     files3 = dir([sourcePath,'\201506*.mat']);
%     
%     fields = fieldnames(files1);
%     temp = [struct2cell(files1), struct2cell(files2), struct2cell(files3)];
%     files = cell2struct(temp,fields);
%     clear files1 files2 files3 temp
    
%     timeFlag = [datetime(0,0,0,9,30,0.0,'Format','HH:mm:ss:SSS'),datetime(0,0,0,11,30,0.0,'Format','HH:mm:ss:SSS'); ...
%         datetime(0,0,0,13,0,0.0,'Format','HH:mm:ss:SSS'),datetime(0,0,0,15,0,0.0,'Format','HH:mm:ss:SSS')];
%     timeGrid = [];
%     for i = 1:2
%         timeGrid = [timeGrid,timeFlag(i,1):timeSteps:timeFlag(i,2)];
%     end
    
    timeGrid = datetime(0,0,0,11,0,0.0,'Format','HH:mm:ss:SSS'):timeSteps:datetime(0,0,0,11,30,0.0,'Format','HH:mm:ss:SSS');
    N = length(files);
    
    outflow = zeros((length(timeGrid)-1),N);
    inflow = outflow;
    
    display(sprintf('***Orderbook Conservation Analysis: time scale %d seconds***', timeScale))
    tic;
    parfor fIndex = 1:N
        x = load([sourcePath,'\',files(fIndex).name]);
        data = x.data;
        counter = 1;
        tempIn = zeros((length(timeGrid)-1),1);
        tempOut = tempIn;
        for tIndex = 1:length(timeGrid)-1
            if(timeGrid(tIndex) == datetime(0,0,0,11,30,0.0,'Format','HH:mm:ss:SSS'))
                continue
            end
            
            index = find(data.time>=timeGrid(tIndex) & data.time<timeGrid(tIndex+1));
            if(isempty(index))
                continue;
            end
            
            tempIn(counter) = sum(data.orderInflow(index));
            tempOut(counter) = sum(data.orderOutflow(index));
            
            counter = counter+1;
        end
        inflow(:,fIndex) = tempIn;
        outflow(:,fIndex) = tempOut;
        
        display(sprintf('File: %s has been finished!',files(fIndex).name));
        %toc
    end
    inflow = inflow(:);
    outflow = outflow(:);
    stats = regstats(inflow, outflow, 'linear', {'beta','rsquare'});
    beta(iscale) = stats.beta(2,1);
    rsquare(iscale) = stats.rsquare;
    subplot(3,3,iscale);
    scatter(inflow, outflow);hold on;
    xlabel('Order inflow');
    ylabel('Order outflow');
    
    if(timeScale<60)
        title([num2str(timeScale),' seconds']);
    else
        title([num2str(timeScale/60),' minutes']);
    end
    set(gca,'XLim',[0.8*min(inflow) 1.1*max(inflow)])
    set(gca,'YLim',[0.8*min(outflow) 1.1*max(outflow)])
    toc
end
toc