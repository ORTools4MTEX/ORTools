function [variant_grains,ebsdC] = computeVariantGrains(job,varargin)
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
% Output
%  variant_grains   - @grains2d 
%  ebsdC  - @EBSD

ebsdC = job.ebsdPrior(job.grainsPrior(job.isTransformed));
%Get reconstructed mean parent orientations for each child grain
oriP = job.grains(job.mergeId(ebsdC.grainId)).meanOrientation;
%Calculate variant and packet Ids for transformed EBSD data
[varIds,packIds] = calcVariantId(oriP,ebsdC.orientations,job.p2c,...
                                 'variantMap', job.variantMap);
%Concatenate variant Ids and parent grain Ids for transformed EBSD data
varPids = [varIds,job.grains(job.mergeId(ebsdC.grainId)).id];
%Compute new child grains based on variant and parent identity
[variant_grains,ebsdC.grainId] = calcGrains(ebsdC,'variants',varPids);
%Save packet Ids in grain structure as well
variant_grains(ebsdC.grainId).prop.packetId = packIds;