function ipfKey = plotMap_clusters(job, varargin)
% plot clusters from 'clusterGraph' on top of semi-transparent child
% IPF map
%
% Syntax
%  ipfKey = plotMap_clusters(job)
%  ipfKey = plotMap_clusters(job,direction)
%
% Input
%  job          - @parentGrainreconstructor
%  direction    - @vector3d
%

% Check direction
vector = getClass(varargin,'vector3d',vector3d.X);

%Merge grains according to cluster
[grainsMerged,~] = merge(job.grains,job.graph);
if grainsMerged.length == job.grains.length
    warning('Run method ''clusterGraph'' first to obtain clusters')
end

f = figure;
ipfKey = ipfHSVKey(job.ebsd(job.csChild));
ipfKey.inversePoleFigureDirection = vector;
colors = ipfKey.orientation2color(job.ebsd(job.csChild).orientations);
plot(job.ebsd(job.csChild),colors,'faceAlpha',0.5)
hold all
plot(grainsMerged.boundary,varargin{:});
hold off
guiTitle = ['Cluster + Child IPF ',vector.char ,' map = ',job.csChild.mineral];
set(f,'Name',guiTitle,'NumberTitle','on');
drawnow;
end


