# script part of OntoML.Rmd
# create a graph for a simple ontology


# name of obo to be used for the small graph
small.graph.oboname = "mp-heartbeat"


#' collect data on an ontology graph from a crossmap data yaml file
#'
#' @param links data table with two columns, id and parent
#' @param layout_fun function from igraph, acting on a graph and returning a
#' layout
#' @param remove.only.target logical, set TRUE to avoid using nodes that
#' only appear as a target node
#'
#' @return list with nodes, edges, and a graph layout
make.ontology.graph = function(links, layout_fun=layout_with_fr,
                               remove.only.target=TRUE) {
  links = data.table(links)
  colnames(links) = c("id", "target")
  edges = unique(links[, c("id", "target")])
  if (remove.only.target) {
    edges[!target %in% id, "target"] = NA
  }
  edges = edges[!is.na(target)]
  nodes = unique(edges$id)
  # create graph and layout, fix a rotation with PCA
  .graph = igraph::graph_from_edgelist(as.matrix(edges))
  .layout = layout_fun(.graph)
  rownames(.layout) = vertex_attr(.graph)$name
  .layout = prcomp(.layout)$x
  list(nodes = nodes, edges = edges,
       graph = .graph, layout = .layout[, c(2,1)])
}


#' read yaml for one ontology
#'
#' @param oboname character, name of ontology
#'
#' @return list mapping ids to ontology data
read.ontology.data = function(oboname) {
  read_yaml(glue(file.templates$parents.yaml))
}


if (!exists("small.graph.data")) {
  small.graph.data = read.ontology.data(small.graph.oboname)
}


if (!exists("small.graph")) {
  small.graph =
    make.ontology.graph(read.parents(small.graph.oboname,
                                     template=file.templates$metadata,
                                     verbose=FALSE),
                        remove.only.target = TRUE)
}

if (!exists("small.graph.search.results")) {
  small.graph.search.results =
    read.search.results(small.graph.oboname, add.rank=TRUE,
                        template=file.templates$search.results)
}

