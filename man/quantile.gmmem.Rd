% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/quantile.gmmem.R
\name{quantile.gmmem}
\alias{quantile.gmmem}
\title{Calculate quantiles of a mixture component}
\usage{
\method{quantile}{gmmem}(x, comp, probs = 0.95, lower.tail = TRUE, ...)
}
\arguments{
\item{x}{A list object of class \code{gmmem}.}

\item{comp}{A single number specifying the component number.}

\item{probs}{A vector of probabilities. Elements must be [0 ≤ probs ≤ 1].}

\item{lower.tail}{logical; if \code{TRUE} (default), probabilities are
P[X ≤ x] otherwise, P[X > x].}

\item{...}{Unused.}
}
\value{
A vector of quantiles.
}
\description{
\code{quantile.gmmem()} calculates quantiles of a mixture component of the fitted
Gaussian mixture model. The quantiles calculated can be referred to as
read count cutoff thresholds for denoising amplicon sequence variants
(ASVs) inferred from metabarcoding analysis.
}
\examples{
data(mifish)
logmf <- log10(mifish)
set.seed(101)
mod <- gmmem(logmf, k = 3)
autoplot(mod)
thresh <- quantile(mod, comp = 2)
autoplot(mod, vline = c(NA, thresh, NA))
}
\seealso{
\link{gmmem}
}
