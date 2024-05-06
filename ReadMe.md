<div align = 'center'>
<img src = "https://github.com/THUHoloLab/FAIRY/blob/main/Demo/resource/figure_core.png" width = "800" alt="" align = center />
</div><br>

# FAIRY: Feature-domain optimization with Arbitrary constraints for Intensity-based wavefront RecoverY
<br>
This is the MATLAB code for implementation of FAIRY, an optimization framework for intensity-based wavefront recovery. <br>
<br>
FAIRY is a wavefront retrieval engine that recovers for a broad class of wavefront through unique non-convex, high-dimensional, feature-domain optimization with arbitrary constrains. <br>
<br>
Optimizations of the non-convex loss function are regarded as supervised-learning, solved by complex-backpropagation. <br>
<br>

- [FAIRY: Feature-domain optimization with Arbitrary constraints for Intensity-based wavefront RecoverY](#fairy--feature-domain-optimization-with-arbitrary-constraints-for-intensity-based-wavefront-recovery)
  * [Contents](#contents)
  * [How does it works?](#how-does-it-works-)
  * [Results](#results)
    + [1. Phase retrieval under unknown aberrations](#1-phase-retrieval-under-unknown-aberrations)
    + [2. Recovery with arbitrary constraints](#2-recovery-with-arbitrary-constraints)

<br>
<br>

## Contents
This repository contains the implementation of FAIRY for two wavefront tasks which are <br>
**(1) Feature-domain Fourier Ptychography** <br>
**(2) Coded Ptychography** <br>
**(3) Computational Holography** <br>

<br>

## How does it works?
The flowchart of FAIRY is depicted in the title figure, where the loss function for wavefront recovery comprises two blocks: <br>
(1) The first block is the feature-domain augmented likelihood block that uniquely maximizes the data likelihood in image's feature-domain.<br>
(2) The second block is the constraint block which implements extended-HIO (eHIO), providing plug-and-play interfaces for arbitrary customized constraints.<br>
<br>

### Feature-domain likelihood
The **feature-domain likelihood** is the core of FAIRY, which is established on image's feature extracted by invertible feature-extracting operators. The idea is that the image's feature is the inherent properties of image which is more robust to image degrading than image itself.With the feature-domain information, the likelihood function can better utilize the data, improving the robustness of recovery algorithm. <br>
<br>

'''math
\mathcal{L}_\text{Likelihood} = \mathcal{D}\left [ \mathbf{\Theta} \mathcal{S} \left(\mathbf{I}_n^{obs}\right),\ \mathbf{\Theta}\mathcal{S}\left( \mathbf{I}_n^{pre} \right) \right ],\ \mathbb{C}^{K_{in}}\longrightarrow \mathbb{R}^{\ge 0}
'''


### Extended Hybrid input-output (eHIO) modulus for Plug-and-Play constraints
<div align = 'center'>
<img src = "https://github.com/THUHoloLab/FAIRY/blob/main/Demo/resource/eHIO.png" width = "600" alt="" align = center />
</div><br>

The FAIRY framework incorporates the extended HIO, serving as a generalized Gerchberg-Saxton (GS) algorithm. The GS alternates between object and Fourier domain constraints to minimize the error between prediction and observation. If the object-domain constraints was treated as the likelihood-optimization, it would be natural to treat the Fourier-domain constraints as the prior/penalty-optimization. <br>
<br>
Further, the HIO isolates the penalty-optimization, and introduces customized constraints based on physical conditions, such as area shape support or intensity dynamic range thresholding. <br>
<br>
In FAIRY, we optimize the likelihood using complex back-propagation, treating $\mathbf{x}^{t}$ as the input and $\mathbf{x}^{t+1}$ as the output after each gradient step. By reintroducing HIO, we insert custom constraints on $\mathbf{x}$ during gradient descent, leading to a refined penalty function that enhances the reconstruction quality.<br>
<br>
<div align = 'center'>
<img src = "https://github.com/THUHoloLab/FAIRY/blob/main/Demo/resource/ptycho.gif" width = "800" alt="" align = center />
</div><br>
<div align = 'center'>
Ptychography reconstruction. <br> Top left: FAIRY + TV; Top right: FAIRY + Second-order TV; Bottom left: FAIRY + Median filter; Bottom right: WASP.<br>
</div><br>
<br>

The animation shows FAIRY on Ptychography with different denoisers including TV-denoiser, Second-order TV denoiser, and Median filter. The results are compared with [WASP](https://github.com/andyMaiden/SheffieldPtycho). 

### Learning the wavefronts using Optimizers 
The complex gradient given by the likelihood block and constraint block is calculated based on current estimation of model parameters, and is further managed by the optimizer to update the parameters and accelerate the gradient descent progress, just like the way when training a neural network. <br>
<br>
Given the non-convex, non-linear property of the loss function, the **FAIRY bears resemblance to training a deep neural network in a supervised manner**, in which the target wavefront is learned from a series of intensity observations by minimizing the loss function through complex back-propagation. Intricate feature-domain likelihood function can be tackled by FAIRY as long as the function is differentiable. Fruitful optimization/learning strategies in field of deep learning are further adapted for wavefront recovery. <br>
<br>
- For information of optimizers please refer [Optimizing gradient descent](https://www.ruder.io/optimizing-gradient-descent/). <br>
- For Python implementation of optimizers please refer [Optimizers](https://github.com/pytorch/pytorch/tree/main/torch/optim/). <br>
- Usually, the optimizers are designed for real-valued variables and cannot be directly applied to complex-variable in our case, a little modifications to the codes of the optimizers are needed, please refer [this discussion](https://github.com/pytorch/pytorch/issues/59998).





## Results
### 1. Phase retrieval under unknown aberrations
The following GIF shows how FAIRY implementation works for a Fourier ptychography experiment, which retrieves the phase pattern of a quantitative phase target together with the aberration of the pupil function. <br>
Sample codes and data are available in [FAIRY-FPM](https://github.com/THUHoloLab/FAIRY/tree/main/Demo/Fourier%20ptychography) <br>
<div align = 'center'>
<img src = "https://github.com/THUHoloLab/FAIRY/blob/main/Demo/resource/newfile_record-min.gif" width = "400" alt="" align = center />
</div><br>
<br>
<br>

### 2. Phase retrieval under unknown aberrations

<br>
<br>

### 3. Recovery with arbitrary constraints
We conduct experiment using single-shot phase retrieval for in-line holography to show the flexibility of FAIRY in combination of different types of constrains. <br>

<br>
<div align = 'center'>
<img src = "https://github.com/THUHoloLab/FAIRY/blob/main/Demo/resource/Holograohy.png" width = "700" alt="" align = center />
</div><br>

<br>

Single-shot phase retrieval from in-line holography. **(a)** sketch of the optical set. **(b)** Evolve of loss function for GS and FAIRY methods, and the intermediate results of FAIRY in certain iterations. **(c)** Montage of results from GS algorithm and FAIRY. **(d1)**, **(d2)** Zoomed-in pictures for area in the blue box in **(c)**. **(e)** The quantitative phase profile for **(d1)** and **(d2)** along the with line in **(d1)**. **(f1)**, **(f2)** Zoomed-in pictures for area in the green box in **(c)**, with additional results constrained by guided filter. **(g)** Comparison of the SSIM and PSNR of among three results. **(h)** The quantitative phase profile along the yellow curve in **(f1)**. <br>


