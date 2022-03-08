clc;clear; 
files                = dir([pwd,'\*.json']);
filename = {files.name}';

for ii = 1%:length(files)
    s = loadJSON(filename{ii});
    
end