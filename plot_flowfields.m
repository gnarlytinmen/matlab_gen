function [X,Y,dx_dt,dy_dt] = plot_flowfields(plane_dist,focal_dist,trans_vel,rot_vel)

% Plots flow fields for a frontoparallel plane using optic flow model from
% Longuet-Higgins and Prazdny 1980

% Using a 16x9 plane
x = -80:9:80;
y = -45:9:45;
numel_x = numel(x);
numel_y = numel(y);

% Assign parameters

z = plane_dist;
f = focal_dist;
V = trans_vel;    % V = [vx vy vz]
R = rot_vel;      % R = [wx wy wz] - positive values = R/U/CW eye rotation

% Calculate flow field ff(u;v)

dx_dt = zeros(numel_y,numel_x);
dy_dt = zeros(numel_y,numel_x);

for i = 1:numel_y
    for j = 1:numel_x
        dx_dt(i,j) = (1/z).*(-f*V(1)+x(j).*V(3)) + ... % Translation component
                   (1/f).*((R(1).*x(j).*y(i)) - ...    % Rotational component
                   (R(2).*(f^2+x(j).^2))+(R(3)*f.*y(i)));
        dy_dt(i,j) = (1/z).*(-f*V(2)+y(i).*V(3)) + ...
                   (1/f).*((R(1).*(f^2+y(i).^2)) - ...
                   (R(2).*x(j).*y(i))-(R(3)*f.*x(j)));
    end
end

% Plot flow field
[X,Y] = meshgrid(x,y);

h = figure;

quiver(X,Y,dx_dt,dy_dt,'k');
set(gca,'XLim',[min(x)*1.2,max(x)*1.2],'YLim',[min(y)*1.2,max(y)*1.2]);
set(gca,'Visible','off','Box','off');

tightfig(h);
set(gcf,'Position',[50 50 1600 900]);
end