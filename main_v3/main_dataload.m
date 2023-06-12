clc;clear;addpath(genpath('C:\Users\bf341\Desktop\code_v3\')); %path where you download the code

filedir           = 'D:\sycamore_compare_2\'; %main directory where you have the data (above round)
T                 = core.makeMetadata(filedir);
filenames         = T.filenames;

%%
writetable(T,'test_metadata.xlsx');
