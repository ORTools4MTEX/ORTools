function orientationMaker(ori)
% create a unimodal ODF and export a VPSC file
%
% Syntax
%  orientationMaker(crystalDirection,specimenDirection)
%
% Input
%  ori     - @orientation
%
% Options
%  halfwidth        - Halfwidth for ODF calculation
%  nrPoints         - Nr of points in VPSC file

%% Common ideal orientations for fcc materials
% % Cube (C):              phi1 = 45; PHI = 0;  phi2 = 45;
% % Cube-RD (C_RD):        phi1 = 22; PHI = 0;  phi2 = 0;
% % Cube-ND (C_ND):        phi1 = 0;  PHI = 22; phi2 = 0;
% % Cube Twin (CT):        phi1 = 27; PHI = 48; phi2 = 27;
% % Rotated Cube (RtC):    phi1 = 0;  PHI = 0;  phi2 = 45;
% % Goss (G):              phi1 = 90; PHI = 90; phi2 = 45;
% % Rotated Goss (RtG):    phi1 = 0;  PHI = 90; phi2 = 45;
% % Goss Twin (GT):        phi1 = 90; PHI = 25; phi2 = 45;
% % Goss-Brass (GBr):      phi1 = 74; PHI = 90; phi2 = 45;
% % Brass (Br):            phi1 = 55; PHI = 90; phi2 = 45;
% % Copper (Cu):           phi1 = 90; PHI = 35; phi2 = 45;
% % Copper Twin (CuT):     phi1 = 90; PHI = 74; phi2 = 45;
% % Rotated Copper (RtCu): phi1 = 0;  PHI = 35; phi2 = 45;
% % A:                     phi1 = 35; PHI = 90; phi2 = 45;
% % S:                     phi1 = 59; PHI = 37; phi2 = 63;
% % F:                     phi1 = 30; PHI = 55; phi2 = 45;
% % E:                     phi1 = 0;  PHI = 55; phi2 = 45;


%% Common ideal orientations for bcc materials
% % (0 0 1)[1-1 0]:        phi1 = 0;  PHI = 0;  phi2 = 45;
% % (1 1 4)[1-1 0]:        phi1 = 0;  PHI = 19; phi2 = 45;
% % (1 1 2)[1-1 0]:        phi1 = 0;  PHI = 35; phi2 = 45;
% % (2 2 3)[1-1 0]:        phi1 = 0;  PHI = 43; phi2 = 45;
% % (1 1 1)[1-1 0]:        phi1 = 0;  PHI = 55; phi2 = 45;
% % (3 3 2)[1-1 0]:        phi1 = 0;  PHI = 65; phi2 = 45;
% % (2 2 1)[1-1 0]:        phi1 = 0;  PHI = 71; phi2 = 45;
% % (1 1 0)[1-1 0]:        phi1 = 0;  PHI = 90; phi2 = 45;
% % (1 1 1)[1-2 1]:        phi1 = 30; PHI = 55; phi2 = 45;
% % (1 1 1)[0-1 1]:        phi1 = 60; PHI = 55; phi2 = 45;
% % (1 1 1)[-1-1 2]:       phi1 = 90; PHI = 55; phi2 = 45;
% % (5 5 4)[-2-2 5]:       phi1 = 90; PHI = 61; phi2 = 45;
% % (1 1 0)[0 0 1]:        phi1 = 90; PHI = 90; phi2 = 45;
% % (0 0 1)[0-1 0]:        phi1 = 45; PHI = 0;  phi2 = 45;
% % (0 0 1)[-1-1 0]:       phi1 = 90; PHI = 0;  phi2 = 45;
% % (1 1 3)[4-7 1]:        phi1 = 17; PHI = 25; phi2 = 45;

hwidth = get_option(varargin,'halfwidth',2.5);
nrPoints = get_option(varargin,'nrPoints',1000);

%--- Define specimen symmetry
ss = specimenSymmetry('triclinic');
%--- Calculate a single orientation ODF with all symmetries
odf = unimodalODF(symmetrise(ori),'de la Vallee Poussin',...
    'halfwidth',hwidth*degree,'Fourier',22);
%--- Define the ODF specimen symmetry
odf.SS = specimenSymmetry('orthorhombic');
%--- Save a VPSC *.tex file
FileName = 'inputVPSC.Tex';
export_VPSC(odf,FileName,'interface','VPSC','Bunge','points',nrPoints);
%---

end