% Characterization of aggregates in 2D for comparison with 3D analysis
%   Aggregates analyzed here are from each slice of the extracted 3D aggregates which 
%       have been connected with 26 connectivity and processed with a voxel threshold, 
%       optimal threshold of mean(avbg+avfg) and pixel (voxel) intensity adjustments based on bg 
%   Therefore, some slices may contain multiple 2D connected components, which will be 
%       analyzed as separate aggregates for shape characterization 

clear;
format shortG;

%% variables to set 

show_sep   = 0; % set to 1 to display figure with separated 2D sub aggregates for each 3D aggregate - with skeleton
show_slices = 0; % set to 1 to display figure with slices of 3D aggregate
savefig = 1; % set to 1 to save png figures of the aggregates 

figfolder = "F:\NoemieFP_2023\ASAP Parkinsons Project\Data\Datasets\Middata\mid_rawdata_2D_figures\"; % folder where to save figures, make sure it ends with '\'
wsdir = 'C:\Users\Admin\Google Drive\POLY\Stages\WeissLab\Matlab'; % workspace directory
filedir   = 'F:\NoemieFP_2023\ASAP Parkinsons Project\Data\Datasets\Middata\mid_rawdata'; % data directory

%% prepare data 

% get image files 
files = dir([filedir, '\**\Single aggregates\*.tif']); 
names     = {files.name}';
folders   = {files.folder}';
filenames = fullfile(folders,names);

% create parameters table 
tablesz  = [1 9];
varTypes = ["double", "double", "double", "double", "double", "double","logical" ,"logical", "double"];
varNames = ["Fiber", "Elongation", "Area", "Circumference", "Extent", "Convexity","On_edge", "Regular_Fiber", "Circularity"];
param2D_all    = table('Size',tablesz,'VariableTypes',varTypes,'VariableNames',varNames);
param2D_all.Properties.DimensionNames = ["SubAggregateID","Parameters"];
param2D_all.Properties.VariableUnits = ['um','um', 'um^2', 'um', "", "","","",""];

%% characterization
agg_num = 1; % to keep aggregate count 
b = 0; 

