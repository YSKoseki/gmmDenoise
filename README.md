
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gmmDenoise <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/YSKoseki/gmmDenoise/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/YSKoseki/gmmDenoise/actions/workflows/R-CMD-check.yaml)
![Static Badge](https://img.shields.io/badge/licence-GPL_(%3E=_2)-blue)

<!-- badges: end -->

# Overview

gmmDenoise is an R package for erroneous amplicon sequence variant (ASV)
filtering in eDNA metabarcoding data on the basis of Gaussian mixture
modeling (GMM) for accurate intraspecific diversity estimates and
population genetic inferences. The package provides functions for
selecting the number of components of GMM using cross-validation and
parametric bootstrap tests, fitting GMM, and filtering ASVs based on the
fitted GMM. The package also includes functions for visualizing the
results of the GMM fitting and filtering processes.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("YSKoseki/gmmDenoise")
```

## Example

This is an example of how gmmDenoise works for filtering erroneous ASVs.

``` r
library(gmmDenoise)
```

``` r
# Data: a vector of 1,217 ASV read counts, named with assigned taxonomic names
# and [ID numbers]
data(mifish)
head(mifish, n = 10)
length(mifish)
summary(mifish)


# Plot histogram for visual inspection of ASV read count distribution
asvhist(mifish)
```

<img src="man/figures/README-example-1.png" width="50%" />

``` r
asvhist(mifish, type = "density", nbins = 30, xlim = c(1, 6))
```

<img src="man/figures/README-example-2.png" width="50%" />

``` r

# Cross-validation for selecting the number of components of Gaussian
# mixture model
logmf <- log10(mifish)
set.seed(101)
cv <- gmmcv(logmf, epsilon = 1e-03)
autoplot(cv)  # equivalent to `autoplot.gmmcv(cv)`
```

<img src="man/figures/README-example-3.png" width="50%" />

``` r

# An alternative approach for the number of mixture components: Sequential
# parametric bootstrap tests 
set.seed(101)
# May take some time
bs <- gmmbs(logmf, B = 100, epsilon = 1e-03)
p <- autoplot(bs)  # equivalent to `p <- autoplot.gmmbs(bs)`
library(cowplot)
plot_grid(plotlist = p, ncol = 2)
```

<img src="man/figures/README-example-4.png" width="50%" />

``` r
summary(bs)

# Fit a 3-component Gaussian mixture model and display a graphical representation
# of the output
set.seed(101)
mod <- gmmem(logmf, k = 3)
autoplot(mod) # equivalent to `autoplot.gmmem(mod)`
```

<img src="man/figures/README-example-5.png" width="50%" />

``` r
thresh <- quantile(mod, comp = 2)
autoplot(mod, vline = c(NA, thresh, NA))
```

<img src="man/figures/README-example-6.png" width="50%" />

``` r

# Filter ASVs with the threshold value
logmf2 <- logmf[which(logmf > thresh)]
mifish2 <- mifish[which(logmf > thresh)]
asvhist(mifish2)
```

<img src="man/figures/README-example-7.png" width="50%" />

``` r
length(mifish2)
summary(mifish2)
```

<!--
You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date. `devtools::build_readme()` is handy for this. You could also use GitHub Actions to re-render `README.Rmd` every time you push. An example workflow can be found here: <https://github.com/r-lib/actions/tree/v1/examples>.
-->
