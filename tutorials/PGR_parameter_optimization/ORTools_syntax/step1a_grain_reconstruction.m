% Effect of child grain reconstruction on parent grain reconstruction
% Change min_angle for child grain reconstruction and perform parent grain
% reconstruction using the variant graph with default parameters
clearvars
home
close all
%% Parameter
min_angle = 3*degree;   %Threshold angle for grain reconstruction

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
fname1 = [pname '\Map Data 38 - EBSD Data Room Temperature.ctf']; % EXAMPLE FILE
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
KS = orientation.KurdjumovSachs(job.csParent,job.csChild);
NW = orientation.NishiyamaWassermann(job.csParent,job.csChild);
job.p2c = KS;
job.calcParent2Child;
ORinfo(job.p2c);

%Plot the disorientation between OR and GB misorientations
plotHist_OR_misfit(job,[KS,NW],'legend',{'K-S OR','N-W OR'});
plotMap_gB_misfit(job,'linewidth',2, 'maxColor',5);

%% Variant graph based reconstruction
plotMap_gB_prob(job,'linewidth',2,'threshold',2.5*degree,'tolerance',2.5*degree);
job.calcVariantGraph('threshold',2.5*degree,'tolerance',2.5*degree)
job.clusterVariantGraph;

figure; plot(job.grains,job.votes.prob(:,1)); mtexColorbar
job.calcParentFromVote('minProb',0.5)

% plot the result
plotMap_IPF_p2c(job,vector3d.Z,'parent');
%% Reconstruct remaining orientations
% ... excluded for testing effect of grain reconstruction on performance of
% variant grain reconstruction

% % compute the votes
% job.calcGBVotes('p2c','reconsiderAll')
% 
% % assign parent orientations according to the votes
% job.calcParentFromVote

%% Import validation data
fname2 = [pname '\Map Data 30 - EBSD Data 500C.ctf']; % EXAMPLE FILE
% create an EBSD variable containing the data
ebsdVal = EBSD.load(fname2,CS,'interface','ctf',...
  'convertEuler2SpatialReferenceFrame');

% this defines an ipf color key for the Iron bcc phase
ipfKey = ipfColorKey(ebsdVal('Iron fcc'));
ipfKey.inversePoleFigureDirection = vector3d.Z;

mtexFig = newMtexFigure('layout',[1,2]);
colors = ipfKey.orientation2color(ebsdVal('Iron fcc').orientations);
plot(ebsdVal('Iron fcc'),colors)
title("High temperature parent phase data (Validation)")
nextAxis
plot(job.parentGrains,job.parentGrains.meanOrientation)
title("Reconstructed parent phase data")



