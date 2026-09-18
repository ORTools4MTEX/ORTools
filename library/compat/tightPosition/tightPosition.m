function pos = tightPosition(ax,varargin)
%% Function description:
% Compatibility shim for MATLAB's built-in "tightPosition", which was only
% introduced in R2022b. MTEX 7.1 calls it, so running MTEX 7.1 on R2022a or
% earlier fails with an "unrecognized function" error.
%
% IMPORTANT: this file must only be on the MATLAB search path when the
% running release does not provide "tightPosition" itself, otherwise it
% shadows MATLAB's own implementation. "currentFolder.m" adds every folder
% under "library/compat" conditionally for exactly this reason - do not add
% this folder with a plain addpath(genpath(...)).
%
%% Syntax:
%  pos = tightPosition(ax)
%  pos = tightPosition(ax,'IncludeLabels',tf)
%  pos = tightPosition(ax,IncludeLabels=tf)
%
%% Input:
%  ax   - @matlab.graphics.axis.Axes = the axes to measure
%
%% Output:
%  pos  - 1x4 double = [left bottom width height] of the axes, expressed in
%                      the units given by "ax.Units" and relative to the
%                      axes' parent container
%
%% Options:
%  IncludeLabels - Include the tick labels, axis labels and title in the
%                  returned rectangle. (default = false, which matches the
%                  documented behaviour of MATLAB's own "tightPosition":
%                  by default it returns the plot box only)


%% Parse the inputs
if nargin < 1 || ~isscalar(ax) || ~isgraphics(ax,'axes')
    error('tightPosition: the first input must be a single axes handle.');
end

includeLabels = false;
if ~isempty(varargin)
    idx = find(strcmpi(varargin,'IncludeLabels'),1);
    if isempty(idx) || idx == numel(varargin)
        error(['tightPosition: expected an ''IncludeLabels'' name-value ',...
            'pair, got %d trailing argument(s).'],numel(varargin));
    end
    includeLabels = logical(varargin{idx+1});
end

% The reported geometry is stale until the axes has actually been rendered
drawnow;


%% Measure the axes
try
    % "GetLayoutInformation" is undocumented but has existed since R2014b,
    % and is what MATLAB's own "tightPosition" is built on. It reports the
    % geometry that was actually drawn, in pixels relative to the figure,
    % which is what makes the constrained cases ("axis equal", "axis image"
    % or a displayed image) come out right - there the drawn box is smaller
    % than "ax.Position" and MATLAB centres it inside.
    li = ax.GetLayoutInformation;
    if includeLabels
        boxPix = li.DecorationsBox;
    else
        boxPix = li.PlotBox;
    end
    pos = convertFromFigurePixels(ax,boxPix);

catch
    % Documented fallback. This is exact for an unconstrained axes, but
    % "ax.Position" overstates the drawn box whenever a fixed aspect ratio
    % shrinks it, so the result is approximate in those cases.
    warning(['tightPosition: falling back to ''Position''/''TightInset''. ',...
        'The result is approximate for axes with a fixed aspect ratio.']);
    pos = ax.Position;
    if includeLabels
        ti  = ax.TightInset;
        pos = [pos(1)-ti(1), pos(2)-ti(2), ...
               pos(3)+ti(1)+ti(3), pos(4)+ti(2)+ti(4)];
    end
end
end


function pos = convertFromFigurePixels(ax,boxPix)
%% Convert a figure-relative pixel rectangle into the units and reference
% frame of the axes' own parent container.

fig = ancestor(ax,'figure');
figPix = getInPixels(fig,'Position');

% Re-reference from the figure to the parent container. An axes parented
% directly to the figure needs no shift.
parent = ax.Parent;
if isequal(parent,fig)
    refPix = [0 0 figPix(3) figPix(4)];
else
    refPix = getpixelposition(parent,true);
    boxPix(1:2) = boxPix(1:2) - refPix(1:2);
end

switch lower(ax.Units)
    case 'pixels'
        pos = boxPix;

    case 'normalized'
        pos = [boxPix(1)/refPix(3), boxPix(2)/refPix(4), ...
               boxPix(3)/refPix(3), boxPix(4)/refPix(4)];

    otherwise
        % inches, centimeters, points, characters: derive the scale factor
        % by reading the same axes position in both pixels and user units.
        axPix  = getInPixels(ax,'Position');
        axUser = ax.Position;
        scale  = [axUser(3)/axPix(3), axUser(4)/axPix(4)];
        pos = [axUser(1) + (boxPix(1)-axPix(1))*scale(1), ...
               axUser(2) + (boxPix(2)-axPix(2))*scale(2), ...
               boxPix(3)*scale(1), boxPix(4)*scale(2)];
end
end


function value = getInPixels(h,propName)
%% Read a graphics property in pixels, restoring the original units
oldUnits = h.Units;
cleanup  = onCleanup(@() set(h,'Units',oldUnits));
h.Units  = 'pixels';
value    = h.(propName);
end
