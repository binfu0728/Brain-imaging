function num_z = numberAnalysis(smalls,larges,z,s)
% input  : smalls, result of all small aggragtes from this image stack (centroid list)
%          larges, boundarys of all large aggregates from this image stack ()
%          z, the used slices for this sample, zi and zf
%          s, configuration file
%          
% output : num_z, number per slice for small and large aggregates

    num_z = zeros(1,length(smalls)+length(larges)) - 1; %lists are for the small, BWs are for the large, -1 for making the smallest number starting from zero
    for i = 1:length(smalls)
        tmpt = smalls{i};
        num_z(i) = size(tmpt(tmpt(:,end)==z),1); %count the numbers at a specific slice (z)
    end
    
    if ~isempty(larges) %if large aggregates will be analyzed
        for i = 1:length(larges)
            if sum(larges{i},'all') ~= 0 %if there is a large aggregate in the fov
                tmpt = larges{i};
                tmpt = load.boundary2BW(tmpt(tmpt(:,end)==z,1:2),s,1); %load the spreadsheet at a specific slice (z) to a binary mask
                num_z(i+length(smalls)) = length(bwconncomp(tmpt).PixelIdxList); %count the numbers at a specific slice (z)
            else
                num_z(i+length(smalls)) = 0;
            end
        end
    end
end