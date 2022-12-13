function mat = BW2boundary(BW)
% input  : BW, the binary mask of cell/large aggregates
%          z, the used slices for this sample, zi and zf
% 
% output : mat, the boundary of a cell/large aggregate

    mat = [];
    for j = 1:size(BW,3)
        boundaries = bwboundaries(BW(:,:,j), 'noholes');
        boundaries = cell2mat(boundaries);
        if ~isempty(boundaries)
            tmpt = [boundaries,repmat(j,size(boundaries,1),1)];
        else
            tmpt = [0,0,j];
        end
        mat = [mat;tmpt];
    end
end