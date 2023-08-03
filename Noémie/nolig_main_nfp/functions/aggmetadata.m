function [width, height, depth, voxpix_width, voxpix_height, voxpix_depth] = aggmetadata(filename)
% get metadata and scale info of aggregate
% function can be called by whether 'aggregate_characterization3D.m' or 'aggregate_characterization2D.m'
% voxpix variables are whether voxel or pixel data

metadata = imfinfo(filename);
width = metadata.Width;
height = metadata.Height;
depth = length(metadata);

% get resolution info 
resUnit = metadata.ResolutionUnit;
xres = metadata.XResolution; % = nb of pixels / res unit 
yres = metadata.YResolution;

switch resUnit
    case 'Centimeter'
        xres_um = xres/10000;
        yres_um = yres/10000;
    case 'Micron'
        xres_um = xres;
        yres_um = yres;
end

voxpix_width = 1/xres_um;
voxpix_height = 1/yres_um;

% set vox depth if 3D characterization
call = dbstack(1,"-completenames"); 
callingscript = call.name; % script that calls this function

if contains(callingscript, "3D")
    imgdesc = metadata.ImageDescription; % char, where spacing between z slices in microns is specified, metadata written in aggregate_extraction.m
    voxpix_depth = str2double(extractAfter(imgdesc,'spacing=')); 
    
elseif contains(callingscript, "2D")
    voxpix_depth = 0;

end

end