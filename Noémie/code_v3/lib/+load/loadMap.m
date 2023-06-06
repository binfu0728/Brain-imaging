function [gain,offset] = loadMap(name,imsz)
    if nargin < 2
        imsz = [];
    end

    if ~isempty(name)
        load(['gain_',name,'.mat']); % loads gain and offset variables stored in camera folder
        load(['offset_',name,'.mat']);
    else
        gain   = ones(imsz);
        offset = zeros(imsz);
    end
end