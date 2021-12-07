# image_process

***aggreCount***: core code of spot detection, data is available on https://drive.google.com/file/d/1arLmZta4zRyWg_GWi_n65k3Fk8V60mG-/view?usp=sharing  
***:analysis_beta2***: code for Ru to do image process and analysis at the same time  
***:coIncidence***: code for checking coincidence between channels, data is available on https://drive.google.com/file/d/1DoxnzZP6AXE9TDnzBv2_1IXzj-3hV6mW/view?usp=sharing  
***:gaussianFit***: 2D gaussian fitting for spots (not used in aggreCount and analysis_beta2, which only use centroid fitting for finding position of tiny spots)  

***- 07/12/21 update***: simpler kernel function with only one input for determining kernel size and the maskfilter function is updated correspounding to kernel size (to eliminate auto-filling artefact during the convolution). Also, the newest intensity estimation with dilated signal mask is implemented
