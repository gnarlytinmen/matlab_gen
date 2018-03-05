function [M,dots,anidots,twodanidots] = ani_flow(varargin)

% Usage: [M,dots,anidots,twodanidots] = ani_flow(vid_length,t,r)
%        [M,dots,anidots,twodanidots] = ani_flow(vid_length,t,r,video_name)
%        t = [az el speed] in cm/sec
%        r = [rx ry rz] in deg/sec (x:l/r, y:/d, z:f/b)
% Generates bighead-like flow patterns with option to save to .avi
% Uses rand_dotcloud.m and frust_mask.m functions

% Setup
fixation = 0;
pursuit = 0;
plot_still = 0;   % collapses all video frames into single plot
framerate = 25;   % set framerate for video in fps

if nargin == 3
    % Number of frames generated (frames = video length*x fps)
    num_frames = varargin{1}*framerate;
    t = varargin{2};
    t(3) = t(3)/framerate;
    r = varargin{3}./framerate;
    save_vid = 0;
elseif nargin == 4
    num_frames = varargin{1}*framerate;
    t = varargin{2};
    t(3) = t(3)/framerate;
    r = varargin{3}./framerate;
    video_path = ['/home/tyler/Desktop/',varargin{4}];
    save_vid = 1;
elseif nargin == 5
    num_frames = varargin{1}*framerate;
    t = varargin{2};
    t(3) = t(3)/framerate;
    r = varargin{3}./framerate;
    video_path = ['/home/tyler/Desktop/',varargin{4}];
    if strcmp('fixation',varargin{5})
        fixation = 1;
    elseif strcmp('pursuit',varargin{5})
        pursuit = 1;
    end
    save_vid = 1;
end

numdots = 4500;         % Define number of dots in intial unmasked space
h = 120;    % Screen Horizontal size in cm
v = 70;     % Screen Vertical size in cm
d = 150;
screen_dist = 50;
depth_scale = 0.025;  % Perspective scale factor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Radius of sphere containing all possible FoVs for rotation around central
% point (hypotenuse of triangle made between edge and center of far plane and viewer)
radiuso = d/cos((atan(h/(2*screen_dist))));

% Generate cube volume containing this sphere, fill with random dots
clength = round(2*radiuso,-1);
[dots_linds] = rand_dotcloud(numdots,clength,0);

