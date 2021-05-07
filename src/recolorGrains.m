function grains = recolorGrains(grains)
% recolor phases in ebsd and grains interactively
%
% Syntax
%
%  grains = recolorGrains(grains)
%
% Input
%  grains             - @grains
%
% Output
%  grains             - @grains

% If old style color seleUI needed, type the following and re-start Matlab
% setpref('Mathworks_uisetcolor', 'Version', 1);

%% Recolor the phases (minerals)
fprintf(' -> Define the phase color\n');
numPhases = length(grains.CSList);
phaseName = char(grains.mineralList(1:numel(grains.mineralList)));
%% Selecting colors
fprintf(' -> Recoloring all phases\n');
for ii = 2:numPhases
    fprintf('    - ''%s''\n',phaseName(ii,:))
    promptString = ['Define RGB for ''',phaseName(ii,:),''''];
    try
        cRGB = uisetcolor([],promptString);
        
        if cRGB == 0 % Response to "Cancel" or "Close" buttons
            warning('Phase recoloring aborted by user: Keeping previous colors');
            return
        else % Recolor phase
            grains.CSList{ii}.color = cRGB;
            clear cRGB
        end
        
    catch
    end
end
end




