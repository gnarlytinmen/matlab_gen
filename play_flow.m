function play_flow(M,num_reps)

% Play sinewave grating/plaid animation built by sinewave_grating
%
% Usage: []=play_grating(num_reps)

if nargin==1
    num_reps=10;
end

close all
%res=get(0,'screensize');       % get screensize in pixels
% [vert,width,~]=size(M(1).cdata);

fig=figure;
set(gca,'XLim',[-50 50],'YLim',[-35 35],'Visible','off');
set(gca,'pos', [0 0 1 1]); 
set(fig,'Position',[25 50 1778 1000]);
set(gcf, 'menu', 'none', 'Color',[0 0 0]);

movie(M,num_reps,24);



end
