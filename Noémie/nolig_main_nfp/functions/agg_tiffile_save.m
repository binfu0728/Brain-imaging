function agg_tiffile_save(img, filedir, imgfile_id, agg_id)
% save extracted 3D aggregate in tif file with metadata and double intensity values

fname = strcat(imgfile_id, '_agg_', agg_id, '.tif');
filepath = strcat(filedir, '\', fname);
imgdata = double(img);
resolution = 1200 / 0.0132; % nb of pixels per cm, specific to dataset
slices = size(imgdata,3);

% Save the image as a TIFF file

t = Tiff(filepath, 'w'); % set up Tiff object for writing

% set necessary tags values 
tagstruct.ImageLength = size(imgdata,1); % image height
tagstruct.ImageWidth  = size(imgdata,2); % image width
tagstruct.SamplesPerPixel = 1; % corresponds to nb of zstacks but set for each stack, so = 1
tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP; % for floating point datatype
tagstruct.Compression = Tiff.Compression.None;
tagstruct.Photometric = Tiff.Photometric.MinIsBlack; % test/investigate to see which one is better 
tagstruct.BitsPerSample = 64; % specific to double, uint64 or int64 datatypes
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software = 'MATLAB';

% tags for image resolution
tagstruct.XResolution = resolution ; 
tagstruct.YResolution = resolution ;
tagstruct.ResolutionUnit = Tiff.ResolutionUnit.Centimeter ;

zspacing = 0.5 ; %microns, for image metadata in Fiji 

newid=['ImageJ=1.51j' newline];
newid=[newid 'spacing=' num2str(zspacing)];

% for each stack, set tag and write to tif file
for i=1:slices
    setTag(t,tagstruct);
    setTag(t, 'ImageDescription', newid);
    write(t,imgdata(:,:,i));
    writeDirectory(t);
end
close(t)

end

% Other tags : 
% to see every Tag possibilities, write Tiff.getTagNames in command window
% to see every options for a specific tagID, write Tiff.tagID in command window, wont show if options are not constants or methods

%    {'Group3Options'         } use for Fax compression...
%    {'ExtraSamples'          } use for multiple channels
%    {'SGILogDataFmt'         } use for SGIL codec data format...
%    {'SubFileType'           } image type...
%    {'Thresholding'          }
%    {'Orientation'           } use for visual orientation but doesnt change how matlab writes image data

% Stripped layout — Set the RowsPerStrip tag.
% Tiled layout — Set the TileWidth and TileHeight tags.



% for n = 1:zstacks
%     if n == 1
%         imwrite(trdimg(:,:,1), filepath); 
%     else
%         imwrite(trdimg(:,:,n), filepath ,'writemode','append'); 
% 
%     end
% end

