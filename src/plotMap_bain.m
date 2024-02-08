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

% set(0,'DefaultFigureVisible','off');
% allfigh = findall(0,'type','figure');
% if length(allfigh) > 1
%     close(figure(length(allfigh)+1));
% else
%     close(figure(1));
% end
% set(0,'DefaultFigureVisible','on');

%% Define the text output format as Latex
setInterp2Latex
cmap = get_option(varargin,'colormap',rdylgn);
facealpha = get_option(varargin,'facealpha',0.6);

% Scale colormap
nr_bain = max(job.transformedGrains.bainId);
if nr_bain < 8
    n1 = round((0:(nr_bain-1)) ./ (nr_bain-1) .* ...
        (size(cmap,1) - 1)) + 1;
    cmap = cmap(n1, :);
else
    n1 = floor(size(cmap, 1) / nr_bain); % interval between colormap indices
    n2 = length(cmap) - nr_bain*n1 + 1;   % starting index, i.e. mod(cm,n) does not always equal 0
    cmap = cmap(n2:n1:end, :); 
end

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
     plt2 = plot(job.transformedGrains,job.transformedGrains.bainId,'parent',ax2);
else
    pGrains = job.grains(job.mergeId(job.ebsdPrior(job.csChild).grainId));
    isParent = pGrains.phaseId == job.parentPhaseId;
    pGrains = pGrains(isParent);
    cEBSD = job.ebsdPrior(job.csChild);
    cEBSD = cEBSD(isParent);
    [~,~,bainIds] = calcVariantId(pGrains.meanOrientation,cEBSD.orientations,job.p2c,'variantMap',job.variantMap,varargin{:});
    plt2 = plot(cEBSD,bainIds,'parent',ax2);
    f_area = [histcounts(bainIds,nr_packets)/length(bainIds)]';
    disp(table([1:nr_packets]',f_area,'VariableNames',{'Bain Groups','AreaFrac'}))
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
    'YTick', [1:1:nr_bain],'YTickLabel',string(num2str([1:1:nr_bain]')), 'YLim', [0.5 nr_bain+0.5],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
clim(ax2,[0.5 nr_bain + 0.5]);
set(f,'Name','Bain group Id map','NumberTitle','on');
drawnow;
end