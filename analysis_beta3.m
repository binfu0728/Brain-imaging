% Folder format:data\1_1.tif
% Author: Bin Fu, bf341@cam.ac.uk

%% Initialization
clear;clc;

pixSize              = 0.107; %unit in um
time                 = 10;    %number of frame
zaxis                = 11;    %number of z-samples
colour               = 3;     %number of colour channels
sigma                = 2;     %threshold after convolution
numOfTrail           = '22';  % nth round experiment
usedFilesIdx         = [1,2,3,4,5,6,7]; %The used sample index
usedFilesName        = {'rab488','mou568','mou488','rab568','MJFR1/tsyn','MJFR1/psyn','syn211/psyn'}; %The used sample name, order need to be the same as index above
coincidenceIdx       = [5,6]; %The sample that is used for finding coincidence
usedChannel          = [1,2]; %Used channel
mainChannel          = 2;
channelColour        = {'488nm','561nm','405nm'}; %The colour for all channels, order needs to be the same as experimental data
saveResult           = 0;
fileDir              = 'C:\Users\fubin\Desktop\22th'; %folder directory

% File reading and checking
% fileDir              = pwd; 
files                = dir([fileDir,'\*.tif']);
filenames            = {files.name}'; %image names
[filenames,fileFOVs] = extraFiles(filenames,usedFilesIdx);
initialCheck(usedFilesIdx,coincidenceIdx,usedFilesName,usedChannel,mainChannel,channelColour)

