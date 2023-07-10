function [newGrains,newEBSD] = computeVariantGrains(job,varargin)
%% Function description:
% This function refines the child grains in the "job" object based on 
% their variant IDs while keeping the grains of the remaining phases untouched. 
% The ebsd dataset is returned with updated grainIds associated with the refinde grains

%% Syntax:
%  [newGrains,newEBSD] = computeVariantGrains(job,varargin)
%
%% Input:
%  job  - @parentGrainReconstructor
%
%% Output:
%  newGrains   - @grains2d 
%  newEBSD     - @EBSD
%
%% Options:
%  parentGrainId     - parent grain Id using the argument 'parentGrainId'

%Isolating grain and ebsd data
parentGrainId = get_option(varargin,'parentGrainId',[]);
if parentGrainId
    pGrain = job.parentGrains(job.parentGrains.id == parentGrainId);
    pEBSD = job.ebsd(pGrain);
    pEBSD = pEBSD(job.csParent).gridify;
    cEBSD = job.ebsdPrior(job.ebsdPrior.id2ind(pEBSD.id));
    cEBSD = cEBSD(job.csChild).gridify;
else
%     cEBSD = job.ebsdPrior(job.grainsPrior(job.isTransformed)).gridify;
%     remainingEBSD = job.ebsdPrior(job.grainsPrior(~job.isTransformed)).gridify;

    transfLogic = job.isTransformed;
    cEBSD = job.ebsdPrior(job.grainsPrior(transfLogic)).gridify;    
    transfLogic(transfLogic == 1) = inf;
    transfLogic(transfLogic == 0) = 1;
    transfLogic(transfLogic == inf) = 0;
    remainingEBSD = job.ebsdPrior(job.grainsPrior(transfLogic)).gridify;
end

%Getting auxiliary variables in place
l_ebsd = length(cEBSD);
sz_ebsd = size(cEBSD);
is_cEBSD = ~isnan(cEBSD);
is_cEBSD_L = reshape(is_cEBSD,l_ebsd,1);
isIndexed = job.ebsdPrior.gridify.isIndexed;
isIndexed_L = reshape(isIndexed,l_ebsd,1);
%% Get reconstructed mean parent orientations for each child grain
oriP = orientation.nan(job.csParent,[l_ebsd,1]);
oriP(is_cEBSD) = job.grains(job.mergeId(cEBSD(is_cEBSD).grainId)).meanOrientation;

%% Calculate variant, packet and bain Ids for transformed child EBSD data
%Define properties
props = ["variantId","packetId","bainId"];
%Declare properties
for prop = props
    r.(prop) = nan(l_ebsd,1);
end
%Compute properties
[r.variantId(is_cEBSD),r.packetId(is_cEBSD),r.bainId(is_cEBSD)] = calcVariantId( ...
    oriP(is_cEBSD),cEBSD(~isnan(cEBSD)).orientations,job.p2c,'variantMap', job.variantMap);
%Get the Ids of parent grains 
parentIds = nan(l_ebsd,1);
parentIds(is_cEBSD) = job.grains(job.mergeId(cEBSD(is_cEBSD).grainId)).id;
parentIds = reshape(parentIds,sz_ebsd);

%% Compute new child ebsd and grains based on variant and parent identity
%Assign properties to child EBSD data and all remaining EBSD data
for prop = props
    r.(prop) = reshape(r.(prop),sz_ebsd);
    cEBSD.prop.(prop) = r.(prop);
    remainingEBSD.prop.(prop) = nan(size(remainingEBSD));
end

% Merge EBSD datasets to newEBSD
newEBSD = cEBSD;
newEBSD(isnan(cEBSD)) = remainingEBSD(isnan(cEBSD));

%Define cluster Ids for variant-based grain reconstruction [vId, parentGrainId]
clusterIds_v = r.variantId;
clusterIds_v(isnan(cEBSD)) = 0;
clusterIds_pId = parentIds;
clusterIds_pId(isnan(cEBSD)) = max(max(clusterIds_pId)) + remainingEBSD(isnan(cEBSD)).grainId;
clusterIds_vL = reshape(clusterIds_v,l_ebsd,1);
clusterIds_pIdL = reshape(clusterIds_pId,l_ebsd,1);

% Calculate grains based on grains based on clusterIds
[newGrains, newEBSD(isIndexed).grainId]= newEBSD(isIndexed).calcGrains('variants',[clusterIds_vL(isIndexed_L),clusterIds_pIdL(isIndexed_L)]);

%% Compute the quality of fit 
% Get all child variants
childVariants  = variants(job.p2c,oriP);

if size(childVariants,1) == 1
    childVariants = repmat(childVariants,l_ebsd,1);
end

%% Compute distance to all possible variants
d = dot(childVariants,repmat(cEBSD.orientations(:),1,size(childVariants,2)));

%% Take the best quality-of-fit (QOF)
[fit,~] = max(d,[],2);

%% Save the QOF in ebsd and grain structure
newEBSD.prop.fit = reshape(fit,sz_ebsd);

%% Write prop data into grains
props = [props,'fit'];
isTransformed_grains = ~(newGrains.prop.variantId==0);
isTransforemd_ebsd = ~isnan(newEBSD.prop.variantId);
newGrains.prop.variantId(~isTransformed_grains) = nan;
[~,ind] = unique(newEBSD(isTransforemd_ebsd).prop.grainId);
for prop = props
    p = newEBSD(isTransforemd_ebsd).prop.(prop);
    newGrains(~isnan(newGrains.prop.variantId)).prop.(prop) = p(ind);
end

%% Retransform EBSD data to list-shape
newEBSD = EBSD(newEBSD);