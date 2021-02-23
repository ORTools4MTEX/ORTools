function plotMap_gB_c2c(job,varargin)
% plot child-child boundary misorientation map
%
% Syntax
%
%  plotMap_gB_c2c(job,varargin)
%
% Input
%  job  - @parentGrainreconstructor
%
% Options
%  colormap - colormap string

cmap = get_option(varargin,'colormap','jet');

gB_c2c = job.grains.boundary(job.csChild.mineral,job.csChild.mineral);
if ~isempty(gB_c2c)
    %% Plot the parent-child misorientation distribution map
    fprintf(' -> Plotting the child-child misorientation distribution map');
    f = figure;
    plot(job.grains,'grayscale');
    hold on
    % Plot the GBs in black
    plot(job.grains.boundary,'LineColor','k','displayName','GBs',varargin{:});
    hold on
    % Plot the IPBs in jet scale
    plot(gB_c2c,gB_c2c.misorientation.angle./degree,varargin{:})
    hold off
    
    % Round-off the maximum number of color levels to the nearest 5 degrees
    fR = fundamentalRegion(job.csParent,job.csChild);
    maxColors = ceil((fR.maxAngle/degree)/5)*5;
    colormap(cmap);
    caxis([0 maxColors]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [0:5:maxColors],...
        'YTickLabel',num2str([0:5:maxColors]'), 'YLim', [0 maxColors],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    set(f,'Name','Child-child boundary misorientation map','NumberTitle','on');
    drawnow;
else
    message = sprintf('Plotting aborted: No child-child boundaries found');
    uiwait(errordlg(message));
    error('Child-child misorientation distribution map empty');
end
end
