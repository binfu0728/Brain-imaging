function img = multiDoG(img,s)
% input  : img, original image
%          s, config
% 
% output : img, after-processed image

    dim = s.dim;
    k1  = s.k1_dog; %low-end cut-off frequency
    k2  = s.k2_dog; %high-end cut-off frequency
%     if dim ~= length(size(img))
%         error('wrong dimension');
%     end

    switch dim
        case 2 %2D
            if k1 ~= 0 
                img = imgaussfilt(img,k1) - imgaussfilt(img,k2);
            else
                img = img - imgaussfilt(img,k2);
            end
        case 3 %3D
            if k1 ~= 0 
                img = imgaussfilt3(img,k1) - imgaussfilt3(img,k2);
            else
                img = img - imgaussfilt3(img,k2);
            end
        otherwise
            error('not supported dimension');
    end
end