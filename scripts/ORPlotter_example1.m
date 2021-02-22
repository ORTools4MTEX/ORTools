function ORPlotter_example1()
    % *********************************************************************
    %                        ORPlotter - Example 1
    % *********************************************************************
    % Program to plot orientation relationship(s)
    % between parent-child phases in an EBSD dataset
    % *********************************************************************
    % Dr. Azdiar Gazder, 2020, azdiaratuowdotedudotau
    % Dr. Frank Niessen, 2020, contactatfniessendotcom
    % (Remove "dot" and "at" to make this email address valid)
    % License provided in root directory
    % If old style color seleUI needed, type the following and re-start Matlab
    % setpref('Mathworks_uisetcolor', 'Version', 1);
    clc; close all; 
    currentFolder;
    screenPrint('StartUp','ORPlotter - Example 1');
    %% Initialize MTEX
    % startup and set some settings
    startup_mtex;
    setMTEXpref('xAxisDirection','east');
    setMTEXpref('zAxisDirection','outOfPlane');
    setMTEXpref('FontSize',14);   
    %% Load data
    mtexDataset = 'martensite';
    screenPrint('SegmentStart',sprintf('Loading MTEX example data ''%s''',mtexDataset));
    ebsd = mtexdata(mtexDataset);
    %% Compute, filter and smooth grains
    screenPrint('SegmentStart','Computing, filtering and smoothing grains');
    [grains,ebsd.grainId] = calcGrains(ebsd('indexed'), 'angle', 3*degree);
    % remove small grains
    ebsd(grains(grains.grainSize < 4)) = [];
    % reidentify grains with small grains removed:
    [grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',2*degree);
    grains = smooth(grains,5);
    %% Rename and recolor phases 
    screenPrint('SegmentStart','Renaming and recoloring phases');
    phaseNames = {'Gamma','AlphaP','Alpha'};
    ebsd = renamePhases(ebsd,phaseNames);
    [ebsd,grains] = recolorPhases(ebsd,grains);
    %% Define and refine parent-to-child orientation relationship
    screenPrint('SegmentStart','Define and refine parent-to-child OR');
    job = parentGrainReconstructor(ebsd,grains);
    % initial guess for the parent to child orientation relationship
    job.p2c = orientation.KurdjumovSachs(job.csParent, job.csChild);
    % optimizing the parent child orientation relationship
    job.calcParent2Child;
    % get information about the determined OR
    ORinfo(job.p2c);
    %% Plotting (witch ORPlotter functions)
    screenPrint('SegmentStart','Plotting some ORPlotter maps');
    % Phase map
    plotMap_phases(job,10*degree);
    % Parent-child grain boundary misorientation map
    plotMap_gB_p2c(job,'linewidth',2);
    % Child-child grain boundary misorientation map
    plotMap_gB_c2c(job,'linewidth',2);
%     % Parent and child IPF maps
%     plotMap_IPF_p2c(job);
%     % Plot parent-child and child-child OR boundary disorientation map
%     plotMap_gB_Misfit(job);
%     % Plot parent-child and child-child OR boundary probability map
%     plotMap_gB_Prob(job,param);
%     % Plot inverse pole figures for parent-child and child-child boundary
%     % disorientations
%     plotIPDF_gB_Misfit(job);
%     % Plot inverse pole figures for parent-child and child-child boundary 
%     % probabilities
%     plotIPDF_gB_Prob(job,param);
  
end

function currentFolder
    %% Change the current folder to the folder of this m-file.
    if(~isdeployed)
        folder = fileparts(mfilename('fullpath'));
        cd(folder);
        % Add that folder plus all subfolders to the path.
        addpath(genpath(folder));
    end
end

function screenPrint(mode,varargin)
    switch mode
        case 'StartUp'
            titleStr = varargin{1};
            fprintf('\n*************************************************************');
            fprintf(['\n                 ',titleStr,' \n']);
            fprintf('*************************************************************\n'); 
        case 'Termination'
            titleStr = varargin{1};
            fprintf('\n*************************************************************');
            fprintf(['\n                 ',titleStr,' \n']);
            fprintf('*************************************************************\n'); 
        case 'SegmentStart'
            titleStr = varargin{1};
            fprintf('\n------------------------------------------------------');
            fprintf(['\n     ',titleStr,' \n']);
            fprintf('------------------------------------------------------\n'); 
       case 'Step'
            titleStr = varargin{1};
            fprintf([' -> ',titleStr,'\n']);
       case 'SubStep'
            titleStr = varargin{1};
            fprintf(['    - ',titleStr,'\n']);
       case 'SegmentEnd'
            fprintf('\n------------------------------------------------------\n');
    end
end



