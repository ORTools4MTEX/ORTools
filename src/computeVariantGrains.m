function [variant_grains,cEBSD] = computeVariantGrains(job,varargin)
% Refine the child grains in the job object based on their variant IDs 
% and return the refined grains and the child EBSD date with the new grain
% Ids
%
% Syntax
%
%  [variant_grains,job] = computeVariantGrains(job,varargin)
%
% Input
%  job  - @parentGrainReconstructor
%
% Optional
%  parentGrainId     - parent grain Id using the argument 'parentGrainId'
%
% Output
%  variant_grains   - @grains2d 
%  ebsdC  - @EBSD

parentGrainId = get_option(varargin,'parentGrainId',[]);
if parentGrainId
    pGrain = job.parentGrains(job.parentGrains.id == parentGrainId);
    pEBSD = job.ebsd(pGrain);
    pEBSD = pEBSD(job.csParent);
    cEBSD = job.ebsdPrior(job.ebsdPrior.id2ind(pEBSD.id));
    cEBSD = cEBSD(job.csChild);
else
    cEBSD = job.ebsdPrior(job.grainsPrior(job.isTransformed));
end

%Get reconstructed mean parent orientations for each child grain
oriP = job.grains(job.mergeId(cEBSD.grainId)).meanOrientation;
%% AAG EDIT
%Calculate variant and packet Ids for transformed EBSD data
% [varIds,packIds] = calcVariantId(oriP,cEBSD.orientations,job.p2c,...
%                                  'variantMap', job.variantMap);

%Calculate variant, packet and bain Ids for transformed EBSD data
[varIds,packIds,bainIds] = calcVariantId(oriP,cEBSD.orientations,job.p2c,...
                                 'variantMap', job.variantMap);
%% AAG EDIT

%Concatenate variant Ids and parent grain Ids for transformed EBSD data
varPids = [varIds,job.grains(job.mergeId(cEBSD.grainId)).id];
%Compute new child grains based on variant and parent identity
[variant_grains,cEBSD.grainId] = calcGrains(cEBSD,'variants',varPids);
%Save packet Ids in grain structure as well
variant_grains(cEBSD.grainId).prop.packetId = packIds;
%% AAG EDIT
%Save bain Ids in grain structure as well
variant_grains(cEBSD.grainId).prop.bainId = bainIds;
%% AAG EDIT