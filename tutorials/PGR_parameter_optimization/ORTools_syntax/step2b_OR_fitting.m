% Visualize the effect of different OR fitting parameters on determining
% the best fitting OR
clearvars
home
close all
%% Parameter
min_angle = 1*degree;   %Threshold angle for grain reconstruction
% Different quantile settings for the calcParent2Child function
quantiles = [0.6,0.7,0.8,0.9,0.99999];

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

%% Set up Reconstructor and fit ORs
% set up the job
job = setParentGrainReconstructor(ebsd,grains);

for ii = 1:length(quantiles)
    job.p2c = orientation.KurdjumovSachs(job.csParent,job.csChild);
    job.calcParent2Child('quantile',quantiles(ii));
    p2cs(ii) = job.p2c;
end
quant = quantiles(1:end-1);
plotHist_OR_misfit(job,p2cs(1:end-1),'legend',cellstr(num2str(quant(:))));
l = get(gca,'legend');
l.String(1) = cellstr(num2str(quantiles(end)));

%% Map fit with OR on grain boundaries
for ii = 1:length(p2cs)
    job.p2c = p2cs(ii);
    plotMap_gB_misfit(job,'linewidth',2, 'maxColor',5);
    set(gcf,'name',strcat(get(gcf,'name'),' - ',num2str(quantiles(ii))));
end

