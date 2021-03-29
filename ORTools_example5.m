
% *********************************************************************
%                        ORTools - Example 5
% *********************************************************************
% Using the OR peak fitter to deconvolute multiple ORs in a TRIP-TWIP (TRWIP) alloy
% *********************************************************************
% Dr. Azdiar Gazder, 2020, azdiaratuowdotedudotau
% Dr. Frank Niessen, 2020, contactatfniessendotcom
% (Remove "dot" and "at" to make this email address valid)
% *********************************************************************
clc; close all; clear all;
currentFolder;
screenPrint('StartUp','ORTools - Example 5');
%% Initialize MTEX
% startup and set some settings
startup_mtex;
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize',14);   
% Default directories - Do not modify
Ini.dataPath = [pwd,'\data\'];
Ini.cifPath = [Ini.dataPath,'input\cif\'];
Ini.ebsdPath = [Ini.dataPath,'input\ebsd\'];
Ini.texturePath = [Ini.dataPath,'output\texture\'];
Ini.imagePath = [Ini.dataPath,'output\images\'];
Ini.phaseNames = {'Gamma','AlphaP','Epsilon','Beta','Alpha','AlphaDP'};
%% Import EBSD data and save current file name
ebsd = loadEBSD_ctf([Ini.ebsdPath,'TRWIPsteel.ctf'],'convertSpatial2EulerReferenceFrame');
ebsd = ebsd('indexed');
%% Compute, filter and smooth grains
screenPrint('SegmentStart','Computing, filtering and smoothing grains');
% Grains are calculated with a 3° threshold
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',3*degree,...
  'removeQuadruplePoints');
%% Rename and recolor phases 
screenPrint('SegmentStart','Renaming and recoloring phases');
%Rename "Iron fcc" to "Gamma", "Iron bcc (old)" to "AlphaP" and 
%"Epsilon_Martensite" to "Epsilon"
ebsd = renamePhases(ebsd,Ini.phaseNames);
%Choose your favourite colors
[ebsd,grains] = recolorPhases(ebsd,grains);
%% Define the transformation system
screenPrint('SegmentStart','Finding the orientation relationship(s)');
% Choose "Gamma" as a parent and "Alpha" as a child phase
job = setParentGrainReconstructor(ebsd,grains,Ini.cifPath);
%% Plot initial maps
% Plotting the phase map 
plotMap_phases(job,'linewidth',2);
%       - Epsilon has formed from Gamma and AlphaP from Epsilon

% Parent and child IPF maps
plotMap_IPF_p2c(job,vector3d.Z,'linewidth',2);
%       - Multiple gamma grains are covered

% Parent-child grain boundary misorientation map 
plotMap_gB_p2c(job,'linewidth',1.5);
%       - Misorientation mainly around ~45°

% Child-child grain boundary misorientation map 
plotMap_gB_c2c(job,'linewidth',1.5);
%       - Different misorientation angles are visible


%% Fit multiple ORs
% We can fit the OR from gamma-alpha boundary misorientations
%
% Use the peak fitter in the pop-up menu
%     - We see that there are two misorientation peaks
%           - Set the threshold to include them both in the fitting
%     - Compute ORs by "Maximum f(g)"
%     - Choose to export "All ORs" - defineOR returns a cell array job{:}
job = defineORs(job);
% The command window shows us that two ORs are at work:
%  - The first OR is showing no misorientation, or cube-on-cube OR

% Let us check the disorientation of alphaP child-child boundaries and 
% compare it with K-S and N-W
plotHist_OR_misfit(job,[orientation.KurdjumovSachs(job.csParent,job.csChild), ...
                       orientation.NishiyamaWassermann(job.csParent,job.csChild)],...
                       'legend',{'K-S','N-W'});
return
%% Plot the inverse pole figure
% Plot inverse pole figures for parent-child and child-child boundary
% disorientations
% We color the boundaries up to 5° disorientation to emphasize the effects
plotIPDF_gB_misfit(job{1},'maxColor',5);
%       - The misorientation axis is scattered because of the 0° angle
%       - The disorientation is quite high

plotIPDF_gB_misfit(job{2},'maxColor',5);
%       - OR 2 is the governing OR with a good match for the misorientation
%         axis and the disorientation angle

%% Analyze the microstructure by plotting maps
% Plot parent-child and child-child OR boundary disorientation map
% We color the boundaries up to 5° disorientation to emphasize the effects
plotMap_gB_misfit(job{1},'linewidth',1.5,'maxColor',5);
%       - Only few small grains of Alpha with no connection to Epsilon
%         match

plotMap_gB_misfit(job{2},'linewidth',1.5,'maxColor',5);
%       - Most grains apart from the small grains of OR 1 match

% Seeing that the OR 1 describes a cube-on-cube misorientation of small
% alphaP grains in gamma, these are identified as misindexed points, i.e.
% points belonging to gamma, but indexed as alpha - so let's clean this up

%% Merging misindexed gamma
% OR 1 has only variant, calcGBVotes finds the fit of that theoretical
% variant with the parent-child boundary misorientations
job{1}.calcGBVotes('noC2C','numfit',1);
% We transform all alpha grains that have a fit of <=5° to gamma
job{1}.calcParentFromVote('minFit',5*degree);
% We can see that the small grains have been transformed
figure;
plot(job{1}.parentGrains, job{1}.parentGrains.meanOrientation);
% We can merge them into the surrounding grains and check the  result
job{1}.mergeSimilar('threshold',5*degree);
figure;
plot(job{1}.parentGrains, job{1}.parentGrains.meanOrientation);
% Finally, we make a new ebsd map, with the misindexed alpha grains of OR1
% being transformed to gamma grains
ebsdCleaned = job{1}.calcParentEBSD;

%% Recomputing the grains from the new EBSD dataset
screenPrint('SegmentStart','Computing, filtering and smoothing grains');
[grains,ebsd.grainId] = calcGrains(ebsdCleaned,'threshold',3*degree,...
  'removeQuadruplePoints');
%% Making a new "job" containing the new EBSD data and grains
screenPrint('SegmentStart','Finding the orientation relationship(s)');
% Choose "Gamma" as a parent and "Alpha" as a child phase
job = setParentGrainReconstructor(ebsdCleaned,grains,Ini.cifPath);
% And enter the OR peak fitter again
job = defineORs(job);
% We can now see that the peak at 0° has disappeared.
% From here we can continue working with the second OR or explore the other
% smaller peaks to plot maps or reconstruct the parent microstructure
%% Save images
saveImage(Ini.imagePath);
%% Summary
% This example has shown how to identify different ORs and revert them
% individually. In the present case, we found an OR corresponding to a
% cube-on-cube orientation relationship, which was caused by misindexing
% gamma as alpha. We reverted these grains to gamma in order to clean the
% map. 
