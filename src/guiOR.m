function p2c = guiOR(job)
% Graphical user interface for definition of an orientation relationship by
% parallel planes and directions
%
% Syntax
%  p2c = guiOR(job)
%
% Input
%  job          - @parentGrainreconstructor
%
% Output
%  p2c          - parent to child orientation relationship

screenPrint('Step','Computing a user-defined OR');
Prompt = {
    '\bf H_p','H_p',''
    '\bf K_p','K_p',''
    '\bf I_p','I_p',''
    '\bf L_p','L_p',''
    '\bf U_p','U_p',''
    '\bf V_p','V_p',''
    '\bf T_p','T_p',''
    '\bf W_p','W_p',''
    '\bf H_c','H_c',''
    '\bf K_c','K_c',''
    '\bf I_c','I_c',''
    '\bf L_c','L_c',''
    '\bf U_c','U_c',''
    '\bf V_c','V_c',''
    '\bf T_c','T_c',''
    '\bf W_c','W_c',''
    '\bf Parent convention    ','rBp',''
    '\bf Child convention','rBd',''
    '\bf Key:','',''
    '\bf (H_p K_p L_p)   or   (H_p K_p I_p L_p)   =   Parent plane','',''
    '\bf [U_p V_p W_p]   or   [U_p V_p T_p W_p]   =   Parent direction','',''
    '\bf (H_c K_c L_c)   or   (H_c K_c I_c L_c)   =   Child plane','',''
    '\bf [U_c V_c W_c]   or   [U_c V_c T_c W_c]   =   Child direction','',''
    };

for ro = 1:4
    for col = 1:4
        Formats(ro,col).format = 'float';
    end
end

DefAns = struct([]);
DefAns(1).H_p = 1;
DefAns.K_p = 1;
DefAns.I_p = 0;
DefAns.L_p = -1;

DefAns.U_p = 1;
DefAns.V_p = -1;
DefAns.T_p = 0;
DefAns.W_p = 0;

DefAns.H_c = 0;
DefAns.K_c = 1;
DefAns.I_c = 0;
DefAns.L_c = -1;

DefAns.U_c = 1;
DefAns.V_c = -1;
DefAns.T_c = 0;
DefAns.W_c = -1;


Formats(ro+1,1).type = 'list';
Formats(ro+1,1).span = [1 4];
Formats(ro+1,1).format = 'text';
Formats(ro+1,1).style = 'radiobutton';
Formats(ro+1,1).items = {'Miller (hkl)[UVW]', 'Miller-Bravais (hkil)[UVTW]'};
DefAns.rBp = 'Miller (hkl)[UVW]';

Formats(ro+2,1).type = 'list';
Formats(ro+2,1).span = [1 2];
Formats(ro+2,1).format = 'text';
Formats(ro+2,1).style = 'radiobutton';
Formats(ro+2,1).items = {'Miller (hkl)[UVW]', 'Miller-Bravais (hkil)[UVTW]'};
DefAns.rBd = 'Miller (hkl)[UVW]';

Formats(ro+3,1).type = 'text'; % Key
Formats(ro+3,1).span = [1 4];

Formats(ro+4,1).type = 'text'; % Parent plane
Formats(ro+4,1).span = [1 2];

Formats(ro+4,3).type = 'text'; % Parent direction
Formats(ro+4,3).span = [1 2];

Formats(ro+5,1).type = 'text'; % Child plane
Formats(ro+5,1).span = [1 2];

Formats(ro+5,3).type = 'text'; % Child direction
Formats(ro+5,3).span = [1 2];

Title = 'Define an OR using Miller indices';
% Options.AlignControls = 'off';
% Options.CreateFcn = @(~,~,handles)celldisp(get(handles,'type'));
% Options.DeleteFcn = @(~,~,handles)celldisp(get(handles,'type'));
% evalc('[guiFields,~] = inputsdlg(Prompt,Title,Formats,DefAns)');
[guiFields,~] = inputsdlg(Prompt,Title,Formats,DefAns);


if strcmp(guiFields.rBp,'Miller (hkl)[UVW]')
    planeParent = Miller(...
        guiFields.H_p,...
        guiFields.K_p,...
        guiFields.L_p,...
        job.csParent);
    directionParent = Miller(...
        guiFields.U_p,...
        guiFields.V_p,...
        guiFields.W_p,...
        job.csParent);
elseif strcmp(guiFields.rBp,'Miller-Bravais (hkil)[UVTW]')
    planeParent = Miller(...
        guiFields.H_p,...
        guiFields.K_p,...
        guiFields.I_p,...
        guiFields.L_p,...
        job.csParent);
    directionParent = Miller(...
        guiFields.U_p,...
        guiFields.V_p,...
        guiFields.T_p,...
        guiFields.W_p,...
        job.csParent);
end

if strcmp(guiFields.rBd,'Miller (hkl)[UVW]')
    planechild = Miller(...
        guiFields.H_c,...
        guiFields.K_c,...
        guiFields.L_c,...
        job.csChild);
    directionchild = Miller(...
        guiFields.U_c,...
        guiFields.V_c,...
        guiFields.W_c,...
        job.csChild);
elseif strcmp(guiFields.rBd,'Miller-Bravais (hkil)[UVTW]')
    planechild = Miller(...
        guiFields.H_c,...
        guiFields.K_c,...
        guiFields.I_c,...
        guiFields.L_c,...
        job.csChild);
    directionchild = Miller(...
        guiFields.U_c,...
        guiFields.V_c,...
        guiFields.T_c,...
        guiFields.W_c,...
        job.csChild);
end
                       
%--- Define the OR as a misorientation
p2c = orientation('map',...
    planeParent,...
    planechild,...
    directionParent,...
    directionchild);
