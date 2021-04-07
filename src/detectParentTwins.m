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
pGrain = job.parentGrains(job.parentGrains.id == pGrainId);   
oriP = pGrain.meanOrientation;
neighborIds = pGrain.neighbors(job.parentGrains);
misos = inv(job.grains(neighborIds(:,1)).meanOrientation).*job.grains(neighborIds(:,2)).meanOrientation;
twIds = neighborIds((angle(misos,CSL(3,job.csParent)) < 5*degree),:);
if isempty(twIds)
    fprintf("-> No twins in the parent phase detected\n")
else
    twEBSDp = parentEBSD(job.grains(twIds));
    twEBSDc = job.ebsd(job.grains(twIds));
    twgB = job.grains.boundary.selectByGrainId(job.grains(twIds).id');

    %% Check fit of local child orienations to parent and twin orientation
    newPId = nan(size(twIds,1),length(twEBSDc));
    for ii = 1:size(twIds,1)
       [~,fit(:,1)] = calcParent(twEBSDc.orientations,job.grains(twIds(ii,1)).meanOrientation,job.p2c);
       [~,fit(:,2)] = calcParent(twEBSDc.orientations,job.grains(twIds(ii,2)).meanOrientation,job.p2c);

       %Assign parent Ids
        fit = fit/degree;
        [~,id] = min(fit,[],2);
        newPId(ii,id == 1) = twIds(ii,1);
        newPId(ii,id == 2) = twIds(ii,2);
    end

    %% Plot results
    figure;
    mtexFig = newMtexFigure('layout',[1,2]);
    plot(twEBSDp,twEBSDp.orientations)
    hold on
    plot(job.grains(twIds).boundary,'linewidth',3);
    plot(twgB,'lineColor','cyan','linewidth',5,'DisplayName','CSL 3')

    nextAxis
    for ii = 1:size(twIds,1)
        plot(twEBSDp,job.grains(newPId(ii,:)).meanOrientation);
        hold on
    end
    set(gcf,'name','Reconstructed vs. Refined parent orientations');

end