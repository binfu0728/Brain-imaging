function [] = Gifwrite(filename,f,i)
    frame = getframe(f);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if i == 1
      imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',0.1);
    else
      imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.1);
    end
end