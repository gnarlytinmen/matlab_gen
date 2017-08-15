function [M,dots,anidots,twodanidots]=ani_flow(varargin)

% Usage: [M,dots,anidots,twodanidots]=ani_flow(vid_length,t,r)
%        [M,dots,anidots,twodanidots]=ani_flow(vid_length,t,r,video_name)
%        t=[az el speed] in cm/sec
%        r=[rx ry rz] in deg/sec
% Generates bighead-like flow patterns with option to save to .avi

% Setup
fixation=0;
pursuit=0;
plot_still=1;   % collapses all video frames into single plot
framerate=25;   % set framerate for video in fps

if nargin==3
    num_frames=varargin{1}*framerate;     % Number of frames generated (frames=video length*x fps)
    t=varargin{2};
    t(3)=t(3)/framerate;
    r=varargin{3}./framerate;
    save_vid=0;
elseif nargin==4
    num_frames=varargin{1}*framerate;
    t=varargin{2};
    t(3)=t(3)/framerate;
    r=varargin{3}./framerate;
    video_path=['C:\Users\tyler\Desktop\',varargin{4}];
    save_vid=1;
elseif nargin==5
    num_frames=varargin{1}*framerate;
    t=varargin{2};
    t(3)=t(3)/framerate;
    r=varargin{3}./framerate;
    video_path=['C:\Users\tyler\Desktop\',varargin{4}];
    if strcmp('fixation',varargin{5})
        fixation=1;
    elseif strcmp('pursuit',varargin{5})
        pursuit=1;
    end
    save_vid=1;
end

numdots=4500;         % Define percentage of empty space (x/1000)
h=120;    % Screen Horizontal size in cm
v=70;     % Screen Vertical size in cm
d=150;
screen_dist=50;
depth_scale=0.025;  % Perspective scale factor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [dots]=rand_dotcloud(dot_perc,h,v,d,plots); % need to redo this to place dots in frustum space
[dots1,h2,v2]=frust_mask(h,v,d,screen_dist,numdots);
num_dots=length(dots1);

% Center dots around horizontal and vertical dimensions + add screen offset
dots(:,1)=dots1(:,2)-h2/2;
dots(:,2)=dots1(:,1)-v2/2;
dots(:,3)=dots1(:,3);

% Setup velocity (displacement opposite directions of self-motion)

% Setup INITIAL translation in eye-centered coordinates
% Positives simulate self translation in positive axis direction
tx=sin(t(1)*(pi/180))*t(3);
ty=sin(t(2)*(pi/180))*t(3);
tz=cos(t(1)*(pi/180))*t(3);

% Positives simulate clockwise rotational self-motion
%(+ve=right/up rotations)
rx=r(1)*pi/180;
ry=r(2)*pi/180;
rz=r(3)*pi/180;

% Calculate 3D dot positions in each frame
anidots=zeros(num_dots,3,num_frames);
anidots(:,:,1)=dots;

dxdt=@(x,y,z,rz,ry,tx)-tx...
    +x.*cos(rz)-y.*sin(rz)-x...
    +x.*cos(ry)-z.*sin(ry)-x;
dydt=@(x,y,z,rz,rx,ty)-ty...
    +x.*sin(rz)+y.*cos(rz)-y...
    +z.*sin(rx)+y.*cos(rx)-y;
dzdt=@(x,y,z,rx,ry,tz)-tz...
    +x.*sin(ry)+z.*cos(ry)-z...
    +z.*cos(rx)-y.*sin(rx)-z;

for i=2:num_frames
    % Calculate distortion of flow due to retinal slip
    anidots(:,1,i)=anidots(:,1,i-1)+dxdt(anidots(:,1,i-1),anidots(:,2,i-1),anidots(:,3,i-1),rz,ry,tx);
    anidots(:,2,i)=anidots(:,2,i-1)+dydt(anidots(:,1,i-1),anidots(:,2,i-1),anidots(:,3,i-1),rz,rx,ty);
    anidots(:,3,i)=anidots(:,3,i-1)+dzdt(anidots(:,1,i-1),anidots(:,2,i-1),anidots(:,3,i-1),rx,ry,tz);
    
    % Calculate rotation of distorted pattern due to change in eye position
    tx=-tx+tx.*cos(rz)-ty.*sin(rz)...
        +tx.*cos(ry)-tz.*sin(ry);
    ty=-ty+tx.*sin(rz)+ty.*cos(rz)...
        +tz.*sin(rx)+ty.*cos(rx);
    tz=-tz+tx.*sin(ry)+tz.*cos(ry)...
        +tz.*cos(rx)-ty.*sin(rx);
    
    collided_dots=find(anidots(:,3,i)<screen_dist);
    num_regendots=numel(collided_dots);
    anidots(collided_dots,:,i)=NaN;
    
    anidots(collided_dots,1,i)=randi([-h2/2,h2/2],num_regendots,1);         % Add dots equal to number of collided dots to furthest depth plane
    anidots(collided_dots,2,i)=randi([-v2/2,v2/2],num_regendots,1);
    anidots(collided_dots,3,i)=d*ones(num_regendots,1);
end


% Project dots onto 2D screen coords, project onto retina, calculate each frame
twodanidots=zeros(num_dots,2,num_frames);

for i=1:num_frames
    % Project 3D dot cloud onto screen
    twodanidots(:,1,i)=anidots(:,1,i)./(anidots(:,3,i)*depth_scale); % X coords
    twodanidots(:,2,i)=anidots(:,2,i)./(anidots(:,3,i)*depth_scale); % Y coords
    
    %     % Get degrees visual angle
    %     twodanidots(:,1,i)=tan(twodanidots(:,1,i)./50);
    %     twodanidots(:,2,i)=tan(twodanidots(:,2,i)./50);
    
    %     twodanidots(:,1,i)=tan(anidots(:,1,i)./anidots(:,3,i));
    %     twodanidots(:,2,i)=tan(anidots(:,2,i)./anidots(:,3,i));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% Plot and animate

M(num_frames)=struct('cdata',[],'colormap',[]);
dot_displacement=linspace(-25.4,25.4,num_frames);

for i=1:num_frames
    fig=figure;
    hold on;
    scatter(twodanidots(:,1,i),twodanidots(:,2,i),'.w');
    if pursuit==1
        scatter(dot_displacement(i),0,'r','filled');
    elseif fixation==1
        scatter(0,0,'r','filled');
    end
    set(gca,'pos', [0 0 1 1]);
    set(gca,'XLim',[-50 50],'YLim',[-35 35],'Visible','off');
    set(fig,'Position',[25 50 1778 1000]);
    set(gcf, 'menu', 'none', 'Color',[0 0 0]);
    
    drawnow;
    M(i)=getframe;
    
    close
end

if save_vid==1
    writerObj = VideoWriter(video_path,'mp4');
    writerObj.FrameRate = framerate;
    open(writerObj);
    for i=1:num_frames
        frame=M(i).cdata;
        writeVideo(writerObj,frame);
    end
    close (writerObj);
end

if plot_still==1
    fig2=figure;hold on;
    set(gca,'pos', [0 0 1 1]);
    set(gca,'XLim',[-50 50],'YLim',[-35 35],'Visible','off');
    set(fig2,'Position',[25 25 1778 1000]);
    set(gcf,'Color',[0 0 0]);
    grays=linspace(0.25,1,num_frames);
    
    for i=1:num_frames
        hold on;
%         scatter(twodanidots(:,1,i),twodanidots(:,2,i),[],'.w');
        scatter(twodanidots(:,1,i),twodanidots(:,2,i),5,[grays(i) grays(i) grays(i)],'filled');
    end
    
    scatter(0,0,'r','filled');
end

end



