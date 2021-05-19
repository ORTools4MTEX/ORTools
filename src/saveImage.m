function saveImage(fileDir,fileName)
% Save all open figures
%
% Syntax
% saveImage(fileDir,fileName)
% saveImage(fileDir)
% saveImage
%
% Input
%  fileName    - file name (string with file of type *.bmp, *.jpeg, *.png or *.tiff )
%  fileDir     - file directory


% Compute the number of figure windows currently open
openFigs = get(0,'Children');
numOpenFigs = size(openFigs,1);
if numOpenFigs == 0
    error('Image save terminated: No open figures');
    
else % Figure windows are open
    if nargin == 2
        fileNameType = fileName; 
        fileIdx = 3;
    else
        if nargin == 0; fileDir = pwd; end
        [fileNameType,fileDir,fileIdx] = uiputfile(...
            {'*.bmp','Microsoft Windows Bitmap';...
            '*.jpeg','Joint Photographic Experts Group';...
            '*.png','Portable Network Graphics';...
            '*.tiff','Tagged Image File Format';...
            '*.*','All files (*.*)'},...
            'Save file',[fileDir,'/','*.png']);
    end    
    % In the function 'uiputfile' if the selected file exists in the
    % folder, MATLAB auto-prompts the user with a new GUI window asking
    % for confirmation to overwrite the file.
    % This extra step is not needed in this function but cannot be avoided.
    
    % This function auto-checks for an existing file name.
    % It prevents the over-writing of existing image files by adding
    % incremental numbers as suffixes to the saved file name.

    if fileIdx >=1 && fileIdx <= 4
        % Continue execution as the user inputted or selected a file name
        [~,fileName,fileType] = fileparts(fileNameType);
        
        % Check if file(s) with the same name and type exist(s) in the folder
        if exist([fileDir,fileNameType],'file') == 2
            % Find the number of files with the same name and type in the folder
            fileStruc = dir([fileDir,fileName,'*',fileType]);
            fileNameList = {fileStruc.name};
            numFilesInFolder = sum(contains(fileNameList,fileName));
            disp([num2str(numFilesInFolder),' file(s) of this name & type exist(s) in the folder']);
        else
            numFilesInFolder = 0;
        end
        
        % Save all images in the specified format
        for numFigs2Save = (numFilesInFolder+1):(numFilesInFolder+numOpenFigs)
            figure(numFigs2Save-numFilesInFolder);
            set(gcf,'PaperPositionMode','auto');
            figFileName = sprintf(strcat(fileName,'_%02d',fileType),numFigs2Save);
            % Define the image format
            imgType = join(['-d',extractAfter(fileType,'.')]);
            imgType = char(strrep(imgType,' ',''));

            % Case sensitive re-check for the correct image format
            if any(strcmp(imgType,{'-dbmp','-djpeg','-dpng','-dtiff'}))
                % Save images
                print([fileDir,figFileName],imgType,'-r0');
                disp(['Image saved as: ',figFileName]);
            else
                warning('Choose *.bmp, *.jpeg, *.png or *.tiff image types only');
                error('Image save terminated: Incorrect image type');
            end
        end
        
    elseif fileIdx == 5
        % If user selected 'All files (*.*)'
        warning('Choose *.bmp, *.jpeg, *.png or *.tiff image types only');
        error('Image save terminated: Incorrect image type');
    
    elseif fileIdx == 0
        % If user closed the UI window or pressed 'Cancel'
        warning('Image save terminated: Execution aborted by user');
        return
    end

end
end
%---