function f_area = plotMap_packets(job, varargin)
%% Function description:
% This function plots an ebsd map by colorising child grains according to 
% their crystallographic packet ID. It also outputs the area fraction
% of each crystallographic packet.
%
%% Syntax:
%  plotMap_packets(job)
%
%% Input:
%  job      - @parentGrainreconstructor
%
%% Output:
%  f_area: Area fraction of each variant
%  entire EBSD map
%
%% Options:
%  colormap - colormap variable
%  grains   - plot grain data instead of EBSD data

cmap = get_option(varargin,'colormap',viridis);

%% Define the text output format as Latex
setInterp2Latex

p2c_V = job.p2c.variants;
p2c_V = p2c_V(:);
maxPackets = max(job.transformedGrains.packetId);

f = figure;
if check_option(varargin,'grains')
    plot(job.transformedGrains,job.transformedGrains.packetId);
else
    pGrains = job.grains(job.mergeId(job.ebsdPrior(job.csChild).grainId));
    isParent = pGrains.phaseId == job.parentPhaseId;
    pGrains = pGrains(isParent);
    cEBSD = job.ebsdPrior(job.csChild);
    cEBSD = cEBSD(isParent);
    [~,packIds,~] = calcVariantId(pGrains.meanOrientation,cEBSD.orientations,job.p2c,'variantMap',job.variantMap,varargin{:});
    plot(cEBSD,packIds);
    f_area = [histcounts(packIds,maxPackets)/length(packIds)]';
    disp(table([1:maxPackets]',f_area,'VariableNames',{'Packets','AreaFrac'}))
end


hold on
parentGrains = smooth(job.parentGrains,10);
plot(parentGrains.boundary,varargin{:})
hold off

% Define the maximum number of color levels and plot the colorbar

colormap(cmap);
caxis([1 maxPackets]);
colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
    'YTick', [1:1:maxPackets],...
    'YTickLabel',num2str([1:1:maxPackets]'), 'YLim', [1 maxPackets],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(f,'Name','Packet Id map','NumberTitle','on');
drawnow;
end