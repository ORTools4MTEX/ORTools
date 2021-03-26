function fibreMaker(crystalDirection,specimenDirection,varargin)
% create a fibre ODF and export a VPSC file
%
% Syntax
%  fibreMaker(crystalDirection,specimenDirection)
%
% Input
%  crystalDirection     - @Miller
%  specimenDirection    - @vector3d
%
% Options
%  halfwidth    - halfwidth for ODF calculation
%  points       - humber of points in VPSC file
%  export       - (optional path) & name of VPSC file to save


%% All fibres are defined based on the following specimen co-ordinate system
% RD = xvector; TD = yvector; ND = zvector;

%% Common fibers for fcc materials
% % alpha-fibre = <110> || ND
% % beta-fibre = <110> tilted 60° from ND towards TD
% % gamma-fibre = <111> || ND
% % tau-fibre = <110> || TD
% % REF: https://doi.org/10.1016/j.actamat.2011.05.050
% % theta-fibre = <001> || ND


%% Common fibers for bcc materials
% % Alpha-fibre = <110> || RD
% % Eta-fibre = <100> || RD
% % Epsilon-fibre = <110> || TD
% % Gamma-fibre = <111> || ND
% % GammaPrime-fibre = <223> || ND
% % Theta-fibre = <100> || ND
% % Zeta-fibre = <110> || ND
% % REF:  https://doi.org/10.1002/adem.201000075
% % {h 1 1} <1/h 1 2> fibre
% %  Notes: This fibre can be simplified as a nominal bcc alpha-fibre
% % whose <110> is tilted 20° from RD towards ND 


%% Common fibres for hcp materials
% % 0001-fibre = <0 0 0 1> || ND
% % 11-20-fibre = <1 1 -2 0> || RD
% % 10-10-fibre = <1 0 -1 0> || ND
% % hkil-fibre = <0 0 0 1> tilted 20° from ND towards RD

%% How to define fibres as used in the function
%% Example 1 
% % Applied to the bcc {h 1 1} <1/h 1 2> fibre 
% % which can be simplified as a nominal bcc alpha-fibre 
% % whose <110> is tilted 20° from RD towards ND 
%% Define a crystallographic direction
% cD = Miller({1,1,0},crystalSystem.parent,'uvw');
%% Define a sample direction parallel to the crystallographic direction
% % sD = RD;
%% Define a tilt away a specimen co-ordinate system direction 
% % rotN = rotation('Euler',-20*degree,0*degree,0*degree);
% % sD = rotN * RD;

%% Example 2 
% % Applied to the fcc beta fibre 
% % whose <110> is tilted 60° from ND towards TD 
%% Define a crystallographic direction
% % cD = Miller({1,1,0},crystalSystem.parent,'uvw');
%% Define a sample direction tilted 60° from ND towards TD
% % rotN = rotation('Euler',90*degree,60*degree,0*degree);
% % sD = rotN * ND;
%%
hwidth = get_option(varargin,'halfwidth',2.5*degree);
numPoints = get_option(varargin,'points',1000);
pfName_Out = get_option(varargin,'export','inputVPSC.Tex');

%--- Define specimen symmetry
ss = specimenSymmetry('triclinic');

%--- Calculate a fibre ODF
odf = fibreODF(crystalDirection,specimenDirection,ss,'de la Vallee Poussin',...
    'halfwidth',hwidth,'Fourier',22);
%--- Define the ODF specimen symmetry
odf.SS = specimenSymmetry('orthorhombic');
%--- Save a VPSC *.tex file
export_VPSC(odf,pfName_Out,'interface','VPSC','Bunge','points',numPoints);
%---

end
