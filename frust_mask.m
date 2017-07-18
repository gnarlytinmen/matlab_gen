function [final_dots,h,v]=frust_mask(varargin)

% Define FOV boundaries

if nargin==0
    halfscreen_h=60;
    halfscreen_v=33.75;
    d=100;
    screen_dist=50;
else
    halfscreen_h=varargin{1}/2;    % Screen Horizontal size in cm
    halfscreen_v=varargin{2}/2;     % Screen Vertical size in cm
    d=varargin{3};    % Field depth in cm
    screen_dist=varargin{4};
    dot_thresh=varargin{5};
end

%dot_thresh=2500; 

theta_h=atan(halfscreen_h/screen_dist);
theta_v=atan(halfscreen_v/screen_dist);

x=0:1:d-1;                      % depth of generated volume
a=(screen_dist+x)*tan(theta_h);      % distance from center to horizontal bound at each depth plane
b=(screen_dist+x)*tan(theta_v);      % distance from center to veritcal bound at each depth plane

a_r=round(a);                   % round vals
b_r=round(b);

h=a_r(end)*2+4;
v=b_r(end)*2+2;

rights=((h+1)/2)*ones(1,numel(a_r))+a_r-0.5;        % vectors of all boundaries at each depth plane
lefts=((h+1)/2)*ones(1,numel(a_r))-a_r+0.5;
tops=((v+1)/2)*ones(1,numel(b_r))+b_r-0.5;
bottoms=((v+1)/2)*ones(1,numel(b_r))-b_r+0.5;

horiz_bounds=[lefts;rights];
vert_bounds=[bottoms;tops];

% Build 3D mask

mask=zeros(v,h,d);        % build empty 3D space defined by slight overestimate of furthest depth plane size

for i=1:d
    h1=[zeros(1,horiz_bounds(1,i)-1),ones(1,horiz_bounds(2,i)-horiz_bounds(1,i)+1),zeros(1,h-horiz_bounds(2,i))];
    v1=[zeros(1,vert_bounds(1,i)-1),ones(1,vert_bounds(2,i)-vert_bounds(1,i)+1),zeros(1,v-vert_bounds(2,i))];
    
    [h2,v2]=meshgrid(h1,v1);
    mask_place=h2.*v2;
    
    mask(:,:,i)=mask_place;
end

% Generate random dot field in volume

[dots]=rand_dotcloud(dot_thresh,h,v,d,0);

dot_vol=zeros(v,h,d);

for j=1:numel(dots)/3
dot_vol(dots(j,2),dots(j,1),dots(j,3))=1;
end

masked_dots=mask.*dot_vol;

linds=find(masked_dots==1);
[f1,f2,f3]=ind2sub(size(masked_dots),linds);

final_dots=[f1,f2,f3];

end