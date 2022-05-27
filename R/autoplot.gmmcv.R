#' Graphical representation of cross-validation analysis for the number of
#'     mixture components
#'
#' `autoplot.gmmcv()` displays a graphical representation of cross-validation
#'     analysis for the number of components of Gaussian mixture model, drawing
#'     the point plot of model's log-likelihood against the number of mixture
#'     components, superimposed with the fitted LOESS curve and its confidence
#'     interval.
#'
#' @import ggplot2
#' @param object A list object of class `gmmcv`.
#' @param ... Unused.
#' @seealso [gmmcv()]
#' @return A ggplot2 plot
#' @examples
#' data(mifish)
#' logmf <- log10(mifish)
#' set.seed(101)
#' cv <- gmmcv(logmf, epsilon = 1e-03)
#' autoplot(cv)
#' @export autoplot.gmmcv
#' @export
autoplot.gmmcv <- function(object, ...) {
  if (!inherits(object, "gmmcv"))
    stop("use only with \'gmmcv\' objects")
  k <- log.lik <- NULL
  df <- data.frame(k = object$k, log.lik = object$log.lik)
  maxk <- max(df$k)
  p <- ggplot(df, aes(k, log.lik)) +
    geom_point(size = 3) +
    geom_smooth(method = "loess", formula = y ~ x) +
    xlab("Number of components, k") +
    ylab("Log-likelihood") +
    scale_x_continuous(breaks = 1:maxk)
  return(p)
}
