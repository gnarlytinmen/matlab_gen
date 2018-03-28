function [cartcoords] = spher2cart(spherecoords)
% Converts 2D spherical coordinates to 3D cartesian coordinates. Input 
% (in degrees)is either nx3 set of points (az,el,radius) for any arbitrary 
% set of points or nx2 for points about a unit sphere. Output coords are 
% (x,y,z) - need to fix coordinate system?.
% 
% Usage [cartcoords] = spher2cart(spherecoords)

numpts = size(spherecoords,1);

if size(spherecoords,2) == 2
    r = ones(numpts,1);
    scoord = [spherecoords r];
else
    scoord = spherecoords;
end
   
% cart = @(az,el,r) [r.*sind(el).*cosd(az) r.*sind(el).*sind(az) r.*cosd(el)];
% Use lab coordinate system
cart = @(az,el,r) [r.*cosd(el).*sind(az) r.*sind(el) r.*cosd(el).*cosd(az)];

% Since elevation must be [0,180] and azimuth [0,360):
% 1) offset elevation from normal [-90,90] conventions used in lab
% 2) rotate axes to zero-left mathematical convention

scoord = [scoord(:,1) scoord(:,2) scoord(:,3)];

% Convert to cartesian coords
cartcoords = cart(scoord(:,1),scoord(:,2),scoord(:,3));

end