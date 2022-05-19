% one pixel
clc;clear;

fileDir   = pwd;
files     = dir([fileDir,'\*.tif']);
filenames = {files.name}';

darkidx   = 0;
brightidx = [400,800,1200,1600,2000];

darkimg = extractFiles(filenames,0);
darkimg = double(Tifread(darkimg));
darkimg = darkimg(256-149:256+150,256-149:256+150,:); %crop to central FOV

pix = [100,100];
offset  = mean(squeeze(darkimg(pix(1),pix(2),:)));

mean_sig = zeros(length(brightidx),1);
std_sig  = zeros(length(brightidx),1);
var_sig  = zeros(length(brightidx),1);

for ii = 1:length(brightidx)
    bi = brightidx(ii);
    brightimg = extractFiles(filenames,bi);
    brightimg = double(Tifread(brightimg));
    brightimg = brightimg(256-149:256+150,256-149:256+150,:) - offset; %crop to central FOV
    mean_sig(ii) = mean(squeeze(brightimg(pix(1),pix(2),:)));
    std_sig(ii)  = std(squeeze(brightimg(pix(1),pix(2),:)));
    var_sig(ii)  = std_sig(ii)^2;
end

g = pinv(var_sig'*var_sig)*var_sig'*mean_sig
%%
plot(var_sig,mean_sig,'b.','markersize',10);
set(gca,'fontsize',14);
xlabel('Variance(count^2)','fontsize',14);
ylabel('Mean(count)','fontsize',14);
title('Mean-Variance plot','fontsize',16);
%%
function filename = extractFiles(filenames,idx)
    filePrefix = zeros(length(filenames),1);
    for i = 1:length(filenames)
        tmpt   = char(filenames(i));
        for j = 1:length(tmpt)
            if isempty(str2num(tmpt(j))) %do not change to str2double
                filePrefix(i) = str2double(tmpt(1:j-1));
                break
            end
        end
    end
    idx = find(filePrefix==idx);
    if isempty(idx)
        error('wrong index used');
    else
       filename = filenames{idx}; 
    end
end

function tiff_stack = Tifread(filename)
    tiff_info              = imfinfo(filename);
    width                  = tiff_info.Width;
    height                 = tiff_info.Height;
    tiff_stack             = uint16(zeros(height(1),width(1),length(tiff_info)));
    for i                  = 1:length(tiff_info)
        tiff_stack(:,:,i)      = imread(filename, i);
    end
end