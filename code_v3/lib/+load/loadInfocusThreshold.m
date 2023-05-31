function [t_differential,t_integral] = loadInfocusThreshold(name)
    switch name
        case 'sycamore'
            t_differential = abs(load(['focusScore_aggregate_',name,'.mat']).epsilon);
            t_differential = prctile(t_differential,12.5);
            t_integral = 60; %determine from data, might put the algorithm here sometimes later
        otherwise
            t_differential = 0;
            t_integral     = 0;
    end
end