function packets = computePacketGrains(job,varargin)
%% Function description:
% This function computes the crystallographic packet IDs of child 
% grains.
%
%% Syntax:
% computePacketGrains(job)
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

%% Get packet IDs
packetId = job.packetId;

%% Get the packet numbers of the grains at the boundaries
ids = packetId(gB.grainId);

%% Check where they are identical
isPacket = ids(:,1) - ids(:,2) == 0;

%% Get the packet boundaries
packetBoundary = gB(isPacket);

%% Get packet IDs
[packets,parentId] = merge(job.grainsPrior,packetBoundary);
% % Somebody help me remove the loop to speed up the function!
%  pId = nan(length(packets),1);
% for ii = 1:length(packets)
%     pId(ii) = median(packetId(packets(ii).id==parentId),"all","omitnan");
% end
pId = arrayfun(@(idx) median(packetId(packets(idx).id == parentId(idx)),'all','omitnan'), 1:length(packets));
pId = reshape(pId, [], 1);