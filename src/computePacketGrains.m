function packets = computePacketGrains(job, varargin)
% Compute the packet grains
%
% Syntax
%  computePacketGrains(job)
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
packetId = job.packetId;
% Get the packet numbers of the grains at the boundaries
ids = packetId(gB.grainId);
% Check where they are identical
isPacket = ids(:,1) - ids(:,2) == 0;
% Get the packet boundaries
packetBoundary = gB(isPacket);
% Get packets
[packets,parentId] = merge(job.grainsPrior,packetBoundary);
 pId = nan(length(packets),1);

%Somebody help me remove the loop to speed up the function!
for ii=1:length(packets)
    pId(ii) = median(packetId(packets(ii).id==parentId),"all","omitnan");
end
