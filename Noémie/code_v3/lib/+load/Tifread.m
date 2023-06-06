function tiff_stack = Tifread(filename)
    tiff_info              = imfinfo(filename);
    width                  = tiff_info.Width; %columns
    height                 = tiff_info.Height; %rows
    tiff_stack             = uint16(zeros(height(1),width(1),length(tiff_info)));
    
    for i = 1:length(tiff_info) % how does length(tiff_info) correspond to nb of stacks ?
        tiff_stack(:,:,i)      = imread(filename, i);
    end
end