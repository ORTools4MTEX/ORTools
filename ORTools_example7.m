
% *********************************************************************
%             ORTools - Example 1 - Variant Graph Approach
% *********************************************************************
% Reconstructing the prior austenite microstructure from lath martensite
% with the variant graph approach and analyzing variant pairing
% The MTEX description for reconstruction is given here:
% https://mtex-toolbox.github.io/MaParentGrainReconstruction.html
% *********************************************************************
% Dr. Azdiar Gazder, 2022, azdiaratuowdotedudotau
% Dr. Frank Niessen, 2022, contactatfniessendotcom
% (Remove "dot" and "at" to make this email address valid)
% *********************************************************************
home; close all; clear variables;
currentFolder;
set(0,'DefaultFigureWindowStyle','normal');
screenPrint('StartUp','ORTools - Example 1 - Variant Graph Approach');

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize',14);   

% Default directories - Do not modify
Ini.dataPath = [pwd,'/data/'];
Ini.cifPath = [Ini.dataPath,'input/cif/'];
Ini.ebsdPath = [Ini.dataPath,'input/ebsd/'];
Ini.texturePath = [Ini.dataPath,'output/texture/'];
Ini.imagePath = [Ini.dataPath,'output/images/'];

%% Load data
% Load an MTEX dataset into 'ebsd'
mtexDataset = 'martensite';
screenPrint('SegmentStart',sprintf('Loading MTEX example data ''%s''',mtexDataset));
ebsd = mtexdata(mtexDataset);

%% Compute, filter and smooth grains
screenPrint('SegmentStart','Computing, filtering and smoothing grains');
% Grains are calculated with a 3° threshold
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',3*degree);
% EBSD data in small grains are removed
ebsd(grains(grains.grainSize < 3)) = [];
% Recalculate the grains from the remaining data ...
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',3*degree);
% ... and smooth the grain boundaries
grains = smooth(grains,5);

%% Rename and recolor phases 
screenPrint('SegmentStart','Renaming and recoloring phases');
phaseNames = {'Gamma','AlphaP'};
% Rename 'Iron bcc (old)'to 'AlphaP' and 'Iron fcc' to 'Gamma'
ebsd = renamePhases(ebsd,phaseNames);
% Choose your favourite colors
ebsd = recolorPhases(ebsd);

%% Define and refine parent-to-child orientation relationship
screenPrint('SegmentStart','Define and refine parent-to-child OR');
% Define 'Gamma" as the parent and 'AlphaP' as the child phase
job = setParentGrainReconstructor(ebsd,grains,Ini.cifPath);
% Give an initial guess for the OR: Kurdjumov-Sachs ...
job.p2c = orientation.KurdjumovSachs(job.csParent, job.csChild);
% ... and refine it based on the fit with boundary misorientations
job.calcParent2Child;
% Let us check the disorientation and compare it with K-S and N-W
% (The disorientation is the misfit between the grain misorientations
% and the misorientation of the OR)
KS = orientation.KurdjumovSachs(job.csParent,job.csChild);
NW = orientation.NishiyamaWassermann(job.csParent,job.csChild);
plotHist_OR_misfit(job,[KS,NW],'legend',{'K-S OR','N-W OR'});
% Plot information about the OR
ORinfo(job.p2c);
%    - There are 24 martensitic variants
%    - And a ~2.4° disorientation exists from the Nishiyama-Wassermann OR

%% Plotting (with ORTools functions)
screenPrint('SegmentStart','Plotting some ORTools maps');
% Use some of the ORTools functions to visualize the determined OR
% and its relation to the microstructure

% Phase map
plotMap_phases(job,'linewidth',2);
%    - There is no retained austenite (gamma)

% Parent and child IPF maps
plotMap_IPF_p2c(job,vector3d.Z,'linewidth',2);
%    - It is clear that martensite has formed from multiple prior 
%    - austenite grains and that some surface scratches led to bad indexing

% Child-child grain boundary misorientation map
plotMap_gB_c2c(job,'linewidth',2);
%    - Misorientation angles of ~15-50° are not present within prior
%    austenite grains and thus delinitate prior austenite grain
%    boundaries

% Plot a map of the OR boundary disorientation, or misfit
plotMap_gB_misfit(job,'linewidth',2, 'maxColor',5);
%    - By setting a threshold at 5 degrees, the prior austenite grain
%    boundaries are identified by their large misfit with the OR

% Plot a map of the OR boundary probability 
plotMap_gB_prob(job,'linewidth',2);
%   - the same can be visualized by calculating the probability that a
%     boundary belongs to the OR

%% Reconstruct parent microstructure
%   - Reconstruct the microstructure with the variant graph based approach
job.calcVariantGraph('threshold',2.5*degree,'tolerance',2.5*degree);
% job.calcVariantGraph('threshold',2.5*degree,'tolerance',2.5*degree,'mergeSimilar')
% job.clusterVariantGraph
% job.calcVariantGraph('threshold',2.5*degree,'tolerance',2.5*degree)
job.clusterVariantGraph('includeSimilar');
% ... plot the votes (high values show high certainty)
figure; plot(job.grains,job.votes.prob(:,1))
mtexColorbar
% ... and calculate the parent orientations
job.calcParentFromVote('minProb',0.5)
% Plot the reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',2);

%% Remove badly reconstructed clusters
% In order to reconstruct the remaining parent grains, we can calculate the
% votes for surrounding parent grains by the already reconstructed parent
% grains

% compute the votes
job.calcGBVotes('p2c','reconsiderAll')
% assign parent orientations according to the votes
job.calcParentFromVote
% plot the result
plot(job.parentGrains,job.parentGrains.meanOrientation)

%% Clean reconstructed grains
% Now clean the grains by: 
% - merging grains with similar orientation
job.mergeSimilar('threshold',7.5*degree);
% - merging small inclusions
job.mergeInclusions('maxSize',50);
% This is the cleaned reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',2)

%% Variant analysis
% Now that both the alpha and the associated prior gamma orientations are
% available, variant analysis can be conducted.
% Plot the possible variants in a pole figure
plotPDF_variants(job);
% Then calculate the variant IDs of all alpha grains ...
job.calcVariants;
% ... and plot them
plotMap_variants(job,'grains','linewidth',3); %Grain data
plotMap_variants(job,'linewidth',3); %EBSD data

% We see that each child grain contains several variants on EBSD level
% For analyzing the variant pairing, we need the variants on EBSD level
% to be reconstructed to grains

%% Variant pairing (block boundary) analysis
[variant_grains,ebsdC] = computeVariantGrains(job);
%Compare variant indexing for old and new grains
figure; %Old grains
plot(job.transformedGrains,job.transformedGrains.variantId);
figure; %New grains
plot(variant_grains,variant_grains.variantId);
%We see that all the variant detail of the variantId's in the EBSD map are
%not also present on grain level. This allows us to analyze the boundaries
%between variants:
variant_boundaries = plotMap_variantPairs(variant_grains,ebsdC,'linewidth',1.5);
%In theory one could use the reindexed grains to redo the parent grain
%reconstruction based on these grains. This does however not lead to a
%significantly better reconstruction (in the present datas
%% Save images
saveImage(Ini.imagePath);

%% Check the gamma grains interactively by clicking on them
grainClick(job,'noScalebar','noFrame'); %Plot EBSD data

%% Do the same at the grain level 
% This includes the variant pairing map (only useful after having refined
% to laths!) and the block width calculator - valid for martensitic steels
grainClick(job,'grains','noFrame'); %Plot grain data

%% Refine gamma twins by clicking on gamma grains
grainClick(job,'parentTwins');
