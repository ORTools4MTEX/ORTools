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
% Plot the GBs in black
plot(job.grains.boundary,'LineColor','k','displayName','GBs',varargin{:});
hold off
set(f,'Name','Phases','NumberTitle','on');
drawnow;
end