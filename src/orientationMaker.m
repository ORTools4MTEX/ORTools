function orientationMaker2(oriIn,sampleSymmetry,varargin)
%% Function description:
% This function creates an ideal crystallographic orientation from a 
% unimodal ODF with a user specified half-width and exports the data as a
% lossless Mtex *.txt file for later use.
%
%% Syntax:
%  orientationMaker(ori,sampleSymmetry)
%
%% Input:
%  oriIn          - @orientation
%  sampleSymmetry - @specimenSymmetry
%
%% Options:
%  halfwidth      - halfwidth for the ODF calculation
%  export         - (optional path and) name of the file


hwidth = get_option(varargin,'halfwidth',2.5*degree);

%% define the specimen symmetry to compute ODF
sS = specimenSymmetry('triclinic');

%% calculate a single orientation ODF with all symmetries
pfName_Out = get_option(varargin,'export','inputOrN.txt');

%% calculate a unimodal ODF
odf = unimodalODF(symmetrise(oriIn),'halfwidth',hwidth);

%% re-define the ODF specimen symmetry based on the user specification
odf.SS = sampleSymmetry;

%% generate the user specified number of orientations from the ODF
oriOut = odf.discreteSample(length(odf.weights));

%% save an MTEX ASCII File *.txt file (lossless format)
export(oriOut,pfName_Out,'Bunge','interface','mtex');

end

