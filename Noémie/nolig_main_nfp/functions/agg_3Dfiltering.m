function [filt_agg, bwfilt_agg] = agg_3Dfiltering(agg, newagg, zedge, height, width, depth, newdepth, newvoxVol, og_fulldepth, og_vol_nt)
% filtering of 3D aggregates for smoother shape and surface

if zedge == 1
    % add blank slices in each dimension except on z edge
    blank_zslice = zeros([height, width]);
    blank_xslice = zeros([(height+2), 1, (newdepth+1)]);
    blank_yslice = zeros([1, width, (newdepth+1)]);

    % get which slice is on edge - gives 1 if its the bottom slice
    bottom = sum(agg(:,:,1), 'all') > sum(agg(:,:,depth),'all');

    % add blank z slice to z edges that are not cut
    if depth == og_fulldepth % depth of original non cropped image (before aggregate extraction) - agg is cut on top and bottom slices
        visual_agg = newagg;
        blank_xslice = zeros([(height+2), 1, (newdepth)]);
        blank_yslice = zeros([1, width, (newdepth)]);
    elseif bottom == 1 % agg is cut at bottom slice
        visual_agg = cat(3, newagg,blank_zslice);
    else % agg is cut at top slice
        visual_agg = cat(3,blank_zslice, newagg);
    end
    
    visual_agg = cat(1, blank_yslice, visual_agg, blank_yslice);
    visual_agg = cat(2, blank_xslice, visual_agg, blank_xslice);

    padding = 'replicate';

elseif zedge == 0

    visual_agg = newagg;
    padding = 0;

end


% filter to get smooth aggregate
h = fspecial3('ellipsoid',[4,3,3]);
filt_agg = imfilter(visual_agg,h, padding ,"full","conv");
se = strel('sphere',4);
filt_agg = imclose(filt_agg,se);


% apply threshold and get volume similar to original unprocessed agg (before otsu thresh application in aggregage_extraction)
bwfilt_agg = logical(filt_agg);

filt_vol = sum(bwfilt_agg,"all")*newvoxVol; % filtered aggregate volume
vol_scaleFactor = og_vol_nt/filt_vol; % factor to multiply with final volume to get approx og volume

if vol_scaleFactor < 1
    perc_thresh = 1-vol_scaleFactor; % percentage of aggregate voxels to delete to get approx og vol
    numdelVox = round(perc_thresh*sum(bwfilt_agg,"all")); % number of voxels to delete 
    sorted_voxVals = sort(nonzeros(filt_agg)); % sorted voxel values to find threshold that deletes the right number of voxels
    thresh = sorted_voxVals(numdelVox,:); 
    filt_agg(filt_agg < thresh) = 0; % apply thresh
    bwfilt_agg = logical(filt_agg);
    % crop array to current bounding box
    coco = bwconncomp(bwfilt_agg,26);

    % for now, keep only biggest component :)
    if coco.NumObjects > 1
        props = regionprops3(coco, 'Volume');
        volumes = [props.Volume];
        biggestcomp = find((max(volumes))==volumes);
        
        bwlab = bwlabeln(bwfilt_agg,26);
        bwfilt_agg = zeros(size(bwlab));
        bwfilt_agg(bwlab == biggestcomp) = 1;
        filt_agg(bwfilt_agg == 0) = 0;
    end
    coco2 = bwconncomp(bwfilt_agg,26);
    propsc = regionprops3(coco2,'BoundingBox');
    bbox = propsc.BoundingBox;
    boundbox = [(bbox(:,1:3) + 0.5), (bbox(:,4:6)-1)];
    filt_agg = imcrop3(filt_agg, boundbox);
    bwfilt_agg = logical(filt_agg);
end



end