function plotMap_phases(job,varargin)
%% Function description:
% This function plots an ebsd map of the grain phases in the *job* 
% variable as well as the grain boundaries (*job.grains.boundary*).
%
%% Syntax:
% p2c = plotMap_phases(job)
%
%% Input:
%  job  - @parentGrainReconstructor


%% Define the text output format as Latex
setInterp2Latex

%% Plot the phase map
f = figure;
plot(job.grains);
hold all
% Plot the GBs in black
plot(job.grains.boundary,'LineColor',[0 0 0],'displayName','GBs',varargin{:});
hold off
set(f,'Name','Phases','NumberTitle','on');
drawnow;
end