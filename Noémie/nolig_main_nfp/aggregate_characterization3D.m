%% variables to set 
clear;
format shortG;

og_fulldepth = 17; % number of stacks in complete original raw image 
showw   = 0; % set to 1 to display volumes and scatter plot with skeleton - only to visualize a few aggregates
savefig = 1; % set to 1 to save png figures of the aggregates 

figfolder = "F:\NoemieFP_2023\ASAP Parkinsons Project\Data\Datasets\Middata\mid_rawdata_3D_figures\"; % folder where to save figures, make sure it ends with '\'
wsdir = 'C:\Users\Admin\Google Drive\POLY\Stages\WeissLab\Matlab';  % workspace directory
filedir   = 'F:\NoemieFP_2023\ASAP Parkinsons Project\Data\Datasets\Middata\mid_rawdata'; % data directory

%% prepare data 

% get image files
files = dir([filedir, '\**\Single aggregates\*.tif']); 
names     = {files.name}';
folders   = {files.folder}';
filenames = fullfile(folders,names);

% create parameters table 
tablesz  = [1 8];
varTypes = ["double", "double", "double", "double", "double", "double", "logical","logical"];
varNames = ["Fiber", "Elongation", "Volume", "Surface Area", "Extent", "Convexity","On_Zedge", "Regular_Fiber"];
param3D_all    = table('Size',tablesz,'VariableTypes',varTypes,'VariableNames',varNames);
param3D_all.Properties.DimensionNames = ["AggregateID","Parameters"];
param3D_all.Properties.VariableUnits = ['um','um', 'um^3', 'um^2', "", "","",""];

%% characterize every aggregate 

