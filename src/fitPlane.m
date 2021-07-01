function [n,rSqu] = fitPlane(H,varargin)
%Plot plane through crystal directions
    fac = 1000;
    %Check if weights are supplied
    if ~isempty(varargin) && all(sort(size(H.x)) == sort(size(varargin{1})))
       weights = varargin{1};
       [fitpln,gof] = fit(fac.*[H.u,H.v],fac*H.w,'poly11','weights',weights);
    else
       [fitpln,gof] = fit(fac.*[H.u,H.v],fac.*H.w,'poly11'); 
    end
    %Find normal vector
    x(1) = 0.8;                                                            %Arbitrary x1
    x(2) = 0.4;                                                            %Arbitrary x2
    y(1) = 0.3;                                                            %Arbitrary y1
    y(2) = 0.7;                                                            %Arbitrary y2
    z(1)=fitpln(0.8,0.3);                                                  %Get z1
    z(2)=fitpln(0.4,0.7);                                                  %Get z2
    n = cross([0.8,0.3,z(1)],[0.4,0.7,z(2)]);                              %Normal vector
    n = n/norm(n);                                                         %Normalized normal vector
    %Error
    rSqu = gof.rsquare;
	

%     %Plot plane through crystal directions
%     fac = length(H); %1000
%     %Check if weights are supplied
%     if ~isempty(varargin) && all(sort(size(H.x)) == sort(size(varargin{1})))
%        weights = varargin{1};
%        [fitpln,gof] = fit(fac.*[H.u,H.v],fac*H.w,'poly11','weights',weights,'Normalize','on');
%     else
%        [fitpln,gof] = fit(fac.*[H.u,H.v],fac.*H.w,'poly11','Normalize','on'); 
%     end
%     %Find normal vector
% %     x(1) = 0.8;                                                            %Arbitrary x1
% %     x(2) = 0.4;                                                            %Arbitrary x2
% %     y(1) = 0.3;                                                            %Arbitrary y1
% %     y(2) = 0.7;                                                            %Arbitrary y2
% %     z(1)=fitpln(0.8,0.3);                                                  %Get z1
% %     z(2)=fitpln(0.4,0.7);                                                  %Get z2
% %     n = cross([0.8,0.3,z(1)],[0.4,0.7,z(2)]);                              %Normal vector
%     
%     z(1)=fitpln(0.9999,0.0001);                                                  %Get z1
%     z(2)=fitpln(0.0001,0.9999);                                                  %Get z2
%     n = cross([0.9999,0.0001,z(1)],[0.0001,0.9999,z(2)]);     
%     
%     n = n/norm(n);                                                         %Normalized normal vector
%     %Error
%     rSqu = gof.rsquare;

end