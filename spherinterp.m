function [FR_interps,sampAzVec,sampElVec]=spherinterp(azimuths,elevations,frs,res)

az=azimuths*pi/180;
el=elevations*pi/180;
numdirs=numel(azimuths);
az=mod(az,2*pi); % Convert any azimuths from -pi:pi to 0:2pi

% Copy polar (up/down) headings along all azimuth directions. 
maxElAzVec = linspace(0.25*pi,2*pi,8)';     % arbitrary number of azimuth samples to map polar heading to
[~,highElIdx] = max(el);               % find index of upward pole
[~,lowElIdx] = min(el);                % find index of downward pole
wrapElAzIdxs = [maxElAzVec repmat([pi/2 highElIdx],size(maxElAzVec))];  % upward heading
wrapElAzIdxs = cat(1, wrapElAzIdxs, [maxElAzVec repmat([-pi/2 lowElIdx],size(maxElAzVec))]); % stick on downward headings

% Get a new set of Az-El combos (+indices) with additional points

% [az el] - original data
% wrapPhiThIdxs(:,1:2) - stick all converted polar points at end of matrix
%     too

global_heads = cat(1, [az el], wrapElAzIdxs(:,1:2));
globalhead_inds = cat(1, (1:numdirs)', wrapElAzIdxs(:,3));

% Interpolate using 
DT = DelaunayTri(global_heads(:,1),global_heads(:,2));      % Triangulate points
TSinterp = TriScatteredInterp(DT, frs(globalhead_inds));    % Interpolate FR vals based on triangulation

% Map onto -pi:pi azimuth convention
sampAzVec = [pi:res:2*pi-res 0:res:pi];         % Generate spherical grid to map interps to
sampElVec = -pi/2:res:pi/2;    
[sampAzMat, sampElMat] = meshgrid(sampAzVec, sampElVec);
FR_interps = TSinterp(sampAzMat, sampElMat);                % Map interpolations

end