for k = 1:length(files)
    %% aggregate tif file metadata
    
    filename = filenames{k};
    agg_id = erase(names{k}, '.tif');

    % get agg tif file data 
    [width, height, depth, pix_width, pix_height,~] = aggmetadata(filename);
    pix_area = pix_width*pix_height;
    agg_sz = [height, width, depth];
    slice_edges = [1, height, 1, width]; %[first row, last row, first col, last col]
    
    % create figure for separate sub agg 
    if show_sep == 1 | savefig == 1
        f = figure;
        f.NumberTitle = 'off';
        f.Name = agg_id;
        f.Units = "inches";
        f.OuterPosition = [0, 0.5, 13, 7];
        t = tiledlayout(f,"flow","TileSpacing","compact");
    end

    % create figure for slices 
    if show_slices == 1 | savefig == 1
        fig = figure;
        fig.NumberTitle = 'off';
        fig.Name = agg_id;
        fig.Units = "inches";
        fig.OuterPosition = [0, 0.5, 13, 7];%[0.25, 0.25, 8, 6];
        tl = tiledlayout(fig,"flow","TileSpacing","compact"); 
    end

    %% looping the aggregate's slices 

    for i = 1:depth
        % get 2D image
        slice = imread(filename,i);
        slice_id = agg_id + "_s" + i;

        % separate different connected components
        bwslice = logical(slice);
        ccbwslice = bwconncomp(bwslice,8);
        numcomp = ccbwslice.NumObjects;
        labslice = bwlabel(bwslice, 8);

        istats = regionprops(ccbwslice,slice, "all");

        % add slice to slice figure
        if show_slices == 1 | savefig == 1
            if show_slices == 1
                numfig = length(findobj('Type','figure'));
                if numfig > 15
                    warning('!');
                    disp('Lots of figures are open. You might want to set show settings to 0')
                    b = 1;
                    break
                end
            end
            % get data for scatter plotting
            [ro_i, co_i, cc_i] = find(slice);
            xx_i = co_i*pix_width; % to have microns for axes units
            yy_i = ro_i*pix_height;

            ax_i = nexttile(tl);
            ax_i.XLim = [0, ceil(width*pix_width)];
            ax_i.XTick = [linspace(0, ceil(width*pix_width),(ceil(width*pix_width)+1))];
            ax_i.XLabel.String = 'x (um)';
            ax_i.XGrid = 'off';            
            ax_i.YLim = [0, ceil(height*pix_height)];
            ax_i.YTick = [linspace(0,ceil(height*pix_height),(ceil(height*pix_height)+1))];
            ax_i.YLabel.String = 'y (um)';
            ax_i.YGrid = 'off';
            ax_i.DataAspectRatio = [1 1 1];
            ax_i.Title.String = "Slice " + i;
            % display
            hold(ax_i,"on")
            scatter(xx_i,yy_i,20,cc_i,'o','filled')
            cob_i = colorbar;
            cob_i.Label.String = 'Intensity';
            cob_i.Label.FontSize = 10;
            hold(ax_i, "off")
        end


        %% looping the distinct components in a slice 

        for o = 1:numcomp
            % Identify sub aggregate
            if numcomp == 1
                sub_agg_id = slice_id + "_SAU"; % U for unique 
            else
                sub_agg_id = slice_id + "_SA" + o;
            end
            
            % skip too small sub aggregates
            numpix = istats(o).Area;
            if numpix < 5
                continue
            end

            % get og area for later
            sub_og_area_wt = numpix*pix_area; % linked to original agg volume with opt thresh applied in extraction, analyzed aggregate
            sub_og_area_nt = 2*sub_og_area_wt; % based on original aggregate volume without opt thresh applied in extraction, approx based on observations

            % get cropped agg 
            sub_bbox = istats(o).BoundingBox;
            bbox = [(sub_bbox(:,1:2) + 0.5), (sub_bbox(:,3:4)-1)];
            sub_agg = slice;
            sub_agg(labslice ~= o) = 0;
            sub_agg = imcrop(sub_agg,bbox);

            % check if sub agg is on xy edge
            aggedges = [bbox(2), bbox(2)+bbox(4), bbox(1), bbox(1)+bbox(3)]; % [first row, last row, first col, last col]
            edgematch = [slice_edges == aggedges]; % gives 1 if any boundary (given by bbox) matches image boundaries
            
            % filtering
            [On_edge, sub_agg_id, filt_agg, bwfilt_agg] = agg_2Dfiltering(sub_agg, sub_agg_id, edgematch, sub_og_area_nt, pix_area);
     

            %% get fiber length and elongation  
            
            % get skeleton
            min_br_len = round(0.3*max(size(filt_agg))); % set minimal skel length to only keep long branches
            skel = bwskel(bwfilt_agg,'MinBranchLength',min_br_len);
        
            % get coordinates of skeleton pixels
            idx = find (skel == 1);
            [ro_s, co_s] = ind2sub(size(skel),idx);
            skel_coor = [ro_s, co_s];
        
            % get skel endpoints
            ext = bwmorph(skel,'endpoints');
            % get coordinates of endpoints
            ends = find (ext == 1);
            [ro_e, co_e] = ind2sub(size(ext),ends);
            ends_coor = [ro_e, co_e];
        
            % get aggregate's edges
            perim = bwperim(filt_agg, 4);
        
            % get fiber (extended skel) and new endpoints - step in process
            if length(ends) == 2
                [fiber, extremities, regFib] = skel2fiber(bwfilt_agg, perim, skel, skel_coor, ends_coor);       
            else
                regFib = false;
                fiber = skel;
                extremities = zeros([2,2]);
            end
           
            % get fiber length
            pixfiber_length = sum(fiber, "all"); % in voxels
            fiber_length = pixfiber_length*pix_height; % in um
            
            % get elongation
            end1 = extremities(1,:);
            end2 = extremities(2,:);
            euclidist = sqrt( ((end2(2)-end1(2))^2) + ((end2(1)-end1(1))^2) ); % euclidean distance in voxels
            elong = euclidist / pixfiber_length; 


            %% get regionprops parameters 

            ccbwagg = bwconncomp(bwfilt_agg, 8); % to use CC input for regionprops3, makes sure that conn = 8
            stats = regionprops(ccbwagg, filt_agg, 'all');
            
            area        = (stats.Area)*pix_area; % so the output area is in um^2
            perimeter   = (stats.Perimeter)*pix_height; % output perim in um
            extent      = stats.Extent; % ratio between agg area and bounding box area
            convexity   = stats.Solidity; % ratio between agg area and convexhull area
            circularity = stats.Circularity; % to classify aggregates ? not used yet

            %% visualization for separate aggregates

            if show_sep == 1 | savefig == 1    
                if show_sep == 1
                    numfig = length(findobj('Type','figure'));
                    if numfig > 15
                        warning('!');
                        disp('Lots of figures are open. You might want to set show settings to 0')
                        b = 1;
                        break
                    end
                end

                % get pixel coordinates for scatter plotting
                P = stats.PixelList;
                cc = stats.PixelValues;
                coor = P*pix_height; % to have microns for axes units
                xx = coor(:,1);
                yy = coor(:,2);
      
                % get coordinates of fiber
                fiber_coor = find (fiber == 1);
                [ro_f, co_f] = ind2sub(size(fiber),fiber_coor);            
   
                % scatter plotting with skeleton & fiber                
                ax = nexttile(t);

                ax.XLim = [0, ceil(max(xx))];
                ax.XTick = [linspace(0,ceil(max(xx)),(ceil(max(xx))+1))];
                ax.XLabel.String = 'x (um)';
                ax.XGrid = 'off';               
                ax.YLim = [0, ceil(max(yy))];
                ax.YTick = [linspace(0,ceil(max(yy)),(ceil(max(yy))+1))];
                ax.YLabel.String = 'y (um)';
                ax.YGrid = 'off';       
                ax.DataAspectRatio = [1 1 1];
                ax.Title.String = "SubAgg "+ agg_num + ", Slice " + i;

                % display
                hold(ax,"on")
                scatter(xx,yy,25,cc,'o','filled') % display aggregate
                cob = colorbar;
                cob.Label.String = 'Intensity';
                cob.Label.FontSize = 8;
                % add skeleton, fiber, endpoints and surface
                hold on;
                scatter(co_f*pix_height,ro_f*pix_height,25,"black","filled") % fiber
                scatter(co_s*pix_height,ro_s*pix_height,15,[0 0.4470 0.7410],"filled") % skel
                scatter(co_e*pix_height,ro_e*pix_height,15,"red", "diamond","filled") % skel endpoints
                scatter(extremities(:,2)*pix_height, extremities(:,1)*pix_height, 20,[0.6350 0.0780 0.1840],"diamond","filled") % fiber endpoints
                hold off
                hold(ax, "off")  
            end

            %% save agg parameters in table 

            param2D_all(agg_num,:) = {fiber_length, elong, area, perimeter, extent, convexity, On_edge, regFib, circularity};
            param2D_all.SubAggregateID(agg_num)= {char(sub_agg_id)}; % format 'sampleRSID_agg_#' + '_zcut' if agg located on z edges 
            % to access row data : param(agg_id,:)

            agg_num = agg_num + 1;
        end

    end
    
    % disable display & save figures according to settings    
    if (show_sep == 0 & savefig == 1) | b == 1
        set(f, 'Visible', 'off');
    end
    if (show_slices == 0 & savefig == 1) | b == 1
        set(fig, 'Visible', 'off');
    end
    if savefig == 1 & b == 0
        exportgraphics(f,figfolder + "#"+ k +"-"+ agg_id +"_SA" +".png","Resolution",300)
        exportgraphics(fig,figfolder + "#"+ k +"-"+ agg_id +"_slices" +".png","Resolution",300)
    end
    if b == 1
        break
    end

end

%% save parameters table
cd(wsdir); 
writetable(param2D_all,'agg_parameters_2D.xlsx', "WriteRowNames", true);