for k = 1:length(files)
    %% metadata
    
    filename = filenames{k};
    agg_id = erase(names{k}, '.tif');
    zedge = endsWith(agg_id, "zcut");

    % get agg tif file data 
    [width, height, depth, vox_width, vox_height, vox_depth] = aggmetadata(filename);
    agg_sz = [height, width, depth];
    
    % get aggregate 3D array
    agg = zeros(agg_sz);
    for i = 1:depth
        agg(:,:,i) = imread(filename,i);
    end

    % get volume data for later 
    vox_vol = vox_depth*vox_width*vox_height; % voxel volume
    tmpo = regionprops3(logical(agg), agg, "Volume");
    og_vol_wt = (tmpo.Volume)*vox_vol; % original agg volume with optimal thresh applied in extraction, analyzed aggregate
    og_vol_nt = 2*og_vol_wt; % original aggregate volume without optimal thresh applied in extraction, approx based on observations


    %% Interpolate data to right scale + filter

    [a,b,c] = ndgrid((1:height)*vox_height,(1:width)*vox_width,(1:depth)*vox_depth);
    F = griddedInterpolant(a,b,c,agg, 'linear','linear'); % create interpolating function 
    newdepth = round(depth*(vox_depth/vox_height)); % where voxdepth/voxheight gives voxel depth for 1:1 pixel size, assuming vox_height = vox_width
    [a1,b1,c1] = ndgrid((1:height)*vox_height,(1:width)*vox_height,(1:newdepth)*vox_height);
    newagg = F(a1,b1,c1); % at this point, all voxels in newagg are size 0.11x0.11x0.11 um (approximately)
    newagg (newagg < 0) = 0; % set negative values to zero 
    
    % get new voxel volume and side area
    newvoxVol = vox_height*vox_height*vox_height;
    newvoxArea = vox_height*vox_height;

    % interpolated aggregate filtering 
    [filt_agg, bwfilt_agg] = agg_3Dfiltering(agg, newagg, zedge, height, width, depth, newdepth, newvoxVol, og_fulldepth, og_vol_nt);
    
    %% get fiber length and elongation  
    
    % get skeleton
    min_br_len = round(0.3*max(size(filt_agg))); % set minimal skel length to discard branches that are too small
    skel = bwskel(bwfilt_agg,'MinBranchLength',min_br_len);

    % get coordinates of skeleton voxels
    idx = find (skel == 1);
    [ro_s, co_s, pl_s] = ind2sub(size(skel),idx);
    skel_coor = [ro_s, co_s, pl_s];

    % get skel endpoints
    ext = bwmorph3(skel,'endpoints');
    % get coordinates of endpoints
    ends = find (ext == 1);
    [ro_e, co_e, pl_e] = ind2sub(size(ext),ends);
    ends_coor = [ro_e, co_e, pl_e];

    % get aggregate's edges
    perim = bwperim(filt_agg,6);  

    % get fiber (extended skel) and new endpoints - step in process  
    if length(ends) == 2
        [fiber, extremities, regFib] = skel2fiber(bwfilt_agg, perim, skel, skel_coor, ends_coor);       
    else
        regFib = false;
        fiber = skel;
        extremities = zeros([2,3]);
    end
   
    % get fiber length
    voxfiber_length = sum(fiber, "all"); % in voxels
    fiber_length = voxfiber_length*vox_height; % in um
    
    % get elongation
    end1 = extremities(1,:);
    end2 = extremities(2,:);
    euclidist = sqrt( ((end2(2)-end1(2))^2) + ((end2(1)-end1(1))^2) + ((end2(3)-end1(3))^2)); % euclidean distance in voxels
    elong = euclidist / voxfiber_length; 
    
    
    %% get regionprops3 parameters 

    ccbwagg = bwconncomp(bwfilt_agg,26); % to use CC input for regionprops3, makes sure that conn = 26
    
    stats = regionprops3(ccbwagg, filt_agg, 'all');
    vol = (stats.Volume)*newvoxVol; % so the output volume is in um^3
    surfarea = (stats.SurfaceArea)*newvoxArea; % output area in um^2
    extent = stats.Extent; % ratio between agg volume and bounding box volume
    convexity = stats.Solidity; % ratio between agg volume and convexhull volume
    
    %% visualization and/or figure saving

    if showw == 1 | savefig == 1
        if showw == 1
            numfig = length(findobj('Type','figure'));
            if numfig > 15
                warning('!');
                disp('Lots of figures are open. You might want to set showw to 0')
                break
            end

            % display volume with fiber and box
            fig = uifigure;
            fig.Name = agg_id;
            viewer = viewer3d(fig,BackgroundColor="white", BackgroundGradient="off",Box="on",...
                Lighting="off", Position=[802.2,202.6,560,420],ScaleBar="on");
            see = volshow(filt_agg, Parent=viewer, RenderingStyle="VolumeRendering", OverlayData=fiber,...
                Alphamap=linspace(0,0.5,256),OverlayRenderingStyle="LabelOverlay", OverlayAlphamap=1,OverlayThreshold=0.99);
        end
        
        % scatter plotting with skeleton & fiber
        % get vox coordinates and intensities (cc), alphadata, alphashape surface (contour) and its coordinates for scatter plotting with contour
        [xx, yy, zz, cc, alphadata, contour, ctpos] = scatterdata(stats, perim, vox_height); 
        
        % get coordinates of fiber
        fiber_coor = find (fiber == 1);
        [ro_f, co_f, pl_f] = ind2sub(size(fiber),fiber_coor);
  
        % create figure and axe object
        f = figure;
        f.NumberTitle = 'off';
        f.Name = agg_id;
        ax = axobj(f, xx,yy,zz,k);

        % display
        hold(ax,"on")
        scatter3(xx,yy,zz,25,cc,'diamond','filled', 'AlphaData',alphadata,'MarkerFaceColor','flat','MarkerEdgeColor','flat' ,...
            'MarkerFaceAlpha','flat','MarkerEdgeAlpha','flat','AlphaDataMode','manual','AlphaDataMapping','none') %'ColorVariable',cc)
        cob = colorbar;
        cob.Label.String = 'Intensity';
        cob.Label.FontSize = 10;
        % add skeleton, fiber, endpoints and surface 
        hold on;
        scatter3(co_f*vox_height,ro_f*vox_height,pl_f*vox_height,15,"black","filled") % fiber
        scatter3(co_s*vox_height,ro_s*vox_height,pl_s*vox_height,15,[0 0.4470 0.7410],"filled") % skel
        scatter3(co_e*vox_height,ro_e*vox_height,pl_e*vox_height,15,"red", "diamond","filled") % skel endpoints
        scatter3(extremities(:,2)*vox_height, extremities(:,1)*vox_height, extremities(:,3)*vox_height, 20,[0.6350 0.0780 0.1840],"diamond","filled") % fiber endpoints
        trisurf(contour,ctpos(:,1),ctpos(:,2),ctpos(:,3),FaceColor=[0.2422, 0.1504, 0.6603],FaceAlpha=0.3,EdgeColor=[0.2422, 0.1504, 0.6603],EdgeAlpha=0.2) % surface 
        hold off
        hold(ax, "off")

        % disable display if only saving figures 
        if showw == 0
            set(f, 'Visible', 'off');
        end
        % save figure
        if savefig == 1
            exportgraphics(f, figfolder + "#"+ k +"-"+ agg_id + ".png","Resolution",300)
        end
    
    end
    

    %% save agg parameters in table 

    param3D_all(k,:) = {fiber_length, elong, vol, surfarea, extent, convexity, zedge, regFib};
    param3D_all.AggregateID(k) = {agg_id}; % format 'sampleRSID_agg_#' + '_zcut' if agg located on z edges 
    % to access row data : param(agg_id,:)

end

%% save parameters table
cd(wsdir); 
writetable(param3D_all,'agg_parameters_3D.xlsx', "WriteRowNames", true);

