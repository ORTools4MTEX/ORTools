function [groupIds,groupLabels] = computeVariantPairGroups(job,varargin)
%% Function description:
% This function automatically derives the complete list of crystallographic
% variant pair groups for an orientation relationship. Two variant pairs
% belong to the same group when their misorientations are symmetrically
% equivalent. For example, for the Kurdjumov-Sachs OR with 24 variants, all
% nchoosek(24,2) = 276 variant pairs are sorted into 16 groups, each of
% which is labelled by its V1-Vx representative(s).
%
%
%% Syntax:
%  [groupIds,groupLabels] = computeVariantPairGroups(job)
%  [groupIds,groupLabels] = computeVariantPairGroups(p2c,'variantMap',vMap)
%
%% Input:
%  job         - @parentGrainReconstructor, or the parent-to-child
%                @orientation relationship (p2c) directly.
%
%% Output:
%  groupIds    - @cell   = a cell array of groups. Each cell holds an n x 2
%                          array of variant id pairs whose misorientations
%                          are symmetrically equivalent.
%  groupLabels - @cell   = a cell array of labels, one per group, named
%                          after the V1-Vx representative(s) of the group
%                          (for e.g. 'V1-V2', 'V1-V3(V5)').
%
%% Options:
%  threshold   - The angular tolerance used to decide whether two
%                misorientations are equivalent. (default = 0.5*degree)
%  variantMap  - The variant map to apply. Only used when the first input is
%                a p2c @orientation; a @parentGrainReconstructor supplies its
%                own "job.variantMap".


threshold = get_option(varargin,'threshold',0.5*degree);

%% Resolve the orientation relationship and the variant numbering
if isa(job,'parentGrainReconstructor')
    p2c = job.p2c;
    variantMap = job.variantMap;
elseif isa(job,'orientation')
    p2c = job;
    variantMap = get_option(varargin,'variantMap',[]);
else
    error(['computeVariantPairGroups: the first input must be a ',...
        '@parentGrainReconstructor or a parent-to-child @orientation.']);
end

% Compute the child variants of an identity parent orientation. The variant
% map is applied so that the returned ids match the "variantId" property
% assigned by "computeVariantGrains.m" via MTEX's "calcVariantId".
oriP = orientation.id(p2c.CS);
oriV = variants(p2c,oriP);
if isempty(variantMap); variantMap = 1:length(oriV); end
oriV = variants(p2c,oriP,variantMap);
oriV = oriV(:);
nV = length(oriV);
assert(nV >= 2,['computeVariantPairGroups: the orientation relationship ',...
    'defines only %d variant(s); at least 2 are required.'],nV);

%% Compute the misorientation between every ordered pair of variants
% MTEX's mtimes forms the outer product of two @orientation arrays, so this
% returns an nV x nV array whose element (ii,jj) is the misorientation from
% variant ii to variant jj. Note that "*" is not element-wise here - ".*"
% would return an nV x 1 array instead.
mori = inv(oriV) * oriV;

%% Group the V1-Vx reference misorientations
% Several V1-Vx misorientations are symmetrically equivalent to each other
% (for e.g. V1-V3 and V1-V5 for the Kurdjumov-Sachs OR). Merge these first,
% so that each remaining reference defines exactly one group. Because the
% references are visited in ascending order, the groups come out ordered by
% their smallest V1-Vx representative.
refIds = (2:nV).';
refMori = mori(1,refIds).';

classRefIdx = {};
for kk = 1:numel(refIds)
    isAssigned = false;
    for cc = 1:numel(classRefIdx)
        if isEquivalentMori(refMori(kk),refMori(classRefIdx{cc}(1)),threshold)
            classRefIdx{cc}(end+1) = kk;
            isAssigned = true;
            break
        end
    end
    if ~isAssigned
        classRefIdx{end+1} = kk; %#ok<AGROW>
    end
end
nGroups = numel(classRefIdx);

%% Label each group after its V1-Vx representative(s)
groupLabels = cell(1,nGroups);
for cc = 1:nGroups
    reps = refIds(classRefIdx{cc});
    groupLabels{cc} = sprintf('V1-V%d',reps(1));
    if numel(reps) > 1
        extras = arrayfun(@(v) sprintf('V%d',v),reps(2:end),'UniformOutput',false);
        groupLabels{cc} = [groupLabels{cc},'(',strjoin(extras(:).',','),')'];
    end
end

%% Sort all unique variant pairs into the groups
[pairI,pairJ] = find(triu(true(nV),1));
pairs = sortrows([pairI pairJ],[1 2]);
pairMori = mori(sub2ind([nV nV],pairs(:,1),pairs(:,2)));

groupIds = cell(1,nGroups);
groupOfPair = zeros(size(pairs,1),1);
for cc = 1:nGroups
    isMatch = isEquivalentMori(pairMori,refMori(classRefIdx{cc}(1)),threshold);
    isClash = isMatch & groupOfPair > 0;
    if any(isClash)
        error(['computeVariantPairGroups: variant pair V%d-V%d matches more ',...
            'than one group. Reduce the ''threshold'' option (currently %.3f deg).'],...
            pairs(find(isClash,1),1),pairs(find(isClash,1),2),threshold/degree);
    end
    groupOfPair(isMatch) = cc;
    groupIds{cc} = pairs(isMatch,:);
end

isOrphan = groupOfPair == 0;
if any(isOrphan)
    error(['computeVariantPairGroups: %d of %d variant pairs (for e.g. V%d-V%d) ',...
        'could not be assigned to any group. Increase the ''threshold'' option ',...
        '(currently %.3f deg).'],nnz(isOrphan),size(pairs,1),...
        pairs(find(isOrphan,1),1),pairs(find(isOrphan,1),2),threshold/degree);
end
assert(sum(cellfun(@(g) size(g,1),groupIds)) == nchoosek(nV,2),...
    'computeVariantPairGroups: the computed groups do not partition all %d variant pairs.',...
    nchoosek(nV,2));

% Check that every group contains each variant id equally often. The symmetry group
% acts transitively on the variants, so each group necessarily holds a
% multiple of nV/2 pairs. A violation means that the misorientation
% equivalence test did not reduce over both crystal symmetries, in which case
% the groups are wrong even though they still partition all variant pairs.
for cc = 1:nGroups
    idCounts = histcounts(groupIds{cc}(:),0.5:1:(nV+0.5));
    if any(idCounts ~= idCounts(1))
        error(['computeVariantPairGroups: group ''%s'' holds %d pairs but does not ',...
            'contain every variant id equally often. The misorientation equivalence ',...
            'test is inconsistent - check the ''threshold'' option (currently %.3f deg).'],...
            groupLabels{cc},size(groupIds{cc},1),threshold/degree);
    end
end

end


function tf = isEquivalentMori(mori,refMori,threshold)
%% Check whether misorientations are symmetrically equivalent to a reference
% Variant pair boundaries are unordered, so a misorientation is equivalent
% to the reference if it matches either the reference or its inverse.
tf = angle(mori,refMori) < threshold | angle(mori,inv(refMori)) < threshold;
end
