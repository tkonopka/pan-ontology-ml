# custom histogram


#' barplot/histogram with custom intervals
#'
#' @param x numeric vector
#' @param intervals named vector, bins for discretization
#' @param filtered vector, which of the intervals should be marked with the filtered color
#' @param xlab character, label for x-axis
#' @param ylab character, label for y-axis
#' @param main character, label for chart
#' @param Rcss object of class Rcss
#' @param Rcssclass character, style class
plot.custom.histogram = function(x,
                                 intervals=c("< 1 month"=30, "1-3 months"=91,
                                             "3-6 months"=182, "6-12 months"=365,
                                             "> 1 year"=Inf, "NA"=NA),
                                 filtered=NA, 
                                 xlab="", ylab="", main="",
                                 Rcssclass=c()) {
  
  RcssCompulsoryClass = RcssGetCompulsoryClass(c("customhist", Rcssclass))
  padding = RcssValue("customhist", "padding", default=0.05)
  cols = c(RcssValue("barplot", "col", default="#0000ff"),
           RcssValue("barplot", "col", default="#999999", Rcssclass="filtered"))
  
  counts = rep(0, length(intervals))
  for (i in seq_len(length(intervals))) {
    if (is.na(intervals[i])) {
      counts[i] = sum(is.na(x))
    } else {
      if (i==1) {
        counts[1] = sum(x <= intervals[1], na.rm=TRUE)
      } else {
        counts[i] = sum(x <= intervals[i] & x > intervals[i-1], na.rm=TRUE)
      }
    }
  }
  names(counts) = names(intervals)
  
  par()
  bar.colors = setNames(rep(cols[1], length(counts)), names(intervals))
  bar.colors[filtered] = cols[2]
  bar.positions = barplot(counts, col=bar.colors)

  ylim = c(0, max(counts))  
  axis(2, at=ylim, label=c("", ""), line=0, tck=0, Rcssclass="y")
  axis(2, label=NA, line=0, Rcssclass="y")
  axis(2, lwd=0, Rcssclass="y")
  text(bar.positions[,1], -padding*ylim[2], names(intervals), Rcssclass="x")
  mtext(side=1, xlab, Rcssclass="xlab")
  mtext(side=2, ylab, Rcssclass="ylab")
  mtext(side=3, main, Rcssclass="main")

  invisible(counts)
}


#' plot a histogram with integer bins
#'
#' @param x vector of numbers
#' @param xlab character, label for x-axis
#' @param ylab character, label for y-axis
#' @param main character, label for chart
#' @param xlim numeric of length 2, limits for x-axis
#' @param ylim numeric of length 2, limits for y-axis
#' @param show.x.labels logical, set TRUE to display values on x bins
#' @param Rcssclass character style class
#'
plot.int.hist = function(x,
                         xlab="", ylab="", main="",
                         xlim=NULL, ylim=NULL,
                         show.x.labels=FALSE,
                         Rcssclass=c()) {

  RcssCompulsoryClass = RcssGetCompulsoryClass(c("inthist", Rcssclass))

  xtab = table(x)
  if (is.null(xlim)) {
    xlim = c(-0.5, max(x)+0.5)
  }
  if (is.null(ylim)) {
    ylim = c(0, max(xtab))
  }

  par()
  hist(x, breaks=seq(-0.5, max(x)+0.5), xlim=xlim, ylim=ylim,
       axes=FALSE)
  axis(2, at=ylim, label=c("", ""), line=0, tck=0, Rcssclass="y")
  axis(2, label=NA, line=0, Rcssclass="y")
  axis(2, lwd=0, Rcssclass="y")
  axis(1, at=xlim, label=c("", ""), line=0, tck=0, Rcssclass="x")
  axis(1, label=NA, line=0, Rcssclass="x")
  if (show.x.labels) {
    axis(1, lwd=0, Rcssclass="x")
  }
  mtext(side=1, xlab, Rcssclass="xlab")
  mtext(side=2, ylab, Rcssclass="ylab")
  mtext(side=3, main, Rcssclass="main")
}

