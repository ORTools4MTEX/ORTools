function out = computeGrainPairs(pairGrains,varargin)
%% Function description:
% This function computes the absolute or normalised frequency and boundary
% segment lengths of grain pairs. The grain pair ids can be defined for 
% variants, packets, bain groups, or any other equivalent type as chosen 
% by the user.
%
%% Syntax:
% [out] = computeGrainPairs(pairGrains)
%
%% Input:
%  pairGrains   - @grain2d = child grain pairs as computed by the
%                            "computeVariantGrains.m" function
%
%% Output:
%  out          - @struc   = a strcture variable containing the absolute 
%                            or normalised frequency and boundary segment 
%                            lengths of grain pairs. 
%
%% Options:
%  variant    - Uses the variant Ids of the child grains.
%  packet     - Uses the packet Ids of the child grains.
%  bain       - Uses the Bain Ids of the child grains.
%  other      - Uses a user-specified list of Ids of the child grains.
%  equivalent - A cell defining different groups of equivalent ids.
%  include    - Includes similar neighbouring variant, packet, bain or 
%               other id pairs. For e.g. - V1-V1, CP2-CP2, B3-B3 etc. 
%  exclude    - Excludes similar neighbouring variant, packet, bain or 
%               other-id type pairs. (default)
%  absolute   - Returns the absolute frequency and boundary segment values
%               of neighbouring variant, packet, bain or other-id type 
%               pairs.
%  normalise  - Returns the normalised frequency and boundary segment 
%               values of neighbouring variant, packet, bain or other-id 
%               type pairs. (default)


pairType = lower(get_flag(varargin,{'variant','packet','bain','other'},'variant'));
eqIds = get_option(varargin,'equivalent',{});
calcType = lower(get_flag(varargin,{'exclude','include'},'exclude'));
outputType = lower(get_flag(varargin,{'normalise','absolute'},'normalise'));


%% Determine the pairs
% Get the boundary segments and neighbouring variants
pairGBs = pairGrains.boundary(pairGrains.CS,pairGrains.CS);
pairGrainIds = pairGBs.grainId;

[l1,~] = ismember(pairGrainIds,pairGrains.id);
pairGBs(any(~l1,2)) = [];
pairGrainIds(any(~l1,2),:) = [];

switch pairType
    case {'variant'}
        pairIds = pairGrains(pairGrains.id2ind(pairGrainIds)).variantId;
    case {'packet'}
        pairIds = pairGrains(pairGrains.id2ind(pairGrainIds)).packetId;
    case {'bain'}
        pairIds = pairGrains(pairGrains.id2ind(pairGrainIds)).bainId;
    case {'other'}
        if isempty(eqIds)
            error('Define equivalent id groups in a cell array.');
            return;
        end
        pairIds = pairGrains(pairGrains.id2ind(pairGrainIds)).otherId;
%     otherwise
%         fieldNames = fieldnames(pairGrains.prop);
%         idx = find(~contains(fieldNames,{'meanRotation','GOS','variantId','parentId','packetId','bainId','fit'}))
%         idx = find(contains(fieldNames,{'other'}))
%         pairIds = pairGrains(pairGrains.id2ind(pairGrainIds)).prop.(fieldNames{idx});
end
[pairIds,idx] =  sortrows(pairIds,[1 2]);
pairGBs = pairGBs(idx);
maxId = max(max(pairIds));



% %---------------------------------
%% Define a matrix whose rows & columns signify variant pair combinations
% For example, row 1, column 2 = variant pair V1-V2
% pairMatrix = ones(24,24); ones(6,6); % since a total of 24 variants variants are possible
pairMatrix = ones(maxId,maxId);
% Re-define unique (value = 1) and equivalent (value = 0) pair combinations
% as follows:
% (eg.- V1-V2 (unique pair) == V2-V1 (equivalent pair))
pairMatrix =  logical(triu(pairMatrix));



% %---------------------------------
%% Calculate the counts & boundary segment lengths of all unique pair
% combinations
% Find the linear indices with value 1
ind1 = find(pairMatrix);
% Find the subscripts of the linear indices
[r1,c1] = ind2sub(size(pairMatrix),ind1);
% Define all unique pair combinations
mat1 = [r1 c1];
mat1 = sortrows(mat1,[1 2]);
% Find the counts and boundary segment lengths for each unique pair
% combination in the variant data
for ii = 1:size(mat1,1)
    cond1 = ismember(pairIds,mat1(ii,:),'rows');
    counts1(ii,1) = nnz(cond1);
    pairsSegLength1(ii,1) = sum(pairGBs(cond1).segLength);
