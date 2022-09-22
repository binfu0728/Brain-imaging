function [] = plotScaleBar(f,img,pixelRes,scale)
% input  :  f, the figure where the scale bar should be
%           img, original image
%           pixelRes, pixel size in object space
%           scale, the real scale of the scale bar, !!! in the same scale with pixelRes

    figure(f);hold on;
    [r,c] = size(img);
    length_bar = round(scale/pixelRes);
    width_bar = round(length_bar/10);
    r_start = round(r*13/14) - length_bar;
    c_start = round(c*13/14) - width_bar;
    
    rectangle('Position',[r_start,c_start,length_bar,width_bar],'FaceColor',[1 1 1])
    text(r_start+(length_bar/2),c_start-2,[num2str(scale),'\mum'],'HorizontalAlignment','center','VerticalAlignment','bottom','Color',[1 1 1],'Fontweight','bold');
end