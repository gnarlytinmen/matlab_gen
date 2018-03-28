function [centangles] = centangle3(poi,pointset)
% Finds the central angle between a given point and a set of other points
% on a unit sphere. Input should be in spherical coordinates (az,el), where
% coordinates follow lab conventions az: [0,360) and el: [-90,90].
%
% Usage: [centangles] = centangle3(point of interest,set of points)

% Central angle between two points on a sphere (spherical coords method)

% sph_centang = @() ...
% atan2(sqrt((cos().*sin()).^2 + (cos().*sin() - sin().*cos().*cos()).^2)...
%       ./(sin().*sin() + cos().*cos().*cos()));

% More accurate (?) dot product method
% ------------------------------------------------------------------------%

% Convert points from spherical to cartesian coords 
poi_cart = spher2cart(poi);
pointset_cart = spher2cart(pointset);

% Compute dot product between point of interest and all specified points
numpts = size(pointset_cart,1);
poi_mat = repmat(poi_cart,numpts,1);
dotprods = dot(poi_mat,pointset_cart,2);

% Get central angle from dotprods

centangles = acosd(dotprods);

% plot to test
% f = figure;
% f.Position = [100 100 900 700];
% hold on;
% scatter3(poi_cart(1),poi_cart(2),poi_cart(3),15,'r','filled');
% scatter3(pointset_cart(:,1),pointset_cart(:,2),pointset_cart(:,3),15,'b','filled');
% plot3([-1 1],[0 0],[0 0],'k');
% plot3([0 0],[-1 1],[0 0],'k');
% plot3([0 0],[0 0],[-1 1],'k');
% plot3([-cosd(45) cosd(45)],[-cosd(45) cosd(45)],[0 0],'k');
% plot3([-cosd(45) cosd(45)],[cosd(45) -cosd(45)],[0 0],'k');
% 
% set(gca,'CameraPosition',[-11.4 -12.3 4.4],'Projection','perspective'...
%     );

end