function setInterp2Latex
%% Function description:
% This function changes all MATLAB text interpreters from 'tex' to 'latex 
% in all subsequent figures, plots, and graphs.
%
%% Syntax:
% setLabels2Latex


factoryList = fieldnames(get(groot,'factory'));
interpreterIdx = find(contains(factoryList,'Interpreter'));
for ii = 1:length(interpreterIdx)
    defaultName = strrep(factoryList{interpreterIdx(ii)},'factory','default');
    set(groot,defaultName,'latex');
end
end
