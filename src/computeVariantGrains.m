function [newGrains,newEBSD] = computeVariantGrains(job,varargin)
%% Function description:
% This function refines the child grains in the "job" object based on
% their variant IDs while keeping the grains of the remaining phases 
% untouched.
% The ebsd dataset is returned with updated grainIds associated with the 
% refined grains.

%% Syntax:
%  [newGrains,newEBSD] = computeVariantGrains(job,varargin)
%
%% Input:
%  job  - @parentGrainReconstructor
%  pGrainId     - parent grain Id using the argument 'parentGrainId'
%% Output:
%  newGrains   - @grains2d
%  newEBSD     - @EBSD


pGrainId = get_option(varargin,'parentGrainId',[]);
if pGrainId
    isTransf = job.isTransformed & job.mergeId == pGrainId;
else
    isTransf = job.isTransformed;
end

cEBSD = job.ebsdPrior(job.grainsPrior(isTransf));
transfIdx = cEBSD.id2ind(cEBSD.id);
remainingEBSD = job.ebsdPrior(job.ebsdPrior.id2ind(setdiff(job.ebsdPrior.id, cEBSD.id)));

% Assign ancillary variables
length_cEBSD = length(cEBSD);

%% Get reconstructed mean parent orientations for each child grain
oriP = job.grains(job.mergeId(cEBSD.grainId)).meanOrientation;

%% Calculate variant, packet and bain Ids for transformed child EBSD data
% Define properties
props = ["variantId","packetId","bainId","parentId"];

% Declare properties
for prop = props
    r.(prop) = nan(length_cEBSD,1);
end

% Compute properties
[r.variantId,r.packetId,r.bainId] = calcVariantId( ...
    oriP,cEBSD.orientations,job.p2c,'variantMap', job.variantMap);

% Get the Ids of parent grains
r.parentId = job.grains(job.mergeId(cEBSD.grainId)).id;

%% Compute new child ebsd and grains based on variant and parent identity
% Assign properties to child EBSD data and all remaining EBSD data
for prop = props
    cEBSD.prop.(prop) = r.(prop);
    remainingEBSD.prop.(prop) = nan(size(remainingEBSD));
end

% Assign dummy variant and parentIds to non-transformed EBSD data
% to guide variant-based grain reconstruction
remainingEBSD.prop.variantId = remainingEBSD.grainId + max(r.variantId) + 1;
remainingEBSD.prop.parentId= remainingEBSD.grainId + max(cEBSD.prop.parentId) + 1;


% Merge EBSD datasets to newEBSD
newEBSD = [cEBSD; remainingEBSD];

% Calculate grains based on grains based on clusterIds
[newGrains, newEBSD.grainId]= newEBSD.calcGrains('variants',[newEBSD.prop.variantId,newEBSD.prop.parentId]);

% Undo fake variant and parent Ids
newEBSD.prop.variantId(newEBSD.prop.variantId > max(r.variantId)) = nan;
newEBSD.prop.parentId(newEBSD.prop.parentId > max(cEBSD.prop.parentId)) = nan;
newGrains.prop.variantId(newGrains.prop.variantId > max(r.variantId)) = nan;
newGrains.prop.variantId(newGrains.prop.variantId == 0) = nan;

newGrains.prop.parentId(newGrains.prop.parentId > max(cEBSD.prop.parentId)) = nan;

%% Compute the quality-of-fit (QOF)
% Get all child variants
childVariants  = variants(job.p2c,oriP);
if length(oriP) == 1
    childVariants = repmat(childVariants,length_cEBSD,1);
end

%% Compute distance to all possible variants
d = dot(childVariants,repmat(cEBSD.orientations(:),1,size(childVariants,2)));

%% Take the best QOF
[fit,~] = max(d,[],2);
newEBSD.prop.fit = nan(size(newEBSD));
newEBSD(transfIdx).prop.fit = fit;

%% Save properties in grain object
isTransf = ~isnan(newGrains.prop.variantId);
oriP = job.grains(newGrains(isTransf).prop.parentId).meanOrientation;

[~,packetId,bainId] = calcVariantId(oriP,...
    newGrains(isTransf).meanOrientation,job.p2c,'variantMap', job.variantMap);

newGrains.prop.packetId = nan(size(newGrains));
newGrains.prop.bainId = nan(size(newGrains));
newGrains(isTransf).prop.packetId = packetId;
newGrains(isTransf).prop.bainId = bainId;

end
