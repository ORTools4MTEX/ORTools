function plotCrystal_OR(job,oriP,varargin)
% plot crystal orientations of the parent orientation and child variants
%
% Syntax
%  f = crystalOR(job,oriP)
%
% Input
%  ori     - @orientation
%  job     - @parentGrainreconstructor
%
% Options
%  variantId    - list with specific variant Ids to plot


variantId = get_option(varargin,'variantId',[]);

% Display the OR
ORinfo(job.p2c,'silent');
% Find the parent & child planes and directions
[planeP,...
    planeC,...
    directionP,...
    directionC] =...
    round2Miller(job.p2c,'maxHKL',15);


% Calculate the child variants
% oriP = orientation.byEuler(0*degree,0*degree,0*degree,job.csParent);
oriC = variants(job.p2c,oriP,job.variantMap);

% Checks for user-defined variant numbers
if ~isempty(variantId)
    if ~isinteger(int8(variantId)) ||... % integer check
            any(variantId < 0) ||... % negative integer check
            any(variantId > size(oriC,2)) % highest positive integer check
        error(['Variant Ids require positive integers between 1 and ',num2str(size(oriC,2))])
    end
    % Select only user-defined variants and their weights
    oriC = oriC(:,variantId);
end
oriC = oriC(:);


% Define the rows and colums of the figure subplots based on the number
% of default or user-defined variants
f = figure;
f.WindowState = 'maximized'; %'fullscreen'
% % For older Matlab versions
% f = figure('units','normalized','outerposition',[0 0 1 1]);
if length(oriC)>12 && length(oriC)<=24 %12-24 variants
    maxRo = 4; maxCol = 1+6;
elseif length(oriC)>6 && length(oriC)<=12 %6-12 variants
    maxRo = 3; maxCol = 1+5;
elseif length(oriC)>3 && length(oriC)<=6 %3-6 variants
    maxRo = 2; maxCol = 1+4;
elseif length(oriC)>=1 && length(oriC)<=3 %1-3 variants
    maxRo = 1; maxCol = 1+3;
end
ff = newMtexFigure('nrows',maxRo,'ncols',maxCol);

%% Plot the parent
ro = 1; col = 1; nAx = [];
nAx(1) = nextAxis(ro,col,1);
drawCrystal(job.csParent,oriP,planeP,directionP);
% Ref: https://groups.google.com/g/mtexmail/c/Y_ALICW7gVs/m/s77Xd6rGAgAJ
% Setting the plotting convention inside an mtexFigure
ff.setCamera('xAxisDirection',getMTEXpref('xAxisDirection'));
ff.setCamera('zAxisDirection',getMTEXpref('zAxisDirection'));
view(-37.5,30);
text(0.3,-0.05,['Parent: ',job.csParent.mineral],'units','normalized');
text(0.35,-0.1,...
    ['(',num2str(round(oriP.phi1./degree,2)),', ',...
    num2str(round(oriP.Phi./degree,2)),', ',...
    num2str(round(oriP.phi2./degree,2)),')'],...
    'units','normalized');
hold off



%% Plot the child variants
ro = 1; col = 2;
for ii = 1:length(oriC)
    nAx(ii+1) = nextAxis(ro,col,ii+1);
    drawCrystal(job.csChild,oriC(ii),planeC,directionC);
    if ~isempty(variantId)
        text(0.3,-0.05,['Child: ',job.csChild.mineral,' Variant ',num2str(variantId(ii))],'units','normalized');
    else
        text(0.3,-0.05,['Child: ',job.csChild.mineral,' Variant ',num2str(ii)],'units','normalized');
    end
    text(0.35,-0.1,...
        ['(',num2str(round(oriC(ii).phi1./degree,2)),', ',...
        num2str(round(oriC(ii).Phi./degree,2)),', ',...
        num2str(round(oriC(ii).phi2./degree,2)),')'],...
        'units','normalized');
    hold off
    
    col = col+1;
    if col > maxCol
        ro = ro+1; col = 2;
    end
end

set(f,'Name','Unit cell orientations of parent grain and child variants based on the OR','NumberTitle','on');

%% Enable rotate and zoom for all subplots
hLink = linkprop([nAx(:)],{'CameraPosition','CameraUpVector','CameraTarget','XLim','YLim','ZLim','PlotBoxAspectRatio'});
setappdata(gcf,'StoreTheLink',hLink);
rotate3d on
end



% Based on Rudiger Killian's code
% https://github.com/mtex-toolbox/mtex/discussions/534
% https://github.com/mtex-toolbox/mtex/issues/504
function drawCrystal(cs,ori,h,v)
% x-y plane
[xx,yy] = meshgrid(-0.5:0.5);
surf(xx,yy,zeros(size(xx,1)),'FaceColor',[0 0 0],'FaceAlpha',0.3);
hold all

if cs.id >= 41 && cs.id <= 45
    cShape1 = crystalShape.cube(cs);
elseif cs.id >= 33 && cs.id <= 40
    cShape1 = crystalShape.hex(cs);
end
pcS = plot(ori*cShape1);
alpha(pcS,0.15);

cShape2 = crystalShape([h Miller({1,0,0},cs)],2.67); % magic number
h = symmetrise(h,'unique','antipodal');

p = ori*cShape2(h(1));
s = - p.faceCenter; % shift to the center
plot(1.3*(p + s),'FaceColor',[1 0 0]) % arbitrary scaling

set(gca,'xtick',[]);
set(gca,'ytick',[]);
set(gca,'ztick',[]);
set(gca,'XColor','none','YColor','none','ZColor','none');
axis equal;
axis tight;

% The following lines do not work correctly yet
% Since the OR direction is in-plane to the OR plane, 
% define the normal to the direction
v = v.uvw;
v = v/norm(v);
% Find two orthonormal vectors which are orthogonal to v
% The idea here is that one of them is parallel (or in-plane) to the plane
w = null(v); 
% P = [-0.5,0.5;-0.5,0.5]; % x Square limits
% Q = [-0.5,-0.5;0.5,0.5]; % y square limits
% x1 = 0; y1 = 0; z1 = 0; % center coordinates
% X = x1+w(1,1)*P+w(1,2)*Q; % Compute the corresponding cartesian coordinates...
% Y = y1+w(2,1)*P+w(2,2)*Q; % ... using the two vectors in w
% Z = z1+w(3,1)*P+w(3,2)*Q;
% gb_plane = surf(X,Y,Z,'FaceColor',[0 0 1],'FaceAlpha',0.67);

arrow3d([w(1,1)/10,w(1,2)/10],...
    [w(2,1)/10,w(2,2)/10],...
    [w(3,1)/10,w(3,2)/10],...
    0.85,0.01,0.02,[0 0 0]);
end