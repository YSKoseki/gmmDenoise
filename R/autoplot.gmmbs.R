#' Graphical representation of sequential parametric bootstrap tests for the
#'     number of mixture components
#'
#' `autoplot.gmmbs()` displays a graphical representation of sequential
#'     parametric bootstrap tests of k-component versus (k+1)-component
#'     Gaussian mixture models, drawing a series of histogram plots. The
#'     histogram in each plot shows the bootstrap distribution of likelihood
#'     ratio statistic, to which the observed likelihood ratio (LR) is compared.
#'     A vertical line signifying the observed LR is also drawn if it is not
#'     extremely far from the bootstrap distribution.
#'
#' @import ggplot2
#' @param object A list object of class `gmmbs`.
#' @param title.size,annot.size The sizes of the plot title and annotation.
#'     Use to override the default values.
#' @param ... Unused.
#' @seealso [gmmbs()]
#' @return A ggplot2 plot
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
#' @export autoplot.gmmbs
#' @export
autoplot.gmmbs <- function(object, title.size = NULL, annot.size = 6, ...) {
  if (!inherits(object, "gmmbs"))
    stop("use only with \'gmmbs\' objects")
  obsLLs <- object$obs.log.lik
  p.val <- object$p.values
  n <- length(p.val)
  h <- NULL
  for (i in 1:n) {
    val <- object$log.lik[[i]]
    brk <- pretty(range(val), n = nclass.Sturges(val), min.n = 1)
    df <- data.frame(val = val)
    h[[i]] <- ggplot(df, aes(x = val)) +
      geom_histogram(color = "black", fill = "grey", breaks = brk) +
      xlab("Bootstrap likelihood ratio statistic") +
      ylab("Frequency") +
      scale_y_continuous(expand = c(0, 0)) +
      ggtitle(paste0("k = ", i, " vs k = ", i+1)) +
      theme(plot.title = element_text(size = title.size, hjust = 0.5))
    data.of.h <- ggplot_build(h[[i]])$data[[1]]
    xmin <- min(data.of.h$xmin)
    xmax <- max(data.of.h$xmax)
    obsLL <- obsLLs[i]
    obsLL.1dig <- sprintf("%0.1f", obsLL)
    pval <- p.val[i]
    pval.2dig <- sprintf("%0.2f", pval)
    if (pval<0.05) {
      h[[i]] <- h[[i]] +
        geom_vline(xintercept = obsLL[obsLL >= xmin & obsLL <= xmax],
                   color = "red") +
        annotate(geom = "text",
                 label = paste0("LR=", obsLL.1dig, "  \n",
                                "p=", pval.2dig, "  "),
                 color = "red", size = annot.size,
                 x = Inf, y = Inf, vjust = 1.2, hjust = 1)
    }
    else {
      h[[i]] <- h[[i]] +
        geom_vline(xintercept = obsLL[obsLL >= xmin & obsLL <= xmax],
                   color = "blue") +
        annotate(geom = "text",
                 label = paste0("LR=", obsLL.1dig, "  \n",
                                "p=", pval.2dig, "  "),
                 color = "blue", size = annot.size,
                 x = Inf, y = Inf, vjust = 1.2, hjust = 1)
    }
  }
  return(h)
}
