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

%% Define the default window settings for figures
set(0,'DefaultFigureWindowStyle','normal');

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

%% Define the window settings for a set of docked figures
desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
% Define a unique group name for the dock
groupName = ['plotHist',num2str(randi(100))];
figGroup = desktop.addGroup(groupName);
desktop.setGroupDocked(groupName,0);
figDim = java.awt.Dimension(2,1);  % 2 columns, 1 rows
% % Define how the figure appear in the dock 
% % 1 = Maximized, 2 = Tiled, 3 = Floating
desktop.setDocumentArrangement(groupName,1,figDim)
% Define the graphics object array for the number of figures to be plotted
figH = gobjects(2,1);
bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');


%% Plot p2c pairs histogram
p2cPairs = neighbors(job.grains(job.csParent),job.grains(job.csChild));
p2cPairs = p2cPairs(:,flip([1 2]));
if ~isempty(p2cPairs)
    misfitHist(groupName,figH,p2c,job,p2cPairs,numBins,allLegend,'pairType','p2c')
else
    warning('No parent-child neighbors found (p2c grain pairs empty)');
end

%% Plot c2c pairs histogram
c2cPairs = neighbors(job.grains(job.csChild),job.grains(job.csChild));
c2cPairs = c2cPairs(:,flip([1 2]));
if ~isempty(c2cPairs)
    misfitHist(groupName,figH,p2c,job,c2cPairs,numBins,allLegend,'pairType','c2c')
else
    warning('No child-child neighbors found (c2c grain pairs empty)');
end

%% Place first tabbed figure on top, undock the figure window and return
allfigh = findall(0,'type','figure');
if length(allfigh) > 1
    figure(length(allfigh)-1);
end
set(0,'DefaultFigureWindowStyle','normal');
warning(bakWarn);
clear misfitHist
return
end



function misfitHist(groupName,figH,p2c,job,pairList,numBins,allLegend,varargin)
% Setup a counter for the number of times the plotting function was called
persistent count;
if isempty(count); count = 0; end
count = count+1

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
figH(count) = figure('WindowStyle','docked');
set(get(handle(figH(count)),'javaframe'),'GroupName',groupName);
pause(0.05);  % Reduce rendering errors
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
        'DisplayName',sprintf('OR %d',ii),'facealpha',0.25);
    hold on;
end
hold off

if ~isempty(job.p2c) && ~isempty(allLegend)
    h(1).DisplayName = 'OR **';
elseif ~isempty(job.p2c) && isempty(allLegend)
    h(1).DisplayName = 'OR 1**';
end

if ~isempty(allLegend)
    for ii = 2:length(p2c)
        h(ii).DisplayName = allLegend{ii-1};
    end
end

grid on
legend
ylabel('Relative frequency ({\itf}(g))','FontSize',14);
if strcmp(pairType,'p2c')==1
    xlabel('Parent-child grain disorientation (°)','FontSize',14);
    set(figH(count),'Name','Parent-child grain disorientation histogram','NumberTitle','on');
elseif strcmp(pairType,'c2c')==1
    xlabel('Child-child grain disorientation (°)','FontSize',14);
    set(figH(count),'Name','Child-child grain disorientation histogram','NumberTitle','on');
end
pause(0.05);  % Reduce rendering errors
end