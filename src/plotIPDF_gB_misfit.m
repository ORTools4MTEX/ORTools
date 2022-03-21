function plotIPDF_gB_misfit(job,varargin)
% Plot the misfit, or the disorientation, between the parent-child and
% child-child boundaries with the orientation relationship
%
% Syntax
%  plotIPDF_gB_misfit(job)
%
% Input
%  job  - @parentGrainreconstructor
%
% Options
%  colormap - colormap string
%  maxColor - maximum color on color range [degree]

cmap = get_option(varargin,'colormap','jet');

if job.p2c == orientation.id(job.csParent,job.csChild)
    warning('Orientation relationship is (0,0,0). Initialize ''job.p2c''');
    return
end


%% Compute the p2c and c2c boundary disorientation (misfits)
% Compute all parent-child grain boundaries
gB_p2c = job.grains.boundary(job.csParent.mineral,job.csChild.mineral);
if ~isempty(gB_p2c)
    % Compute the disorientation from the nominal OR
    misfit_p2c = angle(gB_p2c.misorientation,job.p2c);
end
% Compute all child-child grain boundaries
gB_c2c = job.grains.boundary(job.csChild.mineral,job.csChild.mineral);
% Compute the disorientation from the nominal OR
p2c_V = job.p2c.variants;
p2c_V = p2c_V(:);
c2c_variants = job.p2c * inv(p2c_V);
if ~isempty(gB_c2c)
    % Compute the disorientation to c2c variants
    misfit_c2c = angle_outer(gB_c2c.misorientation,c2c_variants);
    % Compute the map variant with the minimum disorientation from the OR variant
    % Note: The second output is unused in this function, is variant number
    [misfit_c2c,~] = min(misfit_c2c,[],2);
end

%% Define the text output format as Latex
setLabels2Latex


%% Define the window settings for a set of docked figures
% % Ref: https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs
warning off
desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
% % Define a unique group name for the dock using the function name
% % and the system timestamp
dockGroupName = ['plotIPDF_gB_misfit_',char(datetime('now','Format','yyyyMMdd_HHmmSS'))];
desktop.setGroupDocked(dockGroupName,0);
bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');



%% Axis plot for parent grains using parent-child boundaries
drawnow;
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if ~isempty(gB_p2c)
    plot(gB_p2c.misorientation.axis,...
        misfit_p2c./degree,...
        job.csParent.properGroup,...
        'all','symmetrised','FundamentalRegion',...
        'LineWidth',0.25,...
        'Marker','o','MarkerSize',3,...
        'MarkerEdgeColor',[0 0 0]);
    if get_option(varargin,'maxColor')
        maxColor = get_option(varargin,'maxColor');
    else
        maxColor = ceil(max(misfit_p2c./degree)/5)*5;
    end
    colormap(cmap);
    caxis([0 maxColor]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    hold all
else
    warning('There are no parent-child grain boundaries in the dataset');
end

plot(job.p2c.axis,...
    job.csParent.properGroup,...
    'all','symmetrised','FundamentalRegion',...
    'LineWidth',1,...
    'Marker','o','MarkerSize',12,...
    'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1]);
hold off
set(figH,'Name',strcat('Rot. axis p2c - Parent grain disori. from OR'),'NumberTitle','on');
drawnow;
%---------------



%% Axis plot for child grains using parent-child boundaries
drawnow;
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if ~isempty(gB_p2c)
    plot(gB_p2c.misorientation.axis,...
        misfit_p2c./degree,...
        job.csChild.properGroup,...
        'all','symmetrised','FundamentalRegion',...
        'LineWidth',0.25,...
        'Marker','o','MarkerSize',3,...
        'MarkerEdgeColor',[0 0 0]);
    if get_option(varargin,'maxColor')
        maxColor = get_option(varargin,'maxColor');
    else
        maxColor = ceil(max(misfit_p2c./degree)/5)*5;
    end
    colormap(cmap);
    caxis([0 maxColor]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    hold all
else
    warning('There are no parent-child grain boundaries in the dataset');
end

plot(job.p2c.axis,...
    job.csChild.properGroup,...
    'all','symmetrised','FundamentalRegion',...
    'LineWidth',1,...
    'Marker','o','MarkerSize',12,...
    'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1]);
hold off
set(figH,'Name',strcat('Rot. axis p2c - Child grain disori. from OR'),'NumberTitle','on');
drawnow;
%---------------


%% Axis plot for child grains using child-child boundaries
drawnow;
figH = gobjects(1);
figH = figure('WindowStyle','docked');
set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
drawnow;
if ~isempty(gB_c2c)
    plot(gB_c2c.misorientation.axis,...
        misfit_c2c./degree,...
        job.csChild.properGroup,...
        'all', 'symmetrised', 'FundamentalRegion',...
        'LineWidth',0.25,...
        'Marker','o','MarkerSize',3,...
        'MarkerEdgeColor',[0 0 0]);
    if get_option(varargin,'maxColor')
        maxColor = get_option(varargin,'maxColor');
    else
        maxColor = ceil(max(misfit_c2c./degree)/5)*5;
    end
    colormap(cmap);
    caxis([0 maxColor]);
    colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
        'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
    hold all
else
    warning('There are no child-child grain boundaries in the dataset');
end

plot(c2c_variants.axis,...
    job.csParent.properGroup,...
    'all', 'symmetrised', 'FundamentalRegion',...
    'LineWidth',1,...
    'Marker','o','MarkerSize',12,...
    'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1]);
hold off
set(figH,'Name',strcat('Rot. axis c2c - Child grain disori. from OR variants'),'NumberTitle','on');
drawnow;
%---------------



%% Place first tabbed figure on top and return
warning on
allfigh = findall(0,'type','figure');
if length(allfigh) > 1 &&...
        ~isempty(gB_p2c) &&...
        ~isempty(gB_c2c)
    figure(length(allfigh)-2);
elseif length(allfigh) > 1 &&...
        isempty(gB_p2c) &&...
        ~isempty(gB_c2c)
    figure(length(allfigh));
else
    figure(1);
end
warning(bakWarn);
pause(1); % Reduce rendering errors
return
end