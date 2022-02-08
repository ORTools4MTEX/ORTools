function plotMap_variants(job, varargin)
% plot the map of child grains colored according to their variant ID
%
% Syntax
%  plotMap_variants(job)
%
% Input
%  job          - @parentGrainreconstructor
%
% Options
%  colormap - colormap string
%  grains   - plot grain data instead of EBSD data

cmap = get_option(varargin,'colormap','jet');

%% Define the text output format as Latex
setLabels2Latex

p2c_V = job.p2c.variants;
p2c_V = p2c_V(:);
c2c_variants = job.p2c * inv(p2c_V);

f = figure;

if check_option(varargin,'grains')
    plot(job.transformedGrains,job.transformedGrains.variantId);
else
    pGrains = job.grains(job.mergeId(job.ebsdPrior(job.csChild).grainId));
    isParent = pGrains.phaseId == job.parentPhaseId;
    pGrains = pGrains(isParent);
    cEBSD = job.ebsdPrior(job.csChild);
    cEBSD = cEBSD(isParent);
    varIds = calcVariantId(pGrains.meanOrientation,cEBSD.orientations,job.p2c,'variantMap',job.variantMap,varargin{:});
    plot(cEBSD,varIds);
end

hold on
parentGrains = smooth(job.parentGrains,10);
plot(parentGrains.boundary,varargin{:})
hold off

% Define the maximum number of color levels and plot the colorbar
maxColors = length(c2c_variants);
colormap(cmap);
caxis([1 maxColors]);
colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
    'YTick', [1:1:maxColors],...
    'YTickLabel',num2str([1:1:maxColors]'), 'YLim', [1 maxColors],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(f,'Name','Variant Id map','NumberTitle','on');
drawnow;
end