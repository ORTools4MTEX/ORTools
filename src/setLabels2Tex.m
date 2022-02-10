function setLabels2Tex
% https://au.mathworks.com/matlabcentral/answers/183311-setting-default-interpreter-to-latex
% Change all interpreters from 'latex' to 'tex'
factoryList = fieldnames(get(groot,'factory'));
interpreterIdx = find(contains(factoryList,'Interpreter'));
for ii = 1:length(interpreterIdx)
    defaultName = strrep(factoryList{interpreterIdx(ii)},'factory','default');
    set(groot,defaultName,'tex');
end
end
