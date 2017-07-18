function [dots,delta_dots,h]=rand_flowfield_projr(az,el,trans_vel,purs_angle,rot_vel)

% Usage: rand_flowfield(az,el,vt,purs_angle,pur_vel)
% az,el,and pursuit angle/vel inputs should be in units of degrees or deg/s.

% Generates 3D matrix of random dots and calculates/plots specified
% translational & rotational motion (uses model from Longuet-Higgins and
% Prazdny 1980 for each plane of data, which matches stimulus). Rotation component 
% takes tangent error into consideration.
% Translation does not take tangent error into consideration (matches
% stimulus, which simply mimicks space shifting towards plane of screen)

% Use 6.667 units/sec for translational velocity and 10 deg/sec to
% match bighead setup. Dot density in bighead is set to 1000/m^3

% Set up parameters
num_dots=1200;   % Set number of dots in flow field (810 to match stimulus volume of 0.81 m^3)
dist=6.667;     % Set screen distance to match setup
f=dist;         % Set focal distance to screen distance, where fixation point is

vt=trans_vel;               % Calculate components of translation vector
vy=-vt*sin(el/(180/pi));    % Adjust sign to match lab convention
vxz=vt*cos(el/(180/pi));
vx=vxz*sin(az/(180/pi));
vz=vxz*cos(az/(180/pi));
V=[vx vy vz];    


rt=rot_vel/(180/pi);
theta=purs_angle/(180/pi);
ry=rt*sin(theta);
rx=rt*cos(theta);
R=[ry rx 0];      % R=[wx wy wz] - positive values=R/U/CW eye rotation

res=0.125;    % Set resolution, must be some multiple of (2)^-1 (works best around 0.125-0.25)
h=16/res+1;
v=9/res+1;
d=13/res+1;

frust=0;

% Get dot cloud

if frust==1
    [dots,hmax,vmax]=frust_mask(h,v,d,dist);  % Get frustum of dots instead of simple cube
else
    [dots]=rand_dotcloud(num_dots,h,v,d,0);
end

% Calculate dx/dt and dy/dt (doesn't take into account scaling of planes with depth)

[num_dots,~]=size(dots);    % Should be roughly (thresh/1000)*(dimx*dimy*dimz)
dx_dt=zeros(v,h,d);
dy_dt=zeros(v,h,d);

for i=1:num_dots
    x=res*(dots(i,1)-(1+(h-1)/2));  % Scale and zero-center
    y=res*(dots(i,2)-(1+(v-1)/2));
    z=res*(dots(i,3)-1)+dist;
    xind=dots(i,1);
    yind=dots(i,2);
    zind=dots(i,3);
    
    % Not sure why this works - if x and y positions aren't switched, trans
    % becomes rotation and vice versa..
    
    dx_dt(yind,xind,zind)=(1/z)*(-f*V(1)+x*V(3))+...                      % Translational component
                         (1/f)*((R(1)*x*y)-(R(2)*(f^2+x^2))+(R(3)*f*y)); % Rotational component
    delta_dots(i,1)=dx_dt(yind,xind,zind);
    dy_dt(yind,xind,zind)=(1/z)*(-f*V(2)+y*V(3))+...
                         (1/f)*((R(1)*(f^2+y^2))-(R(2)*x*y)-(R(3)*f*x));
    delta_dots(i,2)=dy_dt(yind,xind,zind);
    delta_dots(i,3)=0;
                     
    clear x y z
end

% Plot flowfield

if frust==1
    x=-hmax/2:res:hmax/2;
    y=-vmax/2:res:vmax/2;
    z=0+dist:res:13+dist;
else
    x=-8:res:8;
    y=-4.5:res:4.5;
    z=0+dist:res:13+dist;
end

dz_dt=zeros(v,h,d); % Set dummy var for quiver3

[X,Y,Z]=meshgrid(x,y,z);   % make sure -y in bottom portion of graph

figure;clf;hold on;
quiver3(X,Y,Z,dx_dt,dy_dt,dz_dt,6,'Color',[0.3 0.3 0.3]);%,'ShowArrowHead','off');
scatter3(0,0,dist,20,'r','filled');
set(gca,'Visible','off','Box','off','Projection','perspective','CameraPosition',[0 0 -170]);
set(gca,'YLim',[-4.5 4.5],'XLim',[-8 8],'ZLim',[0+dist 13+dist]);
set(gcf,'Position',[50 50 1600 900]);
               
end