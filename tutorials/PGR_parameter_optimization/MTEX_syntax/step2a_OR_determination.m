% Visualizing the suitability of different orientation relationships
clearvars
home
close all
%% Parameter
min_angle = 1*degree;   %Threshold angle for grain reconstruction

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
KS = orientation.KurdjumovSachs(job.csParent,job.csChild);
NW = orientation.NishiyamaWassermann(job.csParent,job.csChild);
GT = orientation.GreningerTrojano(job.csParent,job.csChild);
job.p2c = KS;

%% Plot fit of different rational ORs and optimized OR
% close all
figure;
%KS
histogram(job.calcGBFit./degree,'BinMethod','sqrt')
xlabel('disorientation angle')
%NW
job.p2c = NW;
hold on
histogram(job.calcGBFit./degree,'BinMethod','sqrt')
hold off
%GT
job.p2c = GT;
hold on
histogram(job.calcGBFit./degree,'BinMethod','sqrt')
hold off
%Fitted
job.calcParent2Child
hold on
histogram(job.calcGBFit./degree,'BinMethod','sqrt')
hold off
p2cnames = {"KS","NW","GT","Fitted"};
legend(p2cnames);
% compute the misfit for all child to child grain neighbours
[fit,c2cPairs] = job.calcGBFit;

%% Map fit with OR on grain boundaries
p2cs = [KS,NW,GT,job.p2c];
for ii = 1:length(p2cs)
    figure;
    job.p2c = p2cs(ii);
    % compute the misfit for all child to child grain neighbours
    [fit,c2cPairs] = job.calcGBFit;
    % select grain boundary segments by grain ids
    [gB,pairId] = job.grains.boundary.selectByGrainId(c2cPairs);    
    % plot the child phase
    plot(ebsd('Iron bcc'),ebsd('Iron bcc').orientations,'figSize','large','faceAlpha',0.5)    
    % and on top of it the boundaries colorized by the misfit
    hold on;
    % scale fit between 0 and 1 - required for edgeAlpha
    plot(gB, 'edgeAlpha', (fit(pairId) ./ degree - 2.5)./2 ,'linewidth',2);
    hold off
    set(gcf,'name',strcat(get(gcf,'name'),' - ',p2cnames{ii}));
end
