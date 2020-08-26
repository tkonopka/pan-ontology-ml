# helper functions


#' add text labels with ontology ids and term names
#'
#' adds a title label, and a list of ontology term names
#'
#' @param d data frame with at least column $name
#' @param x numeric, x coordinate of title line
#' @param y numeric, y coordinate of title line
#' @param show.ids logical, toggle visibility of id terms
#' @param main character title
#' @param Rcssclass character, style class
#'
add.ontologyterm = function(d, x=0, y=1, show.ids=TRUE,
                            main="",
                            Rcssclass=c()) {

  RcssCompulsoryClass = RcssGetCompulsoryClass(c("ontologyterm", Rcssclass))
  id.width = RcssValue("ontologyterm", "id.width", default=0.1)
  line.height = RcssValue("ontologyterm", "line.height", default=0.15)

  text(x, y, main, Rcssclass="main")
  ycoord = y-seq_len(nrow(d))*line.height
  if (show.ids) {
    text(x, ycoord, d$id, Rcssclass="id")
    text(x+id.width, ycoord, d$name, Rcssclass="term")
  } else {
    text(x, ycoord, d$name, Rcssclass="term")
  }

}

