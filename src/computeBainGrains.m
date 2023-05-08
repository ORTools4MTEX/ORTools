function bains = computeBainGrains(job, varargin)
% Compute the Bain group grains
%
% Syntax
%  computeBainGrains(job)
%
% Input
%  job          - @parentGrainreconstructor
%
% Options

% Get the grain boundaries
gB = job.grainsPrior.boundary;
% Only get child to child boundaries
gB = gB(job.csChild,job.csChild);
% Get packet Ids
bainId = job.bainId;
% Get the packet numbers of the grains at the boundaries
ids = bainId(gB.grainId);
% Check where they are identical
isBain = ids(:,1) - ids(:,2) == 0;
% Get the packet boundaries
bainBoundary = gB(isBain);
% Get bain groups
[bains,parentId] = merge(job.grainsPrior,bainBoundary);
 pId = nan(length(bains),1);

%Somebody help me remove the loop to speed up the function!
for i=1:length(bains)
    pId(i) = median(bainId(bains(i).id==parentId),"all","omitnan");
end
