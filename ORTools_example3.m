
% *********************************************************************
%                        ORTools - Example 3
% *********************************************************************
% Using the parent-child misorientation peak fitting GUI to investigate 
% multiple ORs in an alpha-beta titanium alloy 
% *********************************************************************
% Dr. Azdiar Gazder, 2020, azdiaratuowdotedudotau
% Dr. Frank Niessen, 2020, contactatfniessendotcom
% (Remove "dot" and "at" to make this email address valid)
% *********************************************************************
home; close all; clear variables;
currentFolder;
screenPrint('StartUp','ORTools - Example 3');
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
Ini.phaseNames = {'Gamma','AlphaP','Epsilon','Beta','Alpha','AlphaDP'};
%% Load data
mtexDataset = 'alphaBetaTitanium';
screenPrint('SegmentStart',sprintf('Loading MTEX example data ''%s''',mtexDataset));
ebsd = mtexdata(mtexDataset);
%% Compute, filter and smooth grains
screenPrint('SegmentStart','Computing, filtering and smoothing grains');
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',3*degree,...
  'removeQuadruplePoints');
%% Rename and recolor phases 
screenPrint('SegmentStart','Renaming and recoloring phases');
% Rename "Ti (BETA) to "Beta"and "Ti (alpha)" to "Alpha"
ebsd = renamePhases(ebsd,Ini.phaseNames);
% Choose your favourite colors
ebsd = recolorPhases(ebsd);
%% Define the transformation system
screenPrint('SegmentStart','Finding the orientation relationship(s)');
% Choose Beta as a parent and Alpha as a child phase in the transition
job = setParentGrainReconstructor(ebsd,grains,Ini.cifPath);
%% Plot initial maps
% Plotting the phase map 
plotMap_phases(job,'linewidth',1);
%       - The microstructure consists of 99.75 % alpha 

% Child-child grain boundary misorientation map 
plotMap_gB_c2c(job,'linewidth',1.5);
%       - Alpha of same prior beta grain seem to have ~58° misorientation

%% Fit multiple ORs
% We can fit the OR from alpha-beta boundaries even though only 0.25 % 
% beta are present
%
% Use the peak fitter in the pop-up menu
%     - We see that there are two misorientation peaks
%           - Set the threshold to include them both in the fitting
%     - Compute ORs by "Maximum f(g)"
%     - Choose to export "All ORs" - defineOR returns a cell array job{:}
job = defineORs(job);
% The command window shows us that two OR's are at work:
%  - OR1: (110)_beta||(1000)_alpha [1-11]_beta||[-12-10]_alpha 
%  - OR2: (11-1)_beta||(-1-100)_alpha [0-1-1]_beta||[000-3]_alpha 

dori = angle(job{1}.p2c,job{2}.p2c)/degree
%       - We have a disorientation angle of 30° between the ORs 

%% Plot the inverse pole figure
% Plot inverse pole figures for parent-child and child-child boundary
% disorientations
% We color the boundaries up to 5° disorientation to emphasize the effects
plotIPDF_gB_misfit(job{1},'maxColor',5);
%       - OR 1 belongs to a distinct alpha-beta boundary miso axis
%       - Few of the alpha-alpha boundary misorientations match the OR

plotIPDF_gB_misfit(job{2},'maxColor',5);
%       - OR 2 belongs to a distinct alpha-beta boundary miso axis
%       - The majority of alpha-alpha boundary misorientations match the OR
%       - Misorientaitons not fulfilled by OR2 also don't fit to OR1
%          - may be part of non-OR related prior-beta boundaries

%% Analyze the microstructure by plotting maps
% Plot parent-child and child-child OR boundary disorientation map
% We color the boundaries up to 5° disorientation to emphasize the effects
plotMap_gB_misfit(job{1},'linewidth',1.5,'maxColor',5);
%       - Many regions have >= 5° disorientation from OR 1
%       - Locally OR 1 seems to work well 

plotMap_gB_misfit(job{2},'linewidth',1.5,'maxColor',5);
%       - Most regions have <= 2° disorientation from OR 2
%       - Locally OR 2 seems to not work

% It follows that OR2 
%   OR2: (11-1)_beta||(-1-100)_alpha [0-1-1]_beta||[000-3]_alpha 
% is the dominating OR


% Plot parent-child and child-child OR boundary probability map
% The same trends can be shown by plotting the OR probability, showing with
% which probability a boundary belongs to an OR in a range of 0 to 1
plotMap_gB_prob(job{1},'linewidth',1.5);

plotMap_gB_prob(job{2},'linewidth',1.5);

%% Save images
saveImage(Ini.imagePath);

%% Summary
BurgersOR = orientation.Burgers(job{2}.csParent,job{2}.csChild);
dori = angle(job{2}.p2c,BurgersOR)/degree

% We can see that the 2nd OR is equivalent to the common Burgers OR
% in Titanium alloys (misfit < 0.4°)
