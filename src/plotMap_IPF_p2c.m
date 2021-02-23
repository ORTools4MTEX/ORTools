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
% Output
%  ipfKey       - @ipfHSVKey

vector = getClass(varargin,'vector3d',vector3d.X);
ipfKey1 = [];
ipfKey2 = [];

if ~isempty(job.ebsd(job.csParent))
    f = figure;
    ipfKey1 = ipfHSVKey(job.ebsd(job.csParent));
    ipfKey1.inversePoleFigureDirection = vector;
    colors = ipfKey1.orientation2color(job.ebsd(job.csParent).orientations);
    plot(job.ebsd(job.csParent),colors);
    hold all
    plot(job.grains.boundary,varargin{:});
    hold off
    guiTitle = ['Parent IPFx map = ',job.csParent.mineral];
    set(f,'Name',guiTitle,'NumberTitle','on');
    drawnow;
else
    warning('Parent IPFx map empty');
end


if ~isempty(job.ebsd(job.csChild))
    f = figure;
    ipfKey2 = ipfHSVKey(job.ebsd(job.csChild));
    ipfKey2.inversePoleFigureDirection = vector;
    colors = ipfKey2.orientation2color(job.ebsd(job.csChild).orientations);
    plot(job.ebsd(job.csChild),colors);
    hold all  
    plot(job.grains.boundary,varargin{:});
    hold off
    guiTitle = ['Child IPFx map = ',job.csChild.mineral];
    set(f,'Name',guiTitle,'NumberTitle','on');
    drawnow;
else
    warning('Child IPFx map empty');
end
ipfKey = [ipfKey1, ipfKey2];
end