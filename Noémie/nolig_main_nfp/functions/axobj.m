function ax = axobj(f,xx,yy,zz,k)
% creates axes object for 3D scatter plotting with the right properties

ax = axes(f);
ax.Box = "on";
ax.BoxStyle = 'back';

ax.XLim = [0, ceil(max(xx))];
ax.XLabel.String = 'x (um)';  
ax.XGrid = 'off';

ax.YLim = [0, ceil(max(yy))];
ax.YLabel.String = 'y (um)';
ax.YGrid = 'off';

ax.ZLim = [0, ceil(max(zz))];
ax.ZLabel.String = 'z (um)';
ax.ZDir = 'normal';
ax.ZGrid = 'on';

ax.DataAspectRatio = [1 1 1];
ax.Title.String = "Aggregate "+ k;
ax.Projection = "orthographic";

% set view according to agg dimensions
if max(yy) < max(xx)
    ax.XTickLabelRotation = 40;        
    ax.YTickLabelRotation = -12;
    ax.View = [25, 20];
    % adapt tick labeling 
    if max(yy) > 3.5 || max(yy)/max(xx) < 0.3
        ax.YTick = [linspace(0,ceil(max(yy)),(ceil(max(yy))+1))];
    else
        ax.YTick = [linspace(0,ceil(max(yy)),(2*ceil(max(yy))+1))];
    end
    if max(xx) > 10
        ax.XTick = [linspace(0,ceil(max(xx)),(ceil(max(xx))+1))];
        ax.ZTick = [linspace(0,ceil(max(zz)), (ceil(max(zz))+1))];
    else
        ax.XTick = [linspace(0,ceil(max(xx)),(2*ceil(max(xx))+1))];
        ax.ZTick = [linspace(0,ceil(max(zz)), (2*ceil(max(zz))+1))];
    end

else
    ax.XTickLabelRotation = -12;        
    ax.YTickLabelRotation = 40;
    ax.View = [115, 20];

    if max(xx) > 3.5 | max(xx)/max(yy) < 0.3
        ax.XTick = [linspace(0,ceil(max(xx)),(ceil(max(xx))+1))];
    else
        ax.XTick = [linspace(0,ceil(max(xx)),(2*ceil(max(xx))+1))];
    end
    if max(yy) > 10
        ax.YTick = [linspace(0,ceil(max(yy)),(ceil(max(yy))+1))];
        ax.ZTick = [linspace(0,ceil(max(zz)), (ceil(max(zz))+1))];
    else
        ax.YTick = [linspace(0,ceil(max(yy)),(2*ceil(max(yy))+1))];
        ax.ZTick = [linspace(0,ceil(max(zz)), (2*ceil(max(zz))+1))];
    end
end


end