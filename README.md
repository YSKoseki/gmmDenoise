
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gmmDenoise <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->
<!-- badges: end -->

# Overview

gmmDenoise is a set of functions for denoising amplicon sequence
variants (ASVs) inferred from metabarcoding analysis, based on Gaussian
mixture modeling (GMM).

## Installation

``` r
# install.packages("devtools")
devtools::install_github("YSKoseki/gmmDenoise")
```

## Example

This is an example of how gmmDenoise works for denoising metabarcoding
sequence data.

``` r
library(gmmDenoise)
#>  要求されたパッケージ ggplot2 をロード中です
```

``` r
# Data: Read counts of 1,217 amplicon sequence variants (ASVs) from an
#   eDNA metabarcoding study
data(mifish)
head(mifish, n = 10)

# Plot histogram for visual inspection of ASV read count distribution
asvhist(mifish)
```

<img src="man/figures/README-example-1.png" width="100%" />

``` r
asvhist(mifish, type = "density", nbins = 30, xlim = c(1, 6))
```

<img src="man/figures/README-example-2.png" width="100%" />

``` r
# Cross-validation analysis for selecting the number of components of Gaussian
#   mixture model
logmf <- log10(mifish)
set.seed(101)
cv <- gmmcv(logmf, epsilon = 1e-03)
autoplot(cv)
```

<img src="man/figures/README-example-3.png" width="100%" />

``` r
# An alternative approach for the number of mixture components: Sequential
#   parametric bootstrap tests 
set.seed(101)
# May take some time
bs <- gmmbs(logmf, B = 100, epsilon = 1e-03)
p <- autoplot(bs)
library(cowplot)
plot_grid(plotlist = p, ncol = 2)
```

<img src="man/figures/README-example-4.png" width="100%" />

``` r
summary(bs)

# Fit 3-component Gaussian mixture model and displays a graphical representation of the output
set.seed(101)
mod <- gmmem(logmf, k = 3)
autoplot(mod)
```

<img src="man/figures/README-example-5.png" width="100%" />

``` r
thresh <- quantile(mod, comp = 2)
autoplot(mod, vline = c(NA, thresh, NA))
```

<img src="man/figures/README-example-6.png" width="100%" />

<!--
You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date. `devtools::build_readme()` is handy for this. You could also use GitHub Actions to re-render `README.Rmd` every time you push. An example workflow can be found here: <https://github.com/r-lib/actions/tree/v1/examples>.
-->
