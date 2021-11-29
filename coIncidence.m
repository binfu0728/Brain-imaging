clc;clear;

filename    = '5neurites_1'; 
time        = 10;  %number of frame, time-scan
zaxis       = 11;  %number of z-samples
colour      = 3;   %number of colour channels
sigma       = 2;   %portion of rejected background
usedChannel = [1,2]; 
mainChannel = 1;

% Image processing & aggregate counting
img          = double(Tifread([filename,'.tif']));
channel      = 1;
tmpt         = reshape(img,size(img,1),size(img,1),zaxis,time*colour);
masks        = false(size(img,2),size(img,1),colour);
imgs         = zeros(size(img,2),size(img,1),colour);
maskedImages = zeros(size(img,2),size(img,1),colour);

for c = 1:colour
    channel             = tmpt(:,:,:,c:colour:time*colour);
    img1                = mean(squeeze(channel(:,:,1,:)),3); %row x col x time, The processed image is an average
    imgs(:,:,c)         = img1;
    mask                = aggreMask(img1,sigma);
    maskedImages(:,:,c) = mask.*img1;
    mask                = logical(mask);
    masks(:,:,c)        = mask; 
    CC                  = bwconncomp(mask); %8-connectivity(all direction connection will be counted)
    aggregatePoints     = CC.PixelIdxList;
    spotCounts(c)       = length(aggregatePoints);
end

mask_1 = masks(:,:,usedChannel(1));  mask_2 =  masks(:,:,usedChannel(2));
s1 = regionprops(mask_1,'centroid'); c1 = cat(1,s1.Centroid); p1 = round(c1);
s2 = regionprops(mask_2,'centroid'); c2 = cat(1,s2.Centroid); p2 = round(c2);

m1 = zeros(size(mask_1)); 
m2 = zeros(size(mask_1)); 
for i = 1:length(s1)
    m1(p1(i,2),p1(i,1)) = 1;
end

for i = 1:length(s2)
    m2(p2(i,2),p2(i,1)) = 1;
end

m1 = logical(m1); m2 = logical(m2);
figure;
subplot(221);imshow(mask_1,[]);title('channel1');
subplot(222);imshow(mask_2,[]);title('channel2');
subplot(223);imshow(imgs(:,:,1),[]);
subplot(224);imshow(imgs(:,:,2),[]);
se = strel('square',3);
m1 = imdilate(m1,se); 
m2 = imdilate(m2,se);
coincidence_mask = m1&m2;
conincidence_num = regionprops(coincidence_mask,'centroid'); 
sc2 = regionprops(masks(:,:,usedChannel(usedChannel==mainChannel)),'centroid');
coincidence_rate = length(conincidence_num)/length(sc2);

maskedddd = imdilate(coincidence_mask,[1 1 1; 1 1 1; 1 1 1]).*imgs(:,:,usedChannel(usedChannel==mainChannel));
imgg      = normalize16(imgs(:,:,usedChannel(usedChannel==mainChannel))); 
maskedddd = normalize16(maskedddd); 
masked    = normalize16(maskedImages(:,:,usedChannel(usedChannel==mainChannel)));
comb(:,:,1)            = maskedddd*100;
comb(:,:,2)            = masked+imgg;
comb(:,:,3)            = imgg;
f1                     = figure;
image(comb); title('coincidence spots');
set(gca,'XColor', 'none','YColor','none');

masks(:,:,2) = imrotate(masks(:,:,2),90);
mask_1 = masks(:,:,usedChannel(1));  mask_2 =  masks(:,:,usedChannel(2));
s1 = regionprops(mask_1,'centroid'); c1 = cat(1,s1.Centroid); p1 = round(c1);
s2 = regionprops(mask_2,'centroid'); c2 = cat(1,s2.Centroid); p2 = round(c2);

m1 = zeros(size(mask_1)); 
m2 = zeros(size(mask_1)); 
for i = 1:length(s1)
    m1(p1(i,2),p1(i,1)) = 1;
end

for i = 1:length(s2)
    m2(p2(i,2),p2(i,1)) = 1;
end

m1 = logical(m1); m2 = logical(m2);
se = strel('square',3);
m1 = imdilate(m1,se); 
m2 = imdilate(m2,se);
coincidence_mask = m1&m2;
chance_num = regionprops(coincidence_mask,'centroid'); 
sc2 = regionprops(masks(:,:,usedChannel(usedChannel==mainChannel)),'centroid');
chance_rate = length(chance_num)/length(sc2);

maskedddd = imdilate(coincidence_mask,[1 1 1; 1 1 1; 1 1 1]).*imgs(:,:,usedChannel(usedChannel==mainChannel));
imgg      = normalize16(imgs(:,:,usedChannel(usedChannel==mainChannel))); 
maskedddd = normalize16(maskedddd); 
masked    = normalize16(maskedImages(:,:,usedChannel(usedChannel==mainChannel)));
comb(:,:,1)            = maskedddd*100;
comb(:,:,2)            = masked+imgg;
comb(:,:,3)            = imgg;
f1                     = figure;
image(comb); title('Chance coincidence spots');
set(gca,'XColor', 'none','YColor','none');

%% function
function RW = RW2DKernel(a,sigma)
% Inverse Laplacian of Gaussian operator, also called as 2D Ricker wavelet,
% similar to difference of Gaussian kernel, frequently used as a blob detector
    x         = (0:8*sigma) - 4*sigma; y = x;
    [X,Y]     = meshgrid(x,y);
    amplitude = 1.0 / (pi * sigma * 4) * a;
    rr_ww     = (X.^2+Y.^2)/(2.*sigma.^2);
    RW        = amplitude*(1-rr_ww).*exp(-rr_ww);
end

function mask = aggreMask(img,std)
    se                   = strel('disk',10);
    h                    = RW2DKernel(3,1);
    i_conv               = imfilter(imtophat(img,se),h,'conv'); 
    x                    = i_conv(:);
    [~,s]                = normfit(x);
    i_conv(i_conv<std*s) = 0;

    se                   = strel('disk',1);
    mask                 = imopen(i_conv,se); %morphological open operation for filtering ting structures(noise)
    mask(mask>0)         = 1;
    mask                 = maskFilter(mask);
end

function mask = maskFilter(mask)
    mask(1:10,:)       = 0;
    mask(end-10:end,:) = 0;
    mask(:,1:10)       = 0;
    mask(:,end-10:end) = 0;
end

function img = normalize16(img)
    img = img - min(min(img)) + 1;
    img = uint16(img./max(max(img)) .* (2^16-1));
end

function tiff_stack = Tifread(filename)
    tiff_info  = imfinfo(filename); % return tiff structure, one element per image
    tiff_stack = imread(filename, 1) ; % read in first image
    %concatenate each successive tiff to tiff_stack
    if size(tiff_info, 1) > 1
        for j = 2 : size(tiff_info, 1)
            temp_tiff  = imread(filename, j);
            tiff_stack = cat(3 , tiff_stack, temp_tiff);
        end
    end
end