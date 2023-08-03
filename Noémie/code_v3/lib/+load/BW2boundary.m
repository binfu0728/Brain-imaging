function mat = BW2boundary(BW,z)
% input  : BW, the binary mask of cell/large aggregates
%          z, the used slices for this sample, zi and zf
% 
% output : mat, the boundary of a cell/large aggregate

    mat = [];
    for j = 1:size(BW,3)
%         boundaries = bwboundaries(BW(:,:,j), 'noholes');
        L = bwlabel(BW(:,:,j), 8);
        boundaries = images.internal.builtins.bwboundaries(L, 8);%row,col
        boundaries = cell2mat(boundaries);
        boundaries = [boundaries,repmat(z(1)+j-1,size(boundaries,1),1)];
        mat = [mat;boundaries];
    end
end