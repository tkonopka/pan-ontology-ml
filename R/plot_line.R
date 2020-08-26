# line chart


#' line plot with dots
#'
#' @param d data table
#' @param x character, column for x-axis
#' @param y character vector, columns for y-axis
#' @param show.points logical, display points as markers on top of lines
#' @param xlab character, label for x-axis
#' @param ylab character, label for y-axis
#' @param main character, label for main title
#' @param xlim numeric of length 2, limits for x-axis
#' @param ylim numeric of length 2, limits for y-axis
#' @param Rcssclass character, style class
#'
plot.lines = function(d, x, y,
                      show.points=TRUE,
                      xlab="", ylab="", main="",
                      xlim=NULL, ylim=NULL,
                      Rcssclass=c()) {

  RcssCompulsoryClass = RcssGetCompulsoryClass(c("lines", Rcssclass))

  if (is.null(xlim)) {
    xlim = range(d[[x]])
  }
  if (is.null(ylim)) {
    ylim = range(unlist(d[[y]]))
  }

  parplot(xlim, ylim, type="n")
  add.line(d, x, y, show.points=show.points)

  axis(1, at=xlim, labels=c("", ""), line=0, tck=0, Rcssclass="x")
  axis(1, labels=NA, line=0, Rcssclass="x")
  axis(1, lwd=0, Rcssclass="x")
  mtext(side=1, xlab, Rcssclass="xlab")
  axis(2, at=ylim, labels=c("", ""), line=0, tck=0, Rcssclass="y")
  axis(2, labels=NA, line=0, Rcssclass="x")
  axis(2, lwd=0, Rcssclass="y")
  mtext(side=2, ylab, Rcssclass="ylab")
  mtext(side=3, main, Rcssclass="main")
}


#' add a line with dots
#'
#' (this assumes a plot area has already been drawn)
#'
#' @param d data table
#' @param x character, column for x-axis
#' @param y character vector, columns for y-axis
#' @param show.points logical, display points as markers on top of lines
#'
add.line = function(d, x, y, show.points=TRUE, Rcssclass=c()) {
  d = d[order(d[[x]]),]
  lines(d[[x]], d[[y]], Rcssclass=Rcssclass)
  if (show.points) {
    points(d[[x]], d[[y]], Rcssclass=Rcssclass)
  }
}