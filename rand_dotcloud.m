function [dots] = rand_dotcloud(varargin)

% Make 3D random dot cloud
% Usage: rand_dotcloud(thresh,dimensions_h,dimensions_v,dimensions_d,plot_onoff)
%     OR rand_dotcloud(thresh,cube_side_length,plot_onoff)

% Setup
notcube = 0;
plots = 0;

if nargin > 3
    notcube = 1;
    num_dots = varargin{1};         % Define percentage of empty space (x/1000)
    h = varargin{2};    % Screen Horizontal size in cm
    v = varargin{3};     % Screen Vertical size in cm
    d = varargin{4};    % Field depth in cm
    if varargin{5} == 1
        plots = 1;
    end
elseif nargin == 3      % For cube space
    num_dots = varargin{1};
    h = varargin{2};
    if varargin{3} == 1
        plots = 1;
    end
end

% Generate nx1 vector of random dot linear indices in cuboid space
if notcube
    dots = randperm(h*v*d,num_dots);
else
    dots = randperm(h^3,num_dots);
end

if plots
    % Plot dots in 3D void
    dotfield = figure(1);
    set(dotfield,'Position',[50 50 1400 900]);
    scatter3(dots(:,1),dots(:,3),dots(:,2),'.k');
    set(gca,'Projection','perspective','Box','on','BoxStyle','full','CameraPosition',[469 -564 390]);
    set(gca,'YLim',[0 d],'XLim',[0 h],'ZLim',[0 v]);
end
end