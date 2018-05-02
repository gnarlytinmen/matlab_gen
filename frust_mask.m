function [h,v,mask] = frust_mask(varargin)

% Define FOV boundaries

if nargin == 0
    halfscreen_h = 60;
    halfscreen_v = 33.75;
    d = 100;
    screen_dist = 50;
else
    halfscreen_h = varargin{1}/2;    % Screen Horizontal size in cm
    halfscreen_v = varargin{2}/2;     % Screen Vertical size in cm
    screen_dist = varargin{3};
    d = varargin{4} - screen_dist;    % Field depth in cm
end

theta_h = atan(halfscreen_h/screen_dist);
theta_v = atan(halfscreen_v/screen_dist);

z = (0:1:d) + screen_dist;  % depths in generated volume
a = z*tan(theta_h);      % distance from center to horizontal bound at each depth plane
b = z*tan(theta_v);      % distance from center to veritcal bound at each depth plane

a_r = round(a);                   % round vals
b_r = round(b);

h = a_r(d+1)*2;      % width of far plane (add 4?)
v = b_r(d+1)*2;      % height of far plane (add 2?)

rights = (h/2)*ones(1,numel(a_r)) + a_r;        % vectors of all boundaries at each depth plane
lefts = (h/2)*ones(1,numel(a_r)) - a_r;
tops = (v/2)*ones(1,numel(b_r)) + b_r;
bottoms = (v/2)*ones(1,numel(b_r)) - b_r;

horiz_bounds = [lefts;rights];
vert_bounds = [bottoms;tops];

% Build 3D mask

mask = zeros(v,h,d+1);        % build empty 3D space defined by slight overestimate of furthest depth plane size

for i = 1:d+1
    h1 = [zeros(1,horiz_bounds(1,i)),...
          ones(1,horiz_bounds(2,i) - horiz_bounds(1,i)),...
          zeros(1,h - horiz_bounds(2,i))];
    v1 = [zeros(1,vert_bounds(1,i)),...
          ones(1,vert_bounds(2,i) - vert_bounds(1,i)),...
          zeros(1,v - vert_bounds(2,i))];
    
    [h2,v2] = meshgrid(h1,v1);
    mask_place = h2.*v2;
    
    mask(:,:,i) = mask_place;
end

end