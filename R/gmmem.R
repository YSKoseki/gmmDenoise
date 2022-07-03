#' Fit k-component Gaussian mixture models
#'
#' `gmmem()` is a simple wrapper of [mixtools::normalmixEM()] to fit k-component
#'    Gaussian mixture models to data.
#'
#' @importFrom stats sd dnorm
#' @importFrom mixtools normalmixEM
#' @param x A vector of length n consisting of the data.
#' @param k Number of components.
#' @param maxit The maximum number of iterations. See [mixtools::normalmixEM()].
#' @param epsilon The convergence criterion. See [mixtools::normalmixEM()].
#' @param ... Additional arguments passed to [mixtools::normalmixEM()].
#' @return A list object of class `gmmem` with items:
#' \describe{
#'   \item{x}{The raw data.}
#'   \item{lambda}{The final mixing proportions.}
#'   \item{mu}{The final mean parameters.}
#'   \item{sigma}{The final standard deviations. If arbmean = FALSE, then only the smallest standard deviation is returned. See scale below.}
#'   \item{scale}{If arbmean = FALSE, then the scale factor for the component standard deviations is returned. Otherwise, this is omitted from the output.}
#'   \item{loglik}{The final log-likelihood.}
#'   \item{posterior}{An nxk matrix of posterior probabilities for observations.}
#'   \item{all.loglik}{A vector of each iteration's log-likelihood. This vector includes both the initial and the final values; thus, the number of iterations is one less than its length.}
#'   \item{restarts}{The number of times the algorithm restarted due to unacceptable choice of initial values.}
#'   \item{ft}{A character vector giving the name of the function.}
#' }
#' @references
#' Benaglia, T., Chauveau, D., Hunter, D. R., & Young, D. S. (2009). mixtools:
#'     An R package for analyzing finite mixture models. Journal of Statistical
#'     Software, 32(6), 1-29. <https://doi.org/10.18637/jss.v032.i06>
#' @examples
#' data(mifish)
#' logmf <- log10(mifish)
#' set.seed(101)
#' mod <- gmmem(logmf, k = 3)
#' autoplot(mod)
#' thresh <- quantile(mod, comp = 2)
#' autoplot(mod, vline = c(NA, thresh, NA))
#' @export
gmmem <- function(x, k, maxit = 1000, epsilon = 1e-8, ...) {
  if (!is.vector(x))
    stop("use only with a vector")
  if (k == 1) {
    gmm <- NULL
    gmm$x <- x
    names(gmm$x) <- NULL
    gmm$lambda <- 1
    gmm$mu <- mean(x)
    gmm$sigma <- sd(x)
    den <- dnorm(gmm$x, mean = gmm$mu, sd = gmm$sigma)
    gmm$loglik <- sum(log(den))
  }
  else {
    gmm <- normalmixEM(x, k = k, maxit = maxit, epsilon = epsilon, ...)
    comp.ord <- order(gmm$mu)
    gmm$mu <- gmm$mu[comp.ord]
    gmm$sigma <- gmm$sigma[comp.ord]
    gmm$lambda <- gmm$lambda[comp.ord]
    gmm$posterior <- gmm$posterior[, comp.ord]
    colnames(gmm$posterior) <- colnames(gmm$posterior)[comp.ord]
  }
  class(gmm) <- c("gmmem")
  return(gmm)
}
