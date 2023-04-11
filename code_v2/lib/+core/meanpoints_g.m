function Nr = meanpoints_g(r,DIST,rbox,dr)
    Nr = zeros(size(r)); %mean number of datapoints for each radius (mean number = density * area in CSR(complete spatial random))
    for k = 1:length(r) %Edge correction method
            I = find(rbox>r(k)); %numer of datapoints containing the full circle within the box
        if ~isempty(I)
            Nr(k) = sum(sum(DIST(2:end,I)<(r(k)+dr/2) & DIST(2:end,I)>(r(k)-dr/2)))/length(I);
        end
    end
end