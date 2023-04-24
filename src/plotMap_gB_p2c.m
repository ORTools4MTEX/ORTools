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

%% Define the text output format as Latex
setInterp2Latex

gB_p2c = job.grains.boundary(job.csParent.mineral,job.csChild.mineral);
if ~isempty(gB_p2c)
    %% Plot the parent-child misorientation distribution map
    fprintf(' -> Plotting the parent-child misorientation distribution map \n');
    
    % Plot the parent-child misorientation distribution map
    f = figure;
    plot(job.grains,'grayscale');
    hold on
    % Plot the GBs in black
    plot(job.grains.boundary,'LineColor',[0 0 0],'displayName','GBs',varargin{:});
    hold on
    % Plot the IPBs in jet scale
    plot(gB_p2c,gB_p2c.misorientation.angle./degree,varargin{:})
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
    set(f,'Name','Parent-child boundary misorientation map','NumberTitle','on');
    drawnow;
else
    message = sprintf('Plotting aborted: No parent-child boundaries found');
    uiwait(errordlg(message));
    error('Parent-child misorientation distribution map empty');
end
end


