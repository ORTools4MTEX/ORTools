function OR = ORinfo(mori,varargin)
%% Function description:
% The function extracts orientation relationship (OR) information
% contained in the *job.p2c* structure variable and outputs it in the
% MATLAB command window.
%
%% Syntax:
% OR = ORinfo(mori,varargin)
%
%% Input:
%  mori     - parent to child misorientation
%  varargin - 'silent': suppress command window output
%
%% Output:
%  OR       - structure containing OR information


%% Misorientation
OR.misorientation = mori;

%% CrystalSymmetries
OR.CS.parent = OR.misorientation.CS;
OR.CS.child = OR.misorientation.SS;
OR.parent = OR.CS.parent.mineral;
OR.child = OR.CS.child.mineral;

%% Closest rational parallel planes and directions
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

%% Misorientation of rational OR
OR.misorientationRational = orientation('map',...
    OR.plane.parent,...
    OR.plane.child,...
    OR.direction.parent,...
    OR.direction.child);

%% Misorientation axes
OR.rotationAxis.parent = axis(OR.misorientation,OR.CS.parent);
OR.rotationAxis.parent = setDisplayStyle(OR.rotationAxis.parent,'direction');
OR.rotationAxis.child = axis(OR.misorientation,OR.CS.child);
OR.rotationAxis.child = setDisplayStyle(OR.rotationAxis.child,'direction');

%% Angle between rational and actual OR misorientations
OR.misfit.plane = min(angle(OR.misorientation*OR.plane.parent.symmetrise,OR.plane.child));
OR.misfit.direction = min(angle(OR.misorientation*OR.direction.parent.symmetrise,OR.direction.child));
OR.misfit.axis = min(angle(OR.misorientation*OR.rotationAxis.parent.symmetrise,OR.rotationAxis.child));

%% Variants
OR.variants.orientation = OR.misorientation.variants;
OR.variants.misorientation = OR.misorientation.variants.*inv(OR.misorientation.variants(1));
OR.variants.angle = angle(OR.variants.misorientation);
OR.variants.axis = axis(OR.variants.misorientation,OR.CS.child);
OR.variants.axis = setDisplayStyle(OR.variants.axis,'direction');

%% Screen output
if ~check_option(varargin,'silent')
    screenPrint('Step','Detailed information on the selected OR:');
    screenPrint('SubStep',sprintf(['OR misorientation angle = ',...
        num2str(angle(OR.misorientation)./degree),'°']));

    screenPrint('Step','Parallel planes');
    screenPrint('SubStep',sprintf(['Closest parent plane = ',...
        sprintMiller(OR.plane.parent,'round')]));
    screenPrint('SubStep',sprintf(['Closest child plane = ',...
        sprintMiller(OR.plane.child,'round')]));
    screenPrint('SubStep',sprintf(['Disor. of parallel plane relationship from OR = ',...
        num2str(OR.misfit.plane./degree),'°']));

    screenPrint('Step','Parallel directions');
    screenPrint('SubStep',sprintf(['Closest parent direction = ',...
        sprintMiller(OR.direction.parent,'round')]));
    screenPrint('SubStep',sprintf(['Closest child direction = ',...
        sprintMiller(OR.direction.child,'round')]));
    screenPrint('SubStep',sprintf(['Disor. of parallel directions relationship from OR = ',...
        num2str(OR.misfit.direction./degree),'°']));

    screenPrint('Step','OR misorientation rotation axes');
    screenPrint('SubStep',sprintf(['Parent rot. axis = ',...
        sprintMiller(OR.rotationAxis.parent)]));
    screenPrint('SubStep',sprintf(['Child rot. axis = ',...
        sprintMiller(OR.rotationAxis.child)]));
    screenPrint('SubStep',sprintf(['Disor. of parallel rot. axes relationship from OR = ',...
        num2str(OR.misfit.axis./degree),'°']));

    screenPrint('Step','Angle & rot. axes of unique variants');
    for ii = 1:length(OR.variants.orientation)
        screenPrint('SubStep',sprintf([num2str(ii),': ',...
            num2str(OR.variants.angle(ii)./degree,'%2.2f'),...
            '° / ',sprintMiller(OR.variants.axis(ii))]));
    end

