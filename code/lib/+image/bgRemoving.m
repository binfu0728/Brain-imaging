function [img, bg] = bgRemoving(img, scale)
% Different from extractBg, this one estimate a single value for the background
% input  : img, 3D image stack 
%          scale, how much noise will be substracted
%          
% output : img, substracted image
%          bg, estimated background (single number)
    si            = 25;
    img           = double(img);
    [nY,nX,nImgs] = size(img);
    edgeMap       = zeros(nY,nX);

    for m = 1:nImgs
        edgeMap = edgeMap + double(img(:,:,m))./mean2(img(:,:,m));
    end
    bgReg = zeros(floor(nY/si),floor(nX/si));
    
    for m1 = 1:si:nY-si+1
        for m2 = 1:si:nX-si+1
            ref(1:si,1:si) = mean2(edgeMap(m1:m1+si-1,m2:m2+si-1));
            bgReg((m1-1)/si+1,(m2-1)/si+1) = immse(double(edgeMap(m1:m1+si-1,m2:m2+si-1)),ref);
        end
    end
    [y,x] = find(bgReg == min(min(bgReg)));
    locy = y; locx = x;
    
%     % visualization
%     f1 = figure;
%     image(edgeMap); title('edge map'); colormap gray
%     y = y.*si-round(si/2);
%     x = x.*si-round(si/2);
%     hold on
%     viscircles([x,y],round(si/2))

    bg = zeros(nImgs,1);
    for m = 1:nImgs
        bg(m)      = mean2(img(si*locy-si+1:si*locy,si*locx-si+1:si*locx,m));
        img(:,:,m) = img(:,:,m) - scale * bg(m);
        img(:,:,m) = max(img(:,:,m),0);
    end
end