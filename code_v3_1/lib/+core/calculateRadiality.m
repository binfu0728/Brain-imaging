function radiality = calculateRadiality(pil_small,img,Gx,Gy)
% calculate steepness and integrated gradient for each spot detected
% input  : pil_small, array of pixel indice for spots
%          img, img for calculating the radiality
%          Gx, gradient field in x direction
%          Gy, gradient field in y direction
% 
% output : steepness, ratio between local maximum in intensity field and pixel values 2-px away from the local maximum
%          integratedGrad, sum of pixel values 2-px away in gradient field 
% 
% author : Bin Fu, Univerisity of Cambridge, bf341@cam.ac.uk
    
    imsz = size(img);
    radiality = zeros(length(pil_small),2);

    for k = 1:length(pil_small)
        pil_t   = pil_small{k}; %tmpt holder
        [r0,mi] = max(img(pil_t)); %maximum value and its relative index in the current array
        mi      = pil_t(mi); %index on the image
        ind_r2  = radialityPixelInd(mi,imsz); %define region for calculating radiality
        
        % % calculate whether gradient vector converges at the centre
        % [r,c]   = ind2sub(imsz,mi);
        % [r2,c2] = ind2sub(imsz,ind_r2);
        % 
        % % fast weighted centroid
        % localmax = img(r,c);
        % d  = 0.02*localmax;
        % up = localmax-img(r-1,c)<d;
        % dw = localmax-img(r+1,c)<d;
        % le = localmax-img(r,c-1)<d;
        % ri = localmax-img(r,c+1)<d;
        % 
        % r = r - up*0.5 + dw*0.5;
        % c = c - le*0.5 + ri*0.5;
        % dmin = ((c-c2).*Gy(ind_r2) - (r-r2).*Gx(ind_r2)) ./ sqrt(Gx(ind_r2).^2+Gy(ind_r2).^2); %Perpendicular distance between real centre (max) and estimated centres based on the gradient of pixels at radius=2      
        
        g2   = sqrt(Gx(ind_r2).^2+Gy(ind_r2).^2); %gradient value 2 px away from the centre

        steepness = mean(img(ind_r2)./r0);
        integratedGrad = sum(g2);
        radiality(k,:) = [steepness,integratedGrad];
    end
end

function ind_r2 = radialityPixelInd(ind,imsz)
% this function return the pixel indice that are nth pixel away from the centre
    c = ind-imsz(1)*3:imsz(1):ind+imsz(1)*3;
    % ind_r1 = [c(3)-1:c(3)+1,c(4)-1,c(4)+1,c(5)-1:c(5)+1]; %pixel indice at radius=1
    ind_r2 = [c(2)-1:c(2)+1,c(3)-2,c(3)+2,c(4)-2,c(4)+2,c(5)-2,c(5)+2,c(6)-1:c(6)+1]; %pixel indice at radius=2
    % ind_r3 =[c(1)-2:c(1)+2,c(2)-3:imsz(2):c(6)-3,c(2)+3:imsz(2):c(6)+3,c(7)-2:c(7)+2]; %pixel indice at radius=3
end
