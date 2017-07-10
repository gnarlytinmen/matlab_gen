function [M]=sinewave_grating(theta,cycle_size,frames,size,contrast,frames2,theta2)

% Generates drifiting gabor patches (single grating or plaid)
%
% Usage: [M]=sinewave_grating(theta,cycle_size,frames,size,contrast,theta2)
%   - theta: 1st grating angle
%   - cycle_size: size of one grating cycle in cm
%   - frames: number of frames per cycle (tf = framerate/frames per cycle)
%   - size: size of image square in pixels
%   - contrast: % Michelson contrast
%   - theta2: 2nd grating angle

% For plaids, define theta2. For gratings, omit it. 

% Grating velocity=cycle_size*(1/frames)*60fps [in cm/s]

% Generally want sigma to be around 1/8 of image size

%%%%%%%%%%%%%%%%% General properties %%%%%%%%%%%%%%%%%%%%
im_size=size;       % define height/width in pixels
trim=0.005;         % gaussian cutoff
f=frames;           % number of frames per cycle (tf = framerate/frames per cycle)

if nargin>5
    f2=frames2;           % frames per cycle for grating 2 (must be integer multiple of f)
    
%     if mod(f2,f)~=0
%         error('Number of frames in second grating must be integer multiple of the first.');
%     end
end

res=get(0,'screensize');       % get screensize in pixels
horiz=res(3);
vert=res(4);
set(0,'units','centimeters');
res_cm=get(0,'screensize');    % get screensize in cm
horiz_cm=res_cm(3);
screenres=horiz/horiz_cm;     % get screen resolution (pixels/cm)

lambda=round(cycle_size*screenres);    % convert cycle size in cm to closest integer #pixels

set(0,'units','pixels');

% 60fps matches refresh rate of most LCD monitors
% About 1.13sec lag (non playback) time for movie command execution
% Monitor resolution set at 1920x1080 

%%%%%%%%%%%%%%%%% Grating properties %%%%%%%%%%%%%%%%%%%%
num_cycles=(im_size/lambda)*2*pi;      % define number of cycles in stim
theta_rad=(theta/360)*2*pi;      % grating angle (clockwise,0deg at right)
c=contrast/100;      % Define contrast percentage (=[Imax-Imin]/[Imax + Imin] for Ibackground=0.5)

% Spatial frequency depends on distance from screen as well as pixels per
% cycle and pixels per cm; need to take inverse tangent of cycle size in cm
% over distance from monitor in cm to obtain degrees per cycle. 

% Spatial frequency is then reciprocal of the result.


%% Sinewave Grating
x=1:im_size;        
x0=(x/im_size)-0.5;         %make linear ramp [-0.5,0.5] spanning image
[xm,ym]=meshgrid(x0,x0);

xt=xm*cos(theta_rad);       %rotate x and y components of linear ramp by defined angle
yt=ym*sin(theta_rad);
xyt=xt-yt;                  %combine x and y components into 2d map
xyf=xyt*num_cycles;         %scale ramp according to number of cycles completed (larger range = larger number of completed cycles)

drifting=struct;

for i=1:f            % Make grating animation frames
    drifting(i).grating=c*sin(xyf-(2*pi*i)/f);       % offset grating by (2*pi*i)/f for each frame
end

if nargin>5;
    theta2_rad=(theta2/360)*2*pi;
    
    xt2=xm*cos(theta2_rad);
    yt2=ym*sin(theta2_rad);
    xyt2=xt2-yt2;
    xyf2=xyt2*num_cycles;
    
    drifting2=struct;
    
    if f2==f
        for i=1:f           % Make grating animation frames
            drifting2(i).grating=c*sin(xyf2-(2*pi*i)/(f))+drifting(i).grating;
            
            % uncomment for "unikinetic" plaid
            %drifting(i).grating=c*sin(xyf2)+drifting(i).grating;
        end
    elseif f2~=f             % For type 2 plaids and unikinetic (f2=1)
        fr_ratio=f2/f;
        
%         for i=0:f-1
%             for j=1:fr_ratio
%                 drifting2(fr_ratio*i+j).grating=drifting(i+1).grating;
%             end
%         end
        for i=1:f           % Make grating animation frames
%             drifting2(i).grating=c*sin(xyf2-(2*pi*i)/(1/fr_ratio))+drifting2(i).grating;
            drifting2(i).grating=c*sin(xyf2-(2*pi*i)/(1/fr_ratio))+drifting(i).grating;
        end
    end
end

%% Gaussian mask
s=1/7.8;        % define size of gaussian aperture (can adjust)
gauss=exp(-(((xm.^2)+(ym.^2))./(2* s^2)));
gauss(gauss < trim) = 0;        % zero grating at far gaussian tails

%% plot and animate

M(f)=struct('cdata',[],'colormap',[]);

fig=figure(1);
set(fig,'Position',[(horiz-size)/2 10+(vert-size)/2 size size]);
colormap gray(256);   % set to greyscale and define resolution
axis square; % fix aspect ratio to image size and turn off axes
set(gca,'pos', [0 0 1 1]);               
set(gcf, 'menu', 'none', 'Color',[.5 .5 .5]); % turn off menu, grey out background

if nargin>5
    if f2==f
        for i=1:numel(drifting2)             % Make gabor animation frames
            drifting2(i).gabor=gauss.*drifting2(i).grating;
            imshow(drifting2(i).gabor,[-1 1]); axis off;
            
            drawnow;
            M(i)=getframe;
        end
    else
        for i=1:numel(drifting2)             % Make gabor animation frames
            drifting2(i).gabor=gauss.*drifting2(i).grating;
            imshow(drifting2(i).gabor,[-1 1]); axis off;
            
            drawnow;
            M(i)=getframe;
        end
    end
elseif nargin==5
    for i=1:numel(drifting)                  % Make gabor animation frames
        drifting(i).gabor=gauss.*drifting(i).grating;
        imshow(drifting(i).gabor,[-1 1]); axis off;
        
        drawnow;
        M(i)=getframe;
    end
end

end