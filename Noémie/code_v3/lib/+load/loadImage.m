function img = loadImage(filename,s) 
% input type : none
% output type: double
    img = double(load.Tifread(filename));

    width   = s.width;
    height  = s.height;
    frames  = s.frames;
    slices  = s.slices;
    colour  = s.colour;
    hyper   = s.hyper;
%     channel = s.channel;
%     mode    = s.imgLoad;
    
    if (size(img,3) ~= frames*slices*colour)
        error('wrong config');
    end
    
    zidx = strfind(hyper,'z');
    tidx = strfind(hyper,'t');
    cidx = strfind(hyper,'c');

    multiD      = [zidx,tidx,cidx];
    multiD_para = [slices,frames,colour];
    [~,idx]     = sort(multiD,'ascend');
    multiD_para = multiD_para(idx);
    multiD_para = [height,width,multiD_para];
    
    img = reshape(img,multiD_para);
    img = permute(img,[1 2 zidx tidx cidx]); %base is xyztc
%     img = img(:,:,:,:,channel);

%     switch mode
%         case 'max'  %for LB/LN
%             img = max(mean(img,4),[],3);     
%         case 'mean' %for oligomer
%             img = mean(squeeze(img(:,:,1,:)),3); 
%     otherwise
%         error('wrong');
%     end
end