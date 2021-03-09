function plotStack(job,parentEBSD,pGrainId)
% plot maps of a prior parent grain
%
% Syntax
%  plotStack(job,parentEBSD,pGrainId)
%
% Input
%  job          - @parentGrainreconstructor
%  parentEBSD   - reconstructed @EBSD data
%  pGrainId     - parent grain Id

    %% Define the parent grain
    % pGrainId = 2214
    pGrain = job.parentGrains(job.parentGrains.id == pGrainId);
    oriP = parentEBSD(pGrain);
    oriP = oriP(job.csParent);
    % Define the parent grain IPF notation
    ipfKeyParent = ipfHSVKey(job.csParent);
    ipfKeyParent.inversePoleFigureDirection = vector3d.X;
    cbsParent = ipfKeyParent.orientation2color(pGrain.meanOrientation);
    % Define the parent PDF
    hParent = Miller(0,0,1,job.csParent,'hkl');


    %% Define the child grain(s)
    clusterGrains = job.grainsMeasured(job.mergeId == pGrainId);
    cGrains = clusterGrains(job.csChild);
    % Define the child grain(s) IPF notation
    ipfKeyChild = ipfHSVKey(job.csChild);
    ipfKeyChild.inversePoleFigureDirection = vector3d.X;
    cbsChild = ipfKeyChild.orientation2color(cGrains.meanOrientation);
    % Define the child PDF
    hChild = Miller(0,0,1,job.csChild,'hkl');


    %% Define the maximum number of variants and packets for the p2c OR
    maxVariants = length(job.p2c.variants);
    maxPackets = max(job.packetId);

    %% Plot the parent phase map
    f = figure;
    plot(pGrain);
    hold all
    plot(pGrain.boundary,...
        'lineWidth',1,'lineColor',[0 0 0]);
    hold off
    set(f,'Name','Map: Parent phase + GBs','NumberTitle','on');



    %% Plot the child phase map
    f = figure;
    plot(cGrains);
    hold all
    plot(pGrain.boundary,...
    'lineWidth',1,'lineColor',[0.5 0.5 0.5]);
    plot(cGrains.boundary,...
        'lineWidth',1,'lineColor',[0 0 0]);

    hold off
    set(f,'Name','Map: Child phase + GBs','NumberTitle','on');



    %% Plot the parent IPF map
    f = figure;
    plot(pGrain,cbsParent);
    hold all
    plot(pGrain.boundary,...
        'lineWidth',1,'lineColor',[0 0 0]);
    hold off
    set(f,'Name','Map: Parent grain IPF_x + GBs','NumberTitle','on');



    %% Plot the child IPF map
    f = figure;
    plot(cGrains,cbsChild);
    hold all
    plot(pGrain.boundary,...
    'lineWidth',1,'lineColor',[0.5 0.5 0.5]);
    plot(cGrains.boundary,...
        'lineWidth',1,'lineColor',[0 0 0]);
    hold off
    set(f,'Name','Map: Child grain IPF_x + GBs','NumberTitle','on');



    %% Plot the child variant map
    f = figure;
    plot(cGrains(~isnan(cGrains.variantId)),cGrains.variantId(~isnan(cGrains.variantId)));
    hold all
    plot(pGrain.boundary,...
    'lineWidth',1,'lineColor',[0.5 0.5 0.5]);
    plot(cGrains.boundary,...
        'lineWidth',1,'lineColor',[0 0 0]);
    hold off
    % Define the maximum number of color levels and plot the colorbar
    colormap(jet(maxVariants));
    caxis([1 maxVariants]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [1:1:maxVariants],...
        'YTickLabel',num2str([1:1:maxVariants]'), 'YLim', [1 maxVariants],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    set(f,'Name','Map: Child grain(s) variant Id(s) + GBs','NumberTitle','on');



    %% Plot the child packet map
    f = figure;
    plot(cGrains(~isnan(cGrains.packetId)),cGrains.packetId(~isnan(cGrains.packetId)));
    hold all
    plot(pGrain.boundary,...
    'lineWidth',1,'lineColor',[0.5 0.5 0.5]);
    plot(cGrains.boundary,...
        'lineWidth',1,'lineColor',[0 0 0]);
    hold off
    % Define the maximum number of color levels and plot the colorbar
    colormap(parula(maxPackets));
    caxis([1 maxPackets]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [1:1:maxPackets],...
        'YTickLabel',num2str([1:1:maxPackets]'), 'YLim', [1 maxPackets],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    set(f,'Name','Map: Child grain(s) packet Id(s) + GBs','NumberTitle','on');


    %% Plot the parent orientation PDF
    f = figure;
    plotPDF(oriP.orientations,...
        hParent,...
        'equal','antipodal','points','all',...
        'MarkerSize',4,'MarkerEdgeColor',job.csParent.color,...
        'MarkerFaceColor', 'none', 'LineWidth',1);
    hold all
    % plot(pGrain.meanOrientation.symmetrise*hParent,...
    plotPDF(pGrain.meanOrientation,...
        hParent,...
        'equal','antipodal',...
        'MarkerSize',10,'MarkerFaceColor',[1 1 1],...
        'LineWidth',1,'MarkerEdgeColor',[0 0 0]);
    hold off
    set(f,'Name','PDF: Parent grain orientation','NumberTitle','on');


    %% Plot the ideal child variant PDF
    f = figure;
    plotPDF_variants(job,pGrain.meanOrientation,hChild);
    set(f,'Name','PDF: Child grain(s) IDEAL variant Id(s)','NumberTitle','on');



    %% Plot the child variant PDF
    f = figure;
    plotPDF(cGrains.meanOrientation,...
        cGrains.variantId,...
        hChild,...
        'equal','antipodal','points','all',...
        'MarkerSize',5,'MarkerEdgeColor','k');
    % Define the maximum number of color levels and plot the colorbar
    colormap(jet(maxVariants));
    caxis([1 maxVariants]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [1:1:maxVariants],...
        'YTickLabel',num2str([1:1:maxVariants]'), 'YLim', [1 maxVariants],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    set(f,'Name','PDF: Child grain(s) variant Id(s)','NumberTitle','on');


    %% Plot the child packet PDF
    f = figure;
    plotPDF(cGrains.meanOrientation,...
        cGrains.packetId,...
        hChild,...
        'equal','antipodal','points','all',...
        'MarkerSize',5,'MarkerEdgeColor','k');
    % Define the maximum number of color levels and plot the colorbar
    colormap(parula(maxPackets));
    caxis([1 maxPackets]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [1:1:maxPackets],...
        'YTickLabel',num2str([1:1:maxPackets]'), 'YLim', [1 maxPackets],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    set(f,'Name','PDF: Child grain(s) packet Id(s)','NumberTitle','on');

    %% Plot the child variant IPDF
    f = figure;
    plot(ipfKeyChild)
    hold all
    plotIPDF(cGrains.meanOrientation,...
        cGrains.variantId,...
        ipfKeyChild.inversePoleFigureDirection,...
        hChild,'MarkerSize',5,'MarkerEdgeColor','k');
    hold off
    % Define the maximum number of color levels and plot the colorbar
    colormap(jet(maxVariants));
    caxis([1 maxVariants]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [1:1:maxVariants],...
        'YTickLabel',num2str([1:1:maxVariants]'), 'YLim', [1 maxVariants],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    set(f,'Name','IPDF: Child grain(s) variant Id(s)','NumberTitle','on');



    %% Plot the child packet IPDF
    f = figure;
    plot(ipfKeyChild)
    hold all
    plotIPDF(cGrains.meanOrientation,...
        cGrains.packetId,...
        ipfKeyChild.inversePoleFigureDirection,...
        hChild,'MarkerSize',5,'MarkerEdgeColor','k');
    hold off
    % Define the maximum number of color levels and plot the colorbar
    colormap(parula(maxPackets));
    caxis([1 maxPackets]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [1:1:maxPackets],...
        'YTickLabel',num2str([1:1:maxPackets]'), 'YLim', [1 maxPackets],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    set(f,'Name','IPDF: Child grain(s) variant Id(s)','NumberTitle','on');



    %% Plot the weighted area variant Id frequency histogram
    class_range = 1:1:maxVariants;
    [~,abs_counts] = histwc(cGrains.variantId,cGrains.area,maxVariants);
    norm_counts = abs_counts./sum(abs_counts);
    f = figure;
    h = bar(class_range,norm_counts,'hist');
    h.FaceColor ='#A2142F';
    set(gca, 'xlim',[class_range(1)-0.5 class_range(end)+0.5]);
    set(gca,'XTick',class_range);
    set(gca,'FontSize',8);
    xlabel('Variant Id','FontSize',14,'FontWeight','bold');
    ylabel('Area normalised frequency','FontSize',14,'FontWeight','bold');
    set(f,'Name','Histogram: Weighted area variant Ids','NumberTitle','on');



    %% Plot the weighted area packet Id frequency histogram
    class_range = 1:1:maxPackets;
    [~,abs_counts] = histwc(cGrains.packetId,cGrains.area,maxPackets);
    norm_counts = abs_counts./sum(abs_counts);
    f = figure;
    h = bar(class_range, norm_counts, 'hist');
    h.FaceColor ='#A2142F';
    set(gca, 'xlim',[class_range(1)-0.5 class_range(end)+0.5]);
    set(gca,'XTick',class_range);
    set(gca,'FontSize',8);
    xlabel('Packet Id','FontSize',14,'FontWeight','bold');
    ylabel('Area normalised frequency','FontSize',14,'FontWeight','bold');
    set(f,'Name','Histogram: Weighted area packet Ids','NumberTitle','on');
    
    try; tileFigs; end
    return
    end







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
    % Author:
    % mehmet.suzen physics org
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
