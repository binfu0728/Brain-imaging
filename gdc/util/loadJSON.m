function s = loadJSON(filename)
    fname = filename; 
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    s = jsondecode(str);
end
