function [] = plotBinaryMask(f,BW,colour,method,zimg)
% input  : f, the figure where the mask should be
%          BW, the mask for adding to the image
%          colour, the mask colour
    if nargin < 4
        method = 'boundary'; 
        zimg = [];
    end
    figure(f); hold on
    switch method
        case 'boundary'
            [labelBW,numObj] = bwlabel(BW);
            boundaries = bwboundaries(BW, 'noholes');
            for j = 1:numObj
                b = boundaries{j};
                plot(b(:,2),b(:,1),'r','linewidth',1.5,'Color',colour); %Plot boundary
%         
%                  ind = find(labelBW==j);
%                   [m,n] = ind2sub(size(BW), ind);
%                   text(mean(n),mean(m),['\color{white} ' num2str(j)], 'FontSize', 10,'fontweight','bold') %Plot number
            end
        case 'overlay'
            brights  = imdilate(BW,strel('disk',12)).*zimg;
            map      = BW;
            c        = cat(3, ones(size(zimg)),zeros(size(zimg)), zeros(size(zimg))); 
            c(:,:,1) = logical(c(:,:,1).*brights); 
            h = imshow(c);
            set(h, 'AlphaData', map*0.65,'interpolation','bilinear');
    end
end