function f_area = plotMap_bain(job, varargin)
%% Function description:
% This function plots an ebsd map by colorising child grains according to 
% their Bain group ID. It also outputs the area fraction of each Bain 
% group.
%
%% Syntax:
%  plotMap_bain(job)
%
%% Input:
%  job          - @parentGrainreconstructor
%
%% Output:
%  f_area: Area fraction of each Bain group in the EBSD map
%
%% Options:
%  colormap - colormap variable
%  grains   - plot grain data instead of EBSD data

set(0,'DefaultFigureVisible','off');
cmap = get_option(varargin,'colormap',magma);
allfigh = findall(0,'type','figure');
if length(allfigh) > 1
    close(figure(length(allfigh)));
else
    close(figure(1));
end
set(0,'DefaultFigureVisible','on');

%% Define the text output format as Latex
setInterp2Latex

p2c_V = job.p2c.variants;
p2c_V = p2c_V(:);
maxColors = max(job.transformedGrains.bainId);

f = figure();
hold all
if check_option(varargin,'grains')
    plot(job.transformedGrains,job.transformedGrains.bainId);
else
    pGrains = job.grains(job.mergeId(job.ebsdPrior(job.csChild).grainId));
    isParent = pGrains.phaseId == job.parentPhaseId;
    pGrains = pGrains(isParent);
    cEBSD = job.ebsdPrior(job.csChild);
    cEBSD = cEBSD(isParent);
    [~,~,bainIds] = calcVariantId(pGrains.meanOrientation,cEBSD.orientations,job.p2c,'variantMap',job.variantMap,varargin{:});
    plot(cEBSD,bainIds);
    f_area = [histcounts(bainIds,maxColors)/length(bainIds)]';
    disp(table([1:maxColors]',f_area,'VariableNames',{'BainGroups','AreaFrac'}))
end


hold all
parentGrains = smooth(job.parentGrains,10);
plot(parentGrains.boundary,varargin{:})
hold off

% Define the maximum number of color levels and plot the colorbar
colormap(cmap);
caxis([1 maxColors]);
colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
    'YTick', [1:1:maxColors],...
    'YTickLabel',num2str([1:1:maxColors]'), 'YLim', [1 maxColors],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(f,'Name','Bain group Id map','NumberTitle','on');
drawnow;
end