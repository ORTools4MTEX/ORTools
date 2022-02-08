function setLabels2Latex
% https://au.mathworks.com/matlabcentral/answers/183311-setting-default-interpreter-to-latex
% Change all interpreters from 'tex' to 'latex'
factoryList = fieldnames(get(groot,'factory'));
interpreterIdx = find(contains(factoryList,'Interpreter'));
for ii = 1:length(interpreterIdx)
    defaultName = strrep(factoryList{interpreterIdx(ii)},'factory','default');
    set(groot,defaultName,'latex');
end
end


% set(0,'defaultTextInterpreter','latex');
% set(groot,'defaultAxesTickLabelInterpreter','latex');
% set(groot,'defaultLegendInterpreter','latex');

% ylabel('Relative block boundary frequency [$f$(g)]');
% ylabel('\bf Relative block boundary frequency [$\bf f$(g)]');
% ylabel('Block boundary density [$\mu m / \mu m^{2}$]')
% ylabel('\bf Block boundary density [$\bf \mu m / \mu m^{2}$]')