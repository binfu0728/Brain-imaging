function [result_oligomer,result_slice,BW] = findInfo(BW,zimg,j)
% input  : BW, binary mask
%          zimg, the processed image stack
%          j, the current loop number
% 
% output : result_oligomer, result per oligomer
%          result_slice, result per slice

    result_slice       = zeros(1,3); %result per slice, averaged number, averaged mean intensity, averaged sum intensity
%     [aps,BW]          = image.BWdilation(BW);
    [sigImage,bgImage] = core.extractBg(BW,zimg); %pure signal and pure background
    result_oligomer    = regionprops('table',BW,sigImage,'centroid','MeanIntensity','Area');

    if ~isempty(result_oligomer) %if there is at least one oligomer in the FoV
        sumintensity   = 2.5*result_oligomer.MeanIntensity.*result_oligomer.Area; %total intensity per oligomer in long format, 2.5x from calibration between gaussian and flood fill intensity finding calibration
%         sumintensity = zeros(size(result_oligomer,1),1); %use the real mask dilation result, not from calibration ratio
%         for k = 1:size(result_z,1)
%             sumintensity(k) = sum(sigImage(aps{k}));
%         end
        tmpt = array2table([sumintensity,repmat(j,size(result_oligomer,1),1)],'VariableNames', {'SumIntensity','z'}); % add extra columns to the table
        result_oligomer = [result_oligomer,tmpt]; %concat data into the long format
%         result_slice(1) = length(result_oligomer.Centroid);
%         result_slice(2) = mean(result_oligomer.SumIntensity); 
%         result_slice(3) = median(bgImage,'all');
    else
        result_oligomer = array2table([0 0 0 0 0 j]);
        result_oligomer = mergevars(result_oligomer,[2,3]);
        result_oligomer = renamevars(result_oligomer,1:5,{'Area','Centroid','MeanIntensity','SumIntensity','z'});
%         result_slice(1) = 0;
%         result_slice(2) = 0; 
%         result_slice(3) = median(bgImage,'all');
    end
end