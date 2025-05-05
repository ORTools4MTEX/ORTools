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
screenPrint('Step',['All OR(s) determined using Maximum f(g) of the mdf']);

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

        [~,mdfCenterParent] = max(mdfParent,...
            'accuracy',0.25*degree);

    mdfAxisParent = mdfCenterParent.axis(job.csParent.mineral,job.csParent.mineral,ss);
    p2c(jj) = mdfCenterParent;
    ORinfo(p2c(jj),'silent');
    clear gB gBrange psiMODF mdfParent mdfCenterParent mdfAxisParent
end
end


