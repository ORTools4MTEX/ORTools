
% *********************************************************************
%                        ORTools - Example 1
% *********************************************************************
% Reconstructing the prior austenite microstructure from lath martensite
% Find the detailed MTEX version on the details of the reconstruction here:
% https://mtex-toolbox.github.io/MaParentGrainReconstruction.html
% *********************************************************************
% Dr. Azdiar Gazder, 2020, azdiaratuowdotedudotau
% Dr. Frank Niessen, 2020, contactatfniessendotcom
% (Remove "dot" and "at" to make this email address valid)
% *********************************************************************
clc; close all; clear all;
currentFolder;
screenPrint('StartUp','ORTools - Example 1');
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
% We load an MTEX dataset into 'ebsd'
mtexDataset = 'martensite';
screenPrint('SegmentStart',sprintf('Loading MTEX example data ''%s''',mtexDataset));
ebsd = mtexdata(mtexDataset);
%% Compute, filter and smooth grains
screenPrint('SegmentStart','Computing, filtering and smoothing grains');
% Grains are calculated with a 3° threshold
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'), 'angle', 3*degree);
% EBSD data in small grains are removed
ebsd(grains(grains.grainSize < 3)) = [];
% We then recalculate the grains from the remaining data ...
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',3*degree);
% ... and smooth the grain boundaries
grains = smooth(grains,5);
%% Rename and recolor phases 
screenPrint('SegmentStart','Renaming and recoloring phases');
phaseNames = {'Gamma','AlphaP'};
% We rename 'Iron bcc (old)'to 'AlphaP' and 'Iron fcc' to 'Gamma'
ebsd = renamePhases(ebsd,phaseNames);
% Choose your favourite colors
[ebsd,grains] = recolorPhases(ebsd,grains);
%% Define and refine parent-to-child orientation relationship
screenPrint('SegmentStart','Define and refine parent-to-child OR');
% Define 'Gamma" as the parent and 'AlphaP' as the child phase
job = setParentGrainReconstructor(ebsd,grains,Ini.cifPath);
% We give an initial guess for the OR: Kurdjumow-Sachs ...
job.p2c = orientation.KurdjumovSachs(job.csParent, job.csChild);
% ... and refine it based on the fit with boundary misorientations
job.calcParent2Child;
% Let us check the disorientation and compare it with K-S and N-W
KS = orientation.KurdjumovSachs(job.csParent,job.csChild);
NW = orientation.NishiyamaWassermann(job.csParent,job.csChild);
plotHist_OR_misfit(job,[KS,NW],'legend',{'K-S','N-W'});
% Plot information about the OR
ORinfo(job.p2c);
%    - We have 24 martensitic variants
%    - We are ~2.4° from the Nishiyama-Wassermann OR
%% Plotting (with ORTools functions)
screenPrint('SegmentStart','Plotting some ORTools maps');
% Use some of the ORTools functions to visualize the determined OR
% and its relation to the microstructure

% Phase map
plotMap_phases(job,'linewidth',2);
%    - We have no retained austenite (gamma)

% Parent and child IPF maps
plotMap_IPF_p2c(job,vector3d.Z,'linewidth',2);
%    - We can see that martensite has formed from multiple prior 
%    - austenite grains and that some surface scratches led to bad indexing

% Child-child grain boundary misorientation map
plotMap_gB_c2c(job,'linewidth',2);
%    - We can see that misorientation angles of ~15-50° are not present
%    within prior austenite grains and thus delinitate prior austenite
%    grain boundaries

% Plot a map of the OR boundary disorientation, or misfit
plotMap_gB_misfit(job,'linewidth',2, 'maxColor',5);
%    - By setting a threshold at 5 degrees we can identify the prior
%    austenite grain boundaries by their large misfit with the OR

% Plot a map of the OR boundary probability 
plotMap_gB_prob(job,'linewidth',2);
%   - the same can be visualized by calculating the probability that a
%     boundary belongs to the OR

%% Reconstruct parent microstructure
%   - We reconstruct the microstructure with a graph-based approach
job.calcGraph('threshold',2.5*degree,'tolerance',2.5*degree);
job.clusterGraph('inflationPower',1.6);
% Plot the clusters ...
plotMap_clusters(job,'linewidth',2);
% ... and calculate the parent orientations
job.calcParentFromGraph;

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
% We therefire decide to revert the reconstruction of grains with bad fits
% or with very small clusters
job.revert(job.grains.fit > 5*degree | job.grains.clusterSize < 15)
% Plot the remaining grains
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',2)
%% Fill in unreconstructed regions with voting algorithm
% We can now use the already confidently reconstructed gamma grains to 
% vote for the gamma orientation of not yet reconstructed alpha grains
% We iterate this 5 times ...
for k = 1:3 
  % compute votes
  job.calcGBVotes('noC2C');
  % compute parent orientations from votes
  job.calcParentFromVote('minFit',7.5*degree)
end

%... and plot the optimized reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',2)
%% Clean reconstructed grains
% We can now clean the grains by 
% - merging grains with similar orientation
job.mergeSimilar('threshold',7.5*degree);
% - and mergeing small inclusions into larger grains
job.mergeInclusions('maxSize',50);
% This is the cleaned reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',2)
%% Variant analysis
% Now that we have both the alpha and the associated prior gamma
% orientations, we can conduct variant analysis.
% Plot the possible variants in a pole figure
plotPDF_variants(job);
% We then calculate the variant IDs of all alpha grains ...
job.calcVariants;
% ... and plot them
plotMap_variants(job,'linewidth',3);
%plotMap_variants(job,'grains','linewidth',3);  %Plot grain data instead
% The same can be done for the packets
plotMap_packets(job,'linewidth',3);
%plotMap_packets(job,'grains','linewidth',3);   %Plot grain data instead

%% Reconstruct parent EBSD 
% We can finally obtain the reconstructed EBSD data
parentEBSD = job.calcParentEBSD;
% And plot it with the prior beta grain boundaries
figure;
plot(parentEBSD(job.csParent),parentEBSD(job.csParent).orientations);
hold on; 
plot(job.grains.boundary,'lineWidth',3)

%% Save images
saveImage(Ini.imagePath);

%% Check the gamma grains interactively by clicking on them
grainClick(job,parentEBSD);
%grainClick(job,parentEBSD,'grains');    %Plot grain data instead

%% Refine gamma twins by clicking on gamma grains
grainClick(job,parentEBSD,'parentTwins');


