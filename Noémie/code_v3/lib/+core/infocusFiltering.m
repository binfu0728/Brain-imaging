function z = infocusFiltering(focusScore,t_differential)
    dist1  = diff(focusScore); %euclidean distance between each slice
    dist1(dist1<=0) = nan; 
    dist1 = [0;dist1>t_differential]; %mSSDBSCAN from start

    dist2 = diff(flip(focusScore)); %euclidean distance between each slice
    dist2 = [0;dist2<t_differential]; %mSSDBSCAN from end

    dist1 = diff(dist1);
    dist2 = diff(dist2);
    
    zi = find(dist1==-1);  
    zf = find(dist2==1); 

    if isempty(zi); zi = 1; end %first slice is in focus
    if isempty(zf); zf = length(focusScore); end %last slice in focus

    zi = zi(1); zf = length(focusScore)-zf(end)+1;
    z  = [zi,zf];
end


