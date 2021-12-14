% Very draft version of generalized detection code for part of IF images and
% all DAB black-white images
% Author: Bin Fu, bf341@cam.ac.uk
%%
clc;clear;
filename          = '4_LB_neurites_40x_2_MMStack_Default.ome';
img               = Tifread([filename,'.tif']);
img               = mean(img,3);
upsampling        = 4;
mode              = 'IF';
gaussian_size     = 200; %200 for 40x and 100x, if img has undetected but wanted large obj, choose a larger value
bpass_size_l      = 4;   %4 for 40x and 100x, if img has undetected but wanted small obj, choose a smaller value
bpass_size_h      = gaussian_size;
bpass_order       = 1;   %1 for 40X IF image, 4 for DAB due to less distinguishable background
intensity_precent = 0.5; %intensity post fitering is not used in DAB image
area_precent      = 0.3; %DAB could use 0.6


%% Pre-processing
[imgg,i]          = preFiltering(img,upsampling,gaussian_size,bpass_size_l,bpass_size_h,bpass_order,mode);

%% Thresholding
num_bins          = 2^16;
counts            = imhist(i,num_bins);
p                 = counts / sum(counts);
omega             = cumsum(p);

idx               = find(omega>0.95);
t                 = (idx(1) - 1) / (num_bins - 1);
BW                = imbinarize(i,t);
BW                = imfill(BW,'holes');

%% Post-processing
BW                = postFiltering(BW,i,intensity_precent,'intensity');
BW                = postFiltering(BW,i,area_precent,'area');

plotResultFigure(BW,imgg);

%% Analysis
CC            = bwconncomp(BW);
regions       = CC.PixelIdxList;
s             = regionprops('table',BW,'Area','MajorAxisLength','MinorAxisLength');
area          = s.Area;
minorL        = s.MinorAxisLength;
majorL        = s.MajorAxisLength;

result_excel    = [(1:size(s,1))',area,minorL,majorL];
result_excel    = array2table(result_excel,"VariableNames",["No. of LB/LN","Area(pixel)","MinorAxisLength","MajorAxisLength"]);
writetable(result_excel,[filename,'_result.csv']);
maskedImage     = uint16(BW).*imgg;
processedFrame  = imgg;
imwrite(maskedImage,[filename,'_maksedImage.tif']);
imwrite(processedFrame,[filename,'_processedFrame.tif']);

%% Functions
function [img_upsampled,img_processed] = preFiltering(img,upsampling,gsize,bsize_l,bsize_h,order,mode)
    img_upsampled = normalize16(imresize(img,upsampling,'bicubic'));
    
    img_processed = imgaussfilt(img_upsampled,gsize);

    switch mode
        case 'IF'
            img_processed = img_upsampled - img_processed;
        case 'DAB'
            img_processed = img_processed - img_upsampled;
        otherwise
            error('wrong');    
    end
    
    for i = 1:order
        img_processed = bandpass(img_processed,bsize_l,bsize_h);
    end
    img_processed = normalize16(img_processed);
    
end

function [BW,idx] = postFiltering(BW,img,percentage,method)
    CC         = bwconncomp(BW);
    regions    = CC.PixelIdxList; 
    
    switch method
        case 'area'
            s          = regionprops('table',BW,'Area');
            areas      = s.Area;
            sorting    = normalize16(areas);
        case 'intensity'
            sigImage        = abs(img-imfill(uint16((1-BW)).*img));
            avg_intensity   = zeros(length(regions),1);
            for k = 1:length(regions)
                avg_intensity(k)  = mean(sigImage(regions{k}));
            end
            sorting         = normalize16(avg_intensity);
        otherwise
            error('wrong method');
    end
    
    num_bins     = 2^16;
    counts       = imhist(sorting,num_bins);
    p            = counts / sum(counts);
    omega        = cumsum(p);

    idx          = find(omega>percentage);
    idx          = find(sorting<idx(1));
    
    for k = 1:length(idx)
        BW(regions{idx(k)}) = 0;
    end
end

function [] = plotResultFigure(BW,img)
    figure;
    imshow(img,[]);

    figure;
    imshow(img,[]);
    hold on
    [labelBW,numObj] = bwlabel(BW);
    boundaries = bwboundaries(BW, 'noholes');

    for j = 1:numObj
        b = boundaries{j};
        plot(b(:,2),b(:,1),'b','linewidth',1.5); %Plot boundary

        ind = find(labelBW==j);
        [m,n] = ind2sub(size(BW), ind);
    %     plot(out(j,2),out(j,1),'rx') %Plot centre
        text(mean(n)+10,mean(m)+10,['\color{blue} ' num2str(j)], 'FontSize', 10) %Plot number
    end
end

function img           = normalize16(img)
    img                    = img - min(min(img)) + 1;
    img                    = uint16(img./max(max(img)) .* (2^16-1));
end

function tiff_stack    = Tifread(filename)
    tiff_info              = imfinfo(filename);
    width                  = tiff_info.Width;
    height                 = tiff_info.Height;
    tiff_stack             = uint16(zeros(height(1),width(1),length(tiff_info)));
    for i                  = 1:length(tiff_info)
        tiff_stack(:,:,i)      = imread(filename, i);
    end
end
