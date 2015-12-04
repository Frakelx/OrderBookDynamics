clc;clear;

sourcePath = '.\Index Future Tick Data\TruncatedData';

files = dir([sourcePath,'\201411*.mat']);
bestbidsize = [];
bestasksize = [];

for fIndex = 1:length(files)
   
    load([sourcePath,'\',files(fIndex).name]);
    bestbidsize = [bestbidsize; data.bidOrderbook(:,1)];
    bestasksize = [bestasksize; data.askOrderbook(:,1)];
    display(sprintf('%.2f%% has been finished!',fIndex*100/length(files)));
    
end
x = min(bestbidsize):1:max(bestbidsize);
y = min(bestasksize):1:max(bestasksize);
[X, Y] = meshgrid(x, y);
pdf = hist3([bestbidsize, bestasksize], {x, y});
pdf_norm = (pdf' ./ size(bestbidsize,1));
figure()
surf(X, Y, pdf_norm);
xlabel('bestbidsize');
ylabel('bestasksize');
