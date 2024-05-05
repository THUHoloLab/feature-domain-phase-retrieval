<div align = 'center'>
<img src = "https://github.com/THUHoloLab/FAIRY/blob/main/Demo/resource/figure_core.png" width = "800" alt="" align = center />
</div><br>

# FAIRY: Feature-domain optimization with Arbitrary constrains for Intensity-based wavefront RecoverY
<br>
This is the MATLAB code for implementation of FAIRY, an optimization framework for intensity-based wavefront recovery. <br>
<br>
FAIRY is a wavefront retrieval engine that recovers for a broad class of wavefront through unique non-convex, high-dimensional, feature-domain optimization with arbitrary constrains. <br>
<br>
Optimizations of the non-convex loss function are regarded as supervised-learning, solved by complex-backpropagation. <br>
<br>


## Contents
This repository contains the implementation of FAIRY for two wavefront tasks which are <br>
**(1) Computational holography** <br>
**(2) Feature-domain Fourier ptychography** <br>
<br>
<br>

## How does it works?
The flowchart of FAIRY is depicted in the title figure, where the loss function for wavefront recovery comprises two blocks: <br>
(1) The first block is the feature-domain augmented likelihood block that uniquely maximizes the data likelihood in image's feature-domain.<br>
(2) The second block is the constrain block which implements extended-HIO (eHIO), providing plug-and-play interfaces for arbitrary customized constraints.<br>
<br>
The feature-domain likelihood is the core of FAIRY, which is established on image's feature extracted by invertible feature-extracting operators. As the image's feature is the inherent properties of image which is more robust to image degrading than image itself.
