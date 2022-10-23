function ids = cell2rsid(rr,ss)
% input  : rr, a cell containing which round will be used, e.g., {3,8}
%          ss, a cell with the same length as the number of elements in the rr to show which sample is used in a round, e.g., {{1,2,3,4,5,6},{2,3,4,5,6,7}}
% 
% output : ids, the rsid for the used subset

    ids = [];
    for i = 1:length(rr)
        ids = [ids,rr{i} + 0.01.*[ss{i}{:}]];
    end
end