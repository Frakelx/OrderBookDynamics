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
    if(exist([targetPath,'\',files(i).name],'file'))
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
    
    gapValue = diff(effectiveData.time);
    gapPosition = find(gapValue >500 & gapValue < 40500);
    
    for gap_I = 1:length(gapPosition)
        effectiveData.time = [effectiveData.time(1:gapPosition(gap_I));effectiveData.time(gapPosition(gap_I)).*ones(gapValue(gapPosition(gap_I))/500-1,1);effectiveData.time(gapPosition(gap_I)+1:end)];
        gapValue = [gapValue(1:gapPosition(gap_I));500.*ones(gapValue(gapPosition(gap_I))/500-1,1);gapValue(gapPosition(gap_I)+1:end)];
        for gap_J = 1:gapValue(gapPosition(gap_I))/500-1
            effectiveData.time(gapPosition(gap_I) + gap_J) = effectiveData.time(gapPosition(gap_I) + gap_J) + 500*gap_J;
        end
        effectiveData.volume = [effectiveData.volume(1:gapPosition(gap_I));zeros(gapValue(gapPosition(gap_I))/500-1,1);effectiveData.volume(gapPosition(gap_I)+1:end)];
        effectiveData.turnover = [effectiveData.turnover(1:gapPosition(gap_I));zeros(gapValue(gapPosition(gap_I))/500-1,1);effectiveData.turnover(gapPosition(gap_I)+1:end)];
        effectiveData.vwap = [effectiveData.vwap(1:gapPosition(gap_I));effectiveData.vwap(gapPosition(gap_I)).*ones(gapValue(gapPosition(gap_I))/500-1,1);effectiveData.vwap(gapPosition(gap_I)+1:end)];
        effectiveData.midQuote = [effectiveData.midQuote(1:gapPosition(gap_I));effectiveData.midQuote(gapPosition(gap_I)).*ones(gapValue(gapPosition(gap_I))/500-1,1);effectiveData.midQuote(gapPosition(gap_I)+1:end)];
        effectiveData.askPrice = [effectiveData.askPrice(1:gapPosition(gap_I),:);repmat(effectiveData.askPrice(gapPosition(gap_I),:),gapValue(gapPosition(gap_I))/500-1,1);effectiveData.askPrice(gapPosition(gap_I)+1:end,:)];
        effectiveData.askSize = [effectiveData.askSize(1:gapPosition(gap_I),:);repmat(effectiveData.askSize(gapPosition(gap_I),:),gapValue(gapPosition(gap_I))/500-1,1);effectiveData.askSize(gapPosition(gap_I)+1:end,:)];
        effectiveData.bidPrice = [effectiveData.bidPrice(1:gapPosition(gap_I),:);repmat(effectiveData.bidPrice(gapPosition(gap_I),:),gapValue(gapPosition(gap_I))/500-1,1);effectiveData.bidPrice(gapPosition(gap_I)+1:end,:)];
        effectiveData.bidSize = [effectiveData.bidSize(1:gapPosition(gap_I),:);repmat(effectiveData.bidSize(gapPosition(gap_I),:),gapValue(gapPosition(gap_I))/500-1,1);effectiveData.bidSize(gapPosition(gap_I)+1:end,:)];
        
        gapPosition = gapPosition + gapValue(gapPosition(gap_I))/500-1;
    end
    
    %%% we assume ask1 (bid1) is ask1 (bid1); whereas ask2 (bid2) is askN (bidN), where N = [(ask2Price - ask1Price)/0.2 + 1]. It is same for ask3, ask4 and ask5
    %%% Then we obtain standard orderbook where ask(N)Price - ask(N-1)Price = 1 tick
    effectiveData.Spread = round((effectiveData.askPrice(:,1) - effectiveData.bidPrice(:,1))/0.2);   %%% bid-ask spread
    effectiveData.bid1move = [0;round(diff(effectiveData.bidPrice(:,1))./0.2)]; %%% bid1 movement
    effectiveData.ask1move = [0;round(diff(effectiveData.askPrice(:,1))./0.2)]; %%% ask1 movement
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
    %%% Sell Cancellation (SCancel), Buy Cancellation (BCancel).
    effectiveData.MSO = zeros(length(effectiveData.time),1);
    effectiveData.MBO = zeros(length(effectiveData.time),1);
    effectiveData.LSO = zeros(length(effectiveData.time), max(effectiveData.askDst(:,5)));
    effectiveData.LBO = zeros(length(effectiveData.time), -min(effectiveData.bidDst(:,5)));
    effectiveData.SCancel = zeros(length(effectiveData.time), max(effectiveData.askDst(:,5)));
    effectiveData.BCancel = zeros(length(effectiveData.time), -min(effectiveData.bidDst(:,5)));
    
    x1 = size(effectiveData.askOrderbook,2); x2 = size(effectiveData.bidOrderbook,2);
    for j = 1:length(effectiveData.time)
        %%% Notation Change
        y = effectiveData.bid1move(j); z = effectiveData.ask1move(j);
        
        %%% Market Order direction: Sell, Buy or Both
        ratio = effectiveData.vwap(j)/effectiveData.midQuote(j);
        if(ratio > 1)
            effectiveData.MBO(j) = effectiveData.volume(j);
        elseif(ratio < 1)
            effectiveData.MSO(j) = effectiveData.volume(j);
        else
            effectiveData.MBO(j) = ceil(effectiveData.volume(j)/2);
            effectiveData.MSO(j) = floor(effectiveData.volume(j)/2);
        end
            
        if(effectiveData.volume(j) == 0 || j == 1)  %%% if volume = 0, any order is NOT placed.
            continue;        
        
        elseif(y > 0 && z > 0) %%% bid1 increases, ask1 increases            
            effectiveData.LBO(j,1:min(y,x2)) = effectiveData.bidOrderbook(j,1:min(y,x2));
            effectiveData.LBO(j,1) = effectiveData.LBO(j,1) + effectiveData.MSO(j);
            effectiveData.BCancel(j,max(x2-y+1,1):end) = effectiveData.bidOrderbook(j-1,max(x2-y+1,1):end);
            if(y + 1 <= x2)
                effectiveData.LBO(j,min(y+1,x2):end) = ...
                    max(effectiveData.bidOrderbook(j,min(y+1,x2):end) - effectiveData.bidOrderbook(j-1,1:(x2-y)), 0);
                effectiveData.BCancel(j,1:(x2-y)) = ...
                    -min(effectiveData.bidOrderbook(j,min(y+1,x2):end) - effectiveData.bidOrderbook(j-1,1:(x2-y)), 0);
            end
            effectiveData.LSO(j,max(x1-z+1,1):end) = effectiveData.askOrderbook(j,max(x1-z+1,1):end);            
            if(x1 > z)
                effectiveData.LSO(j,1:x1-z) = ...
                    max(effectiveData.askOrderbook(j,1:x1-z) - effectiveData.askOrderbook(j-1,z+1:end), 0);
                effectiveData.SCancel(j,z+1:end) = ...
                    -min(effectiveData.askOrderbook(j,1:x1-z) - effectiveData.askOrderbook(j-1,z+1:end), 0);
            end
            if(effectiveData.MBO(j) - sum(effectiveData.askOrderbook(j-1,1:min(z,x1))) <= 0)
                volume = effectiveData.MBO(j);
                for k = 1:min(z,x1)
                    effectiveData.SCancel(j,k) = max(effectiveData.askOrderbook(j-1,k) - volume, 0);
                    volume = max(volume - effectiveData.askOrderbook(j-1,k),0);
                end
            else
                effectiveData.LSO(j,1) = ...
                    effectiveData.LSO(j,1) + max(effectiveData.MBO(j) - sum(effectiveData.askOrderbook(j-1,1:min(z,x1))),0);
            end
                             
        elseif(y >= 0 && z <= 0 && y ~= 0 && z~= 0) %%% bid1 increases; ask1 decreases
            effectiveData.LSO(j,1:min(-z,x1)) = effectiveData.askOrderbook(j,1:min(-z,x1));
            effectiveData.LSO(j,1) = effectiveData.LSO(j,1) + effectiveData.MBO(j);
            effectiveData.LBO(j,1:min(y,x2)) = effectiveData.bidOrderbook(j,1:min(y,x2));
            effectiveData.LBO(j,1) = effectiveData.LBO(j,1) + effectiveData.MSO(j);
            effectiveData.SCancel(j,max(x1+z+1,1):end) = effectiveData.askOrderbook(j-1,max(x1+z+1,1):end);
            effectiveData.BCancel(j,max(x2-y+1,1):end) = effectiveData.bidOrderbook(j-1,max(x2-y+1,1):end);
            if(-z < x1)
                effectiveData.LSO(j,-z+1:end) = ...
                    max(effectiveData.askOrderbook(j,-z+1:end) - effectiveData.askOrderbook(j-1,1:(x1+z)), 0);
                effectiveData.SCancel(j,1:(x1+z)) = ...
                    -min(effectiveData.askOrderbook(j,-z+1:end) - effectiveData.askOrderbook(j-1,1:(x1+z)), 0);
            end
            if(y < x2)
                effectiveData.LBO(j,y+1:end) = ...
                    max(effectiveData.bidOrderbook(j,y+1:end) - effectiveData.bidOrderbook(j-1,1:x2-y), 0);
                effectiveData.BCancel(j,1:(x2-y)) = ...
                    -min(effectiveData.bidOrderbook(j,y+1:end) - effectiveData.bidOrderbook(j-1,1:x2-y), 0);
            end
            
        elseif(y <= 0 && z >= 0 && y ~= 0 && z ~= 0) %%% bid1 decreases, ask1 increases
            effectiveData.LSO(j,max(x1-z+1,1):end) = effectiveData.askOrderbook(j,max(x1-z+1,1):end);            
            if(x1 > z)
                effectiveData.LSO(j,1:x1-z) = ...
                    max(effectiveData.askOrderbook(j,1:x1-z) - effectiveData.askOrderbook(j-1,z+1:end), 0);
                effectiveData.SCancel(j,z+1:end) = ...
                    -min(effectiveData.askOrderbook(j,1:x1-z) - effectiveData.askOrderbook(j-1,z+1:end), 0);
            end
            if(effectiveData.MBO(j) - sum(effectiveData.askOrderbook(j-1,1:min(z,x1))) <= 0 && effectiveData.MBO(j) ~= 0)
                volume = effectiveData.MBO(j);
                for k = 1:min(z,x1)
                    effectiveData.SCancel(j,k) = max(effectiveData.askOrderbook(j-1,k) - volume, 0);
                    volume = max(volume - effectiveData.askOrderbook(j-1,k),0);
                end
            else
                effectiveData.LSO(j,1) = ...
                    effectiveData.LSO(j,1) + max(effectiveData.MBO(j) - sum(effectiveData.askOrderbook(j-1,1:min(z,x1))),0);
            end
            effectiveData.LBO(j,max(1,x2+y+1):end) = effectiveData.bidOrderbook(j,max(1,x2+y+1):end);
            if(x2 > -y)
                effectiveData.LBO(j,1:x2+y) = ...
                    max(effectiveData.bidOrderbook(j,1:x2+y) - effectiveData.bidOrderbook(j-1,-y+1:end),0);
                effectiveData.BCancel(j,-y+1:end) = ...
                    -min(effectiveData.bidOrderbook(j,1:x2+y) - effectiveData.bidOrderbook(j-1,-y+1:end),0);
            end
            if(effectiveData.MSO(j) - sum(effectiveData.bidOrderbook(j-1,1:min(-y,x2))) <= 0 && effectiveData.MSO(j) ~= 0)
                volume = effectiveData.MSO(j);
                for k = 1:min(-y,x2)
                    effectiveData.BCancel(j,k) = max(effectiveData.bidOrderbook(j-1,k) - volume, 0);
                    volume = max(volume - effectiveData.bidOrderbook(j-1,k),0);
                end
            else
                effectiveData.LBO(j,1) = ...
                    effectiveData.LBO(j,1) + max(effectiveData.MSO(j) - sum(effectiveData.bidOrderbook(j-1,1:min(-y,x2))),0);
            end
            
        elseif(y < 0 && z < 0)
            effectiveData.LSO(j,1:min(-z,x1)) = effectiveData.askOrderbook(j,1:min(-z,x1));
            effectiveData.LSO(j,1) = effectiveData.LSO(j,1) + effectiveData.MBO(j);
            effectiveData.SCancel(j,max(x1+z+1,1):end) = effectiveData.askOrderbook(j-1,max(x1+z+1,1):end);
            if(-z < x1)
                effectiveData.LSO(j,-z+1:end) = ...
                    max(effectiveData.askOrderbook(j,-z+1:end) - effectiveData.askOrderbook(j-1,1:(x1+z)), 0);
                effectiveData.SCancel(j,1:(x1+z)) = ...
                    -min(effectiveData.askOrderbook(j,-z+1:end) - effectiveData.askOrderbook(j-1,1:(x1+z)), 0);
            end
            effectiveData.LBO(j,max(1,x2+y+1):end) = effectiveData.bidOrderbook(j,max(1,x2+y+1):end);
            if(x2 > -y)
                effectiveData.LBO(j,1:x2+y) = ...
                    max(effectiveData.bidOrderbook(j,1:x2+y) - effectiveData.bidOrderbook(j-1,-y+1:end),0);
                effectiveData.BCancel(j,-y+1:end) = ...
                    -min(effectiveData.bidOrderbook(j,1:x2+y) - effectiveData.bidOrderbook(j-1,-y+1:end),0);
            end
            if(effectiveData.MSO(j) - sum(effectiveData.bidOrderbook(j-1,1:min(-y,x2))) <= 0 && effectiveData.MSO(j) ~= 0)
                volume = effectiveData.MSO(j);
                for k = 1:min(-y,x2)
                    effectiveData.BCancel(j,k) = max(effectiveData.bidOrderbook(j-1,k) - volume, 0);
                    volume = max(volume - effectiveData.bidOrderbook(j-1,k),0);
                end
            else
                effectiveData.LBO(j,1) = ...
                    effectiveData.LBO(j,1) + max(effectiveData.MSO(j) - sum(effectiveData.bidOrderbook(j-1,1:min(-y,x2))),0);
            end
            
        else
            effectiveData.LSO(j,:) = ...
                max(effectiveData.askOrderbook(j,:) - effectiveData.askOrderbook(j-1,:),0);
            effectiveData.LBO(j,:) = ...
                max(effectiveData.bidOrderbook(j,:) - effectiveData.bidOrderbook(j-1,:),0);
            effectiveData.SCancel(j,:) = ...
                -min(effectiveData.askOrderbook(j,:) - effectiveData.askOrderbook(j-1,:),0);
            effectiveData.BCancel(j,:) = ...
                -min(effectiveData.bidOrderbook(j,:) - effectiveData.bidOrderbook(j-1,:),0);
            effectiveData.LSO(j,1) = ...
                effectiveData.LSO(j,1) + effectiveData.MBO(j);
            effectiveData.LBO(j,1) = ...
                effectiveData.LBO(j,1) + effectiveData.MSO(j);
        end
        
    end
    
    data = effectiveData;
    save([targetPath, '\', files(i).name], 'data');
end