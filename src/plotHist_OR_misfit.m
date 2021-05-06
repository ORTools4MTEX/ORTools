function plotHist_OR_misfit(job,varargin)
% Plot disorientation (or misfit) histogram between 
% parent-child and child-child grain misorientations 
% with the OR misorientation
%
% Syntax
%  plotHist_OR_misfit(job)
%  plotHist_OR_misfit(job,p2c)
%
% Input
%  job          - @parentGrainreconstructor
%  p2c          - one or multiple orientation relationship(s) to evaluate
%
% Options
%  bins         - number of histogram bins
%  legend       - cell array of strings with legend names of ORs to evaluate

p2c = getClass(varargin,'orientation');
numBins = get_option(varargin,'bins',150);
allLegend = get_option(varargin,'legend',{});

if ~isempty(p2c) && (p2c.CS ~= job.csParent || p2c.SS ~= job.csChild)
    p2c = [];
end
if ~isempty(job.p2c)
    p2c = [job.p2c,p2c];
end

if isempty(p2c)
    warning('No OR was provided by the user');
    return;
end

%% Plot p2c pairs histogram
p2cPairs = neighbors(job.grains(job.csParent),job.grains(job.csChild));
p2cPairs = p2cPairs(:,flip([1 2]));
if ~isempty(p2cPairs)
    misfitHist(p2c,job,p2cPairs,numBins,allLegend,'pairType','p2c')
else
    warning('No parent-child neighbors found (p2c grain pairs empty)');
end

%% Plot c2c pairs histogram
c2cPairs = neighbors(job.grains(job.csChild),job.grains(job.csChild));
c2cPairs = c2cPairs(:,flip([1 2]));
if ~isempty(c2cPairs)
    misfitHist(p2c,job,c2cPairs,numBins,allLegend,'pairType','c2c')
else
    warning('No child-child neighbors found (c2c grain pairs empty)');
end

end



function misfitHist(p2c,job,pairList,numBins,allLegend,varargin)
pairType = get_option(varargin,'pairType','');

mori = inv(job.grains('id',pairList(:,1)).meanOrientation).*...
    job.grains('id',pairList(:,2)).meanOrientation;
mori(mori.angle < 5*degree) = [];
if length(mori) > 50000
    moriSub = discreteSample(mori,50000);
else
    moriSub = mori;
end

% Plot the grain pair disorientation
f = figure;
c = ind2color(1:length(p2c));
for ii = 1:length(p2c)
    if strcmp(pairType,'p2c')==1
        omegaTemp = angle_outer(moriSub,p2c(ii));
    elseif strcmp(pairType,'c2c')==1
        c2c = p2c(ii) * inv(p2c(ii).variants);
        omegaTemp = angle_outer(moriSub,c2c);
    elseif strcmp(pairType,'')==1
        warning('Grain pair type not specified)');
        return
    end
    [omega(ii,:),~] = min(omegaTemp,[],2);
    %--- Calculate the counts in each class interval
    [counts(ii,:),binCenters(ii,:)] = hist(omega(ii,:),numBins);
    %--- Normalise the absolute counts in each class interval
    countsNorm(ii,:) = 1.*(counts(ii,:)/sum(counts(ii,:)));
    h(ii) = area(binCenters(ii,:)./degree, countsNorm(ii,:),...
        'linewidth',2,...
        'edgecolor',c(ii,:), 'facecolor',c(ii,:),...
        'DisplayName',sprintf("OR %d",ii),'facealpha',0.25);
    hold on;
end
hold off

if ~isempty(job.p2c) && ~isempty(allLegend)
    h(1).DisplayName = "OR **";
elseif ~isempty(job.p2c) && isempty(allLegend)
    h(1).DisplayName = "OR 1**";
end

if ~isempty(allLegend)
    for ii = 2:length(p2c)
        h(ii).DisplayName = allLegend{ii-1};
    end
end

grid on
legend
ylabel('Relative frequency ({\itf}(g))', 'FontSize',14);
if strcmp(pairType,'p2c')==1
    xlabel('Parent-child grain disorientation (°)','FontSize',14);
    set(f,'Name','Parent-child grain disorientation distribution histogram','NumberTitle','on');
elseif strcmp(pairType,'c2c')==1
    xlabel('Child-child grain disorientation (°)','FontSize',14);
    set(f,'Name','Child-child grain disorientation distribution histogram','NumberTitle','on');
end
end