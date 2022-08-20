#' Graphical representation of Gaussian mixture model fit to ASV read count data
#'
#' `autoplot.gmmem()` displays a graphical representation of k-component
#'     Gaussian mixture model fit to ASV read count data, plotting the
#'     probability density functions or count density functions of mixture
#'     components over the histogram of log ASV read counts.
#'
#' @importFrom grDevices nclass.Sturges nclass.FD nclass.scott grey
#' @importFrom scales pretty_breaks
#' @importFrom wesanderson wes_palette
#' @import ggplot2
#' @param object A list object of class `gmmem`.
#' @param scale The scale of plot. Either `"log"` (common log, default) or
#'     `"normal"`.
#' @param type The type of plot. Either `"freq"` or `"density"`; if `"freq"`
#'     (default), frequencies (counts) are plotted; if `"density"`, probability
#'     densities are plotted.
#' @param nbins Either a single number giving the number of bins or a character
#'     string naming an algorithm to compute the number of bins (see ‘Details’).
#' @param vline A numeric vector giving the quantiles of the mixture components.
#'     Use to draw threshold(s) of the data. See the example.
#' @param xlim,ylim The ranges of x and y axes. Use to override the plot
#'     defaults.
#' @param hist.color,hist.fill Colors to be used to border and fill the bins.
#'     Use to override the defaults.
#' @param dist.color,dist.fill,dist.alpha The color (color and fill) and
#'     opacity parameters for probability density functions. Use to override the
#'     defaults.
#' @param vline.color The color for vertical lines.
#' @param ... Unused.
#' @details The default for `nbins` is `"FD"`, which stands for
#'     `"Freedman-Diaconis"`; see [grDevices::nclass.FD()]. Other options are
#'     `"Scott"` and `"Sturges"`; see [grDevices::nclass.scott()] and
#'     [grDevices::nclass.Sturges()], respectively.
#' @seealso [gmmem()], [predict.gmmem()], [quantile.gmmem()]
#' @return A ggplot2 plot
#' @examples
#' data(mifish)
#' logmf <- log10(mifish)
#' set.seed(101)
#' mod <- gmmem(logmf, k = 3)
#' autoplot(mod)
#' thresh <- quantile(mod, comp = 2)
#' autoplot(mod, vline = c(NA, thresh, NA))
#' @export autoplot.gmmem
#' @export
autoplot.gmmem <- function(object, scale = "log", type = "freq", nbins = "FD",
                           vline = NULL,
                           xlim = NULL, ylim = NULL,
                           hist.color = NULL, hist.fill = NULL,
                           dist.color = NULL, dist.fill = NULL,
                           dist.alpha = NULL, vline.color = NULL, ...) {
  if (!inherits(object, "gmmem"))
    stop("The object needs to be a \'gmmem\'-class")
  x <- density <- comp <- ..count.. <- ..density.. <- NULL
  # Set bin number or bin break points
  raw.x <- object$x
  if (is.null(nbins) || is.numeric(nbins)) {
    nb <- nbins
    brk <- NULL
  }
  if (identical(nbins, "Sturges")) {
    nb <- NULL
    brk <- pretty(range(raw.x), n = nclass.Sturges(raw.x), min.n = 1)
  }
  if (identical(nbins, "FD")) {
    nb <- NULL
    brk <- pretty(range(raw.x), n = nclass.FD(raw.x), min.n = 1)
  }
  if (identical(nbins, "Scott")) {
    nb <- NULL
    brk <- pretty(range(raw.x), n = nclass.scott(raw.x), min.n = 1)
  }
  # Plot setting
  k <- length(unique(object$lambda))
  if (is.null(hist.color)) hist.color <- grey(.9)
  if (is.null(hist.fill)) hist.fill <- grey(.8)
  if (is.null(dist.color) || is.null(dist.fill) || is.null(vline.color)) {
    if (k == 1) wes <- wes_palette("Darjeeling1", k + 1, type = "continuous")[2]
    if (k > 1) wes <- wes_palette("Darjeeling1", k, type = "continuous")
  }
  if (is.null(dist.color)) dist.color <- wes[1:k]
  if (is.null(dist.fill)) dist.fill <- wes[1:k]
  if (is.null(dist.alpha)) dist.alpha <- .3
  if (is.null(vline.color)) vline.color <- wes[1:length(vline)]
  hist.df <- data.frame(raw.x = raw.x)
  # Count plot
  if (type == "freq") {
    density.df <- predict.gmmem(object)
    if (!is.null(nb)) bw <- diff(range(raw.x)) / nb
    else bw <- diff(range(raw.x)) / (length(brk) - 1)
    n <- length(raw.x)
    p <- ggplot() +
      geom_histogram(data = hist.df,
                     mapping = aes(x = raw.x, y = ..count..),
                     bins = nb, breaks = brk,
                     color = hist.color, fill = hist.fill) +
      geom_line(data = density.df,
                mapping = aes(x = x, y = density * n * bw, color = comp),
                size = 1.1) +
      scale_color_manual(values = dist.color) +
      geom_area(data = density.df,
                mapping = aes(x = x, y = density * n * bw, fill = comp),
                position = position_identity(), alpha = dist.alpha) +
      scale_fill_manual(values = dist.fill) +
      geom_vline(xintercept = vline, color = vline.color, size = .8) +
      scale_x_continuous(limits = xlim, breaks = pretty_breaks()) +
      scale_y_continuous(limits = ylim, expand = c(0, 0),
                         breaks = pretty_breaks()) +
      ylab("Frequency") +
      theme(legend.position = c(.91, .85),
            legend.justification = c(1, 1),
            legend.title = element_blank(),
            legend.text = element_text(size = 14))
  }
  # Density plot
  if (type == "density") {
    new.x <- seq(min(raw.x), max(raw.x), length.out = 1000)
    density.df <- predict.gmmem(object, newdata = new.x)
    p <- ggplot() +
      geom_histogram(data = hist.df,
                     mapping = aes(x = raw.x, y = ..density..),
                     bins = nb, breaks = brk,
                     color = hist.color, fill = hist.fill) +
      geom_line(data = density.df, mapping = aes(x = x, y = density, color = comp),
                size = 1.1) +
      scale_color_manual(values = dist.color) +
      geom_area(data = density.df, mapping = aes(x = x, y = density, fill = comp),
                position = position_identity(), alpha = dist.alpha) +
      scale_fill_manual(values = dist.fill) +
      geom_vline(xintercept = vline, color = vline.color, size = .8) +
      scale_x_continuous(limits = xlim, breaks = pretty_breaks()) +
      scale_y_continuous(limits = ylim, expand = c(0, 0)) +
      ylab("Density") +
      theme(legend.position = c(.91, .85), legend.justification = c(1, 1),
            legend.title = element_blank(),
            legend.text = element_text(size = 14))
  }
  if (scale == "log") {
    p <- p + xlab("Log10(ASV read count)")
  }
  if (scale == "normal") {
    p <- p + xlab("ASV read count")
  }
  return(p)
}
