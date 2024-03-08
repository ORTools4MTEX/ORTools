% Effect of child grain reconstruction using the unit cell method on parent grain reconstruction
%
% Change min_angle for child grain reconstruction and perform parent grain
% reconstruction using the variant graph with default parameters
clearvars
home
close all
%% Parameter
min_angle = 1.5*degree;   %Threshold angle for grain reconstruction

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


%% Plot Child Grain Map (Check it imported correctly)
% this defines an ipf color key for the Iron bcc phase
ipfKey = ipfColorKey(ebsd('Iron bcc (old)'));
ipfKey.inversePoleFigureDirection = vector3d.Z;

% this is the colored fundamental sector
figure;
plot(ipfKey)
colors = ipfKey.orientation2color(ebsd('Iron bcc (old)').orientations);
figure;
plot(ebsd('Iron bcc (old)'),colors)

%% Child Grain Reconstruction
% grain reconstruction
dx = sqrt(sum((max(ebsd.unitCell)-min(ebsd.unitCell)).^2));
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'), 'angle', min_angle,'boundary','tight','maxDist',dx,'unitCell');
ebsd(grains(grains.grainSize < 3)) = [];
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle', min_angle,'boundary','tight','maxDist',dx,'unitCell');
grains = smooth(grains,5);

% plot the data and the grain boundaries
figure;
plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,'figSize','large')
hold on
plot(grains.boundary,'linewidth',2)
hold off

%% Set up Reconstructor
% set up the job
job = parentGrainReconstructor(ebsd,grains);

% initial guess for the parent to child orientation relationship
job.p2c = orientation.KurdjumovSachs(job.csParent, job.csChild);

%% Optimize OR
% close all
figure;
histogram(job.calcGBFit./degree,'BinMethod','sqrt')
xlabel('disorientation angle')

job.calcParent2Child

hold on
histogram(job.calcGBFit./degree,'BinMethod','sqrt')
hold off

% compute the misfit for all child to child grain neighbours
[fit,c2cPairs] = job.calcGBFit;

% select grain boundary segments by grain ids
[gB,pairId] = job.grains.boundary.selectByGrainId(c2cPairs);

% plot the child phase
figure;
plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,'figSize','large','faceAlpha',0.5)

% and on top of it the boundaries colorized by the misfit
hold on;
% scale fit between 0 and 1 - required for edgeAlpha
plot(gB, 'edgeAlpha', (fit(pairId) ./ degree - 2.5)./2 ,'linewidth',2);
hold off

%% Variant graph based reconstruction
job.calcVariantGraph('threshold',2.5*degree,'tolerance',2.5*degree)
job.clusterVariantGraph;
figure;
plot(job.grains,job.votes.prob(:,1))
mtexColorbar

job.calcParentFromVote('minProb',0.5)

% plot the result
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation)

%% Reconstruct remaining orientations
% ... excluded for testing effect of grain reconstruction on performance of
% variant grain reconstruction

% % compute the votes
% job.calcGBVotes('p2c','reconsiderAll')
% 
% % assign parent orientations according to the votes
% job.calcParentFromVote

%% Import validation data
fname2 = [pname '\Map Data 30 - EBSD Data 500C.ctf'];
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



