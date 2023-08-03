function is_out = agg_continuity(bn_mask, img_masked)
% estimates if agg seems to continue outside of image dimensions 
%
% INPUT     :   bn_mask : original img size 3D logical array 
%               img_masked : original img size 3D array with double values where aggregate and 0 where no aggregate
% OUTPUT    :   1 if aggregate seems to continue outside of image dimensions
%               0 if z edge slice of the image seems to be the edge of the aggregate             

is_out = 0;
imsz = size(bn_mask);
slices = imsz(3);

% find which z slice is edge 
getslice = any(any(bn_mask(:,:,1))); % 1 if edge z=1, 0 if edge z=last dim

switch getslice
    case 1
        edge_slice = 1;
        prev_slice = 2;
        scnd_prev_slice = 3;
    case 0
        edge_slice = slices;
        prev_slice = slices - 1;
        scnd_prev_slice = slices - 2;
end

pospixels1 = nonzeros(img_masked(:,:,edge_slice));

% check for obvious continuity with area and pixel intensity values
if sum(bn_mask(:,:,edge_slice)) > sum(bn_mask(:,:,prev_slice)) & sum(bn_mask(:,:,prev_slice)) > sum(bn_mask(:,:,scnd_prev_slice))
    is_out = 1;
elseif sum(pospixels1,"all") > sum(img_masked(:,:,prev_slice)) & sum(img_masked(:,:,prev_slice)) > sum(img_masked(:,:,scnd_prev_slice))
    is_out = 1;
elseif std(pospixels1,1,"all") > 200 % based on analysis of some aggregates 
    is_out = 1;
end

end