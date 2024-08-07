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
% Phase map
plotMap_phases(job,'linewidth',1);
% Parent and child IPF maps
plotMap_IPF_p2c(job,vector3d.Z,'linewidth',1);

%% Reconstruct parent microstructure
%   - Reconstruct the microstructure with the variant graph based approach
job.calcVariantGraph('threshold',2.5*degree,'tolerance',2.5*degree)
job.clusterVariantGraph
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
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',2)
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
plotMap_variants(job,'grains','bc','linewidth',2); %Alternatively plot the grain data on top of the band contrast

% and plot the packet map
plotMap_packets(job,'linewidth',2);
% and plot the Bain group map
plotMap_bain(job,'linewidth',2,'colormap',magma);


%% ***** CHILD GRAIN PAIR ANALYSIS ***** 
% The following sections detail the various options available to users on 
% how to invoke and use the computeGrainPairs function
screenPrint('SegmentStart','Child grain pair analysis');
% To begin analysing child grain pairs, we first need the variants (and 
% packets,and Bain groups) on the EBSD level to be reconstructed as grains

% Choose CASE 1 or CASE 2 here
% CASE 1: Return child grain pair analysis results for the entire map
[newGrains,~] = computeVariantGrains(job);

% % CASE 2: Return child grain pair analysis results for a single parent grain
% % When using Case 2, please un-remark line 269 as well
% [newGrains,~] = computeVariantGrains(job,'parentGrainId',276); 
%

% Ensure the new grains only include child grains
newGrains = newGrains(job.csChild);






%% OPTION 1: Id based child grain pair analysis
% Compute the variant id child grain pairs
screenPrint('Step','Variant id child grain pair analysis');
out11 = computeGrainPairs(newGrains,'variants','plot');
% include similar neighbouring variant pairs for example, V1-V1; V2-V2
out12 = computeGrainPairs(newGrains,'include', 'plot', 'colormap',viridis);

% Compute the crystallographic packet id child grain pairs
% include similar neighbouring packet pairs for example, CP1-CP1; CP2-CP2
screenPrint('Step','Crystallographic packet id child grain pair analysis');
out13 = computeGrainPairs(newGrains,'packet','include','plot');

% Compute the Bain group id child grain pairs
screenPrint('Step','Bain group id child grain pair analysis');
out14 = computeGrainPairs(newGrains,'bain','plot');
%%






