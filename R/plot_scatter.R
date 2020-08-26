# scatter plots


#' draw a scatter plot
#'
#' @param d data frame
#' @param xy character, columns in d for axes
#' @param color character, column in d with colors
#' @param log character, use "xy" for log scale
#' @param xlim numeric of length 2, limits for x-axis
#' @param ylim numeric of length 2, limits for y-axis
#' @param xlab character, label for x-axis
#' @param ylab character, label for y-axis
#' @param at list with components x and y, position of tick marks
#' @param at.labels list with components x and y, text labels to match argument at
#' @param main character, label for whole plot
#' @param Rcssclass character, style class
plot.scatter = function(d,
                        xy=colnames(d)[1:2],
                        color=NA,
                        log="xy",
                        xlim=NULL, ylim=NULL,
                        main="", xlab="", ylab="",
                        at=list(x=10^seq(0, 6), y=10^seq(0, 6)),
                        at.labels=NA,
                        Rcssclass=c()) {
  
  d = as.data.frame(d)
  RcssCompulsoryClass = RcssGetCompulsoryClass(c("scatter", Rcssclass))
  
  # limits for the plot
  x = xy[1]
  if (is.null(xlim)) {
    xlim = c(0, max(d[,x]))
  }
  y = xy[2]
  if (is.null(ylim)) {
    ylim = c(0, max(d[,y]))
  }
  
  # helper to select values in a range
  in.range = function(z, zlim) {
    z[z>=zlim[1] & z<=zlim[2]]
  }
  at$x = in.range(at$x, xlim)
  at$y = in.range(at$y, ylim)
  if (identical(at.labels, NA)) {
    at.labels = at
  }
  
  if (log %in% c("x", "xy")) {
    xlim = log10(xlim)
    d[, x] = log10(d[, x])
    at$x = log10(at$x)
  }
  if (log %in% c("y", "xy")) {
    ylim = log10(ylim)
    d[, y] = log10(d[, y])
    at$y = log10(at$y)
  }
  
  # start empty plot  
  parplot(xlim, ylim, xlim=xlim, ylim=ylim)
  
  if (is.na(color)) {
    points(d[,x], d[,y])
  } else {
    points(d[,x], d[,y], col=d[, color])
  }
  
  axis(1, at=xlim, label=c("", ""), line=0, tck=0, Rcssclass="x")
  axis(1, at=at$x, label=NA, line=0, Rcssclass="x")
  axis(1, at=at$x, label=at.labels$x, lwd=0, Rcssclass="x")
  axis(2, at=ylim, label=c("", ""), line=0, tck=0, Rcssclass="y")
  axis(2, at=at$y, label=NA, line=0, Rcssclass="y")
  if (ylab!="") {
    axis(2, at=at$y, label=at.labels$y, lwd=0, Rcssclass="y")
  }

  mtext(side=1, xlab, Rcssclass="xlab")
  mtext(side=2, ylab, Rcssclass="ylab")
  mtext(side=3, main, Rcssclass="main")
  
}




#' add text labels to certain points
#'
#' @param d data table
#' @param xy character, column for x- and y-axis
#' @param label, column with label
#' @param log character, codes for logarithms on axes
#' @param adj numeric of length 2, parameter adj for text()
#' @param Rcssclass character, style class
add.scatter.labels = function(d, xy=colnames(d)[1:2], label=colnames(d)[3],
                              log="xy",
                              adj=NA,
                              Rcssclass=c()) {

  if (nrow(d)==0) return(NULL)

  RcssCompulsoryClass = RcssGetCompulsoryClass(c("scatter", Rcssclass))
  d = as.data.frame(d)

  x = xy[1]
  y = xy[2]
  if (log %in% c("x", "xy")) {
    d[, x] = log10(d[, x])
  }
  if (log %in% c("y", "xy")) {
    d[, y] = log10(d[, y])
  }

  text(d[,x], d[,y], d[, label], adj=adj, Rcssclass="label")

}

