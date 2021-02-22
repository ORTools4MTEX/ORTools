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
%  ipfKey       - @ipfKey

vector = getClass(varargin,'vector3d',vector3d.X);

if ~isempty(job.ebsd(job.csParent))
    f = figure;
    ipfKey = ipfHSVKey(job.ebsd(job.csParent));
    ipfKey.inversePoleFigureDirection = vector;
    colors = ipfKey.orientation2color(job.ebsd(job.csParent).orientations);
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
    ipfKey = ipfHSVKey(job.ebsd(job.csChild));
    ipfKey.inversePoleFigureDirection = vector;
    colors = ipfKey.orientation2color(job.ebsd(job.csChild).orientations);
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
end