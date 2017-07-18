function [pref_dirs]=vector_avger(dat_tab3)
% Calculate weighted average heading vector for each pursuit condition
% (alternate heading preference shift analysis)                

data=dat_tab3.fr_plot_HP;
[ro,co]=size(data);

% Reorganizer arranges trials into Fixation (1), L(2,3,4), and R(5,6,7) conditions (NP,SiP,StP)
reorg=[1 3 5 7 2 4 6];
reorgdata=zeros(ro,co);
for j=1:7
    reorgdata(j,:)=data(reorg(j),:);
end

azimuths=unique(dat_tab3.trial_az)*(pi/180);
num_az=numel(azimuths);

backfor=0;
if median(azimuths)>=pi
    backfor=1;
end

xcomp=cos(azimuths);
ycomp=sin(azimuths);

xmean=(reorgdata*xcomp);
ymean=(reorgdata*ycomp);

pref_dirs=atan(ymean./xmean)*(180/pi)+180*backfor;
end