function ipfKey = plotMap_clusters(job, varargin)
%% Function description:
% This function plots an ebsd map of child grain clusters that are likely 
% to belong to the same parent grain when clusterGraph.m is called.
% It is displayed as an overlay on top of a semi-transparent IPF map of 
% child grains.
%
%% Syntax:
%  ipfKey = plotMap_clusters(job)
%  ipfKey = plotMap_clusters(job,direction)
%
%% Input:
%  job          - @parentGrainreconstructor
%  direction    - @vector3d


% Check direction
vector = getClass(varargin,'vector3d',vector3d.X);

%Merge grains according to cluster
[grainsMerged,~] = merge(job.grains,job.graph);
if grainsMerged.length == job.grains.length
    warning('Run method ''clusterGraph'' first to obtain clusters')
end

%% Define the text output format as Latex
setInterp2Latex

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


