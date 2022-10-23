function [result_z,result_avg,BW] = findInfo(BW,zimg,z,j)
% input  : BW, binary mask
%          zimg, the processed image stack
%          z, the procesed slice, zi and zf
%          j, the current loop number
% 
% output : result_z, result per oligomer
%          result_avg, result per slice

    result_avg         = zeros(1,3);
%     [aps,BW]           = image.BWdilation(BW);
    [sigImage,bgImage] = image.extractBg(BW,zimg);
    result_z           = regionprops('table',BW,sigImage,'centroid','MeanIntensity','Area');

    if ~isempty(result_z)
        sumintensity   = 2.5*result_z.MeanIntensity.*result_z.Area; %2.5 from gaussian calibration
%         sumintensity = zeros(size(result_z,1),1);
%         for k = 1:size(result_z,1)
%             sumintensity(k) = sum(sigImage(aps{k}));
%         end
        tmpt = array2table([sumintensity,repmat(z+j-1,size(result_z,1),1)],'VariableNames', {'SumIntensity','z'});
        result_z       = [result_z,tmpt];
%         result_z.Area  = result_z.Area/16*(0.107^2);
        result_avg(1)  = length(result_z.Centroid);
        result_avg(2)  = mean(result_z.SumIntensity); 
        result_avg(3)  = median(bgImage,'all');
    else
        result_z       = array2table([0 0 0 0 0 z+j-1]);
        result_z       = mergevars(result_z,[2,3]);
        result_z       = renamevars(result_z,1:5,{'Area','Centroid','MeanIntensity','SumIntensity','z'});
        result_avg(1)  = 0;
        result_avg(2)  = 0; 
        result_avg(3)  = median(bgImage,'all');
    end
end