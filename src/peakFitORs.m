function [p2c] = peakFitORs(job,misoRange)
%% Function description:
% This function peak fits parent-child misorientation angle ranges to
% determine one or several orientation relationships (ORs).
% The function is called by "defineORs.m".
%
%% Syntax:
%  p2c = peakFitORs(job,misoRange)
%
%% Input:
%  job          - @parentGrainreconstructor
%  misoRange    - range of misorientation angles in which to fit
%
%% Output:
%  p2c          - parent to child orientation relationship


screenPrint('Step','Computing ORs from peak-fitted data');
%--- Define the angular misorientation range to display in the misorientation axis distribution
ss = specimenSymmetry('triclinic');
numORs = length(misoRange.min);

%% Method selection
% check for MTEX version
currentVersion = 5.9;
fid = fopen('VERSION','r');
MTEXversion = fgetl(fid);
fclose(fid);
MTEXversion = str2double(MTEXversion(5:end-2));

if MTEXversion >= currentVersion % for MTEX versions 5.9.0 and above
    methodTypes = {'Maximum f(g)','Cancel'};
else % for MTEX versions 5.8.2 and below
    methodTypes = {'Maximum f(g)','Modal center','Cancel'};
end

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
elseif MTEXversion >= currentVersion && strcmpi(methodSelected,methodTypes{2})
    message = sprintf('Script terminated: Execution aborted by user');
    uiwait(warndlg(message));
    return
elseif MTEXversion < currentVersion && strcmpi(methodSelected,methodTypes{3})
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

    if MTEXversion >= currentVersion % for MTEX versions 5.9.0 and above
        [~,mdfCenterParent] = max(mdfParent,...
            'accuracy',0.25*degree);

    else % for MTEX versions 5.8.2 and below
        if strcmpi(methodSelected,methodTypes{1})
            [~,mdfCenterParent] = max(mdfParent,...
                'FundamentalRegion',...
                'resolution',0.25*degree,...
                'silent');

        elseif strcmpi(methodSelected,methodTypes{2})
            mdfCenterParent = calcModes(mdfParent,...
                'FundamentalRegion',...
                'resolution',0.25*degree,...
                'silent');
            %         'accuracy',0.05*degree,...
        end
    end

    mdfAxisParent = mdfCenterParent.axis(job.csParent.mineral,job.csParent.mineral,ss);
    p2c(jj) = mdfCenterParent;
    ORinfo(p2c(jj),'silent');
    clear gB gBrange psiMODF mdfParent mdfCenterParent mdfAxisParent
end
end


