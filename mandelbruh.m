function [mat] = mandelbruh(xbounds,ybounds,iterations,incax,out_filename)

% Plots Mandelbrot set

% bounds to try:
% [-0.77568382 -0.77568372],[0.13646732 0.13646742]
% [-0.7496 -0.741],[0.1321 0.1449]

% Plotting params
outpxvert = 1500;

xlim = xbounds;
ylim = ybounds;

xrange = xlim(2) - xlim(1);
yrange = ylim(2) - ylim(1);
plotAR = xrange/yrange;

resolution = round(yrange/outpxvert,1,'significant');

x = xlim(1):resolution:xlim(2);
y = ylim(1):resolution:ylim(2);

iter0 = 0;
iterMax = iterations;

[matX0,matY0] = meshgrid(x,y);
matY0 = matY0*-1;
matX = matX0;
matY = matY0;

mat = zeros(numel(y),numel(x));

% Begin Iterating
% maybe try to creat a mex function for this..
for i = iter0:iterMax
    xTemp = matX.^2 - matY.^2 + matX0;
    matY = 2.*matX.*matY + matY0;
    matX = xTemp;
    matTemp = matY.*matX;
    
%   xtmp = (zx*zx + zy*zy) ^ (n / 2) * cos(n * atan2(zy, zx)) + cx;
% 	zy = (zx*zx + zy*zy) ^ (n / 2) * sin(n * atan2(zy, zx)) + cy;
% 	zx=xtmp;
    
    
    boundTemp = matTemp > 4;
    boundTemp2 = mat == 0;
    
    newBoundInds = logical(boundTemp.*boundTemp2);
    mat(newBoundInds) = i;
end

mat = log(mat)./log(40);

infinds = mat == -Inf;
% maxdat = max(max(mat));
if infinds(1) ~= 1
    mat(infinds) = mat([infinds(2:end) 0]);
else
    mat(infinds(2:end)) = mat([infinds(3:end) 0]);
end

% Plot
figure;
imagesc(xbounds,ybounds,mat);
set(gca,'YDir','normal');
set(gcf,'Units','Pixels',...
        'Position',[100 0 floor(1000*plotAR) 1000]);
    
if incax
    set(gca,'xtick',xlim(1):xrange/25:xlim(2),'ytick',ylim(1):yrange/25:ylim(2),...
            'xgrid','on','ygrid','on');
else
    set(gcf,'paperunits','inches','paperposition',[0 0 5*plotAR 5]);
    clipmargins(gca,0);
    set(gca,'Visible','off');
    set(gcf,'ToolBar','none','MenuBar','none');
    
    if out_filename ~= 0
        print(['/home/tyler/Desktop/',out_filename,'.png'],...
               '-dpng',['-r' num2str(300)]);
    end   
end

end