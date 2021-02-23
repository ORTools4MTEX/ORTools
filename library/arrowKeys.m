function [xpos,ypos] = arrowKeys(varargin)
global xpos ypos; 
D = varargin{2}.Key;
S = varargin{3};

if strcmp(D,'uparrow') || strcmp(D,'leftarrow')
    for ii = 1:length(S.T)
        if S.I(ii)~=1
            S.I(ii) = S.I(ii)-1;
            set(S.F(ii),'xdata',S.D{ii}{1}(S.I(ii)),...
                'ydata',S.D{ii}{2}(S.I(ii)));
            set(S.T(ii),'position',...
                [S.D{ii}{1}(S.I(ii))+S.DF*2,S.D{ii}{2}(S.I(ii))],...
                'string',{['X: ',sprintf('%3.3g',S.D{ii}{1}(S.I(ii)))];...
                ['Y: ',sprintf('%3.3g',S.D{ii}{2}(S.I(ii)))]});
            
            children = get(gca, 'children');
            delete(children(1));
            line(xlim, [S.D{ii}{2}(S.I(ii)), S.D{ii}{2}(S.I(ii))], 'LineStyle','-','Color','k','LineWidth', 1);
        end
    end
    
elseif strcmp(D,'downarrow') || strcmp(D,'rightarrow')
    for ii = 1:length(S.T)
        if S.I(ii)~=S.L(ii)
            S.I(ii) = S.I(ii)+1;
            set(S.F(ii),'xdata',S.D{ii}{1}(S.I(ii)),...
                'ydata',S.D{ii}{2}(S.I(ii)));
            set(S.T(ii),'position',...
                [S.D{ii}{1}(S.I(ii))+S.DF*2,S.D{ii}{2}(S.I(ii))],...
                'string',{['X: ',sprintf('%3.3g',S.D{ii}{1}(S.I(ii)))];...
                ['Y: ',sprintf('%3.3g',S.D{ii}{2}(S.I(ii)))]});
            
            children = get(gca, 'children');
            delete(children(1));
            line(xlim, [S.D{ii}{2}(S.I(ii)), S.D{ii}{2}(S.I(ii))], 'LineStyle','-','Color','k','LineWidth', 1);
        end
    end
    
elseif strcmp(D,'return')
    xpos = S.D{1}{1}(S.I(1));
    ypos = S.D{1}{2}(S.I(1));
    close(gcf)
    return
end
set(gcf,'keypressfcn',{@arrowKeys,S});  % Update the structure.