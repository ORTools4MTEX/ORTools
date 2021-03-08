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
cmap = get_option(varargin,'colormap','jet');
pathName = get_option(varargin,'path','');

OR = ORinfo(job.p2c,'silent');

%--- Define specimen symmetry
ss = specimenSymmetry('triclinic');


%--- Import the VPSC ODF file into memory
fileName = 'inputVPSC.Tex';
oriP = orientation.load([pathName,fileName],OR.CS.parent,ss,'interface','generic',...
    'ColumnNames', {'phi1' 'Phi' 'phi2' 'weights'}, 'Columns', [1 2 3 4], 'Bunge'); 
%---

%--- Calculate the orientation distribution function and define the specimen symmetry of the parent
odfP = calcDensity(oriP,'halfwidth',hwidth*degree,'points','all');
odfP.SS = specimenSymmetry('orthorhombic');
%--- Calculate the parent pole figures from the parent orientation distribution function 
pfP = calcPoleFigure(odfP,hParent,regularS2Grid('resolution',2.5*degree),'antipodal');

%--- Plot the parent pole figures
odfP.SS = specimenSymmetry('triclinic');
f = figure;
plotPDF(odfP,...
    hParent,...
    'points','all',...
    'equal','antipodal',...
    'contourf');
colormap(cmap)
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
colormap(cmap)
movegui(f,'center');
set(f,'Name','Parent orientation distribution function','NumberTitle','on');
%---

%% Find all the possible child orientations 
oriC = variants(job.p2c, oriP, job.variantMap);

if ~isempty(variantId) && ~isempty(variantWt) % Both variant Ids and weights are specified
    % Checks for user-defined variant numbers
    variantId = variantId(floor(variantId)==variantId); % integer check
    variantId = variantId(variantId > 0); % negative integer check
    variantId = variantId(variantId <= size(oriC,2)); % highest positive integer check
    fprintf(['    - Plotting user-selected variants: \n', num2str(variantId)]);
    
    % Checks for user-defined variant weights
    % check if the variantId and variantWt arrays are of equal size
    % if not equal, populate with the minimum weight value
    if length(variantId) > length(variantWt)
        variantWt(...
            end+1:...
            end+(length(variantId)-length(variantWt))) = min(variantWt);
    end
    % Normalise the weights
    variantWt = normalize(variantWt,'norm',1);
    fprintf(['    - Based on normalised weights: \n', num2str(variantId)]);
    % Define an empty ODF
    odfC = ODF();
    % Apply user-defined weights to each of the user-defined variants &
    % add to the total ODF
    for ii = 1:length(variantId)
        temp_odfC(ii) = calcODF(oriC(:,variantId(ii)),'halfwidth',hwidth*degree,'points','all');
        odfC =  odfC + variantWt(ii)*temp_odfC(ii);
    end
    
elseif ~isempty(variantId) && isempty(variantWt) % Only variant Ids specified
    % Checks for user-defined variant numbers
    variantId = variantId(floor(variantId)==variantId); % integer check
    variantId = variantId(variantId > 0); % negative integer check
    variantId = variantId(variantId <= size(oriC,2)); % highest positive integer check
    fprintf(['    - Plotting user-selected variants with equal weights: \n', num2str(variantId)]);
    % Select only user-defined variants
    oriC = oriC(:,variantId);
    %--- Calculate the orientation distribution function and define the specimen symmetry of the child
    oriC = oriC(:);
    odfC = calcDensity(oriC,'halfwidth',hwidth*degree,'points','all');

elseif isempty(variantId) && ~isempty(variantWt) % Only variant Wts specified
    error('Unable to assign variant weights. Variant numbers unspecified.')

elseif isempty(variantId) && isempty(variantWt) % Both variant Ids and weights are NOT specified
    warning('Plotting all variants without selection and with equal weights \n');
    %--- Calculate the orientation distribution function
    oriC = oriC(:);
    odfC = calcDensity(oriC,'halfwidth',hwidth*degree,'points','all');
end

%--- Define the specimen symmetry of the child
odfC.SS = specimenSymmetry('orthorhombic');
%--- Calculate the parent pole figures from the parent orientation distribution function 
pfC = calcPoleFigure(odfC,hChild,regularS2Grid('resolution',2.5*degree),'antipodal');
%---

%--- Plot the child pole figures
odfC.SS = specimenSymmetry('triclinic');
f = figure;
plotPDF(odfC,...
    hChild,...
    'points','all',...
    'equal','antipodal',...
    'contourf');
colormap(cmap)
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
colormap(cmap)
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