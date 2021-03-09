function f = plotPODF_transformation(job,hParent,hChild,varargin)
% plot transformation texture from VPSC file 
%
% Syntax
%  f = plotPODF_transformation(job,hParent,hChild)
%
% Input
%  hParent     - @Miller (parent polefigures to plot)
%  hChild      - @Miller (child polefigures to plot)
%
% Options
%  odfSecP      - array with angles of parent ODF section to display
%  odfSecC      - array with angles of child ODF section to display
%  variantId    - list with specific variant Ids to plot
%  variantWt    - list with specific variant weights to plot
%  halfwidth    - halfwidth for ODF calculation
%  nrPoints     - nr of points to be written into the VPSC file
%  colormap     - colormap string
%  path         - path to the texture file

odfSecP = get_option(varargin,'odfSecP',[0 45 65]*degree);
odfSecC = get_option(varargin,'odfSecC',[0 45 90]*degree);
variantId = get_option(varargin,'variantId',[]);
variantWt = get_option(varargin,'variantWt',[]);
hwidth = get_option(varargin,'halfwidth',2.5);
nrPoints = get_option(varargin,'nrPoints',1000);
cmapP = get_option(varargin,'colormapP','jet');
cmapC = get_option(varargin,'colormapC','hot');
pathName = get_option(varargin,'path','');

ORinfo(job.p2c,'silent');

%--- Define specimen symmetry
ss = specimenSymmetry('triclinic');


%--- Import the VPSC ODF file into memory
fileName = 'inputVPSC.Tex';
[oriP,prop] = orientation.load([pathName,fileName],job.csParent,ss,'interface','generic',...
    'ColumnNames', {'phi1' 'Phi' 'phi2' 'weights'}, 'Columns', [1 2 3 4], 'Bunge'); 
%---

%--- Calculate the orientation distribution function and define the specimen symmetry of the parent
oriP = oriP(:);
wtP = prop.weights; 
wtP = wtP(:);
odfP = calcDensity(oriP,'weights',wtP,'halfwidth',hwidth*degree,'points','all');
odfP.SS = specimenSymmetry('orthorhombic');
%--- Calculate the parent pole figures from the parent orientation distribution function 
pfP = calcPoleFigure(odfP,hParent,regularS2Grid('resolution',2.5*degree),'antipodal');

%% Find all the possible child orientations 
oriC = variants(job.p2c, oriP, job.variantMap);

if ~isempty(variantId) && ~isempty(variantWt) % Both variant Ids and weights are specified
    % Checks for user-defined variant numbers
    if ~isinteger(int8(variantId)) ||... % integer check
            any(variantId < 0) ||... % negative integer check
            any(variantId > size(oriC,2)) % highest positive integer check
        error(['Variant Ids require positive integers between 1 and ',num2str(size(oriC,2))])
    end
    
    % Checks for user-defined variant weights
    if any(variantWt < 0) % negative floating point number check
        error('Variant weights require positive floating point numbers')
    elseif ~isequal(length(variantId), length(variantWt)) %  equal array size check
        error('Variant Ids and weights arrays of unequal size')
    end
    % Select only user-defined variants and their weights
    oriC = oriC(:,variantId);
    % Normalise the weights
    variantWt = normalize(variantWt,'norm',1);
    wtC = repmat(variantWt,size(oriC,1),1);
    fprintf(['    - Plotting user-selected variants = ', num2str(variantId),' \n']);
    fprintf(['    - Using normalised weights = ', num2str(variantWt),' \n']);  
    
    
elseif ~isempty(variantId) && isempty(variantWt) % Only variant Ids specified
    % Checks for user-defined variant numbers
    if ~isinteger(int8(variantId)) ||... % integer check
            any(variantId < 0) ||... % negative integer check
            any(variantId > size(oriC,2)) % highest positive integer check
        error(['Variant Ids require positive integers between 1 and ',num2str(size(oriC,2))])
    end
    % Select only user-defined variants and their equal weights
    oriC = oriC(:,variantId);
    wtC = ones(size(oriC,1),length(variantId));
    fprintf(['    - Plotting user-selected variants = ', num2str(variantId),' \n']);
    fprintf(['    - Using equal weights \n']);
        
    
elseif isempty(variantId) && ~isempty(variantWt) % Only variant weights specified
    error('Unable to assign variant weights. Variant numbers unspecified.')
    
    
elseif isempty(variantId) && isempty(variantWt) % Both variant Ids and weights are unspecified
    warning('Plotting all variants: (i) without selection, and (ii) with equal weights');
    wtC = ones(size(oriC,1),size(oriC,2));
end

%--- Calculate the orientation distribution function and define the specimen symmetry of the child
oriC = oriC(:);
wtC = wtC(:);
odfC = calcDensity(oriC,'weights',wtC,'halfwidth',hwidth*degree,'points','all');
%--- Define the specimen symmetry of the child
odfC.SS = specimenSymmetry('orthorhombic');
%--- Calculate the parent pole figures from the parent orientation distribution function 
pfC = calcPoleFigure(odfC,hChild,regularS2Grid('resolution',2.5*degree),'antipodal');
%---




%--- Plot the parent pole figures
odfP.SS = specimenSymmetry('triclinic');
f = figure;
plotPDF(odfP,...
    hParent,...
    'points','all',...
    'equal','antipodal',...
    'contourf');
colormap(cmapP);
% colormap(flipud(colormap(cmapP))); % option to flip the colorbar
movegui(f,'center');
set(f,'Name','Parent pole figure(s)','NumberTitle','on');
odfP.SS = specimenSymmetry('orthorhombic');
%---

%--- Plot the parent orientation distribution function
f = figure;
plotSection(odfP,...
    'phi2',odfSecP,...
    'points','all','equal',...
    'contourf');    
colormap(cmapP);
% colormap(flipud(colormap(cmapP))); % option to flip the colorbar
movegui(f,'center');
set(f,'Name','Parent orientation distribution function','NumberTitle','on');
%---



%--- Plot the child pole figures
odfC.SS = specimenSymmetry('triclinic');
f = figure;
plotPDF(odfC,...
    hChild,...
    'points','all',...
    'equal','antipodal',...
    'contourf');
% colormap(cmapC);
colormap(flipud(colormap(cmapC)));  % option to flip the colorbar
movegui(f,'center');
if ~isempty(variantId)
    set(f,'Name',['Child pole figure(s) for user selected variants: ',num2str(variantId)],'NumberTitle','on');
else
    set(f,'Name','Child pole figure(s) without variant selection','NumberTitle','on');
end
odfC.SS = specimenSymmetry('orthorhombic');
%---

%--- Plot the child orientation distribution function
f = figure;
plotSection(odfC,...
    'phi2',odfSecC,...
    'points','all','equal',...
    'contourf');
% colormap(cmapC);
colormap(flipud(colormap(cmapC))); % option to flip the colorbar
movegui(f,'center');
if ~isempty(variantId)
    set(f,'Name',['Child orientation distribution function for user selected variants: ',num2str(variantId)],'NumberTitle','on');
else
    set(f,'Name','Child orientation distribution function without variant selection','NumberTitle','on');
end
%---

%--- Save a VPSC *.tex file
fileName = 'outputVPSC.Tex';
export_VPSC(odfC,[pathName,fileName],'interface','VPSC','Bunge','points',nrPoints);
%---

end
