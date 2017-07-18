% Build Bighead Diagram

load('C:\Users\tyler\Documents\MATLAB\lines.mat');

% Define FOV boundaries

x=1:1:100;
a=(49+x)*tan((50/180)*pi);
b=(49+x)*tan((34/180)*pi);

a_r=round(a);
b_r=round(b);

rights=180.5*ones(1,numel(a_r))+a_r-0.5;
lefts=180.5*ones(1,numel(a_r))-a_r+0.5;
tops=102.5*ones(1,numel(b_r))+b_r-0.5;
bottoms=102.5*ones(1,numel(b_r))-b_r+0.5;

horiz_bounds=[lefts;rights];
vert_bounds=[bottoms;tops];

% Build 3D mask

mask=zeros(204,360,100);

for i=1:100
    h1=[zeros(1,horiz_bounds(1,i)-1),ones(1,horiz_bounds(2,i)-horiz_bounds(1,i)+1),zeros(1,360-horiz_bounds(2,i))];
    v1=[zeros(1,vert_bounds(1,i)-1),ones(1,vert_bounds(2,i)-vert_bounds(1,i)+1),zeros(1,204-vert_bounds(2,i))];
    
    [h,v]=meshgrid(h1,v1);
    mask_place=h.*v;
    
    mask(:,:,i)=mask_place;
end

mask_inv=double(~mask);

% Generate random dot field in volume

[dots]=rand_dotcloud(900,360,204,100,0);

dot_vol=zeros(204,360,100);

for j=1:numel(dots)/3
dot_vol(dots(j,2),dots(j,1),dots(j,3))=1;
end

masked_dots=mask.*dot_vol;
invisi_dots=mask_inv.*dot_vol;

linds=find(masked_dots==1);
linds2=find(invisi_dots==1);
[f1,f2,f3]=ind2sub(size(masked_dots),linds);
[f11,f22,f33]=ind2sub(size(invisi_dots),linds2);

final_dots=[f1,f2,f3];
final_inv_dots=[f11,f22,f33];

hold on;
% scatter3(final_dots(:,2),final_dots(:,3)-100,final_dots(:,1),'.k');
scatter3(final_dots(:,2),final_dots(:,3)-100,final_dots(:,1),'.w');
scatter3(final_inv_dots(:,2),final_inv_dots(:,3)-100,final_inv_dots(:,1),5,...
    'MarkerEdgeColor',[0.2 0.2 0.2],'MarkerFaceColor',[0.2 0.2 0.2]);
plot3(lines(:,1),lines(:,3),lines(:,2));
set(gca,'Projection','perspective','Visible','off','CameraPosition',[2440 -707 260]);