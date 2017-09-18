function [M] = threeD_param_animate(data,degs,units,filename)
% 3D parameter map
%%% CURRENTLY HARD CODED TO PLOT TUNING CENTER

x = data;
exportpath = ['/home/tyler/Desktop/',filename,'_paramfit_3D.avi'];
framerate = 25;
rotation_mag = degs*2;  % Degrees, multiplied by 2 since camorbit is in half-degree steps

figure1 = figure;
set(gcf,'Position',[50 50 1300 900],'Color',[1 1 1]);
ax = axes(figure1);
set(ax,'Units','pixels');

hold on;
xmax = round(max(max(x)));
camviewang = 3*xmax/120;
h = scatter3(x(:,2),x(:,3),x(:,4),65,'filled');
plot3([0 xmax],[0 xmax],[0 xmax],'r','LineWidth',5);
unit_lab = {' (degs)',' (sp/s)'};
xlabel(['Normal pursuit',unit_lab(units)]);
ylabel(['Simulated pursuit',unit_lab(units)]);
zlabel(['Stabilized pursuit',unit_lab(units)]);
set(gca,'XLim',[0,xmax],'YLim',[0,xmax],'ZLim',[0,xmax],'FontSize',18);
set(gca,'XGrid','on','YGrid','on','ZGrid','on','GridAlpha',0.4,...
    'CameraPosition',[2700 -2000 1200],...
    'CameraViewAngle',camviewang);

axis vis3d

M(120)=struct('cdata',[],'colormap',[]);

for i = 1:rotation_mag
    camorbit(0.5,0,'camera')
    drawnow
    M(i) = getframe(gcf, [0, 0, 1300, 900]);
end
for i = 1:rotation_mag
    camorbit(-0.5,0,'camera')
    drawnow
    M(i+60) = getframe(gcf, [0, 0, 1300, 900]);
end

writerObj = VideoWriter(exportpath,'Motion JPEG AVI');
writerObj.FrameRate = framerate;
open(writerObj);
for i=1:120
    frame = M(i).cdata;
    writeVideo(writerObj,frame);
end
close (writerObj);

end