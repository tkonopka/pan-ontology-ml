# script part of OntoML.Rmd
# wrappers for plot functions


#' series of barplots/boxplots for a set of ontologies
#'
fig.onto.summary = function(d, id.col="ID") {
  plot.bars.group(d, var=id.col, type="label-right")
  plot.bars.group(d, var="num_terms", type="bars",
                  log="x", xlim=c(4, 3000000),
                  at=10^seq(1, 6),
                  at.label=c("", "100", "", "10K", "", "1M"),
                  xlab="Size (num. terms)")
  plot.bars.group(d, var="norm_depth", type="qboxes",
                  xlab="Depth / log2(Size)", xlim=c(0, 3),
                  at=c(0, 1, 2, 3))
  plot.bars.group(d, var="num_parents", type="qboxes",
                  xlim=c(0, 5.7),
                  at=c(0,1,2,3,4,5),
                  xlab="Num. parents")
  plot.bars.group(d, var="perc_zero_chars_def", type="bars",
                  log="", xlim=c(0, 100), xlab="% terms wo. def.",
                  at=c(0, 50, 100), Rcssclass="anno")
  plot.bars.group(d, var="chars_def", type="qboxes",
                  log="x", xlim=c(3, 2000), xlab="Chars. in definition",
                  at=c(10, 100, 1000),
                  at.label=c("10", "100", "1,000"), Rcssclass="anno")
  plot.bars.group(d, var="num_synonyms", type="qboxes",
                  xlim=c(0, 18.5),
                  at=seq(0, 16, by=4),
                  xlab="Num. synonyms", Rcssclass="anno")
}


#' series of barplots/boxplots for a set of ontologies
#' the last column consists of filter status codes
supfig.onto.summary = function(d) {
  fig.onto.summary(d)
  filter.xlab = "Filter"
  if (identical(unique(d$filter), "")) {
    filter.xlab = ""
  }
  plot.bars.group(d, var="filter", type="label-center",
                  xlim=c(0, 18.5),
                  at=seq(0, 16, by=4),
                  xlab=filter.xlab)
}


#' series of scatter plots panels
#'
#' panels show relations between one variable and a set of covariates
#'
#' @param d data table
#' @param y character variable for y-axis
#' @param ylab character label for y-axis
#' @param label.ids list with dots to label in each panel
#' @param panel.label character corner label for first plot
#'
fig.explaining = function(d, y, ylab="Parent retrieval, precision",
                          label.ids=list("_", "_", "_", "_", "_"),
                          adj=c(0.5, -1),
                          panel.label="a") {
  num_terms_at = list(x=10^seq(1, 6, by=2), y=seq(0, 1, by=0.25))
  plot.scatter(d, xy=c("num_terms", y),
               log="x",
               at=num_terms_at,,
               at.labels=list(x=sprintf("%d", num_terms_at$x),
                              y=num_terms_at$y),
               xlim=c(10, 3e6), ylim=c(0, 1),
               xlab="Size (num. terms)",
               ylab=ylab, Rcssclass="large")
  multipanelLabel(panel.label)
  add.scatter.labels(d[id %in% label.ids[[1]]],
                     xy=c("num_terms", y),
                     label="ID", log="x", adj=adj)
  plot.scatter(d, xy=c("avg_num_parents", y),
               log="", at=list(x=c(0.8, 1, 1.2, 1.4, 1.6, 1.8), y=seq(0, 1, by=0.25)),
               xlim=c(0.85, 1.75), ylim=c(0, 1),
               xlab="avg. num. parents",
               ylab="", Rcssclass=c("large", "next"))
  add.scatter.labels(d[id %in% label.ids[[2]]],
                     xy=c("avg_num_parents", y),
                     label="ID", log="", adj=adj)
  plot.scatter(d, xy=c("avg_norm_depth", y),
               log="", at=list(x=c(0, 0.5, 1, 1.5, 2), y=seq(0, 1, by=0.25)),
               xlim=c(0.0, 1.5), ylim=c(0, 1),
               xlab="avg. depth / log(Size)",
               ylab="", Rcssclass=c("large", "next"))
  add.scatter.labels(d[id %in% label.ids[[3]]],
                     xy=c("avg_norm_depth", y),
                     label="ID", log="", adj=adj)
  plot.scatter(d, xy=c("avg_chars_def", y),
               log="x", at=list(x=10^seq(0, 6), y=seq(0, 1, by=0.25)),
               xlim=c(1, 600), ylim=c(0, 1),
               xlab="1 + avg. chars. definitions",
               ylab="", Rcssclass=c("large", "next", "anno"))
  add.scatter.labels(d[id %in% label.ids[[4]]],
                     xy=c("avg_chars_def", y),
                     label="ID", log="x", adj=adj)
  plot.scatter(d, xy=c("avg_chars_comments", y),
               log="x", at=list(x=10^seq(0, 2), y=seq(0, 1, by=0.25)),
               xlim=c(1, 300), ylim=c(0, 1),
               xlab="1 + avg. chars. comments",
               ylab="",
               Rcssclass=c("large", "next", "anno"))
  add.scatter.labels(d[id %in% label.ids[[5]]],
                     xy=c("avg_chars_comments", y),
                     label="ID", log="x", adj=adj)
  invisible(NULL)
}


#' draw text labels explaining mapping for one hp id
#'
#' this creates a two-column layout
#' the first columns shows the query and expected results
#' the second column shows a set of search results
#'
#' @param hp.id character id for one HP term
#' @param x2 numeric, x-position of second column
#' @param Rcssclass character style class
#'
plot.hp.example = function(hp.id, x2=0.5, Rcssclass=NULL) {
  hp.eg.parent = hp$graph$edges[id==hp.id]$target
  hp.eg.hits = hp$search$plain.data.name.diff.parents.0.3[id==hp.id]$target
  hp.eg.hits = hp.eg.hits[hp.eg.hits != hp.id]
  hp.eg.hits = data.table(id=hp.eg.hits, rank=seq_along(hp.eg.hits))
  line.height = RcssValue("ontologyterm", "line.height", default=0.2,
                          Rcssclass=Rcssclass)
  parplot(c(0, 1), c(0, 1), type="n", Rcssclass="ontologyterm")
  add.ontologyterm(hp$terms[id==hp.id], x=0, y=1,
                   main="Query", Rcssclass=Rcssclass)
  add.ontologyterm(hp$terms[id==hp.eg.parent], x=0, y=1-(line.height*3),
                   main="Parent", Rcssclass=Rcssclass)
  add.ontologyterm(merge(hp.eg.hits, hp$terms, by="id")[order(rank)],
                   x=x2, y=1,
                   main="Nearest neighbors", Rcssclass=Rcssclass)
}

