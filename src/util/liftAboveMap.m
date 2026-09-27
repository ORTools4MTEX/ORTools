function h = liftAboveMap(h, grains)
    %% Function description:
    % This function lifts arrows drawn with "quiver(grains,...)" slightly
    % towards the viewer. MTEX 7 draws these arrows in 3D, so arrows lying
    % in the plane of the map are hidden by the map itself and only their
    % heads remain visible.
    %
    %% Syntax:
    %  h = liftAboveMap(h,grains)
    %
    %% Input:
    %  h      - handle(s) returned by quiver(grains,...)
    %  grains - @grain2d passed to quiver
    %
    %% Output:
    %  h      - the same handle(s)

    if isempty(h), return; end

    outOfScreen = grains.how2plot.outOfScreen;
    ax = ancestor(h(1), 'axes');
    dz = 0.01 * max(diff(ax.XLim), diff(ax.YLim)) * outOfScreen.z;
    for ii = 1:numel(h)
        if isprop(h(ii), 'ZData')
            if isempty(h(ii).ZData)
                h(ii).ZData = zeros(size(h(ii).XData));
            end
            h(ii).ZData = h(ii).ZData + dz;
        end
    end
end
