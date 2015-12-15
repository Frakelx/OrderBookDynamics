clc;clear;

sourcePath = '.\Index Future Tick Data\TruncatedData';

files = dir([sourcePath, '\*.mat']);

range.bid = zeros(length(files),5);
range.allbid = zeros(length(files),1);
range.ask = zeros(length(files),5);
range.allask = zeros(length(files),1);

for fIndex = 1:length(files)
    
    load([sourcePath, '\', files(fIndex).name]);
%     temp = (data.bidDst - repmat(data.Spread./2,1,5) + 1) .* data.bidSize;
%     range.bid(fIndex,:) = sum(temp) ./ sum(data.bidSize);
%     range.allbid(fIndex,:) = sum(sum(temp)) / sum(sum(data.bidSize));
%     
%     temp1 = (data.askDst + repmat(data.Spread./2,1,5) - 1) .* data.askSize;
%     range.ask(fIndex,:) = sum(temp1) ./ sum(data.askSize);
%     range.allask(fIndex,:) = sum(sum(temp1)) / sum(sum(data.askSize));
%     
%     clear temp temp1;
%     display(sprintf('%.2f%% has been finished!',fIndex*100/length(files)));
    time(fIndex,:) = data.date;
end

% plot(1:length(files), range.bid(:,1)')
% hold on
% plot(1:length(files), range.bid(:,2)')
% plot(1:length(files), range.bid(:,3)')
% plot(1:length(files), range.bid(:,4)')
% plot(1:length(files), range.bid(:,5)')
% 
% plot(1:length(files), range.ask(:,1)')
% plot(1:length(files), range.ask(:,2)')
% plot(1:length(files), range.ask(:,3)')
% plot(1:length(files), range.ask(:,4)')
% plot(1:length(files), range.ask(:,5)')
% 
% plot(1:length(files), range.allbid')
% plot(1:length(files), range.allask')
