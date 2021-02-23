function [p2c] = peakFitORs(job,misoRange)
% peak fitting of parent-child misorientation angle ranges for 
% determination of one or several orientation relationships
% Function is executed by "defineORs.m"
%
% Syntax
%  p2c = peakFitORs(job,misoRange)
%
% Input
%  job          - @parentGrainreconstructor
%  misoRange    - range of misorientation angles in which to fit
%
% Output
%  p2c          - parent to child orientation relationship

screenPrint('Step','Computing ORs from peak-fitted data');
%--- Define the angular misorientation range to display in the misorientation axis distribution
ss = specimenSymmetry('triclinic');
numORs = length(misoRange.min);

%% Method selection
methodTypes = {'Maximum f(g)','Modal center','Cancel'};
try
    methodSelected = questdlg('Choose the method to compute the OR(s):', ...
        'Method selection', methodTypes{:},methodTypes{1});
catch
end
% This command prevents function execution in cases when
% the user presses the "Cancel" or "Close" buttons
if isempty(methodSelected)
    message = sprintf('Script terminated: Execution aborted by user');
    uiwait(warndlg(message));
    return
elseif strcmp(methodSelected,methodTypes{3})
    message = sprintf('Script terminated: Execution aborted by user');
    uiwait(warndlg(message));
    return
end
screenPrint('Step',['All OR(s) determined using ', methodSelected,' of the mdf']);

%% Begin OR computation
for jj = 1:numORs
    screenPrint('Step',sprintf(['Computing OR ',num2str(jj),':']));
    screenPrint('SubStep',sprintf(['Peak between ',num2str(misoRange.min(jj)),'° & ',num2str(misoRange.max(jj)),'°']));
    gB = job.grains.boundary(job.csParent.mineral,job.csChild.mineral);
    gBrange = gB(...
        gB.misorientation.angle >= misoRange.min(jj).*degree &...
        gB.misorientation.angle <= misoRange.max(jj).*degree);
    
    if length(gBrange)>1500
        gBrange = discreteSample(gBrange,1500,'withReplacement');
    end
    
    psiMODF = calcKernel(gBrange.misorientation,'exact','silent');
    mdfParent = calcDensity(gBrange(job.csParent.mineral).misorientation,...
        job.csParent,...
        'halfwidth',psiMODF.halfwidth,...
        'resolution',0.25*degree,...
        'exact','silent');
    
    if strcmp(methodSelected,methodTypes{1})
        [~,mdfCenterParent] = max(mdfParent,...
            'FundamentalRegion',...
            'resolution',0.25*degree,...
            'silent');
        
    elseif strcmp(methodSelected,methodTypes{2})
        mdfCenterParent = calcModes(mdfParent,...
            'FundamentalRegion',...
            'resolution',0.25*degree,...
            'silent');
%         'accuracy',0.05*degree,...
    end
    mdfAxisParent = mdfCenterParent.axis(job.csParent.mineral,job.csParent.mineral,ss);
    p2c(jj) = mdfCenterParent;
    ORinfo(p2c(jj),'silent');
    clear gB gBrange psiMODF mdfParent mdfCenterParent mdfAxisParent
end
end


