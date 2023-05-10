function [habitPlane,statistics] = computeHabitPlane(job,varargin)
% Compute the habit plane based on determined traces of a 2D map as per the
% following reference:
% T. Nyyssonen, A.A. Gazder, R. Hielscher, F. Niessen, Habit plane 
% determination from reconstructed parent phase orientation maps 
% (https://doi.org/10.48550/arXiv.2303.07750)
%
% Syntax
% [hPlane,statistics] = computeHabitPlane(job)
%
% Input
%  job      - @parentGrainReconstructor
%
% Output
%  hPlane      - @Miller     = Habit plane
%  statistics  - @Container  = Statistics of fitting
%
% Options
%  minClusterSize - minimum number of pixels required for trace computation (default: 100) 
%  Radon          - Radon based algorithm (pixel data used)
%  Fourier        - Fourier based algorithm (pixel data used)
%  Shape          - Characteristic grain shape based algorithm (grain data used)
%  Hist           - Circular histogram based algorithm (grain data used)


if all(isnan(job.variantId))
    job.calcVariants  % Compute variants
end

% Get child grains
childGrains = job.grainsPrior;

% Calculate the traces of the child grains
[traces, relIndex, clusterSize] = calcTraces(childGrains, [job.mergeId(:), job.variantId(:)],varargin);

% Only consider those traces that have a reconstructed parent orientation
traces = traces(job.isParent,:); 

% Get the parent orientations
oriParent = job.parentGrains.meanOrientation;

% Determine the variant specific parent orientations
oriPVariant = oriParent.project2FundamentalRegion .* ...
    inv(variants(job.p2c)) .* job.p2c; 

% Transform traces into the parent reference frame
tracesParent = inv(oriPVariant) .* traces;

% Determine the habit plane (orthogonal fit)
habitPlane = perp(tracesParent,'robust'); 

% Change Miller object to type crystal plane
habitPlane = setDisplayStyle(habitPlane,'plane'); % ORTools default
% habitPlane.dispStyle = "hkl"; %Mtex default

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


%% Plot and return the habit plane
% Plot traces and fitted habit plane
figure;
h{1} = scatter(tracesParent,'MarkerSize',6,'MarkerFaceColor','k','MarkerFaceAlpha',0.4,'MarkerEdgeAlpha',0.5);
hold all
h{2} = plot(habitPlane,'plane','linecolor','r','linewidth',2);
h{3} = plot(habitPlane,'Marker','s','MarkerColor','r','MarkerEdgeColor','k','MarkerSize',10,'LineWidth',1,'label',{sprintMiller(habitPlane)});
hold off;
drawnow;
legend([h{:}], {'Parent traces','Habit trace','Habit plane'}, 'location', 'east');

figure;
tpd = calcDensity(tracesParent,'noSymmetry','halfwidth',2.5*degree);
contourf(tpd)
mtexColorMap white2black
mtexColorbar
circle(habitPlane,'color','red','linewidth',2)



%% Output habit plane text
screenPrint('Step','Detailed information on the computed habit plane:');
screenPrint('SubStep',sprintf(['Habit plane (as-computed) = ',...
    sprintMiller(habitPlane)]));
screenPrint('SubStep',sprintf(['Habit plane (rounded-off) = ',...
    sprintMiller(habitPlane,'round')]));
screenPrint('SubStep',sprintf(['Nr. analysed traces = ',...
    num2str(length(find(~isnan(traces))))]));
screenPrint('SubStep',sprintf(['Nr. analysed parent grains = ',...
    num2str(length(oriParent))]));
screenPrint('SubStep',sprintf(['Mean deviation = ',...
    num2str(meanDeviation),'° ± ',num2str(stdDeviation),'°']));
screenPrint('SubStep',sprintf(['Quantiles [25, 50, 75 percent] = [',...
    num2str(quantiles(1)),'°, ',num2str(quantiles(2)),'°, ',num2str(quantiles(3)),'°]']));
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

