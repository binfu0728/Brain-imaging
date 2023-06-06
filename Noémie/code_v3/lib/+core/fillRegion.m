function BW = fillRegion(imsz,idxToKeep)
    idxToKeep = vertcat(idxToKeep{:}); % displays all values in the nx1 matrices in a single column
    BW        = false(imsz);
    BW(idxToKeep) = true;
end