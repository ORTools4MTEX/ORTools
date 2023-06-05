function orientationMaker(oriIn,sampleSymmetry,varargin)
%% Function description:
% This function creates an ideal crystallographic orientation from a 
% unimodal ODF with a user specified half-width and exports the data as a 
% lossless MATLAB *.mat variable for later use.
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
pfName_Out = get_option(varargin,'export','inputOrN.mat');

%% define the specimen symmetry to compute ODF
sS = specimenSymmetry('triclinic');

%% calculate a unimodal ODF
odf = unimodalODF(symmetrise(oriIn),'halfwidth',hwidth);

%% re-define the ODF specimen symmetry based on user specification
odf.SS = sampleSymmetry;

%% save the ODF.mat variable (lossless format)
save(pfName_Out,"odf");

end

