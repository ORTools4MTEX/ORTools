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
%  Radon          - Radon based algorithm (ebsd pixel data used)
%  Fourier        - Fourier based algorithm (ebsd pixel data used)
%  Calliper       - Shortest calliper based algorithm (grain data used)
%  Shape          - Characteristic grain shape based algorithm (grain data 
%                   used)
%  Hist           - Circular histogram based algorithm (grain data used)
%  minClusterSize - Minimum number of pixels required for trace 
%                   determination (default = 100)
%  reliability    - Minimum value of accuracy in determined traces
%                   used to compute the habit plane (varies from 0 to 1, 
%                   default = 0.5)
%  colormap       - Defines the colormap to display the variants (default 
%                   =  haline)
%  noScalebar     - Remove scalebar from maps
%  noFrame        - Remove frame around maps
%  plotTraces     - Logical used to plot the trace & habit plane output


if all(isnan(job.variantId))
    job.calcVariants;  % Compute variants
end
job.calcParentEBSD; % Apparently needs to be repeated

hpMethod = lower(get_flag(varargin,{'calliper','shape','hist','fourier','radon'},'radon'));
cSize = get_option(varargin,'minClusterSize',100);
rIdx = get_option(varargin,'reliability',0.5);
pGrainId = get_option(varargin,'parentGrainId',job.parentGrains.id);
cmap = get_option(varargin,'colormap',haline);
linecolor = get_option(varargin,'linecolor','r');
plotTraces = check_option(varargin,'plotTraces');


%% Define the parent grain(s) and parent ebsd data
isTransformed_EBSD = ~isnan(job.ebsd.variantId);
%Get parent grain and EBSD data (only the reconstructed one!)
pGrains = job.parentGrains(job.parentGrains.id == pGrainId);
pEBSD = job.ebsd(isTransformed_EBSD);

%% Define the child grain(s) and child ebsd data
if length(pGrainId) == 1
    cGrains = job.grainsPrior(job.mergeId == pGrains.id);
    cEBSD = job.ebsdPrior(cGrains);
else
    cGrains = job.transformedGrains;
    cEBSD = job.ebsdPrior(isTransformed_EBSD);
end

%% Define a discretised colormap equal to the number of child variants
set(0,'DefaultFigureVisible','off');
cmap = discreteColormap(cmap,length(job.p2c.variants));
% allfigh = findall(0,'type','figure');
% if length(allfigh) > 1
%     close(figure(length(allfigh)+1));
% else
%     close(figure(1));
% end
set(0,'DefaultFigureVisible','on');


%% Calculate the traces of the child grains
switch hpMethod
    case {'radon','fourier'}
        %EBSD
        ind = [pEBSD.grainId,job.ebsd(isTransformed_EBSD).variantId];
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
traces.antipodal = true;

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
hasTrace = ~isnan(traces) & relIndex >= rIdx;

%% Plot the computed traces and the corresponding grains/EBSD data for each variant
if plotTraces
    switch hpMethod
        case {'calliper', 'shape','hist'}
            figure();
            [~,mP] = plot(cGrains,cGrains.variantId);
            colormap(cmap);
            hold all
            plot(pGrains.boundary);
            for ii = 1:length(job.p2c.variants)
                isTrace = ~isnan(traces(:,ii))  & relIndex(:,ii) >= rIdx ;
                pIds = pGrainId(isTrace);
                cIds = cGrains(ismember(ind(:,1),pIds) & cGrains.variantId == ii).id;
                [~,ind_traces] = ismember(job.mergeId(cIds),pGrainId);
                q = quiver(cGrains(ismember(cGrains.id,cIds)),traces(ind_traces,ii),'color',linecolor);
                q.ShowArrowHead = 'off'; q.Marker = 'none';
            end
            colorbar;
            hold off
            set(gcf,'name','Fitted traces');
            if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end

            if check_option(varargin,'noFrame')
                mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
            end

        case {'radon','fourier'}
            % Define the window settings for a set of docked figures
            % % Ref: https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs
            warning off
            desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
            % % Define a unique group name for the dock using the function name
            % % and the system timestamp
            dockGroupName = ['fittedTraces_',char(datetime('now','Format','yyyyMMdd_HHmmSS'))];
            desktop.setGroupDocked(dockGroupName,0);
            bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

            for ii = 1:length(job.p2c.variants)
                drawnow;
                figH = gobjects(1);
                figH = figure('WindowStyle','docked');
                set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
                drawnow;

                isTrace = ~isnan(traces(:,ii));
                pIds = pGrainId(isTrace);
                cIds = cEBSD(ismember(ind(:,1),pIds) & job.ebsd(isTransformed_EBSD).variantId == ii).id;
                [~,ind_traces] = ismember(pIds,pGrainId);
                plot(cEBSD(ismember(cEBSD.id,cIds)),repmat(cmap(ii,:),[length(cIds) 1]));%'grayscale');
                hold all
                [~,mP] = plot(pGrains.boundary);
                q = quiver(pGrains(ismember(pGrains.id,unique(pIds))),traces(unique(ind_traces),ii),'color',linecolor);
                q.ShowArrowHead = 'off'; q.Marker = 'none';
                hold off
                set(figH,'Name',strcat(['Variant ',num2str(ii)]),'NumberTitle','on');
                if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end

                if check_option(varargin,'noFrame')
                    mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
                end
                drawnow;
            end
            warning on
            warning(bakWarn);
            pause(1); % reduce rendering errors
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
% [habitPlane,idRobust] = perp(tracesParent(hasTrace),'robust'); % TO-DO
% hasTrace = hasTrace(idRobust);

