function plotMap_packets(job, varargin)
% plot the map of child grains colored according to their packet ID
%
% Syntax
%  plotMap_packets(job)
%
% Input
%  job          - @parentGrainreconstructor
%
% Options
%  colormap - colormap string
%  grains   - plot grain data instead of EBSD data

cmap = get_option(varargin,'colormap','viridis');

p2c_V = job.p2c.variants;
p2c_V = p2c_V(:);

f = figure;
if check_option(varargin,'grains')
    plot(job.transformedGrains,job.transformedGrains.packetId);
else
    pGrains = job.grains(job.ebsd(job.csChild).grainId);
    cEBSD = job.ebsd(pGrains(job.csParent));
    cEBSD = cEBSD(job.csChild);
    pGrains = pGrains(job.csParent);   
    [~,packIds] = calcVariantId(pGrains.meanOrientation,cEBSD.orientations,job.p2c,'variantMap',job.variantMap,varargin{:});
    plot(cEBSD,packIds);   
end


hold on
parentGrains = smooth(job.parentGrains,10);
plot(parentGrains.boundary,varargin{:})
hold off

% Define the maximum number of color levels and plot the colorbar
    maxColors = max(job.transformedGrains.packetId);
    colormap(cmap);
    caxis([1 maxColors]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [1:1:maxColors],...
        'YTickLabel',num2str([1:1:maxColors]'), 'YLim', [1 maxColors],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    set(f,'Name','Packet Id map','NumberTitle','on');
    drawnow;
end