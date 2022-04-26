#' Calculate probability density functions of mixture components
#'
#' `fitted.gmmem()` calculates probability density functions (PDFs) of
#'     individual mixture components of the fitted Gaussian mixture model.
#'
#' @importFrom dplyr `%>%` bind_cols rename_with
#' @importFrom stringr str_replace
#' @importFrom tidyr pivot_longer
#' @importFrom stats fitted sd dnorm
#' @importFrom mixtools normalmixEM
#' @param object A list object of class `gmmem`.
#' @param ... Unused.
#' @return A data frame of class `fitted.gmmem` with three columns:
#' \describe{
#'   \item{x}{The raw data.}
#'   \item{comp}{Name of Mixture component.}
#'   \item{density}{The probability densities.}
#' }
#' @seealso [gmmem()]
#' @examples
#' data(mifish)
#' logmf <- log10(mifish)
#' set.seed(101)
#' mod <- gmmem(logmf, k = 3)
#' pdf <- fitted(mod)
#' @export fitted.gmmem
#' @export
fitted.gmmem <- function(object, ...) {
  if (!inherits(object, "gmmem"))
    stop("use only with \'gmmem\' objects")
  . <- x <- NULL
  df <- 1:length(object$lambda) %>%
    sapply(function(k) dgauss(object = object, k)) %>%
    bind_cols() %>%
    rename_with(~ str_replace(., "...", "Comp")) %>%
    bind_cols(x = object$x, .) %>%
    pivot_longer(cols = -x, names_to = "comp", values_to = "density") %>%
    suppressMessages()
  class(df) <- c("data.frame")
  return(df)
}

# Helpers -----------------------------------------------------------------

#' Calculate probability density function for a component
#' @importFrom stats dnorm
#' @param object A list of class `gmmem`.
#' @param comp A single number specifying the ID of mixture component.
#' @noRd
#
dgauss <- function(object, k) {
  x <- object$x
  lambda <- object$lambda[k]
  mu <- object$mu[k]
  sigma <- object$sigma[k]
  d <- lambda * dnorm(x, mean = mu, sd = sigma)
  return(d)
}
