function filepath = extractPath(filepath,pos) 
% input  : filepath, the path where the result/image is saved
%          pos, the position of the slash, the thing after which will be extracted
% 
% output : filepath, the extracted filepath

    idx = strfind(filepath,'\');
    filepath = filepath(idx(pos)+1:end);
end