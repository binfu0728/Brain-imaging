function BW = boundary2BW(mat,imsz)
% input  : mat, the boundary of the cell/large aggregates
% 
% output : BW, the converted binary mask
    BW = false(imsz);
    if ~isempty(mat)           
        tmpt = sub2ind(size(BW),mat(:,1)',mat(:,2)');
        BW(tmpt) = 1;
        BW = imfill(BW,'holes');
    end
end