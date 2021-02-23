function [misoRange] = gaussFit(classRange,classInterval,counts)
if ~any([isempty(classRange),isempty(classInterval),isempty(counts)])
    screenPrint('Step','Fitting the interpolated misorientation distribution histogram');
    screenPrint('Step',sprintf('Set a threshold value above which peaks are found'));

    x = classRange.pchip;
    y = counts.normalised.pchip;
    global xpos ypos;

    %% Plot the histogram
    f = figure;
    for ii = 1:1
        s(ii) = subplot(1,1,ii);
        L(ii) = bar(x, y, 'LineWidth',1.5);
    end
    set(gca, 'xlim',[0 max(x)+5]);
    set(gca, 'ylim',[0 max(y)+0.1]);
    grid on
    %% Annotate the graph axes and title
    xlabel('Parent-child boundary misorientation (°)','FontSize',14);
    ylabel('Relative frequency ({\it f}(g))', 'FontSize',14);
    set(f,'Name','Interpolated parent-child misorientation distribution histogram','NumberTitle','on');
    %% Plot the initial graph
    for ii = 1:length(s)
        S.D{ii} = get(L(ii),{'xdata','ydata'});
        S.L(ii) = length(S.D{ii}{1});
        S.M(ii) = floor(S.L(ii)/2);
        S.DF = diff(S.D{ii}{1}(S.M(ii):S.M(ii)+1));
        S.I(ii) = S.M(ii);
        S.T(ii) = text(S.D{ii}{1}(S.M(ii)+2),S.D{ii}{2}(S.M(ii)+2),'here');
        set(S.T(ii),'string',{['X: ',sprintf('%3.3g',S.D{ii}{1}(S.M(ii)))];...
            ['Y: ',sprintf('%3.3g',S.D{ii}{2}(S.M(ii)))]},...
            'parent',s(ii),'backgroundcolor',[.8 .8 0]);
        set(s(ii),'nextplot','add');
        S.F(ii) = plot(s(ii),S.D{ii}{1}(S.M(ii)),S.D{ii}{2}(S.M(ii)),'ok');
        set(S.F(ii),'markerface','r');
        line(xlim, [S.D{ii}{2}(S.I(ii)), S.D{ii}{2}(S.I(ii))], 'LineStyle','-','Color','k','LineWidth', 1);   
    end
    set(gcf,'KeyPressFcn',{@arrowKeys,S});
    uiwait(f);




    %% Find peaks in the distribution
    [peakValue,peakPositionIdx,peakWidth,peakHeight] = findpeaks(y, 'MinPeakDist',classInterval.fine, 'MinPeakHeight',ypos,'Annotate','extents','WidthReference','halfheight');
    peakPosition = x(peakPositionIdx);
    screenPrint('Step',sprintf([num2str(size(peakValue,1)),' peak(s) found in the distribution']));
    %% Fit the individual peaks
    screenPrint('Step',sprintf(['Begin the Gaussian fitting of ',num2str(size(peakValue,1)),' distribution(s)']));
    % Gaussian function as defined in Eq(1) in https://en.wikipedia.org/wiki/Gaussian_function
    functionEquation = @(c,x) c(1) .* exp(-((x-c(2)).^2 ./ (2*(c(3).^2))));
    % Sum-Squared-Error Cost function
    SSECF = @(c,x,y) sum((y - functionEquation(c,x)).^2);
    lims = 1;
    functionConstants = zeros(3,size(peakValue,1));
    AUC = zeros(1,size(peakValue,1));
    FWHM = zeros(1,size(peakValue,1));
    sigma = zeros(1,size(peakValue,1));
    for k1 = 1:size(peakValue,1)
        indexRange = peakPositionIdx(k1)-lims : peakPositionIdx(k1)+lims;
        [functionConstants(:,k1), SSE(k1)] = fminsearch(@(c)SSECF(c,x(indexRange),y(indexRange)), [peakValue(k1); x(peakPositionIdx(k1)); classInterval.fine]);
        AUC(k1) = trapz(x, functionEquation(functionConstants(:,k1),x));
        FWHM(k1) = 2*(x(peakPositionIdx(k1)) - fzero(@(x) functionEquation(functionConstants(:,k1),x) - peakValue(k1)/2, x(peakPositionIdx(k1))-classInterval.fine));
        sigma(k1) = functionConstants(3,k1);

        xx1 = [(peakPosition(k1)-peakWidth(k1)): classInterval.fine: (peakPosition(k1)+peakWidth(k1))]';
        xx2 = [(peakPosition(k1)-(2*sigma(k1))): classInterval.fine: (peakPosition(k1)+(2*sigma(k1)))]';

        xx1(xx1 <= 0) = [];
        xx2(xx2 <= 0) = [];
        xRange1{k1} = xx1;
        xRange2{k1} = xx2;

        misoRange.min(k1) = min(xx2);
        misoRange.max(k1) = max(xx2);

        clear xx1 xx2;
        yRange1{k1} = functionEquation(functionConstants(:,k1),xRange1{k1});
        yRange2{k1} = functionEquation(functionConstants(:,k1),xRange2{k1});


    end
    screenPrint('Step',sprintf(['Completed the Gaussian fitting of ',num2str(size(peakValue,1)),' distribution(s)']));


    f = figure;
    bar(x, y, 'LineWidth',1.5)
    set(gca, 'xlim',[0 max(x)+5]);
    set(gca, 'ylim',[0 max(y)+0.1]);
    hold all
    plot(x(peakPositionIdx), peakValue, 'or','LineWidth',1)
    for k1 = 1:size(peakValue,1)
        plot(xRange1{k1}, yRange1{k1}, 'LineWidth',1);
        line([peakPosition(k1), peakPosition(k1)], ylim, 'LineStyle',':','Color','k','LineWidth', 1);
        h = text(peakPosition(k1),peakValue(k1)+0.025,['OR ',num2str(k1)],'Color','red','FontSize',16,'FontWeight','bold');
        set(h,'Rotation',90);
    end
    hold off
    grid on
    %% Annotate the graph axes and title
    xlabel('Parent-child boundary misorientation (°)','FontSize',14);
    ylabel('Relative frequency ({\it f}(g))', 'FontSize',14);
    set(f,'Name','Fitted parent-child misorientation distribution histogram','NumberTitle','on');
    pause(1.0)
else
    warning('No parent-child misorientation data to analyse');
    misoRange = []; 
end