if saveResult
    idcs      = strfind(fileDir,'\');
    newdir    = fileDir(1:idcs(end)-1);
    resultDir = [newdir,'\result_',fileDir(idcs(end)+1:end)];
    tableDir  = '\tables';
    maskedDir = '\maskedImage';
    oriImgDir = '\processedFrame';
    makeNewSubFolder(resultDir,tableDir,3);
    makeNewSubFolder(resultDir,maskedDir,3);
    makeNewSubFolder(resultDir,oriImgDir,3);
end

%% Image Process
spotCounts       = zeros(length(filenames),colour);
coincidence_rate = zeros(length(filenames),1);
chance_rate      = zeros(length(filenames),1);

for k = 1:length(filenames)
    tic
    filename        = char(filenames(k)); 
    img             = double(Tifread([fileDir,'\',filename]));
    img             = reshape(img,size(img,1),size(img,1),zaxis,time*colour);
    masks           = false(size(img,2),size(img,1),colour);
    
    for c = 1:colour
        channel         = img(:,:,:,c:colour:time*colour);
        img1            = mean(squeeze(channel(:,:,1,:)),3); %row x col x time, The processed image is an average   
        bgmask          = aggreMask(img1,sigma);
        maskedImage     = bgmask.*img1;

        masks(:,:,c)    = bgmask; 
        CC              = bwconncomp(bgmask); %8-connectivity(all direction connection will be counted)
        aggregatePoints = CC.PixelIdxList;
        spotCounts(k,c) = length(aggregatePoints);
        
        if saveResult
            s         = regionprops(bgmask,'centroid','area','MinorAxisLength','MajorAxisLength');
            centroids = cat(1,s.Centroid);
            longD     = cat(1,s.MajorAxisLength); 
            shortD    = cat(1,s.MinorAxisLength);

            segments  = false(512,512,length(s));
            for p = 1:length(s)
                tmpt = false(512,512);
                tmpt(aggregatePoints{p}) = 1;
                if (longD(p)-shortD(p))<5
                    dilatedR = 1;
                else
                    dilatedR = 2;
                end
                se = strel('disk',dilatedR);
                tmpt = imdilate(tmpt,se); 
                segments(:,:,p) = tmpt;
            end
            sigmask = max(segments,[],3);

            bgEstimation_fill      = (1-bgmask).*img1;     %bg = image - spots, estimated by performing a flood-fill operation
            bgImage                = imfill(bgEstimation_fill); %bg estimation based on bgImage
            sigImage               = abs(img1-imfill((1-sigmask).*img1)); %pure signal intensity of the detected points.
            
            intensity       = zeros(length(s),1);
            background      = zeros(length(s),1);
            area            = cat(1,s.Area);
            
            for j = 1:length(aggregatePoints)
                intensity(j)  = sum(sigImage(aggregatePoints{j}));
                background(j) = mean(bgImage(aggregatePoints{j})); 
            end

            result_excel    = [(1:length(s))',area,intensity,background];
            result_excel    = array2table(result_excel,"VariableNames",["No. of Olig","Area(pixel)","Total Intensity","Mean Background"]);
            writetable(result_excel,[resultDir,tableDir,'\','c',num2str(c),'\',filename,'_result.csv']);
            maskedImage     = normalize16(maskedImage);
            processedFrame  = normalize16(img1);
            imwrite(maskedImage,[resultDir,maskedDir,'\','c',num2str(c),'\',filename,'_maksedImage.tif']);
            imwrite(processedFrame,[resultDir,oriImgDir,'\','c',num2str(c),'\',filename,'_processedFrame.tif']);
            
            clear s centroids longD shortD area
        end
        
    end
 
    [coincidence_rate(k),~] = findCoincidence(masks,usedChannel,mainChannel);
    masks(:,:,1)            = imrotate(masks(:,:,1),90);
    [chance_rate(k),~]      = findCoincidence(masks,usedChannel,mainChannel);
    ttime                   = toc;
    fprintf(['Process ',num2str(k),' | ',num2str(length(filenames)),', took ',num2str(ttime),' secs for all 3 channels\n']);
end

%% Image Analysis
meanSpots                    = zeros(length(fileFOVs),colour);
meanCoincidence              = zeros(length(fileFOVs),2);
stdSpots                     = meanSpots;
stdCoincidence               = meanCoincidence;
startIdx                     = 1; 
endIdx                       = 1;

for i = 1:length(fileFOVs)
    endIdx                       = startIdx+fileFOVs(i)-1;
    meanSpots(i,:)               = mean(spotCounts(startIdx:endIdx,:),1);
    meanCoincidence(i,1)         = mean(coincidence_rate(startIdx:endIdx,:),1);
    meanCoincidence(i,2)         = mean(chance_rate(startIdx:endIdx,:),1);
    if fileFOVs(i) ~= 1
        stdSpots(i,:)               = std(spotCounts(startIdx:endIdx,:),1);
        stdCoincidence(i,1)         = std(coincidence_rate(startIdx:endIdx,:),1);
        stdCoincidence(i,2)         = std(chance_rate(startIdx:endIdx,:),1);
    end
    startIdx                     = endIdx+1;
end
meanCoincidence = meanCoincidence*100; stdCoincidence = stdCoincidence*100; % change to percentage representation

idx = ismember(usedFilesIdx,coincidenceIdx);
plotResultFigure(meanCoincidence(idx,:),stdCoincidence(idx,:),usedFilesIdx,usedFilesName,usedChannel,channelColour,numOfTrail,'coincidence',idx);
plotResultFigure(meanSpots(:,usedChannel),stdSpots(:,usedChannel),usedFilesIdx,usedFilesName,usedChannel,channelColour,numOfTrail,'spots');

%% Functions
function mask = aggreMask(img,std)
    se                   = strel('disk',5);
    ksize                = 1;
    h                    = RW2DKernel(ksize);
    i_conv               = imfilter(imtophat(img,se),h,'conv'); 
    x                    = i_conv(:);
    [~,s]                = normfit(x);
    i_conv(i_conv<std*s) = 0;

    se                   = strel('disk',1);
    mask                 = imopen(i_conv,se); %morphological open operation for filtering ting structures(noise)
    mask(mask>0)         = 1;
    mask                 = maskFilter(mask,ksize);
end

function [coincidence_rate,coincidence_mask] = findCoincidence(masks,usedChannel,mainChannel,diameter)
    if nargin<4
        diameter = 3;
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
    se = strel('square',diameter);
    m1 = imdilate(m1,se); 
    m2 = imdilate(m2,se);
    coincidence_mask = m1&m2;
    sc1 = regionprops(coincidence_mask,'centroid'); 
    sc2 = regionprops(masks(:,:,usedChannel(usedChannel==mainChannel)),'centroid');
    coincidence_rate = length(sc1)/length(sc2);
end

function [] = plotResultFigure(meanNum,stdNum,usedFilesIdx,usedFilesName,usedChannel,channelColour,numOfTrail,mode,idx)
    if nargin<9
        idx = 1:length(usedFilesIdx);
    end
    
    f                            = figure;
    f.Position                   = [200 200 250*length(usedFilesIdx) 700];
    
    usedFilesIdx                 = usedFilesIdx(idx);
    usedFilesName                = usedFilesName(idx);
    errorHigh                    = stdNum;
    errorLow                     = errorHigh;
    errorLow(stdNum>meanNum)     = meanNum(stdNum>meanNum);
    
    if strcmp(mode,'spots')
        legendNames = channelColour(usedChannel);
        format = '%0.0f';
    elseif strcmp(mode,'coincidence')
        legendNames = {'Coincidence','Chance Coincidence'};
        format = '%0.2f';
    else
        error('not supported');
    end
    
    barColour                    = colourLUT(channelColour);
    axes1                        = axes;
    hold on
    numFiles                     = 1:length(usedFilesIdx);
    for i = 1:length(numFiles)
        move                         = 1:size(errorHigh,2);
        move                         = move-mean(move);
        for j = 1:size(errorHigh,2)
            b(j) = bar(numFiles(i)+0.15*move(j),meanNum(i,j),0.1,'FaceColor',barColour(usedChannel(j),:));
            err                        = errorbar(numFiles(i)+0.15*move(j),meanNum(i,j),errorLow(i,j),errorHigh(i,j),'.','color','k');
            text(numFiles(i)+0.15*move(j),(meanNum(i,j)+errorHigh(i,j))*1.01,num2str(meanNum(i,j)',format),...
                'fontsize',18,'fontweight','bold','HorizontalAlignment','center','VerticalAlignment','bottom'); 
            err.LineWidth              = 3;
            err.CapSize                = 6;
        end
    end
    
    axes1.LineWidth = 1.5;
    set(axes1,'Xlim',[0.5 length(usedFilesIdx)+0.5]);
    set(axes1,'XTick',1:length(usedFilesIdx),'XTickLabel',usedFilesName,'fontsize',20);
    
    l = legend([b(1),b(2)],legendNames,'Location','best');
    legend('boxoff');
    l.ItemTokenSize = [50,25];
    set(l,'fontsize',20);
    
    if strcmp(mode,'spots')
        title([numOfTrail,'^t^h round analysis on the number of detected spots'],'fontsize',22);
        ylabel('Average number of spots / FOV','fontsize',20);
    elseif strcmp(mode,'coincidence')
        title([numOfTrail,'^t^h round analysis on the coincidence between channels'],'fontsize',22);
        ylabel('coincidence(%)','fontsize',20);
    else
        error('not supported');
    end
end

function [filenames,fileFOVs] = extraFiles(filenames,usedFilesIdx)
    files      = [];
    filePrefix = zeros(length(filenames),1);
    count      = 1;
    for i = 1:length(filenames)
        tmpt   = char(filenames(i));
        for j = 1:length(tmpt)
            if isempty(str2num(tmpt(j))) %do not change to str2double
                filePrefix(i) = str2double(tmpt(1:j-1));
                break
            end
        end
        if find(usedFilesIdx==filePrefix(i))
            files(count) = i;
            count = count + 1;
        end
    end
    
    filePrefix  = filePrefix(files);
    [~,Y]       = ismember(filePrefix,usedFilesIdx);
    [~,sortIdx] = sort(Y,'ascend');
    files       = files(sortIdx);
    filePrefix  = filePrefix(sortIdx);
    filenames   = filenames(files);
        
    [uniqueFiles, ~, ic] = unique(filePrefix,'stable');
    fileFOVs             = zeros(length(uniqueFiles),1);
    
    for i = 1:length(uniqueFiles)
        fileFOVs(i) = length(find(ic == i));
    end
end

function [] = makeNewSubFolder(parentFolder,subFolderName,channels)   
    newFolder = [parentFolder,subFolderName];
    if ~exist(newFolder, 'dir')
        mkdir(newFolder); 
        if channels ~= 1
            for c = 1:channels
                mkdir([newFolder,'\','c',num2str(c)]); 
            end
        end
    end
end

function RW = RW2DKernel(sigma)
% Inverse Laplacian of Gaussian operator, also called as 2D Ricker wavelet,
% similar to difference of Gaussian kernel, frequently used as a blob detector
    x = (0:8*sigma) - 4*sigma; y = x;
    [X,Y] = meshgrid(x,y);
    amplitude = 1.0 / (pi * sigma * 4);
    rr_ww = (X.^2+Y.^2)/(2.*sigma.^2);
    RW = amplitude*(1-rr_ww).*exp(-rr_ww);
end

function mask = maskFilter(mask,sigma)
    mask(1:4*sigma,:) = 0;
    mask(end-4*sigma:end,:) = 0;
    mask(:,1:4*sigma) = 0;
    mask(:,end-4*sigma:end) = 0;
    mask = logical(mask);
end

function img = normalize16(img)
    img = img - min(min(img)) + 1;
    img = uint16(img./max(max(img)) .* (2^16-1));
end

function barColour = colourLUT(channelColour)
    barColour      = zeros(length(channelColour),3);
    for i = 1:length(channelColour)
        if strcmp(char(channelColour(i)),'405nm')
            barColour(i,:) = [0.4940 0.1840 0.5560]; 
        elseif strcmp(char(channelColour(i)),'488nm')
            barColour(i,:) = [0.3010 0.7450 0.9330];
        elseif strcmp(char(channelColour(i)),'561nm')
            barColour(i,:) = [0.4660 0.6740 0.1880];
        else
            barColour      = [0 0 0];
        end
    end
end

function [] = initialCheck(usedFilesIdx,coincidenceIdx,usedFilesName,usedChannel,mainChannel,channelColour)
    if length(usedFilesIdx) ~= length(usedFilesName)
        error('Unmatching between names and files');
    end
    
    if length(usedChannel) > length(channelColour)
        error('Wrong number of used channels/channel colours');
    end
    
    if nnz(ismember(usedFilesIdx,coincidenceIdx)) ~= length(coincidenceIdx)
        error('Wrong input on index of coincidence files');
    end
    
    if nnz(ismember(usedChannel,mainChannel)) ~= 1
        error('Wrong input on main Channel');
    end
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
