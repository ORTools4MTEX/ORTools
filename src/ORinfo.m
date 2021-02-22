function OR = ORinfo(p2c,varargin)
    % Extract OR information in a structure variable
    %
    % Syntax
    % OR = ORinfo(p2c)
    %
    % Input
    %  p2c     - parent to child misorientation
    %
    % Output
    %  OR       - structure containing OR information
    %
    % Options
    %  silent - suppress command window output

    %Misorientation
    OR.misorientation = p2c;

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
        round2Miller(OR.misorientation,'maxHKL',15);

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

    %Deviation angle between rational and actual OR misorientations
    OR.devAngle.plane = min(angle(OR.misorientation*OR.plane.parent.symmetrise,OR.plane.child));
    OR.devAngle.direction = min(angle(OR.misorientation*OR.direction.parent.symmetrise,OR.direction.child));

    %Misorientation axes
    OR.misorientationAxis.parent = axis(OR.misorientation,OR.CS.parent);
    OR.misorientationAxis.parent = setDisplayStyle(OR.misorientationAxis.parent,'direction');
    OR.misorientationAxis.child = axis(OR.misorientation,OR.CS.child);
    OR.misorientationAxis.child = setDisplayStyle(OR.misorientationAxis.child,'direction');

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
        screenPrint('SubStep',sprintf(['Ang. dev. of parallel plane relationship from OR = ',...
            num2str(OR.devAngle.plane./degree),'º']));

        screenPrint('Step','Parallel directions');
        screenPrint('SubStep',sprintf(['Closest parent direction = ',...
            sprintMiller(OR.direction.parent,'round')]));
        screenPrint('SubStep',sprintf(['Closest child direction = ',...
            sprintMiller(OR.direction.child,'round')]));
        screenPrint('SubStep',sprintf(['Ang. dev. of parallel directions relationship from OR = ',...
            num2str(OR.devAngle.direction./degree),'º']));

        screenPrint('Step','OR misorientation rotation axes');
        screenPrint('SubStep',sprintf(['Parent rot. axis = ',...
            sprintMiller(OR.misorientationAxis.parent)]));
        screenPrint('SubStep',sprintf(['Child rot. axis = ',...
            sprintMiller(OR.misorientationAxis.child)]));

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

function screenPrint(mode,varargin)
    switch mode
        case 'StartUp'
            titleStr = varargin{1};
            fprintf('\n*************************************************************');
            fprintf(['\n                 ',titleStr,' \n']);
            fprintf('*************************************************************\n'); 
        case 'Termination'
            titleStr = varargin{1};
            fprintf('\n*************************************************************');
            fprintf(['\n                 ',titleStr,' \n']);
            fprintf('*************************************************************\n'); 
        case 'SegmentStart'
            titleStr = varargin{1};
            fprintf('\n------------------------------------------------------');
            fprintf(['\n     ',titleStr,' \n']);
            fprintf('------------------------------------------------------\n'); 
       case 'Step'
            titleStr = varargin{1};
            fprintf([' -> ',titleStr,'\n']);
       case 'SubStep'
            titleStr = varargin{1};
            fprintf(['    - ',titleStr,'\n']);
       case 'SegmentEnd'
            fprintf('\n------------------------------------------------------\n');
    end
end


