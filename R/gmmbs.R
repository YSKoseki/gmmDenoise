#' Perform sequential parametric bootstrap tests for the number of mixture
#'     components
#'
#' `gmmbs()` is a simple wrapper of [mixtools::boot.comp()] to perform
#'     sequential parametric bootstrap tests of k-component versus
#'     (k+1)-component Gaussian mixture models for selecting the number of
#'     components.
#'
#' @importFrom mixtools boot.comp
#' @param x A vector of length n consisting of the data.
#' @param maxk The maximum number of components to consider.
#' @param B The number of bootstrap realizations of the likelihood ratio
#'     statistic to produce. For details, see [mixtools::boot.comp()].
#' @param sig The significance level for which to compare the p-value against
#'     when performing the test of k-components versus (k+1)-components.
#' @param epsilon The convergence criterion. See [mixtools::boot.comp()].
#' @param ... Additional arguments passed to [mixtools::boot.comp()].
#' @return A list object of class `gmmbs` with items:
#' \describe{
#'   \item{p.values}{The p-values for each test of k-components vs.
#'       (k+1)-components.}
#'   \item{log.lik}{The B bootstrap realizations of the likelihood ratio
#'       statistic for each test.}
#'   \item{obs.log.lik}{The observed likelihood ratio statistic for each test
#'       which is used in determining the p-values.}
#' }
#' @references
#' * Benaglia, T., Chauveau, D., Hunter, D. R., & Young, D. S. (2009). mixtools:
#'     An R package for analyzing finite mixture models. Journal of Statistical
#'     Software, 32(6), 1-29. <https://doi.org/10.18637/jss.v032.i06>
#' * Shalizi, C. R. (2011). Lecture 20, Mixture Examples and Complements.
#'     In 36-402, Advanced Data Analysis (pp. 1-23).
#'     <https://www.stat.cmu.edu/~cshalizi/402/lectures/20-mixture-examples/lecture-20.pdf>
#' @examples
#' \dontrun{
#'   data(mifish)
#'   logmf <- log10(mifish)
#'   set.seed(101)
#'   # May take some time
#'   bs <- gmmbs(logmf, B = 100, epsilon = 1e-03)
#'   p <- autoplot(bs)
#'   library(cowplot)
#'   plot_grid(plotlist = p, ncol = 2)
#'   summary(bs)
#' }
#' @export
gmmbs <- function(x, maxk = 10, B = 1000, sig = .05, epsilon = 1e-8, ...) {
  if (!is.vector(x))
    stop("use only with a vector")
  bs.list <- boot.comp(x, max.comp = maxk, B = B, sig = sig, epsilon = epsilon,
                       mix.type = "normalmix", hist = FALSE, ...)
  class(bs.list) <- "gmmbs"
  return(bs.list)
}
