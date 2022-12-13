function [nums_z,inten_z,inten_i] = longFormatting(smalls,larges,z,rsid,s)
% input  : lists, centroid of small aggregates  
%          BWs, boundaries of large aggregates  
%          z is zi & zf, 
%          rsid, the correspounding rsid for this image stack, a single value 
%          s, configuration file
% 
% output : nums_z, number per slice
%          inten_z, intensity per slice
%          inten_i, intensity per oligomer

    nums_z  = zeros(length(z(1):z(2)),length(smalls)+length(larges)+1); %repo for averaged numbers per slice with n columns where n is the number of all input small and large aggregates result
    inten_z = zeros(length(z(1):z(2)),length(smalls)+1); %repo for averaged intensity per slice with n columns where n is the number of all input small aggregates (oligomers)
    inten_i = cell(1,length(smalls)); %repo for intensity per oligomer in long format
    inten_t = cell(length(z(1):z(2)),length(smalls)); %tmpt holder

    nums_z(:,end)  = repmat(rsid,length(z(1):z(2)),1);
    inten_z(:,end) = repmat(rsid,length(z(1):z(2)),1);
    
    for j = 1:length(z(1):z(2))
        nums_z(j,1:length(smalls)+length(larges))  = core.numberAnalysis(smalls,larges,j,s);
        [inten_z(j,1:length(smalls)),inten_t(j,:)] = core.intensityAnalysis(smalls,j); 
    end

    nums_z(:,end)  = repmat(rsid,length(z(1):z(2)),1);
    inten_z(:,end) = repmat(rsid,length(z(1):z(2)),1);
    for i = 1:length(smalls)
        tmpt       = vertcat(inten_t{:,i});
        inten_i{i} = [tmpt,repmat(rsid,size(tmpt,1),1)]; %concat the intensity per oligomer into the long format
    end
end