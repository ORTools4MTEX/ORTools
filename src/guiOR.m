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
windowTitle = 'Define an OR using Miller indices';

prompt = repmat({''},20,4);
% prompt = repmat({''},25,4);
prompt(:,1:2) = {...
    '\bf Parent phase:  (h k l)_p [U V W]_p    or    (h k i l)_p [U V T W]_p',''
    '\bf h_p  ','h_p'
    '\bf k_p  ','k_p'
    '\bf i_p   ','i_p'
    '\bf l_p    ','l_p'
    '\bf U_p  ','U_p'
    '\bf V_p  ','V_p'
    '\bf T_p  ','T_p'
    '\bf W_p  ','W_p'
    '\bf Parent convention    ','rB_p'
    '\bf Child phase:   (h k l)_c [U V W]_c    or    (h k i l)_c [U V T W]_c',''
    '\bf h_c  ','h_c'
    '\bf k_c  ','k_c'
    '\bf i_c   ','i_c'
    '\bf l_c    ','l_c'
    '\bf U_c  ','U_c'
    '\bf V_c  ','V_c'
    '\bf T_c  ','T_c'
    '\bf W_c  ','W_c'
    '\bf Child convention     ','rB_c'};
%     '\bf Key:',''
%     '\bf (h k l)_p      or      (h k i l)_p    =    Parent plane',''
%     '\bf [U V W]_p   or   [U V T W]_p   =   Parent direction',''
%     '\bf (h k l)_c      or      (h k i l)_c     =   Child plane',''
%     '\bf [U V W]_c   or   [U V T W]_c   =   Child direction',''};

%%
formats = struct(...
    'type',{},...
    'style',{},...
    'items',{},...
    'format',{},...
    'span',{});

% Parent plane text
formats(1,1).type = 'text';
formats(1,1).format = 'text';
formats(1,1).span = [1 4];

% Parent plane and direction indices
for ro = 2:3
    for col = 1:4
        formats(ro,col).type = 'edit';
        formats(ro,col).style = 'edit';
        formats(ro,col).format = 'float';
    end
end
defAns = struct([]);
defAns(1).h_p = 1;
defAns.k_p = 1;
defAns.i_p = 0;
defAns.l_p = -1;

defAns.U_p = 1;
defAns.V_p = -1;
defAns.T_p = 0;
defAns.W_p = 0;

% Parent convention radio button
formats(4,1).type = 'list';
formats(4,1).span = [1 4];
formats(4,1).format = 'text';
formats(4,1).style = 'radiobutton';
formats(4,1).items = {'Miller (hkl)[UVW]', 'Miller-Bravais (hkil)[UVTW]'};
defAns.rB_p = 'Miller (hkl)[UVW]';






% Child plane text
formats(9,1).type = 'text';
formats(9,1).format = 'text';
formats(9,1).span = [1 4];

% Child plane and direction indices
for ro = 10:11
    for col = 1:4
        formats(ro,col).type = 'edit';
        formats(ro,col).style = 'edit';
        formats(ro,col).format = 'float';
    end
end
defAns.h_c = 0;
defAns.k_c = 1;
defAns.i_c = 0;
defAns.l_c = -1;

defAns.U_c = 1;
defAns.V_c = -1;
defAns.T_c = 0;
defAns.W_c = -1;

% Child convention radio button
formats(12,1).type = 'list';
formats(12,1).span = [1 4];
formats(12,1).format = 'text';
formats(12,1).style = 'radiobutton';
formats(12,1).items = {'Miller (hkl)[UVW]', 'Miller-Bravais (hkil)[UVTW]'};
defAns.rB_c = 'Miller (hkl)[UVW]';






% formats(16,1).type = 'text'; % Key
% formats(16,1).span = [1 4];
% 
% formats(17,1).type = 'text'; % Parent plane
% formats(17,1).span = [1 2];
% 
% formats(17,3).type = 'text'; % Parent direction
% formats(17,3).span = [1 2];
% 
% formats(18,1).type = 'text'; % Child plane
% formats(18,1).span = [1 2];
% 
% formats(18,3).type = 'text'; % Child direction
% formats(18,3).span = [1 2];


[guiFields,guiCancel] = inputsdlg(prompt,windowTitle,formats,defAns);

if guiCancel == 1
    warning('OR not defined. Please define an OR before continuing.')
    return
    
elseif guiCancel == 0
    if strcmpi(guiFields.rB_p,'Miller (hkl)[UVW]')
        planeParent = Miller(...
            guiFields.h_p,...
            guiFields.k_p,...
            guiFields.l_p,...
            job.csParent,...
            'hkl');
        directionParent = Miller(...
            guiFields.U_p,...
            guiFields.V_p,...
            guiFields.W_p,...
            job.csParent,...
            'uvw');
    elseif strcmpi(guiFields.rB_p,'Miller-Bravais (hkil)[UVTW]')
        planeParent = Miller(...
            guiFields.h_p,...
            guiFields.k_p,...
            guiFields.i_p,...
            guiFields.l_p,...
            job.csParent,...
            'hkil');
        directionParent = Miller(...
            guiFields.U_p,...
            guiFields.V_p,...
            guiFields.T_p,...
            guiFields.W_p,...
            job.csParent,...
            'UVTW');
    end
    
    if strcmpi(guiFields.rB_c,'Miller (hkl)[UVW]')
        planechild = Miller(...
            guiFields.h_c,...
            guiFields.k_c,...
            guiFields.l_c,...
            job.csChild,...
            'hkl');
        directionchild = Miller(...
            guiFields.U_c,...
            guiFields.V_c,...
            guiFields.W_c,...
            job.csChild,...
            'uvw');
    elseif strcmpi(guiFields.rB_c,'Miller-Bravais (hkil)[UVTW]')
        planechild = Miller(...
            guiFields.h_c,...
            guiFields.k_c,...
            guiFields.i_c,...
            guiFields.l_c,...
            job.csChild,...
            'hkil');
        directionchild = Miller(...
            guiFields.U_c,...
            guiFields.V_c,...
            guiFields.T_c,...
            guiFields.W_c,...
            job.csChild,...
            'UVTW');
    end
    
    %--- Define the OR as a misorientation
    p2c = orientation('map',...
        planeParent,...
        planechild,...
        directionParent,...
        directionchild);
end
end
