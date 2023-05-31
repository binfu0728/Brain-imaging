function [oligomer_result,non_oligomer_position,non_oligomer_intensity,numbers] = BW2table(img,centroids,ndlMask,z,information)
    if nargin < 5
        information = [0 0 0];
    end
    oligomer_result        = []; %x,y,z,intensity,background,rsid,grid,position
    non_oligomer_position  = []; %x,y,z,rsid,grid,position
    non_oligomer_intensity = []; %intensity,background,z,rsid,grid,position
    numbers = zeros(size(img,3),5); %oligomer_nums,non_oligomer_nums,rsid,grid,position
    
    imsz = size(img);
    structure = strel('disk',4);

    for i = z(1):z(2)
        zimg = img(:,:,i);

        % diffraction-limited object analysis
        if ~isempty(centroids{i})  
            [esti_inten,esti_bg] = core.oligomerIntensityEstimation(zimg,centroids{i});
            tmpt_oligomer = [centroids{i},repmat(i,size(centroids{i},1),1),esti_inten,esti_bg]; %x,y,z,intensity,background,rsid
        else
            tmpt_oligomer = []; %x,y,z,intensity,background
        end
        oligomer_result = [oligomer_result;tmpt_oligomer];
        
        % non-diffraction limited object analysis
        L   = bwlabel(ndlMask(:,:,i), 8);
        pil = bwconncomp_2d(ndlMask(:,:,i),8); %pixelindexlist for each binary object
        boundaries  = images.internal.builtins.bwboundaries(L, 8); %boundary in cell format
        boundaries2 = cell2mat(boundaries); %boundary in double format
        bg_ndl      = zeros(size(boundaries,1),1);
        ity_ndl     = zeros(size(boundaries,1),1);
        bg_zimg     = imfill2d(zimg,ndlMask(:,:,i),structure);
    
        for k = 1:size(boundaries,1)
            sub = boundaries{k}; %row,col
            boundaries_ind = core.sub2ind2d(imsz(1:2),sub(:,1),sub(:,2));
            bg_ndl(k)  = mean(bg_zimg(boundaries_ind));
            ity_ndl(k) = sum(zimg(pil{k})-bg_ndl(k)); 
        end
        
        if ~isempty(boundaries2)
            tmpt_non_oligomer_position  = [boundaries2,repmat(i,size(boundaries2,1),1)]; %x,y,z
            tmpt_non_oligomer_intensity = [ity_ndl, bg_ndl, repmat(i,size(boundaries,1),1)]; %intensity,background,z
        else
            tmpt_non_oligomer_position  = []; %x,y,z
            tmpt_non_oligomer_intensity = []; %intensity,background,z
        end
        non_oligomer_position  = [non_oligomer_position;tmpt_non_oligomer_position];
        non_oligomer_intensity = [non_oligomer_intensity;tmpt_non_oligomer_intensity];

        % number analysis
        numbers(i,:) = [size(centroids{i},1),size(boundaries,1),information];
    end

    oligomer_result        = [oligomer_result,repmat(information,size(oligomer_result,1),1)];
    non_oligomer_position  = [non_oligomer_position,repmat(information,size(non_oligomer_position,1),1)];
    non_oligomer_intensity = [non_oligomer_intensity,repmat(information,size(non_oligomer_intensity,1),1)];
end

%%
function img = imfill2d(img,ndlMask,structure)
    imsz    = size(img);
    ndlMask = ~imdilate(ndlMask,structure);
    pil     = bwconncomp_2d(~ndlMask,8);
    boundaries = images.internal.builtins.bwboundaries(bwlabel(~ndlMask, 8), 8); %boundary in cell format
    for i = 1:size(boundaries,1)
        sub = boundaries{i}; %row,col
        boundaries_ind = core.sub2ind2d(imsz,sub(:,1),sub(:,2));
        img(pil{i})    = min(img(boundaries_ind));
    end
end

function [pixelIdxList,numObjects] = bwconncomp_2d(BW,mode)
    %BWCONNCOMP_2D Label connected components in 2-D binary image.
    %   BWCONNCOMP_2D(BW,mode) is called by bwconncomp to get the linear indices of
    %   pixels in each region and the total number of regions (objects) in each
    %   image.
    %
    %   No error checking.  Done by bwconncomp. BW must be 2-D.  mode can be 4 or 8.
    
    %   Copyright 2008-2020 The MathWorks, Inc.
    
    [startRow,endRow,startCol,labelForEachRun,numObjects] = labelBinaryRuns(BW,mode);
    
    runLengths = endRow - startRow + 1;
    
    subs = [labelForEachRun(:), ones(numel(labelForEachRun), 1)];
    objectSizes = accumarray(subs, runLengths);
    
    pixelIdxList = images.internal.builtins.pixelIdxLists(size(BW),numObjects,objectSizes,startRow,...
                                 startCol,labelForEachRun,runLengths);
end

function [startRow,endRow,startCol,labelForEachRun,numComponents] = labelBinaryRuns(BW,mode)
    %labelBinaryRuns is used by bwlabel and bwconncomp_2d. 
    %   The inputs are a 2D binary image BW and the connectivity MODE. There is no
    %   error checking in this code.  BW must be a 2D binary image and MODE must be
    %   4 or 8.
    %
    %   The outputs are:
    %   startRow        - starting Row subscript of the run.
    %   endRow          - last Row subscript of the run.
    %   startCol        - starting Col of the run.
    %   labelForEachRun - label associated with each run.
    %   numComponents   - number of Connected Components in BW.
    %
    %   startRow, endRow, startCol, and labels are vectors of the same size.
    
    % Copyright 2008-2020 The MathWorks, Inc.
    
    % Reference - See the "Connected Components" category in Steve Eddins' blog.
    % http://blogs.mathworks.com/steve/2007/03/20/connected-component-labeling-part-3/
    
    
    % The variable labelForEachRun is the initial labels for each run. However, some labels may be
    % equivalent to one another. The variables, i & j indicate which pairs of labels
    % are equivalent.  For example, i(k) and j(k) tell you that those labels (and in
    % turn those runs) point to different pieces of the same object.
    
    [startRow,endRow,startCol,labelForEachRun,i,j] = images.internal.builtins.bwlabel1(BW,mode);
    if (isempty(labelForEachRun))
        numInitialLabels = 0;
    else
        numInitialLabels = max(labelForEachRun);
    end
    
    % Create a sparse matrix representing the equivalence graph.
    tmp = (1:numInitialLabels)';
    A = sparse([i;j;tmp], [j;i;tmp], 1, numInitialLabels, numInitialLabels);
    
    % Determine the connected components of the equivalence graph
    % and compute a new label vector.
    
    % Find the strongly connected components of the adjacency graph
    % of A.  dmperm finds row and column permutations that transform
    % A into upper block triangular form.  Each block corresponds to
    % a connected component; the original source rows in each block
    % correspond to the members of the corresponding connected
    % component.  The first two output% arguments (row and column
    % permutations, respectively) are the same in this case because A
    % is symmetric.  The vector r contains the locations of the
    % blocks; the k-th block as indices r(k):r(k+1)-1.
    [tmp,p,r] = dmperm(A);
    
    % Compute vector containing the number of elements in each
    % component.
    sizes = diff(r);
    
    % Number of connected components after equivalence class resolution.
    numComponents = length(sizes);  
    
    blocks = zeros(1,numInitialLabels);
    blocks(r(1:numComponents)) = 1;
    blocks = cumsum(blocks);
    blocks(p) = blocks;
    labelForEachRun = blocks(labelForEachRun);
end