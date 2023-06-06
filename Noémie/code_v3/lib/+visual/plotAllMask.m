function f = plotAllMask(img,smallM,largeM,flagS,flagL,contrast,pauseTime,range)
    if nargin < 7
        range = [1 size(img,3)];
        pauseTime = 0.1;
    elseif nargin < 8
        range = [1 size(img,3)];
    end
    
    for i = range(1):range(2)
        f = figure; imshow(img(:,:,i),contrast);
        pause(pauseTime);
        if flagS == 1
            visual.plotBinaryMask(f,smallM(:,:,i),[0.92,0.5,0.38]); % why this range?
        end
        if flagL == 1
            visual.plotBinaryMask(f,largeM(:,:,i),[0.23,0.5,0.45]);
        end
        pause(pauseTime);
    end
end