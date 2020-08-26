# a heatmap


#' draw a heatmap
#'
#' @param m matrix
#' @param drop.na logical, set TRUE to drop rows in m that only have NA values
#' @param color.fun function to generate colors
#' @param color.direction numeric, argument 'direction' to color.fun
#' @param color.max numeric, value that saturates the color scale
#' @param xlab character, label for x-axis
#' @param ylab character, label for y-axis
#' @param main character, title label
#' @param legend.main character, title for legend
#' @param Rcssclass character, style class
plot.heatmap = function(m, drop.na=TRUE,
                        color.fun=magma, color.direction=1, color.max=1,
                        xlab="", ylab="", main="", legend.main="Weight",
                        Rcssclass=NULL) {

  if (drop.na) {
    some.not.na = function(x) { !all(is.na(x)) }
    m = m[apply(m, 1, some.not.na), , drop=FALSE]
  }

  RcssCompulsoryClass = RcssGetCompulsoryClass(c("heatmap", Rcssclass))
  color.vector = color.fun(101, begin=0, end=1, direction=color.direction)
  xlim = c(0.5, nrow(m)+0.5)
  ylim = -c(ncol(m)+0.5, 0.5)

  parplot(xlim, ylim, xlim=xlim, ylim=ylim, xaxs="i", yaxs="i")

  # x-axis labels - at an angle
  x.line = RcssValue("axis", "line", default=-0.3, Rcssclass="x")
  text(seq_len(nrow(m)), min(ylim)-x.line, gsub("_", " ", rownames(m)),
       Rcssclass="x")
  # y-axis labels - usual axis, but ensure all labels are printed
  for (i in seq_len(ncol(m))) {
    axis(2, at=-i, label=gsub("_", " ", colnames(m)[i]),
         lwd=0, Rcssclass="y")
  }
  mtext(side=1, xlab, Rcssclass="xlab")
  mtext(side=2, ylab, Rcssclass="ylab")
  mtext(side=3, main, Rcssclass="main")

  # draw the heatmap boxes
  for (x in seq_len(nrow(m))) {
    for (y in seq_len(ncol(m))) {
      .value = m[x, y]
      if (is.na(.value)) {
        rect(x-0.5, -y-0.5, x+0.5, -y+0.5, Rcssclass="NA")
      } else {
        .col = color.vector[round(min(1, .value/color.max)*100)]
        rect(x-0.5, -y-0.5, x+0.5, -y+0.5, col=.col)
      }
    }
  }
  box()

  # draw the legend
  l.height = RcssValue("heatmap", "legend.height", default=0.5)
  l.width = RcssValue("heatmap", "legend.width", default=0.05)
  l.pad = RcssValue("heatmap", "legend.padding", default=0.05)
  l.text = RcssValue("heatmap", "legend.textpad", default=0.02)
  legend.x = xlim[2] + xlim[2]*(l.pad + c(0, l.width, l.width+l.text))
  legend.y = mean(ylim) + c(-1, 1)*l.height/2
  legend.scale = seq(legend.y[1], legend.y[2], length=length(color.vector))
  rect(legend.x[1], legend.scale[-length(legend.scale)],
       legend.x[2], legend.scale[-1], col=color.vector,
       Rcssclass=c("legend", "inner"))
  rect(legend.x[1], legend.y[1], legend.x[2], legend.y[2],
       Rcssclass=c("legend", "outer"))
  text(legend.x[3], c(legend.y[1], mean(legend.y), legend.y[2]),
       color.max*c(0, 0.5, 1), Rcssclass="legend")
  text(legend.x[1], legend.y[2], legend.main,
       Rcssclass=c("legend", "main"))
}

