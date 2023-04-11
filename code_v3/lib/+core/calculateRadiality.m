function radiality = calculateRadiality(pil_small,img,imsz)
    radiality = zeros(length(pil_small),1);
    for k = 1:length(pil_small)
        pil_t        = pil_small{k}; %tmpt holder
        pvs          = img(pil_t); %pixel values
        [r0,mi]      = max(pvs); %maximum value and its relative index in the current array
        mi           = pil_t(mi); %absolution index on the image
        [~,pout,pr2] = core.pixelDilation(mi,imsz); %define region for calculating radiality
        esti_bg      = min(img(pout));
        radiality(k) = sum(1 - img(pr2)./r0);
    end
end