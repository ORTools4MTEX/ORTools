function plotStack(job,pGrainId,varargin)
% plot maps of a prior parent grain
%
% Syntax
%  plotStack(job,pGrainId)
%
% Input
%  job          - @parentGrainreconstructor
%  pGrainId     - parent grain Id
%  direction    - @vector3d
%
% Option
%  grains       - plot grain data instead of EBSD data
%  noScalebar   - Remove scalebar from maps
%  noFrame      - Remove frame around maps


vector = getClass(varargin,'vector3d',vector3d.X);
%% Define the parent grain
pGrain = job.parentGrains(job.parentGrains.id == pGrainId);
pEBSD = job.ebsd(pGrain);
pEBSD = pEBSD(job.csParent);
% Define the parent grain IPF notation
ipfKeyParent = ipfHSVKey(job.csParent);
ipfKeyParent.inversePoleFigureDirection = vector;
% Define the parent PDF
hParent = Miller(0,0,1,job.csParent,'hkl');

%% Define the child grain(s)
clusterGrains = job.grainsPrior(job.mergeId == pGrainId);
cGrains = clusterGrains(job.csChild);
cEBSD = job.ebsdPrior(job.ebsdPrior.id2ind(pEBSD.id));
cEBSD = cEBSD(job.csChild);
% Define the child grain(s) IPF notation
ipfKeyChild = ipfHSVKey(job.csChild);
ipfKeyChild.inversePoleFigureDirection = vector;
% Define the child PDF
hChild = Miller(0,0,1,job.csChild,'hkl');
hParent = Miller(0,0,1,job.csParent,'hkl');

%% Define the maximum number of variants and packets for the p2c OR
maxVariants = length(job.p2c.variants);
maxPackets = max(job.packetId);

%% Define the window settings for a set of docked figures
% % Ref: https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs
warning off
desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
% % Define a unique group name for the dock using the function name
% % and the system timestamp
dockGroupName = ['plotStack_',char(datetime('now','Format','yyyyMMdd_HHmmSS'))];
desktop.setGroupDocked(dockGroupName,0);
bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');



%% Plot the parent phase map
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if check_option(varargin,'grains')
    plot(pGrain);
else
    plot(pEBSD);
end
hold all
[~,mP] = plot(pGrain.boundary,...
    'lineWidth',1,'lineColor',[0 0 0]);
hold off
set(figH,'Name','Map: Parent phase + GBs','NumberTitle','on');
if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end

if check_option(varargin,'noFrame')
    mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
end
drawnow;


%% Plot the child phase map
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if check_option(varargin,'grains')
    plot(cGrains);
else
    plot(cEBSD);
end
hold all
plot(pGrain.boundary,...
    'lineWidth',1,'lineColor',[0.5 0.5 0.5]);
[~,mP] = plot(cGrains.boundary,...
    'lineWidth',1,'lineColor',[0 0 0]);

hold off
set(figH,'Name','Map: Child phase + GBs','NumberTitle','on');
if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end
if check_option(varargin,'noFrame')
    mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
end
drawnow;


%% Plot the parent IPF map
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if check_option(varargin,'grains')
    cbsParent = ipfKeyParent.orientation2color(pGrain.meanOrientation);
    plot(pGrain,cbsParent);
else
    cbsParent = ipfKeyParent.orientation2color(pEBSD.orientations);
    plot(pEBSD,cbsParent);
end
hold all
[~,mP] = plot(pGrain.boundary,...
    'lineWidth',1,'lineColor',[0 0 0]);
hold off
set(figH,'Name','Map: Parent grain IPF_x + GBs','NumberTitle','on');
if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end
if check_option(varargin,'noFrame')
    mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
end
drawnow;


%% Plot the child IPF map
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if check_option(varargin,'grains')
    cbsChild = ipfKeyChild.orientation2color(cGrains.meanOrientation);
    plot(cGrains,cbsChild);
else
    cbsChild = ipfKeyChild.orientation2color(cEBSD.orientations);
    plot(cEBSD,cbsChild);
end
hold all
plot(pGrain.boundary,...
    'lineWidth',1,'lineColor',[0.5 0.5 0.5]);
