function OR = ORinfo(mori,varargin)
% Extract OR information in a structure variable
% Syntax
% OR = ORinfo(mori,varargin)
% Input
%  mori     - parent to child misorientation
%  varargin - 'silent': suppress command window output
% Output
%  OR       - structure containing OR information


%Misorientation
OR.misorientation = mori;

%CrystalSymmetries
OR.CS.parent = OR.misorientation.CS;
OR.CS.child = OR.misorientation.SS;
OR.parent = OR.CS.parent.mineral;
OR.child = OR.CS.child.mineral;

%Closest rational parallel planes and directions
[OR.plane.parent,...
    OR.plane.child,...
    OR.direction.parent,...
    OR.direction.child] = ...
    round2Miller(OR.misorientation);
%round2Miller(OR.misorientation,'maxHKL',15);

OR.plane.parent = setDisplayStyle(OR.plane.parent,'plane');
OR.plane.child = setDisplayStyle(OR.plane.child,'plane');
OR.direction.parent = setDisplayStyle(OR.direction.parent,'direction');
OR.direction.child = setDisplayStyle(OR.direction.child,'direction');

%Misorientation of rational OR
OR.misorientationRational = orientation('map',...
    OR.plane.parent,...
    OR.plane.child,...
    OR.direction.parent,...
    OR.direction.child);

%Misorientation axes
OR.rotationAxis.parent = axis(OR.misorientation,OR.CS.parent);
OR.rotationAxis.parent = setDisplayStyle(OR.rotationAxis.parent,'direction');
OR.rotationAxis.child = axis(OR.misorientation,OR.CS.child);
OR.rotationAxis.child = setDisplayStyle(OR.rotationAxis.child,'direction');

%Angle between rational and actual OR misorientations
OR.misfit.plane = min(angle(OR.misorientation*OR.plane.parent.symmetrise,OR.plane.child));
OR.misfit.direction = min(angle(OR.misorientation*OR.direction.parent.symmetrise,OR.direction.child));
OR.misfit.axis = min(angle(OR.misorientation*OR.rotationAxis.parent.symmetrise,OR.rotationAxis.child));

%Variants
OR.variants.orientation = OR.misorientation.variants;
OR.variants.misorientation = OR.misorientation.variants.*inv(OR.misorientation.variants(1));
OR.variants.angle = angle(OR.variants.misorientation);
OR.variants.axis = axis(OR.variants.misorientation,OR.CS.child);
OR.variants.axis = setDisplayStyle(OR.variants.axis,'direction');

%Screen output
if ~check_option(varargin,'silent')
    screenPrint('Step','Detailed information on the selected OR:');
    screenPrint('SubStep',sprintf(['OR misorientation angle = ',...
        num2str(angle(OR.misorientation)./degree),'º']));
    
    screenPrint('Step','Parallel planes');
    screenPrint('SubStep',sprintf(['Closest parent plane = ',...
        sprintMiller(OR.plane.parent,'round')]));
    screenPrint('SubStep',sprintf(['Closest child plane = ',...
        sprintMiller(OR.plane.child,'round')]));
    screenPrint('SubStep',sprintf(['DisorN. of parallel plane relationship from OR = ',...
        num2str(OR.misfit.plane./degree),'º']));
    
    screenPrint('Step','Parallel directions');
    screenPrint('SubStep',sprintf(['Closest parent direction = ',...
        sprintMiller(OR.direction.parent,'round')]));
    screenPrint('SubStep',sprintf(['Closest child direction = ',...
        sprintMiller(OR.direction.child,'round')]));
    screenPrint('SubStep',sprintf(['DisorN. of parallel directions relationship from OR = ',...
        num2str(OR.misfit.direction./degree),'º']));
    
    screenPrint('Step','OR misorientation rotation axes');
    screenPrint('SubStep',sprintf(['Parent rot. axis = ',...
        sprintMiller(OR.rotationAxis.parent)]));
    screenPrint('SubStep',sprintf(['Child rot. axis = ',...
        sprintMiller(OR.rotationAxis.child)]));
    screenPrint('SubStep',sprintf(['DisorN. of parallel rot. axes relationship from OR = ',...
        num2str(OR.misfit.axis./degree),'º']));
    
    screenPrint('Step','Angle & rot. axes of unique variants');
    for ii = 1:length(OR.variants.orientation)
        screenPrint('SubStep',sprintf([num2str(ii),': ',...
            num2str(OR.variants.angle(ii)./degree,'%2.2f'),...
            'º / ',sprintMiller(OR.variants.axis(ii))]));
    end
    
else
    screenPrint('SubStep',['OR =\t',...
        sprintMiller(OR.plane.parent,'round'),'_p || ',...
        sprintMiller(OR.plane.child,'round'),'_c,\t',...
        'Ang. dev: ',num2str(OR.devAngle.plane./degree),'º\n',...
        '\t\t\t',sprintMiller(OR.direction.parent,'round'),'_p || ',...
        sprintMiller(OR.direction.child,'round'),'_c,\t',...
        'Ang. dev: ',num2str(OR.devAngle.direction./degree),'º']);
    
end
end

%% Set Display Style of Miller objects
function m = setDisplayStyle(millerObj,mode)
m = millerObj;
if isa(m,'Miller')
    if any(strcmpi(m.CS.lattice,{'hexagonal','trigonal'})) == 1
        if strcmpi(mode,'direction')
            m.dispStyle = 'UVTW';
        elseif strcmpi(mode,'plane')
            m.dispStyle = 'hkil';
        end
    else
        if strcmpi(mode,'direction')
            m.dispStyle = 'uvw';
        elseif strcmpi(mode,'plane')
            m.dispStyle = 'hkl';
        end
    end
end
end

%% Print Crystal Planes
function s = sprintMiller(mil,varargin)
if any(strcmpi(mil.dispStyle,{'hkl','hkil'}))
    if strcmpi(mil.dispStyle,'hkil')
        mill = {'h','k','i','l'};
    elseif strcmpi(mil.dispStyle,'hkl')
        mill = {'h','k','l'};
    end
    s = '(';
    for i = 1:length(mill)
        if check_option(varargin,'round')
            s = [s,num2str(round(mil.(mill{i}),0))];
        else
            s = [s,num2str(mil.(mill{i}),'%0.4f')];
        end
        if i<length(mill)
            s = [s,','];
        end
    end
    s = [s,')'];
elseif any(strcmpi(mil.dispStyle,{'uvw','UVTW'}))
    if strcmpi(mil.dispStyle,'UVTW')
        mill = {'U','V','T','W'};
    elseif strcmpi(mil.dispStyle,'uvw')
        mill = {'u','v','w'};
    end
    s = '[';
    for i = 1:length(mill)
        if check_option(varargin,'round')
            s = [s,num2str(round(mil.(mill{i}),0))];
        else
            s = [s,num2str(mil.(mill{i}),'%0.4f')];
        end
        if i<length(mill)
            s = [s,','];
        end
    end
    s = [s,']'];
end
end


