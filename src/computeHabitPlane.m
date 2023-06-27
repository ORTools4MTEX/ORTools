function [habitPlane,statistics,tracesPlotting] = computeHabitPlane(job,varargin)
%% Function description:
% This function computes the habit plane based on the determined traces
% from 2D ebsd map data as per the following reference:
% T. Nyyssönen, A.A. Gazder, R. Hielscher, F. Niessen, Habit plane
% determination from reconstructed parent phase orientation maps
% (https://doi.org/10.48550/arXiv.2303.07750)
%
%% Syntax:
% [hPlane,statistics] = computeHabitPlane(job)
%
%% Input:
%  job      - @parentGrainReconstructor
%
%% Output:
%  hPlane      - @Miller     = Habit plane
%  statistics  - @Container  = Statistics of fitting
%
%% Options:
%  minClusterSize - minimum number of pixels required for trace computation (default: 100)
%  Radon          - Radon based algorithm (pixel data used)
%  Fourier        - Fourier based algorithm (pixel data used)
%  Shape          - Characteristic grain shape based algorithm (grain data used)
%  Hist           - Circular histogram based algorithm (grain data used)


if all(isnan(job.variantId))
    job.calcVariants  % Compute variants
end

hpMethod = lower(get_flag(varargin,{'calliper','shape','hist','fourier','radon'},'radon'));
cSize = get_option(varargin,'minClusterSize',100);
rIdx = get_option(varargin,'reliability',0.5);
pGrainId = get_option(varargin,'parentGrainId',job.parentGrains.id);

%% Define the parent grain(s) and parent ebsd data
pGrains = job.parentGrains(job.parentGrains.id == pGrainId);
pEBSD = job.ebsd(pGrains);
pEBSD = pEBSD(job.csParent);

%% Get prior parent grain Ids and variant Ids for EBSD and grains
% Grain data
cGrains = job.transformedGrains;
ind1 = [job.mergeId, job.variantId];
ind1 = ind1(job.isTransformed,:);

% EBSD data
cEBSD = job.ebsdPrior(job.transformedGrains);
ind2 = [job.ebsd.grainId(job.ebsdPrior.id2ind(pEBSD.id)),job.ebsd.variantId(job.ebsdPrior.id2ind(pEBSD.id))];

%% Calculate the traces of the child grains
switch hpMethod
    case {'calliper', 'shape','hist'}
        [traces, relIndex, clusterSize] = calcTraces(cGrains,ind1,hpMethod,'minClusterSize',cSize);
    case {'radon','fourier'}
        [traces, relIndex, clusterSize] = calcTraces(cEBSD,ind2,hpMethod,'minClusterSize',cSize);
end


%% Only consider those traces that have a reconstructed parent orientation
if length(pGrainId) == 1
    traces = traces(job.isParent(job.parentGrains.id == pGrainId),:);
    relIndex = relIndex(job.isParent(job.parentGrains.id == pGrainId),:);
    clusterSize = clusterSize(job.isParent(job.parentGrains.id == pGrainId),:);
else
    traces = traces(job.isParent,:);
    relIndex = relIndex(job.isParent,:);
    clusterSize = clusterSize(job.isParent,:);
end
% Logical index of traces with a high reliability index
hasTrace = ~isnan(traces) & relIndex >= rIdx;


%% Get the parent orientations
oriParent = pGrains.meanOrientation;

%% Determine the variant specific parent orientations
oriPVariant = oriParent.project2FundamentalRegion .* ...
    inv(variants(job.p2c)) .* job.p2c;

%% Transform traces into the parent reference frame
tracesParent = inv(oriPVariant) .* traces;
if length(pGrainId) == 1
    tracesPlotting = vector3d.nan(length(pGrains),1);
else
    tracesPlotting = vector3d.nan(length(pGrainId),1);
end
tracesPlotting(pGrainId,1:size(oriPVariant,2)) = tracesParent;

%% Determine the habit plane (orthogonal fit)
habitPlane = perp(tracesParent(hasTrace),'robust');

%% Change Miller object to type = crystal plane
habitPlane = setDisplayStyle(habitPlane,'plane'); % ORTools default
% habitPlane.dispStyle = "hkl"; %Mtex default

%% Recompute traces from fitted habit plane
if length(pGrainId) == 1
    traceImPlane = vector3d.nan(length(pGrains),1);
else
    traceImPlane = vector3d.nan(length(pGrainId),1);
end
traceImPlane(pGrainId,1:size(oriPVariant,2)) = cross(oriPVariant .* habitPlane,zvector);


if length(pGrainId) > 1
    %% Calculate the angular deviation between the traces and the fitted habit plane
    deviation = 90 - angle(habitPlane,tracesParent(~isnan(tracesParent)),'noSymmetry')./degree;
    % Mean deviation
    meanDeviation = mean(deviation);
    % Std deviation
    stdDeviation = std(deviation);
    % Quantiles
    quantiles = quantile(deviation,[0.25 0.5 0.75]);
    % Return the statistics of fitting
    statistics = containers.Map(...
        {'relIndex','clusterSize','Deviation','meanDeviation','stdDeviation','Quantiles'},...
        {relIndex,clusterSize,deviation,meanDeviation,stdDeviation,quantiles},...
        'UniformValues',false);
else
    statistics = NaN;
end

%% Plot and return the habit plane

% Plot traces and fitted habit planes in spherical projection
figure();
h{1} = scatter(tracesParent,'MarkerSize',6,'MarkerFaceColor','k','MarkerFaceAlpha',0.4,'MarkerEdgeAlpha',0.5);
hold all
h{2} = plot(habitPlane,'plane','linecolor','r','linewidth',2);
h{3} = plot(habitPlane,'Marker','s','MarkerColor','r','MarkerEdgeColor','k','MarkerSize',10,'LineWidth',1,'label',{sprintMiller(habitPlane)});
hold off;
drawnow;
legend([h{:}], {'Parent traces','Habit trace','Habit plane'}, 'location', 'east');
set(gcf,'name','Spherical projection of determined traces and fitted habit plane');

% Plot ODF
if length(pGrainId) > 1
    figure();
    tpd = calcDensity(tracesParent,'noSymmetry','halfwidth',2.5*degree);
    contourf(tpd)
    mtexColorMap white2black
    mtexColorbar
    circle(habitPlane,'color','red','linewidth',2)
    set(gcf,'name','ODF of fitted traces and habit plane');
end

% % Plot microstructure map - Fitted traces
% figure()
% plot(job.transformedGrains,'grayscale');
% hold on
% pId = ind1(:,1); %= [job.mergeId(ismember(job.mergeId,pGrainId)), job.variantId(ismember(job.mergeId,pGrainId))];
% vId = ind1(:,2);
% % pId = job.mergeId(job.isTransformed);
% % vId = job.variantId(job.isTransformed);
% tracesPlotting = tracesPlotting(pId,:);
% quiver(job.transformedGrains,tracesPlotting(vId),'color','b','linewidth',2,'DisplayName','Fitted Plane Traces','MaxHeadSize',0);
% set(gcf,'name','Fitted traces');
%
% % Plot microstructure map - traces of fitted habit plane
% figure()
% plot(job.transformedGrains,'grayscale');
% hold on
% pId = ind1(:,1); %= [job.mergeId(ismember(job.mergeId,pGrainId)), job.variantId(ismember(job.mergeId,pGrainId))];
% vId = ind1(:,2);
% % pId = job.mergeId(job.isTransformed);
% % vId = job.variantId(job.isTransformed);
% traceImPlane = traceImPlane(pId,:);
% quiver(job.transformedGrains,traceImPlane(vId),'color','r','linewidth',2,'DisplayName','Habit Plane Traces','MaxHeadSize',0);
% set(gcf,'name','Traces of fitted habit plane');

if length(pGrainId) > 1
    %% Output habit plane text
    screenPrint('Step','Detailed information on the computed habit plane:');
    screenPrint('SubStep',sprintf(['Habit plane (as-computed) = ',...
        sprintMiller(habitPlane)]));
    screenPrint('SubStep',sprintf(['Habit plane (rounded-off) = ',...
        sprintMiller(habitPlane,'round')]));
    nTrace = sum(sum(~isnan(traces)));
    screenPrint('SubStep',sprintf(['Number of possible traces = ',...
        num2str(nTrace)]));
    aTrace = sum(sum(hasTrace));
    screenPrint('SubStep',sprintf(['Number of analysed traces = ',...
        num2str(aTrace)]));
    pctTrace = round(aTrace/nTrace,4);    
    screenPrint('SubStep',sprintf(['Fraction of analysed vs. possible traces = ',...
        num2str(pctTrace)]));
    screenPrint('SubStep',sprintf(['Number of analysed parent grains = ',...
        num2str(length(oriParent))]));
    screenPrint('SubStep',sprintf(['Mean deviation = ',...
        num2str(meanDeviation),'° ± ',num2str(stdDeviation),'°']));
    screenPrint('SubStep',sprintf(['Quantiles [25, 50, 75 percent] = [',...
        num2str(quantiles(1)),'°, ',num2str(quantiles(2)),'°, ',num2str(quantiles(3)),'°]']));
end
end





%% Set Display Style of Miller objects
function m = setDisplayStyle(millerObj,mode)
m = millerObj;
if isa(m,'Miller')
    if any(strcmpi(m.CS.lattice,{'hexagonal','trigonal'})) == 1
        if strcmpi(mode,'direction')
            m.dispStyle = 'UVTW';
        elseif strcmpi(mode,'plane')
            m.dispStyle = 'hkil';
        end
    else
        if strcmpi(mode,'direction')
            m.dispStyle = 'uvw';
        elseif strcmpi(mode,'plane')
            m.dispStyle = 'hkl';
        end
    end
end
end

%% Screenprint Crystal Planes
function s = sprintMiller(mil,varargin)
if any(strcmpi(mil.dispStyle,{'hkl','hkil'}))
    if strcmpi(mil.dispStyle,'hkil')
        mill = {'h','k','i','l'};
    elseif strcmpi(mil.dispStyle,'hkl')
        mill = {'h','k','l'};
    end
    s = '(';
    for i = 1:length(mill)
        if check_option(varargin,'round')
            s = [s,num2str(round(mil.(mill{i}),0))];
        else
            s = [s,num2str(mil.(mill{i}),'%0.4f')];
        end
        if i<length(mill)
            s = [s,','];
        end
    end
    s = [s,')'];
elseif any(strcmpi(mil.dispStyle,{'uvw','UVTW'}))
    if strcmpi(mil.dispStyle,'UVTW')
        mill = {'U','V','T','W'};
    elseif strcmpi(mil.dispStyle,'uvw')
        mill = {'u','v','w'};
    end
    s = '[';
    for i = 1:length(mill)
        if check_option(varargin,'round')
            s = [s,num2str(round(mil.(mill{i}),0))];
        else
            s = [s,num2str(mil.(mill{i}),'%0.4f')];
        end
        if i<length(mill)
            s = [s,','];
        end
    end
    s = [s,']'];
end
end