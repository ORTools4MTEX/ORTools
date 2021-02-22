function plotMap_phases(job,varargin)
% plot phase map with low and high angle boundaries
%
% Syntax
%
%  p2c = plotMap_phases(job)
%
% Input
%  job  - @parentGrainReconstructor

%% Plot the phase map
f = figure;
plot(job.grains);
hold all
% Plot the HABs in black
plot(job.grains.boundary,'LineColor','k','LineWidth',2,'displayName','HABs');
hold all
% Plot the LABs in navajowhite
plot(job.grains.innerBoundary,'LineColor',[255/255 222/255 173/255],'LineWidth',2,'displayName','LABs');
hold off
set(f,'Name','Phases','NumberTitle','on');
drawnow;
end