else
    screenPrint('SubStep',['OR =\t',...
        sprintMiller(OR.plane.parent,'round'),'_p || ',...
        sprintMiller(OR.plane.child,'round'),'_c,\t',...
        'Ang. dev: ',num2str(OR.misfit.plane./degree),'°\n',...
        '\t\t\t',sprintMiller(OR.direction.parent,'round'),'_p || ',...
        sprintMiller(OR.direction.child,'round'),'_c,\t',...
        'Ang. dev: ',num2str(OR.misfit.direction./degree),'°']);
end
end



%% ANCILLARY FUNCTIONS

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

%% Screenprint Crystal Planes or Directions
function s = sprintMiller(m,varargin)
if any(strcmpi(m.dispStyle,{'hkl','hkil'}))
    if strcmpi(m.dispStyle,'hkil')
        mLabel = {'h','k','i','l'};
    elseif strcmpi(m.dispStyle,'hkl')
        mLabel = {'h','k','l'};
    end
    if check_option(varargin,'round')
        [m,~] = intMiller(m);
    end  
    s = '(';
    for ii = 1:length(mLabel)
        if check_option(varargin,'round')
            s = [s,num2str(m.(mLabel{ii}))];
        else
            s = [s,num2str(m.(mLabel{ii}),'%0.4f')];
        end
        if ii<length(mLabel)
            s = [s,','];
        end
    end
    s = [s,')'];
elseif any(strcmpi(m.dispStyle,{'uvw','UVTW'}))
    if strcmpi(m.dispStyle,'UVTW')
        mLabel = {'U','V','T','W'};
    elseif strcmpi(m.dispStyle,'uvw')
        mLabel = {'u','v','w'};
    end
    if check_option(varargin,'round')
        [m,~] = intMiller(m);
    end
    s = '[';
    for ii = 1:length(mLabel)
        if check_option(varargin,'round')
            s = [s,num2str(m.(mLabel{ii}))];
        else
            s = [s,num2str(m.(mLabel{ii}),'%0.4f')];
        end
        if ii<length(mLabel)
            s = [s,','];
        end
    end
    s = [s,']'];
end
end

function [outMiller,delta] = intMiller(inMiller)
if isa(inMiller,'Miller')
    if any(strcmpi(inMiller.CS.lattice,{'hexagonal','trigonal'}))
        if all(inMiller.dispStyle == 'hkil') %inMiller.dispStyle == 'hkil'
            m = [inMiller.h inMiller.k inMiller.i inMiller.l];
            m = m./findMin(m);
            m = round(m.*1E4)./1E4;
            m = round(m,0);
            outMiller = Miller(m(1),m(2),m(3),m(4),inMiller.CS,'plane');

        elseif all(inMiller.dispStyle == 'UVTW') %inMiller.dispStyle == 'UVTW'
            n = [inMiller.U inMiller.V inMiller.T inMiller.W];
            n = n./findMin(n);
            n = round(n.*1E4)./1E4;
            n = round(n,0);
            outMiller = Miller(n(1),n(2),n(3),n(4),inMiller.CS,'direction');
        end

    else % for all other CS
        if all(inMiller.dispStyle == 'hkl') %inMiller.dispStyle == 'hkl'
            m = [inMiller.h inMiller.k inMiller.l];
            m = m./findMin(m);
            m = round(m.*1E4)./1E4;
            m = round(m,0);
            outMiller = Miller(m(1),m(2),m(3),inMiller.CS,'plane');

        elseif all(inMiller.dispStyle == 'uvw') %inMiller.dispStyle == 'uvw'
            n = [inMiller.u inMiller.v inMiller.w];
            n = n./findMin(n);
            n = round(n.*1E4)./1E4;
            n = round(n,0);
            outMiller = Miller(n(1),n(2),n(3),inMiller.CS,'direction');
        end
    end
end
delta = angle(inMiller,outMiller);
end

function minA = findMin(a)
% a(a < 0.3333) = 0;
a(a == 0) = inf;
minA = min(abs(a),[],2);
end



