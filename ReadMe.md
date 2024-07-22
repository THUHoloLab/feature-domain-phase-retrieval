<div align = 'center'>
<img src = "https://github.com/THUHoloLab/FAIRY/blob/main/Demo/resource/figure_core.png" width = "800" alt="" align = center />
</div><br>

# Perceptual phase retrieval: ascension from image domains to feature domains
<br>
This is the MATLAB code for implementation of PPR, an optimization framework for intensity-based wavefront recovery. <br>
<br>
Perceptual phase retrieval is a wavefront retrieval engine that recovers for a broad class of wavefront through unique non-convex, high-dimensional, feature-domain optimization with arbitrary constrains. <br>
<br>
Optimizations of the non-convex loss function are regarded as supervised-learning, solved by complex-backpropagation. <br>
<br>
<br>

## Contents
This repository contains the implementation of PPR for two wavefront tasks which are <br>
**(1) Feature-domain Fourier Ptychography** <br>
**(2) Coded Ptychography** <br>
**(3) Computational Holography** <br>

- [Perceptual phase retrieval: ascension from image domains to feature domains](#fairy--feature-domain-optimization-with-arbitrary-constraints-for-intensity-based-wavefront-recovery)
  * [Contents](#contents)
  * [How does it work?](#how-does-it-work-)
    + [Feature-domain likelihood](#feature-domain-likelihood)
    + [Extended Hybrid input-output (eHIO) modulus for Plug-and-Play constraints](#extended-hybrid-input-output--ehio--modulus-for-plug-and-play-constraints)
    + [Learning the wavefronts using Optimizers](#learning-the-wavefronts-using-optimizers)
  * [Results](#results)
    + [1. Phase retrieval under unknown aberrations](#1-phase-retrieval-under-unknown-aberrations)
    + [2. Coded ptychography](#2-coded-ptychography)
    + [3. Recovery with arbitrary constraints](#3-recovery-with-arbitrary-constraints)
<br>
<br>
## How does it work?
The PPR begins with a general task for wavefront recovery, where one or a series of intensity measurements (observation, ob), $\mathbf{I}_1^{obs}, \mathbf{I}_2^{obs}, \dots \mathbf{I}_n^{obs}, \dots, \mathbf{I}_N^{obs}, (n = 1, 2, 3, \dots)$ were collected, with the corresponding image formation model (forward model)
```math
\mathbf{I}_n = \text{Degrading}\left( \sum_{m=1}^{M} \left| \mathbf{A}_{n,m}\mathbf{x}  \right|^2 \right)
```
<br>

describing the image formation progress of the optical system. $\text{Degrading}( \cdot)$ denotes arbitrary corrupt processes. $\mathbf{x}$ is the target wavefront to be recovered. The matrix $\mathbf{A}_{n,m}$ denotes a known linear process that converts the complex amplitude $\mathbf{x}$ to the $n$-th intensity measurement. <br>
<br>

It is assumed that the final measured intensity is the summation of several intensity (a total of $M$) of incoherent waves, where $M$ can be a function of $n$. 
<br>
<br>
The flowchart of PPR is depicted in the title figure, where the loss function for wavefront recovery comprises two blocks: <br>
(1) The first block is the feature-domain augmented likelihood block that uniquely maximizes the data likelihood in image's feature-domain.<br>
(2) The second block is the constraint block which implements extended-HIO (eHIO), providing plug-and-play interfaces for arbitrary customized constraints.<br>
<br>

### Feature-domain likelihood
The **feature-domain likelihood** is the core of PPR, which is established on image's feature extracted by invertible feature-extracting operators. The idea is that the image's feature is the inherent properties of image which is more robust to image degrading than image itself.With the feature-domain information, the likelihood function can better utilize the data, improving the robustness of recovery algorithm. <br>
<br>

```math
{\Large \mathcal{L}_{Likelihood} = \mathcal{D} \left [ \mathbf{\Theta} \mathcal{S} \left(\mathbf{I}_n^{obs}\right),\ \mathbf{\Theta}\mathcal{S}\left( \mathbf{I}_n^{pre} \right) \right ]}
```
<br>

where $\mathbf{I}_{n}$ is the model predicted intensity. $\mathcal{D}(\mathbf{x},\mathbf{y}), \mathcal{D} \ge 0$ denotes an arbitrary differentiable likelihood or fidelity function measuring the \textit{distance} between the model prediction $\mathbf{x}$ and observation $\mathbf{y}$. $\mathcal{S}(\mathbf{x})$ is a scaling operation that adjusts the dynamics range of prediction and observations. $\mathbf{\Theta}$ is an manually-selected invertible feature extraction operator. <br>
<br>

### Extended Hybrid input-output (eHIO) modulus for Plug-and-Play constraints
<div align = 'center'>
<img src = "https://github.com/THUHoloLab/FAIRY/blob/main/Demo/resource/eHIO.png" width = "600" alt="" align = center />
</div><br>

The PPR framework incorporates the extended HIO, serving as a generalized Gerchberg-Saxton (GS) algorithm. The GS alternates between object and Fourier domain constraints to minimize the error between prediction and observation. If the object-domain constraints was treated as the likelihood-optimization, it would be natural to treat the Fourier-domain constraints as the prior/penalty-optimization. <br>
<br>
Further, the HIO isolates the penalty-optimization, and introduces customized constraints based on physical conditions, such as area shape support or intensity dynamic range thresholding. <br>
<br>
In PPR, we optimize the likelihood using complex back-propagation, treating $\mathbf{x}^{t}$ as the input and $\mathbf{x}^{t+1}$ as the output after each gradient step. By reintroducing HIO, we insert custom constraints on $\mathbf{x}$ during gradient descent, leading to a refined penalty function that enhances the reconstruction quality.<br>
<br>
<div align = 'center'>
<img src = "https://github.com/THUHoloLab/FAIRY/blob/main/Demo/resource/ptycho.gif" width = "800" alt="" align = center />
</div><br>
<div align = 'center'>
Ptychography reconstruction. <br> Top left: PPR + TV; Top right: PPR + Second-order TV; Bottom left: PPR + Median filter; Bottom right: WASP.<br>
</div><br>
<br>

The animation shows PPR on Ptychography with different denoisers including TV-denoiser, Second-order TV denoiser, and Median filter. The results are compared with [WASP](https://github.com/andyMaiden/SheffieldPtycho). 

### Learning the wavefronts using Optimizers 
The complex gradient given by the likelihood block and constraint block is calculated based on current estimation of model parameters, and is further managed by the optimizer to update the parameters and accelerate the gradient descent progress, just like the way when training a neural network. <br>
<br>
Given the non-convex, non-linear property of the loss function, the **PPR bears resemblance to training a deep neural network in a supervised manner**, in which the target wavefront is learned from a series of intensity observations by minimizing the loss function through complex back-propagation. Intricate feature-domain likelihood function can be tackled by PPR as long as the function is differentiable. Fruitful optimization/learning strategies in field of deep learning are further adapted for wavefront recovery. <br>
<br>
- For information of optimizers please refer [Optimizing gradient descent](https://www.ruder.io/optimizing-gradient-descent/). <br>
- For Python implementation of optimizers please refer [Optimizers](https://github.com/pytorch/pytorch/tree/main/torch/optim/). <br>
- Usually, the optimizers are designed for real-valued variables and cannot be directly applied to complex-variable in our case, a little modifications to the codes of the optimizers are needed, please refer [this discussion](https://github.com/pytorch/pytorch/issues/59998).
<br>
<br>

## Results
### 1. Phase retrieval under unknown aberrations
The following GIF shows how PPR implementation works for a Fourier ptychography experiment, which retrieves the phase pattern of a quantitative phase target together with the aberration of the pupil function. <br>
Sample codes and data are available in [PPR-FPM](https://github.com/THUHoloLab/FAIRY/tree/main/Demo/Fourier%20ptychography) <br>
<div align = 'center'>
<img src = "https://github.com/THUHoloLab/FAIRY/blob/main/Demo/resource/newfile_record-min.gif" width = "400" alt="" align = center />
</div><br>
<br>
<br>

### 2. Coded ptychography
The PPR can be applied to Coded ptychography as well. Data can be found in [DATA](https://zenodo.org/records/7492626). For PPR, the user needs first save all image file to .tif format in a foler named 'raw_data', then you can select a specific area for reconstruction. <br>
<br>
Please refer this [PAPER](https://www.nature.com/articles/s41596-023-00829-4) for the implementation of codes and data.<br>
<br>
<br>

### 3. Recovery with arbitrary constraints
We conduct experiment using single-shot phase retrieval for in-line holography to show the flexibility of PPR in combination of different types of constrains. <br>

<br>
<div align = 'center'>
<img src = "https://github.com/THUHoloLab/FAIRY/blob/main/Demo/resource/Holograohy.png" width = "700" alt="" align = center />
</div><br>

<br>

Single-shot phase retrieval from in-line holography. **(a)** sketch of the optical set. **(b)** Evolve of loss function for GS and PPR methods, and the intermediate results of PPR in certain iterations. **(c)** Montage of results from GS algorithm and PPR. **(d1)**, **(d2)** Zoomed-in pictures for area in the blue box in **(c)**. **(e)** The quantitative phase profile for **(d1)** and **(d2)** along the with line in **(d1)**. **(f1)**, **(f2)** Zoomed-in pictures for area in the green box in **(c)**, with additional results constrained by guided filter. **(g)** Comparison of the SSIM and PSNR of among three results. **(h)** The quantitative phase profile along the yellow curve in **(f1)**. <br>


