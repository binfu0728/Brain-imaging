function [esti_inten,esti_bg] = fastIntensityEstimation(img,centroids) 
    imsz       = size(img); 
    ind        = core.sub2ind2d(imsz,centroids(:,2),centroids(:,1));
    esti_inten = zeros(length(ind),1); %estimated sum intensity
    esti_bg    = zeros(length(ind),1); %estimated background
%     cnr        = zeros(length(ind),1); %pure signal / var(background)
%     test       = false(size(smallM));  %test for checking whether pixel dilation works
    for k = 1:length(ind)
        [pin,pout]    = core.pixelDilation(ind(k),imsz); %define region for calculating intensity and background
        esti_bg(k)    = mean(img(pout));
        esti_inten(k) = 1.05*sum(img(pin)-esti_bg(k)); %1.05 is a calibration factor acquired from the simluation for a better intensity estimation
%         cnr(k)        = (max(img(pin)) - esti_bg(k))/std(img(pout));
%         test(pout)    = true;
    end
end