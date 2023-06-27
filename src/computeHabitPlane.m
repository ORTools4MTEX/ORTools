function [habitPlane,statistics] = computeHabitPlane(job,varargin)
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
job.calcParentEBSD; % Apparently needs to be repeated

hpMethod = lower(get_flag(varargin,{'calliper','shape','hist','fourier','radon'},'radon'));
cSize = get_option(varargin,'minClusterSize',100);
rIdx = get_option(varargin,'reliability',0.5);
pGrainId = get_option(varargin,'parentGrainId',job.parentGrains.id);
cmap = get_option(varargin,'colormap',viridis);
plotTraces = check_option(varargin,'plotTraces');

%% Define the parent grain(s) and parent ebsd data
is_transformed_EBSD = ~isnan(job.ebsd.variantId);
%Get parent grain and EBSD data (only the reconstructed one!)
pGrains = job.parentGrains(job.parentGrains.id == pGrainId);
pEBSD = job.ebsd(is_transformed_EBSD);

%% Define the child grain(s) and child ebsd data
if length(pGrainId) == 1
   cGrains = job.grainsPrior(job.mergeId == pGrains.id);
   cEBSD = job.ebsdPrior(cGrains);
else
    cGrains = job.transformedGrains; 
    cEBSD = job.ebsdPrior(is_transformed_EBSD);
end

%% Calculate the traces of the child grains
switch hpMethod
    case {'radon','fourier'}
        %EBSD
        ind = [pEBSD.grainId,job.ebsd(is_transformed_EBSD).variantId];
        traces = vector3d.nan(max(ind(:,1)),length(job.p2c.variants));
        relIndex = nan(max(ind(:,1)),length(job.p2c.variants));
        clusterSize = nan(max(ind(:,1)),length(job.p2c.variants));
        isVar = ismember(1:length(job.p2c.variants),unique(ind(:,2)));
        [traces(:,isVar), relIndex(:,isVar), clusterSize(:,isVar)] = calcTraces(cEBSD,ind,hpMethod,'minClusterSize',cSize);
    case {'calliper', 'shape','hist'}
        %Grains
        if length(pGrainId) == 1
            ind = [job.mergeId(job.mergeId == pGrains.id), job.variantId(job.mergeId == pGrains.id)];
        else
            ind = [job.mergeId(job.isTransformed), job.variantId(job.isTransformed)];
        end
        traces = vector3d.nan(max(ind(:,1)),length(job.p2c.variants));
        relIndex = nan(max(ind(:,1)),length(job.p2c.variants));
        clusterSize = nan(max(ind(:,1)),length(job.p2c.variants));
        %ind = ind(job.isTransformed,:);
        isVar = ismember(1:length(job.p2c.variants),unique(ind(:,2)));
        [traces(:,isVar), relIndex(:,isVar), clusterSize(:,isVar)] = calcTraces(cGrains,ind,hpMethod,'minClusterSize',cSize);
end

%% Remove entries that are NaN
if length(pGrainId) == 1
    traces = traces(pGrainId,:);
    relIndex = relIndex(pGrainId,:);
    clusterSize = clusterSize(pGrainId,:);
else
    traces = traces(pGrainId,:);
    relIndex = relIndex(pGrainId,:);
    clusterSize = clusterSize(pGrainId,:);
end
% % traces = traces(~isnan(traces));
hasTrace = ~isnan(traces) & relIndex >= rIdx;
%% Plot the computed traces and the corresponding grains/EBSD data for each variant
if plotTraces
    switch hpMethod
        case {'calliper', 'shape','hist'}  
            figure;
            plot(cGrains,cGrains.variantId);
            colormap(cmap);
            hold on
            plot(pGrains.boundary);
            for ii = 1:length(job.p2c.variants)      
                isTrace = ~isnan(traces(:,ii))  & relIndex(:,ii) >= rIdx ;  
                pIds = pGrainId(isTrace);
                cIds = cGrains(ismember(ind(:,1),pIds) & cGrains.variantId == ii).id;
                [~,ind_traces]=ismember(job.mergeId(cIds),pGrainId);       
                quiver(cGrains(ismember(cGrains.id,cIds)),traces(ind_traces,ii),'color','r'); 
            end
            colorbar;  
            set(gcf,'name',"Fitted traces");
        case {'radon','fourier'}
            % Define the window settings for a set of docked figures
            % % Ref: https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs
            warning off
            desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
            % % Define a unique group name for the dock using the function name
            % % and the system timestamp
            dockGroupName = ['Fitted traces ',char(datetime('now','Format','yyyyMMdd_HHmmSS'))];
            desktop.setGroupDocked(dockGroupName,0);
            bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            
            for ii = 1:length(job.p2c.variants)
                figH = gobjects(1);
                figH = figure('WindowStyle','docked');
                set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
                drawnow;
                
                isTrace = ~isnan(traces(:,ii));  
                pIds = pGrainId(isTrace);
                cIds = cEBSD(ismember(ind(:,1),pIds) & job.ebsd(is_transformed_EBSD).variantId == ii).id;
                [~,ind_traces]=ismember(pIds,pGrainId);
                plot(cEBSD(ismember(cEBSD.id,cIds)),'grayscale');
                hold on
                plot(pGrains.boundary)
                quiver(pGrains(ismember(pGrains.id,unique(pIds))),traces(unique(ind_traces),ii),'color','r');
                set(figH,'Name',strcat(['Variant ',num2str(ii)]),'NumberTitle','on');
            end
    end  
