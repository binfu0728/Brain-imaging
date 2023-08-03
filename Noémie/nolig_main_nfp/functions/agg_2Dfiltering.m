function [On_edge,sub_agg_id,filt_agg,bwfilt_agg] = agg_2Dfiltering(sub_agg, sub_agg_id, edgematch, sub_og_area_nt,pix_area)
% filtering of 2D sub aggregates for smoother shape 

visual_agg = sub_agg;
% padding for filtering
if sum(any(edgematch)) > 0
    sub_agg_id = sub_agg_id + "_edge";
    On_edge = true;
    padding = 'replicate';

    % padding according to [pre dim1, post dim1, pre dim2, post dim2], add blank row or col to sides that are not on edge
    if edgematch(1) == 0                                      
        visual_agg = padarray(sub_agg,[1 0],0,"pre"); % pad top row with 0
    end
    % pad bottom row
    if edgematch(2) == 0                 
        visual_agg = padarray(visual_agg,[1 0],0,"post"); % 0 padding
    end
    % pad left col
    if edgematch(3) == 0                                 
        visual_agg = padarray(visual_agg,[0 1],0,"pre"); % 0 padding
    end
    % pad right col
    if edgematch(4) == 0                                   
        visual_agg = padarray(visual_agg,[0 1],0,"post"); % 0 padding
    end

else
    On_edge = false;
    padding = 0;
end

% filter to get smooth aggregate
h = fspecial('disk', 1);
filt_agg = imfilter(visual_agg,h, padding ,"full","conv");

% apply threshold and get area similar to original unprocessed agg (before opt thresh application in aggregage_extraction)
bwfilt_agg = logical(filt_agg);

filt_area = sum(bwfilt_agg,"all")*pix_area; % filtered aggregate area
area_scaleFactor = sub_og_area_nt/filt_area; % factor to multiply with final volume to get approx og area

if area_scaleFactor < 1
    perc_thresh = 1-area_scaleFactor; % percentage of aggregate voxels to delete to get approx og area
    numdelPix = round(perc_thresh*sum(bwfilt_agg,"all")); % number of pixels to delete 
    sorted_pixVals = sort(nonzeros(filt_agg)); % sorted pixel values to find threshold that deletes the right number of pixels
    thresh = sorted_pixVals(numdelPix,:); 
    filt_agg(filt_agg < thresh) = 0; % apply thresh
    bwfilt_agg = logical(filt_agg);
    
    % crop matrix to current bounding box
    coco = bwconncomp(bwfilt_agg,8);
    % for now, keep only biggest component :)
    if coco.NumObjects > 1
        props = regionprops(coco, 'Area');
        areas = [props.Area];
        biggestcomp = find((max(areas))==areas);
        
        bwlab = bwlabel(bwfilt_agg,8);
        bwfilt_agg = zeros(size(bwlab));
        bwfilt_agg(bwlab == biggestcomp) = 1;
        filt_agg(bwfilt_agg == 0) = 0;
    end
    coco2 = bwconncomp(bwfilt_agg,8);
    propsc = regionprops(coco2,'BoundingBox');
    bbox = propsc.BoundingBox;
    boundbox = [(bbox(:,1:2) + 0.5), (bbox(:,3:4)-1)];
    filt_agg = imcrop(filt_agg, boundbox);
    bwfilt_agg = logical(filt_agg);
end

end