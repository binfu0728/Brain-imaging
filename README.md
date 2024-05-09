# Brain sample image processing code

***code***: The formal version of the detection and analysis code

***- 09/05/24 update***: The RASP paper version is uploaded

***- 12/06/23 update***: update on the radiality (2 input, absolute magnitude and direction, 3 input, absolute magnitude, relative magnitude and  direction) and also rewrite centre finding for the radiality from find max to find weighted centroid. Also update on focus score, which takes the log value.

***- 31/05/23 update***: update on code v3 to integrate autofocus filtering and radiality fileting together

***- 14/05/23 update***: New gain and offset map for sCMOS camera on the sycamore microscope

***- 13/04/23 update***: update on defining radiality and add percentage thresholding to the code

***- 16/03/23 update***: v3 (with radiality) is uploaded. The parameter is only optimized for sycamore brain images. Not applicable to other images yet.

***- 16/03/23 update***: Update on the code to measure the background per oligomer

***- 06/03/23 update***: Update on sycamore camera gain

***- 22/02/23 update***: add minor axis length filtering to the colour segmentation.

***- 13/02/23 update***: Update on LB detection (faster)

***- 02/02/23 update***: Simplify and add more comments to the main functions

***- 18/01/23 update***: Fix a bug for metadata loading function.

***- 04/01/23 update***: guassianFit code is changed to a function file.

***- 13/12/22 update***: GUIv5 is uploaded. This is the first official version. Also, the code is updated from 4x upsampling to 1x upsampling. Lib is changed

***- 07/12/22 update***: Test GUI is uploaded and oligomer intensity estimation is updated

***- 23/10/22 update***: More comments is added to the v1.0 code. Metadata loading is optimized

***- 22/09/22 update***: The formal v1.0 is uploaded. It can detect both small and large aggregates and also some type of cells. The preset configurations for some types are uploaded as well 

***- 20/05/22 update***: gif image write is uploaded to gdc->lib->+load

***- 06/05/22 update***: Spatial analysis function is uploaded and util folder is changed into lib folder and functions are rearranged into diffferent subfolders

***- 03/05/22 update***: In-cell/Out-cell density calculation is uploaded and the detailed out-cell density calculation as well. All versions for oligomer detection except gdc is moved into old branch

***- 08/03/22 update***: configuration file and image loading method have been updated for loading all kinds of images by specifying its hyperstack structure. Also, main.m(gdc_v2_1.m) has been refactored to a cleaner version

***- 22/02/22 update***: configuration file of biscutella that is always used in sample imaging is uploaded

***- 02/02/22 update***: configuration file is saved in .json format for a more convenient way to change and load the configuration files. 

***- 21/01/22 update***: move some functions into util folder, so the gdc code is only a main.m code right now. plotScaleBar.m is added to util for any purposes of plotting a scale bar

***- 17/01/22 update***: GDC has been updated with loading parameters from a config file. The config file writing script is added to gdc folder as well. In the future, please save the used config in the config folder for repeatable analysis

***- 05/01/22 update***: The 1st complete version of generalized detection code, the structure of which has been refactored. The newer version of analysis_beta is uploaded with a newer version of the coincidence check. The new coincidence check method will have a slightly lower rate compared to the previous version. This version is capable of calculating the coincidence for both LB/LN and oligomers 

***- 20/12/21 update***: Fix the bug for intensity estimation with the dilation mask in gaussianFit, aggreCount and analysis_beta

***- 15/12/21 update***: The code for Generalized detection is uploaded. It is able to do part of IF staining and all of DAB staining at the moment with some maunally tuned parameters

***- 12/12/21 update***: update of the gaussian fit code with the new ability to estimate the rotational angle of a gaussian spot

***- 07/12/21 update***: simpler kernel function with only one input for determining kernel size and the maskfilter function is updated correspounding to kernel size (to eliminate auto-filling artefact during the convolution). Also, the newest intensity estimation with dilated signal mask is implemented
