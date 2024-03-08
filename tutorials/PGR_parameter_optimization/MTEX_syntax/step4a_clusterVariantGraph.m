% Systematic mapping of the effect of clustering parameters on the final
% PGR result
clearvars
home
close all
%% Parameter
min_angle = 1*degree;   %Threshold angle for grain reconstruction
% Tolerance and Threshold for calcVariantGraph
tol = 2;
threshold = 5;
% Different settings for Alpha (Inflation Parameter) and Num Iter for MCL clustering
alpha = [1,1.05,1.1,1.2,1.4];
numIter = [5,5,5,5,5];

% % Different settings for Alpha (Inflation Parameter) and Num Iter for MCL clustering
% alpha = [1,1.05,1,1.05];
% numIter = [8,8,10,10];

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
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'), 'angle', min_angle);

% remove small grains
ebsd(grains(grains.grainSize < 3)) = [];

% reidentify grains with small grains removed:
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',min_angle);
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
job.p2c = orientation.KurdjumovSachs(job.csParent,job.csChild);
% Optimize OR
job.calcParent2Child;

%% Check reconstructed microstructure for different clustering parameters
ipfKey = ipfColorKey(ebsd('Iron fcc'));
ipfKey.inversePoleFigureDirection = vector3d.Z;
job.calcVariantGraph('threshold',threshold*degree,'tolerance',tol*degree)
for ii = 1:length(alpha)
    job.clusterVariantGraph('inflationPower',alpha(ii),'numIter',numIter(ii));
    job.calcParentFromVote('minProb',0.5)
    colors = ipfKey.orientation2color(job.parentGrains.meanOrientation);
    figure;
    plot(job.parentGrains,colors)
    set(gcf,'name',strcat(get(gcf,'name'),' - Alpha: ',num2str(alpha(ii)), ", NumIter: ", num2str(numIter(ii))));
    job.revert;
end

%% Validation
fname2 = [pname '\Map Data 30 - EBSD Data 500C.ctf']; % EXAMPLE FILE
% create an EBSD variable containing the data
ebsdVal = EBSD.load(fname2,CS,'interface','ctf',...
  'convertEuler2SpatialReferenceFrame');

% this defines an ipf color key for the Iron bcc phase
ipfKey = ipfColorKey(ebsdVal('Iron fcc'));
ipfKey.inversePoleFigureDirection = vector3d.Z;
colors = ipfKey.orientation2color(ebsdVal('Iron fcc').orientations);
figure;
plot(ebsdVal('Iron fcc'),colors)
