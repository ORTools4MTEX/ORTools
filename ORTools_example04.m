
% *********************************************************************
%                        ORTools - Example 4
% *********************************************************************
% Predicting the transformation texture in an alpha-beta titanium alloy
% https://www.youtube.com/watch?v=Yx2jKII3HUc&t=27s
% *********************************************************************
% Dr. Azdiar Gazder, 2020, azdiaratuowdotedudotau
% Dr. Frank Niessen, 2020, contactatfniessendotcom
% (Remove "dot" and "at" to make this email address valid)
% *********************************************************************
home; close all; clear variables;
currentFolder;
set(0,'DefaultFigureWindowStyle','normal');
screenPrint('StartUp','ORTools - Example 4');
%% Initialize MTEX
% Startup and set some settings
startup_mtex;
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize',14);
setInterp2Tex;
% Default directories - Do not modify
Ini.dataPath = [strrep(pwd,'\','/'),'/data/'];
Ini.cifPath = [Ini.dataPath,'input/cif/'];
Ini.ebsdPath = [Ini.dataPath,'input/ebsd/'];
Ini.texturePath = [Ini.dataPath,'output/texture/'];
Ini.imagePath = [Ini.dataPath,'output/images/'];
%% Load data
% Open the MTEX dataset on alpha and beta titanium
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
phaseNames = {'Alpha','Beta'};
% Rename "Ti (BETA) to "Beta"and "Ti (alpha)" to "Alpha"
ebsd = renamePhases(ebsd,phaseNames);
% Choose your favourite colors
ebsd = recolorPhases(ebsd);
%% Finding the orientation relationship
screenPrint('SegmentStart','Finding the orientation relationship(s)');
% Choose Beta as a parent and Alpha as a child phase in the transition
job = parentGrainReconstructor(ebsd,grains,Ini.cifPath);
job.p2c = orientation.Burgers(job.csParent, job.csChild);
% Check the disorientation
plotHist_OR_misfit(job);
xlim([0,10]);
%% Plotting (with ORTools functions)
screenPrint('SegmentStart','Plotting some ORTools maps');
% Parent and child IPF maps
plotMap_IPF_p2c(job,vector3d.Z,'linewidth',1,'child');
% Plot map for parent-child and child-child boundary disorientations
plotMap_gB_misfit(job,'maxColor',5,'linewidth',1.5);
%% Compute parent orientations (see example 2 for details)
job.calcTPVotes('minFit',2.5*degree,'maxFit',5*degree);
job.calcParentFromVote('minProb',0.7);
for k = 1:3
    job.calcGBVotes('p2c','threshold',k*2.5*degree);
    job.calcParentFromVote
end
% Clean reconstructed grains
job.mergeSimilar('threshold',5*degree);
job.mergeInclusions('maxSize',5);
% Plot the cleaned reconstructed parent microstructure
figure;
plot(job.ebsd(job.csParent),job.ebsd(job.csParent).orientations);
hold on;
plot(job.grains.boundary,'lineWidth',3)
%% Variant analysis
% We calculate the variants ...
job.calcVariants;
% ... and plot them
plotMap_variants(job,'linewidth',3);
% The histogram shows a quite even distribution of the variants
figure
histogram(job.transformedGrains.variantId,'facecolor', 'r','Normalization','pdf');
xlabel('Variant Ids'); ylabel('Frequency');
%% Predict transformation texture
% The even distribution of variants is great to calculate the
% transformation texture, assuming no strong variant selection

% We will plot these pole figures
hParent = [Miller(1,1,0,job.csParent),Miller(2,0,0,job.csParent)];
hChild = [Miller(0,0,0,2,job.csChild),Miller(1,1,-2,0,job.csChild)];

% Compute and plot the reconstructed parent ODF
odf_parent = calcDensity(job.parentEBSD.orientations);
figure;
plotPDF(odf_parent,hParent,'antipodal','silent','contourf');
colormap jet

%% We write a texture file generated from the parent ODF...
% save the parent odf as a *.mat file object (lossless format)
pfName_In = [Ini.texturePath,'inputTexture.mat']; % the name of the *.mat file may be changed 
% In the plotPODFtrasform.m function:
% - the input parent ODF must always be defined by the variable "inputODF"
% - the output child transformed ODF is always defined by the variable "outputODF"
% ** NOTE: the variable names "inputODF" and "outputODF" must not be 
% edited. **
inputODF = odf_parent; 
save(pfName_In,"inputODF");

%% ... which is used to calculate the transformation texture.
pfName_Out = [Ini.texturePath,'outputTexture.mat']; % the name of the *.mat file may be changed 
% The transformation tetxure is plotted and saved as a odf_child.mat variable
plotPODF_transform(job,hParent,hChild,'import',pfName_In,'export',pfName_Out);

%% Compare the transformation texture to the actual child ODF
odf_child = calcDensity(ebsd(job.csChild).orientations);
figure;
plotPDF(odf_child,hChild,'antipodal','silent','contourf');
colormap(flipud(hot))

% We can see a quite good agreement. Slight mismatches in the intensity
% originate from a non-random variant selection

%% Include variant selection in prediction of transformation texture
% We can also calculate the transformation texture using strict variant
% selection:

% Consider variants 3, 6, 9 and 12 
% NOTE: since variantWt is not specified, the modal weights based on the 
% parent ODF are used here
plotPODF_transform(job,hParent,hChild,'import',pfName_In,...
    'variantId',[3 6 9 12]);

% Consider variants 1, 3, 5, and 7 with weights between 0 and 100
% NOTE: since variantWt is specified, modal weights are not used.
% Instead, the normalised variantWt is used.
plotPODF_transform(job,hParent,hChild,'import',pfName_In,...
    'variantId',[1 3 5 7],'variantWt',[100 100 1 0.1]);

% Consider variants 4, 8 and 12 with equal weights
plotPODF_transform(job,hParent,hChild,'import',pfName_In,...
    'variantId',[4 8 12],'variantWt',[1 1 1]);

% Consider all variants with equal weights
plotPODF_transform(job,hParent,hChild,'import',pfName_In,...
    'variantId',[1:12],'variantWt',ones(1,12));

%% Save images
saveImage(Ini.imagePath);



















