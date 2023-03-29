
% *********************************************************************
%             ORTools - Example 8
% *********************************************************************
% Reconstructing the prior beta Ti microstructure from alpha grains
% with the variant graph approach
% The MTEX description for reconstruction is given here:
% https://mtex-toolbox.github.io/TiBetaReconstruction.html
% *********************************************************************
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
% Dr. Frank Niessen, 2023, contactatfniessendotcom
% (Remove "dot" and "at" to make this email address valid)
% *********************************************************************
home; close all; clear variables;
currentFolder;
set(0,'DefaultFigureWindowStyle','normal');
screenPrint('StartUp','ORTools - Example 8 - Variant Graph Approach in Ti');

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
mtexDataset = 'alphaBetaTitanium';
screenPrint('SegmentStart',sprintf('Loading MTEX example data ''%s''',mtexDataset));
ebsd = mtexdata(mtexDataset);

%% Compute grains
screenPrint('SegmentStart','Computing, filtering and smoothing grains');
% Grains are calculated with a 1.5° threshold
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',1.5*degree,...
    'removeQuadruplePoints');
%% Rename and recolor phases
screenPrint('SegmentStart','Renaming and recoloring phases');
phaseNames = {'Alpha','Beta'};
% Rename "Ti (BETA) to "Beta"and "Ti (alpha)" to "Alpha"
ebsd = renamePhases(ebsd,phaseNames);
% Choose your favourite colors
ebsd = recolorPhases(ebsd);
%% Finding the orientation relationship
screenPrint('SegmentStart','Finding the orientation relationship(s)');
% Choose Beta as a parent and Alpha as a child phase in the transition
job = setParentGrainReconstructor(ebsd,grains,Ini.cifPath);
% Provide the OR
job.p2c = orientation.Burgers(ebsd('Beta').CS,ebsd('Alpha').CS);
% Let us check the disorientation
% (The disorientation is the misfit between the grain misorientations
% and the misorientation of the OR)
plotHist_OR_misfit(job);
% Plot information about the OR
ORinfo(job.p2c);

%% Plotting (with ORTools functions)
% ... is skipped for this example, check out example 2 for different plots

%% Reconstruct parent microstructure using the variant graph approach
%   - Reconstruct the microstructure with the variant graph based approach
job.calcVariantGraph('threshold',1.5*degree);
job.clusterVariantGraph('numIter',3);
job.calcParentFromVote;
% Plot the reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation)

%% Clean reconstructed grains
% Now clean the grains by: 
% - merging grains with similar orientation
job.mergeSimilar('threshold',5*degree);
% - merging small inclusions
job.mergeInclusions('maxSize',10);
% This is the cleaned reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation);

%% Get parent EBSD data
figure;
parentEBSD = job.ebsd;
plot(parentEBSD('Beta'),parentEBSD('Beta').orientations);
hold on;
plot(job.grains.boundary,'linewidth',3);
%% Variant analysis
% Plot the variant pole figure
figure;
plotPDF_variants(job);
% We can calculate variants and packets
job.calcVariants;
% and plot the variant map
plotMap_variants(job,'linewidth',3);
