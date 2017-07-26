function [] = newpolartix(spokes,datahandle,axeshandle)

% Usage: [] = newpolartix(spokes,handle)

% Modifies number of angle tick intervals in polar plot according to number
% of "spokes" defined in function call. Function modified from Adam Danz's
% polarticks http://www.mathworks.com/matlabcentral/fileexchange/46087-polarticks-m
%
% Modified by Tyler Manning, July 2017

%   Inputs:
%   spokes = number of equally spaced ticks (radii) around the circumference starting at 0deg.
%            Must be an even integer.
%   handle = the polar plot figure handle (optional; default is gca)

if nargin < 3 || isempty(axeshandle)
    axeshandle = gca; 
end

if mod(spokes,2) ~= 0
    error ('Number of spokes needs to be an even integer');
end

% Find all lines in polar plot and keep radius line markers
h = findall(axeshandle,'type','line');
hinds = nan(10,1);
cnt = 1;
for i = 1:numel(h)
    % radius markers in polar plot have lots of vertices
    if numel(h(i).XData) > 20
        hinds(cnt) = i;
        cnt = cnt + 1;
    end
end
hinds = hinds(~isnan(hinds));
h(hinds) = [];
% Find handle associated with plotted data
h(ismember(h,datahandle)) = [];

delete (h)

% Find all text in plot and keep radius text markers
t = findall(axeshandle,'type','text');
tinds = nan(10,1);
cnt = 1;
for i=1:numel(t)
    % radius text markers are left aligned,
    if strcmp(t(i).HorizontalAlignment,'left')
        tinds(cnt) = i;
        cnt = cnt +1;
    end
end
tinds = tinds(~isnan(tinds));
t(tinds) = [];
delete (t)

% Add desired angle tick marks

% Plot spokes
th = (1 : spokes/2) * 2 * pi / spokes;
cst = cos(th);
snt = sin(th);
cs = [-cst; cst];
sn = [-snt; snt];
v = [get(axeshandle, 'XLim') get(axeshandle, 'YLim')];
rmax = v(2);
ls = get(axeshandle, 'GridLineStyle');
tc = [0.872 0.872 0.872];
line(rmax * cs, rmax * sn, 'LineStyle', ls, 'Color', tc,  'LineWidth', 1, ...
    'HandleVisibility', 'off', 'Parent', axeshandle);

% Add Text markers to spokes
rt = 1.1 * rmax;
degint = 360/spokes;
for i = 1 : length(th)
    t_hand1(i) = text(rt * cst(i), rt * snt(i), int2str(i * degint),...
        'HorizontalAlignment', 'center', ...
        'HandleVisibility', 'off', 'Parent', axeshandle);
    if i == length(th)
        loc = int2str(0);
    else
        loc = int2str(180 + i * degint);
    end
    t_hand2(i) = text(-rt * cst(i), -rt * snt(i), loc, 'HorizontalAlignment', 'center', ...
        'HandleVisibility', 'off', 'Parent', axeshandle);
end

% Set view to 2-D
view(axeshandle, 2);
% Set axis limits
axis(axeshandle, rmax * [-1, 1, -1.15, 1.15]);

end

% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.