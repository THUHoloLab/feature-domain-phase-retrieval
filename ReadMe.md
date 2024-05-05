[toc]

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
The feature-domain likelihood is the core of FAIRY, which is established on image's feature extracted by invertible feature-extracting operators. As the image's feature is the inherent properties of image which is more robust to image degrading than image itself.<br>
<br>
The complex gradient given by the likelihood block and constrain block is calculated based on current estimation of model parameters, and is further managed by the optimizer to update the parameters and accelerate the gradient descent progress, just like the way when training a neural network. <br>
<br>
Given the non-convex, non-linear property of the loss function, the FAIRY bears resemblance to training a deep neural network in a supervised manner, in which the target wavefront is learned from a series of intensity observations by minimizing the loss function through complex back-propagation. Intricate feature-domain likelihood function can be tackled by FAIRY as long as the function is differentiable. Fruitful optimization/learning strategies in field of deep learning are further adapted for wavefront recovery. <br>
<br>

## Results
### 1. Phase retrieval under unknown aberrations
The following GIF shows how FAIRY implementation of a Fourier ptychography experiment which retrieves the phase pattern of a quantitative phase target together with the aberration of the pupil function. <br>
Sample codes and data are available in [FAIRY-FPM](https://github.com/THUHoloLab/FAIRY/tree/main/Demo/Fourier%20ptychography) <br>
<div align = 'center'>
<img src = "https://github.com/THUHoloLab/FAIRY/blob/main/Demo/resource/newfile_record-min.gif" width = "400" alt="" align = center />
</div><br>

<br>
<br>

### 2. Recovery with arbitrary constrains
We conduct experiment using single-shot phase retrieval for in-line holography to show the flexibility of FAIRY in combination of different types of constrains. <br>

<br>
<div align = 'center'>
<img src = "https://github.com/THUHoloLab/FAIRY/blob/main/Demo/resource/Holograohy.png" width = "700" alt="" align = center />
</div><br>

<br>

Single-shot phase retrieval from in-line holography. **(a)** sketch of the optical set. **(b)** Evolve of loss function for GS and FAIRY methods, and the intermediate results of FAIRY in certain iterations. **(c)** Montage of results from GS algorithm and FAIRY. **(d1)**, **(d2)** Zoomed-in pictures for area in the blue box in **(c)**. **(e)** The quantitative phase profile for **(d1)** and **(d2)** along the with line in **(d1)**. **(f1)**, **(f2)** Zoomed-in pictures for area in the green box in **(c)**, with additional results constrained by guided filter. **(g)** Comparison of the SSIM and PSNR of among three results. **(h)** The quantitative phase profile along the yellow curve in **(f1)**. <br>


