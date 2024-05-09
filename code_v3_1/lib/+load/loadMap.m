function [gain,offset] = loadMap(name,z,imsz)
    if nargin < 3
        imsz = [];
    end

    if ~isempty(name)
        gain = load(['gain_',name,'.mat']).gain;
        offset = load(['offset_',name,'.mat']).offset;
    else
        gain   = ones(imsz);
        offset = zeros(imsz);
    end

    gain    = repmat(gain,[1 1 z]);
    offset  = repmat(offset,[1 1 z]);
end