%% Change Miller object to type = crystal plane
habitPlane = setDisplayStyle(habitPlane,'plane'); % ORTools default
% habitPlane.dispStyle = "hkl"; %Mtex default

%% Recompute traces from fitted habit plane
traceImPlane = cross(oriPVariant .* habitPlane,zvector);

% if length(pGrainId) > 1
    %% Calculate the angular deviation between the traces and the fitted habit plane
    deviationAll = 90 - angle(habitPlane,tracesParent(~isnan(tracesParent)),'noSymmetry')./degree;
    deviationAna = 90 - angle(habitPlane,tracesParent(hasTrace),'noSymmetry')./degree;
    % Mean deviation
    meanDeviationAll = mean(deviationAll);
    meanDeviationAna = mean(deviationAna);
    % Std deviation
    stdDeviationAll = std(deviationAll);
    stdDeviationAna = std(deviationAna);
    % Quantiles
    quantileAll = quantile(deviationAll,[0.25 0.5 0.75]);
    quantileAna = quantile(deviationAna,[0.25 0.5 0.75]);
    % Return the statistics of fitting
    statistics = containers.Map(...
        {'relIndex','clusterSize',...
        'DeviationAll','meanDeviationAll','stdDeviationAll','QuantilesAll',...
        'DeviationAna','meanDeviationAna','stdDeviationAna','QuantilesAna'},...
        {relIndex,clusterSize,...
        deviationAll,meanDeviationAll,stdDeviationAll,quantileAll,...
        deviationAna,meanDeviationAna,stdDeviationAna,quantileAna},...
        'UniformValues',false);
% else
%     statistics = NaN;
% end

%% Plot and return the habit plane

