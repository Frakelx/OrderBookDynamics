clc;clear;

sourcePath = '.\Index Future Tick Data\MatData';
targetPath = '.\Index Future Tick Data\TruncatedData';
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
    
%%% we assume ask1 (bid1) is ask1 (bid1); whereas ask2 (bid2) is askN (bidN), where N = [(ask2Price - ask1Price)/0.2 + 1]. It is same for ask3, ask4 and ask5
%%% Then we obtain standard orderbook where ask(N)Price - ask(N-1)Price = 1 tick
    effectiveData.Spread = effectiveData.askPrice(:,1) - effectiveData.bidPrice(:,1);   %%% bid-ask spread
    effectiveData.askDst = round((effectiveData.askPrice - repmat(effectiveData.askPrice(:,1), 1, 5))./0.2 + 1);    %%% distance away from ask1 (ticks)
    effectiveData.bidDst = round((effectiveData.bidPrice - repmat(effectiveData.bidPrice(:,1), 1, 5))./0.2 - 1);    %%% distance away from bid1 (ticks)
    effectiveData.askOrderbook = zeros(length(effectiveData.Spread),max(effectiveData.askDst(:,5)));
    effectiveData.bidOrderbook = zeros(length(effectiveData.Spread), -min(effectiveData.bidDst(:,5)));
    
    for j = 1:length(effectiveData.askOrderbook)
        effectiveData.askOrderbook(j,effectiveData.askDst(j,:)) = effectiveData.askSize(j,:);
    end
    for j = 1:length(effectiveData.bidOrderbook)
        effectiveData.bidOrderbook(j,abs(effectiveData.bidDst(j,:))) = effectiveData.bidSize(j,:);
    end
    
    
    
%%% Market Sell Order (MSO), Market Buy Order (MBO) arrival
%%% Limit Sell Order (LSO), Limit Buy Order (LBO) insertion and
%%% Cancellation (Cancel)
%     effectiveData.MSO = zeros(length(effectiveData.time));
%     effectiveData.MBO = zeros(length(effectiveData.time));
%     effectiveData.LSO = zeros(length(effectiveData.time), max(effectiveData.askDst(:,5)));
%     effectiveData.LBO = zeros(length(effectiveData.time), -min(effectiveData.bidDst(:,5)));
%     effectiveData.Cancel = zeros(lenght(effectiveData.time), 
%     
%     for j = 1:length(effectiveData.time)
%         if(effectiveData.volume(j) == 0 || j == 1)  %%% if volume = 0, any order is NOT placed.
%             effectiveData.MSO(j) = 0;
%             effectiveData.MBO(j) = 0;
%             effectiveData.LSO(j,:) = 0;
%             effectiveData.LBO(j,:) = 0;
%             effectiveData.Cancel(j,:) = 0;   
%         elseif(effectiveData.midQuote(j) == effectiveData.midQuote(j-1) && j > 1 ) %%% mid-quote stays the same
%             ratio = effectiveData.vwap(j)/effectiveData.midQuote(j);
%             if(ratio > 1)
%                 effectiveData.MSO(j) = 0;
%                 effectiveData.MBO(j) = effectiveData.volume(j);
%             elseif(ratio < 1)
%                 effectiveData.MSO(j) = effectiveData.volume(j);
%                 effectiveData.MBO(j) = 0;
%             else
%                 effectiveData.MSO(j) = floor(effectiveData.volume(j)/2);
%                 effectiveData.MBO(j) = floor(effectiveData.volume(j)/2);
%             end
% 
%         end
        
        
%    end
    
    data = effectiveData;
    if (i == 370)
        continue
    end
    save([targetPath, '\', files(i).name], 'data');
end