function obj = recolorPhases(obj)
%% Function description:
% This function is a GUI to interactively recolor phases in the *ebsd* 
% or *grains* variables.
%
%% Syntax:
%  ebsd   = recolorPhases(ebsd)
%  grains = recolorPhases(grains)
%
%% Input:
%  ebsd             - @EBSD
%  grains           - @grains
%
%% Output:
%  ebsd             - @EBSD
%  grains           - @grains


% % If old style color seleUI needed, type the following and re-start Matlab
% % setpref('Mathworks_uisetcolor', 'Version', 1);

%% Recolor the phases (minerals)
if isa(obj,'EBSD') || isa(obj,'grain2d')
fprintf(' -> Define the phase color\n');
numPhases = length(obj.CSList);
phaseName = char(obj.mineralList(1:numel(obj.mineralList)));
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
            obj.CSList{ii}.color = cRGB;
            clear cRGB
        end
        
    catch
    end
end
else
    msg = 'Incorrect variable type: Only "ebsd" or "grains" accepted.';
    error(msg);
end
end
