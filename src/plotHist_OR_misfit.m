function plotHist_OR_misfit(job,varargin)
% Plot histogram of misfit between grain misorientations and the OR
% misorientation
%
% Syntax
%  plotHist_OR_misfit(job)
%  plotHist_OR_misfit(job,p2c)
%
% Input
%  job          - @parentGrainreconstructor
%  p2c          - One or multiple orientation-relationships to evaluate
%

p2c = getClass(varargin,'orientation');
if ~isempty(p2c) && (p2c.CS ~= job.csParent || p2c.SS ~= job.csChild)
    p2c = []; 
end
if ~isempty(job.p2c)
    p2c = [job.p2c,p2c]; 
end

if isempty(p2c)
    warning('No OR provided by user'); 
    return; 
end

%% Plot histogram
%Prepare the boundary misorientations
c2cPairs = job.grains(job.csChild).neighbors;
oriChild = reshape(job.grains('id',c2cPairs).meanOrientation,[],2);
mori = inv(oriChild(:,1)).*oriChild(:,2);
mori(mori.angle < 5 * degree) = [];
if length(mori) > 50000
    moriSub = discreteSample(mori,50000);
else
    moriSub = mori;
end

%Plot the disorientation
f = figure;
c = ind2color(1:length(p2c));
for ii = 1:length(p2c)
    c2c = p2c(ii) * inv(p2c(ii).variants);      
    omegaTemp = angle_outer(moriSub, c2c);
    [omega(ii,:),~] = min(omegaTemp,[],2); 
    [counts(ii,:),binCenters(ii,:)] = hist(omega(ii,:),500);
    %--- Normalise the absolute counts in each class interval
    counts_Norm(ii,:) = 1.*(counts_Norm(ii,:)/sum(counts_Norm(ii,:)));
    h(ii) = area(binCenters(ii,:)./degree, counts_Norm(ii,:),...
        'linewidth',2,...
        'edgecolor',c(ii,:), 'facecolor',c(ii,:),...
        'DisplayName',sprintf("OR %d",ii),'facealpha',0.25);
    hold on;
end
hold off

if ~isempty(job.p2c)
    h(1).DisplayName = "Current OR"; 
end

xlabel('Child-child boundary disorientation (°)','FontSize',14);
ylabel('Relative frequency ({\it f}(g))', 'FontSize',14);
set(gca, 'xlim',[0 max(max(binCenters)./degree)+5]);
set(gca, 'ylim',[0 max(max(counts))+0.1]);
grid on
legend
set(f,'Name','Child-child disorientation distribution histogram','NumberTitle','on');
end
    

