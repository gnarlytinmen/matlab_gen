function clipmargins(ax_handle,axes_on)
% Removes whitespace from around axes in figure

if ~axes_on
    ax = ax_handle;
    outerpos = ax.OuterPosition;
    left = outerpos(1);
    bottom = outerpos(2);
    ax_width = outerpos(3);
    ax_height = outerpos(4);
    ax.Position = [left bottom ax_width ax_height];
else
    ax = gca;
    outerpos = ax.OuterPosition;
    ti = ax.TightInset;
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];
end

end