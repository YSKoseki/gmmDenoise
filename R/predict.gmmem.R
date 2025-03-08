#' Extract predicted values from PDFs of mixture components
#'
#' `predict.gmmem()` extracts predicted values from probability density
#'     functions (PDFs) of individual mixture components of the fitted Gaussian
#'     mixture model.
#'
#' @importFrom dplyr `%>%` bind_cols rename_with
#' @importFrom stringr str_replace
#' @importFrom tidyr pivot_longer
#' @importFrom stats fitted sd dnorm
#' @importFrom mixtools normalmixEM
#' @param object A list object of class `gmmem`.
#' @param newdata An optional vector of length n consisting of the new data. If
#'     NULL (default), the fitted values are used.
#' @param ... Unused.
#' @return A data frame of class `predict.gmmem` with three columns:
#' \describe{
#'   \item{x}{The data to which probability densities are predicted.}
#'   \item{comp}{Name of Mixture component.}
#'   \item{density}{The probability densities.}
#' }
#' @seealso [gmmem()]
#' @examples
#' data(mifish)
#' logmf <- log10(mifish)
#' set.seed(101)
#' mod <- gmmem(logmf, k = 3)
#' pdf <- predict(mod)
#' @export predict.gmmem
#' @export
predict.gmmem <- function(object, newdata = NULL, ...) {
  if (!inherits(object, "gmmem"))
    stop("use only with \'gmmem\' objects")
  . <- x <- lev <- revlev <- NULL
  if (is.null(newdata)) {
    newdata <- object$x
  }
  df <- 1:length(object$lambda) %>%
    sapply(function(k) dgauss(object = object, newdata = newdata, k)) %>%
    bind_cols() %>%
    rename_with(~ str_replace(., "...", "Comp ")) %>%
    bind_cols(x = newdata, .) %>%
    pivot_longer(cols = -x, names_to = "comp", values_to = "density") %>%
    suppressMessages()
  lev <- df$comp %>%
    unique()
  revlev <- rev(lev)
  df$comp <- factor(df$comp, levels = lev, labels = revlev)
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
dgauss <- function(object, newdata, k) {
  if (is.null(newdata)) {
    newdata <- object$x
  }
  lambda <- object$lambda[k]
  mu <- object$mu[k]
  sigma <- object$sigma[k]
  d <- lambda * dnorm(newdata, mean = mu, sd = sigma)
  return(d)
}
