function plotMap_gB_prob(job,varargin)
% calculate and plot the probability distribution between 0 and 1, that a 
% boundary belongs to the orientation relationship
%
% Syntax
%  plotMap_gB_prob(job)
%
% Input
%  job          - @parentGrainreconstructor
%
% Options
%  threshold - the misfit at which the probability is exactly 50 percent ... 
%  tolerance - ... and the standard deviation in a cumulative Gaussian distribution
%  colormap - colormap string
%
%See also:
%https://mtex-toolbox.github.io/parentGrainReconstructor.calcGraph.html 

cmap = get_option(varargin,'colormap','viridis');
threshold = get_option(varargin,'threshold',2.5*degree);
tolerance = get_option(varargin,'tolerance',2.5*degree);

if job.p2c == orientation.id(job.csParent,job.csChild)
    warning('Orientation relationship is (0,0,0). Initialize ''job.p2c''!');
    return
end
%% Compute the p2c and c2c boundary probabilities
% Find all grain pairs
grainPairs = neighbors(job.grains);
% Find p2c grain pairs
grainPairs_p2c = neighbors(job.grains(job.csParent.mineral),job.grains(job.csChild.mineral));
% Find the index of p2c grain pairs in the 'all grain pairs' variable
[idx_p2c,~] = ismember(grainPairs,grainPairs_p2c,'rows');
if isempty(idx_p2c(idx_p2c==1))
    grainPairs_p2c = grainPairs_p2c(:,[2 1]);
    [idx_p2c,~] = ismember(grainPairs,grainPairs_p2c,'rows');
end
% Find c2c grain pairs
grainPairs_c2c = neighbors(job.grains(job.csChild.mineral),job.grains(job.csChild.mineral));
% Find the index of c2c grain pairs in the 'all grain pairs' variable
[idx_c2c,~] = ismember(grainPairs,grainPairs_c2c,'rows');
if isempty(idx_c2c(idx_c2c==1))
    grainPairs_c2c = grainPairs_c2c(:,[2 1]);
    [idx_c2c,~] = ismember(grainPairs,grainPairs_c2c,'rows');
end
% Define all boundaries and calculate their probabilities
job.calcGraph('threshold',threshold,...
    'tolerance',tolerance);
v = full(job.graph(sub2ind(size(job.graph),grainPairs(:,1),grainPairs(:,2))));
[gB,pairId] = job.grains.boundary.selectByGrainId(grainPairs);
% Define p2c boundaries and find their probabilities
[gB_p2c,pairId_p2c] = job.grains.boundary.selectByGrainId(grainPairs(idx_p2c,:));
v_p2c = v(idx_p2c==1);
% Define c2c boundaries and find their probabilities
[gB_c2c,pairId_c2c] = job.grains.boundary.selectByGrainId(grainPairs(idx_c2c,:));
v_c2c = v(idx_c2c==1);
if ~isempty(gB)
    %% Plot the OR boundary probability distribution map
    f = figure;
    plot(job.grains,'grayscale');
    hold on
    % Plot the HABs in black
    plot(job.grains.boundary,'LineColor','k','displayName','GBs',varargin{:});
    hold on
    % Plot the p2c and c2c boundary probabilities
    if ~isempty(gB_p2c)
        plot(gB_p2c,v_p2c(pairId_p2c),varargin{:});
    else
        warning('p2c boundary probability distribution map empty');
    end
    if ~isempty(gB_c2c)
        plot(gB_c2c,v_c2c(pairId_c2c),varargin{:});
    else
        warning('c2c boundary probability distribution map empty');
    end
    hold off
    
    % Define the maximum number of color levels and plot the colorbar
    colormap(cmap);
    caxis([0 1]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [0:0.1:1],...
        'YTickLabel',num2str([0:0.1:1]'), 'YLim', [0 1],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    set(f,'Name','Child-child OR boundary probabilities map','NumberTitle','on');
    drawnow;
else
    message = sprintf('Plotting aborted: No p2c and c2c OR boundary probabilities found');
    uiwait(errordlg(message));
    error('p2c and c2c OR boundary probability distribution map empty');
end
end