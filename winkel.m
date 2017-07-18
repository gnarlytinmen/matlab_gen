function [rawmat,FR_interps,upsampAzVec,upsampElVec]=winkel(path)

% Projects matrix of heading direction-wise firing rate values onto 2D map
% using Winkel Tripel Projection that optimally minimizes three distortions: 
% area,direction and distance.
%
% Usage: [rawmat,FR_interps,sampAzVec,sampElVec]=winkel(path)

% Load in samples of full spherical tuning

load([path,'\heading_tuning\head_trials.mat']);

num_heads=numel(head_trials);
rawmat=zeros(num_heads,3);

res=2*pi*(1/100);

for i=1:num_heads
    rawmat(i,1)=head_trials(i).head_az;
    rawmat(i,2)=head_trials(i).head_el;
    rawmat(i,3)=head_trials(i).mean_FR;
end

% Linearly interpolate between points in spherical coordinates 
% (22.5deg (pi/8) resolution, azimuth outputs from -180:360:180)

% [FR_interps,sampAzVec,sampElVec]=...
%     spherinterp(rawmat(:,1),rawmat(:,2),rawmat(:,3),res);

% Just use interp2 instead
sampAzVec = 0:pi/4:2*pi;         % Generate spherical grid to map interps to
sampElVec = -1*(-pi/2:pi/4:pi/2);    
[sampAzMat, sampElMat] = meshgrid(sampAzVec, sampElVec);

upsampAzVec = [pi:res:2*pi-res 0:res:pi];         % Generate spherical grid to map interps to
upsampElVec = -1*(-pi/2:res:pi/2);    
[upsampAzMat, upsampElMat] = meshgrid(upsampAzVec, upsampElVec);

numaz=numel(unique(rawmat(:,1)));
FRs = [ones(1,numaz)*rawmat(1,3);rawmat(2:9,3)';rawmat(10:17,3)';rawmat(18:25,3)';ones(1,numaz)*rawmat(26,3)];
FRs = [FRs FRs(:,1)];

[FR_interps]=interp2(sampAzMat,sampElMat,FRs,upsampAzMat,upsampElMat);

% Plot interpolations in on cartesian plot
az_label=-180:res*(180/pi):180;
[x2,y2]=meshgrid(az_label,upsampElVec*(180/pi));

figure3=figure;
axes1=axes('Parent',figure3,'YLim',...
    [-90,90],'XLim',[-180,180],'YTick',-90:45:90,'XTick',-180:45:180,...
    'PlotBoxAspectRatio',[1.0 0.5 0.5]);
box(axes1,'on'); hold(axes1,'all');
set(gcf,'Position',[50 200 1500 700]);

[C,h]=contourf(x2,y2,FR_interps); 
% imagesc(az_label,sampElVec*(180/pi),FR_interps);

cb=colorbar('peer',axes1);
set(get(cb,'ylabel'),'String','Firing Rate (Hz)','FontSize',15);
set(gca,'FontSize',15);
xlabel('Azimuth (deg)','FontSize',15);ylabel('Elevation (deg)','FontSize',15);
title('Preferred Heading (Center of Motion)','FontSize',15);

% Project interpolated points onto 2D surface
% lambda: longitude - central meridian (i.e. line of isoazimuth)
% phi: latitude (i.e. line of isoelevation)
% stand_par: line of latitude where projection intersects globe

stand_par=0;

xproj=@(lam,stand_par,phi)...
    0.5.*(lam.*cos(stand_par)+(2.*cos(phi).*sin(lam./2))./(acos(cos(phi).*cos(lam./2))));
yproj=@(lam,phi)...
    0.5.*(phi+sin(phi)./(acos(cos(phi).*cos(lam./2))));

dirs_sphere=rawmat(:,1:2)*(pi/180);

dirs_cart(:,1)=xproj(dirs_sphere(:,1),stand_par,dirs_sphere(:,2))*(180/pi);
dirs_cart(:,2)=yproj(dirs_sphere(:,1),dirs_sphere(:,2))*(180/pi);

end