function [ebsd,grains] = recolorPhases(ebsd,grains)
%
% Syntax
%
%  [ebsd,grains] = recolorPhases(ebsd,grains)
%
% Input
%  ebsd             - @EBSD
%  grains           - @grain2d
%
% Output
%  ebsd             - @EBSD
%  grains           - @grain2d

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
            for jj = 2:phaseNum
               ebsd.opt.cRGB(jj,:) = ebsd.CSList{jj}.color;
            end
            [ebsd,grains] = recolorGrains(ebsd,grains);
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
ebsd.opt.cRGB = cRGB;

[ebsd,grains] = recolorGrains(ebsd,grains);
end

