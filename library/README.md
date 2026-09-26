# Third-party code

This folder holds code written outside the ORTools project, kept as the original authors wrote it.
It is excluded from formatting and linting (see `miss_hit.cfg` in this folder). Licences are those of
the original authors, as stated in each file.

| Path | Author | Notes |
|---|---|---|
| `arrow3d.m` | Moshe Lindner, Bar-Ilan University (2010) | 3D arrows |
| `arrowKeys.m` | unknown | Keyboard navigation callback; no author information in the file |
| `inputsdlg.m` | Takeshi Ikuma | Enhanced input dialog, version 2.2.0 (2015) |
| `padcat.m` | Jos van der Geest | Concatenate vectors of different lengths, version 1.4 (2018) |
| `sshist.m` | Hideaki Shimazaki (2009, 2010) | Optimal histogram bin width, [doi:10.1162/neco.2007.19.6.1503](https://doi.org/10.1162/neco.2007.19.6.1503) |
| `colorMaps/` | Timothy Sipkens, plus the colormap sources listed in [`colorMaps/README.md`](colorMaps/README.md) | Perceptually uniform colormaps; licences per source in that README |

## ORTools code in this folder

These files are part of ORTools and fall under the repository's MIT licence:

| Path | Notes |
|---|---|
| `gaussFit.m` | Gaussian peak fitting used by `defineORs` |
| `compat/` | Compatibility shims for older MATLAB releases, added to the path only when MATLAB lacks the function (see `currentFolder.m`) |
