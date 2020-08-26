# graph/network with nodes and edges



#' draw a network (graph)
#'
#' @param layout matrix with two columns for x-y coordinates
#' @param edges data frame/table with objects and nearest neighbors
#' @param show.lines character, style for plotting edges between points
#' @param show.points logical, toggle visibility of graph points
#' @param legend.pos numeric of length 2, position of legend
#' @param legend.main character, title for the legend
#' @param Rcssclass character, style class
#'
plot.graph = function(layout, edges=NULL, main="",
                      show.lines=c("simple", "none", "rank", "arrows"),
                      show.points=c("plain", "none", "self"),
                      show.labels=TRUE,
                      legend.pos=NA, legend.main="Predictions",
                      add=FALSE,
                      Rcssclass=c()) {

  show.lines = match.arg(show.lines)
  xlim = range(layout[,1])
  ylim = range(layout[,2])
  RcssCompulsoryClass = RcssGetCompulsoryClass(c("graph", Rcssclass))

  if (!add) {
    parplot(xlim, ylim, xlim=xlim, ylim=ylim)
  }

  # draw the lines
  edges = as.matrix(edges)
  if (show.lines %in% c("simple", "arrows")) {
    edges.list = list(rank_0=edges)
  } else if (show.lines == "rank") {
    edges.list = split(data.table(edges[, c("id", "target")]), edges[, "rank"])
    names(edges.list) = paste0("rank_", names(edges.list))
  }

  line.col = c()
  line.lwd = c()
  edges.names = names(edges.list)
  add.arrows = function(edges.tab, Rcssclass) {
    edges.tab = as.matrix(edges.tab[,1:2])
    edges.tab = edges.tab[edges.tab[,1]!=edges.tab[,2], , drop=FALSE]
    arr.length = RcssValue("Arrows", "arr.length", default=1,
                           Rcssclass=Rcssclass)
    arr.width = RcssValue("Arrows", "arr.width", default=1,
                          Rcssclass=Rcssclass)
    arr.col = RcssValue("Arrows", "col", default="#000000",
                        Rcssclass=Rcssclass)
    if (show.lines=="simple") {
      for (i in seq_len(nrow(edges.tab))) {
        coord.id = layout[edges.tab[i,1], ]
        coord.parent = layout[edges.tab[i,2], ]
        lines(c(coord.id[1], coord.parent[1]), c(coord.id[2], coord.parent[2]),
              col=arr.col)
      }
    } else {
      for (i in seq_len(nrow(edges.tab))) {
        coord.id = layout[edges.tab[i,1], ]
        coord.parent = layout[edges.tab[i,2], ]
        Arrows(coord.id[1], coord.id[2],
               coord.parent[1], coord.parent[2], xpd=1,
               col=arr.col, lcol=arr.col,
               arr.length=arr.length, arr.width=arr.width,
               arr.adj=1)
      }
    }
  }
  if (show.lines %in% c("simple", "rank", "arrows")) {
    for (r in rev(edges.names)) {
      add.arrows(edges.list[[r]], Rcssclass=r)
    }
  }
  # draw points
  if (show.points %in% "self") {
    self.hits = unique(edges[edges[,1]==edges[,2], 1])
    self.nonhits = setdiff(rownames(layout), self.hits)
    if (length(self.hits)) {
      points(layout[self.hits,1], layout[self.hits,2], Rcssclass="selfhit")
    }
    if (length(self.nonhits)) {
      points(layout[self.nonhits,1], layout[self.nonhits,2], Rcssclass="selfmiss")
    }
  } else if (show.points == "plain") {
    points(layout[,1], layout[,2])
  }

  mtext(side=3, main, Rcssclass="main")



  invisible(edges.list)
}



#' draw a separate panel with a legend for a graph
#'
#' @param k integer, number of line types to draw
#' @param y numeric, y-coordinates of two rows of the legend
#' @param Rcssclass character, style class
plot.graph.legend = function(k=3, y=c(0.33, 0.66), Rcssclass=c()) {
  RcssCompulsoryClass = RcssGetCompulsoryClass(c("graph", Rcssclass))
  xylim = c(0, 1)
  parplot(xylim, xylim, xlim=xylim, ylim=xylim, Rcssclass="legend")

  # padding for legend (space between points and text)
  padding = RcssValue("graphlegend", "padding", default=0.01)
  xpad = 1/(2*k)
  xpos = seq(xpad, 1-xpad, length=k)

  # draw hit/miss points
  points.pch = c(RcssValue("points", "pch", default=19, Rcssclass="selfmiss"),
                 RcssValue("points", "pch", default=19, Rcssclass="selfhit"))
  points.col = c(RcssValue("points", "col", default=1, Rcssclass="selfmiss"),
                 RcssValue("points", "col", default=1, Rcssclass="selfhit"))
  points.bg = c(RcssValue("points", "bg", default=1, Rcssclass="selfmiss"),
                 RcssValue("points", "bg", default=1, Rcssclass="selfhit"))
  points.lwd = c(RcssValue("points", "lwd", default=1, Rcssclass="selfmiss"),
                 RcssValue("points", "lwd", default=1, Rcssclass="selfhit"))
  points(xpos[1:2]-2*padding, rep(y[2], 2),
         pch=points.pch, col=points.col, lwd=points.lwd, bg=points.bg)
  text(xpos[1:2]+padding, rep(y[2], 2), c("miss", "hit"), Rcssclass="legend")

  # draw arrows
  for (.k in seq_len(k)) {
    .kclass = paste0("rank_", .k)
    arr.length = RcssValue("Arrows", "arr.length", default=1,
                           Rcssclass=.kclass)
    arr.width = RcssValue("Arrows", "arr.width", default=1,
                          Rcssclass=.kclass)
    arr.col = RcssValue("Arrows", "col", default="#000000",
                        Rcssclass=.kclass)
    Arrows(xpos[.k]-5*padding, y[1],
           xpos[.k]-1*padding, y[1],
           xpd=1, col=arr.col, lcol=arr.col,
           arr.length=arr.length, arr.width=arr.width, arr.adj=1)
    text(xpos[.k]+padding, y[1], paste0("rank ", .k), Rcssclass="legend")
  }
}

