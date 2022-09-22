function [] = Gifwrite(filename,f,i,time)
    if nargin<4
        time = 0.1;
    end
    frame = getframe(f);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if i == 1
      imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',time);
    else
      imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',time);
    end
end