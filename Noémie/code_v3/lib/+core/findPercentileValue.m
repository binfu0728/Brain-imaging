function m = findPercentileValue(counts,percentile,range) %counts input is a 2D img when called by aggregateDetection
    if nargin == 3
        counts  = counts(range(1):range(2),range(1):range(2)); % to apply percentile value to square of 401 to 800 x and y coordinates values (given range of [401 800] for 1200x1200 pixels images)
    end
    counts  = sort(counts(:));
    highend = round(length(counts)*(1-percentile));
    m = counts(highend);
end