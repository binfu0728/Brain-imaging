function img = loadImage(filename,mode,t,z,c,ch) 
% input type : none
% output type: double
    if nargin<3
        t = nan;z = nan; c = nan; ch = nan;
    end
    
    img = double(Tifread([filename,'.tif']));
    switch mode
        case 'max'  %for LB/LN
            tmpt = reshape(img,size(img,1),size(img,2),z,t*c);
            tmpt = tmpt(:,:,:,ch:c:t*c);
            tmpt = mean(tmpt,4);
            img  = mean(squeeze(max(tmpt,[],3)),3);     
        case 'mean' %for oligomer
            tmpt = reshape(img,size(img,1),size(img,2),z,t*c);
            tmpt = tmpt(:,:,:,ch:c:t*c);
            img  = mean(squeeze(tmpt(:,:,1,:)),3);
        otherwise
            error('wrong');    
    end
end