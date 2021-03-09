function plotPDF_variants(job,varargin)
% plot a pole figure of the martensitic variants associated with an OR
%
% Syntax
%  plotPDF_variants(job)
%  plotPDF_variants(job,oriParent)
%  plotPDF_variants(job,oriParent,pdf)
%
% Input
%  job          - @parentGrainreconstructor
%  oriParent    - @orientation
%  pdf          - @Miller
%
% Options
%  colormap - colormap string
%
% Alternative to MTEX's plotVariantPF
% https://mtex-toolbox.github.io/parentGrainReconstructor.plotVariantPF.html

oriParent = getClass(varargin,'orientation',orientation.id(job.csParent));
pdf = getClass(varargin,'Miller',Miller(0,0,1,job.csChild,'hkl'));
cmap = get_option(varargin,'colormap','jet');

% Compute the disorientation from the nominal OR
p2c_V = job.p2c.variants;
p2c_V = p2c_V(:);
c2c_variants = job.p2c * inv(p2c_V);
oriVariants = reshape(oriParent.project2FundamentalRegion,[],1) .* inv(p2c_V);
oriVariants = oriVariants(:);

% Note: Include the last 2 lines to uniquely label each variant marker with
% the variant number

if isempty(job.variantMap); job.variantMap = 1:length(c2c_variants); end
plotPDF(oriVariants, job.variantMap, pdf,...
    'equal','antipodal','points','all',...
    'MarkerSize',6,'MarkerEdgeColor',[0 0 0]);
%     'label',1:length(oriVariants),'nosymmetry',...
%     'fontsize',10,'fontweight','bold');

% Define the maximum number of color levels and plot the colorbar
maxColors = length(oriVariants);
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

end