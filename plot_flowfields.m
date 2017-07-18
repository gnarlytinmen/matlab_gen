function [X,Y,dx_dt,dy_dt]=plot_flowfields(plane_dist,focal_dist,trans_vel,rot_vel)

% Plots flow fields for a frontoparallel plane using optic flow model from
% Longuet-Higgins and Prazdny 1980

% Using a 10x10 plane
x=-10:1:10;
y=-10:1:10;

% Assign parameters

z=plane_dist;
f=focal_dist;
V=trans_vel;    % V=[vx vy vz]
R=rot_vel;      % R=[wx wy wz] - positive values=R/U/CW eye rotation

% Calculate flow field ff(u;v)

dx_dt=zeros(21,21);
dy_dt=zeros(21,21);

for i=1:21
    for j=1:21
        dx_dt(i,j)=(1/z).*(-f*V(1)+x(j).*V(3))+...             % Translation component
                   (1/f).*((R(1).*x(j).*y(i))-(R(2).*(f^2+x(j).^2))+(R(3)*f.*y(i))); % Rotational component
        dy_dt(i,j)=(1/z).*(-f*V(2)+y(i).*V(3))+...
                   (1/f).*((R(1).*(f^2+y(i).^2))-(R(2).*x(j).*y(i))-(R(3)*f.*x(j)));
    end
end

% Plot flow field

[X,Y]=meshgrid(x,y);

quiver(X,Y,dx_dt,dy_dt);%,'ShowArrowHead','off');
set(gca,'Visible','off','Box','off');
set(gcf,'Position',[50 50 900 900]);

end