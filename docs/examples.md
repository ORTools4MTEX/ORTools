# ORTools example scripts

##  ORTools example scripts
The world of martensitic transformation or phase transition analysis can be difficult to navigate. To help make the analysis accessible, transparent, and easy to comprehend, the **ORTools** library consists of plug-and-play functions. Example scripts are provided to help demonstrate these functions *in action*.

It is possible to run the example scripts from start to end, but we encourage you to run the example scripts [in sections](https://mathworks.com/help/matlab/matlab_prog/run-sections-of-programs.html) to understand the correlation between the scripts and the generated results. 
This will also help you follow the comments, which provide instructions on the various choices to make in the interactive parts of the program and/or help explain the obtained plots and results. In this way, you will learn the syntax applied throughout the scripts as well as the meaning behind the presented results.

### [Example 10: 03 JUL 2023](https://github.com/ORTools4MTEX/ORTools/blob/master/ORTools_example10.m)

#### Update to Example 1: Parent grain reconstruction using the variant graph approach in lath martensite and child grain id analysis

This script follows the same dataset as that used in the official [MTEX example]( https://mtex-toolbox.github.io/MaParentGrainReconstructionAdvanced.html) to demonstrate the reconstruction of parent gamma grains from child alpha grains in a lath martensite microstructure. The [computeGrainPairs](function_index.md#computeGrainPairs) function provides a direct way of calculating the absolute or normalised frequency and boundary segment lengths of grain pairs. The grain pair ids can be defined by the user for variants, crystallographic packets, Bain groups, any other-id type or for groups of id or equivalent id pairs.

<iframe width="560" height="315" src="https://www.youtube.com/embed/ZOmOw1q0lXg" title="ORTools - Example 10" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[*Example 10 - Parent grain reconstruction using the variant graph approach in lath martensite and child grain id analysis*](https://youtu.be/ZOmOw1q0lXg)

### [Example 09: 06 JUN 2023](https://github.com/ORTools4MTEX/ORTools/blob/master/ORTools_example09.m)

#### Update to Example 1: Parent grain reconstruction using the variant graph approach in lath martensite and habit plane determination

This script follows the same dataset as that used in the official [MTEX example](https://mtex-toolbox.github.io/MaParentGrainReconstructionAdvanced.html) to demonstrate the reconstruction of parent gamma grains from child alpha grains in a lath martensite microstructure. The [computeHabitPlane](function_index.md#computeHabitPlane) function provides a direct way of calculating the habit plane compared to conventional MTEX. 

The details related to the habit plane calculation are described in the following paper:

[**T. Nyyssönen, A.A. Gazder, R. Hielscher, F. Niessen, Habit plane determination from reconstructed parent phase orientation maps, Acta Materialia: 119035, 2023. (https://doi.org/10.1016/j.actamat.2023.119035)**]( https://www.researchgate.net/publication/371310735_Habit_plane_determination_from_reconstructed_parent_phase_orientation_maps)

<iframe width="560" height="315" src="https://www.youtube.com/embed/lM_NhQQY5LY" title="ORTools - Example 9" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[*Example 9 - Parent grain reconstruction using the variant graph approach in lath martensite and habit plane determination*](https://youtu.be/lM_NhQQY5LY)

### [Example 08: 29 MAR 2023](https://github.com/ORTools4MTEX/ORTools/blob/master/ORTools_example08.m)

#### Update to Example 2: Parent grain reconstruction using the variant graph approach in Ti alloys

This script follows the same dataset as that used in the official [MTEX example](https://mtex-toolbox.github.io/TiBetaReconstruction.html) to demonstrate the reconstruction of parent beta grains from child alpha grains in a alpha-beta Ti alloy. The script provides a faster and less involved way of reconstructing this microstructure compared to the triple-point based approach from [Example 2](./ORTools_example2.m). 

The details related to the variant graph approach are described in the following paper:

[**R. Hielscher, T. Nyyssönen, F. Niessen, A.A. Gazder, The variant graph approach to improved parent grain reconstruction, Materialia: 22, 101399, 2022. (https://doi.org/10.1016/j.mtla.2022.101399)**](https://www.researchgate.net/publication/357646342_The_variant_graph_approach_to_improved_parent_grain_reconstruction)

### [Example 07: 23 MAR 2022](https://github.com/ORTools4MTEX/ORTools/blob/master/ORTools_example07.m)

#### Update to Example 1: Parent grain reconstruction using the new variant graph approach and advanced variant analysis in lath martensitic steel

This script follows the same dataset as that used in the official [MTEX example](https://mtex-toolbox.github.io/MaParentGrainReconstruction.html) to demonstrate the reconstruction of parent austenite grains from child lath martensite using the new **variant graph approach**. Compared to the original [Example 1](./ORTools_example1.m), this updated version also features equivalent variant pair analysis and the measurement of lath block widths. 

The details related to the variant graph approach are described in the following paper:

[**R. Hielscher, T. Nyyssönen, F. Niessen, A.A. Gazder, The variant graph approach to improved parent grain reconstruction, Materialia: 22, 101399, 2022. (https://doi.org/10.1016/j.mtla.2022.101399)**](https://www.researchgate.net/publication/357646342_The_variant_graph_approach_to_improved_parent_grain_reconstruction)

<iframe width="560" height="315" src="https://www.youtube.com/embed/E9IFyFUQNl4" title="ORTools - Example 7" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[*Example 7 - Variant graph approach & advanced variant analysis in lath martensitic steel*](https://youtu.be/E9IFyFUQNl4)

### [Example 06: 12 MAY 2021](https://github.com/ORTools4MTEX/ORTools/blob/master/ORTools_example06.m)

#### Two-stage parent grain reconstruction in a TWIP-TRIP steel

This example is of a 10% cold-rolled twinning and transformation induced plasticity (TWIP-TRIP) steel microstructure with a two-step martensitic transformation in which ε martensite formed from γ austenite, and α' martensite formed from ε martensite. ORTools and the MTEX parent grain reconstruction functionalities are used to reconstruct both parent microstructures in a single workflow. Towards the end, it is demonstrated that variant analysis can be conducted on both transformations. 

**EBSD map courtesy: Pramanik et al. https://doi.org/10.1016/j.msea.2018.06.024**

<iframe width="560" height="315" src="https://www.youtube.com/embed/K2rO3Mx4A8s" title="ORTools - Example 6" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[*Example 6 - Two-stage parent grain reconstruction in a TWIP-TRIP steel*](https://youtu.be/K2rO3Mx4A8s)

### [Example 05: 04 MAR 2021](https://github.com/ORTools4MTEX/ORTools/blob/master/ORTools_example05.m)

#### Partial parent grain reconstruction to clean TWIP-TRIP steel EBSD data

This example is of a 20% cold-rolled twinning and transformation induced plasticity (TWIP-TRIP) steel microstructure presenting with a two-step martensitic transformation in which ε martensite formed from γ austenite, and α' martensite formed from ε martensite. Using the [OR peak fitter](function_index.md#peakFitORs) function, it is discovered that two possible ORs could be in operation for the γ to α' microstructure. The first OR is not a real OR but rather, an "apparent" OR corresponding to pixels that were misindexed as α' during map acquisition even though they notionally belong to γ. The parent phase reconstruction features in MTEX and the "apparent" OR are used to revert these misindexed points to γ. The grain calculation and the OR peak fitter is re-run to show that the "apparent" OR was eliminated. 

**EBSD map courtesy: Pramanik et al. https://doi.org/10.1016/j.msea.2018.06.024**

<iframe width="560" height="315" src="https://www.youtube.com/embed/Hj5kVscjljU" title="ORTools - Example 5" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[*Example 5 - Partial parent grain reconstruction to clean TRIP-TWIP steel EBSD map data*](https://youtu.be/Hj5kVscjljU)

### [Example 04: 04 MAR 2021](https://github.com/ORTools4MTEX/ORTools/blob/master/ORTools_example04.m)

#### Predicting the β to α transformation texture in a titanium alloy

In this script, the reconstruction of the prior parent β microstructure from a child α microstructure is repeated as shown in [example 2](examples.md). Examination of the variant distribution shows that strongly preferential variant selection did not occur. Therefore, the transition texture of α can be accurately predicted from the reconstructed β using the [plotPODF_transform](function_index.md#plotPODF_transform) function. The result shows that the predicted α transition texture is in good agreement with the experimental α texture.

<iframe width="560" height="315" src="https://www.youtube.com/embed/Yx2jKII3HUc" title="ORTools - Example 4" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[*Example 4 - Transformation texture prediction in titanium alloys*](https://youtu.be/Yx2jKII3HUc)

### [Example 03: 04 MAR 2021](https://github.com/ORTools4MTEX/ORTools/blob/master/ORTools_example03.m)

#### Using the OR peak fitter to deconvolute multiple ORs in titanium alloys

In [example 2](examples.md) the α-β Ti microstructure showed two ORs in the [OR peak fitter](function_index.md#peakFitORs) function. In this example, both ORs are investigated to find out which one of them dominated the phase transition. To evaluate the best match, the disorientation between grain boundary misorientations and the OR misorientations in inverse pole figures and on boundary maps are plotted.

<iframe width="560" height="315" src="https://www.youtube.com/embed/8e9PhhFCWYc" title="ORTools - Example 3" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[*Example 3 - Separation of multiple ORs in titanium alloys*](https://youtu.be/8e9PhhFCWYc)

### [Example 02: 03 MAR 2021](https://github.com/ORTools4MTEX/ORTools/blob/master/ORTools_example02.m)

#### Parent grain reconstruction and variant analysis in titanium alloys

This script follows the same dataset and steps that are used to demonstrate the reconstruction of β grains from an α microstructure in the official [MTEX example](https://mtex-toolbox.github.io/TiBetaReconstruction.html) for phase transitions in titanium alloys. Here the [OR peak fitter](function_index.md#peakFitORs) function is used to determine the OR from alpha-beta boundaries even though they only make up < 1% of all boundaries in the dataset. Advanced plotting functions are employed to produce publication-ready plots.

<iframe width="560" height="315" src="https://www.youtube.com/embed/e6R0dApUc8Q" title="ORTools - Example 2" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[*Example 2 - Parent grain reconstruction in titanium alloys*](https://youtu.be/e6R0dApUc8Q)

### [Example 01: 03 MAR 2021](https://github.com/ORTools4MTEX/ORTools/blob/master/ORTools_example01.m)

#### Parent grain reconstruction and variant analysis in lath martensitic steel

This script follows the same dataset and steps that are used to demonstrate the reconstruction of austenitic parent grains from martensite grains using the **grain graph approach** in the official [MTEX example](https://mtex-toolbox.github.io/GrainGraphBasedReconstruction.html) for martensite transformation in steels. The functionality of **ORTools** in providing pre-written and additional plotting functions to create publication-ready plots is demonstrated.

<iframe width="560" height="315" src="https://www.youtube.com/embed/AcR-nXg5QKo" title="ORTools - Example 1" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

[*Example 1 - Parent grain reconstruction in steel*](https://youtu.be/AcR-nXg5QKo)

