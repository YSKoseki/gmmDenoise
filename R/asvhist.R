#' Plot an ASV read count histogram
#'
#' `asvhist()` creates a custom histogram plot of read counts of amplicon
#'     sequence variants (ASVs) inferred from metabarcoding analysis.
#'
#' @importFrom grDevices nclass.Sturges nclass.FD nclass.scott
#' @importFrom scales pretty_breaks
#' @import ggplot2
#' @param x A vector of ASV read counts (all positive numbers).
#' @param scale The scale of plot. Either `"log"` (common log, default) or
#'     `"normal"`.
#' @param type The type of plot. Either `"freq"` or `"density"`; if `"freq"`
#'     (default), frequencies (counts) are plotted; if `"density"`, probability
#'     densities are plotted.
#' @param nbins Either a single number giving the number of bins or a character
#'     string naming an algorithm to compute the number of bins (see ‘Details’).
#' @param xlim,ylim The ranges of x and y axes. Use to override the plot default.
#' @param color,fill Colors to be used to border and fill the bins. Use to
#'     override the defaults (`"black"` and `"grey"`).
#' @details The default for `nbins` is `"FD"`, which stands for
#'     `"Freedman-Diaconis"`; see [grDevices::nclass.FD()]. Other options are
#'     `"Scott"` and `"Sturges"`; see [grDevices::nclass.scott()] and
#'     [grDevices::nclass.Sturges()].
#' @return A ggplot2 histogram plot
#' @examples
#' data(mifish)
#' asvhist(mifish)
#' asvhist(mifish, type = "density", nbins = 30, xlim = c(1, 6))
#' @export
asvhist <- function(x, scale = "log", type = "freq", nbins = "FD",
                    xlim = NULL, ylim = NULL, color = "black", fill = "grey") {
  if (!is.vector(x) || any(x <= 0))
    stop("use only with a vector of count data (all positive integers)")
  count <- ..density.. <- NULL
  if (scale == "log") {
    x <- log10(x)
  } else {
    x <- x
  }
  if (is.null(nbins) | is.numeric(nbins)) {
    nb <- nbins
    brk <- NULL
  }
  if (identical(nbins, "Sturges")) {
    nb <- NULL
    brk <- pretty(range(x), n = nclass.Sturges(x), min.n = 1)
  }
  if (identical(nbins, "FD") | identical(nbins, "Freedman-Diaconis")) {
    nb <- NULL
    brk <- pretty(range(x), n = nclass.FD(x), min.n = 1)
  }
  if (identical(nbins, "Scott")) {
    nb <- NULL
    brk <- pretty(range(x), n = nclass.scott(x), min.n = 1)
  }
  df <- data.frame(count = x)
  h <- ggplot(df, aes(count)) +
    scale_x_continuous(limits = xlim, breaks = pretty_breaks())
  if (type == "freq") {
    h <- h +
      geom_histogram(bins = nb, breaks = brk, color = color, fill = fill) +
      scale_y_continuous(limits = ylim, expand = c(0, 0), breaks = pretty_breaks()) +
      ylab("Frequency")
  }
  if (type == "density") {
    h <- h +
      geom_histogram(aes(y = ..density..),
                     bins = nb, breaks = brk, color = color, fill = fill) +
      scale_y_continuous(limits = ylim, expand = c(0, 0)) +
      ylab("Density")
  }
  if (scale == "log") {
    h <- h + xlab("Log(ASV read count)")
  } else {
    h <- h + xlab("ASV read count")
  }
  return(h)
}
