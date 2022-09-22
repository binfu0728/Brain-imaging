function num_z = numberAnalysis(lists,BWs,z)
% input  : lists, result of all small aggragtes from this image stack
%          BWs, boundarys of all large aggregates from this image stack
%          z, the used slices for this sample, zi and zf
%          
% output : num_z, number per slice for small and large aggregates

    s.width  = 2048;
    s.height = 2048;
    num_z = zeros(1,length(lists)+length(BWs)); %small,large
    for i = 1:length(lists)
        tmpt = lists{i};
        num_z(i)  = size(tmpt(tmpt(:,end)==z),1) - 1;
    end

    if ~isempty(BWs)
        for i = 1:length(BWs)
            if sum(BWs{i},'all') ~= 0
                tmpt = BWs{i};
                tmpt = load.boundary2BW(tmpt(tmpt(:,end)==z,1:2),s,1);
                num_z(i+length(lists)) = length(bwconncomp(tmpt).PixelIdxList);
            else
                num_z(i+length(lists)) = 0;
            end
        end
    end
end