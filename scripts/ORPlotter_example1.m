
% *********************************************************************
%                        ORPlotter - Example 1
% *********************************************************************
% This script follows the same dataset and steps that are used to 
% demonstrate the reconstruction of austenitic parent grains from martensite 
% grains in the official MTEX example for phase transitions in steels. Here 
% some of ORplotter's plotting functions are used to create 
% publication-ready plots.
% *********************************************************************
% Dr. Azdiar Gazder, 2020, azdiaratuowdotedudotau
% Dr. Frank Niessen, 2020, contactatfniessendotcom
% (Remove "dot" and "at" to make this email address valid)
% License provided in root directory
% If old style color seleUI needed, type the following and re-start Matlab
% setpref('Mathworks_uisetcolor', 'Version', 1);
clc; close all; clear all;
currentFolder;
screenPrint('StartUp','ORPlotter - Example 1');
%% Initialize MTEX
% startup and set some settings
startup_mtex;
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize',14);   
% Default directories - Do not modify
Ini.dataPath = [fileparts(mfilename('fullpath')),'\data\'];
Ini.cifPath = [Ini.dataPath,'input\cif\'];
Ini.ebsdPath = [Ini.dataPath,'input\ebsd\'];
Ini.texturePath = [Ini.dataPath,'output\texture\'];
%% Load data
mtexDataset = 'martensite';
screenPrint('SegmentStart',sprintf('Loading MTEX example data ''%s''',mtexDataset));
ebsd = mtexdata(mtexDataset);
%% Compute, filter and smooth grains
screenPrint('SegmentStart','Computing, filtering and smoothing grains');
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'), 'angle', 3*degree);
% remove small grains
ebsd(grains(grains.grainSize < 4)) = [];
% reidentify grains with small grains removed:
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',2*degree);
grains = smooth(grains,5);
%% Rename and recolor phases 
screenPrint('SegmentStart','Renaming and recoloring phases');
phaseNames = {'Gamma','AlphaP','Alpha'};
ebsd = renamePhases(ebsd,phaseNames);
[ebsd,grains] = recolorPhases(ebsd,grains);
%% Define and refine parent-to-child orientation relationship
screenPrint('SegmentStart','Define and refine parent-to-child OR');
job = parentGrainReconstructor(ebsd,grains,Ini.cifPath);
% initial guess for the parent to child orientation relationship
job.p2c = orientation.KurdjumovSachs(job.csParent, job.csChild);
% optimizing the parent child orientation relationship
job.calcParent2Child;
% get information about the determined OR
ORinfo(job.p2c);
%% Plotting (with ORPlotter functions)
screenPrint('SegmentStart','Plotting some ORPlotter maps');
% Phase map
plotMap_phases(job,'linewidth',2);
% Parent-child grain boundary misorientation map
plotMap_gB_p2c(job,'linewidth',2);
% Child-child grain boundary misorientation map
plotMap_gB_c2c(job,'linewidth',2);
% Parent and child IPF maps
plotMap_IPF_p2c(job,vector3d.Z,'linewidth',2);
% Plot parent-child and child-child OR boundary disorientation map
plotMap_gB_misfit(job,'linewidth',2);
% Plot parent-child and child-child OR boundary probability map
plotMap_gB_prob(job,'linewidth',2);
% Plot inverse pole figures for parent-child and child-child boundary
% disorientations
plotIPDF_gB_misfit(job);
% Plot inverse pole figures for parent-child and child-child boundary 
% probabilities
plotIPDF_gB_prob(job);
%% Reconstruct parent microstructure
job.calcGraph('threshold',2.5*degree,'tolerance',2.5*degree);
job.clusterGraph('inflationPower',1.6);
job.calcParentFromGraph;
% Plot reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',2);
%% Remove badly reconstructed clusters
% Plot misfit of reconstruction
figure;
plot(job.grains,job.grains.fit./degree,'linewidth',2);
setColorRange([0,5]);
mtexColorbar;
% Revert misfit > 5° and clusters < 15
job.revert(job.grains.fit > 5*degree | job.grains.clusterSize < 15)
% Plot the filtered reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation)
%% Fill in unreconstructed regions with voting algorithm
for k = 1:5 
  % compute votes
  job.calcGBVotes('noC2C');
  % compute parent orientations from votes
  job.calcParentFromVote('minFit',7.5*degree)
end
% Plot optimized reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation)
%% Clean reconstructed grains
% merge grains with similar orientation
job.mergeSimilar('threshold',7.5*degree);
% merge small inclusions into larger grains
job.mergeInclusions('maxSize',50);
% Plot the cleaned reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation)
%% Variant analysis
job.calcVariants;
% Plot variant pole figure
plotPDF_variants(job);
% Variant(s) map (ORPlotter function)
plotMap_variants(job,'linewidth',3);
% Packet(s) map (ORPlotter function)
plotMap_packets(job,'linewidth',3);


