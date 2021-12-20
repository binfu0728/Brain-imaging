# LB/LN/Oligomer in brain sample - process and analysis code

***aggreCount***: core code of spot detection, test data is available on https://drive.google.com/file/d/1arLmZta4zRyWg_GWi_n65k3Fk8V60mG-/view?usp=sharing  
***analysis_beta***: code for Ru to do image process and analysis at the same time  
***coIncidence***: code for checking coincidence between channels, test data is available on https://drive.google.com/file/d/1DoxnzZP6AXE9TDnzBv2_1IXzj-3hV6mW/view?usp=sharing  
***gaussianFit***: 2D gaussian fitting for spots (not used in aggreCount and analysis_beta2, which only use centroid fitting for finding position of tiny spots)  
***Generalized_Detection***: LB/LN detection in black-white DAB staining image, test data is available on https://drive.google.com/drive/folders/19_O6kN9VP3fTC4ojEN2GLmOfWxAyi7Op?usp=sharing (40x DAB) https://drive.google.com/drive/folders/1yfgqH0mEew9aJCVtZm60o0jNY7s1mvE6?usp=sharing (100X DAB) and https://drive.google.com/drive/folders/1Dee7lvrtHVo-BF1yYEvEsOKVt9doDGJd?usp=sharing (40X IF)

***- 07/12/21 update***: simpler kernel function with only one input for determining kernel size and the maskfilter function is updated correspounding to kernel size (to eliminate auto-filling artefact during the convolution). Also, the newest intensity estimation with dilated signal mask is implemented

***- 12/12/21 update***: update of the gaussian fit code with the new ability to estimate the rotational angle of a gaussian spot

***- 15/12/21 update***: The code for Generalized detection is uploaded. It is able to do part of IF staining and all of DAB staining at the moment with some maunally tuned parameters

***- 20/12/21 update***: Fix the bug for intensity estimation with the dilation mask in gaussianFit, aggreCount and analysis_beta
