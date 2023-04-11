function f = plotAllMask(img,smallM,largeM,flagS,flagL,contrast,range,pauseTime)
    if nargin < 7
        range = [1 size(img,3)];
        pauseTime = 0.1;
    end
    for i = range(1):range(2)
        f = figure; imshow(img(:,:,i),contrast);
        pause(pauseTime);
        if flagS == 1
            visual.plotBinaryMask(f,smallM(:,:,i),[0.25,0.5,0.75]);
        end
        if flagL == 1
            visual.plotBinaryMask(f,largeM(:,:,i),[0.75,0.5,0.25]);
        end
        pause(pauseTime);
    end
end