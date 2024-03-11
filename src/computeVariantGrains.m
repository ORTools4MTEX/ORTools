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
notTransf = ~isTransf;
cEBSD = job.ebsdPrior(job.grainsPrior(isTransf)).gridify('extent',job.ebsdPrior.extent,'prop',job.ebsdPrior.prop);
remainingEBSD = job.ebsdPrior(job.grainsPrior(notTransf)).gridify('extent',job.ebsdPrior.extent,'prop',job.ebsdPrior.prop);

% Defining ancillary variables
length_cEBSD = length(cEBSD);
size_cEBSD = size(cEBSD);
is_cEBSD = ~isnan(cEBSD);
is_length_cEBSD = reshape(is_cEBSD,length_cEBSD,1);
isIndexed = job.ebsdPrior.gridify('extent',cEBSD.extent,'prop',cEBSD.prop).isIndexed;
isIndexed_length_cEBSD = reshape(isIndexed,length_cEBSD,1);


%% Get reconstructed mean parent orientations for each child grain
oriP = orientation.nan(job.csParent,[length_cEBSD,1]);
oriP(is_cEBSD) = job.grains(job.mergeId(cEBSD(is_cEBSD).grainId)).meanOrientation;


%% Calculate variant, packet and bain Ids for transformed child EBSD data
% Define properties
props = ["variantId","packetId","bainId"];

% Declare properties
for prop = props
    r.(prop) = nan(length_cEBSD,1);
end
% Compute properties
[r.variantId(is_cEBSD),r.packetId(is_cEBSD),r.bainId(is_cEBSD)] = calcVariantId( ...
    oriP(is_cEBSD),cEBSD(~isnan(cEBSD)).orientations,job.p2c,'variantMap', job.variantMap);

% Get the Ids of parent grains
parentIds = nan(length_cEBSD,1);
parentIds(is_cEBSD) = job.grains(job.mergeId(cEBSD(is_cEBSD).grainId)).id;
parentIds = reshape(parentIds,size_cEBSD);


%% Compute new child ebsd and grains based on variant and parent identity
%Assign properties to child EBSD data and all remaining EBSD data
for prop = props
    r.(prop) = reshape(r.(prop),size_cEBSD);
    cEBSD.prop.(prop) = r.(prop);
    remainingEBSD.prop.(prop) = nan(size(remainingEBSD));
end

% Merge EBSD datasets to newEBSD
newEBSD = cEBSD;
newEBSD(isnan(cEBSD)) = remainingEBSD(isnan(cEBSD));

% Define cluster Ids for variant-based grain reconstruction [vId, parentGrainId]
clusterIds_v = r.variantId;
clusterIds_v(isnan(cEBSD)) = 0;
clusterIds_pId = parentIds;
clusterIds_pId(isnan(cEBSD)) = max(max(clusterIds_pId)) + remainingEBSD(isnan(cEBSD)).grainId;
clusterIds_vL = reshape(clusterIds_v,length_cEBSD,1);
clusterIds_pIdL = reshape(clusterIds_pId,length_cEBSD,1);

% Calculate grains based on grains based on clusterIds
[newGrains, newEBSD(isIndexed).grainId]= newEBSD(isIndexed).calcGrains('variants',[clusterIds_vL(isIndexed_length_cEBSD),clusterIds_pIdL(isIndexed_length_cEBSD)]);
newIsTransf = newGrains.prop.variantId~=0;
newGrains(~newIsTransf).prop.variantId = nan;


%% Compute the quality of fit
% Get all child variants
childVariants  = variants(job.p2c,oriP);

if size(childVariants,1) == 1
    childVariants = repmat(childVariants,length_cEBSD,1);
end


%% Compute distance to all possible variants
d = dot(childVariants,repmat(cEBSD.orientations(:),1,size(childVariants,2)));


%% Take the best quality-of-fit (QOF)
[fit,~] = max(d,[],2);


%% Save the QOF in ebsd and grain structure
newEBSD.prop.fit = reshape(fit,size_cEBSD);
newGrains(reshape(newEBSD(isIndexed).grainId,[],1)).prop.packetId = newEBSD(isIndexed).prop.packetId;
newGrains(reshape(newEBSD(isIndexed).grainId,[],1)).prop.bainId = newEBSD(isIndexed).prop.bainId;
newGrains(reshape(newEBSD(isIndexed).grainId,[],1)).prop.fit = newEBSD(isIndexed).prop.fit;


%% Re-transform EBSD data to list-shape
newEBSD = EBSD(newEBSD);