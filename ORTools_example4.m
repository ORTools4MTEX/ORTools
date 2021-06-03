
% *********************************************************************
%                        ORTools - Example 4
% *********************************************************************
% Predicting the transformation texture in an alpha-beta titanium alloy
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
% Default directories - Do not modify
Ini.dataPath = [pwd,'/data/'];
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
% Use the peak fitter in the pop-up menu
%     - Adjust the threshold to include only the largest peak
%     - Compute the OR by "Maximum f(g)"
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
histogram(job.transformedGrains.variantId,'facecolor', 'r');
xlabel('Variant Ids'); ylabel('Frequency');
%% Predict transformation texture
% The even distribution of variants is great to calculate the
% transformation texture, assuming no strong variant selection

% We will plot these pole figures
hParent = [Miller(1,0,0,job.csParent),Miller(1,1,0,job.csParent)];
hChild = [Miller(0,0,0,2,job.csChild),Miller(1,1,-2,0,job.csChild)];

% Compute and plot the reconstructed parent ODF
odf_parent = calcDensity(job.parentEBSD.orientations);
figure;
plotPDF(odf_parent,hParent,'antipodal','silent','contourf');
colormap jet

% We write a texture file generated from the parent ODF ...
export_VPSC(odf_parent,[Ini.texturePath,'inputVPSC.Tex'],'interface',...
    'VPSC','Bunge','points', 5000);

% ... which is used to calculate the transformation texture.
% We plot it, and write a file containing the transformed texture
plotPODF_transform(job,hParent,hChild,'path',Ini.texturePath);

% Compare the transformation texture to the actual child ODF
odf_child = calcDensity(ebsd(job.csChild).orientations);
figure;
plotPDF(odf_child,hChild,'antipodal','silent','contourf');
colormap(flipud(colormap('hot')))

% We can see a quite good agreement. Slight mismatches in the intensity
% originate from a non-random variant selection

%% Include variant selection in prediction of transformation texture
% We can also calculate the transformation texture using strict variant
% selection:

%Only consider variants 3,4,6 and 8
plotPODF_transform(job,hParent,hChild,'path',Ini.texturePath,...
    'variantId',[3 4 6 8]);

%Only consider variants 3,4,6 and 8 with weights between 0 and 100
plotPODF_transform(job,hParent,hChild,'path',Ini.texturePath,...
    'variantId',[3 4 6 8],'variantWt',[100 100 10 10]);

%Only consider variants 3,4,6 and 8 with weights between 0 and 100
plotPODF_transform(job,hParent,hChild,'path',Ini.texturePath,...
    'variantId',[3 4 6 8],'variantWt',[100 10 1 0.1]);

%% Save images
saveImage(Ini.imagePath);



















