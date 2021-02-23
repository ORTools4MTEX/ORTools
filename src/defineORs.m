function job = defineORs(job)
% auxiliary function to define orientation relationships for given parent
% and child phase in "job" by:
%    - Parallel Planes Directions in a GUI
%    - Peakfit of the parent-child boundary misorientation angle
%      distribution
%
% Syntax
%  job = defineORs(job)
%
% Input
%  job  - @parentGrainreconstructor

% Check if p2c boundaries exist
if isempty(job.parentGrains)
    p2c = guiOR(job);
    ORnumber = 1;
else
    % Method selection
    methodTypes = {'Define','Peak-fit','Cancel'};
    try
        loadMode = questdlg('Define an OR or peak-fit ORs from parent-child grain boundaries', ...
            'Method selection', methodTypes{:},methodTypes{1});
    catch
    end
    
    % This command prevents function execution in cases when
    % the user presses the "Cancel" or "Close" buttons
    if isempty(loadMode) || strcmp(loadMode,methodTypes{3})
        message = sprintf('Script terminated: Execution aborted by user');
        uiwait(warndlg(message));
        return
        
    elseif strcmp(loadMode,'Define') || strcmp(loadMode,methodTypes{1})
        p2c = guiOR(job);
        ORnumber = 1;
        
    elseif strcmp(loadMode,'Peak-fit') || strcmp(loadMode,methodTypes{2})
        % Compute the parent-child misorientation distribution histogram
        [classRange,classInterval,counts] = computePCHistogram(job);
        % Fit the parent-child misorientation distribution histogram
        [misoRange] = gaussFit(classRange,classInterval,counts);
        % Find the parent-child orientation relationships
        [p2c] = peakFitORs(job,misoRange);
        ORnumber = selectORnumber(p2c);
        close all
    end
end
% Update p2c
job.p2c = p2c(ORnumber);
ORinfo(job.p2c);
end

function [classRange,classInterval,counts] = computePCHistogram(job)
    % Graphical user interface for definition of an orientation relationship by
    % parallel planes and directions
    %
    % Syntax
    %  [classRange,classInterval,counts] = computePCHistogram(job)
    %
    % Input
    %  job          - @parentGrainreconstructor
    %
    % Output
    %  p2c          - parent to child orientation relationship

    if ~isempty(job.grains.boundary(job.csParent.mineral,job.csChild.mineral))
        % Computing the parent-child boundary misorientation distribution histogram
        screenPrint('Step',sprintf('Computing the parent-child misorientation distribution histogram'));
        %--- Calculate the misorientation angle of the interface in the lower symmetry crystal reference frame
        misoAngleList = job.grains.boundary(job.csParent.mineral,job.csChild.mineral).misorientation.angle./degree;
        %--- Find the optimal bin width (or class interval) for the distribution
        fR = fundamentalRegion(job.csParent,job.csChild);
        [~, classInterval.coarse, ~] = sshist(misoAngleList,fR.maxAngle/degree);
        %--- Define the class interval and range
        classRange.all = [-1: classInterval.coarse: fR.maxAngle/degree]';

        %--- Get the number of absolute counts in each class interval
        counts.absolute.all = histc(misoAngleList,classRange.all);
        %--- Normalise the absolute counts in each class interval
        counts.normalised.all = 1.*(counts.absolute.all./sum(counts.absolute.all));

        % Define a fine class interval to interpolate the distribution
        classInterval.fine = 0.1;  
        % Re-define x-axis data based on the fine class interval
        classRange.pchip = [-1: classInterval.fine: max(classRange.all)]';
        % Use the Piecewise Cubic Hermite Interpolating Polynomial (PCHIP) to interpolate y-axis data
        counts.normalised.pchip = pchip(classRange.all,counts.normalised.all,classRange.pchip);
    else
        warning('No parent-child misorientation data to analyze');
        classRange = []; classInterval = []; counts = [];
    end

end


function [ORnumber] = selectORnumber(p2c)
    % Auxiliary function for selcting one out of several fitted OR's 
    %
    % Syntax
    %  [ORnumber] = selectORnumber(p2c)
    %
    % Input
    %  p2c  - parent to child orientation relationship
    %
    % Output
    %  ORnumber     - number of selected OR

    prompt = {'Select a peak-fit OR by its number to continue:'};
    windowTitle = 'Select a peak-fit OR';
    dims = [1 75];
    predefinedInput = {'1'};
    try
        userInput = inputdlg(prompt,windowTitle,dims,predefinedInput);

        if  sum(isnan(str2double(userInput{1}))) > 0
            message = sprintf('Script terminated: Non-numeric input');
            uiwait(warndlg(message));
            return
        end
        if userInput{1} == '0' ||...
                isreal(str2double(userInput{1})) == 0 ||...
                isreal(str2double(userInput{1})) > length(p2c)
            message = sprintf('Script terminated: Invalid OR identification number');
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
    % Return the user-defined OR number
    ORnumber = str2double(userInput{1});
end