end

%% Get the parent orientations
oriParent = pGrains.meanOrientation;

%% Determine the variant specific parent orientations
oriPVariant = oriParent.project2FundamentalRegion .* ...
    inv(variants(job.p2c)) .* job.p2c;

%% Transform traces into the parent reference frame
tracesParent = inv(oriPVariant) .* traces;

%% Determine the habit plane (orthogonal fit)
habitPlane = perp(tracesParent(hasTrace),'robust');

%% Change Miller object to type = crystal plane
habitPlane = setDisplayStyle(habitPlane,'plane'); % ORTools default
% habitPlane.dispStyle = "hkl"; %Mtex default

%% Recompute traces from fitted habit plane
traceImPlane = cross(oriPVariant .* habitPlane,zvector);

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
h{1} = scatter(tracesParent(relIndex < rIdx),'MarkerSize',4,'MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor','k');
hold all;
h{2} = scatter(tracesParent(hasTrace),relIndex(hasTrace),'MarkerSize',6,'MarkerEdgeColor','k');
hold all
h{3} = plot(habitPlane,'plane','antipodal','linecolor','r','linewidth',2);
h{4} = plot(habitPlane,'antipodal','Marker','s','MarkerColor','r','MarkerEdgeColor','k','MarkerSize',10,'LineWidth',1,'label',{sprintMiller(habitPlane)});
mtexColorbar
hold off;
drawnow;
legend([h{:}], {'Ignored parent traces','Analysed parent traces','Habit trace','Habit plane'}, 'location', 'east');
set(gcf,'name','Spherical projection of determined traces and fitted habit plane');

% Plot ODF
if length(pGrainId) > 1
    figure();
    tpd = calcDensity(tracesParent(hasTrace),'noSymmetry','halfwidth',2.5*degree);
    contourf(tpd)
    mtexColorMap white2black
    mtexColorbar
    circle(habitPlane,'color','red','linewidth',2)
    set(gcf,'name','ODF of fitted traces and habit plane');
end

%% Plot the traces associated with the determined habit plane

if plotTraces
    figure();
    switch hpMethod
       case {'calliper', 'shape','hist'}
            plot(cGrains,cGrains.variantId);
            colormap(cmap);
            hold on
            plot(pGrains.boundary);
            for ii = 1:length(job.p2c.variants)      
                isTrace = ~isnan(traceImPlane(:,ii));  
                pIds = pGrainId(isTrace);
                cIds = cGrains(ismember(ind(:,1),pIds) & cGrains.variantId == ii).id;
                [~,ind_traces]=ismember(job.mergeId(cIds),pGrainId);             
                quiver(cGrains(ismember(cGrains.id,cIds)),traceImPlane(ind_traces,ii),'color','r'); 
            end
            colorbar;
            set(gcf,'name',"Habit plane traces");
        case {'radon','fourier'}
            % Define the window settings for a set of docked figures
            % % Ref: https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs
            warning off
            desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
            % % Define a unique group name for the dock using the function name
            % % and the system timestamp
            dockGroupName = ['Habit plane traces ',char(datetime('now','Format','yyyyMMdd_HHmmSS'))];
            desktop.setGroupDocked(dockGroupName,0);
            bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

            for ii = 1:length(job.p2c.variants)      
                %drawnow;
                figH = gobjects(1);
                figH = figure('WindowStyle','docked');
                set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
                drawnow;
                
                plot(cEBSD(job.ebsd(is_transformed_EBSD).variantId==ii),'grayscale');
                hold on
                plot(pGrains.boundary);
                
                isTrace = ~isnan(traceImPlane(:,ii));
                pIds = pGrainId(isTrace);
                [~,ind_traces]=ismember(pIds,pGrainId);
                quiver(pGrains(ismember(pGrains.id,unique(pIds))),traceImPlane(unique(ind_traces),ii),'color','r');
                set(figH,'Name',strcat(['Variant ',num2str(ii)]),'NumberTitle','on');
                drawnow;
            end          
            warning on
      end
end


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
    rTrace = round(aTrace/nTrace,4);    
    screenPrint('SubStep',sprintf(['Ratio of possible vs. analysed traces = 1 : ',...
        num2str(rTrace)]));
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
