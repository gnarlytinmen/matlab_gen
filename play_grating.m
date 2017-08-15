function play_grating(M,num_reps)

% Play sinewave grating/plaid animation built by sinewave_grating
%
% Usage: []=play_grating(num_reps)

if nargin==1
    num_reps=10;
end

res=get(0,'screensize');       % get screensize in pixels
horiz=res(3);
vert=res(4);
size=length(M(1).cdata);

figure;
set(gcf,'Position',[(horiz-size)/2 10+(vert-size)/2 size size]);
colormap gray(256);   % set to greyscale and define resolution
axis square; % fix aspect ratio to image size and turn off axes
set(gca,'pos', [0 0 1 1]);               
set(gcf,'menu','none','Color',[.5 .5 .5]); % turn off menu, grey out background
    
movie(M,num_reps,60);

end
