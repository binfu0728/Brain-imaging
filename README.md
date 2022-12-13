# Brain sample imaging processing code

***code***: The formal version of the detection and analysis code

***gaussianFit***: 2D gaussian fitting for spots

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

***17-26 round***: c1 - 488nm, c2 - 568nm, c3 - 405nm

***10-11 & 14-16 round***: c1 - 568nm, c2 - 405nm, c3 - 488nm

***12-13 round***: c1 - 568nm, c2 - 488nm
