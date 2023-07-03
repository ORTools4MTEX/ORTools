
% *********************************************************************
%             ORTools - Example 7
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
screenPrint('StartUp','ORTools - Example 7 - Variant Graph Approach');

%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize',14);   

% Default directories - Do not modify
Ini.dataPath = [strrep(pwd,'\','/'),'/data/'];
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
% Grains are calculated with a 3� threshold
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
KS = orientation.KurdjumovSachs(job.csParent,job.csChild);
job.p2c = KS;
% ... and refine it based on the fit with boundary misorientations
job.calcParent2Child;
% Let us check the disorientation and compare it with K-S and N-W
% (The disorientation is the misfit between the grain misorientations
% and the misorientation of the OR)
NW = orientation.NishiyamaWassermann(job.csParent,job.csChild);
plotHist_OR_misfit(job,[KS,NW],'legend',{'K-S OR','N-W OR'});
% Plot information about the OR
ORinfo(job.p2c);
%    - There are 24 martensitic variants
%    - And a ~2.1� disorientation exists from the Nishiyama-Wassermann OR

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
%    - Misorientation angles of ~15-50� are not present within prior
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
job.calcVariantGraph('threshold',4*degree,'tolerance',3.5*degree);
%job.calcVariantGraph('threshold',2.5*degree,'tolerance',2.5*degree,'mergeSimilar')
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
job.mergeInclusions('maxSize',150);
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
% For analyzing variant pairing, we need the variants on the EBSD level
% to be reconstructed as grains
%% Variant pairing (block boundary) analysis
[~,maxGrainId] = max(job.grains.area);
[variantGrains,ebsdC] = computeVariantGrains(job);
%Compare variant indexing for old and new grains
figure; %Old grains
plot(grains,grains.meanOrientation);
figure; %New grains
plot(variantGrains,variantGrains.meanOrientation);
% We see that all the variant detail of the variantIds in the EBSD map are
% absent at the grain level. This allows us to analyze the boundaries
% between variants.
variantBoundaries_map = plotMap_variantPairs(job,'linewidth',1.5);
% We can also analyze and plot the same for individual prior austenite grains.
variantBoundaries_PAG = plotMap_variantPairs(job,'parentGrainId',maxGrainId,'linewidth',2);
% In theory, one could use the reindexed grains to redo the parent grain
% reconstruction based on these grains. This does however not lead to a
% significantly better reconstruction in the present dataset.

%% Calculate martensite block widths
% ... for a PAG by specifying a gamma grain id
plotMap_blockWidths(job,'parentGrainId',maxGrainId,'linewidth',1.5);
% ... for the entire map (more statistics, but can be slow for large maps)
plotMap_blockWidths(job,'linewidth',1);

%% Display variant information for a PAG by specifying a gamma grain id
plotStack(job,'parentGrainId',maxGrainId,'linewidth',1.5);
plotStack(job,'grains','noFrame','parentGrainId',maxGrainId,'linewidth',1.5);

%% Save images
saveImage(Ini.imagePath);

%% Display variant information for a PAG by interactively clicking on a gamma grain
grainClick(job,'noScalebar','noFrame'); %Based on EBSD data

%% Do the same at the grain level 
grainClick(job,'grains','noFrame'); %Based on grain data

%% Display variant pairing (block boundary) analysis for a PAG by interactively clicking on a gamma grain
grainClick(job,'variantPairs','noFrame','linewidth',2);

%% Calculate martensite block widths for a PAG by interactively clicking on a gamma grain
grainClick(job,'blockWidth','noFrame','linewidth',2);

%% Refine gamma twins for a PAG by interactively clicking on a gamma grain
grainClick(job,'parentTwins');

