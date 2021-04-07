function detectParentTwins(job,parentEBSD,pGrainId,varargin)
% Detect twins in a parent grains by local refinement
%
% Syntax
%  detectParentTwins(jjob,parentEBSD,pGrainId)
%
% Input
%  job          - @parentGrainreconstructor
%  parentEBSD   - reconstructed @EBSD data
%  pGrainId     - parent grain Id
%
% Option
%  grains       - plot grain data instead of EBSD data


%% Define the parent grain
pGrain = job.parentGrains(job.parentGrains.id2ind(pGrainId));   
twIds = checkNeighbors(pGrain,job.parentGrains);
if isempty(twIds)
    fprintf("-> No twins in the parent phase detected\n")
else
    twGrains = job.parentGrains(job.parentGrains.id2ind(twIds));
    twEBSDp = parentEBSD(twGrains);
    twEBSDc = job.ebsd(twGrains);
    twgB = job.parentGrains.boundary.selectByGrainId(twIds);

    %% Check fit of local child orienations to parent and twin orientation
    newPId = nan(size(twIds,1),length(twEBSDc));
    for ii = 1:size(twIds,1)
       [~,fit(:,1)] = calcParent(twEBSDc.orientations,twGrains.meanOrientation(1,ii),job.p2c);
       [~,fit(:,2)] = calcParent(twEBSDc.orientations,twGrains.meanOrientation(2,ii),job.p2c);

       %Assign parent Ids
        fit = fit/degree;
        [~,id] = min(fit,[],2);
        newPId(ii,id == 1) = twIds(ii,1);
        newPId(ii,id == 2) = twIds(ii,2);
    end
    twOris = job.parentGrains(job.parentGrains.id2ind(newPId(ii,:))).meanOrientation;

    %% Plot results
    figure;
    mtexFig = newMtexFigure('layout',[1,2]);
    plot(twEBSDp,twEBSDp.orientations);
    hold on
    plot(job.grains(twIds).boundary,'linewidth',3);
    plot(twgB,'lineColor','cyan','linewidth',5,'DisplayName','CSL 3');

    nextAxis
    for ii = 1:size(twIds,1)
        plot(twEBSDp,twOris);
        hold on
    end
    set(gcf,'name','Reconstructed vs. Refined parent orientations');

end
end

function twIds = checkNeighbors(pGrain,grains,varargin)
    %Iteratively find neighboring twins
    neighborIds = pGrain.neighbors(grains);
    twIds = [];
    while 1
        misos = inv(grains(grains.id2ind(neighborIds(:,1))).meanOrientation).*grains(grains.id2ind(neighborIds(:,2))).meanOrientation;
        twIds_new = neighborIds((angle(misos,CSL(3,pGrain.CS)) < get_option(varargin,'threshold',5*degree)),:);
        if size(twIds,1) == size(twIds_new,1)
            return
        else
           twIds = twIds_new;
           neighborIds = grains(grains.id2ind(twIds)).neighbors(grains);
        end
    end
end