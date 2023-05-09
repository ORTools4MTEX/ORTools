function plotPDF_bain(job,varargin)
% plot a pole figure of the child packets associated with an OR
%
% Syntax
%  plotPDF_bain(job)
%  plotPDF_bain(job,oriParent)
%  plotPDF_bain(job,oriParent,pdf)
%
% Input
%  job          - @parentGrainreconstructor
%  oriParent    - @orientation
%  pdf          - @Miller
%
% Options
%  colormap - colormap string
%

oriParent = getClass(varargin,'orientation',orientation.id(job.csParent));
pdf = getClass(varargin,'Miller',Miller(0,0,1,job.csChild,'hkl'));
cmap = get_option(varargin,'colormap','hot');
msz = get_option(varargin,'markersize',6);

%% Define the text output format as Latex
setInterp2Latex

% Compute the disorientation from the nominal OR
p2c_V = job.p2c.variants;
p2c_V = p2c_V(:);
c2c_variants = job.p2c * inv(p2c_V);
oriVariants = reshape(oriParent.project2FundamentalRegion,[],1) .* inv(p2c_V);
oriVariants = oriVariants(:);
[~,~,bainIds] = calcVariantId(oriParent.project2FundamentalRegion,oriVariants,job.p2c,'variantMap',job.variantMap,varargin{:});
  

% Note: Include the last 2 lines to uniquely label each variant marker with
% the variant number

plotPDF(oriVariants, bainIds, pdf,...
    'equal','antipodal','points','all',...
    'MarkerSize',msz,'MarkerEdgeColor',[0 0 0]);
%     'label',1:length(oriVariants),'nosymmetry',...
%     'fontsize',10,'fontweight','bold');

% Define the maximum number of color levels and plot the colorbar
maxColors = max(bainIds);
colormap(cmap);
caxis([1 maxColors]);
colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
    'YTick', [1:1:maxColors],...
    'YTickLabel',num2str([1:1:maxColors]'), 'YLim', [1 maxColors],...
    'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
hold on

if strcmpi(job.csChild.lattice, 'cubic') && oriParent == orientation.id(job.csParent)
    plot(Miller(1,0,0,job.csChild),'plane','LineColor',[0 0 0],'LineWidth',1); 
    plot(Miller(0,1,0,job.csChild),'plane','LineColor',[0 0 0],'LineWidth',1); 
    plot(Miller(0,0,1,job.csChild),'plane','LineColor',[0 0 0],'LineWidth',1); 
end
hold off
drawnow;
end