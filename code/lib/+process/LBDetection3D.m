function BW = LBDetection3D(img,s,r)
% detect LB in 3D manner, r for if the max intensity of a LB is not 65535
    s.dim    = 2;
    s.intens = 0.05*65535*r; 
    img_mip = max(img,[],3);
    BW_mip  = process.LBDetection2D(img_mip,s);
%     f1      = figure;
%     imshow(img_mip,[]);
%     visual.plotBinaryMask(f1,BW_mip,[0.9290 0.6940 0.1250]);

    s.dim      = 3;
    s.ostu_num = 2;
    img1       = image.multiDoG(img,s);
    img1       = max(img1,0);
    BW         = image.threshold(img1,s);
    for j = 1:size(BW,3)
        s.intens  = s.intens_ratio*mean2(img(:,:,j));
        BW(:,:,j) = image.BWFilter(BW(:,:,j),img(:,:,j),s);
        BW(:,:,j) = imfill(BW(:,:,j),'holes');
        BW(:,:,j) = process.findCoincidence(BW_mip,BW(:,:,j),2);
    end
end