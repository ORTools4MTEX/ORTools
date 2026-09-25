function ensureFolder(filePath)
%% Function description:
% This function creates the folder that "filePath" is written to, if that
% folder does not exist yet.
%
% Git does not track empty directories, so the subfolders of "data/output"
% are not guaranteed to be present in a freshly cloned repository. Saving
% into a missing folder otherwise fails with:
%   "Cannot create 'inputTexture.mat' because '...\data\output\texture'
%    does not exist."
%
%% Syntax:
%  ensureFolder(filePath)
%
%% Input:
%  filePath - char = the full path of a file that is about to be written,
%                    or the path of the folder itself


if ~(ischar(filePath) || isstring(filePath)) || isempty(filePath)
    error('ensureFolder: expected a non-empty file or folder path.');
end

folderPath = fileparts(char(filePath));

% A bare file name is written to the current folder, which always exists
if isempty(folderPath); return; end

if ~exist(folderPath,'dir')
    [isCreated,message] = mkdir(folderPath);
    if ~isCreated
        error('ensureFolder: could not create ''%s'': %s',folderPath,message);
    end
end
end
