function [ebsd,grains,gB] = computeGrains(ebsd,varargin)
% Small GUI to compute grains from EBSD data and optionally filter them
%
% Syntax
%
%  [ebsd,grains,gB] = computeGrains(ebsd)
%
% Input
%  ebsd  - @EBSD
%
% Output
%  ebsd     - @EBSD
%  grains   - @grains2d 
%  gB       - @grainBoundary


%% Get min GB angle and min grain size
[criticalAngle,minGrainSize] = setGrainParameters;
%% Compute the grains
screenPrint('Step',sprintf('Computing grains with >%.0f° misorientation',criticalAngle/degree));
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',criticalAngle,'unitcell');
%% Delete small grains (if any)
if ~isnan(minGrainSize)
    screenPrint('Step',sprintf('Deleting EBSD data of grains with <%.0f pxs',minGrainSize));
    % Assign ebsd data of filtered grains to phase 'noIndexed'
    ebsd(grains(grains.grainSize < minGrainSize)).phase = 0;
    % Set the orientation of ebsd data of filtered grains to 0
    ebsd(grains(grains.grainSize < minGrainSize)).rotations = rotation('Euler',0,0,0);
    % Set the error of ebsd data of filtered grains to 3
    ebsd(grains(grains.grainSize < minGrainSize)).prop.error = 3;
    % Set the number of bands of ebsd data of filtered grains to 0
    ebsd(grains(grains.grainSize < minGrainSize)).prop.bands = 0;
    % Set the mean angular deviation of ebsd data of filtered grains to 0
    ebsd(grains(grains.grainSize < minGrainSize)).prop.mad = 0;
    % Recompute grains after the small grains have been removed
    screenPrint('Step',sprintf('Recomputing grains with >%.0f° misorientation',criticalAngle/degree));
    [grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',criticalAngle);
end
%% Compute grain boundaries
screenPrint('Step',sprintf('Computing all grain boundaries'));
gB = grains.boundary;
end

function [crit_gBAngle,minGS] = setGrainParameters
    prompt = {'Critical grain boundary angle [in °]:',...
        'Min. grain size [in pixels]: (keep empty if no grains require removal)'};
    windowTitle = 'Compute grains';
    dims = [1 75; 1 75];
    predefinedInput = {'3',''};
    try
        userInput = inputdlg(prompt,windowTitle,dims,predefinedInput);
        if  sum(isnan(str2double(userInput{1}))) > 0 || sum(isnan(str2double(userInput{2}))) > 0 && ~isempty(userInput{2})
            message = sprintf('Script terminated: Non-numeric input');
            uiwait(warndlg(message));
            return
        end
        if userInput{1} == '0' || isreal(str2double(userInput{1})) == 0
            message = sprintf('Script terminated: Invalid grain boundary angle');
            uiwait(warndlg(message));
            return
        end
        if userInput{2} == '0' || isreal(str2double(userInput{2})) == 0
            message = sprintf('Script terminated: Invalid grain size');
            uiwait(warndlg(message));
            return
        end
    catch
        % This command prevents function execution in cases when
        % the user presses the "Cancel" or "Close" buttons
        if isempty(userInput)
            message = sprintf('Script terminated: Execution aborted by user');
            uiwait(warndlg(message));
            return
        end
    end
    % Critical boundary angle [in radians]
    crit_gBAngle = str2double(userInput{1})*degree;
    % Minimum grain size [in pixels]
    minGS = str2double(userInput{2});
end