end

% Replace the counts into the upper diagonal
countsMatrix1 = zeros(maxId,maxId);
idx1 = sub2ind(size(countsMatrix1),mat1(:,1),mat1(:,2));
countsMatrix1(idx1) = counts1;
% Replace the boundary segment lengths into the upper diagonal
segLengthMatrix1 = zeros(maxId,maxId);
segLengthMatrix1(idx1) = pairsSegLength1;
% %---------------------------------



% %---------------------------------
%% Calculate the counts & boundary segment lengths of all equivalent pair
% combinations
% Find the linear indices with value 0
ind0 = find(~pairMatrix);
% Find the subscripts of the linear indices
[r0,c0] = ind2sub(size(pairMatrix),ind0);
% Define all equivalent pair combinations
mat0 = [r0 c0];
mat0 = sortrows(mat0,[1 2]);
% Find the counts and boundary segment lengths for each equivalent pair
% combination in the variant data
for ii = 1:size(mat0,1)
    cond0 = ismember(pairIds,mat0(ii,:),'rows');
    counts0(ii,1) = nnz(cond0);
    pairsSegLength0(ii,1) = sum(pairGBs(cond0).segLength);
end
% Replace the counts into the lower diagonal
temp_countsMatrix0 = zeros(maxId,maxId);
idx0 = sub2ind(size(temp_countsMatrix0),mat0(:,1),mat0(:,2));
temp_countsMatrix0(idx0) = counts0;
% Flip the lower diagonal to the upper diagonal
countsMatrix0 = triu(temp_countsMatrix0.',1);
% Replace the boundary segment lengths into the lower diagonal
temp_segLengthMatrix0 = zeros(maxId,maxId);
temp_segLengthMatrix0(idx0) = pairsSegLength0;
% Flip the lower diagonal to the upper diagonal
segLengthMatrix0 = triu(temp_segLengthMatrix0.',1);
% %---------------------------------




% %---------------------------------
%% Output the results
% Sum the upper diagonal matrices of the unique and equivalent pairs
counts  = countsMatrix0 + countsMatrix1;
segLength  = segLengthMatrix0 + segLengthMatrix1;
% Discount similar variant pairs V1-V1, V2-V2 etc. along the matrix
% principal diagonal (this is fedault unless specified otherwise)
switch calcType
    case {'exclude'}
        counts = counts - diag(diag(counts));
        segLength =  segLength - diag(diag(segLength));
end

switch pairType
    case {'other'}
        % find the linear indices with value 1
        ind = find(counts);
        % find the subscripts of the linear indices
        [r,c] = ind2sub(size(counts),ind);
        % define all unique pair combinations
        mat = [r c];
        mat = sortrows(mat,[1 2]);
        
        cond = false(length(mat),length(eqIds));
        for ii = 1:length(eqIds)
            for jj = 1:size(eqIds{ii},1)
                cond(:,ii) = cond(:,ii) | (any(ismember(mat,eqIds{ii}(jj,1)),2) & any(ismember(mat,eqIds{ii}(jj,2)),2));
            end
        end

        for ii = 1:size(cond,2)
            rc = mat(cond(:,ii),:);
            lind = sub2ind(size(counts),rc(:,1),rc(:,2));
            eqCounts(ii) = sum(counts(lind));
            eqSegLength(ii) = sum(segLength(lind));
        end
        
        anyrc = mat(any(cond,2),:);
        anylind = sub2ind(size(counts),anyrc(:,1),anyrc(:,2));
        anyfc = sum(counts(anylind));
        anyfsl = sum(segLength(anylind));
        switch outputType
            case {'normalise','normalize'}
                out.freq = eqCounts./anyfc;
                out.segLength = eqSegLength./anyfsl;
                %         figure; bar(1:4,out.freq(1,:));
                %         figure; bar(1:4,out.segLength(1,:));
            case {'absolute'}
                out.freq = eqCounts;
                out.segLength = eqSegLength;
        end


    otherwise
        switch outputType
            case {'normalise','normalize'}
                out.freq = counts./sum(sum(counts));
                out.segLength = segLength./sum(sum(segLength));
            case {'absolute'}
                out.freq = counts;
                out.segLength = segLength;
        end
end
% %---------------------------------

end