function radiality = calculateRadiality(pil_small,img,Gx,Gy,imsz)
    
    radiality = zeros(length(pil_small),3); %ratio,direction,absolute value
    for k = 1:length(pil_small)
        pil_t   = pil_small{k}; %tmpt holder
        [r0,mi] = max(img(pil_t)); %maximum value and its relative index in the current array
        mi      = pil_t(mi); %index on the image
        ind_r2  = radialityPixelInd(mi,imsz); %define region for calculating radiality
        [r,c]   = core.ind2sub2d(imsz,mi);
        [r2,c2] = core.ind2sub2d(imsz,ind_r2);
        
        %indice at radius = 5
        rd = 5;
        r5 = [r-1,r,r+1,r-rd,r-rd,r-rd,r+rd,r+rd,r+rd,r-1,r,r+1];
        c5 = [c-rd,c-rd,c-rd,c-1,c,c+1,c-1,c,c+1,c+rd,c+rd,c+rd];
        ind_r5 = sub2ind2d(imsz,r5,c5);

        if r<10 || r>imsz(1)-9 || c<10 || c>imsz(1)-9
            continue;
        end
        
        % fast weighted centroid
        localmax = img(r,c);
        d  = 0.02*localmax;
        up = localmax-img(r-1,c)<d;
        dw = localmax-img(r+1,c)<d;
        le = localmax-img(r,c-1)<d;
        ri = localmax-img(r,c+1)<d;

        r = r - up*0.5 + dw*0.5;
        c = c - le*0.5 + ri*0.5;

        %Perpendicular distance between real centre (max) and estimated centres based on the gradient of pixels at radius=2
        dmin = ((c-c2).*Gy(ind_r2) - (r-r2).*Gx(ind_r2)) ./ sqrt(Gx(ind_r2).^2+Gy(ind_r2).^2); 
                
        g2 = sqrt(Gx(ind_r2).^2+Gy(ind_r2).^2); g5 = sqrt(Gx(ind_r5).^2+Gy(ind_r5).^2);

        radiality(k,:) = [mean(g2)/mean(g5),sum(abs(dmin)<1),mean(g2)];
    end
end

function ind_r2 = radialityPixelInd(ind,imsz)
    c = ind-imsz(1)*2:imsz(1):ind+imsz(1)*2;
    ind_r2  = [c(1)-1:c(1)+1,c(2)-2,c(2)+2,c(3)-2,c(3)+2,c(4)-2,c(4)+2,c(5)-1:c(5)+1]; %pixel indice at radius=2
end

function ind = sub2ind2d(size,row,col)
    ind = (col-1).*size(2) + row;
end