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
%  colormap     - Colormap variable (default: viridis)
%  grains       - Plot grain data instead of EBSD data
%  bc           - Plot as semintransparent overlay on bandcontrast (bc) or image quality (iq) data
%  facealpha    - Set transparency for bandcontrast overlay plot (default: 0.6)

%% Define the text output format as Latex
setInterp2Latex
cmap = get_option(varargin,'colormap',viridis);
facealpha = get_option(varargin,'facealpha',0.6);

% Scale colormap
nr_packets = max(job.transformedGrains.packetId);
if nr_packets < 8
    n1 = round((0:(nr_packets-1)) ./ (nr_packets-1) .* ...
        (size(cmap,1) - 1)) + 1;
    cmap = cmap(n1, :);
else
    n1 = floor(size(cmap, 1) / nr_packets); % interval between colormap indices
    n2 = length(cmap) - nr_packets*n1 + 1;   % starting index, i.e. mod(cm,n) does not always equal 0
    cmap = cmap(n2:n1:end, :); 
end

% Start plotting

f = figure();
if check_option(varargin,'bc')
    if isfield(job.ebsdPrior.prop,'bc')
        prop = rescale(filloutliers(job.ebsdPrior.prop.bc,"clip",'quartiles'));
    elseif isfield(job.ebsdPrior.prop,'iq')
        prop = rescale(filloutliers(job.ebsdPrior.prop.iq,"clip",'quartiles'));
    else
        warning('BC was not plotted, as data is missing.');
    end

    % Create main axis and then copy it.  
    plt1 = plot(job.ebsdPrior,prop);
else
    plt1 = plot(job.ebsdPrior,nan(size(job.ebsdPrior)));
    
end
ax1 = plt1.Parent; 
ax2 = copyobj(ax1,f);
delete(ax2.Children);
colormap(ax1,'gray')

if check_option(varargin,'grains')
     plt2 = plot(job.transformedGrains,job.transformedGrains.packetId,'parent',ax2);
else
    pGrains = job.grains(job.mergeId(job.ebsdPrior(job.csChild).grainId));
    isParent = pGrains.phaseId == job.parentPhaseId;
    pGrains = pGrains(isParent);
    cEBSD = job.ebsdPrior(job.csChild);
    cEBSD = cEBSD(isParent);
    [~,packIds,~] = calcVariantId(pGrains.meanOrientation,cEBSD.orientations,job.p2c,'variantMap',job.variantMap,varargin{:});
    plt2 = plot(cEBSD,packIds,'parent',ax2);
    f_area = [histcounts(packIds,nr_packets)/length(packIds)]';
    disp(table([1:nr_packets]',f_area,'VariableNames',{'Packets','AreaFrac'}))
end

if check_option(varargin,'bc')
    set(plt2,'facealpha',facealpha);
end
colormap(ax2,cmap)

% Link the axis properties and turn off axis #2.
ax2.UserData = linkprop([ax1,ax2],...
    {'Position','InnerPosition','DataAspectRatio','xtick','ytick', ...
    'ydir','xdir','xlim','ylim'});
ax2.Visible = 'off';
ax2.Color = 'none';

% Plot parent grain boundaries
hold on
parentGrains = smooth(job.parentGrains,10);
plot(parentGrains.boundary,varargin{:})
hold off

% Define the maximum number of color levels and plot the colorbar

colorbar(ax2,'location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
    'YTick', [1:1:nr_packets],'YTickLabel',string(num2str([1:1:nr_packets]')), 'YLim', [0.5 nr_packets+0.5],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
clim(ax2,[0.5 nr_packets + 0.5]);
set(f,'Name','Packet Id map','NumberTitle','on');
drawnow;
end