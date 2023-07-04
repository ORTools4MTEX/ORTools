% *********************************************************************
%                        ORTools - Example 10
% *********************************************************************
% Child grain pair analysis for a lath martensite EBSD map
% *********************************************************************
home; close all; clear variables;
currentFolder;
set(0,'DefaultFigureWindowStyle','normal');
screenPrint('StartUp','ORTools - Example 10');
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
% ... Check out examples 1 and 7 for more analysis features regarding the
% fitted OR
%% Plotting (with ORTools functions)
% ... Check out examples 1 and 7 for different plotting options (skipped
% here)

%% Reconstruct parent microstructure
%   - Reconstruct the microstructure with the variant graph based approach
job.calcVariantGraph('threshold',2.5*degree,'tolerance',2.5*degree,'mergeSimilar')
job.clusterVariantGraph
job.calcVariantGraph('threshold',2.5*degree,'tolerance',2.5*degree)
job.clusterVariantGraph('includeSimilar')
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
%% Get parent EBSD data
figure;
parentEBSD = job.ebsd;
plot(parentEBSD('Gamma'),parentEBSD('Gamma').orientations);
hold on;
plot(job.grains.boundary,'linewidth',2);
hold off;
%% Variant analysis
% We can calculate variants and packets
job.calcVariants;
% and plot the variant map
plotMap_variants(job,'linewidth',2);
% and plot the packet map
plotMap_packets(job,'linewidth',2);
% and plot the Bain group map
plotMap_bain(job,'linewidth',2,'colormap',magma);


%% Child grain pair analysis
screenPrint('SegmentStart','Child grain pair analysis');
% To begin analyzing child grain pairs, we need the variants (and packets, 
% and Brain groups) on the EBSD level to be reconstructed as grains
[variantGrains,ebsdC] = computeVariantGrains(job);

%% Compute the variant id child grain pairs
screenPrint('Step','Variant id child grain pair analysis');
out1 = computeGrainPairs(variantGrains,'variants');
% include similar neighbouring variant pairs for example, V1-V1; V2-V2
out2 = computeGrainPairs(variantGrains,'include');

%% Compute the crystallographic packet id child grain pairs
% include similar neighbouring packet pairs for example, CP1-CP1; CP2-CP2
screenPrint('Step','Crystallographic packet id child grain pair analysis');
out3 = computeGrainPairs(variantGrains,'packet','include');

%% Compute the Bain group id child grain pairs
screenPrint('Step','Bain group id child grain pair analysis');
out4 = computeGrainPairs(variantGrains,'bain');

%% Compute the equivalent id child grain pairs
screenPrint('Step','Equivalent (or other) group id child grain pair analysis');
% Calculate equivalent variant Ids of martensitic variants (block 
% boundaries) in steel microstructures as per the analysis in the 
% following reference:
% S. Morito, A.H. Pham, T. Hayashi, T. Ohba, Block boundary analyses to
% identify martensite and bainite, Mater. Today Proc., Volume 2,
% Supplement 3, 2015, Pages S913-S916.
% (https://doi.org/10.1016/j.matpr.2015.07.430)
variantGrains.prop.otherId = variantGrains.variantId - (variantGrains.packetId-1) * 24/4;
% IMPORTANT: Regardless of the formula used to compute equivalent ids, the 
% variable name on the LHS defining an "otherId" must not be changed.
out5 = computeGrainPairs(variantGrains,'other');

%% Compute groups of equivalent id child grain pairs
screenPrint('Step','Groups of equivalent id child grain pair analysis');
% Define the four groups of equivalent variant pairs
eqIds = {[1 2; 3 4; 5 6],...
    [1 3; 1 5; 2 4; 2 6; 3 5; 4 6],...
    [1 6; 2 3; 4 5],...
    [1 4; 2 5; 3 6]};
% ... and compute the groups of equivalent id child grain pairs
out6 = computeGrainPairs(variantGrains,'other','equivalent',eqIds)
% The output of the variable 'out6' in the command window is:
% out6 = struct with fields:
%          freq: [0.1503 0.2495 0.1211 0.4790]
%     segLength: [0.1473 0.2452 0.1192 0.4883]
% Compare the above segment length values with the variant pair boundary 
% fraction histogram from ORTools's pre-built function for equivalent 
% variant pairs.
variantBoundaries_map = plotMap_variantPairs(job,'linewidth',1.5);
%  -> Figure 9: variant pair boundary fraction histogram
%   4×2 table
% 
%     eqVariants     Freq  
%     __________    _______
% 
%     V1-V2         0.14733
%     V1-V3(V5)     0.24516
%     V1-V6         0.11921
%     V1-V4          0.4883
% Notice that they are both exactly the same.

