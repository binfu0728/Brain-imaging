
data = readmatrix('non_oligomer_result.csv', 'HeaderLines', 1); % headers are x,y,z,rsid

test_duplicates = 0;

% Extract rsids
agg_rsid = data(:, 4);
[rsids, ind_1stvals, samplenum] = unique(agg_rsid); 
nb_of_samples = length(rsids); % nb of samples that appear in non oligo result, not necessarily nb of all samples

samples_exagg = []; % to save samples with extracted aggregates

for i = 4%1:nb_of_samples
    % identify sample's data location in the csv file
    ze = zeros(size(samplenum));
    ze(samplenum == i) = 1;
    nb_pixels = sum(ze); 
    firstind = ind_1stvals(i);
    lastind = firstind + nb_pixels - 1;

    % get original image (after gain and offset applied in main_aggregate)
    imgfile_id = string(rsids(i));
    imgfile = strcat('image_', imgfile_id,'.mat');
    loadedimg = load(imgfile); % could also access it by running main_aggregate (run fct)
    og_img = loadedimg.img; % original image 

    imsz = size(og_img);
    width = imsz(1);
    height = imsz(2);
    
    % discard 2D samples
    if length(imsz) < 3
        continue % maybe add something to display error / 2D sample
    end
    depth = imsz(3);

    % create folder where tif files will be saved 
    metadata = readtable('test_metadata.csv','VariableNamingRule','preserve');
    filenames = metadata.filenames;
    [filepath,names,~] = fileparts(filenames);
    all_rsid = metadata.rsid;
    % get right sample id
    sid=0;
    for t = 1:length(all_rsid)
        if all_rsid(t)==rsids(i)
            sid = t;
            break
        else
            continue
        end
    end
    filed = string(filepath(sid)); % sample directory 
    newfolderpath = strcat(filed, '\Single aggregates');
    if ~exist(newfolderpath, 'dir')
        mkdir(newfolderpath); 
    end

    % save samples that reach this step - samples with extracted aggregates
    samples_exagg = [samples_exagg; filed]

    % extract pixels' coordinates where there are aggregates 
    xvals = data(firstind:lastind, 1);
    yvals = data(firstind:lastind, 2);
    zvals = data(firstind:lastind, 3);
    coord = [xvals, yvals, zvals];

    % test if there are duplicates in coord - for previous problem solved
    if test_duplicates == 1
        see = [];
        for q = 1:szcoord(1)
            test = coord(q, :);
            see = [see; test];
        end
        [notdup,in] = unique(see(:,1:3), 'rows');
        % notdupsz = size(notdup)
    end

    % create 3D binary mask of where there are aggregates 
    agg_mask = zeros(imsz);
    for j = 1:size(coord, 1)
        x = coord(j, 1);
        y = coord(j, 2);
        z = coord(j, 3);
        agg_mask(y, x, z) = 1;
    end

    % label each aggregate 
    conn = 26; % 3D connection parameter
    labeled_mask = bwlabeln(agg_mask, conn);
  
    % discard aggregates on xy planes' edges and outputs lists with saved agg labels
    [agg_labels, agg_onZedges] = agg_edge_check(labeled_mask, imsz);
    all_agg_labels = sort(horzcat(agg_labels, agg_onZedges));
    
    % To display plot of nb of voxels per aggregate to determine voxel threshold
    % Conclusion : Having visualized some aggregates member of agg_onZedges, most appear relevant and they are too many to not consider them.
    %        Function agg_continuity is to be written and will discard those on edges for which the image seems to include less than 80% of the aggregate or so
    %        Voxel threshold for all_agg_labels seems reasonable at value 1000, according to plots
    %
    % X = []; % nb of aggregates 
    % Y = []; % nb of voxels
    % 
    % for ii = 1: length(all_agg_labels) % change all_agg_labels with agg_labels or agg_onZedges to see these plots
    %     X = [X, ii];
    %     lab = all_agg_labels(ii);
    %     nb_voxels = sum((labeled_mask == lab), 'all');
    %     Y = [Y, nb_voxels];
    % end
    % Y = sort(Y);
    % figure, plot(X,Y)
    % xlabel('aggregates'); ylabel('voxels'); title('all agg labels');

    voxel_threshold = 1000; 

    single_agg_idx_insample = []; % to save single aggs' indices 

    for k = 1: length(all_agg_labels)
        g = all_agg_labels(k);
        agg_id = string(g);

        labeled_mask_object = zeros(imsz);
        labeled_mask_object(labeled_mask == g) = 1; % creates binary mask for each aggregate 
        CC = bwconncomp(labeled_mask_object,conn); % to use CC input for regionprops3, makes sure that conn comp is the same as in bwlabeln instead of relying on regionprops detected connected components
        
        % discard aggregates under certain volume
        if sum(labeled_mask_object,'all') < voxel_threshold 
            continue 
        end


        % get single aggregate properties
        props = regionprops3(CC, 'BoundingBox');
        boundBox = props.BoundingBox; % outputs [upleftfront_x, upleftfront_y, upleftfront_z, width_x, width_y, width_z]
        boundingBox = [(boundBox(:,1:3) + 0.5), (boundBox(:,4:6) - 1)]; % 'BoundingBox' extends coordinates by 0.5 pixels so adding 0.5 gives the right coordinates

        % crop og_img and mask to boundingBox and invert mask to get average surrounding pixel intensity
        cropped_og = imcrop3(og_img, boundingBox);
        cropped_mask = imcrop3(labeled_mask, boundingBox); % using mask of all non oligo to keep only background

        cropped_img_inv_mask = cropped_og;
        cropped_img_inv_mask(cropped_mask >= 1) = 0;
        avbg_intens = mean((nonzeros(cropped_img_inv_mask)), 'all'); % average background intensity

        % substract background from og_img
        adj_img = og_img - avbg_intens;
        adj_img(adj_img < 0) = 0; % set negative values to 0

        % apply mask to adj_img before cropping 
        img_masked = adj_img ;
        img_masked (labeled_mask_object == 0) = 0;

        % refind boundingBox because intensity adjustment adds zeros 
        sagg = bwareaopen((img_masked > 0), 10, conn); % gets rid of small conncomps that got isolated in previous step - could go deeper using quartiles or mean deviation, etc.
        [labeled_sagg_parts, nn] = bwlabeln(sagg, conn);
        cc = bwconncomp(labeled_sagg_parts, conn);
        % apply new mask without isolated voxels to adj_img
        img_masked = adj_img ;
        img_masked(sagg == 0) = 0;

        % if any, disconnected larger components should now be considered as separate single aggregates
        if nn > 1
            % identify aggregates on z edges
            [sagg_labels, sagg_onZedges] = agg_edge_check(labeled_sagg_parts, imsz);
            
            for s = 1:nn
                nid = string(nn);
                agg_id = strcat(agg_id, '.', nid);

                labl_im = zeros(imsz);
                labl_im(sagg == s) = 1;

                img_mask = labl_im .*img_masked; % original size array with new mask applied to isolate aggregate 

                % test if aggregate seems to continue outside of original img size 
                if any(ismember(nn,sagg_onZedges))
                    missing_part = agg_continuity(labl_im, img_mask);
                    if missing_part == 1
                        agg_id = strcat(agg_id, '_zcut'); 
                    end
                end
                % get new bounding box 
                cc = bwconncomp(labl_im, conn);
                props2 = regionprops3(cc, 'BoundingBox', 'VoxelList');
                boundBox2 = props2.BoundingBox;
                boundingBox2 = [(boundBox2(:,1:3) + 0.5), (boundBox2(:,4:6) - 1)];
                
                % save [x y z id] aggregate positions relative to whole sample
                pos = cell2mat(props2.VoxelList);
                agg_idd = (repelem(agg_id, length(pos)))';
                sagg_result = [pos, agg_idd]; % change to save only average position or center of mass/intensity
                single_agg_idx_insample = [single_agg_idx_insample; sagg_result]; 

                % crop 3d image 
                single_agg = imcrop3(img_mask, boundingBox2);         
                
                % save 3d image in tif file, doesnt rewrite file if filename already exists 
                agg_tiffile_save(single_agg, newfolderpath, imgfile_id, agg_id) 
            end
            
        else
            % test if aggregate seems to continue outside of original img size 
            if any(ismember(g,agg_onZedges))
                missing_part = agg_continuity(labeled_sagg_parts, img_masked);
                if missing_part == 1
                    agg_id = strcat(agg_id, 'zcut'); 
                end
            end
            % get new bounding box 
            props2 = regionprops3(cc, 'BoundingBox', 'VoxelList');
            boundBox2 = props2.BoundingBox;
            boundingBox2 = [(boundBox2(:,1:3) + 0.5), (boundBox2(:,4:6) - 1)];
            
            % save [x y z id] aggregate positions relative to whole sample
            pos = cell2mat(props2.VoxelList);
            agg_idd = (repelem(agg_id, length(pos)))';
            sagg_result = [pos, agg_idd]; % change to save only average position or center of mass/intensity
            single_agg_idx_insample = [single_agg_idx_insample; sagg_result]; 

            % crop 3d image 
            single_agg = imcrop3(img_masked, boundingBox2);         
            
            % save 3d image in tif file, doesnt rewrite file if filename already exists 
            agg_tiffile_save(single_agg, newfolderpath, imgfile_id, agg_id) 
        end

   end
   
   % save csv file with single aggregates positions in og_img
   Tagg = array2table(single_agg_idx_insample, "VariableNames",{'x','y','z','agg_id'});
   fname = strcat(newfolderpath,'\','aggregates_positions_', imgfile_id, '.csv');
   writetable(Tagg,fname);

end







