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


%% Check if any twins are around
pGrain = job.parentGrains(job.parentGrains.id2ind(pGrainId));   
twIds = checkNeighbors(pGrain,job.parentGrains);
if isempty(twIds)
    fprintf("-> No twins in the parent phase detected\n")
    return
end

%% Prepare IPF color key
ipfKeyParent = ipfHSVKey(job.csParent);
ipfKeyParent.inversePoleFigureDirection = getClass(varargin,'vector3d',vector3d.Z);

%% Define the parent grainand find twin related neighbor grains
twGrains = job.parentGrains(job.parentGrains.id2ind(twIds));
twEBSDp = parentEBSD(twGrains);
twEBSDc = job.ebsd(twGrains);
twgB = job.parentGrains.boundary.selectByGrainId(twIds);

%% Check fit of local child orienations to mean parent and twin orientation
% and determine the local

for ii = 1:size(twIds,1)
   for gNr = 1:2 %Loop grain pair
       %Get parent variant IDs and Fit
       if all(size(twGrains) == [2,1]) % THIS SHOULD BE FIXED IN MTEX!!
           [pVarIds(:,gNr),fit(:,ii,gNr)] = calcParent(twEBSDc.orientations,twGrains.meanOrientation(gNr,ii),job.p2c,'id');
       else
           [pVarIds(:,gNr),fit(:,ii,gNr)] = calcParent(twEBSDc.orientations,twGrains.meanOrientation(ii,gNr),job.p2c,'id');
       end
       %Get local parent orientations
       pOris(:,ii,gNr) = variants(job.p2c, twEBSDc.orientations, pVarIds(:,gNr));

% *** ATTEMPT OF CHECKING LOCAL FIT - NOT SUCCESFUL        
%            %Get parent variant IDs
%            [pVarIds(:,gNr),~] = calcParent(twEBSDc.orientations,twGrains.meanOrientation(gNr,ii),job.p2c,'id');
%            %Get local parent orientations
%            pOris(:,gNr) = variants(job.p2c, twEBSDc.orientations, pVarIds(:,gNr));
%            %Remove the ones that don't match the mean orientation well
%            badFit = angle(pOris(:,gNr),twGrains.meanOrientation(gNr,ii)) > 2*get_option(varargin,'threshold',5*degree);
%            pOris(badFit,gNr) = orientation.nan(pGrain.CS);
%            %Get fit of each orientation
%            [~,fit(:,gNr)] = calcParent(twEBSDc.orientations,pOris(:,gNr),job.p2c);
   end         
end

    %Assign parent orienetations based on best fit

try
    %Works with MATLAB 2019a and later
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
%Initial parent EBSD data and twin boundary
mtexFig = newMtexFigure('layout',[1,2]);
cbsParent = ipfKeyParent.orientation2color(twEBSDp.orientations);
plot(twEBSDp,cbsParent);
hold on
plot(job.grains(twIds).boundary,'linewidth',3);
plot(twgB,'lineColor','cyan','linewidth',5,'DisplayName','CSL 3');

%And the refined twin orientations
nextAxis
for ii = 1:size(twIds,1)
    cbsParent = ipfKeyParent.orientation2color(newPoris);
    plot(twEBSDp,cbsParent);
    hold on
end
set(gcf,'name','Reconstructed vs. Refined parent orientations');

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

function [v,idx] = minN(A)
    %MINN - gets minimum value and its index of n-dimensional matrix
    %
    % Syntax:  [v,idx] = minN(A)
    %
    % Inputs:
    %    A   - the matrix of which the minimum value shall be found
    %
    % Outputs:
    %    v   - the minimum value of A
    %    idx - the index of v in matrix A
    %
    % Example: 
    %    A(:,:,1) = [1,1,1;1,1,1;1,1,1];
    %    A(:,:,2) = [1,1,1;1,1,1;1,1,1];
    %    A(:,:,3) = [1,1,1;1,1,1;0,1,1];
    %    
    %    [v,idx] = minN(A);
    %
    %    % v = 0, and idx = [3,1,3]
    %    % it is A(3,1,3) = 0
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    %
    % See also: min, max, maxN
    % Author: Christopher Haccius, significantly enhanced by Jos (Matlab
    % community member)
    % Telecommunications Lab, Saarland University, Germany
    % email: haccius@nt.uni-saarland.de
    % December 2013; Last revision: 19-December-2013
    [v, linIdx] = min(A(:));
    [idxC{1:ndims(A)}] = ind2sub(size(A),linIdx);
    idx = cell2mat(idxC);
end
