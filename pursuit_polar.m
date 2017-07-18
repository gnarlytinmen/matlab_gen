function pursuit_polar(trial_data)

% Plots pursuit tuning in polar coordinates
% Usage: pursuit_polar(trial_data)

p = polar([trial_data.trial_dir' trial_data.trial_dir(1)]*(pi/180),[trial_data.FR_plot trial_data.FR_plot(1)],'k');

% h = polarticks(8, p);

title('Preferred Pursuit Direction');

end