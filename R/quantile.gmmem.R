#' Calculate quantiles of a mixture component
#'
#' `quantile.gmmem()` calculates quantiles of mixture components (default is
#'     the upper 95% of the second uppermost component) of the fitted Gaussian
#'     mixture model. The quantile calculated can be referred to as the read
#'     count cutoff threshold for amplicon sequence variant (ASV) filtering.
#'
#' @importFrom stats quantile qnorm
#' @param x A list object of class `gmmem`.
#' @param comp A numeric vector specifying the component numbers. Note that the
#'     component numbers are in ascending order from the uppermost component.
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
#' thresh <- quantile(mod)
#' autoplot(mod, vline = thresh)
#' @export quantile.gmmem
#' @export
quantile.gmmem <- function(x, comp = 2, probs = .95, lower.tail = TRUE, ...) {
  if (!inherits(x, "gmmem"))
    stop("use only with \'gmmem\' objects")
  q <- qnorm(probs, mean = rev(x$mu)[comp], sd = rev(x$sigma)[comp],
             lower.tail = lower.tail)
  return(q)
}
