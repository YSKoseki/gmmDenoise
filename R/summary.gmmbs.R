#' Summarize the result of sequential parametric bootstrap tests for the number
#'     of mixture components
#'
#' `summary.gmmbs()` creates a data frame object of the summary statistics of
#'     sequential parametric bootstrap tests for the number of mixture
#'     components.
#'
#' @param object A data frame object of class `gmmbs`.
#' @param ... Unused.
#' @return A data frame object with two columns:
#' \describe{
#'   \item{LR}{The observed likelihood ratio statistic for each test of
#'     k-components versus (k+1)-components.}
#'   \item{p.val}{The p-value for each test.}
#' }
#' @seealso [gmmbs()]
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
#' @export summary.gmmbs
#' @export
summary.gmmbs <- function(object, ...) {
  if (!inherits(object, "gmmbs"))
    stop("use only with \'gmmbs\' objects")
  LR <- object$obs.log.lik
  p.val <- object$p.values
  tab <- cbind(LR = LR, p.val = p.val)
  n <- nrow(tab)
  labs <- rep(NA, n)
  for (i in 1:n) {
    labs[i] <- paste0("k = ", i, " vs k = ", i + 1)
  }
  rownames(tab) <- labs
  return(tab)
}
