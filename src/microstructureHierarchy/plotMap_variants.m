function f_area = plotMap_variants(job, varargin)
%% Function description:
% This function plots an ebsd map by colorising child grains according to
% their variant IDs. It also outputs the area fraction of each variant.
%
%% Syntax:
%  plotMap_variants(job)
%
%% Input:
%  job      - @parentGrainreconstructor
%
%% Output:
%  f_area: Area fraction of each variant
%  entire EBSD map
%
%% Options:
%  colormap     - Colormap variable (default: jet)
%  grains       - Plot grain data instead of EBSD data
%  bc           - Plot as semintransparent overlay on bandcontrast (bc) or image quality (iq) data
%  facealpha    - Set transparency for bandcontrast overlay plot (default: 0.6)

%% Define varargin
cmap = get_option(varargin,'colormap',jet);
facealpha = get_option(varargin,'facealpha',0.67);

%% Scale colormap
nr_variants = length(job.p2c.variants);
nr_shades = 25; % number of shades for band contrast
if nr_variants < 8
    n1 = round((0:(nr_variants-1)) ./ (nr_variants-1) .* ...
        (size(cmap,1) - 1)) + 1;
    cmap = cmap(n1, :);
else
    n1 = floor(size(cmap, 1) / nr_variants); % interval between colormap indices
    n2 = length(cmap) - nr_variants*n1 + 1;  % starting index, i.e. mod(cm,n) does not always equal 0
    cmap = cmap(n2:n1:end, :);
end

%% Define the text output format as Latex
setInterp2Latex

%% Start plotting
f = figure(); %newMtexFigure;
if check_option(varargin,'bc')
    if isfield(job.ebsdPrior.prop,'bc')
        prop = nr_shades * rescale(filloutliers(job.ebsdPrior.prop.bc,"clip",'quartiles')) - nr_shades;
    elseif isfield(job.ebsdPrior.prop,'iq')
        prop = nr_shades * rescale(filloutliers(job.ebsdPrior.prop.iq,"clip",'quartiles')) - nr_shades;
    else
        warning('BC or IQ was not plotted as data is missing.');
    end
    plt1 = plot(job.ebsdPrior,prop);

else
    plt1 = plot(job.ebsdPrior,nan(size(job.ebsdPrior)));
end
hold on

if check_option(varargin,'grains')
    plt2 = plot(job.transformedGrains,job.transformedGrains.variantId);
else
    pGrains = job.grains(job.mergeId(job.ebsdPrior(job.csChild).grainId));
    isParent = pGrains.phaseId == job.parentPhaseId;
    pGrains = pGrains(isParent);
    cEBSD = job.ebsdPrior(job.csChild);
    cEBSD = cEBSD(isParent);
    varIds = calcVariantId(pGrains.meanOrientation,cEBSD.orientations,job.p2c,'variantMap',job.variantMap,varargin{:});
    plt2 = plot(cEBSD,varIds);
    p2c_V = job.p2c.variants;
    p2c_V = p2c_V(:);
    f_area = [histcounts(varIds,length(p2c_V))/length(varIds)]';
    disp(table([1:length(p2c_V)]',f_area,'VariableNames',{'Variants','AreaFrac'}))
end

if check_option(varargin,'bc')
    set(plt2,'facealpha',facealpha);
end

colormap([gray(nr_shades);cmap]);

% Plot parent grain boundaries
hold on
parentGrains = smooth(job.parentGrains,10);
plot(parentGrains.boundary,varargin{:})
hold off

% Define the maximum number of color levels and plot the colorbar
figM = gcm;
colorbar(figM);
set(figM.cBarAxis,'location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
    'YTick', [1:1:nr_variants],'YTickLabel',string(num2str([1:1:nr_variants]')), 'YLim', [0.5 nr_variants+0.5],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
caxis([-nr_shades+0.5 nr_variants + 0.5]);
set(f,'Name','Variant Id map','NumberTitle','on');
drawnow;

end