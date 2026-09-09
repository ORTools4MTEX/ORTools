function out = computeGrainPairs(pairGrains,varargin)
%% Function description:
% This function computes the absolute or normalised frequency and boundary
% segment lengths of grain pairs. The grain pair ids can be defined by the 
% user for variants, crystallographic packets, Bain groups, any other-id 
% type or for groups of id or equivalent id pairs.
%
%% Syntax:
% [out] = computeGrainPairs(grains)
%
%% Input:
%  pairGrains - @grain2d = child grain pairs as computed by the 
%                          "computeVariantGrains.m" function
%
%% Output:
%  out        - @struc   = a structure variable containing the absolute or 
%                          normalised frequency and boundary segment 
%                          lengths ofgrain pairs or groups of equivalent 
%                          pairs.
%
%% Options:
%  variant    - Uses the variant ids of child grain pairs.
%  packet     - Uses the packet ids of child grain pairs.
%  bain       - Uses the Bain ids of child grain pairs.
%  other      - Uses a pre-specified list of ids of child grain pairs.
%  group      - A cell defining groups of id or equivalent id pairs. Use
%               the "computeVariantPairGroups.m" function to derive the
%               complete set of groups automatically.
%  labels     - A cell of x-axis labels, one per group, used when plotting
%               groups of id or equivalent id pairs. Labels are composed
%               from the id pairs themselves if not specified.
%  include    - Includes similar neighbouring variant, packet, bain, 
%               other-id type, groups of id or equivalent id pairs.
%               For e.g. - V1-V1, or CP2-CP2, or B3-B3 etc. 
%  exclude    - Excludes similar neighbouring variant, packet, bain, 
%               other-id type, groups of id or equivalent id pairs. 
%               (default)
%  absolute   - Returns the absolute frequency and boundary segment values
%               of neighbouring variant, packet, bain, other-id type or 
%               groups of id or equivalent id pairs.
%  normalise  - Returns the normalised frequency and boundary segment 
%               values of neighbouring variant, packet, bain, other-id 
%               type groups of id or equivalent id pairs. (default)


pairType = lower(get_flag(varargin,{'variant','packet','bain','other'},'variant'));
groupIds = get_option(varargin,'group',{});
groupLabels = get_option(varargin,'labels',{});
cmap = get_option(varargin,'colormap',inferno);
calcType = lower(get_flag(varargin,{'exclude','include'},'exclude'));
outputType = lower(get_flag(varargin,{'normalise','normalize','absolute'},'normalise'));


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
        pairIds = pairGrains(pairGrains.id2ind(pairGrainIds)).otherId;
end
[pairIds,idx] =  sortrows(pairIds,[1 2]);
pairGBs = pairGBs(idx);
maxId = max(max(pairIds));



% %---------------------------------
%% Define a matrix whose rows & columns signify variant pair combinations
% For example, row 1, column 2 = variant pair V1-V2
pairMatrix = ones(maxId,maxId);
% Re-define unique (value = 1) and equivalent (value = 0) pair combinations
% as follows: V1-V2 (= unique pair) == V2-V1 (= equivalent pair)
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
% principal diagonal (this behaviour is default unless specified otherwise)
switch calcType
    case {'exclude'}
        counts = counts - diag(diag(counts));
        segLength =  segLength - diag(diag(segLength));
end

if ~isempty(groupIds) % equivalent id groups provided
    % find the linear indices with value 1
    ind = find(counts);
    % find the subscripts of the linear indices
    [r,c] = ind2sub(size(counts),ind);
    % define a matrix of all unique pair combinations
    mat = [r c];
    mat = sortrows(mat,[1 2]);

    % Match the observed pairs against the id pairs listed in each group.
    % Both are sorted along their rows so that the match is insensitive to
    % the order in which a group lists the two ids of a pair.
    sortedMat = sort(mat,2);
    cond = false(size(sortedMat,1),length(groupIds));
    for ii = 1:length(groupIds)
        cond(:,ii) = ismember(sortedMat,sort(groupIds{ii},2),'rows');
    end

    % Warn about pairs that are present in the data but not covered by any
    % group, since these are silently discarded from the output
    isUngrouped = ~any(cond,2);
    if any(isUngrouped)
        lind = sub2ind(size(counts),mat(isUngrouped,1),mat(isUngrouped,2));
        discardedFraction = sum(counts(lind))/sum(counts(:));
        warning(['computeGrainPairs: %d of %d observed id pairs are not covered by ',...
            'the specified groups. These account for %.1f%% of all pairs and are ',...
            'excluded from the output.'],nnz(isUngrouped),size(mat,1),100*discardedFraction);
    end

    for ii = 1:size(cond,2)
        rc = mat(cond(:,ii),:);
        lind = sub2ind(size(counts),rc(:,1),rc(:,2));
        eqCounts(ii) = sum(counts(lind));
        eqSegLength(ii) = sum(segLength(lind));
    end

    switch outputType
        case {'normalise','normalize'}
            out.freq = eqCounts./sum(sum(eqCounts));
            out.segLength = eqSegLength./sum(sum(eqSegLength));
        case {'absolute'}
            out.freq = eqCounts;
            out.segLength = eqSegLength;
    end
