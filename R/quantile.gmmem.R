#' Calculate quantiles of a mixture component
#'
#' `quantile.gmmem()` calculates quantiles of a mixture component of the fitted
#'     Gaussian mixture model. The quantiles calculated can be referred to as
#'     read count cutoff thresholds for denoising amplicon sequence variants
#'     (ASVs) inferred from metabarcoding analysis.
#'
#' @importFrom stats quantile qnorm
#' @param x A list object of class `gmmem`.
#' @param comp A single number specifying the component number. Note that the
#'     component number is in ascending order from the uppermost component.
#' @param probs A vector of probabilities. Elements must be \[0 ≤ probs ≤ 1\].
#' @param lower.tail logical; if `TRUE` (default), probabilities are
#'     P\[X ≤ x\] otherwise, P\[X > x\].
#' @param ... Unused.
#' @return A vector of quantiles.
#' @seealso [gmmem]
#' @examples
#' data(mifish)
#' logmf <- log10(mifish)
#' set.seed(101)
#' mod <- gmmem(logmf, k = 3)
#' autoplot(mod)
#' thresh <- quantile(mod, comp = 2)
#' autoplot(mod, vline = c(NA, thresh, NA))
#' @export quantile.gmmem
#' @export
quantile.gmmem <- function(x, comp, probs = .95, lower.tail = TRUE, ...) {
  if (!inherits(x, "gmmem"))
    stop("use only with \'gmmem\' objects")
  q <- qnorm(probs, mean = rev(x$mu)[comp], sd = rev(x$sigma)[comp],
             lower.tail = lower.tail)
  return(q)
}
