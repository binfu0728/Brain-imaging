% two images
clc;clear;

fileDir   = pwd;
files     = dir([fileDir,'\*.tif']);
filenames = {files.name}';

darkidx   = 0;
brightidx = [400,800,1200,1600,2000];

darkimg = extractFiles(filenames,0);
darkimg = double(Tifread(darkimg));
darkimg = darkimg(256-149:256+150,256-149:256+150,:); %crop to central FOV

offset  = mean(darkimg(:,:,10),'all');

mean_sig_all = zeros(length(brightidx),500-1);
var_sig_all  = zeros(length(brightidx),500-1);

for ii = 1:length(brightidx)
    bi = brightidx(ii);
    tmpt = extractFiles(filenames,bi);
    tmpt = double(Tifread(tmpt));
    brightimg = tmpt(256-149:256+150,256-149:256+150,:) - offset; %crop to central FOV
    for iii = 1:499
        A = brightimg(:,:,iii);
        B = brightimg(:,:,iii+1);
        r = mean(A,'all')/mean(B,'all');
        diff = A-B;
        mean_sig_all(ii,iii) = mean(A,'all');
        std_sig          = std(diff,0,'all');
        var_sig_all(ii,iii)  = std_sig^2/2;
    end
end

g = zeros(300,1);
for iii = 1:300
    var_sig = var_sig_all(:,iii);
    mean_sig = mean_sig_all(:,iii);
    g(iii) = pinv(var_sig'*var_sig)*var_sig'*mean_sig;
end
%%
plot(var_sig_all(:,100),mean_sig_all(:,100),'b.','markersize',10);
set(gca,'fontsize',14);
xlabel('Variance(count^2)','fontsize',14);
ylabel('Mean(count)','fontsize',14);
title('Mean-Variance plot','fontsize',16);

%%
g(g<0.012) = [];
pd = fitdist(g(:),'Normal');
x_pdf = 0.012:0.00005:0.018;
y = pdf(pd,x_pdf);
 
figure
histogram(g,'Normalization','pdf');
title('Gain for all pixels in 300x300 FoV');
set(gca,'fontsize',14);
ylabel('Normalized frequency(a.u.)','fontsize',14);
xlabel('gain(e^-/count)','fontsize',14);
xlim([0.012,0.018]);
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