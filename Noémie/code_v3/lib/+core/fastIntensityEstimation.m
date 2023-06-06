function [esti_inten,esti_bg] = fastIntensityEstimation(img,centroids) 
    imsz       = size(img); 
    ind        = core.sub2ind2d(imsz,centroids(:,2),centroids(:,1)); % converting coordinates to linear indices in 2d
    esti_inten = zeros(length(ind),1); %estimated sum intensity
    esti_bg    = zeros(length(ind),1); %estimated background
%     cnr        = zeros(length(ind),1); %pure signal / var(background)
%     test       = false(size(smallM));  %test for checking whether pixel dilation works
    for k = 1:length(ind)
        [pin,pout]    = intensityPixelInd(ind(k),imsz); %define region for calculating intensity and background
        esti_bg(k)    = mean(img(pout));
        esti_inten(k) = 1.05*sum(img(pin)-esti_bg(k)); %1.05 is a calibration factor acquired from the simluation for a better intensity estimation
%         cnr(k)        = (max(img(pin)) - esti_bg(k))/std(img(pout));
%         test(pout)    = true;
    end
end

function [ind_in,ind_out] = intensityPixelInd(ind,imsz)
    c       = ind-imsz(2)*6:imsz(2):ind+imsz(2)*6; %centre pixel index each column
    ind_in  = [c(3):c(3)+1,c(4)-1:c(4)+2,c(5)-2:c(5)+3,c(6)-3:c(6)+4,c(7)-4:c(7)+5,c(8)-4:c(8)+5,c(9)-3:c(9)+4,c(10)-2:c(10)+3,...
               c(11)-1:c(11)+2,c(12):c(12)+1]; %In pixel indice for radius=5
    ind_out = [c(2),c(2)+1,c(3)-1,c(3)+2,c(4)-2,c(4)+3,c(5)-3,c(5)+4,c(6)-4,c(6)+5,c(7)-5,c(7)+6,c(8)-5,c(8)+6,c(9)-4,c(9)+5,c(10)-3,c(10)+4,...
               c(11)-2,c(11)+3,c(12)-1,c(12)+2,c(13),c(13)+1]; %Out pixel indice for radius=5
end