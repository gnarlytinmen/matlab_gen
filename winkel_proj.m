[X,Y,Z]=sphere(16);  % Generate spherical surface approiximation with 16 points per latitude/longitude line


% Winkel Tripel projection

x=@(lam,stand_par,phi)0.5*(lam*cos(stand_par)+(2*cos(phi)*sin(lam/2))/(acos(cos(phi)*cos(lam/2))));
y=@(lam,phi)0.5*(phi+sin(phi)/(acos(cos(phi)*cos(lam/2))));

stand_par=acos(2/pi);