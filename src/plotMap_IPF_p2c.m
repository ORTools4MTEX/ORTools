function ipfKey = plotMap_IPF_p2c(job, varargin)
% plot inverse polefigure maps of parent and child phases
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


% Check what to plot
onlyChild = false; 
onlyParent = false; 
if check_option(varargin,'child')
   onlyChild = true; 
   varargin(find_option(varargin,'child'))=[];
elseif check_option(varargin,'parent')
   onlyParent = true; 
   varargin(find_option(varargin,'parent'))=[];
end

% Parent map
if ~isempty(job.ebsd(job.csParent)) && ~onlyChild
    f = figure;
    ipfKey1 = ipfHSVKey(job.ebsd(job.csParent));
    ipfKey1.inversePoleFigureDirection = vector;
    colors = ipfKey1.orientation2color(job.ebsd(job.csParent).orientations);
    plot(job.ebsd(job.csParent),colors);
    hold all
    plot(job.grains.boundary,varargin{:});
    hold off
    guiTitle = ['Parent IPF <',vector.char,'> map = ',job.csParent.mineral];
    set(f,'Name',guiTitle,'NumberTitle','on');
    drawnow;
elseif isempty(job.ebsd(job.csParent))
    warning('Parent IPFx map empty');
end

% Child map
if ~isempty(job.ebsd(job.csChild)) && ~onlyParent
    f = figure;
    ipfKey2 = ipfHSVKey(job.ebsd(job.csChild));
    ipfKey2.inversePoleFigureDirection = vector;
    colors = ipfKey2.orientation2color(job.ebsd(job.csChild).orientations);
    plot(job.ebsd(job.csChild),colors);
    hold all  
    plot(job.grains.boundary,varargin{:});
    hold off
    guiTitle = ['Child IPF <',vector.char,'> map = ',job.csChild.mineral];
    set(f,'Name',guiTitle,'NumberTitle','on');
    drawnow;
elseif isempty(job.ebsd(job.csChild))
    warning('Child IPFx map empty');
end
ipfKey = [ipfKey1,ipfKey2];
end