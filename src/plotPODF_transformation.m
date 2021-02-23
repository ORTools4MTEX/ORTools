function f = plotPODF_transformation(job,hP,hD,varargin)
% plot transformation texture from VPSC file 
%
% Syntax
%  f = plotPODF_transformation(job,hP,hD)
%
% Input
%  crystalDirection     - @Miller
%  specimenDirection    - @vector3d
%
% Options
%  odfSecP      - array with angles of parent ODF section to display
%  odfSecC      - array with angles of child ODF section to display
%  variantId    - list with specific variant Ids to plot
%  halfwidth    - halfwidth for ODF calculation
%  nrPoints     - Nr of points to be written into the VPSC file
%  colormap     - colormap string

odfSecP = get_option(varargin,'odfSecP',[0 45 65]*degree);
odfSecC = get_option(varargin,'odfSecC',[0 45 90]*degree);
variantId = get_option(varargin,'variantId',[]);
hwidth = get_option(varargin,'halfwidth',2.5);
nrPoints = get_option(varargin,'nrPoints',1000);
cmap = get_option(varargin,'colormap','jet');

setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize',16);
OR = ORinfo(job.p2c,'silent');

%--- Define specimen symmetry
ss = specimenSymmetry('triclinic');


%--- Import the VPSC ODF file into memory
FileName = 'inputVPSC.Tex';
oriP = orientation.load(FileName,OR.CS.parent,ss,'interface','generic',...
    'ColumnNames', {'phi1' 'Phi' 'phi2' 'weights'}, 'Columns', [1 2 3 4], 'Bunge'); 
%---

%--- Calculate the orientation distribution function and define the specimen symmetry of the parent
odfP = calcDensity(oriP,'halfwidth',hwidth*degree,'points','all');
odfP.SS = specimenSymmetry('orthorhombic');
%--- Calculate the parent pole figures from the parent orientation distribution function 
pfP = calcPoleFigure(odfP,hP,regularS2Grid('resolution',2.5*degree),'antipodal');

%--- Plot the parent pole figures
setMTEXpref('xAxisDirection','north');
odfP.SS = specimenSymmetry('triclinic');
f = figure;
plotPDF(odfP,...
    hP,...
    'points','all',...
    'equal','antipodal',...
    'contourf',...
    'colorrange',[1 ceil(max(max(pfP)))]);
mtexColorMap white2black
movegui(f,'center');
set(f,'Name','Parent pole figure(s)','NumberTitle','on');
setMTEXpref('xAxisDirection','east');
odfP.SS = specimenSymmetry('orthorhombic');
%---

%--- Plot the parent orientation distribution function
f = figure;
plotSection(odfP,...
    'phi2',odfSecP,...
    'points','all','equal',...
    'contourf',...
    'colorrange',[1 ceil(max(odfP))]);    
mtexColorMap white2black
movegui(f,'center');
set(f,'Name','Parent orientation distribution function','NumberTitle','on');
%---

%% Find all the possible child orientations 
% % Based on the list of parent orientations in the ODF and the OR
% % Note: no variant selection is applied - all childs are possible
% oriD = symmetrise(oriP) * OR.CS.parent.properGroup * inv(OR.misorientation);
% % oriD = orientation.id(OR.crystalSystem.child.properGroup) * misoD;
% % oriD = unique(oriD);

% Compute the disorientation from the nominal OR
p2c_V = job.p2c.variants;
p2c_V = p2c_V(:);
c2c_variants = job.p2c * inv(p2c_V);
% Compute the transformed child orientations
% Note: no variant selection is applied here - all children are possible
oriD = reshape(oriP.project2FundamentalRegion,[],length(oriP)) .* inv(p2c_V);
% Applying user-defined variants if specified
if ~isempty(variantId)
    % Checks for user-defined variant numbers
    variantId = variantId(floor(variantId)==variantId); % integer check
    variantId = variantId(variantId > 0); % negative integer check
    variantId = variantId(variantId <= length(p2c_V)); % highest positive integer check
    fprintf(['    - Plotting user selected variants: \n', num2str(variantId)]);
    % Select only user-defined variants
    oriD = oriD(variantId,:);
else
    fprintf('    - Plotting all variants without selection \n');
end
oriD = oriD(:);

%--- Calculate the orientation distribution function and define the specimen symmetry of the child
odfD = calcDensity(oriD,'halfwidth',hwidth*degree,'points','all');
odfD.SS = specimenSymmetry('orthorhombic');
%--- Calculate the parent pole figures from the parent orientation distribution function 
pfD = calcPoleFigure(odfD,hD,regularS2Grid('resolution',2.5*degree),'antipodal');
%---

%--- Plot the child pole figures
setMTEXpref('xAxisDirection','north');
odfD.SS = specimenSymmetry('triclinic');
f = figure;
plotPDF(odfD,...
    hD,...
    'points','all',...
    'equal','antipodal',...
    'contourf',...
    'colorrange',[1 ceil(max(max(pfD)))]);
colormap(cmap)
movegui(f,'center');
if ~isempty(variantId)
    set(f,'Name',['Child pole figure(s) for user selected variants: ',num2str(variantId)],'NumberTitle','on');
else
    set(f,'Name','Child pole figure(s) without variant selection','NumberTitle','on');
end
setMTEXpref('xAxisDirection','east');
odfD.SS = specimenSymmetry('orthorhombic');
%---

%--- Plot the child orientation distribution function
f = figure;
plotSection(odfD,...
    'phi2',odfSecC,...
    'points','all','equal',...
    'contourf',...
    'colorrange',[1 ceil(max(odfD))]);
colormap(cmap)
movegui(f,'center');
if ~isempty(variantId)
    set(f,'Name',['Child orientation distribution function for user selected variants: ',num2str(variantId)],'NumberTitle','on');
else
    set(f,'Name','Child orientation distribution function without variant selection','NumberTitle','on');
end
%---

%--- Save a VPSC *.tex file
FileName = 'outputVPSC.Tex';
export_VPSC(odfD,FileName,'interface','VPSC','Bunge','points',nrPoints);
%---

end