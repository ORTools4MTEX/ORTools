
% *********************************************************************
%                        ORTools - Example 2
% *********************************************************************
% Reconstruction of beta parent grains from alpha in titanium alloys. 
% Find the detailed MTEX version on the details of the reconstruction here:
% https://mtex-toolbox.github.io/TiBetaReconstruction.html
% *********************************************************************
% Dr. Azdiar Gazder, 2020, azdiaratuowdotedudotau
% Dr. Frank Niessen, 2020, contactatfniessendotcom
% (Remove "dot" and "at" to make this email address valid)
% *********************************************************************
clc; close all; clear all;
currentFolder;
screenPrint('StartUp','ORTools - Example 2');
%% Initialize MTEX
% Startup and set some settings
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
%% Load data
% Let's open the MTEX dataset on alpha and beta titanium
mtexDataset = 'alphaBetaTitanium';
screenPrint('SegmentStart',sprintf('Loading MTEX example data ''%s''',mtexDataset));
ebsd = mtexdata(mtexDataset);
%% Compute, filter and smooth grains
screenPrint('SegmentStart','Computing, filtering and smoothing grains');
% Grains are calculated with a 1.5° threshold
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',1.5*degree,...
  'removeQuadruplePoints');
%% Rename and recolor phases 
screenPrint('SegmentStart','Renaming and recoloring phases');
phaseNames = {'Gamma','AlphaP','Alpha','Beta','AlphaDP'};
% Rename "Ti (BETA) to "Beta"and "Ti (alpha)" to "Alpha"
ebsd = renamePhases(ebsd,phaseNames);
% Choose your favourite colors
[ebsd,grains] = recolorPhases(ebsd,grains);
%% Finding the orientation relationship
screenPrint('SegmentStart','Finding the orientation relationship(s)');
% Choose Beta as a parent and Alpha as a child phase in the transition
job = setParentGrainReconstructor(ebsd,grains,Ini.cifPath);
% Use the peak fitter in the pop-up menu
%     - Adjust the threshold to include only the largest peak
%     - Compute the OR by "Maximum f(g)"
job = defineORs(job);
% Let us check the disorientation and compare it with the Burgers OR
plotHist_ORMisfit(job,orientation.Burger(job.csParent, job.csChild));
xlim([0,10]);
%     - The misfit with Burgers OR and the experimental OR is almost
%     identical
%% Plotting (with ORTools functions)
screenPrint('SegmentStart','Plotting some ORTools maps');
% Let's use some of the ORTools functions to visualize the determined OR
% and its relation to the microstructure

% Phase map
plotMap_phases(job,'linewidth',1);
%       - The microstructure consists of 99.75 % alpha 

% Parent and child IPF maps
plotMap_IPF_p2c(job,vector3d.Z,'linewidth',1,'child')
%       - We can visually recognize the prior beta grains

% Child-child grain boundary misorientation map
plotMap_gB_c2c(job,'linewidth',1);
%       - Alpha of same prior beta grain seem to have ~58° misorientation

% Plot a map of the OR boundary disorientation, or misfit
plotMap_gB_misfit(job,'linewidth',1.5, 'maxColor', 10);
%       - A threshold of 10° shows where the prior beta boundaries are

% Plot parent-child and child-child OR boundary probability map
plotMap_gB_prob(job,'linewidth',1.5);
%       - This is also manifested in the OR probability map

% We can plot the OR and boundary misorientation axes and color the 
% experimental points according to their disorientation angle from the OR 
% We plot the 
%       - parent-child misorientation axes in the parent basis
%       - parent-child misorientation axes in the child basis
%       - and the child-child misorientation axes in the child basis
plotIPDF_gB_misfit(job);

% And we can do the same for the OR probability
plotIPDF_gB_prob(job);
%% Compute parent orientations from triple junctions
% We can use a voting algorithm which votes for a parent orientation at
% triple points of child grains
job.calcTPVotes('numFit',2);
% and calcualte parent orientations based on this vote
job.calcParentFromVote('strict', 'minFit',2.5*degree,...
                                 'maxFit',5*degree,'minVotes',2);
%Let's plot them
figure;
plot(job.parentGrains, job.parentGrains.meanOrientation,'linewidth',1.5);
%% Grow parent grains at grain boundaries by voting algorithm
% We can then let the parent grains grow into the child grains by a voting
% algorithm
job.calcGBVotes('noC2C');
job.calcParentFromVote('minFit',5*degree);
% This is the resulting reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',1.5);
%% Clean reconstructed grains
% We now merge grains with similar orientation
job.mergeSimilar('threshold',5*degree);
% and merge small inclusions into larger grains
job.mergeInclusions('maxSize',50);
% and then plot the cleaned reconstructed parent microstructure
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',1.5)
%% Variant analysis    
% Let's plot the variant pole figure
figure; 
plotPDF_variants(job);
% We can calculate variants and packets
job.calcVariants;
% and plot the variant map
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

%% Check the beta grains interactively by clicking on them
grainClick(job,parentEBSD);
%grainClick(job,parentEBSD,'grains');    %Plot grain data instead
