function BW = fillRegion(imsz,idxToKeep)
    idxToKeep = vertcat(idxToKeep{:});
    BW        = false(imsz);
    BW(idxToKeep) = true;
end