function bains = computeBainGrains(job,varargin)
% Compute the Bain groups of grains.
%
% Syntax
% computeBainGrains(job)
%
% Input
% job          - @parentGrainreconstructor
%
% Output
% grains       - @grains2d 

% Get the grain boundaries
gB = job.grainsPrior.boundary;
% Only get child to child boundaries
gB = gB(job.csChild,job.csChild);
% Get bain groups
bainId = job.bainId;
% Get the bain groups of the grains at the boundaries
ids = bainId(gB.grainId);
% Check where they are identical
isBain = ids(:,1) - ids(:,2) == 0;
% Get the bain boundaries
bainBoundary = gB(isBain);
% Get bain groups
[bains,parentId] = merge(job.grainsPrior,bainBoundary);
%  pId = nan(length(bains),1);
% 
% % Somebody help me remove the loop to speed up the function!
% for ii = 1:length(bains)
%     pId(ii) = median(bainId(bains(ii).id==parentId),"all","omitnan");
% end

pId = arrayfun(@(idx) median(bainId(bains(idx).id == parentId(idx)),'all','omitnan'), 1:length(bains));
pId = reshape(pId, [], 1);