<h1 style="display: flex; align-items: center; gap: 0.4em; flex-wrap: nowrap; margin-bottom: 0.6em; border-bottom: none;">
  <a href="https://ortools4mtex.github.io/ORTools/" style="text-decoration: none; display: flex; align-items: baseline; gap: 0;">
    <span style="color: #d32f2f; font-weight: 900; font-style: normal;">OR</span><span style="color: #555; font-style: italic; font-weight: 400;">Tools</span>
  </a>
  <span style="font-weight: 400; color: #555; font-style: normal;">— a companion toolbox for</span>
  <a href="https://mtex-toolbox.github.io/index" style="display: flex; align-items: center;">
    <img src="https://mtex-toolbox.github.io/images/icons/MTEX_100x67px.png" alt="MTEX" style="height: 1.1em; width: auto; vertical-align: middle; display: inline-block;">
  </a>
</h1>

![matlab compatible](https://img.shields.io/badge/matlab-compatible-lightgrey.svg)  ![GitHub top language](https://img.shields.io/github/languages/top/ORTOOLS4MTEX/ORTools)

**Orientation relationship tools** (**ORTools**) is a function library for OR discovery, advanced OR analysis and the plotting of visually stunning and informative publication-ready figures particular to microstructures undergone partial/full martensitic transformation or OR-related phase transition. 

The **ORTools** function library is written in [**MATLAB**](https://mathworks.com/products/matlab.html) and is used as an add-on to the basic phase transformation functionalities within the MATLAB-based crystallographic toolbox [**MTEX**](https://mtex-toolbox.github.io). Due to their specific nature, the scripts contained in the **ORTools** library have not been included in MTEX. You may want to watch this [talk by Frank Niessen](https://youtu.be/B0faPjtOdmA) at the 2021 MTEX Workshop for an introduction to the phase transformation features in MTEX and **ORTools**. 

The advanced OR discovery, analysis and plotting functionalities of the **ORTools** library are highlighted in a series of [example scripts](examples.md) that showcase how the functions work and what their output comprises. 

To help maintain the **ORTools** library, please report any bugs you encounter in the [discussions board](https://github.com/ORTools4MTEX/ORTools/discussions). If you would like to contribute additional functionalities or wish to suggest new features that help improve it, please [submit an issue](https://github.com/ORTools4MTEX/ORTools/issues) or [open a discussion](https://github.com/ORTools4MTEX/ORTools/discussions).

<iframe width="560" height="315" src="https://www.youtube.com/embed/inkR6LBzFeQ" title="ORTools - Short video introduction" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[*A short introduction to ORTools*](https://youtu.be/inkR6LBzFeQ)

## How to use ORTools
![GitHub forks](https://img.shields.io/github/forks/ORTools4MTEX/ORTools)  ![GitHub Repo stars](https://img.shields.io/github/stars/ORTools4MTEX/ORTools)  ![GitHub watchers](https://img.shields.io/github/watchers/ORTools4MTEX/ORTools)  ![GitHub followers](https://img.shields.io/github/followers/ORTools4MTEX)  

- The ORTools library only works **after** the prior installation of [MATLAB](https://se.mathworks.com/help/install/install-products.html) and [**MTEX**](https://mtex-toolbox.github.io/).   
   - Follow the instructions for installing [MATLAB](https://se.mathworks.com/help/install/install-products.html). ORTools is tested for compatibility from MATLAB 2016b onwards. 
   - With each [release](https://github.com/ORTools4MTEX/ORTools/releases) of ORTools, please check exactly which version of MTEX it is compatible with. 
- Click on the weblinks to download either one of the following two combinations:
  - <ins>Latest STABLE releases of:</ins> 
    - [**MTEX**](https://mtex-toolbox.github.io/download.html) and [**ORTools**](https://github.com/ORTools4MTEX/ORTools/releases/tag/v3.0.0).
  - <ins>DEVELOPER versions of:</ins>
    - [**MTEX**](https://github.com/mtex-toolbox/mtex/blob/develop/) and [**ORTools**](https://github.com/ORTools4MTEX/ORTools/archive/develop.zip).
- For instructions on installing MTEX and ORTools within MATLAB, please refer to the video given below.
- The peak fitting functionality within the function [defineORs](function_index.md#defineORs) requires the prior installation of the [MATLAB Signal Processing Toolbox](https://au.mathworks.com/products/signal.html).
- Open MATLAB and run one of the example files. Please refer to the [Example 1](https://youtu.be/AcR-nXg5QKo) instruction video to learn how to run the examples. Alternatively, if you do not wish to run the example files and want to use the function library instead, please ensure that the **ORTools** root directory and all of its sub-directories are added to the MATLAB path. 
- If you encounter any problems, please [submit an issue](https://github.com/ORTools4MTEX/ORTools/issues) or [open a discussion](https://github.com/ORTools4MTEX/ORTools/discussions).
- If you would like to contribute additional functionalities or wish to suggest new features, please [submit a contribution or request a feature in the discussion](https://github.com/ORTools4MTEX/ORTools/discussions).

<iframe width="560" height="315" src="https://www.youtube.com/embed/SsiDFqqqZU4" title="ORTools - How to install MTEX" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[*How to install MTEX*](https://youtu.be/SsiDFqqqZU4)

## How to cite ORTools
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4898682.svg)](https://doi.org/10.5281/zenodo.4898682)

If you have applied the OR discovery, OR and variant analyses, parent grain reconstruction, and correlated plotting features of MTEX and **ORTools** to your research, please cite this open-access paper as your reference:

[**F. Niessen, T. Nyyssönen, A.A. Gazder, R. Hielscher, Parent grain reconstruction from partially and fully transformed microstructures in MTEX, Journal of Applied Crystallography: 55(1), pp. 180-194, 2022. (https://doi.org/10.1107/S1600576721011560)**](https://journals.iucr.org/j/issues/2022/01/00/nb5309/nb5309.pdf)

## Authors and contributors
![GitHub contributors](https://img.shields.io/github/contributors/ORTools4MTEX/ORTools)

**ORTools** has been created by [**Dr Azdiar Gazder**](https://www.researchgate.net/profile/Azdiar-Gazder) and [**Dr Frank Niessen**](https://www.researchgate.net/profile/Frank-Niessen-4). 

## Collaborators
![Static Badge](https://img.shields.io/badge/Collaborators-Welcome!-8A2BE2)

[**Dr Tuomo Nyyssönen**](https://www.researchgate.net/profile/Tuomo-Nyyssoenen) - Lath martensite block width calculator

