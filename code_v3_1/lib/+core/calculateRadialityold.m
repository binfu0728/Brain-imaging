function radiality = calculateRadiality(pil_small,img,Gx,Gy,imsz)
% calculate relative and absolute gradient (they together are called radiality) for each oligomer detected
% input  : pil_small, array of pixel indice for oligomers
%          img, img for calculating the radiality
% 
% output : radiality, three column matrix for directions towards the centre, absolute gradient and relative gradient 
% 
% author : Bin Fu, Univerisity of Cambridge, bf341@cam.ac.uk
    
    radiality = zeros(length(pil_small),3); %ratio,direction,absolute value
    for k = 1:length(pil_small)
        pil_t   = pil_small{k}; %tmpt holder
        [r0,mi] = max(img(pil_t)); %maximum value and its relative index in the current array
        mi      = pil_t(mi); %index on the image
        ind_r2  = radialityPixelInd(mi,imsz); %define region for calculating radiality
        [r,c]   = ind2sub2d(imsz,mi);
        [r2,c2] = ind2sub2d(imsz,ind_r2);
        
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
        g2   = sqrt(Gx(ind_r2).^2+Gy(ind_r2).^2);

        radiality(k,:) = [sum(abs(dmin)<1),sum(g2),mean(img(ind_r2)./r0)];
    end
end

function ind_r2 = radialityPixelInd(ind,imsz)
    c = ind-imsz(1)*2:imsz(1):ind+imsz(1)*2;
    ind_r2  = [c(1)-1:c(1)+1,c(2)-2,c(2)+2,c(3)-2,c(3)+2,c(4)-2,c(4)+2,c(5)-1:c(5)+1]; %pixel indice at radius=2
end

function [row,col] = ind2sub2d(imsz,ind)
    row = mod(ind,imsz(1));
    col = (ind-row)/imsz(1) + 1;
end