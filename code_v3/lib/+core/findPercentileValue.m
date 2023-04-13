function m = findPercentileValue(counts,percentile,range)
    if nargin == 3
        counts  = counts(range(1):range(2),range(1):range(2));
    end
    counts  = sort(counts(:));
    highend = round(length(counts)*(1-percentile));
    m = counts(highend);
end