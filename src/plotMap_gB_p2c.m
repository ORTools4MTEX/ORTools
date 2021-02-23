function plotMap_gB_p2c(job,varargin)
% plot parent-child boundary misorientation map
%
% Syntax
%
%  plotMap_gB_p2c(job,varargin)
%
% Input
%  job  - @parentGrainreconstructor
%
% Options
%  colormap - colormap string

cmap = get_option(varargin,'colormap','jet');

gB_p2c = job.grains.boundary(job.csParent.mineral,job.csChild.mineral);
if ~isempty(gB_p2c)
    %% Plot the parent-child misorientation distribution map
    fprintf(' -> Plotting the parent-child misorientation distribution map');
    
    f = figure;
    plot(job.grains,'grayscale');
    hold on
    % Plot the HABs in black
    plot(job.grains.boundary,'LineColor','k','displayName','GBs',varargin{:});
    hold on
    % Plot the IPBs in jet scale
    plot(gB_p2c,gB_p2c.misorientation.angle./degree,varargin{:})
    hold off
    
    % Round-off the maximum number of color levels to the nearest 5 degrees
    fR = fundamentalRegion(job.csParent,job.csChild);
    maxColors = ceil((fR.maxAngle/degree)/5)*5;
    colormap(cmap)
    caxis([1 maxColors]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [0:5:maxColors],...
        'YTickLabel',num2str([0:5:maxColors]'), 'YLim', [1 maxColors],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    set(f,'Name','Parent-child boundary misorientation map','NumberTitle','on');
    drawnow;
else
    warning('There are no parent-child grain boundaries in the dataset');
end
end


