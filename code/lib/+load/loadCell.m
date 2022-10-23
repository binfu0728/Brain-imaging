function c = loadCell(filename)
    t = readcell(filename);
    c = cell(size(t,1),1);
    for i = 1:size(t,1)
        tmpt = rmmissing([t{i,:}]);
        tmpt = reshape(tmpt,length(tmpt)/2,2);
        c{i} = tmpt;
    end
end