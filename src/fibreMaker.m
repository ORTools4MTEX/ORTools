function fibreMaker(crystalDirection,sampleDirection,sampleSymmetry,varargin)
%% Function description:
% Creates an ideal crystallographic fibre with a user specified
% half-width and exports the data as a lossless Mtex *.txt file (for 
% version 5.9.0 and onwards) or as a lossy discretised Mtex *.txt file (for 
% up to version 5.8.2) for later use.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Modified by:
% Dr. Frank Niessen to include varargin.
%
%% Version(s):
% The first version of this function was posted in:
% https://github.com/ORTools4MTEX/ORTools/blob/develop/fibreMaker.m
%
%% Syntax:
%  fibreMaker(crystalDirection,samplenDirection,,sampleSymmetry)
%
%% Input:
%  crystalDirection     - @Miller
%  sampleDirection      - @vector3d
%  sampleSymmetry       - @specimenSymmetry
%
%% Options:
%  halfwidth    - halfwidth for the ODF calculation
%  points       - number of points (discrete orientations) in the VPSC file
%  export       - (optional path) and name of the VPSC file
%%

hwidth = get_option(varargin,'halfwidth',2.5*degree);

% define the specimen symmetry to compute ODF
ss = specimenSymmetry('triclinic');

% check for MTEX version
currentVersion = 5.9;
fid = fopen('VERSION','r');
MTEXversion = fgetl(fid);
fclose(fid);
MTEXversion = str2double(MTEXversion(5:end-2));

if MTEXversion >= currentVersion % for MTEX versions 5.9.0 and above
    pfName_Out = get_option(varargin,'export','inputFibre.txt');

    % pre-define the fibre
    f = fibre(symmetrise(crystalDirection),sampleDirection,ss,'full');

    % calculate a fibre ODF
    odf = fibreODF(f,'halfwidth',hwidth);
    % re-define the ODF specimen symmetry based on user specification
    odf.SS = sampleSymmetry;
    % find the current working directory
    dataPath = [pwd,'\'];
    % define the path and file name
    pfname = fullfile(dataPath,pfName_Out);
    % save an MTEX ASCII File *.txt file (lossless format)
    export(odf,pfname,'Bunge');

else % for MTEX versions 5.8.2 and below
    pfName_Out = get_option(varargin,'export','inputFibre.Tex');

    % calculate a fibre ODF
    odf = fibreODF(symmetrise(crystalDirection),sampleDirection,ss,'de la Vallee Poussin',...
        'halfwidth',hwidth,'Fourier',22);
    % re-define the ODF specimen symmetry based on user specification
    odf.SS = sampleSymmetry;
    % discretise the ODF (lossy format)
    ori =  odf.discreteSample(length(odf.components{1}.weights));
    % save an MTEX ASCII File *.txt file 
    export(ori,pfName_Out,'Bunge');
end
end
