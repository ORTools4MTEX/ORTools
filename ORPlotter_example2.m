
% *********************************************************************
%                        ORPlotter - Example 2
% *********************************************************************
% This script follows the same dataset and steps that are used to 
% demonstrate the reconstruction of beta parent grains from alpha 
% grains in the official MTEX example for phase transitions in titanium
% alloys. Here ORplotter's misorientation peak-fitter is used to determine
% the orientation relationship and advanced plotting functions are 
% employed to produce publication-ready plots.
% *********************************************************************
% Dr. Azdiar Gazder, 2020, azdiaratuowdotedudotau
% Dr. Frank Niessen, 2020, contactatfniessendotcom
% (Remove "dot" and "at" to make this email address valid)
% License provided in root directory
% If old style color seleUI needed, type the following and re-start Matlab
% setpref('Mathworks_uisetcolor', 'Version', 1);
clc; close all; clear all;
currentFolder;
screenPrint('StartUp','ORPlotter - Example 2');
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
%% Load data
mtexDataset = 'alphaBetaTitanium';
screenPrint('SegmentStart',sprintf('Loading MTEX example data ''%s''',mtexDataset));
ebsd = mtexdata(mtexDataset);
%% Compute, filter and smooth grains
screenPrint('SegmentStart','Computing, filtering and smoothing grains');
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',1.5*degree,...
  'removeQuadruplePoints');
%% Rename and recolor phases 
screenPrint('SegmentStart','Renaming and recoloring phases');
phaseNames = {'Gamma','AlphaP','Alpha','Beta','AlphaDP'};
ebsd = renamePhases(ebsd,phaseNames);
[ebsd,grains] = recolorPhases(ebsd,grains);
%% Finding the orientation relationship
screenPrint('SegmentStart','Finding the orientation relationship(s)');
job = parentGrainReconstructor(ebsd,grains,Ini.cifPath);
% Use the peak fitter in the pop-up menu
%     - Adjust the threshold to include only the largest peak
%     - Compute the OR by "Maximum f(g)"
job = defineORs(job);
%% Plotting (with ORPlotter functions)
screenPrint('SegmentStart','Plotting some ORPlotter maps');
% Phase map
plotMap_phases(job,'linewidth',1);
% Parent-child grain boundary misorientation map
plotMap_gB_p2c(job,'linewidth',1);
% Child-child grain boundary misorientation map
plotMap_gB_c2c(job,'linewidth',1);
% Parent and child IPF maps
plotMap_IPF_p2c(job,vector3d.Z,'linewidth',1);
% Plot parent-child and child-child OR boundary disorientation map
plotMap_gB_misfit(job,'linewidth',1);
% Plot parent-child and child-child OR boundary probability map
plotMap_gB_prob(job,'linewidth',1);
% Plot inverse pole figures for parent-child and child-child boundary
% disorientations
plotIPDF_gB_misfit(job);
% Plot inverse pole figures for parent-child and child-child boundary 
% probabilities
plotIPDF_gB_prob(job);
%% Compute parent orientations from triple junctions
job.calcTPVotes('numFit',2);
job.calcParentFromVote('strict', 'minFit',2.5*degree,...
                                 'maxFit',5*degree,'minVotes',2);
figure;
plot(job.parentGrains, job.parentGrains.meanOrientation,'linewidth',1);
%% Grow parent grains at grain boundaries by voting algorithm
job.calcGBVotes('noC2C');
job.calcParentFromVote('minFit',5*degree);
% Plot resulting reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',1);
%% Clean reconstructed grains
% merge grains with similar orientation
job.mergeSimilar('threshold',5*degree);
% merge small inclusions into larger grains
job.mergeInclusions('maxSize',50);
% Plot the cleaned reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation)
%% Variant analysis                                
% Calculate variants and packets
job.calcVariants;
% Plot variant pole figure
plotPDF_variants(job);
% Variant map (ORPlotter function)
plotMap_variants(job,'linewidth',3);
% Packet map (ORPlotter function)
plotMap_packets(job,'linewidth',3);
%% Reconstruct parent EBSD 
parentEBSD = job.calcParentEBSD;
figure;
plot(parentEBSD(job.csParent),parentEBSD(job.csParent).orientations);
hold on; 
plot(job.grains.boundary,'lineWidth',3)