[~,mP] = plot(cGrains.boundary,...
    'lineWidth',1,'lineColor',[0 0 0]);
hold off
set(figH,'Name','Map: Child grain IPF_x + GBs','NumberTitle','on');
if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end
if check_option(varargin,'noFrame')
    mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
end
drawnow;


%% Plot the child variant map
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if check_option(varargin,'grains')
    plot(cGrains(~isnan(cGrains.variantId)),cGrains.variantId(~isnan(cGrains.variantId)));
else
    [varIds,packIds] = calcVariantId(pGrain.meanOrientation,cEBSD.orientations,job.p2c, ...
        'variantMap', job.variantMap);
    plot(cEBSD,varIds);
end

hold all
plot(pGrain.boundary,...
    'lineWidth',1,'lineColor',[0.5 0.5 0.5]);
[~,mP] = plot(cGrains.boundary,...
    'lineWidth',1,'lineColor',[0 0 0]);
hold off
% Define the maximum number of color levels and plot the colorbar
colormap(jet(maxVariants));
caxis([1 maxVariants]);
colorbar('location','eastOutSide','lineWidth',1.25,'tickLength', 0.01,...
    'YTick', [1:1:maxVariants],...
    'YTickLabel',num2str([1:1:maxVariants]'), 'YLim', [1 maxVariants],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(figH,'Name','Map: Child grain(s) variant Id(s) + GBs','NumberTitle','on');
if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end
if check_option(varargin,'noFrame')
    mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
end
drawnow;


%% Plot the child packet map
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if isnan(maxPackets)
    maxPackets = max(packIds);
end
if check_option(varargin,'grains')
    plot(cGrains(~isnan(cGrains.packetId)),cGrains.packetId(~isnan(cGrains.packetId)));
else
    plot(cEBSD,packIds);
end
hold all
plot(pGrain.boundary,...
    'lineWidth',1,'lineColor',[0.5 0.5 0.5]);
[~,mP] = plot(cGrains.boundary,...
    'lineWidth',1,'lineColor',[0 0 0]);
hold off
% Define the maximum number of color levels and plot the colorbar
colormap(viridis);
caxis([1 maxPackets]);
colorbar('location','eastOutSide','lineWidth',1.25,'tickLength', 0.01,...
    'YTick', [1:1:maxPackets],...
    'YTickLabel',num2str([1:1:maxPackets]'), 'YLim', [1 maxPackets],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(figH,'Name','Map: Child grain(s) packet Id(s) + GBs','NumberTitle','on');
if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end
if check_option(varargin,'noFrame')
    mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
end
drawnow;


%% Plot the parent orientation PDF
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if check_option(varargin,'grains')
    plotPDF(pGrain.meanOrientation,...
        hParent,...
        'equal','antipodal',...
        'MarkerSize',10,'MarkerFaceColor',[1 1 1],...
        'lineWidth',1,'MarkerEdgeColor',job.csParent.color);
else
    plotPDF(pEBSD.orientations,...
        hParent,...
        'equal','antipodal',...
        'MarkerSize',10,'MarkerFaceColor',[1 1 1],...
        'lineWidth',1,'MarkerEdgeColor',job.csParent.color);
end
hold off
set(figH,'Name','PDF: Parent grain orientation','NumberTitle','on');
drawnow;


%% Plot the ideal child variant PDF
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
plotPDF_variants(job,pGrain.meanOrientation,hChild);
set(figH,'Name','PDF: Child grain(s) IDEAL variant Id(s)','NumberTitle','on');
drawnow;


%% Plot the ideal child packet PDF
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
plotPDF_packets(job,pGrain.meanOrientation,hChild);
set(figH,'Name','PDF: Child grain(s) IDEAL packet Id(s)','NumberTitle','on');
drawnow;


%% Plot the ideal parent PDF
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
plotPDF(pGrain.meanOrientation,hParent,'markersize',12,'markerfacecolor' ,'k');
set(figH,'Name','PDF: Mean parent grain orientation','NumberTitle','on');
drawnow;


%% Plot the child variant PDF
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if check_option(varargin,'grains')
    plotPDF(cGrains.meanOrientation,...
        cGrains.variantId,...
        hChild,...
        'equal','antipodal','points','all',...
        'MarkerSize',5,'MarkerEdgeColor','k');
else
    plotPDF(cEBSD.orientations,...
        varIds,...
        hChild,...
        'equal','antipodal','points','all',...
        'MarkerSize',3,'MarkerEdgeColor','k');
end
% Define the maximum number of color levels and plot the colorbar
colormap(jet(maxVariants));
caxis([1 maxVariants]);
colorbar('location','eastOutSide','lineWidth',1.25,'tickLength', 0.01,...
    'YTick', [1:1:maxVariants],...
    'YTickLabel',num2str([1:1:maxVariants]'), 'YLim', [1 maxVariants],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(figH,'Name','PDF: Child grain(s) variant Id(s)','NumberTitle','on');
drawnow;


%% Plot the child packet PDF
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if check_option(varargin,'grains')
    plotPDF(cGrains.meanOrientation,...
        cGrains.packetId,...
        hChild,...
        'equal','antipodal','points','all',...
        'MarkerSize',5,'MarkerEdgeColor','k');
else
    plotPDF(cEBSD.orientations,...
        packIds,...
        hChild,...
        'equal','antipodal','points','all',...
        'MarkerSize',3,'MarkerEdgeColor','k');
end
% Define the maximum number of color levels and plot the colorbar
colormap(viridis);
caxis([1 maxPackets]);
colorbar('location','eastOutSide','lineWidth',1.25,'tickLength', 0.01,...
    'YTick', [1:1:maxPackets],...
    'YTickLabel',num2str([1:1:maxPackets]'), 'YLim', [1 maxPackets],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(figH,'Name','PDF: Child grain(s) packet Id(s)','NumberTitle','on');
drawnow;


%% Plot the child variant IPDF
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
plot(ipfKeyChild)
hold all
if check_option(varargin,'grains')
    plotIPDF(cGrains.meanOrientation,...
        cGrains.variantId,...
        ipfKeyChild.inversePoleFigureDirection,...
        hChild,'MarkerSize',5,'MarkerEdgeColor','k');
else
    plotIPDF(cEBSD.orientations,...
        varIds,...
        ipfKeyChild.inversePoleFigureDirection,...
        hChild,'MarkerSize',3,'MarkerEdgeColor','k');
end
hold off
% Define the maximum number of color levels and plot the colorbar
colormap(jet(maxVariants));
caxis([1 maxVariants]);
colorbar('location','eastOutSide','lineWidth',1.25,'tickLength', 0.01,...
    'YTick', [1:1:maxVariants],...
    'YTickLabel',num2str([1:1:maxVariants]'), 'YLim', [1 maxVariants],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(figH,'Name','IPDF: Child grain(s) variant Id(s)','NumberTitle','on');
drawnow;


%% Plot the child packet IPDF
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
plot(ipfKeyChild)
hold all
if check_option(varargin,'grains')
    plotIPDF(cGrains.meanOrientation,...
        cGrains.packetId,...
        ipfKeyChild.inversePoleFigureDirection,...
        hChild,'MarkerSize',5,'MarkerEdgeColor','k');
else
    plotIPDF(cEBSD.orientations,...
        packIds,...
        ipfKeyChild.inversePoleFigureDirection,...
        hChild,'MarkerSize',3,'MarkerEdgeColor','k');
end
hold off
% Define the maximum number of color levels and plot the colorbar
colormap(viridis);
caxis([1 maxPackets]);
colorbar('location','eastOutSide','lineWidth',1.25,'tickLength', 0.01,...
    'YTick', [1:1:maxPackets],...
    'YTickLabel',num2str([1:1:maxPackets]'), 'YLim', [1 maxPackets],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
set(figH,'Name','IPDF: Child grain(s) variant Id(s)','NumberTitle','on');
drawnow;


%% Plot the weighted area variant Id frequency histogram
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
class_range = 1:1:maxVariants;
if check_option(varargin,'grains')
    [~,abs_counts] = histwc(cGrains.variantId,cGrains.area,maxVariants);
else
    abs_counts = histc(varIds,class_range);
end
norm_counts = abs_counts./sum(abs_counts);
h = bar(class_range,norm_counts,'hist');
h.FaceColor =[162 20 47]./255;
set(gca,'FontSize',14);
set(gca,'xlim',[class_range(1)-0.5 class_range(end)+0.5]);
set(gca,'XTick',class_range);
xlabel('Variant Id','FontSize',14,'FontWeight','bold');
if size(class_range,2)>1; class_range = class_range'; end
if size(abs_counts,2)>1; abs_counts = abs_counts'; end
if size(norm_counts,2)>1; norm_counts = norm_counts'; end
if check_option(varargin,'grains')
    ylabel('Weighted area relative frequency ({\itf_w}(g))','FontSize',14,'FontWeight','bold');
    set(figH,'Name','Histogram: Weighted area variant Ids','NumberTitle','on');
    % % Output histogram data in a table
    screenPrint('Step',['Figure ',num2str(figH.Number),': variantId weighted area histogram']);
    %     table(class_range,abs_counts,'VariableNames',{'variantId','wtAreaCounts'})
    table(class_range,norm_counts,'VariableNames',{'variantId','wtAreaFreq'})
else
    ylabel('Relative frequency ({\itf}(g))','FontSize',14,'FontWeight','bold');
    set(figH,'Name','Histogram: Relative frequency variant Ids','NumberTitle','on');
    % % Output histogram data in a table
    screenPrint('Step',['Figure ',num2str(figH.Number),': variantId histogram']);
    %     table(class_range,abs_counts,'VariableNames',{'variantId','Counts'})
    table(class_range,norm_counts,'VariableNames',{'variantId','Freq'})
end
drawnow;


%% Plot the weighted area packet Id frequency histogram
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
class_range = 1:1:maxPackets;
if check_option(varargin,'grains')
    [~,abs_counts] = histwc(cGrains.packetId,cGrains.area,maxPackets);
else
    abs_counts = histc(packIds,class_range);
end
norm_counts = abs_counts./sum(abs_counts);
h = bar(class_range,norm_counts,'hist');
h.FaceColor =[162 20 47]./255;
set(gca,'FontSize',14);
set(gca,'xlim',[class_range(1)-0.5 class_range(end)+0.5]);
set(gca,'XTick',class_range);
xlabel('Variant Id','FontSize',14,'FontWeight','bold');
if size(class_range,2)>1; class_range = class_range'; end
if size(abs_counts,2)>1; abs_counts = abs_counts'; end
if size(norm_counts,2)>1; norm_counts = norm_counts'; end
if check_option(varargin,'grains')
    ylabel('Weighted area relative frequency ({\itf_w}(g))','FontSize',14,'FontWeight','bold');
    set(figH,'Name','Histogram: Weighted area packet Ids','NumberTitle','on');
    % % Output histogram data in a table
    screenPrint('Step',['Figure ',num2str(figH.Number),': packetId weighted area histogram']);
    %     table(class_range,abs_counts,'VariableNames',{'packetId','wtAreaCounts'})
    table(class_range,norm_counts,'VariableNames',{'packetId','wtAreaFreq'})
else
    ylabel('Relative frequency ({\itf}(g))','FontSize',14,'FontWeight','bold');
    set(figH,'Name','Histogram: Relative frequency packet Ids','NumberTitle','on');
    % % Output histogram data in a table
    screenPrint('Step',['Figure ',num2str(figH.Number),': packetId histogram']);
    %     table(class_range,abs_counts,'VariableNames',{'packetId','Counts'})
    table(class_range,norm_counts,'VariableNames',{'packetId','Freq'})
end
drawnow;


%% Plot martensite block widths
% % THIS SCRIPT WAS CONTRIBUTED BY: Dr Tuomo Nyyssönen
if check_option(varargin,'grains')
    % Get all 111 vector3ds for each grain:
    h = Miller({1,1,1},{1,-1,1},{-1,1,1},{1,1,-1},job.p2c.CS);
    h = h(job.packetId(job.mergeId == pGrainId))';
    z = pGrain.meanOrientation.project2FundamentalRegion.*h;
    
    % figH = gobjects(1);
    % figH = figure('WindowStyle','docked');
    % set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
    % drawnow;
    % [~,mP] = plot(cGrains)
    % hold all
    % quiver(cGrains,cross(z,zvector),'linecolor','r');
    % quiver(cGrains,z,'linecolor','g');
    % hold off
    % if check_option(varargin,'noScalebar'), mP.micronBar.visible = 'off'; end
    % if check_option(varargin,'noFrame')
    %     mP.ax.Box = 'off'; mP.ax.YAxis.Visible = 'off'; mP.ax.XAxis.Visible = 'off';
    % end
    % drawnow;
    
    % % According to <Morito et al., https://doi.org/10.1016/j.msea.2005.12.048>,
    % % block width values between 1 to 2 um are expected.
    % % One method to calculate a representative value for block widths
    % % is to project all boundary points to the vector perpendicular to the
    % % trace of the {111}a plane.
    
    % % Using the function at the bottom of this script, all grain boundary
    % % points of a grain are projected to a vector going through the center of
    % % that grain:
    [p,~,~] = projectPoints2Vector(cGrains,rotate(cross(z,zvector),...
        rotation.byAxisAngle(zvector,90*degree)));
    
    % % A representative value for the average halfwidth could be the mean of
    % % the absolute values:
    new_A = cellfun(@abs,p,'UniformOutput',false);
    new_A = cellfun(@mean,new_A);
    % % Vector form for visual verification:
    new_A_vec = rotate(cross(z,zvector),rotation.byAxisAngle(zvector,90*degree));
    new_A_vec = normalize(new_A_vec).*new_A';
    new_A_vec.antipodal = 1;
    
    % % Calculate the block widths again and plot to visually verify
    % % what the width perpendicular to the {111} trace looks like:
    % % Calculate the assumed block width:
    d_block_new = 2*new_A'.*sin(z.theta);
    
    % % Plot the grains along with their traces and normals
    figH = gobjects(1);
    figH = figure('WindowStyle','docked');
    set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
    drawnow;
    [~,mP] = plot(cGrains,d_block_new);
    hold all
    ha(1) = quiver(cGrains,cross(z,zvector),'linecolor','r');
    ha(2) = quiver(cGrains,z,'linecolor','g');
    ha(3) = quiver(cGrains,new_A_vec,'linecolor','b');
    legend(ha,'111a || 011m trace','111a || 011m normal','Mean of projected points')
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
    
    % % Plot the martensite block width histogram
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
    xlabel('Martensite block width [\mum]','FontSize',14,'FontWeight','bold');
    ylabel('Relative frequency ({\itf}(g))','FontSize',14,'FontWeight','bold');
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
end



%% Place first tabbed figure on top and return
warning on
% allfigh = findall(0,'type','figure');
% if length(allfigh) > 1
%     figure(length(allfigh)-15);
% else
%     figure(1);
% end
figure(2);
warning(bakWarn);
pause(1); % Reduce rendering errors
return
end


%% Compute weighted histogram
function [vinterval,histw] = histwc(val,wt,nbins)
% HISTWC  Weighted histogram count given number of bins
%
% This function generates a vector of cumulative weights for data
% histogram. Equal number of bins will be considered using minimum and
% maximum values of the data. Weights will be summed in the given bin.
%
% Usage: [vinterval,histw] = histwc(val, wt, nbins)
%
% Arguments:
%       val    - values as a vector
%       wt     - weights as a vector
%       nbins  - number of bins
%
% Returns:
%       histw     - weighted histogram
%       vinterval - intervals used
%
%
%
% See also: HISTC, HISTWCV
% Author: mehmet.suzen
% BSD License
% July 2013
minV  = 1; %min(val)
maxV  = nbins; %max(val)
delta = (maxV-minV)/nbins;
vinterval = linspace(minV, maxV, nbins)-delta/2.0;
histw = zeros(nbins, 1);
for ii=1:length(val)
    idx = find(vinterval < val(ii),1,'last');
    if ~isempty(idx)
        histw(idx) = histw(idx) + wt(ii);
    end
end
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