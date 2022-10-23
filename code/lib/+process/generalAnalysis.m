function [nums_z,inten_z,inten_i,coloc_z] = generalAnalysis(lists,BWs,z,rsid,ref,s)
% input  : lists, centroid of small aggregates  
%          BWs, centroid of large aggregates  
%          z is zi & zf, 
%          rsid, the correspounding rsid for this image stack, a single value 
%          ref, the reference channel used to find the coincidence, a single number
%          s, configuration file
% 
% output : nums_z, number per slice
%          inten_z, intensity per slice
%          inten_i, intensity per oligomer
%          coloc_z, coincidence per slice 

    if nargin<5 %if no input config file (mainly for compatible purpose)
        ref = [];
        s.width   = 2048;
        s.height  = 2048; 
    end

    nums_z  = zeros(length(z(1):z(2)),length(lists)+length(BWs)+1); %repo for averaged numbers per slice with n columns where n is the number of all input small and large aggregates result
    inten_z = zeros(length(z(1):z(2)),length(lists)+1); %repo for averaged intensity per slice with n columns where n is the number of all input small aggregates (oligomers)
    inten_i = cell(1,length(lists)); %repo for intensity per oligomer in long format
    inten_t = cell(length(z(1):z(2)),length(lists)); %tmpt holder
    coloc_z = zeros(length(z(1):z(2)),5); %coloc_large,chance_large,coloc_small,chance_small,rsid

    for j = 1:length(z(1):z(2))
        nums_z(j,1:length(lists)+length(BWs))     = analyze.numberAnalysis(lists,BWs,z(1)+j-1,s);
        [inten_z(j,1:length(lists)),inten_t(j,:)] = analyze.intensityAnalysis(lists,z(1)+j-1); 
        if ~isempty(ref) %if coincidence check is used
            small1           = lists{1}; small1 = load.centroid2BW(round(small1(small1(:,end)==z(1)+j-1,2:3)),s); %convert oligomer result (centroid) into binart mask (nxn, defined by config)
            small2           = lists{2}; small2 = load.centroid2BW(round(small2(small2(:,end)==z(1)+j-1,2:3)),s); %convert oligomer result (centroid) into binart mask (nxn, defined by config)
            large1           = BWs{1};   large1 = load.boundary2BW(large1(large1(:,end)==z(1)+j-1,1:2),s,1); %convert large aggregates result (bounadry) into binary mask (nxn, defined by config)
            large2           = BWs{2};   large2 = load.boundary2BW(large2(large2(:,end)==z(1)+j-1,1:2),s,1); %convert large aggregates result (bounadry) into binary mask (nxn, defined by config)
            [~,coloc_z(j,1)] = process.findCoincidence(large1,large2,ref);
            [~,coloc_z(j,2)] = process.findCoincidence(large1,imrotate(large2,90),ref);
            [~,coloc_z(j,3)] = process.findCoincidence(small1,small2,ref);
            [~,coloc_z(j,4)] = process.findCoincidence(small1,imrotate(small2,90),ref);

        end
    end
    nums_z(:,end)  = repmat(rsid,length(z(1):z(2)),1);
    inten_z(:,end) = repmat(rsid,length(z(1):z(2)),1);
    coloc_z(:,end) = repmat(rsid,length(z(1):z(2)),1);
    for i = 1:length(lists)
        tmpt       = vertcat(inten_t{:,i});
        inten_i{i} = [tmpt,repmat(rsid,size(tmpt,1),1)]; %concat the intensity per oligomer into the long format
    end
end