% Plot traces and fitted habit planes in spherical projection
figure();
h{1} = scatter(tracesParent(~hasTrace),'MarkerSize',6,'MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor','k','MarkerFaceAlpha',0.5);
hold all;
h{2} = scatter(tracesParent(hasTrace),relIndex(hasTrace),'MarkerSize',6,'MarkerEdgeColor','k');
hold all
h{3} = plot(habitPlane,'plane','antipodal','linecolor','r','linewidth',2);
h{4} = plot(habitPlane,'antipodal','Marker','s','MarkerColor','r','MarkerEdgeColor','k','MarkerSize',10,'LineWidth',1,'label',{sprintMiller(habitPlane)});
mtexColorMap jet
colorbar;
caxis([0,1])
hold off;
drawnow;
legend([h{:}], {'Discarded parent traces','Analysed parent traces','Habit plane','Habit plane normal'}, 'location', 'east');
set(gcf,'name','Spherical projection of determined traces and fitted habit plane');
clear h;

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
    switch hpMethod
        case {'calliper', 'shape','hist'}
            figure();
            [~,mP] = plot(cGrains,cGrains.variantId);
            colormap(cmap);
            hold all
            plot(pGrains.boundary);
            for ii = 1:length(job.p2c.variants)
                isTrace = ~isnan(traceImPlane(:,ii));
                pIds = pGrainId(isTrace);
                cIds = cGrains(ismember(ind(:,1),pIds) & cGrains.variantId == ii).id;
                [~,ind_traces]=ismember(job.mergeId(cIds),pGrainId);
                q = quiver(cGrains(ismember(cGrains.id,cIds)),traceImPlane(ind_traces,ii),'color',linecolor);
                q.ShowArrowHead = 'off'; q.Marker = 'none';
            end
            hold off
            colorbar;
            set(gcf,'name','Habit plane traces');
            if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end

            if check_option(varargin,'noFrame')
                mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
            end
            %Angular deviation between fitted and HP traces
            dalpha = angle(traces,traceImPlane)./degree;
            figure();
            for ii = 1:length(job.p2c.variants)
                isTrace = ~isnan(traces(:,ii));
                pIds = pGrainId(isTrace);
                cIds = cGrains(ismember(ind(:,1),pIds) & cGrains.variantId == ii).id;
                [~,ind_traces]=ismember(job.mergeId(cIds),pGrainId);
                plot(cGrains(ismember(cGrains.id,cIds)),dalpha(ind_traces,ii));
                hold on
            end
            plot(pGrains.boundary,'linewidth',3);
            colormap(jet);
            hold off
            colorbar;
            set(gcf,'name','Misfit between trace and fitted habit plane');
            if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end

            if check_option(varargin,'noFrame')
                mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
            end


        case {'radon','fourier'}
            % Define the window settings for a set of docked figures
            % % Ref: https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs
            warning off
            desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
            % % Define a unique group name for the dock using the function name
            % % and the system timestamp
            dockGroupName = ['habitPlaneTraces_',char(datetime('now','Format','yyyyMMdd_HHmmSS'))];
            desktop.setGroupDocked(dockGroupName,0);
            bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

            for ii = 1:length(job.p2c.variants)
                drawnow;
                figH = gobjects(1);
                figH = figure('WindowStyle','docked');
                set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
                drawnow;

                plot(cEBSD(job.ebsd(isTransformed_EBSD).variantId==ii),repmat(cmap(ii,:),[length(cEBSD(job.ebsd(isTransformed_EBSD).variantId==ii)) 1]));%'grayscale');
                hold all
                [~,mP] = plot(pGrains.boundary);

                isTrace = ~isnan(traceImPlane(:,ii));
                pIds = pGrainId(isTrace);
                [~,ind_traces] = ismember(pIds,pGrainId);
                q = quiver(pGrains(ismember(pGrains.id,unique(pIds))),traceImPlane(unique(ind_traces),ii),'color',linecolor);
                q.ShowArrowHead = 'off'; q.Marker = 'none';
                hold off
                set(figH,'Name',strcat(['Variant ',num2str(ii)]),'NumberTitle','on');
                if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end

                if check_option(varargin,'noFrame')
                    mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
                end
                drawnow;
            end
            warning on
            warning(bakWarn);
            pause(1); % reduce rendering errors
    end
    

   
   
end



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
%     if length(pGrainId) > 1
        screenPrint('SubStep',sprintf(['Number of analysed parent grains = ',...
            num2str(length(oriParent))]));
        screenPrint('SubStep',sprintf(['Mean deviation (all) = ',...
            num2str(meanDeviationAll),'° ± ',num2str(stdDeviationAll),'°']));
        screenPrint('SubStep',sprintf(['Mean deviation (analysed) = ',...
            num2str(meanDeviationAna),'° ± ',num2str(stdDeviationAna),'°']));
        screenPrint('SubStep',sprintf(['Quantiles (all) [25, 50, 75 percent] = [',...
            num2str(quantileAll(1)),'°, ',num2str(quantileAll(2)),'°, ',num2str(quantileAll(3)),'°]']));
        screenPrint('SubStep',sprintf(['Quantiles (analysed) [25, 50, 75 percent] = [',...
            num2str(quantileAna(1)),'°, ',num2str(quantileAna(2)),'°, ',num2str(quantileAna(3)),'°]']));
%     end
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
    for ii = 1:length(mill)
        if check_option(varargin,'round')
            s = [s,num2str(round(mil.(mill{ii}),0))];
        else
            s = [s,num2str(mil.(mill{ii}),'%0.4f')];
        end
        if ii<length(mill)
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
    for ii = 1:length(mill)
        if check_option(varargin,'round')
            s = [s,num2str(round(mil.(mill{ii}),0))];
        else
            s = [s,num2str(mil.(mill{ii}),'%0.4f')];
        end
        if ii<length(mill)
            s = [s,','];
        end
    end
    s = [s,']'];
end
end


%% Sub-divide a default colormap palette into a user specified number of 
% discrete colors to improve on the visual distinction between bins/levels.
function outcmap = discreteColormap(incmap,nbins)

% check for input bin size
if length(incmap) < nbins
    error('Maximum number of bins exceeded.');
    return;
end

% generate a linearly spaced [n x 1] vector of row indices based on:
% an interval = 1:maximum number of rows as the input colormap
% the spacing between the points = (length(incmap)-1)/(nbins-1)
out = [linspace(1,length(incmap),nbins)]';

% convert the row indices between 2:end-1 to integers
out(2:end-1,1) = round(out(2:end-1,1));

% re-assign the row indices to the colormap
outcmap = incmap(out,:);
end
