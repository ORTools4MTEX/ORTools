function bains = computeBainGrains(job,varargin)
%% Function description:
% This function computes the Bain group IDs of child grains.
%
%% Syntax:
% computeBainGrains(job)
%
%% Input:
% job    - @parentGrainreconstructor
%
%% Output:
% grains - @grains2d 


%% Get the grain boundaries
gB = job.grainsPrior.boundary;

%% Only get child to child boundaries
gB = gB(job.csChild,job.csChild);

%% Get bain group IDs
bainId = job.bainId;

%% Get the bain group IDs of grains located at boundaries
ids = bainId(gB.grainId);

%% Check where they are identical
isBain = ids(:,1) - ids(:,2) == 0;

%% Get the bain boundaries
bainBoundary = gB(isBain);

%% Get bain group IDs
[bains,parentId] = merge(job.grainsPrior,bainBoundary);
% % Somebody help me remove the loop to speed up the function!
%  pId = nan(length(bains),1);
% for ii = 1:length(bains)
%     pId(ii) = median(bainId(bains(ii).id==parentId),"all","omitnan");
% end
pId = arrayfun(@(idx) median(bainId(bains(idx).id == parentId(idx)),'all','omitnan'), 1:length(bains));
pId = reshape(pId, [], 1);