else % equivalent id groups not provided
    switch outputType
        case {'normalise','normalize'}
            out.freq = counts./sum(sum(counts));
            out.segLength = segLength./sum(sum(segLength));
        case {'absolute'}
            out.freq = counts;
            out.segLength = segLength;
    end
end

% Set not considered values to NaN
if all(size(out.freq)>1)
    out.freq(~pairMatrix) = nan;
    out.segLength(~pairMatrix) = nan;
    if ~find_option(varargin,'include')
        dia = logical(diag(ones(size(out.freq,1),1)));
        out.freq(dia) = nan;
        out.segLength(dia) = nan;
    end
end
%% Plot the results
if find_option(varargin,'plot')
    figH = figure('color','w');
    if find_option(varargin,'group')
        if ~isempty(groupLabels)
            assert(length(groupLabels) == length(groupIds),...
                ['computeGrainPairs: %d labels were specified for %d groups. ',...
                'The ''labels'' option requires one label per group.'],...
                length(groupLabels),length(groupIds));
            labels = groupLabels;
        else
            labels = cell(1,length(groupIds));
            for ii=1:length(groupIds)
                labels{ii} = formatLabel(groupIds{ii});
            end
        end

        h = bar(out.freq);
        h.FaceColor =[162 20 47]./255;
        set(gca,'FontSize',14);
        xticks(1:length(labels));
        xticklabels(labels);
        xtickangle(90);
        xlabel('\bf Variant pairs');
        ylabel('\bf Relative frequency [$\bf f$(g)]','interpreter','latex');
        drawnow;
    elseif all(size(out.freq)>1)
        
        [nr,nc] = size(out.freq);
        s = pcolor([(1:nr+1)-0.5],[(1:nc+1)-0.5],[out.freq nan(nr,1); nan(1,nc+1)]);
        shading flat;
        s.EdgeColor = [1 1 1];
        s.LineWidth = 1;
        set(gca,'Color','none') 
        daspect([1 1 1])
        c = colorbar;
        colormap(cmap)
        c.Label.String = '\bf Relative frequency [$\bf f$(g)]';
        c.Label.Interpreter = 'latex';
        xticks(1:size(out.freq,1));
        yticks(1:size(out.freq,2));
        xlabel('Id');
        ylabel('Id');
        xtickangle(0);
        xlim_curr =xlim;
        xlim([xlim_curr(1)-xlim_curr(2)/50,xlim_curr(2)+xlim_curr(2)/50]);
        ylim_curr =ylim;
        ylim([ylim_curr(1)-ylim_curr(2)/50,ylim_curr(2)+ylim_curr(2)/50]);
    else
        warning("Skipping plotting");
    end
end
end

function label = formatLabel(pairIds)
%% Compose an x-axis label from an n x 2 array of id pairs
% Groups derived with "computeVariantPairGroups.m" hold up to 24 pairs each,
% so only the first few pairs are spelled out and the rest are counted.
maxPairs = 3;
nShown = min(size(pairIds,1),maxPairs);
sublabels = cell(1,nShown);
for ii = 1:nShown
    sublabels{ii} = sprintf('V%d-V%d',pairIds(ii,1),pairIds(ii,2));
end
label = strjoin(sublabels,' / ');
if size(pairIds,1) > nShown
    label = sprintf('%s (+%d)',label,size(pairIds,1)-nShown);
end
end
