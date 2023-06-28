% *********************************************************************
%                        ORTools - Example 9
% *********************************************************************
% Habit plane determination from a lath martensite EBSD map
% *********************************************************************
home; close all; clear variables;
currentFolder;
set(0,'DefaultFigureWindowStyle','normal');
screenPrint('StartUp','ORTools - Example 9');
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

%% Compute the habit plane
screenPrint('SegmentStart','Compute the habit plane');
% Check the research paper for the theoretical background of the methods
% https://github.com/ORTools4MTEX/ORTools/blob/develop/doc/Nyyss%C3%B6nen_Gazder_Hielscher_Niessen_2023.pdf

%Let's try the radon-based approach (on pixelised EBSD data) ...
[hPlane1,statistics1] =  computeHabitPlane(job,'Radon','minClusterSize',50,'plotTraces');
%... and the shape-based approach (on reconstructed grain data)
[hPlane2,statistics2] =  computeHabitPlane(job,'Shape','minClusterSize',50,'reliability',0.5,'plotTraces');
%The histogram approach (on recosntructed grain data) using a different
%colormap and trace color ...
[hPlane3,statistics3] =  computeHabitPlane(job,'Hist','minClusterSize',50,'reliability',0.25,'plotTraces','colormap',jet,'linecolor','w');
%... and the calliper approach (on reconstructed grain data) for a single
%parent grain
[~,ind_maxGrain] = max(job.grains.area);
[hPlane4,~] =  computeHabitPlane(job,'calliper','minClusterSize',20,...
    'parentGrainId',ind_maxGrain,...
    'plotTraces','noFrame','noScalebar');