function img = multiLoG(img,s)
% input  : img, original image
%          s, config
% 
% output : img, after-processed image

    dim   = s.dim;
    sigma = s.k_log;
    if dim ~= length(sigma)
        error('wrong dimension');
    end
    h   = image.rickerWavelet(sigma);
    img = imfilter(img,h,'replicate','conv','same');  
end