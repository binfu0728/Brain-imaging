# LB/LN/Oligomer in brain sample - process and analysis code

## Two version are included in the code. 1st is the std threshold version used in gaussianFit aggreCount and analysis_beta. 2nd version is gdc version using the new generalized detection code.

***aggreCount***: The old and robust version of aggregation count. Can be applied to any oligomer sample

***analysis_beta***: code for Ru to do image process and analysis at the same time 

***gaussianFit***: 2D gaussian fitting for spots (not used in aggreCount and analysis_beta2, which only use centroid fitting for finding position of tiny spots)  

***Generalized_Detection***: Detection of all wanted objects in an image (LB/LN and oligomers), test data is available on https://drive.google.com/drive/folders/19_O6kN9VP3fTC4ojEN2GLmOfWxAyi7Op?usp=sharing (40x DAB) https://drive.google.com/drive/folders/1yfgqH0mEew9aJCVtZm60o0jNY7s1mvE6?usp=sharing (100X DAB) and https://drive.google.com/drive/folders/1Dee7lvrtHVo-BF1yYEvEsOKVt9doDGJd?usp=sharing (40X IF). 40x IF, 40x & 100x DAB are from 25th round data, 100x IF is from 24th round data

***- 07/12/21 update***: simpler kernel function with only one input for determining kernel size and the maskfilter function is updated correspounding to kernel size (to eliminate auto-filling artefact during the convolution). Also, the newest intensity estimation with dilated signal mask is implemented

***- 12/12/21 update***: update of the gaussian fit code with the new ability to estimate the rotational angle of a gaussian spot

***- 15/12/21 update***: The code for Generalized detection is uploaded. It is able to do part of IF staining and all of DAB staining at the moment with some maunally tuned parameters

***- 20/12/21 update***: Fix the bug for intensity estimation with the dilation mask in gaussianFit, aggreCount and analysis_beta

***- 05/01/22 update***: The 1st complete version of generalized detection code, the structure of which has been refactored. The newer version of analysis_beta is uploaded with a newer version of the coincidence check. The new coincidence check method will have a slightly lower rate compared to the previous version. This version is capable of calculating the coincidence for both LB/LN and oligomers 
