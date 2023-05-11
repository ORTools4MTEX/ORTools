function setInterp2Tex
%% Function description:
% This function changes all MATLAB text interpreters from 'latex' to 'tex'
% in all subsequent figures, plots, and graphs.
%
%% Syntax:
% setLabels2Latex

factoryList = fieldnames(get(groot,'factory'));
interpreterIdx = find(contains(factoryList,'Interpreter'));
for ii = 1:length(interpreterIdx)
    defaultName = strrep(factoryList{interpreterIdx(ii)},'factory','default');
    set(groot,defaultName,'tex');
end
end

