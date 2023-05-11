function ebsd = renamePhases(ebsd,phaseStrings)
%% Function description:
% This function is a GUI to interactively rename phases. It opens a list 
% of phase names (pre-defined in *phaseStrings*) and renames each phase in
% the *ebsd* variable according to a user's selection.
%
%% Syntax:
%  ebsd = renamePhases(ebsd,phStr)
%
%% Input:
%  ebsd             - @EBSD
%  phaseStrings     - cell array of strings with possible phase names
%
%% Output:
%  ebsd             - @EBSD


%% Rename the phases (minerals)
phaseNum = length(ebsd.CSList);
phaseNames = char(ebsd.mineralList(1:numel(ebsd.mineralList)));
% Check if all phase names agree with the names in the EBSD data set
if ~isempty(intersect(ebsd.mineralList(2:numel(ebsd.mineralList)),phaseStrings)) &&...
        all(contains(intersect(ebsd.mineralList,phaseStrings),phaseStrings))
    [~,~,ind] = intersect(ebsd.mineralList,phaseStrings);
    ind = sort(ind);
    fprintf(' -> %s phase(s) automatically identified ''%s''\n',phaseStrings{ind});

else
    fprintf(' -> Identifying phases to rename\n');
    try
        for ii = 2:phaseNum
            fprintf(['    - ''',phaseNames(ii,:),'''']);
            [ind,~] = listdlg('PromptString',['Rename phase corresponding to ''',phaseNames(ii,:),''':'],...
                'SelectionMode','single','ListString',phaseStrings,...
                'ListSize',[300 150]);
            ebsd.CSList{ii}.mineral = phaseStrings{ind};
            fprintf([' renamed to ''',phaseStrings{ind},'''\n']);
        end
    catch
        % This command prevents function execution in cases when
        % the user presses the "Cancel" or "Close" buttons
        message = sprintf('Program terminated: Execution aborted by user');
        uiwait(errordlg(message));
        error('Program terminated: Execution aborted by user');
    end
end
end

