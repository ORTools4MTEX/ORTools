function computeParentTwins(job,pGrainId,varargin)
%% Function description:
% This function computes twins in parent grains by local refinement.
%
%% Syntax:
%  computeParentTwins(job,pGrainId)
%
%% Input:
%  job          - @parentGrainreconstructor
%  pGrainId     - parent grain Id 
%  direction    - @vector3d
%
%% Options:
%  grains       - plot grain data instead of EBSD data


%% Check for any twins
pGrain = job.parentGrains(job.parentGrains.id2ind(pGrainId));   
twIds = checkNeighbors(pGrain,job.parentGrains);
if isempty(twIds)
    error('No twins detected in the parent phase.')
    return;
end

%% Prepare IPF color key
ipfKeyParent = ipfHSVKey(job.csParent);
ipfKeyParent.inversePoleFigureDirection = getClass(varargin,'vector3d',vector3d.X);

%% Define the parent grain and find twin related neighbor grains
twGrains = job.parentGrains(job.parentGrains.id2ind(twIds));
twEBSDp = job.ebsd(twGrains);
twEBSDc = job.ebsdPrior(job.ebsdPrior.id2ind(twEBSDp.id));
twEBSDc = twEBSDc(job.csChild);
twgB = job.parentGrains.boundary.selectByGrainId(twIds);

%% Check fit of local child orienations to mean parent and twin orientation
% and determine the local parent orientations

for ii = 1:size(twIds,1)
   for gNr = 1:2 %Loop grain pair
       % Get parent variant IDs and Fit
       [pVarIds(:,gNr),fit(:,ii,gNr)] = calcParent(twEBSDc.orientations,twGrains.meanOrientation(ii,gNr),job.p2c,'id');

       % Get local parent orientations
       pOris(:,ii,gNr) = variants(job.p2c, twEBSDc.orientations, pVarIds(:,gNr));

%        *** ATTEMPT TO CHECK LOCAL FIT - UNSUCCESSFUL
%        % Get parent variant IDs
%        [pVarIds(:,gNr),~] = calcParent(twEBSDc.orientations,twGrains.meanOrientation(gNr,ii),job.p2c,'id');
%        % Get local parent orientations
%        pOris(:,gNr) = variants(job.p2c, twEBSDc.orientations, pVarIds(:,gNr));
%        % Remove the ones that don't match the mean orientation well
%        badFit = angle(pOris(:,gNr),twGrains.meanOrientation(gNr,ii)) > 2*get_option(varargin,'threshold',5*degree);
%        pOris(badFit,gNr) = orientation.nan(pGrain.CS);
%        % Get fit of each orientation
%        [~,fit(:,gNr)] = calcParent(twEBSDc.orientations,pOris(:,gNr),job.p2c);
   end         
end

    % Assign parent orienetations based on best fit

try
    % Works with MATLAB 2019a and later
    [~,id] = min(fit,[],[2 3],'linear');    
    newPoris = pOris(id);  
catch
    newPoris = orientation.nan([size(pOris,1),1],job.csParent);
    pOris = reshape(pOris,[size(fit,1),size(fit,2)*size(fit,3)]);
    fit = reshape(fit,[size(fit,1),size(fit,2)*size(fit,3)]);
    [~,id] = min(fit,[],2);% Locate minimum value for all rows
    for ii = 1:length(newPoris)
        newPoris(ii) = pOris(ii,id(ii));
    end   
end


%% Plot results
figure;
% Initial parent EBSD data and twin boundary
mtexFig = newMtexFigure('layout',[1,2]);
cbsParent = ipfKeyParent.orientation2color(twEBSDp.orientations);
plot(twEBSDp,cbsParent);
hold on
plot(job.grains(twIds).boundary,'linewidth',3);
plot(twgB,'lineColor','cyan','linewidth',3,'DisplayName','CSL 3');

% And the refined twin orientations
nextAxis
cbsParent = ipfKeyParent.orientation2color(newPoris);
plot(twEBSDc,cbsParent);
set(gcf,'name','Reconstructed vs. Refined parent orientations');

end


function twIds = checkNeighbors(pGrain,grains,varargin)
    % Iteratively find neighboring twins
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