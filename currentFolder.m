function currentFolder
%% Change the current folder to the folder of this m-file.
if(~isdeployed)
    folder = fileparts(mfilename('fullpath'));
    cd(folder);
    % Add that folder plus all subfolders to the path.
    addpath(genpath(folder));
end