%% OPTION 2:  Groups of variant id for child grain pair analysis
screenPrint('Step','Groups of variant id child grain pair analysis');
% Calculate groups of variant Ids as per the analysis in the
% following references:
%
% N. Takayama, G. Miyamoto, T. Furuhara, Effects of transformation 
% temperature on variant pairing of bainitic ferrite in low carbon steel,
% Acta Materialia, Volume 60, Issue 5, 2012, Pages 2387-2396.
% (https://doi.org/10.1016/j.actamat.2011.12.018)
%
% H. Beladi, G.S. Rohrer, A.D. Rollett, V. Tari, P.D. Hodgson, The 
% distribution of intervariant crystallographic planes in a lath 
% martensite using five macroscopic parameters, Acta Materialia, 
% Volume 63, 2014, Pages 86-98.
% (https://doi.org/10.1016/j.actamat.2013.10.010)
%
% Define the groups of variant pairs
vGroupIds = {[1 2],...
    [1 3; 1 5],...
    [1 4],...
    [1 6],...
    [1 7],...
    [1 8],...
    [1 9; 1 19],...
    [1 10; 1 14],...
    [1 11; 1 13],...
    [1 12; 1 20],...
    [1 15; 1 23],...
    [1 16],...
    [1 17],...
    [1 18; 1 22],...
    [1 21],...
    [1 24]};
% ... and compute the groups of equivalent id child grain pairs
out21 = computeGrainPairs(newGrains,'variant','group',vGroupIds,'plot');

% For plotting individual outputs, use this block of script
figH = figure;
h = bar(out21.freq);
h.FaceColor = [162 20 47]./255;
set(gca,'FontSize',14);
xticks(1:16);
xlabelString = {'V2','V3,V5','V4','V6',...
    'V7','V8','V9,V19','V10,V14',...
    'V11,V13','V12,V20','V15,V23','V16',...
    'V17','V18,V22','V21','V24'};
xticklabels(xlabelString);
xtickangle(90);
xlabel('\bf Variant paired with V1');
ylabel('\bf Relative frequency [$\bf f$(g)]');
set(figH,'Name','Histogram: Groups of child grain variant pairs','NumberTitle','on');
drawnow;

% For plotting individual outputs, use this block of script
mapArea = prod(ebsd.gridify.size.*[ebsd.gridify.dx,ebsd.gridify.dy]);
boundaryFraction = out21.segLength./mapArea;
figH = figure;
h = bar(boundaryFraction);
h.FaceColor = [162 20 47]./255;
set(gca,'FontSize',14);
xticks(1:16);
xlabelString = {'V2','V3,V5','V4','V6',...
    'V7','V8','V9,V19','V10,V14',...
    'V11,V13','V12,V20','V15,V23','V16',...
    'V17','V18,V22','V21','V24'};
xticklabels(xlabelString);
xtickangle(90);
xlabel('\bf Variant paired with V1');
ylabel('\bf Boundary length density [$\bf \mu m / \mu m^{2}$]')
set(figH,'Name','Histogram: Groups of child grain variant pair boundary density','NumberTitle','on');
drawnow;
%%






%% OPTION 3: Equivalent variant id child grain pair analysis
screenPrint('Step','Equivalent (or other) variant id child grain pair analysis');
% Calculate equivalent variant Ids of martensitic variants (block
% boundaries) in steel microstructures as per the analysis in the
% following reference:
%
% S. Morito, A.H. Pham, T. Hayashi, T. Ohba, Block boundary analyses to
% identify martensite and bainite, Mater. Today Proc., Volume 2,
% Supplement 3, 2015, Pages S913-S916.
% (https://doi.org/10.1016/j.matpr.2015.07.430)
%
newGrains.prop.otherId = newGrains.variantId - (newGrains.packetId-1) * 24/4;
% IMPORTANT: Regardless of the formula used to compute other (or any
% equivalent) ids, the variable name on the LHS defined as
% "newGrains.prop.otherId" must not be changed.
out31 = computeGrainPairs(newGrains,'other','plot');

% Compute groups of equivalent variant id child grain pairs
screenPrint('Step','Groups of equivalent variant id child grain pair analysis');
% Define the four groups of equivalent variant id pairs
eqIds = {[1 2; 3 4; 5 6],...
    [1 3; 1 5; 2 4; 2 6; 3 5; 4 6],...
    [1 6; 2 3; 4 5],...
    [1 4; 2 5; 3 6]};
% ... and compute the groups of equivalent id child grain pairs
out32 = computeGrainPairs(newGrains,'other','group',eqIds, 'plot');
% The output of the variable 'out32' in the command window is:
% out32 = struct with fields:
%          freq: [0.1522,0.2473,0.1195,0.4810]
%     segLength: [0.1494,0.2427,0.1177,0.4902]
% Compare the above segment length values with the variant pair boundary
% fraction histogram from ORTools's pre-built function for equivalent
% variant pairs.
variantBoundaries_map = plotMap_KSvariantPairs(job,'linewidth',1.5);
% variantBoundaries_map = plotMap_KSvariantPairs(job,'parentGrainId',276,'linewidth',1.5);
%  -> Figure 20: variant pair boundary fraction histogram
%   4×2 table
%
%     eqVariants     Freq  
%     __________    _______
% 
%     V1-V2         0.14941
%     V1-V3(V5)     0.24271
%     V1-V6         0.11768
%     V1-V4          0.4902
% Notice that they are both exactly the same.
%%
