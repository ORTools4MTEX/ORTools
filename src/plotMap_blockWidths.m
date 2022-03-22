function plotMap_blockWidths(job,varargin)
% % THIS SCRIPT WAS CONTRIBUTED BY: Dr Tuomo Nyyssönen
% % This script calculates the representative value for martensite block 
% % widths by projecting all boundary points to the vector perpendicular 
% % to the trace of the {111}a plane as per the following reference:
% % [S.Morito, H.Yoshida, T.Maki,X.Huang, Effect of block size on the
% % strength of lath martensite in low carbon steels, Mater. Sci. Eng.: A,
% % Volumes 438–440, 2006, Pages 237-240, 
% % https://doi.org/10.1016/j.msea.2005.12.048]
%
% Syntax
%  plotMap_blockWidths(job,varargin)
%
% Input
%  job          - @parentGrainreconstructor
%  pGrainId     - parent grain Id using the argument 'parentGrainId'
%
% Option
%  noScalebar   - Remove scalebar from maps
%  noFrame      - Remove frame around maps


if ~isempty(varargin) && any(strcmpi(varargin,'parentGrainId'))
    pGrainId = varargin{find(strcmpi('parentGrainId',varargin)==1)+1};
else
    error('Argument "parentGrainId" (in single quotes) not specified.');
    return;
end


%% Define the parent grain
pGrain = job.parentGrains(job.parentGrains.id == pGrainId);
pEBSD = job.ebsd(pGrain);
pEBSD = pEBSD(job.csParent);

%% Define the child grain(s)
clusterGrains = job.grainsPrior(job.mergeId == pGrainId);
cGrains = clusterGrains(job.csChild);
cEBSD = job.ebsdPrior(job.ebsdPrior.id2ind(pEBSD.id));
cEBSD = cEBSD(job.csChild);

%% Plot martensite block widths
% if check_option(varargin,'grains')
% Get all 111 vector3ds for each grain:
hh = Miller({1,1,1},{1,-1,1},{-1,1,1},{1,1,-1},job.p2c.CS);
hh = hh(job.packetId(job.mergeId == pGrainId))';
zz = pGrain.meanOrientation.project2FundamentalRegion.*hh;

% drawnow;
% figH = gobjects(1);
% figH = figure('WindowStyle','docked');
% set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
% drawnow;
% [~,mP] = plot(cGrains)
% hold all
% quiver(cGrains,cross(zz,zvector),'linecolor','r');
% quiver(cGrains,zz,'linecolor','g');
% hold off
% if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end
% if check_option(varargin,'noFrame')
%     mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
% end
% drawnow;

% % Using the function at the bottom of this script, all grain boundary
% % points of a grain are projected to a vector going through the center of
% % that grain:
[p,~,~] = projectPoints2Vector(cGrains,rotate(cross(zz,zvector),...
    rotation.byAxisAngle(zvector,90*degree)));

% % A representative value for the average halfwidth could be the mean of
% % the absolute values:
new_A = cellfun(@abs,p,'UniformOutput',false);
new_A = cellfun(@mean,new_A);
% % Vector form for visual verification:
new_A_vec = rotate(cross(zz,zvector),rotation.byAxisAngle(zvector,90*degree));
new_A_vec = normalize(new_A_vec).*new_A';
new_A_vec.antipodal = 1;

% % Calculate the block widths again and plot to visually verify
% % what the width perpendicular to the {111} trace looks like:
% % Calculate the assumed block width:
d_block_new = 2*new_A'.*sin(zz.theta);


%% Define the text output format as Latex
setLabels2Latex

%% Define the window settings for a set of docked figures
% % Ref: https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs
warning off
desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
% % Define a unique group name for the dock using the function name
% % and the system timestamp
dockGroupName = ['plotMap_variantPairs_',char(datetime('now','Format','yyyyMMdd_HHmmSS'))];
desktop.setGroupDocked(dockGroupName,0);
bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');


%% Plot the grains along with their traces and normals
drawnow;
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
[~,mP] = plot(cGrains,d_block_new,varargin{:});
hold all
ha(1) = quiver(squeeze(cGrains),squeeze(cross(zz,zvector)),'color',[1 0 0]);
ha(2) = quiver(squeeze(cGrains),squeeze(zz),'color',[0 1 0]);
ha(3) = quiver(squeeze(cGrains),squeeze(new_A_vec),'color', [0 0 1]);
legend(ha,'$111_a {\parallel} 011_m$ trace','$111_a {\parallel} 011_m$ normal','Mean of projected points')
hold off
% Define the maximum number of color levels and plot the colorbar
colormap(flipud(bone));
caxis([0 round(max(d_block_new))]);
colorbar('location','eastOutSide','lineWidth',1.25,'tickLength', 0.01,...
    'YTick', [0:1:round(max(d_block_new))],...
    'YTickLabel',num2str([0:1:round(max(d_block_new))]'), 'YLim', [0 round(max(d_block_new))],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(figH,'Name','Map: Trace & normal for block width calculation','NumberTitle','on');
if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end
if check_option(varargin,'noFrame')
    mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
end
drawnow;


%% Plot the martensite block width histogram
drawnow;
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
class_range = 0:0.25:round(max(d_block_new));
abs_counts = histc(d_block_new,class_range);
norm_counts = abs_counts./sum(abs_counts);
h = bar(class_range,norm_counts,'hist');
h.FaceColor =[162 20 47]./255;
set(gca,'FontSize',14);
set(gca,'xlim',[0 class_range(end)+0.5]);
set(gca,'XTick',0:0.5:class_range(end)+0.5);
xlabel('\bf Martensite block width [$\bf \mu$m]','FontSize',14,'FontWeight','bold');
%     xlabel('Martensite block width [\mum]','FontSize',14,'FontWeight','bold');
ylabel('\bf Relative frequency [$\bf f$(g)]','FontSize',14);
%     ylabel('Relative frequency ({\itf}(g))','FontSize',14,'FontWeight','bold');
set(figH,'Name','Histogram: Martensite block width','NumberTitle','on');
screenPrint('Step',['Figure ',num2str(figH.Number),': martensite block width histogram']);
drawnow;
% % Output histogram data in a table
if size(class_range,2)>1; class_range = class_range'; end
if size(abs_counts,2)>1; abs_counts = abs_counts'; end
if size(norm_counts,2)>1; norm_counts = norm_counts'; end
table(class_range,norm_counts,'VariableNames',{'blockWidth','Freq'})

% % The figure and histogram show that block widths are consistently
% % smaller when calculated this way

%% Place first tabbed figure on top and return
warning on
allfigh = findall(0,'type','figure');
if length(allfigh) > 1
    figure(length(allfigh)-1);
else
    figure(1);
end
warning(bakWarn);
pause(1); % Reduce rendering errors
return
end


function [p,px,py] = projectPoints2Vector(grains,v)
% This function projects all grain boundary points to a vector
% going through the center of that grain
%
% Syntax
% [p,px,py] = projectPoints2Vector(grains,v)
%
% Input:
%  grains   - @grain2d
%  v        - @vector3d, image plane components will be used
%
% Output:
%  p     - cell containing projection lengths for all boundary points
%  px    - cell containing projection point x coordinates
%  py    - cell containing projection point y coordinates
%
% Example:
% mtexdata testgrains
% v = caliper(grains(8),'shortest')
% p = projectPoints2Vector(grains(8),v)

if length(grains) ~= length(v)
    error('number of input must be identical')
end

V = grains.V;
poly = grains.poly;
ce = grains.centroid;

for ii = 1:length(grains)
    % Get vertices
    Vg = V(poly{ii},:);
    
    % Center vertices
    Vg = [Vg(:,1)-ce(ii,1) Vg(:,2)-ce(ii,2)];
    
    a = v(ii).y/v(ii).x;
    b = -1;
    c = Vg(:,2) - Vg(:,1)*a;
    
    p{ii} = (a*Vg(:,2) - b*Vg(:,1))./sqrt(a^2+b^2);
    px{ii} = (-a*c)/(a^2+b^2);
    py{ii} = (-b*c)/(a^2+b^2);
end
end