# table as a heatmap


#' draw one or two tables as heatmaps
#'
#' @param m1 matrix first table
#' @param m2 matrix optional, a second table
#' @param color.fun function to generate colors
#' @param color.direction numeric, argument 'direction' to color.fun
#' @param xlab character, label for x-axis
#' @param ylab character, label for y-axis
#' @param main1 character, title label for first heatmap
#' @param main2 character, title label for second heatmap
#' @param digits integer, number of significant digits
#' @param Rcssclass character, style class
plot.heattable = function(m1, m2=NULL,
                          color.fun=magma, color.direction=1,
                          xlab="", ylab="", legend.main="Precision",
                          main1="", main2="",
                          digits=2,
                          Rcssclass=c()) {

  RcssCompulsoryClass = RcssGetCompulsoryClass(c("heattable", Rcssclass))
  between = RcssValue("heattable", "between", default=0.5)
  color.vector = color.fun(101, begin=0, end=1, direction=color.direction)
  n1 = ncol(m1)

  # limits for the plot
  if (is.null(m2)) {
    n2 = 0
    xlim = c(0.5, n1 + 0.5)
    xpos = seq_len(n1)
  } else {
    n2 = ncol(m2)
    xlim = c(0.5, n1 + n2 + 0.5 + between)
    xpos = c(seq_len(n1), + between + seq(n1+1, n1+n2))
  }
  ylim = -c(nrow(m1)+0.5, 0.5)

  parplot(xlim, ylim, xlim=xlim, ylim=ylim)

  axis(1, at=xpos[seq_len(n1)], label=colnames(m1),
       lwd=0, Rcssclass="x")
  axis(3, at=mean(xpos[seq_len(n1)]), label=main1,
       lwd=0, Rcssclass="main")
  if (!is.null(m2)) {
    axis(1, at=xpos[seq(n1+1, n1+n2)], label=colnames(m1),
         lwd=0, Rcssclass="x")
    axis(3, at=mean(xpos[seq(n1+1, n1+n2)]), label=main2,
         lwd=0, Rcssclass="main")
  }
  axis(2, at=-seq_len(nrow(m1)), label=rownames(m1), lwd=0, Rcssclass="y")
  mtext(side=1, xlab, Rcssclass="xlab")
  mtext(side=2, ylab, Rcssclass="ylab")

  # draw the contingency table boxes
  add.contingency.heatmap = function(m, xvals=c(1,2)) {
    if (is.null(m)) { return() }
    yrange = c(-1, -nrow(m))
    for (x in seq_len(ncol(m))) {
      for (y in seq_len(nrow(m))) {
        .col = color.vector[round(m[y,x]*100)]
        rect(xvals[x]-0.5, -y-0.5, xvals[x]+0.5, -y+0.5, col=.col)
        text(xvals[x], -y, signif(m[y,x], digits),
             Rcssclass=ifelse(m[y,x]>0.5, "high", "low"))
      }
    }
    rect(min(xvals)-0.5, yrange[1]+0.5, max(xvals)+0.5, yrange[2]-0.5,
         xpd=1, col=NA, Rcssclass="outer")
  }
  add.contingency.heatmap(m1, xvals=xpos[seq_len(n1)])
  add.contingency.heatmap(m2, xvals=xpos[seq(n1+1, n1+n2)])

  # draw the legend
  l.height = RcssValue("heattable", "legend.height", default=0.5)
  l.width = RcssValue("heattable", "legend.width", default=0.05)
  l.pad = RcssValue("heattable", "legend.padding", default=0.05)
  l.text = RcssValue("heattable", "legend.textpad", default=0.02)
  legend.x = xlim[2] + l.pad + c(0, l.width, l.width+l.text)
  legend.y = mean(ylim) + c(-1, 1)*l.height/2
  legend.scale = seq(legend.y[1], legend.y[2], length=length(color.vector))
  rect(legend.x[1], legend.scale[-length(legend.scale)],
       legend.x[2], legend.scale[-1], col=color.vector,
       Rcssclass=c("legend", "inner"))
  rect(legend.x[1], legend.y[1], legend.x[2], legend.y[2],
       Rcssclass=c("legend", "outer"))
  text(legend.x[3], c(legend.y[1], mean(legend.y), legend.y[2]),
       c(0, 0.5, 1), Rcssclass="legend")
  text(legend.x[1], legend.y[2], legend.main,
       Rcssclass=c("legend", "main"))
}