[r1,c1,d1] = ind2sub([clength,clength,clength],dots_linds);
dots1 = [r1',c1',d1'];

[~,~,frust_vol] = frust_mask(h,v,screen_dist,d);

mask = zeros(clength,clength,clength);
mask(131:340,56:415,285:385) = frust_vol;

% Center dots around horizontal and vertical dimensions + add screen offset
dots(:,1) = dots1(:,2,1);   % x .... check these
dots(:,2) = dots1(:,1,1);   % y
dots(:,3) = dots1(:,3,1);   % z

% Setup velocity (displacement opposite directions of self-motion)

% Setup INITIAL translation in eye-centered coordinates
% Positives simulate self translation in positive axis direction
% Transform into 3D cartesian coords from 2D polar coords as well
tx = sin(t(1)*(pi/180))*t(3);
ty = sin(t(2)*(pi/180))*t(3);
tz = cos(t(1)*(pi/180))*t(3);

% Positives simulate clockwise rotational self-motion
%(+ve = right/up rotations)
rx = r(1)*pi/180;
ry = r(2)*pi/180;
rz = r(3)*pi/180;

% Calculate 3D dot positions in each frame
% (from adding rotation matrices Rx[x y z]' + Ry[x y z]' + Rz[x y z]' and translation matrix)
anidots = zeros(numdots,3,num_frames);
anidots(:,:,1) = dots - clength/2;

% Generate framewise xforms for each dot
dxdt = @(x,y,z,rz,ry,tx)-tx...
    +x.*cos(rz)-y.*sin(rz)-x... % where does the position dependence come in?
    +x.*cos(ry)-z.*sin(ry)-x;
dydt = @(x,y,z,rz,rx,ty)-ty...
    +x.*sin(rz)+y.*cos(rz)-y...
    +z.*sin(rx)+y.*cos(rx)-y;
dzdt = @(x,y,z,rx,ry,tz)-tz...
    +x.*sin(ry)+z.*cos(ry)-z...
    +z.*cos(rx)-y.*sin(rx)-z;

% Define limits of dot volume
boundmax = clength - clength/2;
boundmin = -boundmax + 1;

for i = 2:num_frames
    % Calculate distortion of flow due to retinal slip
    anidots(:,1,i) = anidots(:,1,i-1) + ...
        dxdt(anidots(:,1,i-1),anidots(:,2,i-1),anidots(:,3,i-1),rz,ry,tx);
    anidots(:,2,i) = anidots(:,2,i-1) + ...
        dydt(anidots(:,1,i-1),anidots(:,2,i-1),anidots(:,3,i-1),rz,rx,ty);
    anidots(:,3,i) = anidots(:,3,i-1) + ...
        dzdt(anidots(:,1,i-1),anidots(:,2,i-1),anidots(:,3,i-1),rx,ry,tz);
    
    % Since this is modeling retinotopic coordinates, rotate translation
    % vector relative to viewing direction
    tx = -tx+tx.*cos(rz)-ty.*sin(rz)...
        +tx.*cos(ry)-tz.*sin(ry);
    ty = -ty+tx.*sin(rz)+ty.*cos(rz)...
        +tz.*sin(rx)+ty.*cos(rx);
    tz = -tz+tx.*sin(ry)+tz.*cos(ry)...
        +tz.*cos(rx)-ty.*sin(rx);
    
    % Detect dots going past limits of volume, regenerate on opposite side
    
    % Find exiting dots
    collided_dots_xmn = find(anidots(:,1,i) < boundmin);
    collided_dots_xmx = find(anidots(:,1,i) > boundmax);
    collided_dots_ymn = find(anidots(:,2,i) < boundmin);
    collided_dots_ymx = find(anidots(:,2,i) > boundmax);
    collided_dots_zmn = find(anidots(:,3,i) < boundmin);
    collided_dots_zmx = find(anidots(:,3,i) > boundmax);
    
    % Add dots equal to number of collided dots to furthest depth plane
    
    % Collided against: xmin
    if ~isempty(collided_dots_xmn)
        num_regendots_xmx = numel(collided_dots_xmn);
        anidots(collided_dots_xmn,1,i) = boundmin*ones(num_regendots_xmx,1);
        anidots(collided_dots_xmn,2,i) = ...
            randi([boundmin,boundmax],num_regendots_xmx,1);
        anidots(collided_dots_xmn,3,i) = ...
            randi([boundmin,boundmax],num_regendots_xmx,1);
    end
    
    % xmax
    if ~isempty(collided_dots_xmx)
        num_regendots_xmn = numel(collided_dots_xmx);
        anidots(collided_dots_xmx,1,i) = boundmax*ones(num_regendots_xmn,1);
        anidots(collided_dots_xmx,2,i) = ...
            randi([boundmin,boundmax],num_regendots_xmn,1);
        anidots(collided_dots_xmx,3,i) = ...
            randi([boundmin,boundmax],num_regendots_xmn,1);
    end
    
    % ymin
    if ~isempty(collided_dots_ymn)
        num_regendots_ymx = numel(collided_dots_ymn);
        anidots(collided_dots_ymn,1,i) = ...
            randi([boundmin,boundmax],num_regendots_ymx,1);
        anidots(collided_dots_ymn,2,i) = boundmin*ones(num_regendots_ymx,1);
        anidots(collided_dots_ymn,3,i) = ...
            randi([boundmin,boundmax],num_regendots_ymx,1);
    end
    
    % ymax
    if ~isempty(collided_dots_ymx)
        num_regendots_ymn = numel(collided_dots_ymx);
        anidots(collided_dots_ymx,1,i) = ...
            randi([boundmin,boundmax],num_regendots_ymn,1);
        anidots(collided_dots_ymx,2,i) = boundmax*ones(num_regendots_ymn,1);
        anidots(collided_dots_ymx,3,i) = ...
            randi([boundmin,boundmax],num_regendots_ymn,1);
    end
    
    % zmin
    if ~isempty(collided_dots_zmn)
        num_regendots_zmx = numel(collided_dots_zmn);
        anidots(collided_dots_zmn,1,i) = ...
            randi([boundmin,boundmax],num_regendots_zmx,1);
        anidots(collided_dots_zmn,2,i) = ...
            randi([boundmin,boundmax],num_regendots_zmx,1);
        anidots(collided_dots_zmn,3,i) = boundmin*ones(num_regendots_zmx,1);
    end
    
    % zmax
    if ~isempty(collided_dots_zmx)
        num_regendots_zmn = numel(collided_dots_zmx);
        anidots(collided_dots_zmx,1,i) = ...
            randi([boundmin,boundmax],num_regendots_zmn,1);
        anidots(collided_dots_zmx,2,i) = ...
            randi([boundmin,boundmax],num_regendots_zmn,1);
        anidots(collided_dots_zmx,3,i) = boundmax*ones(num_regendots_zmn,1);
    end
end

% Convert subscripts to ones in 3D space, mask, then convert back to
% subscripts (not great, would like to do this without a loop - verrry slow)
masked_anidots = nan(size(anidots,1),3,num_frames);

for i = 1:num_frames
    dots3d = zeros(clength,clength,clength);
    
    dotsubs = round(anidots(:,:,i) + clength/2);    % introducing some error here with rounding
    linds = sub2ind(size(dots3d),dotsubs(:,1),...
        dotsubs(:,2),dotsubs(:,3));
    
    dots3d(linds) = 1;
    masked_dots = mask.*dots3d;
    
    linds2 = find(masked_dots == 1);
    [f1,f2,f3] = ind2sub(size(masked_dots),linds2);
    
    masked_anidots(1:length(f1),:,i) = [f1,f2,f3];
end

% Project dots onto 2D screen coords, calculate each frame
twodanidots = zeros(size(masked_anidots,1),2,num_frames);

for i = 1:num_frames
    % Project 3D dot cloud onto screen
    twodanidots(:,1,i) = masked_anidots(:,1,i)./...
        (masked_anidots(:,3,i)*depth_scale); % X coords
    twodanidots(:,2,i) = masked_anidots(:,2,i)./...
        (masked_anidots(:,3,i)*depth_scale); % Y coords
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot and animate

M(num_frames) = struct('cdata',[],'colormap',[]);
dot_displacement = linspace(-25.4,25.4,num_frames);

fig = figure('Position',[25 50 1778 1000], 'menu', 'none', 'Color',[0 0 0]);
ax = axes(fig);
set(ax,'Units','pixels','Position', [0 0 1778 1000]);
set(ax,'XLim',[-50 50],'YLim',[-35 35],'Visible','off');

for i = 1:num_frames
    h1 = line(twodanidots(:,1,i),twodanidots(:,2,i),'Color','w',...
        'LineStyle','none','Marker','.','MarkerSize', 15, 'Parent', ax);
    
    if pursuit == 1
        h2 = line(dot_displacement(i),0,'Color','r','LineStyle','none',...
            'Marker','.','MarkerSize', 30, 'Parent', ax);
    elseif fixation == 1
        h2 = line(0,0,'Color','r','LineStyle','none','Marker','.',...
            'MarkerSize', 20, 'Parent', ax);
    end
    
    drawnow;
    M(i) = getframe(gcf, [0, 0, 1778, 1000]);
    
    if ~pursuit && ~fixation
        delete([h1]);
    else
        delete([h1;h2]);
    end
end

if save_vid == 1
    writerObj = VideoWriter(video_path,'Motion JPEG AVI');
    writerObj.FrameRate = framerate;
    open(writerObj);
    for i = 1:num_frames
        frame = M(i).cdata;
        writeVideo(writerObj,frame);
    end
    close (writerObj);
end

if plot_still == 1
    fig2 = figure;hold on;
    set(gca,'pos', [0 0 1 1]);
    set(gca,'XLim',[-50 50],'YLim',[-35 35],'Visible','off');
    set(fig2,'Position',[25 25 1778 1000]);
    set(gcf,'Color',[0 0 0]);
    grays = linspace(0.25,1,num_frames);
    
    for i = 1:num_frames
        hold on;
        % Keep all dots white regardless of frame
        %         scatter(twodanidots(:,1,i),twodanidots(:,2,i),[],'.w');
        
        % In collapsed plot, dim dots in earlier frames
        scatter(twodanidots(:,1,i),twodanidots(:,2,i),5,...
            [grays(i) grays(i) grays(i)],'filled');
    end
    
    scatter(0,0,'r','filled');
end

end