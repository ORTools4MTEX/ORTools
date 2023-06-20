
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
%   - Reconstruct the microstructure with a graph-based approach
job.calcGraph('threshold',2.5*degree,'tolerance',2.5*degree);
job.clusterGraph('inflationPower',1.6)
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

%% Compute the habit plane
screenPrint('SegmentStart','Compute the habit plane');
[hPlane,statistics] =  computeHabitPlane(job,'Shape','minClusterSize',50);
plotMap_habitPlane(job,hPlane);
% statistics('Deviation')
% statistics('meanDeviation')
% statistics('stdDeviation')
% statistics('Quantiles')
