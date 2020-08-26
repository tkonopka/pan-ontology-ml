# helper functions for reading yaml


#' read a yaml document pertaining to an ontology, extract id-parent
#' relationships from the metadata
#' @param oboname characer, name of ontology
#' @param template character, template for file path (will substitute {oboname})
#' @param verbose logical
#'
#' @return data.table with column id, parent
read.parents = function(oboname, template, verbose=TRUE) {
  if (verbose) {
    print(paste(date(), " ", oboname))
  }
  # first read the yaml file as text lines, then parse each item individually
  result = readLines(glue(template))
  result = split(result, cumsum(!startsWith(result, " ")))
  rbindlist(lapply(result, function(x) {
    xmeta = yaml.load(paste(x, collapse="\n"))[[1]]$metadata
    parents = unlist(xmeta$parents)
    if (length(parents)==0) { parents = "" }
    data.frame(id=xmeta$id, parent=parents, stringsAsFactors=FALSE)
  }))
}


#' read two documents for a node2vec layout
#'
#' @param oboname characer, name of ontology
#' @param template.node2vec character, template for file path (layout)
#' @param template.nodes character, template for file path (node names)
#'
#' @return matrix with coordinates
read.node2vec = function(oboname, template.node2vec, template.nodes) {
  # (oboname is not used explicitly in this function, but it is used
  #  by glue() to fill into the templates)
  layout = fread(glue(template.node2vec), skip=1)
  coord_cols = paste0("N2V_", seq_len(ncol(layout)-1))
  colnames(layout) = c("index", coord_cols)
  nodes = fread(glue(template.nodes), skip=0)
  colnames(nodes) = c("index", "id")
  both = merge(layout, nodes, by="index")[order(index)]
  # construct a matrix
  result = as.matrix(both[, coord_cols, with=FALSE])
  rownames(result) = both$id
  result
}

