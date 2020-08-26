# yaml plots

#' draw a yaml-like structure using text boxes
#'
#' @param d list with text data
#' @param main character, title for the plot
#' @param Rcssclass character, style class
plot.yaml = function(d, main="", max.chars=56, Rcssclass=NULL) {

  RcssCompulsoryClass = RcssGetCompulsoryClass(c("yaml", Rcssclass))
  indent = RcssValue("yaml", "indent", default=0.02)
  key.width = RcssValue("yaml", "key.width", default=0.04)
  line.height = RcssValue("yaml", "line.height", default=0.02)

  xlim = ylim = c(0, 1)
  # start empty plot
  parplot(xlim, ylim, xlim=xlim, ylim=ylim)

  # helper to shorten text to a maximal length
  shorten = function(x) {
    if (nchar(x)<max.chars)
      return(x)
    paste0(substr(x, 1, max.chars-3), "...")
  }
  # helper to draw one key-value pair
  draw.k.v = function(k, v, position=list(x=-indent, y=1+line.height), root=TRUE) {
    x = position$x
    y = position$y
    if (!root) {
      if (is.null(k)) {
        text(x, y, "-", Rcssclass="key")
      } else {
        text(x, y, paste0(k, ":"), Rcssclass="key")
      }
    }
    if (is(v, "character")) {
      for (i in seq_along(v)) {
        text(x+key.width, y, shorten(v[[i]]), Rcssclass="text")
        y = y-line.height
      }
      position = list(x=x, y=y)
    } else if (is(v, "list")) {
      position = list(x=x+indent, y=y-line.height)
      for (i in seq_along(v)) {
        position = draw.k.v(names(v)[i], v[[i]], position, root=FALSE)
      }
    }
    position
  }
  draw.k.v(NULL, d)

  mtext(side=3, main, Rcssclass="main")
}

