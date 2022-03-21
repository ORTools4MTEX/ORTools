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

%% Define the text output format as Latex
setLabels2Latex

%% Define the window settings for a set of docked figures
% % Ref: https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs
warning off
desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
% % Define a unique group name for the dock using the function name
% % and the system timestamp
dockGroupName = ['plotHist_OR_misfit_',char(datetime('now','Format','yyyyMMdd_HHmmSS'))];
desktop.setGroupDocked(dockGroupName,0);
bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
warning on


%% Plot p2c pairs histogram
p2cPairs = neighbors(job.grains(job.csParent),job.grains(job.csChild));
p2cPairs = p2cPairs(:,flip([1 2]));
if ~isempty(p2cPairs)
    misfitHist(dockGroupName,p2c,job,p2cPairs,numBins,allLegend,'pairType','p2c')
else
    warning('No parent-child neighbors found (p2c grain pairs empty)');
end


%% Plot c2c pairs histogram
c2cPairs = neighbors(job.grains(job.csChild),job.grains(job.csChild));
c2cPairs = c2cPairs(:,flip([1 2]));
if ~isempty(c2cPairs)
    misfitHist(dockGroupName,p2c,job,c2cPairs,numBins,allLegend,'pairType','c2c')
else
    warning('No child-child neighbors found (c2c grain pairs empty)');
end


%% Place first tabbed figure on top and return
allfigh = findall(0,'type','figure');
if length(allfigh) > 1
    figure(length(allfigh)-1);
else
    figure(1);
end
warning(bakWarn);
pause(1); % Reduce rendering errors
return
end



function misfitHist(dockGroupName,p2c,job,pairList,numBins,allLegend,varargin)
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
% Define the graphics object array
warning off;
drawnow;
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;

c = ind2color(1:length(p2c));
for ii = 1:length(p2c)
    if strcmpi(pairType,'p2c')==1
        omegaTemp = angle_outer(moriSub,p2c(ii));
    elseif strcmpi(pairType,'c2c')==1
        c2c = p2c(ii) * inv(p2c(ii).variants);
        omegaTemp = angle_outer(moriSub,c2c);
    elseif strcmpi(pairType,'')==1
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
%     % % Output histogram data in a table
%     figProp = get(groot,'CurrentFigure');
%     if strcmpi(pairType,'p2c')==1
%         screenPrint('Step',['Figure ',num2str(figProp.Number),', Histogram ',num2str(ii),': p2c']);
%     elseif strcmpi(pairType,'c2c')==1
%         screenPrint('Step',['Figure ',num2str(figProp.Number),', Histogram ',num2str(ii),': c2c']);
%     end
%     table(binCenters(ii,:)'./degree,countsNorm(ii,:)','VariableNames',{'binCenters','Freq'})
end
hold off

if ~isempty(job.p2c) && ~isempty(allLegend)
    h(1).DisplayName = 'job.p2c';
elseif ~isempty(job.p2c) && isempty(allLegend)
    h(1).DisplayName = 'job.p2c 1';
end

if ~isempty(allLegend)
    for ii = 2:length(p2c)
        h(ii).DisplayName = allLegend{ii-1};
    end
end

grid on
legend
% ylabel('Relative frequency ({\itf}(g))','FontSize',14);
ylabel('\bf Relative frequency [$\bf f$(g)]');
if strcmpi(pairType,'p2c')==1
%     xlabel('Parent-child grain disorientation [°]','FontSize',14);
    xlabel('\bf Parent-child grain disorientation [$\bf ^\circ$]','FontSize',14);
    set(figH,'Name','Parent-child grain disorientation histogram','NumberTitle','on');
elseif strcmpi(pairType,'c2c')==1
%     xlabel('Child-child grain disorientation [°]','FontSize',14);
    xlabel('\bf Child-child grain disorientation [$\bf ^\circ$]','FontSize',14);
    set(figH,'Name','Child-child grain disorientation histogram','NumberTitle','on');
end
drawnow;
warning on;
end