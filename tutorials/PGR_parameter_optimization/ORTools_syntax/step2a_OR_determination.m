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

%% Set up Reconstructor and plot fit of different rational ORs and optimized OR
job = setParentGrainReconstructor(ebsd,grains);
plotMap_IPF_p2c(job,vector3d.Z,'child');
% Give an initial guess for the OR: Kurdjumov-Sachs ...
job.p2c = orientation.KurdjumovSachs(job.csParent, job.csChild);
% ... and refine it based on the fit with boundary misorientations
job.calcParent2Child;
% Let us check the disorientation and compare it with K-S and N-W
% (The disorientation is the misfit between the grain misorientations
% and the misorientation of the OR)
KS = orientation.KurdjumovSachs(job.csParent,job.csChild);
NW = orientation.NishiyamaWassermann(job.csParent,job.csChild);
GT = orientation.GreningerTrojano(job.csParent,job.csChild);
plotHist_OR_misfit(job,[KS,NW,GT],'legend',{'K-S OR','N-W OR','G-T OR'});
% Display information about the OR
ORinfo(job.p2c);

%% Map fit with OR on grain boundaries
p2cs = [KS,NW,GT,job.p2c];
p2cnames = {'K-S OR','N-W OR','G-T OR',"fitted"};
for ii = 1:length(p2cs)
    job.p2c = p2cs(ii);
    plotMap_gB_misfit(job,'linewidth',2, 'maxColor',5);
    set(gcf,'name',strcat(get(gcf,'name'),' - ',p2cnames{ii}));
end


