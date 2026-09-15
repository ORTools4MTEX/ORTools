function [variantPairs_boundary, variantGrains] = plotMap_KSvariantPairs(job,varargin)
%% Function description:
% This function plots an ebsd map of the equivalent pairs of martensitic 
% variants (block boundaries) within individual crystallographic packets 
% in lath martensite microstructures as per the analysis in the following 
% reference:
% S. Morito, A.H. Pham, T. Hayashi, T. Ohba, Block boundary analyses to
% identify martensite and bainite, Mater. Today Proc., Volume 2,
% Supplement 3, 2015, Pages S913-S916.
% (https://doi.org/10.1016/j.matpr.2015.07.430)
%
%% Syntax:
% variantPairs_boundary = plotMap_KSvariantPairs(job,varargin)
%
%% Input:
%  job          - @parentGrainreconstructor
%  pGrainId     - parent grain Id using the argument 'parentGrainId'
%
%% Output:
% variantPairs_boundary - a structure variable of the groups of equivalent
%                         variant pair boundaries
%
%% Options:
%  include     - Includes equivalent variant pairs between 
%                crystallographic packets
%  noScalebar  - Remove scalebar from maps
%  noFrame     - Remove frame around maps

warnText = sprintf(['\n-----------------------------------------------------------\n',...
    'The ''plotMap_KSvariantPairs'' function is recommended for:\n',...
    '    (1) lath martensite microstructures, AND\n',...
    '    (2) the Kurdjumov-Sachs OR.\n',...
    '-----------------------------------------------------------\n']);
warning(warnText);

% Check if the user has specified the inclusion of variant pairs across 
% different crystallographic packets
includeFlag = check_option(varargin,'include');

pGrainId = get_option(varargin,'parentGrainId',[]);
if pGrainId
    [grainsTemp,ebsdTemp] = computeVariantGrains(job,'parentGrainId',pGrainId);
    pGrain = job.parentGrains(job.parentGrains.id == pGrainId);
else
    warning('Argument ''parentGrainId'' not specified. Equivalent variant pairs will be calculated for the EBSD map.');
    [grainsTemp,ebsdTemp] = computeVariantGrains(job);
end

variantGrains = grainsTemp(job.csChild);
variantGrains = variantGrains(~isnan(variantGrains.prop.variantId));
ebsdC = ebsdTemp(job.csChild);


%% Determine the variant pairs
% Derive variant types 1 to 6 from variants 1 to 24
variantGrains.prop.variantType = variantGrains.variantId - (variantGrains.packetId-1) * 24/4;
% Get the boundary segments and neighbouring variants
variantBoundary = variantGrains.boundary(variantGrains.CS,variantGrains.CS);
variantBoundaryIds = variantBoundary.grainId;

[c,~] = ismember(variantBoundaryIds,variantGrains.id);
variantBoundaryIds(any(~c,2),:) = [];
variantBoundary(any(~c,2)) = [];

% Identify any special boundaries, here V1-V2 : V1:V6
varTypes = variantGrains(variantGrains.id2ind(variantBoundaryIds)).variantType;
cond(1,:) = any(ismember(varTypes,1),2) & any(ismember(varTypes,2),2) | ...
    any(ismember(varTypes,3),2) & any(ismember(varTypes,4),2) | ...
    any(ismember(varTypes,5),2) & any(ismember(varTypes,6),2);     %V1-V2
cond(2,:) = any(ismember(varTypes,1),2) & any(ismember(varTypes,3),2) | ...
    any(ismember(varTypes,1),2) & any(ismember(varTypes,5),2) | ...
    any(ismember(varTypes,2),2) & any(ismember(varTypes,4),2) | ...
    any(ismember(varTypes,2),2) & any(ismember(varTypes,6),2) | ...
    any(ismember(varTypes,3),2) & any(ismember(varTypes,5),2) | ...
    any(ismember(varTypes,4),2) & any(ismember(varTypes,6),2);     %V1-V3(V5)
cond(3,:) = any(ismember(varTypes,1),2) & any(ismember(varTypes,6),2) | ...
    any(ismember(varTypes,2),2) & any(ismember(varTypes,3),2) | ...
    any(ismember(varTypes,4),2) & any(ismember(varTypes,5),2);     %V1-V6
cond(4,:) = any(ismember(varTypes,1),2) & any(ismember(varTypes,4),2) | ...
    any(ismember(varTypes,2),2) & any(ismember(varTypes,5),2) | ...
    any(ismember(varTypes,3),2) & any(ismember(varTypes,6),2);     %V1-V4

for ii = 1:size(cond,1)
    if includeFlag % include variant pairs across crystallographic packets
        variantPairs_boundary{ii} = variantBoundary(cond(ii,:));
    else
        temp_variantPairs_boundary = variantBoundary(cond(ii,:));
        % find the packetId of the variant pairs
        vP_pId = variantGrains(temp_variantPairs_boundary.grainId).prop.packetId;
        % find variant pairs with the same packetId
        likePacketId = all(vP_pId == vP_pId(:,1), 2);
        % only keep variant pairs with the same packetId
        variantPairs_boundary{ii} = temp_variantPairs_boundary(likePacketId);
    end
end


%% Define the text output format as Latex
setInterp2Latex

%% Define the window settings for a set of docked figures
% % Ref: https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs
warning off
desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
% % Define a unique group name for the dock using the function name
% % and the system timestamp
dockGroupName = ['plotMap_KSvariantPairs_',char(datetime('now','Format','yyyyMMdd_HHmmSS'))];
desktop.setGroupDocked(dockGroupName,0);
bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');


%% Plot a map of variant pairs
% Plot the boundaries
colors = {[1 0 0],[0 1 0],[0 0 1],[1 1 0]};
drawnow;
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
plot(ebsdTemp,'grayscale');
hold all;
[hL(1),mP] = plot(variantGrains.boundary,varargin{:});
hL(1).FaceColor = 'k';
xlabelString = {'V1-V2','V1-V3(V5)','V1-V6','V1-V4'};
for ii = 1:size(cond,1)
    [hL(end+1),mP] = plot(variantPairs_boundary{ii},'linecolor',colors{ii},'DisplayName',xlabelString{ii},varargin{:});
    hL(end).FaceColor = colors{ii};
    hold all;
end
if ~isempty(varargin) && any(strcmpi(varargin,'parentGrainId'))
    plot(pGrain.boundary,varargin{:},'linecolor',[0.45 0.45 0.45],varargin{:});
end
[hL(end+1),mP] = plot(job.grains.boundary,varargin{:});
hL(end).FaceColor = 'k';
hold off
legend
set(figH,'Name','Map: Equivalent variant pair Boundaries','NumberTitle','on');
if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end
if check_option(varargin,'noFrame')
    mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
end
drawnow;


%% Plot the variant pair boundary fractions
% Plot a bar graph to show the special boundary fractions
for ii = 1:size(cond,1)
    variantPairs_boundaryFraction(ii) = sum(variantPairs_boundary{ii}.segLength)/sum(variantBoundary(any(cond)).segLength);
end
drawnow;
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;

xlabelString = categorical(xlabelString);
h = bar(xlabelString,variantPairs_boundaryFraction);
h.FaceColor =[162 20 47]./255;
set(gca,'FontSize',14);
% ylabel('Relative block boundary frequency ({\itf}(g))');
ylabel('\bf Relative block boundary frequency [$\bf f$(g)]');
set(figH,'Name','Histogram: Variant pair boundary fractions','NumberTitle','on');
screenPrint('Step',['Figure ',num2str(figH.Number),': variant pair boundary fraction histogram']);
drawnow;
% % Output histogram data in a table
if size(xlabelString,2)>1; xlabelString = xlabelString'; end
if size(variantPairs_boundaryFraction,2)>1; variantPairs_boundaryFraction = variantPairs_boundaryFraction'; end
table(xlabelString,variantPairs_boundaryFraction,'VariableNames',{'eqVariants','Freq'})



%% Determine the block boundary density
ebsdGrid = job.ebsdPrior.gridify;
mapArea = prod(ebsdGrid.size) * norm(ebsdGrid.d1) * norm(ebsdGrid.d2);
for ii = 1:size(cond,1)
    variantPairs_boundaryFraction(ii) = sum(variantPairs_boundary{ii}.segLength)/mapArea;
end
drawnow;
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
h = bar(categorical(xlabelString),variantPairs_boundaryFraction);
h.FaceColor =[162 20 47]./255;
set(gca,'FontSize',14);
% ylabel(['Block boundary density [um/',ebsdC.scanUnit,'^2]'])
ylabel('\bf Block boundary density [$\bf \mu m / \mu m^{2}$]')
set(figH,'Name','Histogram: Variant pair boundary density','NumberTitle','on');
screenPrint('Step',['Figure ',num2str(figH.Number),': variant pair boundary density histogram']);

drawnow;
% % Output histogram data in a table
if size(xlabelString,2)>1; xlabelString = xlabelString'; end
if size(variantPairs_boundaryFraction,2)>1; variantPairs_boundaryFraction = variantPairs_boundaryFraction'; end
table(xlabelString,variantPairs_boundaryFraction,'VariableNames',{'eqVariants','Density'})


%% Place first tabbed figure on top and return
warning on
allfigh = findall(0,'type','figure');
if length(allfigh) > 1
    figure(length(allfigh)-2);
else
    figure(1);
end
warning(bakWarn);
pause(1); % Reduce rendering errors
return
end


function [pGrain,pEBSD,cGrains,cEBSD] = setParentChildData(job,pGrainId)
%% Define the parent grain
pGrain = job.parentGrains(job.parentGrains.id == pGrainId);
pEBSD = job.ebsd(pGrain);
pEBSD = pEBSD(job.csParent);

%% Define the child grain(s)
clusterGrains = job.grainsPrior(job.mergeId == pGrainId);
cGrains = clusterGrains(job.csChild);
cEBSD = job.ebsdPrior(job.ebsdPrior.id2ind(pEBSD.id));
cEBSD = cEBSD(job.csChild);
end
