function currentFolder
%% Change the current folder to the folder of this m-file.
if(~isdeployed)
    folder = fileparts(mfilename('fullpath'));
    cd(folder);
    % Add that folder plus all subfolders to the path.
    addpath(genpath(folder));
    % ... then make the compatibility shims visible only on those MATLAB
    % releases that do not provide the function themselves.
    addCompatibilityShims(fullfile(folder,'library','compat'));
end
end


function addCompatibilityShims(compatFolder)
%% Put a compatibility shim on the path only if MATLAB lacks the function
% "library/compat" holds one subfolder per shimmed function, named after
% that function. The addpath(genpath(...)) above has already added them all,
% so remove each one first and then re-add it only if this release actually
% needs it. A shim left on the path on a newer release would shadow MATLAB's
% own implementation, which handles cases the shims do not.
if ~isfolder(compatFolder); return; end

shims = dir(compatFolder);
shims = shims([shims.isdir] & ~startsWith({shims.name},'.'));

bakWarn = warning('off','MATLAB:rmpath:DirNotFound');
for ii = 1:numel(shims)
    functionName = shims(ii).name;
    shimFolder = fullfile(compatFolder,functionName);
    % Take the shim off the path so that "which" reports on MATLAB's own
    % function rather than on the shim itself
    rmpath(shimFolder);
    if isempty(which(functionName))
        addpath(shimFolder);
    end
end
warning(bakWarn);
end
