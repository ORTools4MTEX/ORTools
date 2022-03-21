function job = defineORs(job)
    % auxiliary function to define orientation relationships for given parent
    % and child phase in 'job' by:
    %    - Parallel planes & directions in a GUI or,
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
        ORNumber = 1;
    else
        % Method selection
        methodTypes = {'Define','Peak-fit','Cancel'};
        try
            loadMode = questdlg('Define an OR or peak-fit ORs from parent-child grain boundaries', ...
                'Method selection', methodTypes{:},methodTypes{1});
        catch
        end

        % This command prevents function execution in cases when
        % the user presses the 'Cancel' or 'Close' buttons
        if isempty(loadMode) || strcmpi(loadMode,methodTypes{3})
            message = sprintf('Script terminated: Execution aborted by user');
            uiwait(warndlg(message));
            return

        elseif strcmpi(loadMode,'Define') || strcmpi(loadMode,methodTypes{1})
            p2c = guiOR(job);
            ORNumber = 1;

        elseif strcmpi(loadMode,'Peak-fit') || strcmpi(loadMode,methodTypes{2})
            % Compute the parent-child misorientation distribution histogram
            f = msgbox(['Use LEFT and RIGHT keyboard arrows to define the threshold for the peak(s)',...
                       'fitting and press enter to continue']);
            uiwait(f);
            [classRange,classInterval,counts] = computePCHist(job);
            % Fit the parent-child misorientation distribution histogram
            [misoRange] = gaussFit(classRange,classInterval,counts);
            % Find the parent-child orientation relationships
            [p2c] = peakFitORs(job,misoRange);
            if length(p2c) > 1
                ORNumber = setORNumber(p2c);
            else
                ORNumber = 1;
            end
            close gcf
        end
    end

    % Update p2c
    if length(ORNumber) > 1
        for ii = ORNumber
           newJob{ii} = parentGrainReconstructor(job.ebsd,job.grains,p2c(ii));
        end  
        job = newJob;
    else  
        job.p2c = p2c(ORNumber);
        ORinfo(job.p2c);
    end
end

function [classRange,classInterval,counts] = computePCHist(job)
    % Graphical user interface for definition of an orientation relationship by
    % parallel planes and directions
    %
    % Syntax
    %  [classRange,classInterval,counts] = computePCHist(job)
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


function [ORNumber] = setORNumber(p2c)
    % Auxiliary function for selcting one out of several fitted OR's 
    %
    % Syntax
    %  [ORNumber] = setORNumber(p2c)
    %
    % Input
    %  p2c  - parent to child orientation relationship
    %
    % Output
    %  ORNumber     - number of selected OR
    
    list = arrayfun(@num2str, 1:length(p2c), 'UniformOutput', 0);
    list = [list,{'All ORs'}];

    ind = listdlg('PromptString',{'Select the OR to continue with.',...
                    'All ORs returns a cell array of ORs.',''}, ...
                    'SelectionMode','single',...
                    'ListString',list);
    if isempty(ind)
        message = sprintf('Script terminated: Execution aborted by user');
        uiwait(warndlg(message));
        return
    end

    % Return the user-defined OR number    
    if ind == length(list), ind = 1:length(list)-1; end
    ORNumber = ind;
end



