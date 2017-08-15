%% Random Dot Kinematogram


dots.nDots = 100;                % number of dots
dots.color = [255,255,255];      % color of the dots
dots.size = 10;                   % size of dots (pixels)
dots.center = [0,0];           % center of the field of dots (x,y)
dots.apertureSize = [12,12];     % size of rectangular aperture [w,h] in degrees.

display.dist = 50;  %cm
display.width = 30; %cm

tmp = Screen('Resolution',0);
display.resolution = [tmp.width,tmp.height];


%% Convert degrees visual angle to pixels

pixpos.x = angle2pix(display,dots.x);
pixpos.y = angle2pix(display,dots.y);
%
% This generates pixel positions, but they're centered at [0,0].  The last
% step for this conversion is to add in the offset for the center of the
% screen:
%
pixpos.x = pixpos.x + display.resolution(1)/2;
pixpos.y = pixpos.y + display.resolution(2)/2;
%
% We can make a similar plot of the pixel positions:
figure(2)
clf
plot(pixpos.x,pixpos.y,'ko','MarkerFaceColor','b');
set(gca,'XLim',[0,display.resolution(1)]);
set(gca,'YLim',[0,display.resolution(2)]);
xlabel('X (pixels)');
ylabel('Y (pixels)');
axis equal

%% Draw dots

try
    display.skipChecks=1;
    display = OpenWindow(display);
    Screen('DrawDots',display.windowPtr,[pixpos.x;pixpos.y], dots.size, dots.color,[0,0],1);
    Screen('Flip',display.windowPtr);
    pause(2)
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');

%% Dots animation

dots.speed = 3;       %degrees/second
dots.duration = 5;    %seconds
dots.direction = 30;  %degrees (clockwise from straight up)

dx = dots.speed*sin(dots.direction*pi/180)/display.frameRate;
dy = -dots.speed*cos(dots.direction*pi/180)/display.frameRate;

nFrames = secs2frames(display,dots.duration);

% First we'll calculate the left, right top and bottom of the aperture (in
% degrees)
l = dots.center(1)-dots.apertureSize(1)/2;
r = dots.center(1)+dots.apertureSize(1)/2;
b = dots.center(2)-dots.apertureSize(2)/2;
t = dots.center(2)+dots.apertureSize(2)/2;

% New random starting positions
dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);

% Each dot will have a integer value 'life' which is how many frames the
% dot has been going.  The starting 'life' of each dot will be a random
% number between 0 and dots.lifetime-1 so that they don't all 'die' on the
% same frame:

dots.lifetime = 12;  %lifetime of each dot (frames)
dots.life =    ceil(rand(1,dots.nDots)*dots.lifetime);

try
    display = OpenWindow(display);
    for i=1:nFrames
        %convert from degrees to screen pixels
        pixpos.x = angle2pix(display,dots.x)+ display.resolution(1)/2;
        pixpos.y = angle2pix(display,dots.y)+ display.resolution(2)/2;

        Screen('DrawDots',display.windowPtr,[pixpos.x;pixpos.y], dots.size, dots.color,[0,0],1);
        %update the dot position
        dots.x = dots.x + dx;
        dots.y = dots.y + dy;

        %move the dots that are outside the aperture back one aperture
        %width.
        dots.x(dots.x<l) = dots.x(dots.x<l) + dots.apertureSize(1);
        dots.x(dots.x>r) = dots.x(dots.x>r) - dots.apertureSize(1);
        dots.y(dots.y<b) = dots.y(dots.y<b) + dots.apertureSize(2);
        dots.y(dots.y>t) = dots.y(dots.y>t) - dots.apertureSize(2);

        %increment the 'life' of each dot
        dots.life = dots.life+1;

        %find the 'dead' dots
        deadDots = mod(dots.life,dots.lifetime)==0;

        %replace the positions of the dead dots to a random location
        dots.x(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(1) + dots.center(1);
        dots.y(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(2) + dots.center(2);

        Screen('Flip',display.windowPtr);
    end
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');