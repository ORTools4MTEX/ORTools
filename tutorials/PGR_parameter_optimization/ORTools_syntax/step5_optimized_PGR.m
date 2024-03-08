% Final complete PGR with optimized parameters (... optimal for the example dataset - please find your own optimal parameters)
clearvars
home
close all
%% Parameter
min_angle = 1*degree;   %Threshold angle for grain reconstruction
% Tolerance and Threshold for calcVariantGraph
tol = 2;
threshold = 5;
% Alpha and Num Iter for MCL clustering
alpha = 1;
numIter = 8;

%% Specify Crystal and Specimen Symmetries
% crystal symmetry
CS = {... 
  'notIndexed',...
  crystalSymmetry('m-3m', [2.9 2.9 2.9], 'mineral', 'Iron bcc (old)', 'color', [0.53 0.81 0.98]),...
  crystalSymmetry('m-3m', [3.7 3.7 3.7], 'mineral', 'Iron fcc', 'color', [0.56 0.74 0.56])};

% plotting convention
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','intoPlane');

%% Specify File Names
% path to files
pname = '..\..\..\data\input\ebsd\Taylor_et_al_2024';

% which files to be imported
fname1 = [pname '\Map Data 38 - EBSD Data Room Temperature.ctf'];
%% Import the Data
% create an EBSD variable containing the data
ebsd = EBSD.load(fname1,CS,'interface','ctf',...
  'convertEuler2SpatialReferenceFrame');

%% Child Grain Reconstruction
% grain reconstruction
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'), 'angle', min_angle);

% remove small grains
ebsd(grains(grains.grainSize < 3)) = [];

% reidentify grains with small grains removed:
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',min_angle);
grains = smooth(grains,5);

%% Set up Reconstructor
% set up the job
job = setParentGrainReconstructor(ebsd,grains);
plotMap_IPF_p2c(job,vector3d.Z,'child');

% initial guess for the parent to child orientation relationship
job.p2c = orientation.KurdjumovSachs(job.csParent,job.csChild);
% Optimize OR
job.calcParent2Child;

%% Reconstruct Parent Austenite
job.calcVariantGraph('threshold',threshold*degree,'tolerance',tol*degree)
job.clusterVariantGraph('inflationPower',alpha,'numIter',numIter);
job.calcParentFromVote('minProb',0.5)
plotMap_IPF_p2c(job,vector3d.Z,'parent');

%% Grow austenite into empty regions
job.calcGBVotes('p2c','reconsiderAll')
job.calcParentFromVote
plotMap_IPF_p2c(job,vector3d.Z,'parent');

%% Merge Similarly oriented grains
job.mergeSimilar('threshold',7.5*degree);
plotMap_IPF_p2c(job,vector3d.Z,'parent','linewidth',2);

%% Merge inclusions
job.mergeInclusions('maxSize',100);
plotMap_IPF_p2c(job,vector3d.Z,'parent','linewidth',2);

%% Validation
fname2 = [pname '\Map Data 30 - EBSD Data 500C.ctf'];
% create an EBSD variable containing the data
ebsdVal = EBSD.load(fname2,CS,'interface','ctf',...
  'convertEuler2SpatialReferenceFrame');

% this defines an ipf color key for the Iron bcc phase
ipfKey = ipfColorKey(ebsdVal('Iron fcc'));
ipfKey.inversePoleFigureDirection = vector3d.Z;
colors = ipfKey.orientation2color(ebsdVal('Iron fcc').orientations);
figure;
plot(ebsdVal('Iron fcc'),colors)


