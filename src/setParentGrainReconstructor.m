function job = setParentGrainReconstructor(ebsd,grains,inPath)
% Auxiliary GUI function to define a job of class parentGrainReconstructor
%
% Syntax
%  setParentGrainReconstructor(ebsd,grains)
%  setParentGrainReconstructor(ebsd,grains,inPath)
%
% Input
%  ebsd     - @EBSD
%  grains   - @grain2d
%  inPath   - string giving path to cif-file folder 
%
% Output
%  job      - @parentGrainReconstructor

if nargin ==2, inPath = pwd; end
%% Define the parent phase (minerals)
phaseIDs = length(ebsd.CSList);
screenPrint('Step','Define the parent phase');
[ind_parent,~] = listdlg('PromptString',['Select parent phase'],...
    'SelectionMode','single','name','Parent phase selection',...
    'ListString',[ebsd.mineralList(2:phaseIDs),'Import parent phase from a *.cif file'],...
    'ListSize',[300 150]);
if ind_parent == phaseIDs
    [FileName,inPath] = uigetfile([inPath,'*.cif'],'Import parent phase: Open *.cif file');
    CS.parent = loadCIF([inPath,FileName]);
else 
    CS.parent = ebsd.CSList{ind_parent+1};
end
screenPrint('SubStep',sprintf('''%s''',CS.parent.mineral));
%% Define the child phase (minerals)
screenPrint('Step','Define the child phase');
[ind_child,~] = listdlg('PromptString',['Select child phase'],...
    'SelectionMode','single','name','child phase selection',...
    'ListString',[ebsd.mineralList(2:phaseIDs),'Import child phase from a *.cif file'],...
    'ListSize',[300 150]);
if ind_child == phaseIDs
    [FileName,inPath] = uigetfile([inPath,'/*.cif'],'Import child phase: Open *.cif file');
    CS.child = loadCIF([inPath,FileName]);
else
    CS.child = ebsd.CSList{ind_child+1};
end
screenPrint('SubStep',sprintf('''%s''',CS.child.mineral));
%% Define parentGrainReconstructor job
%Dummy misorientation to define p2c crystal symmetries
p2c0 = orientation.byEuler(0,0,0,CS.parent,CS.child);
job = parentGrainReconstructor(ebsd,grains,p2c0);