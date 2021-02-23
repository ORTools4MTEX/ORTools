function plotMap_gB_prob(job,param)
screenPrint('Step',sprintf('Plotting the p2c and c2c boundary probability distribution map'));

%% Compute the p2c and c2c boundary probabilities
% Find all grain pairs
grainPairs = neighbors(job.grains);

% Find p2c grain pairs
grainPairs_p2c = neighbors(job.grains(job.csParent.mineral),job.grains(job.csChild.mineral));
% Find the index of p2c grain pairs in the "all grain pairs" variable
[idx_p2c,~] = ismember(grainPairs,grainPairs_p2c,'rows');
if isempty(idx_p2c(idx_p2c==1))
    grainPairs_p2c = grainPairs_p2c(:,[2 1]);
    [idx_p2c,~] = ismember(grainPairs,grainPairs_p2c,'rows');
end

% Find c2c grain pairs
grainPairs_c2c = neighbors(job.grains(job.csChild.mineral),job.grains(job.csChild.mineral));
% Find the index of c2c grain pairs in the "all grain pairs" variable
[idx_c2c,~] = ismember(grainPairs,grainPairs_c2c,'rows');
if isempty(idx_c2c(idx_c2c==1))
    grainPairs_c2c = grainPairs_c2c(:,[2 1]);
    [idx_c2c,~] = ismember(grainPairs,grainPairs_c2c,'rows');
end

% Define all boundaries and calculate their probabilities
job.calcGraph('threshold',param.calcGraph.thrsh*degree,...
    'tolerance',param.calcGraph.tol*degree);
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
    job.ebsd = swapColors(job.ebsd,'gray');
    plot(job.grains);
    hold on
    % Plot the HABs in black
    plot(job.grains.boundary,'LineColor','k','LineWidth',1,'displayName','HABs');
    hold on
    % Plot the LABs boundaries in navajowhite
    plot(job.grains.innerBoundary,'LineColor',[255/255 222/255 173/255],'LineWidth',1,'displayName','LABs');
    hold on
    % Plot the p2c and c2c boundary probabilities
    if ~isempty(gB_p2c)
        plot(gB_p2c,v_p2c(pairId_p2c),'linewidth',1.5);
    else
        warning('p2c boundary probability distribution map empty');
    end
    if ~isempty(gB_c2c)
        plot(gB_c2c,v_c2c(pairId_c2c),'linewidth',1.5);
    else
        warning('c2c boundary probability distribution map empty');
    end
    hold off
    
    % Define the maximum number of color levels and plot the colorbar
    colormap(hot);
    caxis([0 1]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'YTick', [0:0.1:1],...
        'YTickLabel',num2str([0:0.1:1]'), 'YLim', [0 1],...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    set(f,'Name','Child-child boundary misorientation map','NumberTitle','on');
    drawnow;
else
    message = sprintf('Plotting aborted: No p2c and c2c boundary probabilities found');
    uiwait(errordlg(message));
    error('p2c and c2c boundary probability distribution map empty');
end
job.ebsd = swapColors(job.ebsd,'RGB');
end