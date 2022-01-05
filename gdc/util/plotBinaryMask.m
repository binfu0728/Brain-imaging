function [] = plotBinaryMask(BW,img)
    figure;
    imshow(img,[]);

    figure;
    imshow(img,[]);
    hold on
    [labelBW,numObj] = bwlabel(BW);
    boundaries = bwboundaries(BW, 'noholes');

    for j = 1:numObj
        b = boundaries{j};
        plot(b(:,2),b(:,1),'r','linewidth',1.5); %Plot boundary

        ind = find(labelBW==j);
        [m,n] = ind2sub(size(BW), ind);
%         plot(out(j,2),out(j,1),'rx') %Plot centre
        text(mean(n)+10,mean(m)+10,['\color{white} ' num2str(j)], 'FontSize', 10,'fontweight','bold') %Plot number
    end
end