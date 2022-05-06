function [] = Tifwrite(volume,filename)
% volume has to be uint16 normalized
    t = Tiff(filename,'w'); % set up tif for writing
    tagstruct.ImageLength = size(volume,1); % image height
    tagstruct.ImageWidth  = size(volume,2); % image width
    tagstruct.SampleFormat = 1; % uint
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = 16; %change here for saving bit width
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software = 'MATLAB';
    setTag(t,tagstruct)

    for ii=1:size(volume,3)
       setTag(t,tagstruct);
       write(t,volume(:,:,ii));
       writeDirectory(t);
    end
    close(t)
end