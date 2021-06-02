function grainClick(job,varargin)
% interactive parent grain selector
%
% Syntax
%  grainClick(job,parentEBSD)
%
% Input
%  job          - @parentGrainreconstructor
%  parentEBSD   - reconstructed @EBSD data
%  direction    - @vector3d
%
% Option
%  grains       - plot grain data instead of ebsd data
%  parentTwins  - Detect parent twins

close all;
%% Define the default window settings for figures
set(0,'DefaultFigureWindowStyle','normal');

%% Plot reconstructed parent grains
pGrains = job.parentGrains;
f = figure;
[~,mP] = plot(pGrains,'grayscale',...
    'lineColor',[0 0 0],...
    'lineWidth',0.1);
hold on



isNowParent = job.grainsPrior.phaseId == job.childPhaseId &...
    job.grains(job.mergeId).phaseId == job.parentPhaseId;
plot(job.grainsPrior(isNowParent).boundary,'lineWidth',0.5);
plot(job.parentGrains.boundary,'lineWidth',2);


hold off
set(f,'Name','Map: Parent grains + GBs [Left-click = Select grain | Right-click = Exit]','NumberTitle','on');
axis(mP.ax,'tight');


% datacursormode does not work with grains due to a Matlab bug
datacursormode off

% Define a selector
set(gcf,'WindowButtonDownFcn',{@spatialSelection});
setappdata(mP.ax,'grains',[pGrains]);



    function spatialSelection(src,~)
        
        persistent sel_handle;
        
        pos = get(gca,'CurrentPoint');
        pGrains = getappdata(gca,'grains');
        
        idSelected = getappdata(gca,'idSelected');
        handleSelected = getappdata(gca,'handleSelected');
        if isempty(idSelected) || length(idSelected) ~= length(pGrains)
            idSelected = false(size(pGrains));
            handleSelected = cell(size(pGrains));
        end
        
        localId = findByLocation(pGrains,[pos(1,1) pos(1,2)]);
        if isempty(localId); return; end
        localId = localId(1);
        pGrain_select = pGrains.subSet(localId);
        
        if isempty(pGrain_select)
            return
        end
        
        % Remove old parent grain selection
        if strcmpi(src.SelectionType,'normal')
            idSelected = false(size(pGrains));
            try delete([handleSelected{:}]); end %#ok<TRYNC>
            % Delete previously selected parent-child grain(s) figures
            figh = findall(0,'type','figure');
            if length(figh) > 1
                otherFigs = setdiff(figh,figure(1));
                delete(otherFigs)
            end
        elseif strcmpi(src.SelectionType,'extend')
            try delete([handleSelected{localId}]); end %#ok<TRYNC>
            handleSelected{localId} = [];
            
        elseif strcmpi(src.SelectionType,'alt')
            close all
            return
        end
        
        % Define new parent grain selection
        idSelected(localId) = ~idSelected(localId);
        if idSelected(localId)
            hold on
            handleSelected{localId} = plot(pGrain_select.boundary,'lineColor',[1 0 0],'lineWidth',2);
            hold off
        end
        
        txt{1} = ['grainId = '  num2str(unique(pGrain_select.id))];
        txt{2} = ['phase = ', pGrain_select.mineral];
        txt{3} = ['(x,y) = ', xnum2str([pos(1,1) pos(1,2)],'delimiter',', ')];
        if pGrain_select.isIndexed
            txt{4} = ['Euler = ' char(pGrain_select.meanOrientation,'nodegree')];
        end
        
        for k = 1:length(txt)
            disp(txt{k});
        end
        % Plot the user-defined stack of plots
        if ~isempty(varargin) && any(strcmp(varargin,'parentTwins'))
            detectParentTwins(job,unique(pGrain_select.id),varargin{:});
        elseif any(job.isTransformed(job.mergeId == pGrain_select.id))
            plotStack(job,unique(pGrain_select.id),varargin{:});
        else
            f = msgbox('Choose a reconstructed parent grain (within the thick boundaries)', 'Error','warn');
            uiwait(f);
        end
        figure(f);
        
        setappdata(gca,'idSelected',idSelected);
        setappdata(gca,'handleSelected',handleSelected);
    end
end
