# barplot


#' plot a group of bars
#'
#' @param d data table with wide data
#' @param var character, variable name to display
#' @param type character, toggle display of the panel
#' @param log character, set to "x" to transform axis
#' @param xlim numeric of length 2, limits for x-axis
#' @param xlab character, label for x-axis
#' @param ylab character, label for y-axis
#' @param main character, label for chart
#' @param separators.every integer, draw a separator every few rows
#' @param at
#' @param at.labels
#' @param Rcssclass character, style class
plot.bars.group = function(d,
                           var="value",
                           type=c("label-left", "label-right", "label-center",
                                  "bars", "qboxes"),
                           log="", xlim=NULL,
                           xlab="", ylab="", main="",
                           separators.every=5,
                           at=NA,
                           at.labels=NA,
                           Rcssclass=c()) {
  
  type = match.arg(type)
  RcssCompulsoryClass = RcssGetCompulsoryClass(c("bars", Rcssclass))
  barwidth = RcssValue("bars", "width", default=1.0)
  bw2 = barwidth / 2
  
  ylim = c(-nrow(d)-bw2/2, 0+bw2/2)
  ycenters = seq(-1, -nrow(d), by=-1)+0.5
  if (identical(at.labels, NA)) {
    at.labels = at
  }
  
  # some helper functions to draw sub-parts
  add.panel.label = function() {
    xlim = c(0, 1)
    parplot(xlim, ylim, Rcssclass="labels")
    if (grepl("right", type)) {
      text(1, ycenters, d[[var]], Rcssclass=c("axis", "right"))
    } else if (grepl("left", type)) {
      text(0, ycenters, d[[var]], Rcssclass=c("axis", "left"))
    } else {
      text(0.5, ycenters, d[[var]], Rcssclass=c("axis", "center"))
    }
    mtext(side=2, ylab, Rcssclass="ylab")
    mtext(side=3, xlab, Rcssclass="xlab")
  }
  add.panel.axis = function() {
    xlim = graphics::par()$usr[1:2]
    if (log=="x") { at = log10(at) }
    axis(3, at=xlim, label=c("", ""), line=0, tck=0, Rcssclass="x")
    axis(3, at=at, label=NA, line=0, Rcssclass="x")
    for (i in seq_along(at.labels)) {
      axis(3, at=at[i], label=at.labels[i], lwd=0, Rcssclass="x")
    }
    mtext(side=3, xlab, Rcssclass="xlab")
    if (!identical(separators.every, NA)) {
      separators = seq(0, -nrow(d), by=-separators.every)[-1]
      if (length(separators)>0) {
        lines(rep(c(xlim, NA), length(separators)),
              rep(separators, each=3),
              Rcssclass="separator")
      }
    }
  }
  add.panel.bars = function() {
    if (is.null(xlim)) { xlim = c(0, max(d[[var]])) }
    if (log=="x") { xlim=log10(xlim) }
    parplot(xlim, ylim, Rcssclass="bars")
    add.panel.axis()
    if (log=="x") {
      # do not plot bars on log-scale! Use line markers instead.
      lines(rep(log10(d[[var]]), each=3),
            as.numeric(rbind(ycenters-bw2, ycenters+bw2, NA)),
            Rcssclass="bar")
    } else {
      rect(0, ycenters-bw2, d[[var]], ycenters+bw2, Rcssclass="bar")
    }
    axis(2, at=ylim, label=c("", ""), line=0, tck=0, Rcssclass="y")
  }
  add.panel.qboxes = function() {
    if (is.null(xlim)) {
      xlim = c(0, max(d[[var]]))
    }
    if (log=="x") {
      xlim = log10(xlim)
    }
    parplot(xlim, ylim, Rcssclass="qboxes")
    add.panel.axis()
    transform = function(x) {x}
    if (log=="x") transform=log10
    v05 = transform(d[[paste0("q05_", var)]])
    v25 = transform(d[[paste0("q25_", var)]])
    v50 = transform(d[[paste0("q50_", var)]])
    v75 = transform(d[[paste0("q75_", var)]])
    v95 = transform(d[[paste0("q95_", var)]])
    vmin = transform(d[[paste0("min_", var)]])
    vmax = transform(d[[paste0("max_", var)]])
    # points(vmin, ycenters, Rcssclass="extrema")
    points(vmax, ycenters, Rcssclass="extrema")
    lines(as.numeric(rbind(v05, v95, NA)),
          rep(ycenters, each=3),
          Rcssclass="whisker")
    rect(v25, ycenters-bw2, v75, ycenters+bw2,
         Rcssclass="box")
    lines(rep(v50, each=3),
          as.numeric(rbind(ycenters-bw2, ycenters+bw2, NA)),
          Rcssclass="median")
    axis(2, at=ylim, label=c("", ""), line=0, tck=0, Rcssclass="y")
  }
  
  # build up the plot from components using the helper functions
  if (grepl("label", type)) {
    add.panel.label()
  } else {
    if (type=="qboxes") {
      add.panel.qboxes()
    } else if (type=="bars") {
      add.panel.bars()
    }
  }
}



#' simple barplot (horizontal)
#'
#' @param x numeric vector
#' @param xlim numeric of length 2, limits for x axis
#' @param xlab character, label for x-axis
#' @param main character, label for main plot
#' @param at numeric, position of ticks
#' @param Rcssclass character, style class
#'
plot.simplebars = function(x, xlim=NULL, xlab="", main="",
                           at=seq(0, 1, by=0.2),
                           Rcssclass=NULL) {

  RcssCompulsoryClass = RcssGetCompulsoryClass(c("simplebars", Rcssclass))
  if (is.null(xlim)) {
    xlim = c(0, max(x, na.rm=TRUE))
  }

  par()
  ypos = barplot(x, axes=FALSE, names=FALSE, xlim=xlim)

  axis(1, at=xlim, label=c("", ""), line=0, tck=0, Rcssclass="x")
  axis(1, at=at, label=NA, line=0, Rcssclass="x")
  axis(1, at=at, label=at, lwd=0, Rcssclass="x")
  axis(2, at=ypos[,1], lwd=0, label=names(x), Rcssclass="y")
  mtext(side=1, xlab, Rcssclass="xlab")
  mtext(side=3, main, Rcssclass="main")

}

