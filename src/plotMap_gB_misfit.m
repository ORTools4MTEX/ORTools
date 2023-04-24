function plotMap_gB_misfit(job,varargin)
% plot the misfit, or the disorientation, between the parent-child and
% child-child boundaries with the orientation relationship
%
% Syntax
%  plotMap_gB_misfit(job)
%
% Input
%  job          - @parentGrainreconstructor
%
% Options
%  colormap - colormap string
%  maxColor - maximum color on color range [degree]

cmap = get_option(varargin,'colormap','jet');
maxColor = get_option(varargin,'maxColor',[]);

if job.p2c == orientation.id(job.csParent,job.csChild)
    warning('Orientation relationship is (0,0,0). Initialize ''job.p2c''!');
    return
end

%% Define the text output format as Latex
setInterp2Latex

%% Compute the p2c and c2c boundary disorientation (misfits)
gB = job.grains.boundary;
% Compute all parent-child grain boundaries
gB_p2c = job.grains.boundary(job.csParent.mineral,job.csChild.mineral);

if ~isempty(job.grains(job.csParent))
    % Compute the disorientation from the nominal OR
    misfit_p2c = angle(gB_p2c.misorientation,job.p2c);
else
    misfit_p2c = 0;
end
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
    %% Plot the OR boundary disorientation (or misfit) distribution map
    f = figure;
    plot(job.grains, 'grayscale');
    hold on
    % Plot the GBs in black
    plot(job.grains.boundary,'LineColor','k','displayName','GBs',varargin{:});
    hold on
    % Plot the p2c and c2c boundary disorientation (or misfit)
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
    if isempty(maxColor)
        maxColor = ceil(max(max(misfit_p2c),max(misfit_c2c))./degree/5)*5;
    end
    colormap(cmap);
    caxis([0 maxColor]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    set(f,'Name','p2c and c2c boundary disorientation map','NumberTitle','on');
    drawnow;
else
    message = sprintf('Plotting aborted: No p2c and c2c boundary disorientations found');
    uiwait(errordlg(message));
    error('p2c and c2c boundary disorientation distribution map empty');
end

end 