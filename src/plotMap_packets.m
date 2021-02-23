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

cmap = get_option(varargin,'colormap','parula');

p2c_V = job.p2c.variants;
p2c_V = p2c_V(:);

f = figure;
plot(job.transformedGrains,job.transformedGrains.packetId);
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