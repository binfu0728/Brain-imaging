function m = findPercentileRange(counts,percentile)
    counts  = sort(counts(:));
    lowend  = round(length(counts)*(1-percentile(1)));
    highend = round(length(counts)*(1-percentile(2)));
    m       = counts(lowend:highend);
end