function [hPlane,statistics] = computeHabitPlane(job,varargin)
% Compute the habit plane based on determined traces of a 2D map
% Implemented as in https://doi.org/10.48550/arXiv.2303.07750 
%
% Syntax
%
% [hPlane,statistics] = computeHabitPlane(job)
%
% Input
%  job      - @parentGrainReconstructor
%
% Output
%  hPlane   - @Miller  Habit Plane
%  statistics  - @Container  Fitting statistics

if all(isnan(job.variantId)); job.calcVariants; end % Compute variants
childGrains = job.grainsPrior; %Get child grains
traces = calcTraces(childGrains, [job.mergeId(:), job.variantId(:)]); %Calculate traces
traces = traces(job.isParent,:); % Only consider those that have a reconstructed parent orientation
oriParent = job.parentGrains.meanOrientation; %Get the parent orientations
oriPVariant = oriParent.project2FundamentalRegion .* ...
inv(variants(job.p2c)) .* job.p2c; % Determine the variant specific parent orientations
tracesParent = inv(oriPVariant) .* traces; % Transform traces into the parent reference frame
hPlane = perp(tracesParent,'robust'); % Determine the habit plane (orthogonal fit)
hPlane.dispStyle = "hkl"; % Change Miller object to type crystal plane
deviation = angle(hPlane,tracesParent(~isnan(tracesParent)),'noSymmetry')./degree-90; % Deviation between traces and fitted habit plane
meanDeviation = abs(mean(deviation)); %Mean deviation
quantiles = quantile(deviation,[0.25 0.5 0.75]); %Quantiles
statistics = containers.Map({'Deviation','meanDeviation','Quantiles'},{deviation,meanDeviation,quantiles},'UniformValues',false);
%% Plot and return the habit plane 
% Plot traces and fitted habit plane
figure;
plot(tracesParent,'MarkerSize',6,'MarkerFaceColor','k','MarkerFaceAlpha',0.4,'MarkerEdgeAlpha',0.5);
hold on
plot(hPlane,'plane','linecolor','r','linewidth',2);
plot(hPlane,'Marker','s','MarkerColor','r','MarkerEdgeColor','k','MarkerSize',10,'LineWidth',1);

%Text output
nr_traces = length(find(~isnan(traces)));
fprintf("\n*** Habit Plane determination ***\n")
fprintf("Nr. analyzed traces: %d\n",nr_traces);
fprintf("Nr. analyzed parent grains: %d\n",length(oriParent));
fprintf("The habit plane is (%s %s %s)\n",num2str(hPlane.h),num2str(hPlane.k),num2str(hPlane.l));
fprintf("The rounded habit plane is %s\n",hPlane.round);
fprintf("Mean deviation: %0.2f °, Quantiles: [%0.2f %0.2f %0.2f] °\n",meanDeviation, quantiles);