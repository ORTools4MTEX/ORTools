
% *********************************************************************
%                        ORTools - Example 6
% *********************************************************************
% Two-stage parent grain reconstruction in a TWIP-TRIP steel
% *********************************************************************
% Dr. Azdiar Gazder, 2021, azdiaratuowdotedudotau
% Dr. Frank Niessen, 2021, contactatfniessendotcom
% (Remove "dot" and "at" to make this email address valid)
% *********************************************************************
home; close all; clear variables;
currentFolder;
screenPrint('StartUp','ORTools - Example 6');
%% Initialize MTEX
% startup and set some settings
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
Ini.phaseNames = {'Gamma','AlphaP','Epsilon'};
%% Import EBSD data and save current file name
ebsd = loadEBSD_ctf([Ini.ebsdPath,'TRWIPsteel2.ctf'],'convertSpatial2EulerReferenceFrame');
ebsd = ebsd('indexed');
%% Compute, filter and smooth grains
screenPrint('SegmentStart','Computing, filtering and smoothing grains');
% Grains are calculated with a 3° threshold
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',3*degree,...
  'removeQuadruplePoints');
grains = grains.smooth(3);
%% Rename and recolor phases 
screenPrint('SegmentStart','Renaming and recoloring phases');
%Rename "Iron fcc" to "Gamma", "Iron bcc (old)" to "AlphaP" and 
%"Epsilon_Martensite" to "Epsilon"
ebsd = renamePhases(ebsd,Ini.phaseNames);
%Choose your favourite colors
ebsd = recolorPhases(ebsd);
%% Plot phase map
figure;
plot(ebsd); 
hold on
plot(grains.boundary,'linewidth',2);
%% Define the transformation system
screenPrint('SegmentStart','Finding the orientation relationship(s)');
% Choose "Epsilon" as a parent and "AlphaP" as a child phase
job1 = setParentGrainReconstructor(ebsd,grains,Ini.cifPath);
%% Plot parent and child IPF maps
plotMap_IPF_p2c(job1,vector3d.Z,'linewidth',2);

% ************** %
%% Define and check the OR EPSILON - ALPHA
% We define the Burgers OR between Epsilon and AlphaP
job1.p2c = orientation.Burgers(job1.csParent,job1.csChild);
plotHist_OR_misfit(job1);
job1.calcParent2Child('p2c');
plotHist_OR_misfit(job1);
%% Check the fit with the OR locally
% Plot parent-child and child-child OR boundary disorientation map
% We color the boundaries up to 5° disorientation to emphasize the effects
plotMap_gB_misfit(job1,'linewidth',1.5,'maxColor',5);
% The fit is quite good most places
%% Reconstruct alphaP
for k = 1:3
  job1.calcGBVotes('p2c','threshold',k*2.5*degree);
  job1.calcParentFromVote;
end
plotMap_IPF_p2c(job1,vector3d.Z,'linewidth',2,'parent');
%% Merge similar
job1.mergeSimilar('threshold',7.5*degree);
plotMap_IPF_p2c(job1,vector3d.Z,'linewidth',2,'parent');

% ************** %
%% Define and check the OR GAMMA - EPSILON
% Choose "Gamma" as a parent and "Epsilon" as a child phase
job2 = setParentGrainReconstructor(job1.ebsd,job1.grains,Ini.cifPath);
% We define the Shoji Nishiyama OR between Gamma and Epsilon
job2.p2c = orientation.ShojiNishiyama(job2.csParent,job2.csChild);
plotHist_OR_misfit(job2);
job2.calcParent2Child('p2c');
plotHist_OR_misfit(job2);
%% Check the fit with the OR locally
% Plot parent-child and child-child OR boundary disorientation map
% We color the boundaries up to 5° disorientation to emphasize the effects
plotMap_gB_misfit(job2,'linewidth',1.5,'maxColor',5);
% The fit is quite good most places
%% Reconstruct Gamma
for k = 1:3
  job2.calcGBVotes('p2c','threshold',k*2.5*degree);
  job2.calcParentFromVote;
end
plotMap_IPF_p2c(job2,vector3d.Z,'linewidth',2,'parent');
%% Merge similar
job2.mergeSimilar('threshold',7.5*degree);
plotMap_IPF_p2c(job2,vector3d.Z,'linewidth',2,'parent');

% ************** %
%% Variant analysis Gamma-Epsilon
plotPDF_variants(job2);
% Then calculate the variant IDs of all alpha grains ...
job2.calcVariants;
% ... and plot them
plotMap_variants(job2,'linewidth',3);

% ************** %
%% Variant analysis Epsilon-AlphaP
plotPDF_variants(job1);
% Then calculate the variant IDs of all alpha grains ...
job1.calcVariants;
% ... and plot them
plotMap_variants(job1,'linewidth',3);

%% Save images
saveImage(Ini.imagePath);

%% Grain Click
grainClick(job2,'noScalebar','noFrame');
%% Summary
% This example has shown two-stage parent grain reconstruction in a 
% TWIP-TRIP steel. In the first stage, alphaP martensite was reverted to 
% epsilon martensite. In the second stage, epsilon martensite was reverted
% to parent austenite.

