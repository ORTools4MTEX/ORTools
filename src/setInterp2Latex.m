function setInterp2Latex
%% Function description:
% Changes all MATLAB text interpreters from 'tex' to 'latex in all 
% subsequent figures, plots, and graphs.
%
%% Author:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Acknowledgments:
% The first version of this function was posted in:
% https://au.mathworks.com/matlabcentral/answers/183311-setting-default-interpreter-to-latex
%
%% Version(s):
% The first version of this function was posted in:
% https://github.com/ORTools4MTEX/ORTools/blob/develop/setLabels2Latex.m
%
%% Syntax:
% setLabels2Latex
%%

factoryList = fieldnames(get(groot,'factory'));
interpreterIdx = find(contains(factoryList,'Interpreter'));
for ii = 1:length(interpreterIdx)
    defaultName = strrep(factoryList{interpreterIdx(ii)},'factory','default');
    set(groot,defaultName,'latex');
end
end
