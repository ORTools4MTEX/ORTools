
% *********************************************************************
%                        ORTools - Example 1
% *********************************************************************
% Reconstructing the prior austenite microstructure from lath martensite
% with the variant graph approach
% The MTEX description for reconstruction is given here:
% https://mtex-toolbox.github.io/GrainGraphBasedReconstruction.html
% *********************************************************************
% Dr. Azdiar Gazder, 2020, azdiaratuowdotedudotau
% Dr. Frank Niessen, 2020, contactatfniessendotcom
% (Remove "dot" and "at" to make this email address valid)
% *********************************************************************
home; close all; clear variables;
currentFolder;
set(0,'DefaultFigureWindowStyle','normal');
screenPrint('StartUp','ORTools - Example 1');
%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize',14);   
setInterp2Tex;

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
% Display information about the OR
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
%   - Reconstruct the microstructure with a graph-based approach
job.calcGraph('threshold',2.5*degree,'tolerance',2.5*degree);
job.clusterGraph('inflationPower',1.6)
% Plot the clusters ...
plotMap_clusters(job,'linewidth',2);
% ... and calculate the parent orientations
job.calcParentFromGraph

% Plot the reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',2);
%% Remove badly reconstructed clusters
% While the first reconstruction looks good, plotting the fit of each 
% reconstructed alphaP grain with the overall parernt orientation of the
% cluster shows that some grains are not well-reconstructed
figure;
plot(job.grains,job.grains.fit./degree,'linewidth',2);
setColorRange([0,5]);
mtexColorbar;
% Therefore, the reconstructed grains with bad fits or very small clusters
% are reverted
job.revert(job.grains.fit > 5*degree | job.grains.clusterSize < 15)
% Plot the remaining grains
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',2)
%% Fill in unreconstructed regions with voting algorithm
% Use the already confidently reconstructed gamma grains to vote for the
% gamma orientation of the yet-to-be reconstructed alpha grains
% Iterate this 5 times ...
for k = 1:3 
  % compute votes
  job.calcGBVotes('p2c','threshold',k*2.5*degree);
  % compute parent orientations from votes
  job.calcParentFromVote
end

%... and plot the optimized reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',2)
%% Clean reconstructed grains
% Now clean the grains by: 
% - merging grains with similar orientation
job.mergeSimilar('threshold',7.5*degree);
% - and merging small inclusions into larger grains
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
plotMap_variants(job,'linewidth',1);
%plotMap_variants(job,'grains','linewidth',3);  %Plot grain data instead
% The same can be done for the packets
plotMap_packets(job,'linewidth',3);
%plotMap_packets(job,'grains','linewidth',3);   %Plot grain data instead

%% Plot reconstructed parent EBSD orientations and the IPF key
parentIPFkey = plotMap_IPF_p2c(job,vector3d.Z,'linewidth',3,'parent');
figure; plot(parentIPFkey);
%% Save images
saveImage(Ini.imagePath);

%% Check the gamma grains interactively by clicking on them
grainClick(job,'noScalebar','noFrame'); %Plot EBSD data
% grainClick(job,'grains','noScalebar','noFrame'); %Plot grain data

%% Refine gamma twins by clicking on gamma grains
grainClick(job,'parentTwins');