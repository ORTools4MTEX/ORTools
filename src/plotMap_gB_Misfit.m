function plotMap_gB_Misfit(job,varargin)
% plot the misfit, or the disorientation, between the parent-child and
% child-child boundaries with the orientation relationship
%
% Syntax
%  plotMap_gB_Misfit(job)
%
% Input
%  job          - @parentGrainreconstructor

%% Compute the p2c and c2c boundary disorientation (misfits)
gB = job.grains.boundary;
% Compute all parent-child grain boundaries
gB_p2c = job.grains.boundary(job.csParent.mineral,job.csChild.mineral);

if ~isempty(gB_p2c)
    % Compute the disorientation from the nominal OR
    misfit_p2c = angle(gB_p2c.misorientation,job.p2c);

    % Compute all child-child grain boundaries
    gB_c2c = job.grains.boundary(job.csChild.mineral,job.csChild.mineral);
    % Compute the disorientation from the nominal OR
    p2c_V = job.p2c.variants;
    p2c_V = p2c_V(:);
    c2c_variants = job.p2c * inv(p2c_V);
    % Compute the disorientation to c2c variants
    misfit_c2c = angle_outer(gB_c2c.misorientation,c2c_variants);
    % Compute the map variant with the minimum disorientation from the OR variant
    % Note: The second output is unused in this function but is variant number
    [misfit_c2c,~] = min(misfit_c2c,[],2);


    if ~isempty(gB)
        %% Plot the OR boundary probability distribution map
        f = figure;
        job.ebsd = swapColors(job.ebsd,'gray');
        plot(job.grains);
        hold on
        % Plot the HABs in black
        plot(job.grains.boundary,'LineColor','k','displayName','HABs',varargin{:});
        hold on
        % Plot the LABs boundaries in navajowhite
        plot(job.grains.innerBoundary,'LineColor',[255/255 222/255 173/255],'displayName','LABs',varargin{:});
        hold on
        % Plot the p2c and c2c boundary probabilities
        if ~isempty(gB_p2c)
            plot(gB_p2c,misfit_p2c./degree,varargin{:});
        else
            warning('p2c boundary disorientation distribution map empty');
        end
        if ~isempty(gB_c2c)
            plot(gB_c2c,misfit_c2c./degree,varargin{:});
        else
            warning('c2c boundary disorientation distribution map empty');
        end
        hold off

        % Define the maximum number of color levels and plot the colorbar
        maxColors = ceil(max(max(misfit_p2c),max(misfit_c2c))./degree/5)*5;
        colormap(jet(maxColors));
        caxis([0 maxColors]);
        colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
            'YTick', [0:5:maxColors],...
            'YTickLabel',num2str([0:5:maxColors]'), 'YLim', [0 maxColors],...
            'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
        set(f,'Name','p2c and c2c boundary disorientation map','NumberTitle','on');
        drawnow;
    else
        message = sprintf('Plotting aborted: No p2c and c2c boundary disorientations found');
        uiwait(errordlg(message));
        error('p2c and c2c boundary disorientation distribution map empty');
    end
else
    warning('There are no parent-child grain boundaries in the dataset');
end
job.ebsd = swapColors(job.ebsd,'RGB');
end