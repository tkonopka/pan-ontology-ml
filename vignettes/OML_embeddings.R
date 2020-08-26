# script part of OntoML.Rmd
# Creates umap embeddings based on k15 search results
# (Experimental)


#' combinations of obo data types used in the db and for querying
umap.configs = expand.grid(list(obotype=c("plain"),
                                datatype=c("plain", "parents"),
                                difftype=NA,
                                diffvalue=NA,
                                k=15),
                           stringsAsFactors=FALSE)

search.umap.config = umap.defaults
search.umap.config$input = "data"
search.umap.config$min_dist = 2
search.umap.config$spread = 4
search.umap.config$random_state = 12345


###############################################################################
# create umap embeddings

#' create a umap.knn object from a set of search results
#'
#' @param d.raw data table with raw search results
make.umap.knn.from.search = function(d.raw) {
  d.id = data.table(id=unique(d.raw$id))
  d.id$id.index = seq_len(nrow(d.id))
  d.target = copy(d.id)
  setnames(d.target, c("id", "id.index"), c("target", "target.index"))
  d.aug = merge(merge(d.raw, d.id, by="id"), d.target, by="target")
  indexes = dcast(d.aug, id.index~rank, value.var="target.index")
  distances = dcast(d.aug, id.index~rank, value.var="distance")
  rank.cols = as.character(seq_len(max(d.aug$rank)))
  .to.matrix = function(x) {
    x = x[order(id.index)]
    stopifnot(identical(x$id.index, d.id$id.index))
    x$id.index = NULL
    x = as.matrix(x)[, rank.cols]
    rownames(x) = d.id$id
    x
  }
  indexes = .to.matrix(indexes)
  distances = .to.matrix(distances)
  indexes[,1] = seq_len(nrow(indexes))
  distances[,1] = 0
  result = list(indexes=indexes, distances=distances)
  class(result) = "umap.knn"
  result
}


#' run umap on search data
#' @param oboname character, name of ontology
#' @param configs data frame with configurations
#'
make.umap.embeddings = function(oboname, configs=umap.configs, verbose=TRUE) {
  if (verbose) {
    print(paste(date(), oboname))
  }
  result = list()
  search.results = read.search.results(oboname, configs,
                                       template=file.templates$searchk.results,
                                       add.rank=TRUE)
  for (i in seq_along(search.results)) {
    .id = names(search.results)[i]
    i.search = search.results[[.id]]
    i.knn = make.umap.knn.from.search(i.search)
    i.data = data.frame(a=rep(0, nrow(i.knn$indexes)))
    rownames(i.data) = rownames(i.knn$indexes)
    n.comp = max(2, floor(log2(nrow(i.data)))-8)
    i.umap = umap(i.data, conf=search.umap.config,
                  knn=i.knn, n_components=n.comp)
    result[[.id]] = i.umap$layout
  }
  result
}

if (!assignc("umap.embeddings")) {
 les umap.embeddings = lapply(c("fbdv", "hp"), make.umap.embeddings)
  umap.embeddings = lapply(ontologies.selected, make.umap.embeddings)
  umap.embeddings = Reduce(c, umap.embeddings)
  savec(umap.embeddings)
}
