function f = plotAll(img,BW,colour,method)
% input  : img, original image where the mask should be on
%          BW, the mask for adding to the image
%          method, 'normal','contrast'
% 
% output : f, final figure

    if nargin < 4
        method = 'normal';
    end
    
    f = figure;
    switch method
        case 'normal'
            imshow(img,[]);
        case 'contrast'
            imshow(imadjust(uint16(img)));
        otherwise
            error('not supported plotting method');
    end
    visual.plotBinaryMask(f,BW,colour);
end