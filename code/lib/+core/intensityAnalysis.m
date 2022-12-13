function [inten_z,inten_i] = intensityAnalysis(lists,z)
% input  : lists, result of all small aggregates from this image stack
%          z, the used slices for this sample, zi and zf
%          
% output : inten_z, intensity per slice for small aggregates
%          inten_i, intensity per oligomer for small aggregates

    inten_z = zeros(1,length(lists));
    inten_i = cell(1,length(lists));
    for i = 1:length(lists)
        tmpt       = lists{i};
        inten_z(i) = mean(tmpt(tmpt(:,end)==z,5),1); %5th col is the intensity
        inten_i{i} = [inten_i{i};tmpt(tmpt(:,end)==z,5)]; %concat intensities into a long format
    end
end