#' Perform cross-validation analysis for the number of mixture components
#'
#' `gmmcv()` performs split-half cross-validation analysis for selecting the
#'     number of components of Gaussian mixture model, using an EM algorithm
#'     implemented by [mixtools::normalmixEM()] to estimate model parameters.
#'
#' @importFrom stats sd dnorm
#' @importFrom mixtools normalmixEM
#' @param x A vector of length n consisting of the data.
#' @param maxk The maximum number of components to consider.
#' @param maxit The maximum number of iterations. See [mixtools::normalmixEM()].
#' @param epsilon The convergence criterion. See [mixtools::normalmixEM()].
#' @return A list object of class `gmmcv` with items:
#' \describe{
#'   \item{k}{The number of mixture components considered.}
#'   \item{log.lik}{The log-likelihood of the k-component Gaussian mixture model.}
#' }
#' @references
#' * Benaglia, T., Chauveau, D., Hunter, D. R., & Young, D. S. (2009). mixtools:
#'     An R package for analyzing finite mixture models. Journal of Statistical
#'     Software, 32(6), 1-29. <https://doi.org/10.18637/jss.v032.i06>
#' * Shalizi, C. R. (2011). Lecture 20, Mixture Examples and Complements.
#'     In 36-402, Advanced Data Analysis (pp. 1-23).
#'     <https://www.stat.cmu.edu/~cshalizi/402/lectures/20-mixture-examples/lecture-20.pdf>
#' @examples
#' data(mifish)
#' logmf <- log10(mifish)
#' set.seed(101)
#' cv <- gmmcv(logmf, epsilon = 1e-03)
#' autoplot(cv)
#' @export
gmmcv <- function(x, maxk = 10, maxit = 1000, epsilon = 1e-08) {
  if (!is.vector(x))
    stop("use only with a vector")
  n <- length(x)
  # Permute randomly
  permdat <- sample(1:n)
  # Use first random half as training
  train <- permdat[1:floor(n / 2)]
  # Use 2nd random half as testing
  test <- permdat[-(1:floor(n / 2))]
  k <- 1:maxk
  log.lik <- rep(NA, length = maxk)
  # Needs special handling for k = 1
  # MLE of mean
  mu <- mean(x[train])
  # MLE of standard deviation
  sigma <- sd(x[train]) * sqrt((n - 1) / n)
  log.lik[[1]] <- sum(dnorm(x[test], mu, sigma, log = TRUE))
  # Calculate log-likelihoods for GMMs with different numbers of components
  for (i in 2:maxk) {
    mixEM <- NULL
    mixEM <- normalmixEM(x[train], k = i, maxit = maxit, epsilon = epsilon)
    log.lik[[i]] <- logliknormix(x[test], mixEM = mixEM)
  }
  y <- list(k = k, log.lik = log.lik)
  class(y) <- "gmmcv"
  return(y)
}

# Helpers -----------------------------------------------------------------

#' Calculate share of likelihood for all data for one component
#' @importFrom stats dnorm
#' @param x The data as a vector.
#' @param mixEM The output of Gaussian mixture modeling returned by
#'     [mixtools::normalmixEM()].
#' @param comp A single number indicating a component of the Gaussian mixture.
#' @noRd
likcomp <- function(x, mixEM, comp) {
  lambda <- mixEM$lambda[comp]
  mu <- mixEM$mu[comp]
  sigma <- mixEM$sigma[comp]
  lik <- lambda * dnorm(x, mean = mu, sd = sigma)
  return(lik)
}

#' Calculate sum of likelihood shares from components over all data
#' @param x The data as a vector.
#' @param mixEM The output of Gaussian mixture modeling returned by
#'     [mixtools::normalmixEM()].
#' @param log Logical; if `TRUE` (default), log-likelihood is calculated; if
#'     `FALSE`, likelihood is calculated.
#' @noRd
dnormix <- function(x, mixEM, log = FALSE) {
  lambda <- mixEM$lambda
  k <- length(lambda)
  # Create array with likelihood shares from all components over all data
  liks <- sapply(1:k, likcomp, x = x, mixEM = mixEM)
  # Add up contributions from components by data
  d <- rowSums(liks)
  if (log) d <- log(d)
  return(d)
}

#' Calculate total log-likelihood
#' @param x The data as a vector.
#' @param mixEM An output returned by [mixtools::normalmixEM()].
#' @noRd
logliknormix <- function(x, mixEM) {
  loglik <- dnormix(x, mixEM, log = TRUE)
  totLL <- sum(loglik)
  return(totLL)
}
