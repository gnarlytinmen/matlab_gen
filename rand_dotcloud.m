function [dots]=rand_dotcloud(varargin)

% Make 3D random dot cloud (for some reason z=vertical, y=depth, x=width)
% Usage: rand_dotcloud(thresh,dimensions_h,dimensions_v,dimensions_d,plot_onoff)

% If no inputs declared, use rig dimensions

if nargin>1
    num_dots=varargin{1};         % Define percentage of empty space (x/1000)
    h=varargin{2};    % Screen Horizontal size in cm
    v=varargin{3};     % Screen Vertical size in cm
    d=varargin{4};    % Field depth in cm
    if varargin{5}==0
        plots=0;
    end
elseif nargin==1
    thr=varargin{1};
    h=120;
    v=70;
    d=100;
    plots=0;
else
    num_dots=900;
    h=120;
    v=70;
    d=100;
    plots=0;
end

space=zeros(h,v,d);
rand_space=randi([0 h*v*d],size(space));

% Get indices of random dots that pass threshold value
counter=1;
thr=h*v*d-num_dots;

for x=1:h
    for y=1:v
        for z=1:d
            if rand_space(x,y,z)>thr
                dots(counter,1)=x;
                dots(counter,2)=y;
                dots(counter,3)=z;
                
                counter=counter+1;
            end
        end
    end
end

if plots==1
    % Plot dots in 3D void
    dotfield=figure(1);
    set(dotfield,'Position',[50 50 1400 900]);
    scatter3(dots(:,1),dots(:,3),dots(:,2),'.k');
    set(gca,'Projection','perspective','Box','on','BoxStyle','full','CameraPosition',[469 -564 390]);
    set(gca,'YLim',[0 d],'XLim',[0 h],'ZLim',[0 v]);
end
end