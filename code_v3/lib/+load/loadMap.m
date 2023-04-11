function [gain,offset] = loadMap(name,imsz)
    if nargin < 2
        imsz = [];
    end

    if ~isempty(name)
        load(['gain_',name,'.mat']);
        load(['offset_',name,'.mat']);
    else
        gain   = ones(imsz);
        offset = zeros(imsz);
    end
end