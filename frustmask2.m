function [final_dots,h,v]=frustmask2(screenh,screenv,d)
lefts=-screenh/2*d:screenh/20:-screenh/20;
rights=screenh/2:screenh/20:screenh/20*d;
bottoms=-screenv/2*d:screenv/20:-screenv/20;
tops=screenv/2:screenv/20:screenv/20*d;

horiz_bounds=[lefts;rights];
vert_bounds=[bottoms;tops];

horiz_bounds=round(horiz_bounds);
vert_bounds=round(vert_bounds);

h=rights(end)*2;
v=tops(end)*2;

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