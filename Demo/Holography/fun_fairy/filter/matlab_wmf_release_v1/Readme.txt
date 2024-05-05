
***********************************************************************************************************
***********************************************************************************************************

Matlab demo code for "Constant Time Weighted Median Filtering for Stereo Matching and Beyond" (ICCV 2013)

by Ziyang Ma (maziyang08@gmail.com)

If you use/adapt our code in your work (either as a stand-alone tool or as a component of any algorithm),
you need to appropriately cite our ICCV 2013 paper.

This code is for academic purpose only. Not for commercial/industrial activities.


NOTE:

  The running time reported in the paper is from C++/CUDA implementation. This Matlab version is a re-
implementation, and is for the ease of understanding the algorithm. This code is not optimized, and the 
speed is not representative. The result can be slightly different from the paper due to transferring
across platforms.


***********************************************************************************************************
***********************************************************************************************************


Usage:

demo_stereo_refine.m - demonstrate the stereo refinement using weighted_median_filter.m
demo_jpeg.m - demonstrate the JPEG artifact removal using weighted_median_filter_approx.m

Functions:

weighted_median_filter.m - weighted median filter implementation (Sec 2.3 in the paper)
weighted_median_filter_approx.m - an approximated version for general-purpose filtering using downsampling