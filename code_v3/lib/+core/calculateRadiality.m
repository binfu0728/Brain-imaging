function radiality = calculateRadiality(pil_small,img,imsz)
    % calculate image gradient
    gx = zeros(size(img)); gx(:,1:end-1) = diff(img,1,2); %x gradient (right to left)
    gy = zeros(size(img)); gy(1:end-1,:) = diff(img,1,1); %y gradient (bottom to top)
    
    radiality  = zeros(length(pil_small),2); %mag diff,central pos
    for k = 1:length(pil_small)
        pil_t          = pil_small{k}; %tmpt holder
        [r0,mi]        = max(img(pil_t)); %maximum value and its relative index in the current array
        mi             = pil_t(mi); %index on the image
        ind_r2         = radialityPixelInd(mi,imsz); %define region for calculating radiality
        [r,c]          = core.ind2sub2d(imsz,mi);
        [r2,c2]        = core.ind2sub2d(imsz,ind_r2);
        
        %Perpendicular distance between real centre (max) and estimated centres based on the gradient of pixels at radius=2
        dmin           = ((c-c2).*gy(ind_r2) - (r-r2).*gx(ind_r2)) ./ sqrt(gx(ind_r2).^2+gy(ind_r2).^2); 
        %Magnitude of gradient
        gmag           = sum(r0-img(ind_r2))/r0/length(ind_r2);
        radiality(k,:) = [gmag,sum(dmin<1)];
    end
end

function ind_r2 = radialityPixelInd(ind,imsz)
    c = ind-imsz(2)*2:imsz(2):ind+imsz(2)*2;
    ind_r2  = [c(1)-1:c(1)+1,c(2)-2,c(2)+2,c(3)-2,c(3)+2,c(4)-2,c(4)+2,c(5)-1:c(5)+1]; %pixel indice at radius=2
end