function [ebsd] = recolorPhases(ebsd)
% recolor phases in ebsd and grains interactively
%
% Syntax
%
%  [ebsd] = recolorPhases(ebsd)
%
% Input
%  ebsd             - @EBSD
%
% Output
%  ebsd             - @EBSD

% If old style color seleUI needed, type the following and re-start Matlab
% setpref('Mathworks_uisetcolor', 'Version', 1);

%% ReColor the phases (minerals)
fprintf(' -> Define the phase color\n');
phaseNum = length(ebsd.CSList);
phaseNames = char(ebsd.mineralList(1:numel(ebsd.mineralList)));
%% Auto-generate grayscale colors
scale = linspace(0.3,0.95,phaseNum+1)';
ebsd.opt.cGS = repmat(scale(1:end-1),1,3);
%% Selecting colors
fprintf(' -> Recoloring all phases\n');
cRGB = ones(phaseNum,3);
for ii = 2:phaseNum    
    fprintf('    - ''%s''\n',phaseNames(ii,:))
    promptString = ['Define RGB for ''',phaseNames(ii,:),''''];
    try
        tempRGB = uisetcolor([],promptString);
        
        if tempRGB == 0 %%&& size(tempRGB,2) == 1
            % Response to "Cancel" or "Close" buttons
            warning('Phase recoloring aborted by user: Keeping default colors');
                return
        else
            %% Add phase colors
            cRGB(ii,:) = tempRGB;
            clear tempRGB
            ebsd.CSList{ii}.color = cRGB(ii,:);            
        end
    catch
    end
end
end




