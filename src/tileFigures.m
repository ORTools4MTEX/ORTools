function tileFigures() 
% Utility function to tile all figures evenly spread accros the screen
%
% Syntax
%  tileFigs

%% Initialization
mon = 2;                                                                   %Choose monitor number
offset.l = 70; offset.r = 0; offset.b = 70; offset.t = 0;                  %Offsets left right botton top (possible taskbars)
grid = [2 2 2 2 2 3 3 3 3 3 3 4 4 4 4 4 4 4 4 4; 
3 3 3 3 3 3 3 3 4 4 4 5 5 5 5 5 5 5 5 6]';                                 %Define figure grid
%% Find figures and screen dimension
h.figs = flip(findobj('type','figure'));                                   %Get figure handles
h.figs = h.figs(find(strcmp(get(h.figs,'visible'),'on')));                 %Only treat visible figures
set(h.figs,'unit','pixels');                                               %Set figure units to [pxs]
nFigs = size(h.figs,1);                                                    %Get number of visible figures
scr.Sz = get(0,'MonitorPositions');                                        %Get screen size
scr.h = scr.Sz(mon,4)-offset.t;                                            %Get screen height
scr.w = scr.Sz(mon,3)-offset.l-offset.r;                                   %Get screen width
scr.orX = scr.Sz(mon,1)+offset.l;                                          %Get screen origin X
scr.orY = scr.Sz(mon,2);                                                   %Get screen origin Y
%% Check limits
if ~nFigs; error('figures are not found'); return; end                     %Stop for no figures
if nFigs > 20; error('too many figures(maximum = 20)'); return; end        %Check for limit of 20 figures
%% Define grid according to screen aspect ratio
if scr.w > scr.h %Widescreen
    n.h = grid(nFigs,1);                                                   %Define number of figures in height                                                 
    n.w = grid(nFigs,2);                                                   %Define number of figures in width         
else 
    n.h = grid(nFigs,2);                                                   %Define number of figures in height 
    n.w = grid(nFigs,1);                                                   %Define number of figures in width  
end 
%% Determine height and width for each figure
fig.h = (scr.h-offset.b)/n.h;                                              %Figure height
fig.w =  scr.w/n.w;                                                        %Figure width
%% Resize figures
k = 1;                                                                     %Initialize figure counter
for i =1:n.h %Loop over height
    for j = 1:n.w  %Loop over width
        if k > nFigs; return; end                                          %Stop when all figures have been resized 
        fig_pos = [scr.orX + fig.w*(j-1) scr.h-fig.h*i fig.w fig.h];       %Compute new figure position 
        set(h.figs(k),'OuterPosition',fig_pos);                            %Set new figure position
        k = k + 1;                                                         %Increase figure counter
    end 
end
end