function f_area = plotMap_bain2(job, varargin)
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
%  colormap     - Colormap variable (default: rdylgn)
%  grains       - Plot grain data instead of EBSD data
%  bc           - Plot as semintransparent overlay on bandcontrast (bc) or image quality (iq) data
%  facealpha    - Set transparency for bandcontrast overlay plot (default: 0.6)

% Define the text output format as Latex
setInterp2Latex
cmap = get_option(varargin,'colormap',rdylgn);
facealpha = get_option(varargin,'facealpha',0.67);

% Scale colormap
nr_bain = max(job.transformedGrains.bainId);
nrShades = 25; %Nr of shades for band contrast
if nr_bain < 8
    n1 = round((0:(nr_bain-1)) ./ (nr_bain-1) .* ...
        (size(cmap,1) - 1)) + 1;
    cmap = cmap(n1, :);
else
    n1 = floor(size(cmap, 1) / nr_bain); % interval between colormap indices
    n2 = length(cmap) - nr_bain*n1 + 1;   % starting index, i.e. mod(cm,n) does not always equal 0
    cmap = cmap(n2:n1:end, :); 
end

%% Define the text output format as Latex
f = figure();
if check_option(varargin,'bc')
    if isfield(job.ebsdPrior.prop,'bc')
        prop = nrShades*rescale(filloutliers(job.ebsdPrior.prop.bc,"clip",'quartiles'))-nrShades;
    elseif isfield(job.ebsdPrior.prop,'iq')
        prop = nrShades*rescale(filloutliers(job.ebsdPrior.prop.iq,"clip",'quartiles'))-nrShades;
    else
        warning('BC was not plotted, as data is missing.');
    end

    % Create main axis and then copy it.  
    plot(job.ebsdPrior,prop);
else
    plot(job.ebsdPrior,nan(size(job.ebsdPrior)));  
end
hold on

if check_option(varargin,'grains')
     plt2 = plot(job.transformedGrains,job.transformedGrains.bainId);
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

colormap([gray(nrShades);cmap]);

% Plot parent grain boundaries
hold on
parentGrains = smooth(job.parentGrains,10);
plot(parentGrains.boundary,varargin{:})
hold off

% Define the maximum number of color levels and plot the colorbar
figM = gcm;
colorbar(figM);
set(figM.cBarAxis,'location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
    'YTick', [1:1:nr_bain],'YTickLabel',string(num2str([1:1:nr_bain]')), 'YLim', [0.5 nr_bain+0.5],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
caxis([-nrShades+0.5 nr_bain + 0.5]);
set(f,'Name','Bain group Id map','NumberTitle','on');
drawnow;
end