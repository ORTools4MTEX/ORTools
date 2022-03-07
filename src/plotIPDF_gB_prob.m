function plotIPDF_gB_prob(job, varargin)
% Calculate and plot the probability distribution between 0 and 1, that a 
% boundary belongs to an orientation relationship in an inverse 
% pole figure showing the misorientation axes
%
% Syntax
%  plotIPDF_gB_prob(job)
%
% Input
%  job  - @parentGrainreconstructor
%
% Options
%  threshold - the misfit at which the probability is exactly 50 percent ... 
%  tolerance - ... and the standard deviation in a cumulative Gaussian distribution
%  colormap - colormap string
%
%See also:
%https://mtex-toolbox.github.io/parentGrainReconstructor.calcGraph.html

cmap = get_option(varargin,'colormap','hot');
threshold = get_option(varargin,'threshold',2.5*degree);
tolerance = get_option(varargin,'tolerance',2.5*degree);

if job.p2c == orientation.id(job.csParent,job.csChild)
    warning('Orientation relationship is (0,0,0). Initialize ''job.p2c''');
    return
end

%% Define the text output format as Latex
setLabels2Latex

%% Compute the p2c and c2c boundary probabilities
% Find all grain pairs
grainPairs = neighbors(job.grains);

% Find p2c grain pairs
grainPairs_p2c = neighbors(job.grains(job.csParent.mineral),job.grains(job.csChild.mineral));
% Find the index of p2c grain pairs in the 'all grain pairs' variable
[idx_p2c,~] = ismember(grainPairs,grainPairs_p2c,'rows');
if isempty(idx_p2c(idx_p2c==1))
    grainPairs_p2c = grainPairs_p2c(:,[2 1]);
    [idx_p2c,~] = ismember(grainPairs,grainPairs_p2c,'rows');
end

% Find c2c grain pairs
grainPairs_c2c = neighbors(job.grains(job.csChild.mineral),job.grains(job.csChild.mineral));
% Find the index of c2c grain pairs in the 'all grain pairs' variable
[idx_c2c,~] = ismember(grainPairs,grainPairs_c2c,'rows');
if isempty(idx_c2c(idx_c2c==1))
    grainPairs_c2c = grainPairs_c2c(:,[2 1]);
    [idx_c2c,~] = ismember(grainPairs,grainPairs_c2c,'rows');
end

% Define all boundaries and calculate their probabilities
job.calcGraph('threshold',threshold,...
    'tolerance',tolerance);
v = full(job.graph(sub2ind(size(job.graph),grainPairs(:,1),grainPairs(:,2))));
[gB,pairId] = job.grains.boundary.selectByGrainId(grainPairs);

% Define p2c boundaries and find their probabilities
[gB_p2c,pairId_p2c] = job.grains.boundary.selectByGrainId(grainPairs(idx_p2c,:));
v_p2c = v(idx_p2c==1);

% Define c2c boundaries and find their probabilities
[gB_c2c,pairId_c2c] = job.grains.boundary.selectByGrainId(grainPairs(idx_c2c,:));
v_c2c = v(idx_c2c==1);

% Compute the variants of the nominal OR
p2c_V = job.p2c.variants;
p2c_V = p2c_V(:);
c2c_variants = job.p2c * inv(p2c_V);
%---------------



%% Define the window settings for a set of docked figures
% % Ref: https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs
warning off
desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
% % Define a unique group name for the dock using the function name
% % and the system timestamp
dockGroupName = ['plotIPDF_gB_prob_',char(datetime('now','Format','yyyyMMdd_HHmmSS'))];
desktop.setGroupDocked(dockGroupName,0);
bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');



%% Axis plot for parent grains using parent-child boundaries
drawnow;
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if ~isempty(gB_p2c)
    plot(gB_p2c.misorientation.axis,...
        v_p2c(pairId_p2c),...
        job.csParent.properGroup,...
        'all','symmetrised','FundamentalRegion',...
        'LineWidth',0.25,...
        'Marker','o','MarkerSize',3,...
        'MarkerEdgeColor',[0 0 0]);
    colormap(cmap);
    caxis([0 1]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [0:0.1:1],...
        'YTickLabel',num2str([0:0.1:1]'), 'YLim', [0 1],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    hold all
else
    warning('There are no parent-child grain boundaries in the dataset');
end

plot(job.p2c.axis,...
    job.csParent.properGroup,...
    'all','symmetrised','FundamentalRegion',...
    'LineWidth',1,...
    'Marker','o','MarkerSize',12,...
    'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1]);
hold off
set(figH,'Name',strcat('Rot. axis p2c - Probability of parent boundaries'),'NumberTitle','on');
drawnow;
%---------------



%% Axis plot for child grains using parent-child boundaries
drawnow;
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if ~isempty(gB_p2c)
    plot(gB_p2c.misorientation.axis,...
        v_p2c(pairId_p2c),...
        job.csChild.properGroup,...
        'all','symmetrised','FundamentalRegion',...
        'LineWidth',0.25,...
        'Marker','o','MarkerSize',3,...
        'MarkerEdgeColor',[0 0 0]);
    colormap(cmap);
    caxis([0 1]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [0:0.1:1],...
        'YTickLabel',num2str([0:0.1:1]'), 'YLim', [0 1],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    hold all
else
    warning('There are no parent-child grain boundaries in the dataset');
end

plot(job.p2c.axis,...
    job.csChild.properGroup,...
    'all','symmetrised','FundamentalRegion',...
    'LineWidth',1,...
    'Marker','o','MarkerSize',12,...
    'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1]);
hold off
set(figH,'Name',strcat('Rot. axis p2c - Probability of child boundaries'),'NumberTitle','on');
drawnow;
%---------------



%% Axis plot for child grains using child-child boundaries
drawnow;
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if ~isempty(gB_c2c)
    plot(gB_c2c.misorientation.axis,...
        v_c2c(pairId_c2c),...
        job.csChild.properGroup,...
        'all', 'symmetrised', 'FundamentalRegion',...
        'LineWidth',0.25,...
        'Marker','o','MarkerSize',3,...
        'MarkerEdgeColor',[0 0 0]);
    colormap(cmap);
    caxis([0 1]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [0:0.1:1],...
        'YTickLabel',num2str([0:0.1:1]'), 'YLim', [0 1],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    hold all
else
    warning('There are no child-child grain boundaries in the dataset');
end

plot(c2c_variants.axis,...
    job.csParent.properGroup,...
    'all', 'symmetrised', 'FundamentalRegion',...
    'LineWidth',1,...
    'Marker','o','MarkerSize',12,...
    'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1]);
hold off
set(figH,'Name',strcat('Rot. axis c2c - Probability of child boundaries'),'NumberTitle','on');
drawnow;
%---------------


%% Place first tabbed figure on top and return
warning on
allfigh = findall(0,'type','figure');
if length(allfigh) > 1 &&...
        ~isempty(gB_p2c) &&...
        ~isempty(gB_c2c)
    figure(length(allfigh)-2);
elseif length(allfigh) > 1 &&...
        isempty(gB_p2c) &&...
        ~isempty(gB_c2c)
    figure(length(allfigh));
else
    figure(1);
end
warning(bakWarn);
pause(1); % Reduce rendering errors
return
end