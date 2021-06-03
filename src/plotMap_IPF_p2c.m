function ipfKey = plotMap_IPF_p2c(job, varargin)
% plot inverse pole figure maps of parent and child phases
%
% Syntax
%  plotMap_IPF_p2c(job)
%  plotMap_IPF_p2c(job,direction)
%
% Input
%  job          - @parentGrainreconstructor
%  direction    - @vector3d
%
% Option
%  parent       - plot only map of parent phase
%  child        - plot only map of child phase
%
% Output
%  ipfKey       - @ipfHSVKey

vector = getClass(varargin,'vector3d',vector3d.X);
ipfKey1 = [];
ipfKey2 = [];


%% Check what to plot
onlyChild = false;
onlyParent = false;
if check_option(varargin,'child')
    onlyChild = true;
    varargin(find_option(varargin,'child'))=[];
elseif check_option(varargin,'parent')
    onlyParent = true;
    varargin(find_option(varargin,'parent'))=[];
end

%% Define the window settings for a set of docked figures
% % Ref: https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs
warning off
desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
% % Define a unique group name for the dock using the function name
% % and the system timestamp
dockGroupName = ['plotPODF_transform_',char(datetime('now','Format','yyyyMMdd_HHmmSS'))];
desktop.setGroupDocked(dockGroupName,0);
bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');



%% Parent map
if ~isempty(job.ebsd(job.csParent)) && ~onlyChild
    figH = gobjects(1);
    figH = figure('WindowStyle','docked');
    set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
    drawnow;
    ipfKey1 = ipfHSVKey(job.ebsd(job.csParent));
    ipfKey1.inversePoleFigureDirection = vector;
    colors = ipfKey1.orientation2color(job.ebsd(job.csParent).orientations);
    plot(job.ebsd(job.csParent),colors);
    hold all
    plot(job.grains.boundary,varargin{:});
    hold off
    guiTitle = ['Parent IPF <',vector.char,'> map = ',job.csParent.mineral];
    set(figH,'Name',guiTitle,'NumberTitle','on');
    drawnow;
elseif isempty(job.ebsd(job.csParent))
    warning('Parent IPFx map empty');
end

% Child map
if ~isempty(job.ebsd(job.csChild)) && ~onlyParent
    figH = gobjects(1);
    figH = figure('WindowStyle','docked');
    set(get(handle(figH),'javaframe'),'GroupName',dockGroupName);
    drawnow;
    ipfKey2 = ipfHSVKey(job.ebsd(job.csChild));
    ipfKey2.inversePoleFigureDirection = vector;
    colors = ipfKey2.orientation2color(job.ebsd(job.csChild).orientations);
    plot(job.ebsd(job.csChild),colors);
    hold all
    plot(job.grains.boundary,varargin{:});
    hold off
    guiTitle = ['Child IPF <',vector.char,'> map = ',job.csChild.mineral];
    set(figH,'Name',guiTitle,'NumberTitle','on');
    drawnow;
elseif isempty(job.ebsd(job.csChild))
    warning('Child IPFx map empty');
end
ipfKey = [ipfKey1,ipfKey2];

%% Place first tabbed figure on top and return
warning on
allfigh = findall(0,'type','figure');

if length(allfigh) > 1 &&...
        ~isempty(job.ebsd(job.csParent)) && ~onlyChild &&...
        ~isempty(job.ebsd(job.csChild)) && ~onlyParent
    figure(length(allfigh)-1);
else
    figure(1);
end
warning(bakWarn);
pause(1); % Reduce rendering errors
return

end