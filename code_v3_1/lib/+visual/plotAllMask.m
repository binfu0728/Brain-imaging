function [f,f1] = plotAllMask(img,smallM,largeM,flagS,flagL,contrast,pauseTime,range)
    if nargin < 7
        range = [1 size(img,3)];
        pauseTime = 0.1;
    elseif nargin < 8
        range = [1 size(img,3)];
    end
    
    for i = range(1):range(2)
        f1 = figure; imshow(img(:,:,i),contrast);%impixelinfo
        f  = figure; imshow(img(:,:,i),contrast);
        pause(pauseTime);
        if flagS == 1
            visual.plotBinaryMask(f,smallM(:,:,i),[0.92,0.5,0.38]);
        end
        if flagL == 1
            visual.plotBinaryMask(f,largeM(:,:,i),[0.23,0.5,0.45]);
        end
        pause(pauseTime);
        load.Gifwrite('cell1.gif',f1,i-range(1)+1,0.2);
        load.Gifwrite('cell1_bw.gif',f,i-range(1)+1,0.2);
    end
end