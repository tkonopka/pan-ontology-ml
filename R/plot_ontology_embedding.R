# scatter plots


#' draw a umap layout for an ontology
#'
#' @param u umap object
#' @param node.types data frame with columns id, node_type
#' @param node.order character, determines what node types are plotted on bottom
#' and on top
#' @param show.labels logical, whether to show points or text labels
#' @param xlim numeric of length 2, limits for x-axis
#' @param ylim numeric of length 2, limits for y-axis
#' @param xlab character, label for x axis
#' @param ylab character, label for y axis
#' @param main character, label for whole plot
#' @param legend.pos numeric of length 2, position of legend
#' @param Rcssclass character, style class
plot_ontology_embedding = function(u, node.types,
                                   node.order=c("root", "intermediate", "leaf"),
                                   show.labels=TRUE,
                                   xlim=NULL, ylim=NULL,
                                   xlab="UMAP 1", ylab="UMAP 2", main="",
                                   legend.pos=c(5, 10),
                                   Rcssclass=NULL) {

  xy = u
  if (is(u, "umap")) {
    xy = u$layout
  }

  RcssCompulsoryClass = RcssGetCompulsoryClass(c("embedding", Rcssclass))

  # limits for the plot
  if (is.null(xlim)) {
    xlim = range(xy[,1])
  }
  if (is.null(ylim)) {
    ylim = range(xy[,2])
  }

  # start empty plot
  parplot(xlim, ylim, xlim=xlim, ylim=ylim)
  box()

  xydf = data.frame(id=rownames(xy), x=xy[,1], y=xy[,2])
  xydf = merge(xydf, node.types, by="id")
  xysplit = split(xydf, xydf$node_type)
  if (is.null(node.order))
    node.order = names(xysplit)
  legend.data = list(cex = c(), lwd=c(), col=c(), bg=c())
  for (g in rev(node.order)) {
    .data = xysplit[[g]]
    if (show.labels) {
      text(.data[["x"]], .data[["y"]], rownames(.data), Rcssclass=g)
    } else {
      legend.data$cex[g] = RcssValue("points", "cex", default=1, Rcssclass=g)
      legend.data$col[g] = RcssValue("points", "col", default=0, Rcssclass=g)
      legend.data$lwd[g] = RcssValue("points", "lwd", default=1, Rcssclass=g)
      legend.data$bg[g] = RcssValue("points", "bg", default=0, Rcssclass=g)
      points(.data[["x"]], .data[["y"]], pch=21, Rcssclass=g)
    }
  }
  if (!show.labels & !is.null(legend.pos)) {
    legend(legend.pos[1], legend.pos[2], node.order,
           pt.cex=legend.data$cex[node.order],
           pt.bg=legend.data$bg[node.order],
           pt.lwd=legend.data$lwd[node.order],
           col=legend.data$col[node.order])
  }

  mtext(side=1, xlab, Rcssclass="xlab")
  mtext(side=2, ylab, Rcssclass="ylab")
  mtext(side=3, main, Rcssclass="main")
  
}

