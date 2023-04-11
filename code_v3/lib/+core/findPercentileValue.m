function m = findPercentileValue(counts,percentile)
    counts  = sort(counts(:));
    highend = round(length(counts)*(1-percentile));
    m = counts(highend);
end