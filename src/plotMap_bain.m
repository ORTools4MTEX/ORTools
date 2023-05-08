function f_area = plotMap_bain(job, varargin)
% plot the map of child grains colored according to their bain ID
%
% Syntax
%  plotMap_bain(job)
%
% Input
%  job          - @parentGrainreconstructor
%
% Output
%  f_area: Area fraction of each variant
%  entire EBSD map
%
% Options
%  colormap - colormap string
%  grains   - plot grain data instead of EBSD data

cmap = get_option(varargin,'colormap','hot');

%% Define the text output format as Latex
setInterp2Latex

p2c_V = job.p2c.variants;
p2c_V = p2c_V(:);
maxNrBains = max(job.transformedGrains.bainId);

f = figure;
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
    f_area = [histcounts(bainIds,maxNrBains)/length(bainIds)]';
    disp(table([1:maxNrBains]',f_area,'VariableNames',{'Bain groups','AreaFrac'}))
end


hold on
parentGrains = smooth(job.parentGrains,10);
plot(parentGrains.boundary,varargin{:})
hold off

% Define the maximum number of color levels and plot the colorbar

colormap(cmap);
caxis([1 maxNrBains]);
colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
    'YTick', [1:1:maxNrBains],...
    'YTickLabel',num2str([1:1:maxNrBains]'), 'YLim', [1 maxNrBains],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(f,'Name','Bain group Id map','NumberTitle','on');
drawnow;
end