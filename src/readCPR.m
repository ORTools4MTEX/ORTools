function ebsd = readCPR(inPath,fileName)
    % auxiliary function for loading *.cpr data files
    %
    % Syntax
    %  ebsd = readCPR
    %  ebsd = readCPR(inPath)
    %  ebsd = readCPR(inPath, fileName)
    %
    % Input
    %  inPath   - string with path to directory 'xx\yy\zz\'
    %  fileName - string with filename 'xxyyzz.cpr'
    %
    % Output
    %  ebsd     - @EBSD

    % Get filename and path
    fprintf(' -> Load *.cpr file containing EBSD map data\n');
    if nargin == 0
        [fileName,inPath] = uigetfile('.\*.cpr','EBSD map data: Open *.cpr file');
    elseif nargin == 1
        [fileName,inPath] = uigetfile([inPath,'*.cpr'],'EBSD map data: Open *.cpr file');
    end

    % Load file
    if fileName == 0 % cancelled or closed
        message = sprintf('Program terminated: Execution aborted by user');
        uiwait(errordlg(message));
        error('Program terminated: Execution aborted by user');
    else
        fprintf(' -> Loading file ''%s''\n',fileName);
        [ebsd] = loadEBSD_crc([inPath fileName],'interface','crc','convertSpatial2EulerReferenceFrame');
        fprintf(' -> Loaded file ''%s'' successfully\n',fileName);
        % Save filename
        ebsd.opt.fName = fileName;
        ebsd.opt.fPath = inPath;
    end
end

