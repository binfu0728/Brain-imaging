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

brightimg = zeros(300,300,500,length(brightidx));

for ii = 1:length(brightidx)
    bi = brightidx(ii);
    tmpt = extractFiles(filenames,bi);
    tmpt = double(Tifread(tmpt));
    brightimg(:,:,:,ii) = tmpt(256-149:256+150,256-149:256+150,:) - offset; %crop to central FOV
end

mean_sig_all = squeeze(mean(brightimg,3));
std_sig_all  = squeeze(std(brightimg,0,3));
var_sig_all  = std_sig_all.^2;

g = zeros(300,300);
count = 1;
for iii = 1:300
    for jjj = 1:300
        var_sig = squeeze(var_sig_all(iii,jjj,:));
        mean_sig = squeeze(mean_sig_all(iii,jjj,:));
        g(count) = pinv(var_sig'*var_sig)*var_sig'*mean_sig;
        count = count+1;
    end
end


%%
plot(squeeze(var_sig_all(100,100,:)),squeeze(mean_sig_all(100,100,:)),'b.','markersize',10);
set(gca,'fontsize',14);
xlabel('Variance(count^2)','fontsize',14);
ylabel('Mean(count)','fontsize',14);
title('Mean-Variance plot','fontsize',16);

%%
pd = fitdist(g(:),'Normal');
x_pdf = 0.01:0.0001:0.02;
y = pdf(pd,x_pdf);
 
figure
histogram(g,'Normalization','pdf');
title('Gain for all pixels in 300x300 FoV');
set(gca,'fontsize',14);
ylabel('Normalized frequency(a.u.)','fontsize',14);
xlabel('gain(e^-/count)','fontsize',14);
xlim([0.01,0.02]);
line(x_pdf,y,'linewidth',3)
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