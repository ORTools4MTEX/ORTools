% *************************************************************************
% Trace analysis of martensite laths from EBSD data
% *************************************************************************
% Experimental feature

home; close all; clear variables;
currentFolder;
set(0,'DefaultFigureWindowStyle','normal');
screenPrint('StartUp','ORTools - Example 1');
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
Ini.phaseNames = {'Gamma','AlphaP','Epsilon'};
%% Import EBSD data and save current file name
ebsd = mtexdata('martensite');
%ebsd = loadEBSD_ctf([Ini.ebsdPath,'TRWIPsteel.ctf'],'convertSpatial2EulerReferenceFrame');
ebsd = ebsd('indexed');
%% Compute, filter and smooth grains
screenPrint('SegmentStart','Computing, filtering and smoothing grains');
% Grains are calculated with a 3° threshold
[grains,ebsd.grainId] = calcGrains(ebsd,'threshold',1.5*degree,...
  'removeQuadruplePoints');
%% Rename and recolor phases 
screenPrint('SegmentStart','Renaming and recoloring phases');
%Rename "Iron fcc" to "Gamma", "Iron bcc (old)" to "AlphaP" and 
%"Epsilon_Martensite" to "Epsilon"
ebsd = renamePhases(ebsd,Ini.phaseNames);
%Choose your favourite colors
ebsd = recolorPhases(ebsd);
%% Define the transformation system
screenPrint('SegmentStart','Finding the orientation relationship(s)');
% Choose "Gamma" as a parent and "Alpha" as a child phase
job = setParentGrainReconstructor(ebsd,grains,Ini.cifPath);
%% Filter grains
minArea = 0.8;                                                             %Getting min area
minAR = 3;                                                                 %Getting min aspect ratio
childGrains = job.childGrains(all([job.childGrains.area>minArea,...
                                              job.childGrains.aspectRatio>minAR],2)); %Filter grains

%% Compute traces of grains
%The trace is computed by identifying the longest axis by fitting of an
%elipse
[omega,a,b] = childGrains.fitEllipse;
v = childGrains.longAxis;                                                  %Get the longest axis                               
%% Plot traces
figure;                                                                    %Figure
plot(ebsd,ebsd.prop.bc);                                                   %Mean grain orientations of children grains for trace analysis
mtexColorMap black2white                                                   %Change colors to greyscale
hold on                                                                    %More plotting to come
plot(childGrains,childGrains.meanOrientation);                             %Mean grain orientations of children grains for trace analysis                                                               
hold on                                                                    %More plotting to come
quiver(childGrains,v,'color','k');                                         %Draw the traces into the analyzed grains
tileFigs;                                                                  %Distribute figures
drawnow;                                                                   %Show figure now
%% Determine Habit plane traces Htr
R.resetB = rotation(childGrains.meanOrientation);                          %Compute rotation from mean child grain orientations
vRot = rotate(v,inv(R.resetB))';                                           %Rotate habit plane traces into child grain standard projection
Htr = Miller(vRot,job.csChild,'uvw');                                      %Compute Miller crystal directions of the habit plane traces
Htr = project2FundamentalRegion(Htr);                                          
%% Fit habit plane H through traces Htr
weights = sqrt(childGrains.area.*childGrains.aspectRatio);                 %Compute weights for fitting sqrt(grainArea*grainAspectRatio)
weights = weights/max(weights);                                            %Normalize weights
[tmp,rsqu] = fitPlane(Htr,weights);                                        %Fit plane through orientations
H = Miller(tmp(1),tmp(2),tmp(3),job.csChild,'xyz');                        %Convert plane to Miller
%% Plot traces and habit plane
figure;
plot(Htr,'markerfacecolor','k','markeredgecolor','k','markersize','fundamentalregion','markersize',weights*4); 

% Add habit plane
hold on
plot(H,'linecolor','r','plane','antipodal','linewidth',3,'linestyle',':');
tileFigs;

%% Output
fprintf(" - The Habit plane is (%s)\n",H.char);
